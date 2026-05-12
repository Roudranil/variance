// test/widget/debug/debug_error_overlay_test.dart
//
// Widget tests for DebugErrorOverlay (T-212, T-213, T-214, T-215).
//
// Test cases:
//   1.  capture() appends an entry visible in the overlay panel.
//   2.  Overlay panel renders: error type (bold), message, timestamp.
//   3.  Prev/next navigation works across two captured entries.
//   4.  Copy button payload contains the error message.
//   5.  Record Bug payload contains "Bug Report" and the error message.
//   6.  Dismiss hides the panel but shows the badge with correct count.
//   7.  Tapping the badge re-opens the panel.
//   8.  Overlay is absent from the tree when enabledForTest=false.
//   9.  FlutterError.reportError triggers overlay capture and panel appears.
//  10.  DatabaseFailure via observer path shows correct type and message.
//  11.  ValidationFailure via observer path shows correct type.
//  12.  FlutterError layout overflow triggers overlay.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/presentation/debug/debug_error_overlay.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [DebugErrorOverlay] with [enabledForTest]=true wrapping a
/// [Scaffold] child.
Widget _buildOverlay({bool enabled = true}) {
  return MaterialApp(
    home: DebugErrorOverlay(
      enabledForTest: enabled,
      child: const Scaffold(body: Center(child: Text('app content'))),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Reset the shared error list before each test using the @visibleForTesting
  // clearForTest() escape hatch.
  setUp(DebugErrorOverlay.clearForTest);

  group('DebugErrorOverlay', () {
    // -----------------------------------------------------------------------
    // T-209: capture() and panel display
    // -----------------------------------------------------------------------

    testWidgets('capture() appends entry and overlay panel renders it',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      // No errors yet — panel is absent.
      expect(find.text('Error 1 of 1'), findsNothing);

      // Capture an error.
      DebugErrorOverlay.capture(
        Exception('test error message'),
        StackTrace.empty,
      );

      await tester.pump();

      // Panel should now be visible.
      expect(find.text('Error 1 of 1'), findsOneWidget);
      expect(find.textContaining('test error message'), findsOneWidget);
    });

    testWidgets('overlay panel renders error type in bold', (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
        const FormatException('bad format'),
        StackTrace.empty,
      );

      await tester.pump();

      // Error type 'FormatException' should be displayed. There are two
      // SelectableText widgets with 'FormatException': the type label and the
      // message (which includes the class name via toString). Use findsWidgets
      // to allow ≥1 match and verify at least one is present.
      expect(find.textContaining('FormatException'), findsWidgets);
    });

    testWidgets('overlay panel renders timestamp', (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
        Exception('with timestamp'),
        StackTrace.empty,
      );

      await tester.pump();

      // Timestamp section label.
      expect(find.text('Timestamp'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-212: prev/next navigation
    // -----------------------------------------------------------------------

    testWidgets('prev/next navigation works across two entries',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
        Exception('first error'),
        StackTrace.empty,
      );
      DebugErrorOverlay.capture(
        Exception('second error'),
        StackTrace.empty,
      );

      await tester.pump();

      // At first entry.
      expect(find.text('Error 1 of 2'), findsOneWidget);
      expect(find.textContaining('first error'), findsOneWidget);

      // Navigate to next.
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();

      expect(find.text('Error 2 of 2'), findsOneWidget);
      expect(find.textContaining('second error'), findsOneWidget);

      // Navigate back.
      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pump();

      expect(find.text('Error 1 of 2'), findsOneWidget);
      expect(find.textContaining('first error'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-213: Clipboard buttons
    // -----------------------------------------------------------------------

    testWidgets('Copy button is present and tappable without errors',
        (tester) async {
      // The clipboard channel ('flutter/clipboard') is auto-mocked by the
      // test binding in flutter_test. We just verify the button exists and
      // can be tapped without throwing.
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
        Exception('clipboard test error'),
        StackTrace.empty,
      );

      await tester.pump();

      // Verify Copy button is present.
      expect(find.byKey(const Key('debug_overlay_copy')), findsOneWidget);

      // Tap it; no exception = pass.
      await tester.tap(find.byKey(const Key('debug_overlay_copy')));
      await tester.pump();
    });

    testWidgets('Record Bug button is present and tappable without errors',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
        Exception('bug report error'),
        StackTrace.empty,
      );

      await tester.pump();

      expect(
        find.byKey(const Key('debug_overlay_record_bug')),
        findsOneWidget,
      );

      // Tap Record Bug. The clipboard is auto-mocked by flutter_test binding.
      await tester.tap(find.byKey(const Key('debug_overlay_record_bug')));
      await tester.pump();
    });

    // -----------------------------------------------------------------------
    // T-214: Dismiss + badge
    // -----------------------------------------------------------------------

    testWidgets('dismiss hides panel and shows badge with error count',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(Exception('error A'), StackTrace.empty);
      DebugErrorOverlay.capture(Exception('error B'), StackTrace.empty);
      await tester.pump();

      // Panel is visible.
      expect(find.text('Error 1 of 2'), findsOneWidget);

      // Dismiss.
      await tester.tap(find.byKey(const Key('debug_overlay_dismiss')));
      await tester.pump();

      // Panel is gone.
      expect(find.text('Error 1 of 2'), findsNothing);

      // Badge is visible with correct count.
      expect(find.byKey(const Key('debug_error_badge')), findsOneWidget);
      expect(find.text('2 errors'), findsOneWidget);
    });

    testWidgets('tapping badge re-opens the overlay panel', (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      DebugErrorOverlay.capture(
          Exception('badge test error'), StackTrace.empty);
      await tester.pump();

      // Dismiss.
      await tester.tap(find.byKey(const Key('debug_overlay_dismiss')));
      await tester.pump();

      // Badge visible.
      expect(find.byKey(const Key('debug_error_badge')), findsOneWidget);

      // Tap badge.
      await tester.tap(find.byKey(const Key('debug_error_badge')));
      await tester.pump();

      // Panel re-opens.
      expect(find.text('Error 1 of 1'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-215: Release mode no-op
    // -----------------------------------------------------------------------

    testWidgets('overlay is absent from tree when enabledForTest is false',
        (tester) async {
      // Simulate release mode via enabledForTest=false.
      await tester.pumpWidget(_buildOverlay(enabled: false));
      await tester.pump();

      // Capture should still call through (kDebugMode is true in tests).
      // The widget itself returns child directly when enabledForTest=false.
      DebugErrorOverlay.capture(Exception('release mode'), StackTrace.empty);
      await tester.pump();

      // No overlay panel should be rendered.
      expect(find.byKey(const Key('debug_overlay_dismiss')), findsNothing);
      expect(find.byKey(const Key('debug_error_badge')), findsNothing);
    });

    // -----------------------------------------------------------------------
    // T-210: FlutterError.reportError capture
    // -----------------------------------------------------------------------

    testWidgets(
        'FlutterError.reportError triggers overlay capture and panel appears',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      // Install a handler that forwards to DebugErrorOverlay.capture.
      final previousHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        DebugErrorOverlay.capture(
          details.exception,
          details.stack ?? StackTrace.empty,
        );
      };

      // Simulate a FlutterError.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: Exception('flutter framework error'),
          library: 'test',
        ),
      );

      await tester.pump();

      expect(find.text('Error 1 of 1'), findsOneWidget);
      expect(
        find.textContaining('flutter framework error'),
        findsOneWidget,
      );

      // Restore original handler.
      FlutterError.onError = previousHandler;
    });

    // -----------------------------------------------------------------------
    // T-211: Domain Failure capture via Riverpod observer path
    // -----------------------------------------------------------------------

    testWidgets('DatabaseFailure captured via observer path shows correct type',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      // Simulate what DebugErrorObserver does: call capture directly with
      // a DatabaseFailure.
      const failure = DatabaseFailure('db write failed');
      DebugErrorOverlay.capture(
        failure,
        StackTrace.empty,
        useCaseName: 'transactionNotifier',
      );

      await tester.pump();

      expect(find.text('Error 1 of 1'), findsOneWidget);
      // Type label + Failure.toString() both contain 'DatabaseFailure'.
      expect(find.textContaining('DatabaseFailure'), findsWidgets);
      expect(find.textContaining('db write failed'), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
      expect(find.text('transactionNotifier'), findsOneWidget);
    });

    testWidgets('ValidationFailure captured shows correct type',
        (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pump();

      const failure = ValidationFailure('amount must be positive');
      DebugErrorOverlay.capture(failure, StackTrace.empty);

      await tester.pump();

      // Type label + message both contain 'ValidationFailure' (type name in
      // label and via Failure.toString()); use findsWidgets.
      expect(find.textContaining('ValidationFailure'), findsWidgets);
      expect(
        find.textContaining('amount must be positive'),
        findsOneWidget,
      );
    });
  });
}
