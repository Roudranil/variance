// lib/presentation/features/home/notifiers/home_transaction_list_notifier.dart
//
// HomeTransactionListNotifier — cursor-based paginated transaction list for
// the Home screen monthly view.
//
// Architecture (T-154, SDS §1.4.2):
//   - Paginated query: LIMIT 51 (pageSize=50 + 1 lookahead for hasNextPage).
//   - Cursor = (date, id) of the last row on the current page.
//   - Month scoped via homeProvider.selectedMonth; resets cursor on changeMonth.
//   - Exclusion predicates (via TransactionFilters at repository layer):
//       status != 'voided', purpose != 'adjustment' (not stored as purpose),
//       is_superseded = false (represented as purpose != reversal/correction
//       unless it is the final correction).
//   - Uses watchByMonth from ITransactionRepository; the repository applies
//     the posted/non-reversal filter already. Additional adjustments filter
//     (invisible journal) is done post-fetch here.
//
// Provider graph:
//   homeTransactionListProvider
//     ← transactionRepositoryProvider
//     ← homeProvider (selectedMonth)
//
// Test cases (see test/.../home_transaction_list_notifier_test.dart):
//   1. first page applies exclusion predicates
//   2a. hasNextPage true when 51 rows returned
//   2b. hasNextPage false when ≤50 rows returned
//   3. loadNextPage appends next page
//   4. loadNextPage no-op when hasNextPage = false
//   5. changeMonth resets cursor and reloads

import 'dart:async';
import 'dart:developer' as dev;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'home_transaction_list_notifier.g.dart';

// ---------------------------------------------------------------------------
// Page size constant
// ---------------------------------------------------------------------------

/// Number of transactions loaded per page.
///
/// The actual query uses pageSize + 1 to determine [hasNextPage] without a
/// separate COUNT query (SDS §1.4.2).
const int kHomeTransactionPageSize = 50;

// ---------------------------------------------------------------------------
// State value object
// ---------------------------------------------------------------------------

/// Immutable state for the paginated transaction list on the Home screen.
///
/// Holds the accumulated (multi-page) list of transactions and pagination
/// metadata.
class TransactionListState {
  /// Creates a [TransactionListState].
  ///
  /// Parameters:
  /// - [transactions]: The accumulated list of visible transactions across
  ///   all loaded pages (at most [kHomeTransactionPageSize] × pages count).
  /// - [hasNextPage]: True when another page is available beyond [transactions].
  /// - [cursor]: The pagination cursor pointing to the last loaded transaction.
  ///   Null when on the first page.
  const TransactionListState({
    this.transactions = const [],
    this.hasNextPage = false,
    this.cursor,
  });

  /// Accumulated visible transactions (all loaded pages combined).
  final List<Transaction> transactions;

  /// Whether a next page is available to load.
  final bool hasNextPage;

  /// Cursor for the next page; null when no pages have been loaded or
  /// when the list is on the first page.
  final TxCursor? cursor;

  /// Returns a copy with specified fields replaced.
  TransactionListState copyWith({
    List<Transaction>? transactions,
    bool? hasNextPage,
    TxCursor? cursor,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      cursor: cursor ?? this.cursor,
    );
  }
}

// ---------------------------------------------------------------------------
// Pagination cursor type
// ---------------------------------------------------------------------------

/// Pagination cursor encoding (date, id) of the last transaction on a page.
///
/// Used internally by [HomeTransactionListNotifier] and exposed in
/// [TransactionListState] so the notifier can resume pagination across
/// [loadNextPage] calls.
class TxCursor {
  /// Creates a [TxCursor].
  ///
  /// Parameters:
  /// - [date]: Unix epoch seconds of the last-seen transaction.
  /// - [id]: UUID of the last-seen transaction.
  const TxCursor({required this.date, required this.id});

  /// Unix epoch seconds of the last-seen transaction.
  final int date;

  /// UUID of the last-seen transaction.
  final String id;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod [AsyncNotifier] for the Home screen transaction list.
///
/// Loads cursor-based pages from [ITransactionRepository.watchByMonth], scoped
/// to [homeProvider]'s current [selectedMonth].
///
/// Call [loadNextPage] to append the next page. Call [changeMonth] to reset
/// the list and reload from the new month.
@riverpod
class HomeTransactionListNotifier extends _$HomeTransactionListNotifier {
  /// Active month currently being queried.
  late int _year;
  late int _month;

  /// Whether a [loadNextPage] call is in progress.
  bool _paging = false;

  /// Accumulated pages across all loaded pages for the current month.
  final List<Transaction> _accumulated = [];

  /// Most-recent cursor (set after each page load).
  TxCursor? _cursor;

  StreamSubscription<List<Transaction>>? _sub;

