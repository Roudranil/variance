// lib/domain/usecases/transaction/search_transactions_use_case.dart
//
// Use case: full-text search across transactions.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Full-text search input parameters.
class SearchTransactionsInput {
  const SearchTransactionsInput({
    required this.query,
    this.filters,
  });

  final String query;
  final TransactionFilters? filters;
}

/// Searches transactions using FTS5 and optional filters.
class SearchTransactionsUseCase {
  const SearchTransactionsUseCase(this._repository);

  // ignore: unused_field
  final ITransactionRepository _repository;

  /// Executes the full-text search.
  Future<Result<List<Transaction>>> call(SearchTransactionsInput input) {
    throw UnimplementedError(
      'SearchTransactionsUseCase.call is not implemented',
    );
  }
}
