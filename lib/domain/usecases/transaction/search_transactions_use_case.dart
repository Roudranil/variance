// lib/domain/usecases/transaction/search_transactions_use_case.dart
//
// Use case: full-text search across transactions (T-58).
//
// Behaviour:
//   1. If query is empty or whitespace-only, return Ok([]) immediately.
//   2. Delegate to ITransactionRepository.search with optional filters.
//   3. Return Ok(results) or Err from the repository.
//
// FTS5 search is global across all transactions (TC-050 founder resolution):
// the month filter is NOT applied during search. The repository layer (backed
// by TransactionDao.searchByFts) handles FTS5 query execution.
//
// Spec: T-58, TXN-08, SDS §2.8
//
// Test cases (see test/unit/domain/usecases/search/search_transactions_use_case_test.dart):
//   1. empty query returns Ok([]) without hitting repository
//   2. non-empty query returns Ok(results) from repository
//   3. repository search error propagates as Err
//   4. whitespace-only query returns Ok([]) without calling repository
//   5. filters forwarded to repository.search call

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Input parameters for a full-text transaction search.
class SearchTransactionsInput {
  /// Creates a [SearchTransactionsInput].
  ///
  /// Parameters:
  /// - [query]: The search string; FTS5 match expression.
  /// - [filters]: Optional column-level filters applied after FTS5 scoring.
  const SearchTransactionsInput({required this.query, this.filters});

  /// The FTS5 match expression (e.g. 'groceries', '"coffee shop"').
  final String query;

  /// Optional column-level post-filters on the FTS candidates.
  final TransactionFilters? filters;
}

/// Searches transactions by full text with optional filters.
///
/// Delegates to [ITransactionRepository.search] for FTS5 execution.
/// Empty or whitespace-only queries return an empty list without a database
/// round-trip.
class SearchTransactionsUseCase {
  /// Creates a [SearchTransactionsUseCase] backed by [repository].
  const SearchTransactionsUseCase(this._repository);

  final ITransactionRepository _repository;

  /// Executes the full-text search for [input.query].
  ///
  /// Returns [Ok(results)] on success, or [Err] when the FTS query fails.
  /// Returns [Ok([])] immediately when [input.query] is empty or
  /// contains only whitespace — no database round-trip is made.
  ///
  /// Parameters:
  /// - [input]: Query string and optional column-level filters.
  Future<Result<List<Transaction>>> call(SearchTransactionsInput input) async {
    // Short-circuit on blank queries — avoids a no-op FTS scan.
    if (input.query.trim().isEmpty) {
      return const Ok([]);
    }

    return _repository.search(
      input.query,
      filters: input.filters,
    );
  }
}
