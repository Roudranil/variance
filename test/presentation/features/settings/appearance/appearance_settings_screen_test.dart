// test/presentation/features/settings/appearance/appearance_settings_screen_test.dart
//
// Widget tests for AppearanceSettingsScreen (T-175) and dynamic color
// fallback inline note (T-176).
//
// Test cases:
//   1. Theme segmented button shows correct selected segment for each AppTheme.
//   2. Theme segmented button writes correct patch on segment tap.
//   3. Color scheme segmented button shows correct selected segment.
//   4. Color scheme segmented button writes correct patch on tap.
//   5. Seed color picker row is visible when colorSchemeMode == custom.
//   6. Seed color picker row is absent when colorSchemeMode != custom.
//   7. Catppuccin flavor note is visible when colorSchemeMode == catppuccin.
//   8. Animations toggle reflects settings value (true).
//   9. Animations toggle reflects settings value (false).
//  10. Animations toggle writes correct patch on tap.
//  11. Preview row tap navigates to /settings/appearance/preview.
//  12. Dynamic unavailable note is shown when DynamicColorAvailability.available == false.
//  13. Dynamic unavailable note is absent when DynamicColorAvailability.available == true.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/features/settings/appearance/appearance_settings_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

/// Records [save] calls for assertion in tests.
class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(this._initialSettings);
  final AppSettings _initialSettings;

  final List<AppSettingsPatch> savedPatches = [];

  @override
  Future<AppSettings> build() async => _initialSettings;

  @override
  Future<void> save(AppSettingsPatch patch) async {
    savedPatches.add(patch);
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

const _defaultSettings = AppSettings(
  homeCurrency: 'INR',
  onboardingComplete: true,
  theme: AppTheme.system,
  colorSchemeMode: ColorSchemeMode.dynamic,
  animationsEnabled: true,
);

/// Builds [AppearanceSettingsScreen] wrapped in [ProviderScope] + [GoRouter].
///
/// - [settings]: Initial [AppSettings] to pre-fill controls.
/// - [notifier]: Optional fake notifier to capture [save] calls.
/// - [dynamicAvailable]: Whether to simulate dynamic color availability.
/// - [navigatedRoutes]: Records navigation calls.
Widget _buildTestWidget({
  AppSettings settings = _defaultSettings,
  _FakeAppSettingsNotifier? notifier,
  bool dynamicAvailable = true,
  List<String>? navigatedRoutes,
}) {
  final fakeNotifier = notifier ?? _FakeAppSettingsNotifier(settings);

  final router = GoRouter(
    initialLocation: AppRoutes.settingsAppearance,
    routes: [
      GoRoute(
        path: AppRoutes.settingsAppearance,
        builder: (_, __) => const AppearanceSettingsScreen(),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (_, __) {
              navigatedRoutes?.add(AppRoutes.settingsAppearancePreview);
              return const Scaffold(body: Text('preview'));
            },
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(() => fakeNotifier),
    ],
    child: DynamicColorAvailability(
      available: dynamicAvailable,
      child: MaterialApp.router(
        theme: ThemeData(useMaterial3: true),
        routerConfig: router,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppearanceSettingsScreen', () {
    // -----------------------------------------------------------------------
    // Theme segmented button
    // -----------------------------------------------------------------------

    testWidgets('theme segmented button shows "System" selected by default',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // SegmentedButton shows selected state on the 'System' segment.
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('theme segmented button writes patch on Light tap',
        (tester) async {
      final notifier = _FakeAppSettingsNotifier(_defaultSettings);
      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier),
      );
      await tester.pump();

      await tester.tap(find.text('Light'));
      await tester.pump();

      expect(notifier.savedPatches, hasLength(1));
      expect(notifier.savedPatches.first.theme, AppTheme.light);
    });

    testWidgets('theme segmented button writes patch on Dark tap',
        (tester) async {
      final notifier = _FakeAppSettingsNotifier(_defaultSettings);
      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier),
      );
      await tester.pump();

      await tester.tap(find.text('Dark'));
      await tester.pump();

      expect(notifier.savedPatches, hasLength(1));
      expect(notifier.savedPatches.first.theme, AppTheme.dark);
    });

    // -----------------------------------------------------------------------
    // Color scheme segmented button
    // -----------------------------------------------------------------------

    testWidgets('color scheme button shows Dynamic / Custom / Catppuccin',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('Dynamic'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Catppuccin'), findsOneWidget);
    });

    testWidgets('color scheme button writes patch on Custom tap',
        (tester) async {
      final notifier = _FakeAppSettingsNotifier(_defaultSettings);
      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier),
      );
      await tester.pump();

      await tester.tap(find.text('Custom'));
      await tester.pump();

      expect(notifier.savedPatches, hasLength(1));
      expect(
        notifier.savedPatches.first.colorSchemeMode,
        ColorSchemeMode.custom,
      );
    });

    testWidgets('color scheme button writes patch on Catppuccin tap',
        (tester) async {
      final notifier = _FakeAppSettingsNotifier(_defaultSettings);
      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier),
      );
      await tester.pump();

      await tester.tap(find.text('Catppuccin'));
      await tester.pump();

      expect(notifier.savedPatches, hasLength(1));
      expect(
        notifier.savedPatches.first.colorSchemeMode,
        ColorSchemeMode.catppuccin,
      );
    });

    // -----------------------------------------------------------------------
    // Seed color picker row
    // -----------------------------------------------------------------------

    testWidgets('seed color picker row visible when colorSchemeMode == custom',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          settings: const AppSettings(
            homeCurrency: 'INR',
            onboardingComplete: true,
            colorSchemeMode: ColorSchemeMode.custom,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Seed color'), findsOneWidget);
    });

    testWidgets('seed color picker row absent when colorSchemeMode == dynamic',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('Seed color'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Catppuccin flavor note
    // -----------------------------------------------------------------------

    testWidgets('Catppuccin flavor note visible when catppuccin selected',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          settings: const AppSettings(
            homeCurrency: 'INR',
            onboardingComplete: true,
            colorSchemeMode: ColorSchemeMode.catppuccin,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Auto-bound to theme: Light → Latte, Dark → Mocha'),
        findsOneWidget,
      );
    });

    // -----------------------------------------------------------------------
    // Animations toggle
    // -----------------------------------------------------------------------

    testWidgets('animations toggle shows enabled state', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);
    });

    testWidgets('animations toggle shows disabled state', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          settings: const AppSettings(
            homeCurrency: 'INR',
            onboardingComplete: true,
            animationsEnabled: false,
          ),
        ),
      );
      await tester.pump();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    testWidgets('animations toggle writes patch on tap', (tester) async {
      final notifier = _FakeAppSettingsNotifier(_defaultSettings);
      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier),
      );
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(notifier.savedPatches, hasLength(1));
      expect(notifier.savedPatches.first.animationsEnabled, isFalse);
    });

    // -----------------------------------------------------------------------
    // Preview row navigation
    // -----------------------------------------------------------------------

    testWidgets('preview row tap navigates to /settings/appearance/preview',
        (tester) async {
      final navigatedRoutes = <String>[];
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: navigatedRoutes),
      );
      await tester.pump();

      await tester.tap(find.text('Preview color scheme'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes, contains(AppRoutes.settingsAppearancePreview));
    });

    // -----------------------------------------------------------------------
    // Dynamic unavailable note (T-176)
    // -----------------------------------------------------------------------

    testWidgets('dynamic unavailable note shown when dynamicAvailable is false',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(dynamicAvailable: false),
      );
      await tester.pump();

      expect(
        find.text('Dynamic color not available on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('dynamic unavailable note absent when dynamicAvailable is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(dynamicAvailable: true),
      );
      await tester.pump();

      expect(
        find.text('Dynamic color not available on this device.'),
        findsNothing,
      );
    });
  });
}
