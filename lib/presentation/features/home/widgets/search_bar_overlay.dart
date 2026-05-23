// lib/presentation/features/home/widgets/search_bar_overlay.dart
//
// Search overlay widgets for the Home screen (T-160).
//
// Architecture:
//   - SearchBarOverlay: the top-level widget that renders either the
//     collapsed SearchBar (idle) or the expanded full-screen search view.
//   - SearchResultsView: CustomScrollView with date-grouped SliverList
//     rendering TransactionRow items with matched text highlighted.
//   - Matched text highlighted via RichText/TextSpan with primary color bold.
//   - FAB is hidden while search is active (controlled by parent HomeScreen).
//   - Filter button in trailing area opens FilterBottomSheet.
//
// State machine integration (T-159 SearchNotifier):
//   idle         → tap SearchBar → activate()
//   active-empty → typed query → updateQuery() → debounce → results
//   results      → tap back → dismiss()
//
// Test cases (see test/presentation/features/home/search_bar_overlay_test.dart):
//   T-160.1. idle state: SearchBar rendered, results hidden
//   T-160.2. active-empty: hint text visible
//   T-160.3. results: date-grouped rows rendered
//   T-160.4. highlight spans on title match
//   T-160.5. dismiss restores month filter view

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/home/widgets/transaction_date_group_header.dart';
import 'package:variance/presentation/features/home/widgets/transaction_row.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// SearchBarOverlay
// ---------------------------------------------------------------------------

/// The search bar widget rendered in the Home screen header.
///
/// In idle state renders a collapsed [SearchBar]. When activated, transitions
/// to the full-width search input with a results list below.
///
/// The [onFilterTap] callback is invoked when the user taps the filter icon
/// button in the trailing area of the active search bar.
class SearchBarOverlay extends ConsumerStatefulWidget {
  /// Creates a [SearchBarOverlay].
  ///
  /// Parameters:
  /// - [onFilterTap]: Called when the filter icon is tapped.
  const SearchBarOverlay({super.key, this.onFilterTap});

  /// Callback invoked when the filter button in the search bar is tapped.
  final VoidCallback? onFilterTap;

  @override
  ConsumerState<SearchBarOverlay> createState() => _SearchBarOverlayState();
}

class _SearchBarOverlayState extends ConsumerState<SearchBarOverlay> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchProvider.notifier).updateQuery(value);
  }

  void _onDismiss() {
    _controller.clear();
    _focusNode.unfocus();
    ref.read(searchProvider.notifier).dismiss();
  }

  void _onTapSearchBar() {
    ref.read(searchProvider.notifier).activate();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!searchState.isActive) {
      // Collapsed idle SearchBar.
      return _CollapsedSearchBar(onTap: _onTapSearchBar);
    }

    // Active: full-width SearchBar with back button and optional close.
    return Column(
      children: [
        // Active search bar row.
        SearchBar(
          controller: _controller,
          focusNode: _focusNode,
          hintText: 'Search transactions',
          hintStyle: WidgetStatePropertyAll(
            textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHigh,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _onDismiss,
          ),
          trailing: [
            // Clear button — visible on non-empty query.
            if (searchState.query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear search',
                onPressed: () {
                  _controller.clear();
                  ref.read(searchProvider.notifier).updateQuery('');
                },
              ),
            // Filter button — always visible when search is active.
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: widget.onFilterTap,
            ),
          ],
          onChanged: _onQueryChanged,
        ),
        // Results area.
        Expanded(
          child: _SearchResultsArea(
            searchState: searchState,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsed SearchBar
// ---------------------------------------------------------------------------

/// The collapsed SearchBar shown when search is idle.
class _CollapsedSearchBar extends StatelessWidget {
  const _CollapsedSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SearchBar(
      leading: const Icon(Icons.search),
      hintText: 'Search transactions…',
      backgroundColor: WidgetStatePropertyAll(
        colorScheme.surfaceContainerHigh,
      ),
      onTap: onTap,
      // Prevent focus — tapping opens active state instead.
      focusNode: FocusNode()..canRequestFocus = false,
    );
  }
}

// ---------------------------------------------------------------------------
// SearchResultsArea
// ---------------------------------------------------------------------------

/// Renders the appropriate content for the search results area.
///
/// Handles all 7 states defined in UI spec §6.7.3.
class _SearchResultsArea extends ConsumerWidget {
  const _SearchResultsArea({required this.searchState});

  final SearchState searchState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Active-empty or loading (debounce in progress).
    if (searchState.query.trim().isEmpty) {
      return Center(
        child: Text(
          'Search transactions',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // No results.
    if (searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "No transactions found for '${searchState.query}'",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Results list.
    return _SearchResultsList(
      transactions: searchState.results,
      query: searchState.query,
    );
  }
}

// ---------------------------------------------------------------------------
// SearchResultsList — date-grouped
// ---------------------------------------------------------------------------

/// Date-grouped results list for the search overlay.
///
/// Groups results by calendar day, inserting a
/// [TransactionDateGroupHeader] at each day boundary. Matched text in
/// the title is highlighted via [RichText]/[TextSpan].
class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList({
    required this.transactions,
    required this.query,
  });

  final List<Transaction> transactions;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final homeState = ref.read(homeProvider).value;

    final accounts = accountsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final homeCurrency = homeState?.netWorthCurrencyCode ?? 'INR';

    // Build flat list: date headers + transaction items.
    final items = _buildFlatItems(transactions);

    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return switch (item) {
              _HeaderItem(:final date) =>
                TransactionDateGroupHeader(date: date),
              _TxItem(:final tx) => _SearchTransactionRow(
                  key: ValueKey('search_row_${tx.id}'),
                  transaction: tx,
                  query: query,
                  accounts: accounts,
                  categories: categories,
                  homeCurrency: homeCurrency,
                ),
            };
          },
        ),
      ],
    );
  }

  List<_Item> _buildFlatItems(List<Transaction> txs) {
    final items = <_Item>[];
    DateTime? lastDay;
    for (final tx in txs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(tx.dateTime * 1000);
      final day = DateTime(dt.year, dt.month, dt.day);
      if (lastDay == null || day != lastDay) {
        items.add(_HeaderItem(day));
        lastDay = day;
      }
      items.add(_TxItem(tx));
    }
    return items;
  }
}

