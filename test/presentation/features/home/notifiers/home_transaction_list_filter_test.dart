// test/presentation/features/home/notifiers/home_transaction_list_filter_test.dart
//
// Unit tests for HomeTransactionListNotifier filter integration (T-164).
//
// These tests verify that FilterState predicates are applied correctly to the
// transaction list returned by the repository.
//
// Test cases:
//   T-164.1. FilterState.types filters by transaction type
//   T-164.2. FilterState.accountIds filters by source/destination account
//   T-164.3. FilterState.categoryIds filters by category
//   T-164.4. FilterState.dateRange filters by date
//   T-164.5. FilterState.minAmountMinor filters by minimum amount
//   T-164.6. FilterState.sortField=amount desc sorts by amount descending
//   T-164.7. FilterState.hasActiveFilters=false shows all rows

import 'dart:async';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/presentation/features/home/notifiers/home_transaction_list_notifier.dart';
import 'package:variance/presentation/providers/filter_providers.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Transaction _makeTx(
  String id, {
  int date = 1000000,
  TransactionType type = TransactionType.expense,
  TransactionStatus status = TransactionStatus.posted,
  TransactionPurpose purpose = TransactionPurpose.user,
  int amountMinor = 1000,
  String? accountSourceId,
  String? accountDestinationId,
  String? categoryId,
}) =>
    Transaction(
      id: id,
      type: type,
      status: status,
      purpose: purpose,
      dateTime: date,
      amountMinor: amountMinor,
      currencyCode: 'INR',
      createdAt: 0,
      updatedAt: 0,
      accountSourceId: accountSourceId,
      accountDestinationId: accountDestinationId,
      categoryId: categoryId,
    );

class _FakeTransactionRepository implements ITransactionRepository {
  List<Transaction> rows = [];
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    Future.microtask(() => _controller.add(rows));
    return _controller.stream;
  }

  void dispose() => _controller.close();

  @override
  Stream<Transaction?> watchById(String id) => Stream.value(null);
  @override
  Future<Result<Transaction>> create(Transaction draft) async => Ok(draft);
  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async =>
      Ok(draft);
  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) async =>
      Ok(draft);
  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) async =>
      Ok(correction);
  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) async =>
      Err(const DatabaseFailure('stub'));
  @override
  Future<Result<void>> void$(String id) async => Ok(null);
  @override
  Future<Result<void>> bulkVoid(List<String> ids) async => Ok(null);
  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) async =>
      Ok([]);
  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) async => [];
  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) async =>
      Ok(null);
}

class _FakeHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => HomeState(
        selectedMonth: DateTime(2025, 5),
        netWorthMinor: 0,
        netWorthCurrencyCode: 'INR',
        hasStaleFx: false,
        monthlySummary: MonthlySummary(
          incomeMinor: 0,
          expensesMinor: 0,
          netMinor: 0,
          currencyCode: 'INR',
          hasStaleFx: false,
        ),
      );
}

/// A FilterNotifier that starts from a fixed [FilterState].
class _FixedFilterNotifier extends FilterNotifier {
  _FixedFilterNotifier({required this.initial});
  final FilterState initial;

  @override
  FilterState build() => initial;
}

