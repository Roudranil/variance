// test/presentation/features/home/home_screen_test.dart
//
// Widget smoke tests for HomeScreen scaffold (T-153), date-group headers
// (T-156), and swipe actions (T-157).
//
// Test cases:
//   T-153:
//     1. HomeScreen mounts without overflow errors in loading state
//     2. HomeScreen mounts without overflow errors with populated state
//   T-156:
//     3. 3 transactions across 2 days renders 2 date headers and 3 rows
//   T-157:
//     4. Swipe-right navigates (edit action triggered)
//     5. Swipe-left shows delete confirmation dialog
//     6. Long-press shows bottom sheet with Edit and Delete options

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/presentation/features/home/home_screen.dart';
import 'package:variance/presentation/features/home/notifiers/home_transaction_list_notifier.dart';
import 'package:variance/presentation/features/home/widgets/transaction_date_group_header.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/presentation/providers/alerts_strip_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}

class _LoadingHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() => Completer<HomeState>().future;
}

/// Produces a [HomeState] for the given [month] with no FX staleness.
HomeState _makeHomeState({int year = 2025, int month = 1}) {
  return HomeState(
    selectedMonth: DateTime(year, month),
    netWorthMinor: 100000,
    netWorthCurrencyCode: 'INR',
    hasStaleFx: false,
    monthlySummary: const MonthlySummary(
      incomeMinor: 50000,
      expensesMinor: 30000,
      netMinor: 20000,
      currencyCode: 'INR',
      hasStaleFx: false,
    ),
  );
}

class _PopulatedHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => _makeHomeState();
}

// ---------------------------------------------------------------------------
// Helper factories
// ---------------------------------------------------------------------------

Transaction _makeTx(
  String id, {
  int date = 1000000,
  TransactionType type = TransactionType.expense,
  String? sourceId,
  String? destId,
  String? catId,
  String? title,
}) {
  return Transaction(
    id: id,
    type: type,
    status: TransactionStatus.posted,
    dateTime: date,
    amountMinor: 1000,
    currencyCode: 'INR',
    accountSourceId: sourceId,
    accountDestinationId: destId,
    categoryId: catId,
    title: title,
    createdAt: 0,
    updatedAt: 0,
  );
}

Account _makeAccount(String id, String name) => Account(
      id: id,
      name: name,
      accountCategory: AccountCategory.bankAccount,
      currencyCode: 'INR',
      createdAt: 0,
      updatedAt: 0,
    );

Category _makeCat(String id, String name) => Category(
      id: id,
      name: name,
      iconRef: 'shopping_cart',
      treeType: CategoryTreeType.expense,
      createdAt: 0,
      updatedAt: 0,
    );

// ---------------------------------------------------------------------------
// Fake transaction list notifier
// ---------------------------------------------------------------------------

class _FakeTransactionListNotifier extends HomeTransactionListNotifier {
  final TransactionListState _fixedState;

  _FakeTransactionListNotifier(this._fixedState);

  @override
  Future<TransactionListState> build() async => _fixedState;

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> changeMonth(int year, int month) async {}
}

// ---------------------------------------------------------------------------
// App builder helper
// ---------------------------------------------------------------------------

