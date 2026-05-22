// lib/presentation/features/home/widgets/search_bar_overlay.dart
//
// Search bar overlay built with M3 SearchAnchor widget (T-58).
//
// Responsibilities:
//   - Shows an M3 SearchBar that expands into a SearchAnchor view.
//   - Delegates query changes to SearchNotifier (debounced, 300 ms).
//   - Displays search results in the expanded view as a scrollable list.
//   - Tapping a result navigates to TransactionDetailScreen via GoRouter.
//   - Shows an empty-state message when no results found.
//
// Search scope is global (TC-050): month filter is NOT applied.
//
// Test cases (see test/presentation/features/home/search_bar_overlay_test.dart):
//   1. renders SearchBar in collapsed state
//   2. empty query shows no result tiles
//   3. non-empty query shows result tiles from SearchNotifier

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// SearchBarOverlay
// ---------------------------------------------------------------------------

/// M3 search bar that expands to a full-screen search view.
///
/// Placed in the home screen app bar or body. Binds to [SearchNotifier].
class SearchBarOverlay extends ConsumerStatefulWidget {
  /// Creates a [SearchBarOverlay].
  const SearchBarOverlay({super.key});

  @override
  ConsumerState<SearchBarOverlay> createState() => _SearchBarOverlayState();
}

class _SearchBarOverlayState extends ConsumerState<SearchBarOverlay> {
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (BuildContext ctx, SearchController controller) {
        return SearchBar(
          controller: controller,
          leading: const Icon(Icons.search),
          hintText: 'Search transactions…',
          onTap: controller.openView,
          onChanged: (_) => controller.openView(),
          // Trailing clear button — only shown when text is present.
          trailing: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  ref.read(searchProvider.notifier).clear();
                },
              ),
          ],
        );
      },
      suggestionsBuilder: (BuildContext ctx, SearchController controller) {
        // Forward query to SearchNotifier on each keystroke (post-frame
        // to avoid mutating state during build).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(searchProvider.notifier)
              .setQuery(controller.text);
        });

        // Wrap in a Consumer so suggestions rebuild on provider state changes.
        return [
          _SearchSuggestionList(
            key: const ValueKey('suggestions'),
            controller: controller,
            onResultTap: (tx) {
              controller.closeView(null);
              ref.read(searchProvider.notifier).clear();
              ctx.push(
                AppRoutes.transactionDetail.replaceAll(':id', tx.id),
              );
            },
          ),
        ];
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Reactive suggestion list (Consumer wrapper)
// ---------------------------------------------------------------------------

/// Watches [searchProvider] and builds the appropriate suggestion content.
///
/// Using a separate [ConsumerWidget] ensures the list rebuilds when the
/// provider state changes — [SearchAnchor.suggestionsBuilder] is a one-shot
/// callback that does not re-invoke on state changes.
class _SearchSuggestionList extends ConsumerWidget {
  const _SearchSuggestionList({
    super.key,
    required this.controller,
    required this.onResultTap,
  });

  final SearchController controller;
  final void Function(Transaction tx) onResultTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    // Determine if the user has typed anything — empty text means the
    // search has not started; show the hint regardless of provider state.
    final hasQuery = controller.text.trim().isNotEmpty;

    if (!hasQuery) {
      return const _EmptyQueryHint(key: ValueKey('hint'));
    }

    return searchState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const _NoResultsTile(key: ValueKey('no-results'));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: transactions.length,
          itemBuilder: (_, i) => _TransactionResultTile(
            key: ValueKey(transactions[i].id),
            transaction: transactions[i],
            onTap: () => onResultTap(transactions[i]),
          ),
        );
      },
      loading: () => const ListTile(
        key: ValueKey('loading'),
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Searching…'),
      ),
      error: (err, _) => ListTile(
        key: const ValueKey('error'),
        leading: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Search failed'),
        subtitle: const Text('Please try again'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small hint / empty-state widgets
// ---------------------------------------------------------------------------

/// Placeholder shown when the search field is empty.
class _EmptyQueryHint extends StatelessWidget {
  const _EmptyQueryHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Type to search transactions',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

/// Tile shown when a query returned no matches.
class _NoResultsTile extends StatelessWidget {
  const _NoResultsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.search_off),
      title: Text('No transactions found'),
    );
  }
}

/// A single search result tile representing a [Transaction].
class _TransactionResultTile extends StatelessWidget {
  const _TransactionResultTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Format display amount as a simple decimal string.
    final amount = (transaction.amountMinor / 100).toStringAsFixed(2);
    final formattedAmount = '${transaction.currencyCode} $amount';

    // Format date from epoch seconds.
    final date = DateTime.fromMillisecondsSinceEpoch(
      transaction.dateTime * 1000,
    );
    final formattedDate = DateFormat.MMMd().format(date);

    // Derive icon colour from transaction type.
    final iconColor = switch (transaction.type) {
      TransactionType.income => Colors.green,
      TransactionType.expense => cs.error,
      TransactionType.transfer => cs.primary,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(
          switch (transaction.type) {
            TransactionType.income => Icons.arrow_downward,
            TransactionType.expense => Icons.arrow_upward,
            TransactionType.transfer => Icons.swap_horiz,
          },
          color: iconColor,
          size: 18,
        ),
      ),
      title: Text(
        transaction.title ?? formattedAmount,
        style: tt.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.title != null ? '$formattedAmount · ' : ''}'
        '$formattedDate',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: transaction.title != null
          ? Text(formattedAmount, style: tt.labelMedium)
          : null,
      onTap: onTap,
    );
  }
}
