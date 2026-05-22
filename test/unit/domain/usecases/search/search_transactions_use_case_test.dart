// test/unit/domain/usecases/search/search_transactions_use_case_test.dart
//
// Unit tests for SearchTransactionsUseCase (T-58).
//
// Test cases:
//   1. empty query returns Ok([]) without hitting repository
//   2. non-empty query delegates to repository.search and returns Ok(results)
//   3. repository search error returns Err
//   4. whitespace-only query is treated as empty (returns Ok([]))
//   5. filters forwarded to repository.search call

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/usecases/transaction/search_transactions_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeTransactionRepository implements ITransactionRepository {
  /// When set, `search` returns this result.
  Result<List<Transaction>>? searchResult;

  /// Records the last query passed to `search`.
  String? lastQuery;

  /// Records the last filters passed to `search`.
  TransactionFilters? lastFilters;

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) async {
    lastQuery = query;
    lastFilters = filters;
    return searchResult ?? const Ok([]);
  }

  // Unused methods — only `search` is exercised by this use case.
  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) => throw UnimplementedError();
  @override
  Stream<Transaction?> watchById(String id) => throw UnimplementedError();
  @override
  Future<Result<Transaction>> create(Transaction draft) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) => throw UnimplementedError();
  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) => throw UnimplementedError();
  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) => throw UnimplementedError();
  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) => throw UnimplementedError();
  @override
  Future<Result<void>> void$(String id) => throw UnimplementedError();
  @override
  Future<Result<void>> bulkVoid(List<String> ids) =>
      throw UnimplementedError();
  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Transaction _makeTransaction(String id) => Transaction(
      id: id,
      type: TransactionType.expense,
      status: TransactionStatus.posted,
      dateTime: 0,
      amountMinor: 1000,
      currencyCode: 'INR',
      createdAt: 0,
      updatedAt: 0,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeTransactionRepository repo;
  late SearchTransactionsUseCase useCase;

  setUp(() {
    repo = _FakeTransactionRepository();
    useCase = SearchTransactionsUseCase(repo);
  });

  group('SearchTransactionsUseCase', () {
    test('1. empty query returns Ok([]) without hitting repository', () async {
      final result = await useCase(
        const SearchTransactionsInput(query: ''),
      );

      expect(result, isA<Ok<List<Transaction>>>());
      expect((result as Ok).value, isEmpty);
      // Repository must NOT have been called.
      expect(repo.lastQuery, isNull);
    });

    test('2. non-empty query returns Ok(results) from repository', () async {
      final txns = [_makeTransaction('tx-1'), _makeTransaction('tx-2')];
      repo.searchResult = Ok(txns);

      final result = await useCase(
        const SearchTransactionsInput(query: 'coffee'),
      );

      expect(result, isA<Ok<List<Transaction>>>());
      expect((result as Ok).value, equals(txns));
      expect(repo.lastQuery, equals('coffee'));
    });

    test('3. repository search error propagates as Err', () async {
      repo.searchResult = const Err(DatabaseFailure('FTS error'));

      final result = await useCase(
        const SearchTransactionsInput(query: 'groceries'),
      );

      expect(result, isA<Err<List<Transaction>>>());
    });

    test('4. whitespace-only query returns Ok([]) without calling repository',
        () async {
      final result = await useCase(
        const SearchTransactionsInput(query: '   '),
      );

      expect(result, isA<Ok<List<Transaction>>>());
      expect((result as Ok).value, isEmpty);
      expect(repo.lastQuery, isNull);
    });

    test('5. filters are forwarded to repository search call', () async {
      const filters = TransactionFilters(categoryId: 'cat-1');
      repo.searchResult = const Ok([]);

      await useCase(
        const SearchTransactionsInput(query: 'lunch', filters: filters),
      );

      expect(repo.lastFilters?.categoryId, equals('cat-1'));
    });
  });
}
