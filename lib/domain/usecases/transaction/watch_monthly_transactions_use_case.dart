// lib/domain/usecases/transaction/watch_monthly_transactions_use_case.dart
//
// Use case: watch the transaction list for a given calendar month.

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Watches all display-eligible transactions for the given [year] and [month].
///
/// Returns a Stream; errors surface via the stream's error channel.
class WatchMonthlyTransactionsUseCase {
  const WatchMonthlyTransactionsUseCase(this._repository);

  // ignore: unused_field
  final ITransactionRepository _repository;

  /// Executes the use case.
  ///
  /// [year] — four-digit calendar year.
  /// [month] — 1-based month (1 = January, 12 = December).
  Stream<List<Transaction>> call(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    throw UnimplementedError(
      'WatchMonthlyTransactionsUseCase.call is not implemented',
    );
  }
}
