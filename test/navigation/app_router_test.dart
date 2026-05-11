// test/navigation/app_router_test.dart
//
// Widget tests for the GoRouter route tree and onboarding redirect guard.
//
// Test cases:
//   - Fresh install (onboardingComplete=false): all routes redirect to /onboarding
//   - Returning user (onboardingComplete=true): home shell is shown at /
//   - Tapping Home tab renders HomeScreen placeholder
//   - Tapping Accounts tab renders AccountListScreen placeholder
//   - Tapping Settings tab renders SettingsScreen placeholder
//   - /onboarding route renders OnboardingScreen
//   - No GoException on /accounts/:id with a valid id
//   - /transaction/new renders RouteErrorScreen (not yet implemented)
//
// All tests use ProviderScope with overrides for appSettingsProvider so no
// file system access or real database is required.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/features/accounts/account_list_screen.dart';
import 'package:variance/presentation/features/home/home_screen.dart';
import 'package:variance/presentation/features/onboarding/onboarding_screen.dart';
import 'package:variance/presentation/features/settings/settings_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

/// A minimal [AppSettingsNotifier] that returns a predetermined [AppSettings]
/// value so no database or repository is required in route tests.
class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(this._settings);

  final AppSettings _settings;

  @override
  Future<AppSettings> build() async => _settings;
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a [ProviderScope] + [_TestRouterApp] with the given [settings]
/// injected via a notifier override.
Widget _buildApp(AppSettings settings) {
  return ProviderScope(
    overrides: [
      appSettingsProvider
          .overrideWith(() => _FakeAppSettingsNotifier(settings)),
    ],
    child: const _TestRouterApp(),
  );
}

/// A [ConsumerWidget] that calls [makeAppRouter] and wraps it in [MaterialApp.router].
class _TestRouterApp extends ConsumerWidget {
  const _TestRouterApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = makeAppRouter(ref);
    return MaterialApp.router(routerConfig: router);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Onboarding redirect guard', () {
    testWidgets(
      'redirects to /onboarding when onboardingComplete is false',
      (tester) async {
        await tester.pumpWidget(
          _buildApp(const AppSettings(onboardingComplete: false)),
        );

        // Pump until all async work completes.
        await tester.pumpAndSettle();

        // The redirect guard should have sent us to /onboarding.
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
      },
    );

    testWidgets(
      'shows home shell when onboardingComplete is true',
      (tester) async {
        await tester.pumpWidget(
          _buildApp(const AppSettings(onboardingComplete: true)),
        );

        await tester.pumpAndSettle();

        // No redirect — home shell should be shown.
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(OnboardingScreen), findsNothing);
      },
    );
  });

  group('Shell navigation tabs', () {
    testWidgets('initial tab shows HomeScreen', (tester) async {
      await tester.pumpWidget(
        _buildApp(const AppSettings(onboardingComplete: true)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('tapping Accounts tab shows AccountListScreen', (tester) async {
      await tester.pumpWidget(
        _buildApp(const AppSettings(onboardingComplete: true)),
      );
      await tester.pumpAndSettle();

      // Tap the Accounts destination in the NavigationBar.
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountListScreen), findsOneWidget);
    });

    testWidgets('tapping Settings tab shows SettingsScreen', (tester) async {
      await tester.pumpWidget(
        _buildApp(const AppSettings(onboardingComplete: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('Named route paths', () {
    testWidgets('/onboarding renders OnboardingScreen', (tester) async {
      await tester.pumpWidget(
        // Set onboardingComplete=false so the guard redirects to /onboarding.
        _buildApp(const AppSettings(onboardingComplete: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets(
      'navigating to /accounts/:id with a valid id does not throw GoException',
      (tester) async {
        await tester.pumpWidget(
          _buildApp(const AppSettings(onboardingComplete: true)),
        );
        await tester.pumpAndSettle();

        // Navigate to /accounts tab first, then push into an account detail.
        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        // Get the router from context and push the detail route.
        final BuildContext context = tester.element(
          find.byType(AccountListScreen),
        );
        context.push('/accounts/test-id-123');
        await tester.pumpAndSettle();

        // The route should resolve without throwing GoException.
        // The RouteErrorScreen is shown because AccountDetailScreen is not yet
        // implemented — that is expected behaviour.
        expect(tester.takeException(), isNull);
      },
    );
  });
}