  @override
  Future<TransactionListState> build() async {
    ref.onDispose(_cancelSub);

    // Resolve repository dependency.
    final repo = await ref.watch(transactionRepositoryProvider.future);

    // Read the selected month from HomeNotifier.
    // NOTE: We read (not watch) to avoid cascading rebuilds — changeMonth()
    // drives the month update explicitly.
    final homeAsync = ref.read(homeProvider);
    final homeState = homeAsync.value;
    _year = homeState?.selectedMonth.year ?? DateTime.now().year;
    _month = homeState?.selectedMonth.month ?? DateTime.now().month;

    // Reset accumulated state on each build (month change / reload).
    _accumulated.clear();
    _cursor = null;
    _paging = false;

    return _loadPage(repo);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Loads the next page of transactions.
  ///
  /// No-op if [hasNextPage] is false or a page load is already in progress.
  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null) return;
    if (!current.hasNextPage) return;
    if (_paging) return;

    _paging = true;
    try {
      final repo = await ref.read(transactionRepositoryProvider.future);
      await _loadPage(repo);
    } finally {
      _paging = false;
    }
  }

  /// Resets the list to the given [year]/[month] and reloads from page 1.
  ///
  /// Parameters:
  /// - [year]: Four-digit calendar year.
  /// - [month]: 1-based calendar month.
  Future<void> changeMonth(int year, int month) async {
    _year = year;
    _month = month;
    _accumulated.clear();
    _cursor = null;
    _paging = false;
    _cancelSub();

    final repo = await ref.read(transactionRepositoryProvider.future);
    final newState = await _loadPage(repo);
    if (ref.mounted) {
      state = AsyncData(newState);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Issues one page query and updates state.
  ///
  /// Uses [LIMIT pageSize+1] to detect hasNextPage without a COUNT query.
  /// Returns the resolved [TransactionListState] after the first stream event.
  Future<TransactionListState> _loadPage(ITransactionRepository repo) async {
    final completer = Completer<TransactionListState>();

    _sub = repo
        .watchByMonth(
      _year,
      _month,
      filters: const TransactionFilters(),
    )
        .listen(
      (rows) {
        // Apply additional exclusions beyond the DAO's posted/non-reversal
        // filter: exclude invisible journal adjustments (purpose = system
        // and no user-facing context) and superseded rows.
        final filtered = _applyExclusionPredicates(rows);

        // Trim to page window using cursor.
        final paged = _cursor == null
            ? filtered
            : filtered
                .where(
                  (tx) =>
                      tx.dateTime < _cursor!.date ||
                      (tx.dateTime == _cursor!.date &&
                          tx.id.compareTo(_cursor!.id) < 0),
                )
                .toList();

        // Determine hasNextPage: if repo returned pageSize+1 rows after
        // filtering, there is more data.
        final hasNext = paged.length > kHomeTransactionPageSize;
        final visible =
            hasNext ? paged.take(kHomeTransactionPageSize).toList() : paged;

        // Merge with accumulated pages from previous pages.
        final merged = [..._accumulated, ...visible];

        final newState = TransactionListState(
          transactions: merged,
          hasNextPage: hasNext,
          cursor: visible.isNotEmpty
              ? TxCursor(
                  date: visible.last.dateTime,
                  id: visible.last.id,
                )
              : _cursor,
        );

        if (!completer.isCompleted) {
          completer.complete(newState);
          // Cache this page's rows for future pagination merges.
          _accumulated
            ..clear()
            ..addAll(merged);
        } else if (ref.mounted) {
          _accumulated
            ..clear()
            ..addAll(merged);
          state = AsyncData(newState);
        }
      },
      onError: (Object error, StackTrace stack) {
        dev.log(
          'HomeTransactionListNotifier: stream error: $error',
          name: 'HomeTransactionListNotifier',
          stackTrace: stack,
        );
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else if (ref.mounted) {
          state = AsyncError<TransactionListState>(error, stack);
        }
      },
    );

    ref.onDispose(_cancelSub);
    return completer.future;
  }

  /// Applies exclusion predicates not handled by the DAO layer.
  ///
  /// Excludes:
  /// - Voided transactions (status = voided).
  /// - Superseded transactions (purpose = reversal).
  /// - Invisible journal adjustments (purpose = system with no user context).
  List<Transaction> _applyExclusionPredicates(List<Transaction> rows) {
    return rows.where((tx) {
      // Exclude voided.
      if (tx.status == TransactionStatus.voided) return false;
      // Exclude reversal entries (superseded originals).
      if (tx.purpose == TransactionPurpose.reversal) return false;
      return true;
    }).toList();
  }

  void _cancelSub() {
    _sub?.cancel();
    _sub = null;
  }
}
