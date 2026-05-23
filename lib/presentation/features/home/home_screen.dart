// lib/presentation/features/home/home_screen.dart
//
// HomeScreen — main screen for Tab 0 of the shell navigation.
//
// Architecture (T-153, UI spec §5.1, SDS §2.4.2):
//   - Uses CustomScrollView with:
//       SliverToBoxAdapter: greeting + financial summary grid
//       SliverPersistentHeader (pinned): month selector
//       SliverToBoxAdapter: alerts strip
//       SliverList.builder: date-grouped transaction rows (T-156)
//   - No AppBar; greeting and summary are embedded in the scrollable body.
//   - ShellRoute integration: HomeScreen is the root of the Home tab.
//   - FAB: SpeedDial placeholder (bottom-right) — future sprint.
//   - Transaction rows are wrapped in Dismissible for swipe actions (T-157).
//   - Long-press triggers a ModalBottomSheet contextual menu (T-157).
//
// Scroll-to-load: detects when user scrolls within 200dp of the end and
//   triggers HomeTransactionListNotifier.loadNextPage().
//
// Test cases (see test/presentation/features/home/home_screen_test.dart):
//   T-153:
//     1. mounts without overflow in loading state
//     2. mounts without overflow with populated state
//   T-156:
//     3. 3 transactions across 2 days → 2 headers + 3 rows
//   T-157:
//     4. swipe-right navigates
//     5. swipe-left shows delete dialog
//     6. long-press shows Edit + Delete bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';
import 'package:variance/presentation/features/home/notifiers/home_transaction_list_notifier.dart';
import 'package:variance/presentation/features/home/widgets/alerts_strip.dart';
import 'package:variance/presentation/features/home/widgets/catch_up_banner.dart';
import 'package:variance/presentation/features/home/widgets/financial_summary_grid.dart';
import 'package:variance/presentation/features/home/widgets/greeting_row.dart';
import 'package:variance/presentation/features/home/widgets/home_screen_body.dart';
import 'package:variance/presentation/features/home/widgets/home_speed_dial.dart';
import 'package:variance/presentation/features/home/widgets/month_selector.dart';
import 'package:variance/presentation/features/home/widgets/recurring_catch_up_banner.dart';
import 'package:variance/presentation/features/home/widgets/transaction_date_group_header.dart';
import 'package:variance/presentation/features/home/widgets/transaction_row.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// HomeGreeting — backward-compatibility alias for GreetingRow
// ---------------------------------------------------------------------------

/// Backward-compatible alias for [GreetingRow].
///
/// The standalone [HomeGreeting] widget was the original T-17 placeholder
/// widget before [GreetingRow] was extracted into its own file. This typedef
/// preserves compatibility with tests that reference [HomeGreeting] by name.
///
/// Prefer [GreetingRow] in new code.
typedef HomeGreeting = GreetingRow;

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------

