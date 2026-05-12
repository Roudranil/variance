// lib/presentation/debug/debug_error_overlay.dart
//
// DebugErrorOverlay — development-only in-app error display system.
//
// This file implements the full debug overlay feature:
//   - T-209: Widget scaffold + _ErrorEntry model + static capture() method.
//   - T-212: Scrollable error detail panel with prev/next navigation.
//   - T-213: Clipboard actions — Copy and Record Bug buttons.
//   - T-214: Dismiss action and persistent error-count badge.
//
// Architecture:
//   - [DebugErrorOverlay] wraps the app child in a [Stack].
//   - In release mode (`kDebugMode == false`), the widget returns [child]
//     with zero overhead — no observers, no state, no overhead.
//   - The static [DebugErrorOverlay.capture] method appends an [_ErrorEntry]
//     to an internal [ValueNotifier<List<_ErrorEntry>>] visible across the
//     entire debug session.
//   - The overlay panel is full-screen [Material] shown above the child.
//   - When dismissed, a floating badge shows the error count and re-opens
//     the panel on tap.
//
// Test cases (see test/widget/debug/debug_error_overlay_test.dart):
//   1. capture() no-ops when kDebugMode == false (verified via the enabledForTest
//      escape hatch parameter).
//   2. capture() appends an _ErrorEntry with the correct fields.
//   3. overlay panel renders: error type, message, short trace, timestamp.
//   4. prev/next navigation works across multiple captured entries.
//   5. Copy button payload contains the error message.
//   6. Record Bug payload contains "Bug Report" and the error message.
//   7. Dismiss hides the panel but shows the badge with correct count.
//   8. Tapping the badge re-opens the panel.
//   9. FlutterError.reportError triggers overlay capture and panel appears.
//  10. DatabaseFailure via Riverpod observer shows correct type and message.
//  11. ValidationFailure via Riverpod observer shows correct type.
//  12. Overlay is absent when kDebugMode == false (via enabledForTest=false).

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:variance/domain/core/failure.dart';

// ---------------------------------------------------------------------------
// Error entry model
// ---------------------------------------------------------------------------

/// Internal model for a single captured error event.
///
/// Holds all fields needed for display and clipboard payloads.
@immutable
class _ErrorEntry {
  /// Creates an [_ErrorEntry].
  ///
  /// Parameters:
  /// - [errorType]: Short class name of the error (e.g. 'FlutterError').
  /// - [message]: Human-readable error message.
  /// - [tersedTrace]: First 10 frames from [Chain.terse], for display.
  /// - [fullTrace]: Raw stack trace string, for clipboard payloads.
  /// - [route]: Current route at the time of capture, if known.
  /// - [useCaseName]: Riverpod provider name, if error came from a provider.
  /// - [timestamp]: When the error was captured.
  const _ErrorEntry({
    required this.errorType,
    required this.message,
    required this.tersedTrace,
    required this.fullTrace,
    this.route,
    this.useCaseName,
    required this.timestamp,
  });

  /// Short class name of the error (e.g. 'FlutterError', 'DatabaseFailure').
  final String errorType;

  /// Human-readable error message.
  final String message;

  /// Abbreviated stack trace (first 10 frames via Chain.terse), for display.
  final String tersedTrace;

  /// Raw stack trace string, for clipboard payloads.
  final String fullTrace;

  /// Current GoRouter route at the time of capture, if known.
  final String? route;

  /// Riverpod provider name, if the error came via [DebugErrorObserver].
  final String? useCaseName;

  /// When the error was captured (UTC).
  final DateTime timestamp;
}

// ---------------------------------------------------------------------------
// Shared error list (debug-mode only)
// ---------------------------------------------------------------------------

/// Internal shared state — the list of all captured [_ErrorEntry] instances.
///
/// Declared at library scope so [DebugErrorOverlay.capture] (a static method)
/// can append to it without requiring a reference to the widget instance.
///
/// Access is guarded by `kDebugMode` at every write site.
final ValueNotifier<List<_ErrorEntry>> _errorNotifier =
    ValueNotifier<List<_ErrorEntry>>(<_ErrorEntry>[]);

// ---------------------------------------------------------------------------
// DebugErrorOverlay
// ---------------------------------------------------------------------------

/// Wraps [child] with a floating debug error panel shown only in debug mode.
///
/// In release builds (`kDebugMode == false`), the widget returns [child]
/// directly with zero cost — no observers, no stack, no rendering overhead.
///
/// Usage: Wrap [MaterialApp] (or the topmost widget) with [DebugErrorOverlay]:
/// ```dart
/// DebugErrorOverlay(child: MaterialApp.router(...))
/// ```
///
/// Errors are captured via [DebugErrorOverlay.capture]. Flutter framework
/// errors and async errors are forwarded from [main_dev.dart] (T-210).
/// Riverpod provider errors are forwarded by [DebugErrorObserver] (T-211).
///
/// The [enabledForTest] parameter forces a known state for widget tests that
/// cannot set `kDebugMode` at runtime. Pass `true` to enable, `false` to
/// verify the release-mode no-op path in tests.
class DebugErrorOverlay extends StatefulWidget {
  /// Creates the [DebugErrorOverlay].
  ///
  /// Parameters:
  /// - [child]: The widget subtree to wrap.
  /// - [enabledForTest]: Overrides [kDebugMode] in widget tests only.
  ///   `null` means use [kDebugMode]. Pass `false` to simulate release mode.
  const DebugErrorOverlay({
    super.key,
    required this.child,
    this.enabledForTest,
  });

