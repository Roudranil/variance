// lib/presentation/features/home/widgets/home_screen_body.dart
//
// HomeScreenBody — composes all Home screen states into a single widget.
//
// Architecture (T-152, UI spec §5.1.4, UX flows §6.1):
//   - Reads homeProvider and dispatches to the correct state widget.
//   - Loading: skeleton shimmer (greeting 120dp, 4 cards 80dp each, 6 rows).
//   - Error: ErrorCard (errorContainer) + retry FilledButton.
//   - Stale FX: MaterialBanner above content; dismissed per-session via
//     local ValueNotifier.
//   - No-FX-rate: net worth card shows "—" disclaimer (handled in
//     FinancialSummaryGrid).
//   - Future month: "Projected" label in summary (handled in
//     FinancialSummaryGrid).
//   - Nominal: composes GreetingRow + FinancialSummaryGrid + MonthSelector.
//
// Test cases (see test/widget/features/home/home_screen_states_test.dart):
//   1. loading → skeleton visible (skeleton_greeting, 4×skeleton_card,
//      6×skeleton_row)
//   2. error → home_error_card + home_retry_button
//   3. retry → notifier.reload() called
//   4. stale FX → stale_fx_banner shown
//   5. dismiss → stale_fx_banner hidden
//   6. no-FX-rate → no_fx_rate_disclaimer
//   7. future month → "Projected" text

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/presentation/features/home/widgets/financial_summary_grid.dart';
import 'package:variance/presentation/features/home/widgets/greeting_row.dart';
import 'package:variance/presentation/features/home/widgets/month_selector.dart';
import 'package:variance/presentation/providers/home_providers.dart';

/// Top-level body widget for the Home screen that manages all async states.
///
/// Composes [GreetingRow], [FinancialSummaryGrid], and [MonthSelector] in the
/// nominal state. Renders loading skeletons, error cards, and the stale-FX
/// [MaterialBanner] as appropriate.
class HomeScreenBody extends ConsumerStatefulWidget {
  /// Creates the [HomeScreenBody].
  const HomeScreenBody({super.key});

  @override
  ConsumerState<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends ConsumerState<HomeScreenBody> {
  /// Session-scoped flag: true when the stale-FX banner has been dismissed.
  ///
  /// Resets to false on widget re-creation (i.e. each app session).
  bool _fxBannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const _HomeSkeletonState(),
      error: (error, _) => _HomeErrorState(
        onRetry: () => ref.read(homeProvider.notifier).reload(),
      ),
      data: (state) => _HomeNominalState(
        state: state,
        fxBannerDismissed: _fxBannerDismissed,
        onFxBannerDismiss: () => setState(() => _fxBannerDismissed = true),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton state
// ---------------------------------------------------------------------------

/// Skeleton placeholder for the entire Home screen content.
///
/// Shows:
/// - A 120 dp greeting line placeholder.
/// - 4 card placeholders (80 dp each).
/// - 6 row placeholders (48 dp each).
class _HomeSkeletonState extends StatelessWidget {
  const _HomeSkeletonState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting line skeleton
          const _SkeletonBox(
            key: Key('skeleton_greeting'),
            width: 120,
            height: 20,
          ),
          const SizedBox(height: 16),
          // 4 card placeholders (80 dp each)
          for (var i = 0; i < 4; i++) ...[
            _SkeletonBox(
              key: ValueKey('skeleton_card_$i'),
              width: double.infinity,
              height: 80,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          // 6 row placeholders (48 dp each)
          for (var i = 0; i < 6; i++) ...[
            _SkeletonBox(
              key: ValueKey('skeleton_row_$i'),
              width: double.infinity,
              height: 48,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Single skeleton box placeholder.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

/// Error card with a retry button.
///
/// Background uses [ColorScheme.errorContainer]. Retry button calls
/// [HomeNotifier.reload].
class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          key: const Key('home_error_card'),
          color: colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.onErrorContainer,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to load your financial data.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('home_retry_button'),
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

// ---------------------------------------------------------------------------
// Nominal state (populated)
// ---------------------------------------------------------------------------

/// Nominal state — composes greeting, summary grid, month selector, and
/// optional stale-FX banner.
class _HomeNominalState extends StatelessWidget {
  const _HomeNominalState({
    required this.state,
    required this.fxBannerDismissed,
    required this.onFxBannerDismiss,
  });

  final HomeState state;
  final bool fxBannerDismissed;
  final VoidCallback onFxBannerDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stale FX rate banner (shown once per session)
        if (state.hasStaleFx && !fxBannerDismissed)
          _StaleFxBanner(onDismiss: onFxBannerDismiss),

        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingRow(),
                const SizedBox(height: 16),
                const MonthSelector(),
                const SizedBox(height: 12),
                // No-FX-rate disclaimer shown below net worth card
                if (state.hasNoFxRate) const _NoFxRateDisclaimer(),
                const SizedBox(height: 8),
                const FinancialSummaryGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stale FX banner
// ---------------------------------------------------------------------------

/// Material Design banner warning that exchange rates may be outdated.
///
/// Dismissed once per session via [onDismiss] callback. The dismissed state
/// is managed by the parent [_HomeScreenBodyState].
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

// ---------------------------------------------------------------------------
// No-FX-rate disclaimer
// ---------------------------------------------------------------------------

/// Inline disclaimer shown when no exchange rate has ever been fetched.
///
/// Renders below the net worth card; the net worth card itself shows "—".
class _NoFxRateDisclaimer extends StatelessWidget {
  const _NoFxRateDisclaimer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      key: const Key('no_fx_rate_disclaimer'),
      'Net worth unavailable — no exchange rate has been fetched yet.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }
}