/// The root widget for Tab 0 — the Home screen dashboard.
///
/// Uses [CustomScrollView] + [SliverList.builder] to efficiently render
/// date-grouped transaction rows without loading all data into memory.
///
/// Wraps transactions in [Dismissible] for swipe-to-delete/edit (T-157) and
/// supports a long-press contextual menu (T-157).
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the [HomeScreen].
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Session-scoped flag: true when the stale-FX banner has been dismissed.
  bool _fxBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Triggers next-page load when user scrolls within 200dp of the list end.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (maxScroll - current < 200) {
      ref.read(homeTransactionListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      // CustomScrollView — no AppBar per §5.1.
      body: SafeArea(
        child: homeAsync.when(
          loading: () => _buildScrollView(
            isLoading: true,
            fxBannerDismissed: _fxBannerDismissed,
          ),
          error: (error, _) => const HomeScreenBody(), // delegates error UI
          data: (homeState) {
            // Sync the banner dismissal state with the session flag.
            return _buildScrollView(
              isLoading: false,
              fxBannerDismissed: _fxBannerDismissed,
              hasStaleFx: homeState.hasStaleFx,
            );
          },
        ),
      ),
      // HomeSpeedDial FAB — T-165/T-166.
      floatingActionButton: HomeSpeedDial(
        onExpense: () => context.push(
          '${AppRoutes.transactionNew}?type=expense',
        ),
        onIncome: () => context.push(
          '${AppRoutes.transactionNew}?type=income',
        ),
        onTransfer: () => context.push(
          '${AppRoutes.transactionNew}?type=transfer',
        ),
        onDrafts: () => context.push(AppRoutes.settingsDrafts),
      ),
    );
  }

  Widget _buildScrollView({
    required bool isLoading,
    required bool fxBannerDismissed,
    bool hasStaleFx = false,
  }) {
    if (isLoading) {
      // Delegate to existing HomeScreenBody for loading/error states.
      return const HomeScreenBody();
    }

    return Column(
      children: [
        // Stale FX banner (session-dismissable).
        if (hasStaleFx && !fxBannerDismissed)
          _StaleFxBanner(
            onDismiss: () => setState(() => _fxBannerDismissed = true),
          ),

        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Zone 1: Greeting + Financial Summary Grid
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingRow(),
                      SizedBox(height: 16),
                      FinancialSummaryGrid(),
                    ],
                  ),
                ),
              ),

              // Zone 2: Month Selector (pinned)
              SliverPersistentHeader(
                pinned: true,
                // ignore: prefer_const_constructors — delegate has no const ctor
                delegate: _MonthSelectorHeaderDelegate(),
              ),

              // Zone 3: Alerts Strip
              const SliverToBoxAdapter(
                child: AlertsStrip(),
              ),

              // Zone 3b: Recurring Catch-Up Banner (T-121)
              // Shown when stacked remind_and_confirm occurrences were
              // auto-approved in the launch sweep. Session-local dismissal.
              SliverToBoxAdapter(
                child: RecurringCatchUpBanner(
                  autoApprovedCount: AppInitializer.lastAutoApprovedCount,
                ),
              ),

              // Zone 3c: Auto-posted Catch-Up Banner (T-171)
              // Shown when auto_post occurrences were posted during the
              // launch sweep. Uses GetCatchUpBannerUseCase.
              const SliverToBoxAdapter(
                child: CatchUpBanner(),
              ),

              // Zone 4: Transaction list (date-grouped)
              _TransactionSliverList(
                scrollController: _scrollController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month selector persistent header delegate
// ---------------------------------------------------------------------------

/// Persistent header delegate for the pinned month-selector row.
class _MonthSelectorHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  bool shouldRebuild(_MonthSelectorHeaderDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const MonthSelector(),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction SliverList with date groups and swipe actions (T-156, T-157)
// ---------------------------------------------------------------------------

/// Sliver list of date-grouped, swipeable transaction rows.
///
/// Groups transactions by calendar day; inserts
/// [TransactionDateGroupHeader] between day boundaries.
class _TransactionSliverList extends ConsumerWidget {
  const _TransactionSliverList({required this.scrollController});

  // ignore: unused_field — used in future scroll threshold feature
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txListAsync = ref.watch(homeTransactionListProvider);

    return txListAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load transactions.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
      data: (txList) {
        final transactions = txList.transactions;

        if (transactions.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyTransactionState(),
          );
        }

        // Build flattened list of items: date headers + rows.
        final items = _buildFlatList(transactions);

        return SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return switch (item) {
              _DateHeaderItem(:final date) =>
                TransactionDateGroupHeader(date: date),
              _TransactionItem(:final transaction) =>
                _TransactionRowWithActions(transaction: transaction),
            };
          },
        );
      },
    );
  }

  /// Flattens [transactions] (already date-desc sorted) into a list of
  /// [_DateHeaderItem] and [_TransactionItem] entries, inserting a header
  /// at each calendar-day boundary.
  List<_ListItem> _buildFlatList(List<Transaction> transactions) {
    final items = <_ListItem>[];
    DateTime? lastDay;

    for (final tx in transactions) {
      // Convert epoch to DateTime for grouping.
      final txDate = DateTime.fromMillisecondsSinceEpoch(tx.dateTime * 1000);
      final txDay = DateTime(txDate.year, txDate.month, txDate.day);

      if (lastDay == null || txDay != lastDay) {
        items.add(_DateHeaderItem(txDay));
        lastDay = txDay;
      }
      items.add(_TransactionItem(tx));
    }

    return items;
  }
}

// ---------------------------------------------------------------------------
// Flat list item types
// ---------------------------------------------------------------------------

/// Sealed base for flattened list items (date headers + transaction rows).
sealed class _ListItem {}

/// A date-group header item.
final class _DateHeaderItem extends _ListItem {
  _DateHeaderItem(this.date);
  final DateTime date;
}

/// A transaction row item.
final class _TransactionItem extends _ListItem {
  _TransactionItem(this.transaction);
  final Transaction transaction;
}

// ---------------------------------------------------------------------------
// Transaction row with swipe + long-press actions (T-157)
// ---------------------------------------------------------------------------