  /// The wrapped widget subtree.
  final Widget child;

  /// Optional override for [kDebugMode], used only in tests.
  ///
  /// `null` → use [kDebugMode] (default).
  /// `false` → simulate release mode (overlay absent).
  /// `true`  → force enable even in tests that run in release config.
  final bool? enabledForTest;

  // ---------------------------------------------------------------------------
  // Static test helper
  // ---------------------------------------------------------------------------

  /// Clears all captured error entries.
  ///
  /// Call this in [setUp] to isolate widget tests from one another.
  /// Must NOT be called in production code.
  @visibleForTesting
  static void clearForTest() {
    _errorNotifier.value = const <_ErrorEntry>[];
  }

  // ---------------------------------------------------------------------------
  // Static capture API
  // ---------------------------------------------------------------------------

  /// Captures [error] and [stack] into the debug overlay.
  ///
  /// No-ops when [kDebugMode] is `false`. The [_ErrorEntry] is appended to
  /// the shared [_errorNotifier]; the overlay widget rebuilds via
  /// [ValueListenableBuilder].
  ///
  /// Parameters:
  /// - [error]: The caught error object.
  /// - [stack]: The associated [StackTrace].
  /// - [route]: Current route path at the time of the error, if available.
  /// - [useCaseName]: Riverpod provider name, if forwarded by [DebugErrorObserver].
  static void capture(
    Object error,
    StackTrace stack, {
    String? route,
    String? useCaseName,
  }) {
    if (!kDebugMode) return;

    final chain = Chain.forTrace(stack);
    // Chain.terse strips internal Flutter/Dart frames for readability.
    final terse = chain.terse.toString();
    final tersedFrames = terse.split('\n').take(10).join('\n');
    final fullTrace = chain.toString();

    // For domain Failure subclasses, use the human-readable .message field.
    // For other errors, fall back to toString().
    final message = error is Failure ? error.message : error.toString();

    final entry = _ErrorEntry(
      errorType: error.runtimeType.toString(),
      message: message,
      tersedTrace: tersedFrames,
      fullTrace: fullTrace,
      route: route,
      useCaseName: useCaseName,
      timestamp: DateTime.now().toUtc(),
    );

    // Append to notifier — triggers ValueListenableBuilder rebuild.
    _errorNotifier.value = [..._errorNotifier.value, entry];

    // Also log to developer console for IDE integration.
    dev.log(
      'DebugErrorOverlay captured: ${entry.errorType}: ${entry.message}',
      name: 'DebugErrorOverlay',
      error: error,
      stackTrace: stack,
    );
  }

  @override
  State<DebugErrorOverlay> createState() => _DebugErrorOverlayState();
}

class _DebugErrorOverlayState extends State<DebugErrorOverlay> {
  /// Whether the full panel is visible (true) or collapsed to badge (false).
  bool _panelVisible = true;

  /// Index of the currently displayed error entry.
  int _currentIndex = 0;

  bool get _isEnabled => widget.enabledForTest ?? kDebugMode;

