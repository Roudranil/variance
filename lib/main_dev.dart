// lib/main_dev.dart
//
// Dev-flavor entry point for the Variance app.
//
// Spec references:
//   - T-210: Flutter framework and async error capture
//   - T-211: Riverpod ProviderObserver registration
//   - SDS §2.12.4: Build Flavors (dev / staging / prod)
//   - SDS §2.9: Error Handling Patterns
//
// This entry point differs from main.dart (prod) in three ways:
//   1. Installs [DebugErrorOverlay.capture] as the [FlutterError.onError]
//      handler (chained after any existing handler) to capture framework
//      errors (layout overflow, assertion failures, etc.).
//   2. Installs [DebugErrorOverlay.capture] as [PlatformDispatcher.instance.onError]
//      to capture unhandled async errors.
//   3. Registers [DebugErrorObserver] on the root [ProviderScope] to capture
//      domain [Failure] errors from Riverpod notifiers.
//
// Both handlers are guarded by [kDebugMode] — they are no-ops in release
// builds, and the guard is evaluated at compile time so the Dart tree-shaker
// can eliminate the debug code path entirely from a release APK.
//
// Verification command (T-216):
//   flutter build apk --release --flavor prod
//   strings build/app/outputs/flutter-apk/app-prod-release.apk \
//     | grep -i DebugErrorOverlay
//   (expected: zero matches — the overlay is dead-code-eliminated in prod)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/presentation/debug/debug_error_observer.dart';
import 'package:variance/presentation/debug/debug_error_overlay.dart';
import 'package:variance/presentation/navigation/app_router.dart';

/// Dev-flavor entry point.
///
/// Registers debug error capture handlers and wraps the app with
/// [DebugErrorOverlay] before delegating to the standard [ProviderScope] +
/// [AppRouterWidget] tree.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // -----------------------------------------------------------------------
    // Flutter framework error capture (layout, assertion, widget build errors)
    // -----------------------------------------------------------------------
    final previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Chain: forward to the previous handler first (e.g. the default handler
      // which logs the error to the console), then capture for the overlay.
      previousFlutterErrorHandler?.call(details);
      DebugErrorOverlay.capture(
        details.exception,
        details.stack ?? StackTrace.empty,
        route: null, // Route not available at FlutterError boundary.
      );
    };

    // -----------------------------------------------------------------------
    // Async / unhandled error capture (Futures, Isolates, Zones)
    // -----------------------------------------------------------------------
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      DebugErrorOverlay.capture(error, stack);
      // Return true to mark the error as handled (suppresses the red screen).
      return true;
    };
  }

  // DebugErrorObserver is always included in main_dev.dart (a dev-only entry
  // point). The observer itself is a no-op when kDebugMode == false because
  // DebugErrorOverlay.capture guards with `if (!kDebugMode) return`.
  // This file is never compiled into staging or prod builds.
  runApp(
    const ProviderScope(
      observers: [DebugErrorObserver()],
      child: _DevApp(),
    ),
  );
}

/// The dev-flavor root widget.
///
/// Wraps [AppRouterWidget] with [DebugErrorOverlay] so all error captures
/// are visible on top of the app UI.
class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    return const DebugErrorOverlay(
      child: AppRouterWidget(),
    );
  }
}
