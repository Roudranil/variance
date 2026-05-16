// lib/presentation/features/accounts/account_detail_screen.dart
//
// AccountDetailScreen — displays a single account's metadata, balance,
// and per-account transaction list stub.
//
// Layout (ACC-04, PRD §5.1.4a, UI Spec §5):
//   - AppBar: account name, Edit action, overflow (Delete, Reconcile)
//   - Header card: name, category badge, currency, balance
//   - Metadata section: account details (encrypted fields masked)
//   - Net worth inclusion indicator
//   - Per-account transaction list (stubbed — TXN epic)
//   - Credit card variant: outstanding + statement balance chips, Pay FAB
//
// Test cases (see test/presentation/features/accounts/account_detail_screen_test.dart):
//   1. credit_card account shows Pay FAB
//   2. non-credit-card account does not show Pay FAB
//   3. empty transaction list shows empty state
//   4. deleted account shows read-only banner, no edit/delete actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/account_providers.dart';

/// Detail screen for a single financial account.
///
/// Pass [accountId] from the route parameter. Reads from [accountsProvider]
/// and [accountBalanceProvider] reactively.
class AccountDetailScreen extends ConsumerWidget {
  /// Creates an [AccountDetailScreen].
  const AccountDetailScreen({super.key, required this.accountId});

  /// UUID of the account to display.
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(
      accountByIdProvider(accountId),
    );

    return accountAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error loading account: $e')),
      ),
      data: (account) {
        if (account == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account')),
            body: const Center(child: Text('Account not found.')),
          );
        }
        return _AccountDetailView(account: account);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _AccountDetailView extends ConsumerWidget {
  const _AccountDetailView({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(
      accountBalanceProvider(account.id, account.currencyCode),
    );
    final isDeleted = account.isDeleted;
    final isCreditCard = account.accountCategory == AccountCategory.creditCard;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          if (!isDeleted) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit account',
              onPressed: () => context.push(
                AppRoutes.accountEdit(account.id),
                extra: account,
              ),
            ),
            PopupMenuButton<_AccountAction>(
              onSelected: (action) => _handleAction(context, ref, action),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _AccountAction.reconcile,
                  child: Text('Reconcile'),
                ),
                const PopupMenuItem(
                  value: _AccountAction.delete,
                  child: Text('Delete account'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Deleted banner
          if (isDeleted)
            const SliverToBoxAdapter(
              child: _DeletedBanner(),
            ),

          // Balance header
          SliverToBoxAdapter(
            child: _BalanceHeader(
              account: account,
              balanceAsync: balanceAsync,
            ),
          ),

          // Net worth indicator
          SliverToBoxAdapter(
            child: _NetWorthIndicator(
              includeInNetWorth: account.includeInNetWorth,
            ),
          ),

          // Transaction list stub
          const SliverToBoxAdapter(
            child: _TransactionListStub(),
          ),
        ],
      ),
      // Pay FAB — credit cards only, always visible
      floatingActionButton:
          isCreditCard && !isDeleted ? _PayFab(account: account) : null,
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    _AccountAction action,
  ) {
    switch (action) {
      case _AccountAction.reconcile:
        context.push(AppRoutes.accountReconcile(account.id));
      case _AccountAction.delete:
        _confirmDelete(context, ref);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This will soft-delete the account. This cannot '
            'be undone easily.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO(T-42+): call DeleteAccountUseCase
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

enum _AccountAction { reconcile, delete }

/// Banner shown when the account has been soft-deleted.
class _DeletedBanner extends StatelessWidget {
  const _DeletedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This account has been deleted.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header card showing account name, category badge, currency, and balance.
class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.account,
    required this.balanceAsync,
  });

  final Account account;
  final AsyncValue<int> balanceAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = balanceAsync.value ?? 0;
    final isNegative = balance < 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Chip(
              label: Text(
                _categoryLabel(account.accountCategory),
                style: theme.textTheme.labelSmall,
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 8),
            // Balance
            Semantics(
              label:
                  '${isNegative ? "Negative " : ""}balance: ${account.currencyCode} $balance',
              child: Text(
                '${account.currencyCode} $balance',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isNegative
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(AccountCategory cat) => switch (cat) {
        AccountCategory.cash => 'Cash',
        AccountCategory.bankAccount => 'Bank Account',
        AccountCategory.creditCard => 'Credit Card',
        AccountCategory.debitCard => 'Debit Card',
        AccountCategory.topUpWallet => 'Top-Up Wallet',
        AccountCategory.loan => 'Loan',
        AccountCategory.investment => 'Investment',
        AccountCategory.equity => 'Equity',
        AccountCategory.other => 'Other',
      };
}

/// Indicator showing whether the account is included in net worth.
class _NetWorthIndicator extends StatelessWidget {
  const _NetWorthIndicator({required this.includeInNetWorth});

  final bool includeInNetWorth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            includeInNetWorth
                ? Icons.check_circle_outline
                : Icons.remove_circle_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            includeInNetWorth
                ? 'Included in net worth'
                : 'Excluded from net worth',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stub transaction list — replaced when TXN epic is complete.
class _TransactionListStub extends StatelessWidget {
  const _TransactionListStub();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// FAB that opens the credit card payment transfer form.
class _PayFab extends StatelessWidget {
  const _PayFab({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push(
        AppRoutes.transactionNew,
        extra: {'prefillDestinationId': account.id},
      ),
      icon: const Icon(Icons.payment),
      label: const Text('Pay'),
    );
  }
}