  @override
  Widget build(BuildContext context) {
    // Release mode / disabled: return child with zero cost.
    if (!_isEnabled) return widget.child;

    return ValueListenableBuilder<List<_ErrorEntry>>(
      valueListenable: _errorNotifier,
      builder: (context, errors, _) {
        if (errors.isEmpty) {
          return widget.child;
        }

        // Clamp index to valid range when a new error arrives.
        final safeIndex = _currentIndex.clamp(0, errors.length - 1);
        if (safeIndex != _currentIndex) {
          // Trigger rebuild via SchedulerBinding to avoid setState-in-build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentIndex = safeIndex);
          });
        }

        return Stack(
          children: [
            widget.child,
            // Full error panel (shown when _panelVisible == true).
            if (_panelVisible)
              _ErrorPanel(
                errors: errors,
                currentIndex: _currentIndex,
                onPrev: _currentIndex > 0
                    ? () => setState(() => _currentIndex--)
                    : null,
                onNext: _currentIndex < errors.length - 1
                    ? () => setState(() => _currentIndex++)
                    : null,
                onDismiss: () => setState(() => _panelVisible = false),
              ),
            // Persistent badge shown when panel is dismissed.
            if (!_panelVisible)
              Positioned(
                right: 16,
                bottom: 24,
                child: _ErrorBadge(
                  count: errors.length,
                  onTap: () => setState(() {
                    _panelVisible = true;
                    // Re-open at the last viewed index.
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Error panel
// ---------------------------------------------------------------------------

/// Full-screen error detail panel displayed above the app content.
///
/// Shows error type, message, abbreviated trace, route, use-case name,
/// and timestamp for the current entry. Supports prev/next navigation
/// when multiple entries are captured.
class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.errors,
    required this.currentIndex,
    required this.onPrev,
    required this.onNext,
    required this.onDismiss,
  });

  /// All captured error entries.
  final List<_ErrorEntry> errors;

  /// Index of the currently displayed entry.
  final int currentIndex;

  /// Callback to navigate to the previous entry; null when at first entry.
  final VoidCallback? onPrev;

  /// Callback to navigate to the next entry; null when at last entry.
  final VoidCallback? onNext;

  /// Callback to dismiss the full panel (collapses to badge).
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final entry = errors[currentIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer.withAlpha(230),
      child: SafeArea(
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // Header: error N of M + dismiss
            // ---------------------------------------------------------------
            _PanelHeader(
              currentIndex: currentIndex,
              total: errors.length,
              onPrev: onPrev,
              onNext: onNext,
              onDismiss: onDismiss,
            ),
            // ---------------------------------------------------------------
            // Scrollable body
            // ---------------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _ErrorBody(entry: entry),
              ),
            ),
            // ---------------------------------------------------------------
            // Action buttons
            // ---------------------------------------------------------------
            _PanelActions(entry: entry),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel header
// ---------------------------------------------------------------------------

/// Header row: "Error N of M" + prev/next arrows + dismiss button.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onDismiss,
  });

  final int currentIndex;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: 'Previous error',
          ),
          Expanded(
            child: Text(
              'Error ${currentIndex + 1} of $total',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: 'Next error',
          ),
          IconButton(
            key: const Key('debug_overlay_dismiss'),
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            tooltip: 'Dismiss overlay',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error body
// ---------------------------------------------------------------------------

/// Scrollable body with all error fields as [SelectableText] for copying.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.entry});

  final _ErrorEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error type (bold)
        SelectableText(
          entry.errorType,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Message
        SelectableText(entry.message, style: textTheme.bodyMedium),
        const SizedBox(height: 12),
        // Route (if present)
        if (entry.route != null) ...[
          const _FieldLabel(label: 'Route'),
          SelectableText(entry.route!, style: textTheme.bodySmall),
          const SizedBox(height: 8),
        ],
        // Use-case name (if present)
        if (entry.useCaseName != null) ...[
          const _FieldLabel(label: 'Provider'),
          SelectableText(entry.useCaseName!, style: textTheme.bodySmall),
          const SizedBox(height: 8),
        ],
        // Timestamp
        const _FieldLabel(label: 'Timestamp'),
        SelectableText(
          entry.timestamp.toIso8601String(),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        // Abbreviated stack trace
        const _FieldLabel(label: 'Stack trace (first 10 frames)'),
        SelectableText(entry.tersedTrace, style: textTheme.bodySmall),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Field label helper
// ---------------------------------------------------------------------------

/// A small bold label used above field values in the error body.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel actions (T-213)
// ---------------------------------------------------------------------------

/// Row of [TextButton]s: Copy (error message + full trace) and Record Bug.
///
/// Both actions write to [Clipboard.setData]. In widget tests,
/// [TestWidgetsFlutterBinding] intercepts clipboard calls.
class _PanelActions extends StatelessWidget {
  const _PanelActions({required this.entry});

  final _ErrorEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            key: const Key('debug_overlay_copy'),
            onPressed: () => _onCopy(context),
            icon: const Icon(Icons.copy_outlined, size: 18),
            label: const Text('Copy'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            key: const Key('debug_overlay_record_bug'),
            onPressed: () => _onRecordBug(context),
            icon: const Icon(Icons.bug_report_outlined, size: 18),
            label: const Text('Record Bug'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCopy(BuildContext context) async {
    // Payload: error type + message + full stack trace.
    final payload = '${entry.errorType}\n'
        '${entry.message}\n\n'
        '${entry.fullTrace}';
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error copied to clipboard.')),
    );
  }

  Future<void> _onRecordBug(BuildContext context) async {
    // Bug report template per T-213 spec.
    final payload = 'Bug Report\n'
        '----------\n'
        'Error Type: ${entry.errorType}\n'
        'Message: ${entry.message}\n'
        'Timestamp: ${entry.timestamp.toIso8601String()}\n'
        'Route: ${entry.route ?? "unknown"}\n\n'
        'Stack Trace:\n'
        '${entry.fullTrace}';
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug report copied to clipboard.')),
    );
  }
}

// ---------------------------------------------------------------------------
// Error badge (T-214)
// ---------------------------------------------------------------------------

/// Floating badge showing the error count when the panel is dismissed.
///
/// Tapping re-opens the full panel at the last-viewed entry.
class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge({required this.count, required this.onTap});

  /// Number of captured errors to display on the badge.
  final int count;

  /// Callback invoked when the badge is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      key: const Key('debug_error_badge'),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
      icon: const Icon(Icons.bug_report),
      label: Text('$count error${count == 1 ? '' : 's'}'),
    );
  }
}
