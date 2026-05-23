// lib/presentation/providers/search_providers.dart
//
// Riverpod providers for transaction search (T-58, T-159).
//
// Provider graph:
//   searchProvider (SearchNotifier)
//     → searchDaoProvider → AppDatabase
//     → filterProvider (FilterNotifier) — optional; passes active filters
//
// SearchNotifier state machine:
//   idle        → activate() → active-empty
//   active-empty → updateQuery(q) [debounce 300ms] → typing → results
//   results     → updateQuery('') → active-empty
//   any-active  → dismiss() → idle (home list re-engages month filter)
//
// Search scope is global — NO date predicate (TC-050 founder resolution).
// If a filter is also active, filter criteria are passed to SearchDao alongside
// the FTS query so the intersection is computed at the SQL layer.
//
// Test cases (see test/presentation/notifiers/search_notifier_test.dart):
//   T-159.1. initial state: isActive=false, query='', results=[]
//   T-159.2. activate() sets isActive=true
//   T-159.3. updateQuery blank resets results without calling DAO
//   T-159.4. updateQuery fires after 300 ms debounce
//   T-159.5. dismiss() sets isActive=false and clears results
//   T-159.6. global scope — no date constraint in DAO call

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/data/database/daos/search_dao.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/services/search_ranker.dart';
import 'package:variance/presentation/providers/database_providers.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

part 'search_providers.g.dart';

// ---------------------------------------------------------------------------
// SearchState value object
// ---------------------------------------------------------------------------

/// Immutable snapshot of the full-text search state.
///
/// Drives the search overlay UI: active flag, loading indicator, and
/// the scored/ranked result list.
class SearchState {
  /// Creates a [SearchState].
  ///
  /// Parameters:
  /// - [query]: The current search query string.
  /// - [results]: The ranked list of matching transactions.
  /// - [isActive]: Whether the search overlay is open.
  /// - [isLoading]: Whether a search is in progress.
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isActive = false,
    this.isLoading = false,
  });

  /// Current search query entered by the user.
  final String query;

  /// Ranked and scored search results.
  final List<Transaction> results;

  /// True when the search overlay is open (regardless of query content).
  final bool isActive;

  /// True while the debounce timer is running or the DAO is executing.
  final bool isLoading;

  /// Returns a copy with specified fields replaced.
  SearchState copyWith({
    String? query,
    List<Transaction>? results,
    bool? isActive,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ---------------------------------------------------------------------------
// SearchNotifier
// ---------------------------------------------------------------------------

/// Manages the [SearchState] for the full-text transaction search overlay.
///
/// Search is debounced by 300 ms. The query scope is global — no date
/// predicate is applied (TC-050). Active filter criteria from [filterProvider]
/// are forwarded to [SearchDao] when set.
///
/// State lifecycle:
///   idle → [activate] → active-empty
///   active-empty → [updateQuery] → results
///   any active state → [dismiss] → idle
@riverpod
class SearchNotifier extends _$SearchNotifier {
  Timer? _debounce;
  static const _kDebounceDuration = Duration(milliseconds: 300);
  static const _ranker = SearchRanker();

  @override
  SearchState build() {
    // Cancel pending debounce timer on dispose.
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Opens the search overlay and sets [isActive] to true.
  ///
  /// Calling [activate] when already active is a no-op.
  void activate() {
    if (state.isActive) return;
    state = state.copyWith(isActive: true);
  }

  /// Updates the search query and debounces the DAO call by 300 ms.
  ///
  /// Blank queries immediately clear results without waiting for the debounce
  /// timer. Implicitly calls [activate] if the overlay is not yet open.
  ///
  /// Parameters:
  /// - [query]: New query string from the user.
  void updateQuery(String query) {
    _debounce?.cancel();

    if (!state.isActive) {
      state = state.copyWith(isActive: true, query: query);
    } else {
      state = state.copyWith(query: query);
    }

    // Immediately clear on blank query — no debounce needed.
    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: const [],
        isLoading: false,
      );
      return;
    }

    // Show loading indicator while the debounce timer is running.
    state = state.copyWith(isLoading: true);

    _debounce = Timer(_kDebounceDuration, () => _executeSearch(query));
  }

  /// Dismisses the search overlay, clears query and results, and returns the
  /// home list to the month-scoped view.
  void dismiss() {
    _debounce?.cancel();
    state = const SearchState();
  }

  // ---------------------------------------------------------------------------
  // Backward-compat aliases (used by existing SearchBarOverlay)
  // ---------------------------------------------------------------------------

  /// Sets the search query — alias for [updateQuery].
  ///
  /// Provided for backward compatibility with widgets that call [setQuery].
  void setQuery(String query) => updateQuery(query);

  /// Clears the search query — alias for [dismiss].
  ///
  /// Provided for backward compatibility with widgets that call [clear].
  void clear() => dismiss();

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _executeSearch(String query) async {
    if (!ref.mounted) return;

    // Resolve the SearchDao (global scope — no date predicate per TC-050).
    final dao = await ref.read(searchDaoProvider.future);

    // Retrieve active filter criteria to narrow results.
    final filterState = ref.read(filterProvider);

    final candidates = await dao.searchCandidates(query);
    if (!ref.mounted) return;

    // Stage 2: Dart-side scoring and ranking.
    var ranked = _ranker.rank(candidates, query);

    // Apply active filter criteria intersection (T-159).
    if (filterState.hasActiveFilters) {
      ranked = _applyFilterIntersection(ranked, filterState);
    }

    state = state.copyWith(
      results: ranked.map((c) => c.transaction).toList(),
      isLoading: false,
    );
  }

  /// Filters [candidates] to only those satisfying [filter] criteria.
  ///
  /// This is the search ∩ filter intersection described in T-159 and T-164.
  List<SearchCandidate> _applyFilterIntersection(
    List<SearchCandidate> candidates,
    FilterState filter,
  ) {
    return candidates.where((c) {
      final tx = c.transaction;

      // Type filter.
      if (filter.types.isNotEmpty && !filter.types.contains(tx.type)) {
        return false;
      }

      // Account filter.
      if (filter.accountIds.isNotEmpty) {
        final inSource = tx.accountSourceId != null &&
            filter.accountIds.contains(tx.accountSourceId);
        final inDest = tx.accountDestinationId != null &&
            filter.accountIds.contains(tx.accountDestinationId);
        if (!inSource && !inDest) return false;
      }

      // Category filter.
      if (filter.categoryIds.isNotEmpty) {
        final inCategory =
            tx.categoryId != null && filter.categoryIds.contains(tx.categoryId);
        final inSubcat = tx.subcategoryId != null &&
            filter.categoryIds.contains(tx.subcategoryId);
        if (!inCategory && !inSubcat) return false;
      }

      // Date range filter.
      if (filter.dateRange != null) {
        final startEpoch =
            filter.dateRange!.start.millisecondsSinceEpoch ~/ 1000;
        final endEpoch = filter.dateRange!.end.millisecondsSinceEpoch ~/ 1000;
        if (tx.dateTime < startEpoch || tx.dateTime > endEpoch) return false;
      }

      // Amount range filter.
      if (filter.minAmountMinor != null &&
          tx.amountMinor < filter.minAmountMinor!) {
        return false;
      }
      if (filter.maxAmountMinor != null &&
          tx.amountMinor > filter.maxAmountMinor!) {
        return false;
      }

      return true;
    }).toList();
  }
}
