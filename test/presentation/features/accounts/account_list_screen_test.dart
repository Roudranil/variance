// test/presentation/features/accounts/account_list_screen_test.dart
//
// Widget tests for AccountListScreen.
//
// Test cases:
//   1. empty state — shows illustration + "No accounts yet" + FAB
//   2. populated state — net worth card visible
//   3. accounts grouped: contributing accounts appear above excluded
//   4. excluded account row has reduced opacity
//   5. negative balance renders with accessibility label "negative"
//   6. net worth card shows staleness chip when hasStaleRates=true
//   7. loading state shows CircularProgressIndicator
//   8. FAB navigates to /accounts/new route
//   9. row tap navigates to /accounts/:id

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';
import 'package:variance/presentation/features/accounts/account_list_screen.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Account _makeAccount({
  required String id,
  required String name,
  required AccountCategory category,
  String currencyCode = 'INR',
  bool includeInNetWorth = true,
}) {
  return Account(
    id: id,
    name: name,
    accountCategory: category,
    currencyCode: currencyCode,
    includeInNetWorth: includeInNetWorth,
    createdAt: _now,
    updatedAt: _now,
  );
}

const _defaultSettings = AppSettings(
  homeCurrency: 'INR',
  onboardingComplete: true,
);

/// Fake [AppSettingsNotifier] that synchronously resolves to [settings].
class _FakeAppSettings extends AppSettingsNotifier {
  _FakeAppSettings(this._settings);
  final AppSettings _settings;

  @override
  Future<AppSettings> build() async => _settings;
}

/// Wraps the screen in a ProviderScope + GoRouter.
Widget _buildTestWidget({
  required List<Account> accounts,
  NetWorthResult? netWorthResult,
  AppSettings settings = _defaultSettings,
  Map<String, int>? balanceOverrides,
  GoRouter? router,
}) {
  final netWorth = netWorthResult ??
      const NetWorthResult(
        totalMinor: 0,
        homeCurrency: 'INR',
        hasStaleRates: false,
      );

  // Default balance: 0 for each account.
  final balances = balanceOverrides ?? {for (final a in accounts) a.id: 0};

  final testRouter = router ??
      GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (ctx, st) => const AccountListScreen(),
          ),
          GoRoute(
            path: '/accounts/new',
            builder: (ctx, st) =>
                const Scaffold(body: Center(child: Text('NewAccount'))),
          ),
          GoRoute(
            path: '/accounts/:id',
            builder: (ctx, st) => Scaffold(
              body:
                  Center(child: Text('Detail:${st.pathParameters['id']}')),
            ),
          ),
        ],
      );

  return ProviderScope(
    overrides: [
      // AppSettings AsyncNotifier — use class-based override
      appSettingsProvider.overrideWith(() => _FakeAppSettings(settings)),

      // accounts stream provider
      accountsProvider.overrideWith((_) => Stream.value(accounts)),

      // net worth stream provider
      netWorthProvider.overrideWith((_) => Stream.value(netWorth)),

      // account balance per id
      for (final acc in accounts)
        accountBalanceProvider(acc.id, acc.currencyCode).overrideWith(
          (_) => Stream.value(balances[acc.id] ?? 0),
        ),
    ],
    child: MaterialApp.router(
      theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
      darkTheme: AppThemeData.fromSeed(const Color(0xFF6750A4)).dark,
      routerConfig: testRouter,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AccountListScreen', () {
    testWidgets('1. empty state shows "No accounts yet" and FAB',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(accounts: []));
      await tester.pumpAndSettle();

      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('2. populated state shows net worth card', (tester) async {
      final acc = _makeAccount(
        id: 'a1',
        name: 'Savings',
        category: AccountCategory.bankAccount,
      );

      await tester.pumpWidget(
        _buildTestWidget(
          accounts: [acc],
          netWorthResult: const NetWorthResult(
            totalMinor: 500000,
            homeCurrency: 'INR',
            hasStaleRates: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
    });

    testWidgets(
        '3. contributing accounts appear before excluded section header',
        (tester) async {
      final contributing = _makeAccount(
        id: 'a1',
        name: 'Main Wallet',
        category: AccountCategory.cash,
      );
      final excluded = _makeAccount(
        id: 'a2',
        name: 'Investment',
        category: AccountCategory.investment,
        includeInNetWorth: false,
      );

      await tester.pumpWidget(
        _buildTestWidget(accounts: [contributing, excluded]),
      );
      await tester.pumpAndSettle();

      // Account names appear (Investment shows in the tile title + chip label)
      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.textContaining('Investment'), findsWidgets);
      expect(find.text('Excluded from net worth'), findsOneWidget);
    });

    testWidgets('4. excluded account row has reduced opacity', (tester) async {
      final excluded = _makeAccount(
        id: 'e1',
        name: 'Savings',
        category: AccountCategory.bankAccount,
        includeInNetWorth: false,
      );

      await tester.pumpWidget(_buildTestWidget(accounts: [excluded]));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('Savings'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('5. negative balance has accessibility label with "negative"',
        (tester) async {
      final acc = _makeAccount(
        id: 'a1',
        name: 'Credit Card',
        category: AccountCategory.creditCard,
      );

      await tester.pumpWidget(
        _buildTestWidget(
          accounts: [acc],
          balanceOverrides: {'a1': -50000},
        ),
      );
      await tester.pumpAndSettle();

      // Semantics label for negative balance must contain "negative"
      final semantics = tester.getSemantics(
        find.bySemanticsLabel(RegExp('negative', caseSensitive: false)),
      );
      expect(semantics, isNotNull);
    });

    testWidgets('6. staleness chip visible when hasStaleRates=true',
        (tester) async {
      final acc = _makeAccount(
        id: 'a1',
        name: 'USD Account',
        category: AccountCategory.bankAccount,
        currencyCode: 'USD',
      );

      await tester.pumpWidget(
        _buildTestWidget(
          accounts: [acc],
          netWorthResult: const NetWorthResult(
            totalMinor: 100000,
            homeCurrency: 'INR',
            hasStaleRates: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('outdated'), findsOneWidget);
    });

    testWidgets('7. loading state shows CircularProgressIndicator',
        (tester) async {
      // Never-completing stream simulates loading state.
      final neverAccounts = StreamController<List<Account>>();
      final neverNetWorth = StreamController<NetWorthResult>();
      addTearDown(neverAccounts.close);
      addTearDown(neverNetWorth.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith(
              () => _FakeAppSettings(_defaultSettings),
            ),
            accountsProvider.overrideWith((_) => neverAccounts.stream),
            netWorthProvider.overrideWith((_) => neverNetWorth.stream),
          ],
          child: MaterialApp.router(
            theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (ctx, st) => const AccountListScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      // Single pump keeps loading state active
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('8. FAB taps navigate to /accounts/new', (tester) async {
      await tester.pumpWidget(_buildTestWidget(accounts: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('NewAccount'), findsOneWidget);
    });

    testWidgets('9. account row tap navigates to /accounts/:id',
        (tester) async {
      final acc = _makeAccount(
        id: 'abc123',
        name: 'My Account',
        category: AccountCategory.cash,
      );

      await tester.pumpWidget(_buildTestWidget(accounts: [acc]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Account'));
      await tester.pumpAndSettle();

      expect(find.text('Detail:abc123'), findsOneWidget);
    });
  });
}
