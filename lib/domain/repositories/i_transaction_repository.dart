// lib/domain/repositories/i_transaction_repository.dart
//
// Abstract repository interface for the Transaction aggregate.
//
// Financial edits use correctFinancial (reversal + correction pair in a single
// DB transaction). Non-financial in-place edits use updateNonFinancial.
// Void and bulk-void mark transactions as voided without a correction chain.

import 'package:variance/domain/core/result.dart';
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

  /// Corrects financial fields via a reversal + correction pair, both
  /// wrapped in a single database transaction.
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft);

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
}
