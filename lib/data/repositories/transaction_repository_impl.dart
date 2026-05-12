// lib/data/repositories/transaction_repository_impl.dart
//
// Concrete implementation of ITransactionRepository backed by Drift via
// TransactionDao.
//
// Responsibilities:
//   - Delegates all reads to TransactionDao methods
//   - Maps Drift rows to domain entities using TransactionDto / EntryDto
//   - Creates/corrects/voids transactions via TransactionDao
//   - Full-text search via FTS5 through TransactionDao.searchByFts
//
// Not responsible for:
//   - Business rules (duplicate detection, overdraft) — those live in use cases
//   - Ledger entry generation — that is LedgerEngine's job
//   - Balance computation — that is BalanceCalculator's job
//
// Test cases (see test/data/repositories/transaction_repository_impl_test.dart):
//   - create() inserts a transaction and entries; returns Ok(Transaction)
//   - watchByMonth() returns transactions in the correct month
//   - watchById() returns a stream of the transaction or null
//   - void$() sets status = voided
//   - bulkVoid() voids multiple transactions atomically
//   - updateNonFinancial() updates title/description without touching entries

import 'dart:developer' as dev;

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart'
    show TransactionsCompanion;
import 'package:variance/data/database/daos/transaction_dao.dart';
import 'package:variance/data/models/transaction_dto.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
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

  final TransactionDao _dao;

  // -----------------------------------------------------------------------
  // Stream queries
  // -----------------------------------------------------------------------

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    return _dao.watchByMonth(year, month).map(
          (rows) => rows
              .map((row) => TransactionDto.fromRow(row).toEntity())
              .where(
                (tx) => _applyFilters(tx, filters),
              )
              .toList(),
        );
  }

  @override
  Stream<Transaction?> watchById(String id) {
    return _dao.watchById(id).map(
          (row) => row == null ? null : TransactionDto.fromRow(row).toEntity(),
        );
  }

  // -----------------------------------------------------------------------
  // Writes
  // -----------------------------------------------------------------------

  @override
  Future<Result<Transaction>> create(Transaction draft) async {
    try {
      final companion = TransactionDto.toCompanion(draft);
      // Entries are expected to already be persisted by LedgerEngine before
      // this call, or the use case passes them in a combined write.
      // For now, create() only inserts the transaction header; entries are
      // handled by the use case via LedgerEngine.
      await _dao.insertTransactionWithEntries(companion, []);
      final savedRow = await _dao.getById(draft.id);
      if (savedRow == null) {
        return const Err(DatabaseFailure('Transaction not found after insert'));
      }
      return Ok(TransactionDto.fromRow(savedRow).toEntity());
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.create error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to create transaction: $e'));
    }
  }

  /// Creates a transaction header together with its [entries] in a single
  /// atomic database write.
  ///
  /// This overload is called by [CreateTransactionUseCase] which constructs
  /// the entries via [LedgerEngine] before delegating to the repository.
  ///
  /// Parameters:
  /// - [draft]: The fully validated [Transaction] domain entity.
  /// - [entries]: The balanced [Entry] list produced by [LedgerEngine].
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async {
    try {
      final txnCompanion = TransactionDto.toCompanion(draft);
      final entryCompanions = entries.map(EntryDto.toCompanion).toList();

      await _dao.insertTransactionWithEntries(txnCompanion, entryCompanions);

      final savedRow = await _dao.getById(draft.id);
      if (savedRow == null) {
        return const Err(
          DatabaseFailure('Transaction not found after insert'),
        );
      }
      return Ok(TransactionDto.fromRow(savedRow).toEntity());
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.createWithEntries error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(
        DatabaseFailure('Failed to create transaction with entries: $e'),
      );
    }
  }

  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) async {
    // Correction = void original + insert reversal + insert correction.
    // This is orchestrated at the use-case level; the repository only provides
    // the primitive write operations.
    // TODO(dev): Implement full correction flow in EditTransactionUseCase (S-5).
    throw UnimplementedError('correctFinancial not yet implemented — S-5');
  }

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Build a companion containing only the fields the patch specifies.
      await _dao.updateNonFinancial(
        id,
        _patchToCompanion(patch, nowEpoch),
      );

      final savedRow = await _dao.getById(id);
      if (savedRow == null) {
        return const Err(NotFoundFailure('Transaction not found after update'));
      }
      return Ok(TransactionDto.fromRow(savedRow).toEntity());
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.updateNonFinancial error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(
        DatabaseFailure('Failed to update non-financial fields: $e'),
      );
    }
  }

  @override
  Future<Result<void>> void$(String id) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _dao.voidTransaction(id, nowEpoch);
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.void\$ error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to void transaction $id: $e'));
    }
  }

  @override
  Future<Result<void>> bulkVoid(List<String> ids) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _dao.bulkVoidTransactions(ids, nowEpoch);
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.bulkVoid error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to bulk-void transactions: $e'));
    }
  }

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) async {
    try {
      final rows = await _dao.searchByFts(query);
      final transactions = rows
          .map((row) => TransactionDto.fromRow(row).toEntity())
          .where((tx) => _applyFilters(tx, filters))
          .toList();
      return Ok(transactions);
    } on Object catch (e, st) {
      dev.log(
        'TransactionRepositoryImpl.search error: $e',
        name: 'TransactionRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('FTS search failed: $e'));
    }
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Applies [TransactionFilters] to a [Transaction] for in-memory post-filter.
  ///
  /// Returns true if [tx] passes all active filters.
  bool _applyFilters(Transaction tx, TransactionFilters? filters) {
    if (filters == null) return true;
    if (filters.accountId != null &&
        tx.accountSourceId != filters.accountId &&
        tx.accountDestinationId != filters.accountId) {
      return false;
    }
    if (filters.categoryId != null && tx.categoryId != filters.categoryId) {
      return false;
    }
    if (filters.type != null && tx.type != filters.type) {
      return false;
    }
    return true;
  }

  /// Builds a [TransactionsCompanion] from a [TransactionNonFinancialPatch].
  ///
  /// Only fields explicitly set in [patch] are written; others remain absent.
  ///
  /// Parameters:
  /// - [patch]: The non-financial patch object.
  /// - [updatedAt]: Unix epoch seconds for the update timestamp.
  TransactionsCompanion _patchToCompanion(
    TransactionNonFinancialPatch patch,
    int updatedAt,
  ) {
    return TransactionsCompanion(
      title: patch.title != null ? Value(patch.title) : const Value.absent(),
      description: patch.description != null
          ? Value(patch.description)
          : const Value.absent(),
      transactionDate: patch.dateTime != null
          ? Value(patch.dateTime!)
          : const Value.absent(),
      payeeId:
          patch.payeeId != null ? Value(patch.payeeId) : const Value.absent(),
      updatedAt: Value(updatedAt),
    );
  }
}