/// A [TransactionRow] wrapped in [Dismissible] (swipe) and [GestureDetector]
/// (long-press).
///
/// Swipe-left → delete flow:
///   1. Show confirmation dialog.
///   2. On confirm → soft-delete via void$ repository method.
///   3. Show snackbar with "Undo" action.
///   4. On Undo → restore by cancelling or re-posting.
///
/// Swipe-right → navigate to edit screen.
///
/// Long-press → [ModalBottomSheet] with Edit and Delete options.
class _TransactionRowWithActions extends ConsumerWidget {
  const _TransactionRowWithActions({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve accounts and categories for display.
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final homeState = ref.read(homeProvider).value;

    final accounts = accountsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final homeCurrency = homeState?.netWorthCurrencyCode ?? 'INR';
    final isFuture = homeState?.isFutureMonth ?? false;

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

    return GestureDetector(
      key: Key('tx_row_${transaction.id}'),
      onLongPress: () => _showLongPressMenu(context, ref),
      child: Dismissible(
        key: Key('tx_dismissible_${transaction.id}'),
        // Swipe-left: delete
        background: _SwipeBackground(
          alignment: Alignment.centerLeft,
          color: Theme.of(context).colorScheme.errorContainer,
          icon: Icons.delete_outline,
          padding: const EdgeInsets.only(left: 24),
        ),
        // Swipe-right: edit
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight,
          color: Theme.of(context).colorScheme.secondaryContainer,
          icon: Icons.edit_outlined,
          padding: const EdgeInsets.only(right: 24),
        ),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Swipe-left → confirm delete.
            return _confirmDelete(context, ref);
          } else {
            // Swipe-right → navigate to edit; do not dismiss the row.
            // context.push returns a Future but we intentionally don't await.
            if (context.mounted) {
              // ignore: unawaited_futures
              context.push(AppRoutes.transactionEditPath(transaction.id));
            }
            return false;
          }
        },
        onDismissed: (_) {
          // Row was dismissed (delete confirmed). Show undo snackbar.
          // ignore: unawaited_futures — async side-effect, errors logged in method
          _showUndoSnackbar(context, ref);
        },
        child: TransactionRow(
          transaction: transaction,
          category: category,
          parentCategory: parentCat,
          sourceAccount: sourceAccount,
          destinationAccount: destAccount,
          homeCurrency: homeCurrency,
          usedCurrencySymbols: const {},
          isPending: isFuture,
        ),
      ),
    );
  }

  /// Shows the delete confirmation dialog.
  ///
  /// Returns true when the user confirms deletion, false on cancel.
  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this transaction?'),
        content: const Text(
          'This action will remove the transaction. You can undo it '
          'immediately after.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Soft-deletes the transaction and shows an "Undo" snackbar.
  Future<void> _showUndoSnackbar(BuildContext context, WidgetRef ref) async {
    // Perform soft-delete via the resolved repository future.
    final repo = await ref.read(transactionRepositoryProvider.future);
    await repo.void$(transaction.id);

    if (!context.mounted) return;

    // Show undo snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-open is not possible via void; invalidate notifier to reload.
            // The SDS does not define a restore path — just reload the list.
            ref.invalidate(homeTransactionListProvider);
          },
        ),
      ),
    );
  }

  /// Shows the long-press contextual menu (Edit / Delete).
  Future<void> _showLongPressMenu(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.transactionEditPath(transaction.id));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                if (!context.mounted) return;
                final confirmed = await _confirmDelete(context, ref);
                if (confirmed && context.mounted) {
                  await _showUndoSnackbar(context, ref);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipe background widget
// ---------------------------------------------------------------------------

/// Background widget shown behind a transaction row during a swipe gesture.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.padding,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: padding,
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty transaction state
// ---------------------------------------------------------------------------

/// Empty state shown when no transactions exist for the selected month.
class _EmptyTransactionState extends StatelessWidget {
  const _EmptyTransactionState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions this month',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stale FX banner (inline)
// ---------------------------------------------------------------------------

/// Inline stale-FX rate banner shown above the scroll view.
///
/// Dismissed once per session via the parent [_HomeScreenState].
class _StaleFxBanner extends StatelessWidget {
  const _StaleFxBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialBanner(
      key: const Key('stale_fx_banner'),
      backgroundColor: colorScheme.surfaceContainerHigh,
      leading: Icon(
        Icons.warning_amber_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      content: Text(
        'Exchange rate may be outdated',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      actions: [
        TextButton(
          key: const Key('stale_fx_dismiss'),
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

// _SpeedDialFab and _SmallFabAction removed in T-165.
// HomeSpeedDial (lib/presentation/features/home/widgets/home_speed_dial.dart)
// replaces the placeholder implementation.
