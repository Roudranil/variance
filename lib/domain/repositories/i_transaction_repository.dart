// lib/domain/repositories/i_transaction_repository.dart
//
// Abstract repository interface for the Transaction aggregate.
//
// Financial edits use correctFinancial (reversal + correction pair in a single
// DB transaction). Non-financial in-place edits use updateNonFinancial.
// Void and bulk-void mark transactions as voided without a correction chain.
//
// createWithEntries atomically writes the transaction header + entry rows in a
// single DB transaction — used by CreateTransactionUseCase (T-49, T-50) to
// satisfy SDS §1.6.2 atomicity requirement.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';

/// Patch object for non-financial in-place edits.
///
/// Only the fields present (non-null) are applied.
class TransactionNonFinancialPatch {
  const TransactionNonFinancialPatch({
    this.title,
    this.description,
    this.dateTime,
    this.payeeId,
  });

  final String? title;
  final String? description;
  final int? dateTime;
  final String? payeeId;
}

/// Optional filters for transaction list queries.
class TransactionFilters {
  const TransactionFilters({
    this.accountId,
    this.categoryId,
    this.type,
  });

  final String? accountId;
  final String? categoryId;
  final TransactionType? type;
}

/// Contract for all Transaction data-access operations.
abstract interface class ITransactionRepository {
  /// Watches all non-voided, non-reversal transactions for a given month.
  ///
  /// [year] and [month] use calendar values (e.g. 2025, 5 for May 2025).
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  });

  /// Watches a single transaction by UUID.
  Stream<Transaction?> watchById(String id);

  /// Creates a new transaction from [draft] (a fully validated Transaction
  /// value object in status=pending or posted).
  Future<Result<Transaction>> create(Transaction draft);

  /// Creates a transaction header and its [entries] atomically in one DB
  /// transaction (SDS §1.6.2).
  ///
  /// Called by [CreateTransactionUseCase] after [LedgerEngine] has built the
  /// balanced entry set. The caller must never write the entries separately.
  ///
  /// Parameters:
  /// - [draft]: The fully validated [Transaction] entity to persist.
  /// - [entries]: The balanced [Entry] list from [LedgerEngine].
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  );

  /// Corrects financial fields via a reversal + correction pair, both
  /// wrapped in a single database transaction.
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft);

  /// Atomically executes the full correction chain in one DB transaction:
  ///   1. Voids the original ([originalId]).
  ///   2. Inserts [reversal] + [reversalEntries].
  ///   3. Inserts [correction] + [correctionEntries].
  ///
  /// Returns the persisted [correction] transaction on success.
  ///
  /// Parameters:
  /// - [originalId]: UUID of the posted transaction being corrected.
  /// - [reversal]: Pre-built reversal transaction (purpose = 'reversal').
  /// - [reversalEntries]: Balanced entries for the reversal.
  /// - [correction]: Pre-built correction transaction (purpose = 'correction').
  /// - [correctionEntries]: Balanced entries for the correction.
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  });

  /// Updates non-financial fields (title, description, dateTime, payeeId)
  /// in-place; does not create a ledger entry pair.
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  );

  /// Voids a single transaction.
  Future<Result<void>> void$(String id);

  /// Voids multiple transactions atomically.
  Future<Result<void>> bulkVoid(List<String> ids);

  /// Full-text search with optional filters.
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  });

  /// Returns all transactions with status = 'pending' whose date_time is
  /// at or before [nowEpoch].
  ///
  /// Used by [PostPendingTransactionsUseCase] on app launch to sweep due
  /// transactions (T-60).
  ///
  /// Parameters:
  /// - [nowEpoch]: Current Unix epoch seconds (the threshold).
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch);

  /// Atomically writes [entries] for transaction [id] and sets
  /// status = 'posted'.
  ///
  /// Called by [PostPendingTransactionsUseCase] after building balanced
  /// entries for a pending transaction that has become due.
  ///
  /// Parameters:
  /// - [id]: UUID of the pending transaction to post.
  /// - [entries]: Balanced entry list from [LedgerEngine].
  Future<Result<void>> postPending(String id, List<Entry> entries);
}
