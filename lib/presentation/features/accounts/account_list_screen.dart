// lib/presentation/features/accounts/account_list_screen.dart
//
// AccountListScreen — Tab 1 of the main navigation shell.
//
// Layout (UX Flows §8.1, UI Spec §7.1):
//   - SmallTopAppBar with title "Accounts"
//   - Net worth FilledCard (sticky at top)
//   - SliverList of account rows grouped:
//       1. Contributing accounts (includeInNetWorth=true, isDeleted=false)
//       2. "Excluded from net worth" section header + excluded rows
//   - Empty state illustration + CTA when no accounts
//   - FAB → /accounts/new
//   - Row tap → /accounts/:id
//
// States (UI Spec §7.1.2):
//   loading  → shimmer skeleton rows
//   empty    → illustration + "No accounts yet" + FilledButton
//   nominal  → net worth card + grouped account rows
//   error    → inline error card with retry
//
// Balance display (PRD §5.1.4.1):
//   - Positive / zero balance: ColorScheme.onSurface
//   - Negative balance: VarianceColors.warningAmount
//   - Accessibility label includes "negative" for negative balances
//
// Currency symbol disambiguation (CURR-02, T-91):
//   - When two+ active accounts share a currency symbol, each account row
//     appends the ISO code: '$USD', '$CAD'. Single currency → bare symbol.
//
// Test cases (see test/presentation/features/accounts/account_list_screen_test.dart):
//   1. empty state — shows illustration + "No accounts yet" + FAB
//   2. populated state — net worth card visible
//   3. accounts grouped: contributing above excluded section header
//   4. excluded account row has reduced opacity
//   5. negative balance has accessibility label with "negative"
//   6. net worth card shows staleness chip when hasStaleRates=true
//   7. loading state shows shimmer/progress indicator
//   8. FAB taps navigate to /accounts/new
//   9. row tap navigates to /accounts/:id
//  10. two-currency scenario renders ISO-suffixed labels in account rows
//  11. single-currency scenario renders plain symbol in account rows

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/theme/variance_colors.dart';
import 'package:variance/presentation/theme/variance_typography.dart';