ProviderContainer _makeContainer({
  required List<Transaction> rows,
  FilterState filter = const FilterState(),
  _FakeTransactionRepository? fakeRepo,
}) {
  final repo = fakeRepo ?? _FakeTransactionRepository();
  repo.rows = rows;

  return ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWith(
        (ref) async => repo as ITransactionRepository,
      ),
      homeProvider.overrideWith(() => _FakeHomeNotifier()),
      filterProvider.overrideWith(
        () => _FixedFilterNotifier(initial: filter),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeTransactionListNotifier filter integration — T-164', () {
    // -----------------------------------------------------------------------
    // T-164.1: type filter
    // -----------------------------------------------------------------------
    test('T-164.1 type filter excludes non-matching types', () async {
      final txExpense = _makeTx('e1', type: TransactionType.expense);
      final txIncome = _makeTx('i1', type: TransactionType.income);

      final repo = _FakeTransactionRepository()..rows = [txExpense, txIncome];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txExpense, txIncome],
        filter: const FilterState(types: [TransactionType.expense]),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      // Only expense transaction should be present.
      expect(state.transactions.any((t) => t.id == 'e1'), isTrue);
      expect(state.transactions.any((t) => t.id == 'i1'), isFalse);
    });

    // -----------------------------------------------------------------------
    // T-164.2: account filter
    // -----------------------------------------------------------------------
    test('T-164.2 account filter excludes non-matching accounts', () async {
      final txAcc1 = _makeTx('a1', accountSourceId: 'acc-1');
      final txAcc2 = _makeTx('a2', accountSourceId: 'acc-2');

      final repo = _FakeTransactionRepository()..rows = [txAcc1, txAcc2];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txAcc1, txAcc2],
        filter: const FilterState(accountIds: ['acc-1']),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      expect(state.transactions.any((t) => t.id == 'a1'), isTrue);
      expect(state.transactions.any((t) => t.id == 'a2'), isFalse);
    });

    // -----------------------------------------------------------------------
    // T-164.3: category filter
    // -----------------------------------------------------------------------
    test('T-164.3 category filter excludes non-matching categories', () async {
      final txCat1 = _makeTx('c1', categoryId: 'cat-1');
      final txCat2 = _makeTx('c2', categoryId: 'cat-2');

      final repo = _FakeTransactionRepository()..rows = [txCat1, txCat2];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txCat1, txCat2],
        filter: const FilterState(categoryIds: ['cat-1']),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      expect(state.transactions.any((t) => t.id == 'c1'), isTrue);
      expect(state.transactions.any((t) => t.id == 'c2'), isFalse);
    });

    // -----------------------------------------------------------------------
    // T-164.4: date range filter
    // -----------------------------------------------------------------------
    test('T-164.4 date range filter excludes out-of-range transactions',
        () async {
      // Epoch for 2025-05-15 = 1747267200
      const inRangeEpoch = 1747267200;
      // Epoch for 2025-04-01 = 1743465600 (out of range)
      const outOfRangeEpoch = 1743465600;

      final txIn = _makeTx('d1', date: inRangeEpoch);
      final txOut = _makeTx('d2', date: outOfRangeEpoch);

      final repo = _FakeTransactionRepository()..rows = [txIn, txOut];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txIn, txOut],
        filter: FilterState(
          dateRange: DateTimeRange(
            start: DateTime.utc(2025, 5, 1),
            end: DateTime.utc(2025, 5, 31),
          ),
        ),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      expect(state.transactions.any((t) => t.id == 'd1'), isTrue);
      expect(state.transactions.any((t) => t.id == 'd2'), isFalse);
    });

    // -----------------------------------------------------------------------
    // T-164.5: amount filter
    // -----------------------------------------------------------------------
    test('T-164.5 minAmountMinor filter excludes small amounts', () async {
      final txBig = _makeTx('m1', amountMinor: 10000);
      final txSmall = _makeTx('m2', amountMinor: 500);

      final repo = _FakeTransactionRepository()..rows = [txBig, txSmall];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txBig, txSmall],
        filter: const FilterState(minAmountMinor: 1000),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      expect(state.transactions.any((t) => t.id == 'm1'), isTrue);
      expect(state.transactions.any((t) => t.id == 'm2'), isFalse);
    });

    // -----------------------------------------------------------------------
    // T-164.6: sort by amount descending
    // -----------------------------------------------------------------------
    test('T-164.6 sort by amount descending orders correctly', () async {
      final txSmall = _makeTx('s1', amountMinor: 100, date: 2000000);
      final txBig = _makeTx('s2', amountMinor: 9000, date: 1000000);

      final repo = _FakeTransactionRepository()..rows = [txSmall, txBig];
      addTearDown(repo.dispose);

      final container = _makeContainer(
        rows: [txSmall, txBig],
        filter: const FilterState(
          sortField: SortField.amount,
          sortDirection: SortDirection.descending,
        ),
        fakeRepo: repo,
      );
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);

      // s2 (9000) should come before s1 (100).
      final ids = state.transactions.map((t) => t.id).toList();
      expect(ids.indexOf('s2'), lessThan(ids.indexOf('s1')));
    });

    // -----------------------------------------------------------------------
    // T-164.7: no filter — all rows returned
    // -----------------------------------------------------------------------
    test('T-164.7 no active filter returns all rows', () async {
      final rows = List.generate(5, (i) => _makeTx('tx$i', date: 1000000 - i));

      final repo = _FakeTransactionRepository()..rows = rows;
      addTearDown(repo.dispose);

      final container = _makeContainer(rows: rows, fakeRepo: repo);
      addTearDown(container.dispose);

      final state = await container.read(homeTransactionListProvider.future);
      expect(state.transactions.length, equals(5));
    });
  });
}