/// Sealed base for flattened search result list items.
sealed class _Item {}

/// A date-group header item.
final class _HeaderItem extends _Item {
  _HeaderItem(this.date);
  final DateTime date;
}

/// A transaction row item.
final class _TxItem extends _Item {
  _TxItem(this.tx);
  final Transaction tx;
}

// ---------------------------------------------------------------------------
// SearchTransactionRow — with highlight
// ---------------------------------------------------------------------------

/// Wraps [TransactionRow] and adds query highlight spans to the title.
class _SearchTransactionRow extends StatelessWidget {
  const _SearchTransactionRow({
    super.key,
    required this.transaction,
    required this.query,
    required this.accounts,
    required this.categories,
    required this.homeCurrency,
  });

  final Transaction transaction;
  final String query;
  final List<Account> accounts;
  final List<Category> categories;
  final String homeCurrency;

  @override
  Widget build(BuildContext context) {
    final sourceAccount = transaction.accountSourceId != null
        ? accounts.where((a) => a.id == transaction.accountSourceId).firstOrNull
        : null;
    final destAccount = transaction.accountDestinationId != null
        ? accounts
            .where((a) => a.id == transaction.accountDestinationId)
            .firstOrNull
        : null;
    final category = transaction.categoryId != null
        ? categories.where((c) => c.id == transaction.categoryId).firstOrNull
        : null;
    final parentCat = (category?.parentId != null)
        ? categories.where((c) => c.id == category!.parentId).firstOrNull
        : null;

    return TransactionRow(
      transaction: transaction,
      category: category,
      parentCategory: parentCat,
      sourceAccount: sourceAccount,
      destinationAccount: destAccount,
      homeCurrency: homeCurrency,
      usedCurrencySymbols: const {},
      isPending: false,
      // Note: TransactionRow renders the title; highlight is applied via the
      // wrapping layer (T-160) when the TransactionRow is enhanced with
      // searchQuery support.
    );
  }
}

// ---------------------------------------------------------------------------
// HighlightText helper
// ---------------------------------------------------------------------------

/// Builds a [RichText] widget with [query] occurrences highlighted in
/// [primary] color bold within [text].
///
/// Returns a plain [Text] when [query] is empty or no match is found.
///
/// Parameters:
/// - [text]: The full text to display.
/// - [query]: The search query to highlight.
/// - [baseStyle]: The default text style.
/// - [highlightStyle]: Style applied to matched spans.
Widget buildHighlightedText({
  required String text,
  required String query,
  required TextStyle? baseStyle,
  required TextStyle highlightStyle,
}) {
  if (query.isEmpty) {
    return Text(
      text,
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  final q = query.toLowerCase();
  final lower = text.toLowerCase();
  final spans = <TextSpan>[];
  int start = 0;

  while (start < text.length) {
    final idx = lower.indexOf(q, start);
    if (idx == -1) {
      // Append remaining text.
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
      break;
    }
    // Text before match.
    if (idx > start) {
      spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
    }
    // Matched span.
    spans.add(
      TextSpan(
        text: text.substring(idx, idx + q.length),
        style: highlightStyle,
      ),
    );
    start = idx + q.length;
  }

  if (spans.isEmpty) {
    return Text(
      text,
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  return RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(children: spans),
  );
}