/// The Account List screen shown on Tab 1 of the main navigation shell.
///
/// Displays all non-system, non-deleted accounts grouped into contributing
/// (included in net worth) and excluded sections, with a net worth summary
/// card at the top.
class AccountListScreen extends ConsumerWidget {
  /// Creates the [AccountListScreen].
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.accountNew),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
      body: accountsAsync.when(
        loading: () => const _LoadingSkeleton(),
        error: (error, _) => _ErrorCard(
          message: 'Could not load accounts. Tap to retry.',
          onRetry: () => ref.invalidate(accountsProvider),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const _EmptyState();
          }
          return _AccountList(
            accounts: accounts,
            netWorthAsync: netWorthAsync,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account list body
// ---------------------------------------------------------------------------

/// Renders the net worth card + grouped account rows.
///
/// Reads [currencySymbolLabelsProvider] (CURR-02, T-91) to resolve display
/// labels for each account's currency. When multiple active accounts share a
/// symbol (e.g. '$' for USD and CAD), ISO-code suffixes are appended.
class _AccountList extends ConsumerWidget {
  const _AccountList({
    required this.accounts,
    required this.netWorthAsync,
  });

  final List<Account> accounts;
  final AsyncValue<NetWorthResult> netWorthAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributing =
        accounts.where((a) => a.includeInNetWorth && !a.isDeleted).toList();
    final excluded =
        accounts.where((a) => !a.includeInNetWorth && !a.isDeleted).toList();

    // Read home currency for display.
    final settings = ref.watch(appSettingsProvider).value;
    final homeCurrency = settings?.homeCurrency ?? 'INR';

    // Currency symbol disambiguation (CURR-02, T-91): resolves display labels
    // for all active-account currencies. Falls back to bare code when loading.
    final symbolLabels = ref.watch(currencySymbolLabelsProvider).value ?? {};

    return CustomScrollView(
      slivers: [
        // Net worth summary card (sticky below AppBar)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _NetWorthCard(
              netWorthAsync: netWorthAsync,
              homeCurrency: homeCurrency,
            ),
          ),
        ),

        // Contributing account rows
        if (contributing.isNotEmpty)
          SliverList.builder(
            itemCount: contributing.length,
            itemBuilder: (context, index) => _AccountRow(
              account: contributing[index],
              excluded: false,
              symbolLabels: symbolLabels,
            ),
          ),

        // Excluded section header + rows
        if (excluded.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SectionDivider(label: 'Excluded from net worth'),
          ),
          SliverList.builder(
            itemCount: excluded.length,
            itemBuilder: (context, index) => _AccountRow(
              account: excluded[index],
              excluded: true,
              symbolLabels: symbolLabels,
            ),
          ),
        ],

        // Bottom padding so FAB doesn't overlap last row
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Net worth card
// ---------------------------------------------------------------------------

/// FilledCard showing the aggregate net worth total.
///
/// Shows a staleness chip when [NetWorthResult.hasStaleRates] is true.
/// Uses [currencySymbolLabelsProvider] (CURR-02, T-92) to resolve the display
/// label for the home currency. If only one home currency is active the bare
/// symbol is shown; in a multi-currency session the ISO suffix is appended.
class _NetWorthCard extends ConsumerWidget {
  const _NetWorthCard({
    required this.netWorthAsync,
    required this.homeCurrency,
  });

  final AsyncValue<NetWorthResult> netWorthAsync;
  final String homeCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final typo = Theme.of(context).extension<VarianceTypography>() ??
        VarianceTypography.defaults;

    // Resolve home-currency display label (CURR-02, T-92).
    final symbolLabels = ref.watch(currencySymbolLabelsProvider).value ?? {};
    final currencyLabel = symbolLabels[homeCurrency] ?? homeCurrency;

    return Card.filled(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: netWorthAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            'Net worth unavailable',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: typo.bodyMedium,
            ),
          ),
          data: (result) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Worth',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withAlpha(180),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatAmount(result.totalMinor, currencyLabel),
                style: TextStyle(
                  fontSize: typo.displayHeroAmount,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                  height: 1.1,
                ),
              ),
              if (result.hasStaleRates) ...[
                const SizedBox(height: 8),
                _StalenessChip(
                  onPrimaryContainer: colorScheme.onPrimaryContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(int minorUnits, String currencyLabel) {
    // Simple integer-based formatting (minor units → whole.fraction).
    // TODO(dev): Replace with locale-aware formatting from AppSettings when
    //            the number format preferences are implemented (T-178).
    final whole = minorUnits.abs() ~/ 100;
    final frac = (minorUnits.abs() % 100).toString().padLeft(2, '0');
    final sign = minorUnits < 0 ? '-' : '';
    return '$sign$currencyLabel $whole.$frac';
  }
}

/// Small chip indicating that exchange rates may be outdated (> 14 days old).
class _StalenessChip extends StatelessWidget {
  const _StalenessChip({required this.onPrimaryContainer});

  final Color onPrimaryContainer;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.warning_amber_rounded,
        size: 16,
        color: onPrimaryContainer,
      ),
      label: Text(
        'Exchange rate may be outdated',
        style: TextStyle(
          fontSize: 11,
          color: onPrimaryContainer,
        ),
      ),
      backgroundColor: onPrimaryContainer.withAlpha(30),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ---------------------------------------------------------------------------
// Account row
// ---------------------------------------------------------------------------

/// A single account row displayed in the list.
///
/// Wraps the content in [Opacity] when [excluded] is true to visually gray it
/// out (UI Spec §7.1.1 "excluded account row: reduced opacity 0.5").
///
/// [symbolLabels] carries the CURR-02 disambiguation map (code → display label).
class _AccountRow extends ConsumerWidget {
  const _AccountRow({
    required this.account,
    required this.excluded,
    required this.symbolLabels,
  });

  final Account account;
  final bool excluded;

  /// Map from currency code to display label (e.g. '\$USD' when colliding,
  /// '\$' when unique). Produced by [currencySymbolLabelsProvider].
  final Map<String, String> symbolLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = _AccountTile(
      account: account,
      excluded: excluded,
      symbolLabels: symbolLabels,
    );

    if (excluded) {
      return Opacity(opacity: 0.5, child: tile);
    }
    return tile;
  }
}

