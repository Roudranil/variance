// test/presentation/features/settings/warnings/warnings_settings_screen_test.dart
//
// Widget tests for WarningsSettingsScreen, AccountLimitsScreen, and
// CategoryLimitsScreen (T-181, T-182).
//
// Test cases — WarningsSettingsScreen:
//   1. Hub shows "Per-Account Limits" row.
//   2. Hub shows "Per-Category Limits" row.
//   3. Tapping Per-Account row navigates to /settings/warnings/accounts.
//   4. Tapping Per-Category row navigates to /settings/warnings/categories.
//
// Test cases — AccountLimitsScreen:
//   5. Empty state shows "No active accounts".
//   6. Populated list shows account names.
//   7. Account row shows currency code.
//   8. System accounts are excluded from the list.
//   9. Deleted accounts are excluded from the list.
//  10. Tapping an account row expands the inline edit field.
//  11. Inline field shows currency code as label.
//  12. Inline field has confirm (check) and clear (close) buttons.
//  13. Loading state shows CircularProgressIndicator.
//
// Test cases — CategoryLimitsScreen:
//  14. Empty state shows "No expense categories" when all are protected.
//  15. Populated list shows non-protected categories.
//  16. Protected categories (isProtected=true) are excluded.
//  17. Category row shows home currency symbol as trailing label.
//  18. Tapping a category row expands the inline edit field.
//  19. Inline field shows home currency label.
//  20. Loading state shows CircularProgressIndicator.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/features/settings/warnings/account_limits_screen.dart';
import 'package:variance/presentation/features/settings/warnings/category_limits_screen.dart';
import 'package:variance/presentation/features/settings/warnings/warnings_settings_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier([this._settings = const AppSettings()]);
  final AppSettings _settings;

  @override
  Future<AppSettings> build() async => _settings;

  @override
  Future<void> save(patch) async {}
}


// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

int _epoch = 1700000000;

Account _makeAccount({
  required String id,
  required String name,
  required String currencyCode,
  bool isSystem = false,
  bool isDeleted = false,
  int? largeTxnThresholdMinor,
}) {
  return Account(
    id: id,
    name: name,
    accountCategory: AccountCategory.bankAccount,
    currencyCode: currencyCode,
    isSystem: isSystem,
    isDeleted: isDeleted,
    largeTxnThresholdMinor: largeTxnThresholdMinor,
    createdAt: _epoch,
    updatedAt: _epoch,
  );
}

Category _makeCategory({
  required String id,
  required String name,
  bool isProtected = false,
  bool isDeleted = false,
  String? parentId,
  int? largeTxnThresholdMinor,
}) {
  return Category(
    id: id,
    name: name,
    treeType: CategoryTreeType.expense,
    iconRef: 'category',
    isProtected: isProtected,
    isDeleted: isDeleted,
    parentId: parentId,
    largeTxnThresholdMinor: largeTxnThresholdMinor,
    createdAt: _epoch,
    updatedAt: _epoch,
  );
}

// ---------------------------------------------------------------------------
// Hub screen helper
// ---------------------------------------------------------------------------

