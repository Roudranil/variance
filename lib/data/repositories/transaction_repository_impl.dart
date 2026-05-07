// lib/data/repositories/transaction_repository_impl.dart
//
// Concrete implementation of ITransactionRepository backed by Drift via
// TransactionDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic is implemented in later feature tasks (S-5 onward).
//
// Test cases (see test/providers/repository_providers_test.dart):
//   - transactionRepositoryProvider resolves from ProviderContainer without error
//   - Injected TransactionDao is the same instance exposed by appDatabaseProvider

import 'package:variance/data/database/daos/transaction_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Drift-backed implementation of [ITransactionRepository].
///
/// All methods delegate to [TransactionDao] for data access. Business rules
/// (duplicate detection, overdraft checks, posting-case selection) live in the
/// corresponding use cases, not here.
class TransactionRepositoryImpl implements ITransactionRepository {
  /// Creates a [TransactionRepositoryImpl] backed by [dao].
  const TransactionRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
  final TransactionDao _dao;

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    // TODO(dev): Implement month-scoped query with optional filters (S-5).
    throw UnimplementedError('watchByMonth not yet implemented');
  }

  @override
  Stream<Transaction?> watchById(String id) {
    // TODO(dev): Implement single-transaction stream (S-5).
    throw UnimplementedError('watchById not yet implemented');
  }

  @override
  Future<Result<Transaction>> create(Transaction draft) {
    // TODO(dev): Implement atomic insert with entries (S-5).
    throw UnimplementedError('create not yet implemented');
  }

  @override
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft) {
    // TODO(dev): Implement reversal+correction pair (S-5).
    throw UnimplementedError('correctFinancial not yet implemented');
  }

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) {
    // TODO(dev): Implement in-place non-financial field update (S-5).
    throw UnimplementedError('updateNonFinancial not yet implemented');
  }

  @override
  Future<Result<void>> void$(String id) {
    // TODO(dev): Implement single-transaction void (S-5).
    throw UnimplementedError('void\$ not yet implemented');
  }

  @override
  Future<Result<void>> bulkVoid(List<String> ids) {
    // TODO(dev): Implement bulk void in one DB transaction (S-5).
    throw UnimplementedError('bulkVoid not yet implemented');
  }

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) {
    // TODO(dev): Implement FTS5 search with optional filters (S-5).
    throw UnimplementedError('search not yet implemented');
  }
}
