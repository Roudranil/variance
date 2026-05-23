// test/unit/domain/usecases/home/watch_monthly_summary_use_case_test.dart
//
// Unit tests for WatchMonthlySummaryUseCase (T-148).
//
// Test cases:
//   1. empty month (no transactions) emits zero summary
//   2. income-only month: income > 0, expenses = 0, net = income
//   3. expense-only month: income = 0, expenses > 0, net = -expenses
//   4. mixed month: correct net = income − expenses
//   5. transfers excluded from income/expense totals
//   6. transactions outside queried month excluded

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';

// ---------------------------------------------------------------------------
// Minimal fake ITransactionRepository
// ---------------------------------------------------------------------------

class _FakeTransactionRepository implements ITransactionRepository {
  _FakeTransactionRepository(this._transactions);

  final List<Transaction> _transactions;

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    final filtered = _transactions.where((tx) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.dateTime * 1000);
      return date.year == year && date.month == month;
    }).toList();
    return Stream.value(filtered);
  }

  @override
  Stream<Transaction?> watchById(String id) => Stream.value(null);

  @override
  Future<Result<Transaction>> create(Transaction draft) async =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> void$(String id) async => throw UnimplementedError();

  @override
  Future<Result<void>> bulkVoid(List<String> ids) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) async => [];

  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) async =>
      throw UnimplementedError();

  @override
  Future<int> countPosted() async => 0;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Transaction _makeTx({
  required TransactionType type,
  required int amountMinor,
  required String currencyCode,
  required int epochSeconds,
  TransactionStatus status = TransactionStatus.posted,
}) {
  return Transaction(
    id: 'test-$epochSeconds-${type.name}',
    type: type,
    status: status,
    dateTime: epochSeconds,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    createdAt: epochSeconds,
    updatedAt: epochSeconds,
  );
}

int _epochForMonth(int year, int month) {
  return DateTime.utc(year, month, 15).millisecondsSinceEpoch ~/ 1000;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const homeCurrency = 'INR';

  WatchMonthlySummaryUseCase _buildUseCase(List<Transaction> transactions) {
    return WatchMonthlySummaryUseCase(
      transactionRepository: _FakeTransactionRepository(transactions),
      homeCurrency: homeCurrency,
    );
  }

  group('WatchMonthlySummaryUseCase', () {
    test('empty month emits zero summary', () async {
      final useCase = _buildUseCase([]);
      final summary = await useCase.call(2025, 1).first;

      expect(summary.incomeMinor, 0);
      expect(summary.expensesMinor, 0);
      expect(summary.netMinor, 0);
      expect(summary.currencyCode, homeCurrency);
      expect(summary.hasStaleFx, isFalse);
    });

    test('income-only month: income aggregated, expenses zero', () async {
      final tx = _makeTx(
        type: TransactionType.income,
        amountMinor: 50000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 5),
      );
      final summary = await _buildUseCase([tx]).call(2025, 5).first;

      expect(summary.incomeMinor, 50000);
      expect(summary.expensesMinor, 0);
      expect(summary.netMinor, 50000);
    });

    test('expense-only month: expenses aggregated, income zero', () async {
      final tx = _makeTx(
        type: TransactionType.expense,
        amountMinor: 20000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 5),
      );
      final summary = await _buildUseCase([tx]).call(2025, 5).first;

      expect(summary.incomeMinor, 0);
      expect(summary.expensesMinor, 20000);
      expect(summary.netMinor, -20000);
    });

    test('mixed month: net = income − expenses', () async {
      final income = _makeTx(
        type: TransactionType.income,
        amountMinor: 80000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 3),
      );
      final expense = _makeTx(
        type: TransactionType.expense,
        amountMinor: 30000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 3),
      );
      final summary =
          await _buildUseCase([income, expense]).call(2025, 3).first;

      expect(summary.incomeMinor, 80000);
      expect(summary.expensesMinor, 30000);
      expect(summary.netMinor, 50000);
    });

    test('transfers excluded from income/expense totals', () async {
      final transfer = _makeTx(
        type: TransactionType.transfer,
        amountMinor: 40000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 4),
      );
      final summary = await _buildUseCase([transfer]).call(2025, 4).first;

      expect(summary.incomeMinor, 0);
      expect(summary.expensesMinor, 0);
      expect(summary.netMinor, 0);
    });

    test('transactions outside the queried month are excluded', () async {
      // June transaction queried for May.
      final tx = _makeTx(
        type: TransactionType.income,
        amountMinor: 50000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 6),
      );
      final summary = await _buildUseCase([tx]).call(2025, 5).first;

      expect(summary.incomeMinor, 0);
      expect(summary.expensesMinor, 0);
    });

    test('reversal transactions are excluded from totals', () async {
      final reversal = _makeTx(
        type: TransactionType.income,
        amountMinor: 50000,
        currencyCode: homeCurrency,
        epochSeconds: _epochForMonth(2025, 5),
      );
      // Create the reversal by setting purpose = reversal via copyWith.
      final reversalTx = Transaction(
        id: reversal.id,
        type: reversal.type,
        status: TransactionStatus.posted,
        purpose: TransactionPurpose.reversal,
        dateTime: reversal.dateTime,
        amountMinor: reversal.amountMinor,
        currencyCode: reversal.currencyCode,
        createdAt: reversal.createdAt,
        updatedAt: reversal.updatedAt,
      );
      final summary = await _buildUseCase([reversalTx]).call(2025, 5).first;

      expect(summary.incomeMinor, 0);
    });
  });
}