/// The actual [ListTile] content for an account row.
///
/// [symbolLabels] carries the CURR-02 disambiguation map (code → display label).
class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    required this.account,
    required this.excluded,
    required this.symbolLabels,
  });

  final Account account;
  final bool excluded;

  /// Map from currency code to display label produced by
  /// [currencySymbolLabelsProvider] (CURR-02, T-91).
  final Map<String, String> symbolLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final varianceColors = Theme.of(context).extension<VarianceColors>();
    final typo = Theme.of(context).extension<VarianceTypography>() ??
        VarianceTypography.defaults;

    final balanceAsync =
        ref.watch(accountBalanceProvider(account.id, account.currencyCode));

    // Resolve display label: ISO-suffixed when colliding, bare symbol
    // otherwise. Fall back to bare code when the resolver hasn't fired yet.
    final currencyLabel =
        symbolLabels[account.currencyCode] ?? account.currencyCode;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(
          _categoryIcon(account.accountCategory),
          color: colorScheme.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        account.name,
        style: TextStyle(
          fontSize: typo.bodyLarge,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: _CategoryChip(category: account.accountCategory),
      trailing: balanceAsync.when(
        loading: () => const SizedBox(
          width: 60,
          height: 16,
          child: LinearProgressIndicator(),
        ),
        error: (_, __) => const Icon(Icons.error_outline, size: 18),
        data: (balanceMinor) => _BalanceDisplay(
          balanceMinor: balanceMinor,
          // Pass the resolved label (e.g. '$USD') instead of bare code.
          currencyLabel: currencyLabel,
          typo: typo,
          colorScheme: colorScheme,
          varianceColors: varianceColors,
        ),
      ),
      onTap: () => context.push('/accounts/${account.id}'),
    );
  }

  IconData _categoryIcon(AccountCategory category) {
    return switch (category) {
      AccountCategory.cash => Icons.payments_outlined,
      AccountCategory.bankAccount => Icons.account_balance_outlined,
      AccountCategory.creditCard => Icons.credit_card,
      AccountCategory.debitCard => Icons.credit_card_outlined,
      AccountCategory.topUpWallet => Icons.account_balance_wallet_outlined,
      AccountCategory.loan => Icons.handshake_outlined,
      AccountCategory.investment => Icons.trending_up_outlined,
      AccountCategory.other => Icons.folder_outlined,
      AccountCategory.equity => Icons.balance_outlined,
    };
  }
}

/// Displays the account balance with sign-based colour coding.
///
/// - Positive / zero: [ColorScheme.onSurface]
/// - Negative: [VarianceColors.warningAmount]
///
/// [currencyLabel] is the CURR-02 disambiguated label (e.g. '\$USD', '\$CAD',
/// or '₹' when no collision). Accessibility: negative balance includes the
/// word "negative" so screen readers convey the liability state (PRD §5.1.4.1).
class _BalanceDisplay extends StatelessWidget {
  const _BalanceDisplay({
    required this.balanceMinor,
    required this.currencyLabel,
    required this.typo,
    required this.colorScheme,
    required this.varianceColors,
  });

  final int balanceMinor;

  /// Disambiguated display label from [currencySymbolLabelsProvider] (T-91).
  /// May be a bare symbol ('₹'), ISO-suffixed ('$USD'), or bare code ('INR')
  /// as a fallback when the resolver hasn't emitted yet.
  final String currencyLabel;

  final VarianceTypography typo;
  final ColorScheme colorScheme;
  final VarianceColors? varianceColors;

  @override
  Widget build(BuildContext context) {
    final isNegative = balanceMinor < 0;
    final color = isNegative
        ? (varianceColors?.warningAmount ?? colorScheme.error)
        : colorScheme.onSurface;

    // Format: absolute value, no minus sign in primary display (PRD §5.1.4.1).
    final whole = balanceMinor.abs() ~/ 100;
    final frac = (balanceMinor.abs() % 100).toString().padLeft(2, '0');
    final displayText = '$currencyLabel $whole.$frac';

    // Screen reader label conveys liability state (PRD §5.1.4.1).
    final semanticsLabel = isNegative
        ? 'negative $currencyLabel $whole.$frac'
        : '$currencyLabel $whole.$frac';

    return Semantics(
      label: semanticsLabel,
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: typo.numericMedium,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }
}

/// A compact chip showing the account category name.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final AccountCategory category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Chip(
        label: Text(
          _categoryLabel(category),
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        backgroundColor: colorScheme.secondaryContainer,
        side: BorderSide.none,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _categoryLabel(AccountCategory category) {
    return switch (category) {
      AccountCategory.cash => 'Cash',
      AccountCategory.bankAccount => 'Bank Account',
      AccountCategory.creditCard => 'Credit Card',
      AccountCategory.debitCard => 'Debit Card',
      AccountCategory.topUpWallet => 'Wallet',
      AccountCategory.loan => 'Loan',
      AccountCategory.investment => 'Investment',
      AccountCategory.other => 'Other',
      AccountCategory.equity => 'Equity',
    };
  }
}

// ---------------------------------------------------------------------------
// Section divider
// ---------------------------------------------------------------------------

/// A labelled section divider used between contributing and excluded rows.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(child: Divider(color: colorScheme.outlineVariant)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

/// Full-screen empty state shown when no accounts exist yet.
///
/// Shows an icon illustration, headline, subtext, and a FilledButton CTA.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No accounts yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first account to start tracking',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

/// Shimmer-like skeleton loading state (linear progress indicators).
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Net worth card skeleton
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
        // Account row skeletons
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error card
// ---------------------------------------------------------------------------

/// Inline error card with a retry button.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 32),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
