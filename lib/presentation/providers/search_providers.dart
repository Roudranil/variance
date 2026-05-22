// lib/presentation/providers/search_providers.dart
//
// Riverpod providers for transaction search (T-58).
//
// Provider graph:
//   searchNotifierProvider  → SearchTransactionsUseCase (via use_case_providers)
//
// SearchNotifier:
//   - Holds current query string.
//   - Debounces user input by 300 ms (SDS §2.8.3).
//   - On non-empty query: triggers FTS5 search, emits AsyncValue<List<Transaction>>.
//   - On empty/cleared query: emits AsyncValue.data([]) immediately.
//   - Search scope is global — month filter is NOT applied (TC-050).
//
// Test cases (see test/unit/domain/usecases/search/search_providers_test.dart):
//   1. initial state is AsyncValue.data([])
//   2. setQuery with blank resets to AsyncValue.data([]) without calling use case
//   3. setQuery triggers search after 300 ms debounce

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/usecases/transaction/search_transactions_use_case.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

part 'search_providers.g.dart';

// ---------------------------------------------------------------------------
// SearchNotifier
// ---------------------------------------------------------------------------

/// Manages full-text transaction search state.
///
/// Debounces user input by 300 ms. Empty queries immediately resolve to an
/// empty list without hitting the database.
@riverpod
class SearchNotifier extends _$SearchNotifier {
  Timer? _debounce;

  @override
  AsyncValue<List<Transaction>> build() {
    // Cancel debounce timer on dispose.
    ref.onDispose(() => _debounce?.cancel());
    // Initial state: empty results, no search active.
    return const AsyncValue.data([]);
  }

  /// Current search query string.
  String get currentQuery => _currentQuery;
  String _currentQuery = '';

  /// Updates the search query, debouncing by 300 ms before executing.
  ///
  /// Passing an empty or whitespace-only string immediately clears results
  /// without waiting for the debounce timer.
  ///
  /// Parameters:
  /// - [query]: The search string entered by the user.
  void setQuery(String query) {
    _currentQuery = query;
    _debounce?.cancel();

    // Immediately clear results on blank query — no debounce needed.
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    // Debounce: wait 300 ms before firing the FTS query.
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  /// Clears the search query and resets results to an empty list.
  void clear() => setQuery('');

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _search(String query) async {
    state = const AsyncValue.loading();

    // The use case provider is async (depends on DB). Await it.
    final useCase = await ref.read(searchTransactionsUseCaseProvider.future);

    final result = await useCase.call(SearchTransactionsInput(query: query));

    if (!ref.mounted) return;

    switch (result) {
      case Ok(:final value):
        state = AsyncValue.data(value);
      case Err(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