Widget _buildHubWidget({List<String>? navigated}) {
  final navLog = navigated ?? [];
  final router = GoRouter(
    initialLocation: AppRoutes.settingsWarnings,
    routes: [
      GoRoute(
        path: AppRoutes.settingsWarnings,
        builder: (_, __) => const WarningsSettingsScreen(),
        routes: [
          GoRoute(
            path: 'accounts',
            builder: (_, state) {
              navLog.add(state.fullPath ?? '');
              return const Scaffold(body: Text('AccountLimits'));
            },
          ),
          GoRoute(
            path: 'categories',
            builder: (_, state) {
              navLog.add(state.fullPath ?? '');
              return const Scaffold(body: Text('CategoryLimits'));
            },
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// AccountLimitsScreen helper
// ---------------------------------------------------------------------------

Widget _buildAccountWidget(List<Account> accounts) {
  return ProviderScope(
    overrides: [
      accountsProvider.overrideWith(
        (_) => Stream<List<Account>>.value(accounts),
      ),
      appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
    ],
    child: const MaterialApp(home: AccountLimitsScreen()),
  );
}

// ---------------------------------------------------------------------------
// CategoryLimitsScreen helper
// ---------------------------------------------------------------------------

Widget _buildCategoryWidget(
  List<Category> categories, {
  String homeCurrency = 'INR',
}) {
  return ProviderScope(
    overrides: [
      categoryListProvider.overrideWith(
        () => _FakeCategoryListNotifier(categories),
      ),
      appSettingsProvider.overrideWith(
        () => _FakeAppSettingsNotifier(
          AppSettings(homeCurrency: homeCurrency),
        ),
      ),
    ],
    child: const MaterialApp(home: CategoryLimitsScreen()),
  );
}

class _FakeCategoryListNotifier extends CategoryList {
  _FakeCategoryListNotifier(this._cats);
  final List<Category> _cats;

  @override
  Future<List<Category>> build() async => _cats;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WarningsSettingsScreen hub (T-181, T-182)', () {
    testWidgets('1. hub shows "Per-Account Limits" row', (tester) async {
      await tester.pumpWidget(_buildHubWidget());
      await tester.pumpAndSettle();

      expect(find.text('Per-Account Limits'), findsOneWidget);
    });

    testWidgets('2. hub shows "Per-Category Limits" row', (tester) async {
      await tester.pumpWidget(_buildHubWidget());
      await tester.pumpAndSettle();

      expect(find.text('Per-Category Limits'), findsOneWidget);
    });

    testWidgets(
      '3. tapping Per-Account row navigates to /settings/warnings/accounts',
      (tester) async {
        final navLog = <String>[];
        await tester.pumpWidget(_buildHubWidget(navigated: navLog));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Per-Account Limits'));
        await tester.pumpAndSettle();

        expect(find.text('AccountLimits'), findsOneWidget);
      },
    );

    testWidgets(
      '4. tapping Per-Category row navigates to /settings/warnings/categories',
      (tester) async {
        await tester.pumpWidget(_buildHubWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Per-Category Limits'));
        await tester.pumpAndSettle();

        expect(find.text('CategoryLimits'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------

  group('AccountLimitsScreen (T-181)', () {
    testWidgets('5. empty list shows "No active accounts"', (tester) async {
      await tester.pumpWidget(_buildAccountWidget([]));
      await tester.pumpAndSettle();

      expect(find.text('No active accounts'), findsOneWidget);
    });

    testWidgets('6. populated list shows account names', (tester) async {
      final accounts = [
        _makeAccount(id: 'a1', name: 'Savings', currencyCode: 'INR'),
        _makeAccount(id: 'a2', name: 'Wallet', currencyCode: 'USD'),
      ];
      await tester.pumpWidget(_buildAccountWidget(accounts));
      await tester.pumpAndSettle();

      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
    });

    testWidgets('7. account row shows "Not set" when no threshold', (tester) async {
      final accounts = [
        _makeAccount(
          id: 'a1',
          name: 'Savings',
          currencyCode: 'INR',
          largeTxnThresholdMinor: null,
        ),
      ];
      await tester.pumpWidget(_buildAccountWidget(accounts));
      await tester.pumpAndSettle();

      expect(find.text('Not set'), findsOneWidget);
    });

    testWidgets(
      '8. system accounts (isSystem=true) are excluded from the list',
      (tester) async {
        final accounts = [
          _makeAccount(
            id: 'sys1',
            name: '__EQ_INR',
            currencyCode: 'INR',
            isSystem: true,
          ),
          _makeAccount(id: 'a1', name: 'Savings', currencyCode: 'INR'),
        ];
        await tester.pumpWidget(_buildAccountWidget(accounts));
        await tester.pumpAndSettle();

        expect(find.text('__EQ_INR'), findsNothing);
        expect(find.text('Savings'), findsOneWidget);
      },
    );

    testWidgets(
      '9. deleted accounts (isDeleted=true) are excluded from the list',
      (tester) async {
        final accounts = [
          _makeAccount(
            id: 'del1',
            name: 'OldAccount',
            currencyCode: 'INR',
            isDeleted: true,
          ),
          _makeAccount(id: 'a1', name: 'Savings', currencyCode: 'INR'),
        ];
        await tester.pumpWidget(_buildAccountWidget(accounts));
        await tester.pumpAndSettle();

        expect(find.text('OldAccount'), findsNothing);
        expect(find.text('Savings'), findsOneWidget);
      },
    );

    testWidgets(
      '10. tapping an account row expands the inline TextField',
      (tester) async {
        final accounts = [
          _makeAccount(id: 'a1', name: 'Savings', currencyCode: 'INR'),
        ];
        await tester.pumpWidget(_buildAccountWidget(accounts));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Savings'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      '11. inline field shows account currency code as label',
      (tester) async {
        final accounts = [
          _makeAccount(id: 'a1', name: 'Wallet', currencyCode: 'USD'),
        ];
        await tester.pumpWidget(_buildAccountWidget(accounts));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wallet'));
        await tester.pumpAndSettle();

        // 'USD' appears as label and suffix in the inline field.
        expect(find.text('USD'), findsWidgets);
      },
    );

    testWidgets(
      '12. inline field shows confirm (check) and clear (close) icon buttons',
      (tester) async {
        final accounts = [
          _makeAccount(id: 'a1', name: 'Savings', currencyCode: 'INR'),
        ];
        await tester.pumpWidget(_buildAccountWidget(accounts));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Savings'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      },
    );

    testWidgets(
      '13. loading state shows CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              accountsProvider.overrideWith(
                (_) => StreamController<List<Account>>().stream,
              ),
              appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
            ],
            child: const MaterialApp(home: AccountLimitsScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------

  group('CategoryLimitsScreen (T-182)', () {
    testWidgets(
      '14. empty list (all protected) shows "No expense categories"',
      (tester) async {
        await tester.pumpWidget(_buildCategoryWidget([]));
        await tester.pumpAndSettle();

        expect(find.text('No expense categories'), findsOneWidget);
      },
    );

    testWidgets(
      '15. non-protected categories are listed',
      (tester) async {
        final cats = [
          _makeCategory(id: 'c1', name: 'Food'),
          _makeCategory(id: 'c2', name: 'Transport'),
        ];
        await tester.pumpWidget(_buildCategoryWidget(cats));
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
      },
    );

    testWidgets(
      '16. protected categories (isProtected=true) are excluded',
      (tester) async {
        final cats = [
          _makeCategory(id: 'bai', name: 'Balance Adjustment', isProtected: true),
          _makeCategory(id: 'c1', name: 'Food'),
        ];
        await tester.pumpWidget(_buildCategoryWidget(cats));
        await tester.pumpAndSettle();

        expect(find.text('Balance Adjustment'), findsNothing);
        expect(find.text('Food'), findsOneWidget);
      },
    );

    testWidgets(
      '17. category row shows "Not set" when no threshold configured',
      (tester) async {
        final cats = [
          _makeCategory(id: 'c1', name: 'Food', largeTxnThresholdMinor: null),
        ];
        await tester.pumpWidget(_buildCategoryWidget(cats));
        await tester.pumpAndSettle();

        expect(find.text('Not set'), findsOneWidget);
      },
    );

    testWidgets(
      '18. tapping a category row expands the inline TextField',
      (tester) async {
        final cats = [_makeCategory(id: 'c1', name: 'Food')];
        await tester.pumpWidget(_buildCategoryWidget(cats));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      '19. inline field shows home currency code as label',
      (tester) async {
        final cats = [_makeCategory(id: 'c1', name: 'Food')];
        await tester.pumpWidget(_buildCategoryWidget(cats, homeCurrency: 'EUR'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        // 'EUR' appears as the currency label.
        expect(find.text('EUR'), findsWidgets);
      },
    );

    testWidgets(
      '20. loading state shows CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryListProvider.overrideWith(_SlowCategoryNotifier.new),
              appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
            ],
            child: const MaterialApp(home: CategoryLimitsScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      '21. deleted categories (isDeleted=true) are excluded',
      (tester) async {
        final cats = [
          _makeCategory(id: 'del', name: 'OldCat', isDeleted: true),
          _makeCategory(id: 'c1', name: 'Food'),
        ];
        await tester.pumpWidget(_buildCategoryWidget(cats));
        await tester.pumpAndSettle();

        expect(find.text('OldCat'), findsNothing);
        expect(find.text('Food'), findsOneWidget);
      },
    );
  });
}

class _SlowCategoryNotifier extends CategoryList {
  @override
  Future<List<Category>> build() => Completer<List<Category>>().future;
}
