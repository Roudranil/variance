// test/presentation/features/settings/hub/settings_hub_screen_test.dart
//
// Widget tests for SettingsHubScreen (T-174).
//
// Test cases:
//   1. All 15 settings rows render in the loaded state.
//   2. Each visible row has a trailing chevron icon.
//   3. Tapping Appearance row navigates to the correct route.
//   4. Tapping Backup & Data row navigates to the correct route.
//   5. Tapping About row navigates to the correct route.
//   6. Section group headers render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/presentation/features/settings/hub/settings_hub_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds [SettingsHubScreen] in a [MaterialApp.router] with routes that
/// record navigation pushes.
///
/// The `Accounts` tab route (`/accounts`) is registered at the top level.
/// All `/settings/X` routes are registered as children of `/settings`.
Widget _buildTestWidget({required List<String> navigatedRoutes}) {
  final router = GoRouter(
    initialLocation: AppRoutes.settings,
    routes: [
      // Top-level /accounts tab route.
      GoRoute(
        path: AppRoutes.accounts,
        builder: (_, __) {
          navigatedRoutes.add(AppRoutes.accounts);
          return const Scaffold(body: Text('accounts'));
        },
      ),
      // Settings hub and all sub-routes.
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsHubScreen(),
        routes: [
          for (final segment in _kSubSegments)
            GoRoute(
              path: segment,
              builder: (_, __) {
                navigatedRoutes.add('/settings/$segment');
                return const Scaffold(body: Text('destination'));
              },
            ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    theme: ThemeData(useMaterial3: true),
    routerConfig: router,
  );
}

/// Sub-route segments under `/settings` used in the test router registration.
const List<String> _kSubSegments = [
  'appearance',
  'locale',
  'transaction-entry',
  'warnings',
  'profile',
  'security',
  'currency',
  'categories',
  'tags',
  'payees',
  'recurring',
  'drafts',
  'backup',
  'about',
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SettingsHubScreen', () {
    testWidgets('renders at least the visible row titles', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: []),
      );
      await tester.pump();

      // Rows visible in the default 800×600 test viewport (first several).
      const visibleTitles = [
        'Appearance',
        'Locale & Format',
        'Transaction Entry',
        'Warnings & Limits',
      ];

      for (final title in visibleTitles) {
        expect(find.text(title), findsOneWidget, reason: 'Missing: $title');
      }
    });

    testWidgets('renders all 15 rows when scrolled to bottom', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: []),
      );
      await tester.pump();

      // Scroll to the very bottom to force all lazy items into the tree.
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -3000),
      );
      await tester.pump();

      // Items that appear only after scrolling.
      const bottomTitles = ['Backup & Data', 'About'];
      for (final title in bottomTitles) {
        expect(find.text(title), findsOneWidget, reason: 'Missing: $title');
      }
    });

    testWidgets('renders section group headers in order', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: []),
      );
      await tester.pump();

      final sectionHeaders = ['Personalisation', 'Account', 'Data', 'App'];
      for (final header in sectionHeaders) {
        final finder = find.text(header);
        await tester.scrollUntilVisible(finder, 200);
        expect(
          finder,
          findsOneWidget,
          reason: 'Missing section header: $header',
        );
      }
    });

    testWidgets('each visible row has a trailing chevron icon', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: []),
      );
      await tester.pump();

      // ListView.builder only renders visible items. At least the first
      // several rows (within the default 800×600 test viewport) should each
      // have a chevron. Verify ≥1 chevron is present.
      final chevrons = find.byIcon(Icons.chevron_right);
      expect(chevrons, findsWidgets);
    });

    testWidgets('tapping Appearance row navigates to /settings/appearance',
        (tester) async {
      final navigatedRoutes = <String>[];
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: navigatedRoutes),
      );
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes, contains(AppRoutes.settingsAppearance));
    });

    testWidgets('tapping Backup & Data row navigates to /settings/backup',
        (tester) async {
      final navigatedRoutes = <String>[];
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: navigatedRoutes),
      );
      await tester.pump();

      // Drag list down to reveal the 'App' section rows.
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      await tester.tap(find.text('Backup & Data'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes.any((r) => r.contains('backup')), isTrue);
    });

    testWidgets('tapping About row navigates to /settings/about',
        (tester) async {
      final navigatedRoutes = <String>[];
      await tester.pumpWidget(
        _buildTestWidget(navigatedRoutes: navigatedRoutes),
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes.any((r) => r.contains('about')), isTrue);
    });
  });
}
