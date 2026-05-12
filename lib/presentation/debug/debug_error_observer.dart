// lib/presentation/debug/debug_error_observer.dart
//
// DebugErrorObserver — Riverpod ProviderObserver that forwards domain
// Failure errors to DebugErrorOverlay.
//
// Spec reference: T-211
//   - Implements [ProviderObserver] (abstract base class in Riverpod 3.x).
//   - Overrides [didUpdateProvider] to detect [AsyncValue.error] states.
//   - When the error is [Err(Failure)], extracts [Failure.message] and calls
//     [DebugErrorOverlay.capture] with the provider name as [useCaseName].
//   - Registered on the root [ProviderScope] in [main_dev.dart] only.
//   - No-op outside kDebugMode (DebugErrorOverlay.capture guards this).
//
// Riverpod 3.x API notes:
//   - [didUpdateProvider] receives a [ProviderObserverContext] (not
//     ProviderBase directly). The provider is at [context.provider].
//   - [ProviderObserver] is `abstract base class` — subclass must also be
//     `base`, `final`, or `sealed`.
//
// Test cases (see test/widget/debug/debug_error_overlay_test.dart):
//   - Injecting AsyncValue.error(Err(DatabaseFailure('test'))) triggers
//     overlay capture and shows "DatabaseFailure" type and "test" message.
//   - Injecting AsyncValue.error(Err(ValidationFailure(...))) shows
//     "ValidationFailure" type.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/presentation/debug/debug_error_overlay.dart';

/// A [ProviderObserver] that routes domain [Failure] errors to
/// [DebugErrorOverlay] as a debug side-channel.
///
/// Does not modify any production notifier or use case — it is a pure
/// read-only observer wired at the Riverpod root in [main_dev.dart].
///
/// Only active in debug mode; [DebugErrorOverlay.capture] no-ops in
/// release builds.
final class DebugErrorObserver extends ProviderObserver {
  /// Creates the [DebugErrorObserver].
  const DebugErrorObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // Only act on AsyncValue.error states.
    if (newValue is! AsyncValue<dynamic>) return;

    switch (newValue) {
      case AsyncError(:final error, :final stackTrace):
        _forwardError(error, stackTrace, context);
      default:
        return;
    }
  }

  /// Forwards [error] to [DebugErrorOverlay.capture] when it is a domain
  /// [Failure] (either wrapped in [Err] or thrown directly).
  void _forwardError(
    Object error,
    StackTrace stackTrace,
    ProviderObserverContext context,
  ) {
    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();

    // Case 1: Err(Failure) result type — unwrap the Failure.
    if (error is Err<dynamic>) {
      DebugErrorOverlay.capture(
        error.failure,
        stackTrace,
        useCaseName: providerName,
      );
      return;
    }

    // Case 2: Bare Failure (thrown directly, e.g. in tests).
    if (error is Failure) {
      DebugErrorOverlay.capture(
        error,
        stackTrace,
        useCaseName: providerName,
      );
    }

    // Other error types are not forwarded here; they are captured by
    // FlutterError.onError / PlatformDispatcher.instance.onError in
    // main_dev.dart.
  }
}