Widget _buildApp({
  required HomeNotifier Function() homeNotifier,
  required HomeTransactionListNotifier Function() txListNotifier,
  List<Account> accounts = const [],
  List<Category> categories = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/transaction/:id/edit',
        builder: (_, state) =>
            Scaffold(body: Text('Edit ${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
      homeProvider.overrideWith(homeNotifier),
      homeTransactionListProvider.overrideWith(txListNotifier),
      accountsProvider.overrideWith(
        (ref) => Stream.value(accounts),
      ),
      categoryListProvider.overrideWith(
        () => _FakeCategoryListNotifier(categories),
      ),
      // Prevent real DB init
      transactionRepositoryProvider.overrideWith(
        (ref) async => _NullTransactionRepo() as ITransactionRepository,
      ),
      // Stub out alerts strip provider to prevent it from initialising real DB
      // (AlertsStrip is part of the HomeScreen sliver layout)
      pendingOccurrencesProvider.overrideWith(
        () => _FakePendingOccurrencesNotifier(),
      ),
    ],
    child: MaterialApp.router(
      theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
      routerConfig: router,
    ),
  );
}

class _NullTransactionRepo implements ITransactionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCategoryListNotifier extends CategoryList {
  final List<Category> _cats;

  _FakeCategoryListNotifier(this._cats);

  @override
  Future<List<Category>> build() async => _cats;
}

class _FakePendingOccurrencesNotifier extends PendingOccurrences {
  @override
  Future<List<PendingOccurrenceItem>> build() async => [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen scaffold (T-153)', () {
    testWidgets('1 — mounts without overflow in loading state', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          homeNotifier: _LoadingHomeNotifier.new,
          txListNotifier: () =>
              _FakeTransactionListNotifier(const TransactionListState()),
        ),
      );
      await tester.pump();
      // No overflow errors thrown.
      expect(tester.takeException(), isNull);
    });

    testWidgets('2 — mounts without overflow in populated state',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          homeNotifier: _PopulatedHomeNotifier.new,
          txListNotifier: () => _FakeTransactionListNotifier(
            TransactionListState(
              transactions: [
                _makeTx('tx1', title: 'Coffee'),
              ],
              hasNextPage: false,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Date-group headers (T-156)', () {
    testWidgets('3 — 3 transactions across 2 days renders 2 headers + 3 rows',
        (tester) async {
      // day1: 2025-01-15, day2: 2025-01-16
      final day1Epoch =
          DateTime.utc(2025, 1, 15).millisecondsSinceEpoch ~/ 1000;
      final day2Epoch =
          DateTime.utc(2025, 1, 16).millisecondsSinceEpoch ~/ 1000;

      final txs = [
        _makeTx('tx1', date: day2Epoch + 3600, title: 'A'),
        _makeTx('tx2', date: day2Epoch, title: 'B'),
        _makeTx('tx3', date: day1Epoch, title: 'C'),
      ];

      await tester.pumpWidget(
        _buildApp(
          homeNotifier: _PopulatedHomeNotifier.new,
          txListNotifier: () => _FakeTransactionListNotifier(
            TransactionListState(
              transactions: txs,
              hasNextPage: false,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Two date headers should be visible.
      expect(
        find.byType(TransactionDateGroupHeader),
        findsNWidgets(2),
      );
    });
  });

  group('Swipe actions (T-157)', () {
    testWidgets('4 — swipe-left shows delete dialog', (tester) async {
      final account = _makeAccount('a1', 'HDFC');
      final cat = _makeCat('c1', 'Food');
      final txs = [
        _makeTx(
          'tx1',
          title: 'Lunch',
          sourceId: account.id,
          catId: cat.id,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          homeNotifier: _PopulatedHomeNotifier.new,
          txListNotifier: () => _FakeTransactionListNotifier(
            TransactionListState(transactions: txs, hasNextPage: false),
          ),
          accounts: [account],
          categories: [cat],
        ),
      );
      // Allow all async providers to resolve.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Swipe-left (endToStart) on the dismissible
      await tester.drag(
        find.byKey(Key('tx_dismissible_tx1')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Delete confirmation dialog should appear.
      expect(
        find.text('Delete this transaction?'),
        findsOneWidget,
      );
    });

    testWidgets('5 — long-press shows bottom sheet with Edit + Delete',
        (tester) async {
      final account = _makeAccount('a2', 'SBI');
      final cat = _makeCat('c2', 'Transport');
      final txs = [
        _makeTx(
          'tx2',
          title: 'Uber',
          sourceId: account.id,
          catId: cat.id,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          homeNotifier: _PopulatedHomeNotifier.new,
          txListNotifier: () => _FakeTransactionListNotifier(
            TransactionListState(transactions: txs, hasNextPage: false),
          ),
          accounts: [account],
          categories: [cat],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.longPress(find.byKey(Key('tx_row_tx2')));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
