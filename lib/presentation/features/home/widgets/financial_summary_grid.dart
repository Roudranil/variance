// lib/presentation/features/home/widgets/financial_summary_grid.dart
//
// FinancialSummaryGrid — 2×2 grid of ElevatedCard widgets for the home screen.
//
// Architecture (T-150, UI spec §5.1.1):
//   - Renders 4 cards: Net Worth, Income, Expenses, Net.
//   - All cards consume AsyncValue<HomeState> from homeProvider.
//   - Loading state shows 4 skeleton shimmer placeholders.
//   - Populated state shows amount + label per card.
//   - Net card conditional color: incomeAmount (positive), expenseAmount
//     (negative), onSurface (zero).
//   - Amount style: numericLarge from VarianceTypography.
//   - Card background: surfaceContainerLow, elevation=1.
//
// Test cases (see test/widget/features/home/financial_summary_grid_test.dart):
//   1. loading → 4 skeleton placeholders (Key('summary_card_skeleton'))
//   2. populated → all 4 card titles visible
//   3. net positive → incomeAmount color on net amount
//   4. net negative → expenseAmount color on net amount

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/presentation/providers/home_providers.dart';
import 'package:variance/presentation/theme/variance_colors.dart';
import 'package:variance/presentation/theme/variance_typography.dart';

/// 2×2 grid of financial summary cards for the Home screen.
///
/// Reads [homeProvider] and displays loading skeletons or populated cards.
/// Card layout per UI spec §5.1.1: 8 dp gaps, surfaceContainerLow background,
/// elevation=1, numericLarge amounts.
class FinancialSummaryGrid extends ConsumerWidget {
  /// Creates the [FinancialSummaryGrid].
  const FinancialSummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const _SkeletonGrid(),
      error: (_, __) => const _SkeletonGrid(),
      data: (state) => _PopulatedGrid(state: state),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton grid (loading/error states)
// ---------------------------------------------------------------------------

/// Loading skeleton — 4 grey placeholder cards.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return _CardGrid(
      children: List.generate(
        4,
        (i) => _SkeletonCard(index: i),
      ),
    );
  }
}

/// Single skeleton card placeholder.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey('summary_skeleton_card_$index'),
      elevation: 1,
      color: colorScheme.surfaceContainerLow,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Populated grid
// ---------------------------------------------------------------------------

/// Populated 2×2 grid showing actual financial data.
class _PopulatedGrid extends StatelessWidget {
  const _PopulatedGrid({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.monthlySummary;

    return _CardGrid(
      children: [
        _SummaryCard(
          label: 'Net Worth',
          amountMinor: state.netWorthMinor,
          currencyCode: state.netWorthCurrencyCode,
          amountKey: const Key('net_worth_amount_text'),
        ),
        _SummaryCard(
          label: 'Income',
          amountMinor: summary.incomeMinor,
          currencyCode: summary.currencyCode,
          amountColorToken: _AmountColorToken.income,
          amountKey: const Key('income_amount_text'),
        ),
        _SummaryCard(
          label: 'Expenses',
          amountMinor: summary.expensesMinor,
          currencyCode: summary.currencyCode,
          amountColorToken: _AmountColorToken.expense,
          amountKey: const Key('expenses_amount_text'),
        ),
        _SummaryCard(
          label: 'Net',
          amountMinor: summary.netMinor,
          currencyCode: summary.currencyCode,
          amountColorToken: _AmountColorToken.net,
          projectedLabel: state.isFutureMonth,
          amountKey: const Key('net_amount_text'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card grid layout
// ---------------------------------------------------------------------------

/// 2×2 grid container with 8 dp gaps.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 8),
            Expanded(child: children[1]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: children[2]),
            const SizedBox(width: 8),
            Expanded(child: children[3]),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual summary card
// ---------------------------------------------------------------------------

/// Color token hint for the amount display.
enum _AmountColorToken { income, expense, net, neutral }

/// Single summary ElevatedCard with label and formatted amount.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amountMinor,
    required this.currencyCode,
    this.amountColorToken = _AmountColorToken.neutral,
    this.projectedLabel = false,
    this.amountKey,
  });

  final String label;
  final int amountMinor;
  final String currencyCode;
  final _AmountColorToken amountColorToken;
  final bool projectedLabel;
  final Key? amountKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typography = Theme.of(context).extension<VarianceTypography>() ??
        VarianceTypography.defaults;
    final colors =
        Theme.of(context).extension<VarianceColors>() ?? VarianceColors.light;

    final amountColor = _resolveAmountColor(
      colorScheme: colorScheme,
      colors: colors,
      amountMinor: amountMinor,
      token: amountColorToken,
    );

    // Format amount as a simple decimal for display.
    final absMinor = amountMinor.abs();
    final isNegative = amountMinor < 0;
    final formatted =
        '${isNegative ? '−' : ''}$currencyCode ${(absMinor / 100).toStringAsFixed(2)}';

    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (projectedLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    'Projected',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.tertiary,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatted,
              key: amountKey,
              style: TextStyle(
                fontSize: typography.numericLarge,
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolves the display color for the amount based on [token] and value.
  Color _resolveAmountColor({
    required ColorScheme colorScheme,
    required VarianceColors colors,
    required int amountMinor,
    required _AmountColorToken token,
  }) {
    switch (token) {
      case _AmountColorToken.income:
        return colors.incomeAmount;
      case _AmountColorToken.expense:
        return colors.expenseAmount;
      case _AmountColorToken.net:
        if (amountMinor > 0) return colors.incomeAmount;
        if (amountMinor < 0) return colors.expenseAmount;
        return colorScheme.onSurface;
      case _AmountColorToken.neutral:
        return colorScheme.onSurface;
    }
  }
}
