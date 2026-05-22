// lib/presentation/features/home/widgets/month_selector.dart
//
// MonthSelector — row widget for navigating between calendar months.
//
// Architecture (T-151, UI spec §5.1.1, UX flows §6.4):
//   - StatelessWidget (ConsumerWidget) — reads homeProvider for selectedMonth.
//   - Left arrow (chevron_left): decrements month; wraps from Jan → Dec/prev year.
//   - Right arrow (chevron_right): increments month; wraps from Dec → Jan/next year.
//   - Month + year label centered between arrows.
//   - Text style: bodyMedium, onSurface per §5.1.1.
//   - Icon buttons: onSurfaceVariant per §5.1.1.
//   - Default: current calendar month (set by HomeNotifier.build()).
//
// Test cases (see test/widget/features/home/month_selector_test.dart):
//   1. displays current month text
//   2. left arrow → changeMonth(prevYear, prevMonth)
//   3. right arrow → changeMonth(nextYear, nextMonth)
//   4. Jan → Dec/prev year wrap
//   5. Dec → Jan/next year wrap

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:variance/presentation/providers/home_providers.dart';

/// Month navigation row for the Home screen financial summary.
///
/// Renders a row with left/right [IconButton]s and a centred month-year
/// [Text]. Tapping the arrows calls [HomeNotifier.changeMonth] with the
/// adjacent month.
class MonthSelector extends ConsumerWidget {
  /// Creates the [MonthSelector] widget.
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const _MonthSelectorRow(selectedMonth: null),
      error: (_, __) => const _MonthSelectorRow(selectedMonth: null),
      data: (state) => _MonthSelectorRow(selectedMonth: state.selectedMonth),
    );
  }
}

/// Internal row widget that renders the selector UI.
class _MonthSelectorRow extends ConsumerWidget {
  const _MonthSelectorRow({required this.selectedMonth});

  /// The currently selected month, or null when in a loading state.
  final DateTime? selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(homeProvider.notifier);
    final current = selectedMonth ?? DateTime.now();

    final label = DateFormat('MMMM yyyy').format(current);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('month_prev_button'),
          icon: const Icon(Icons.chevron_left),
          color: colorScheme.onSurfaceVariant,
          onPressed: () => _onPrev(notifier, current),
        ),
        Text(
          label,
          key: const Key('month_selector_text'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        IconButton(
          key: const Key('month_next_button'),
          icon: const Icon(Icons.chevron_right),
          color: colorScheme.onSurfaceVariant,
          onPressed: () => _onNext(notifier, current),
        ),
      ],
    );
  }

  /// Navigates to the previous calendar month.
  ///
  /// Wraps from January to December of the previous year.
  void _onPrev(HomeNotifier notifier, DateTime current) {
    final prev = current.month == 1
        ? DateTime(current.year - 1, 12)
        : DateTime(current.year, current.month - 1);
    notifier.changeMonth(prev.year, prev.month);
  }

  /// Navigates to the next calendar month.
  ///
  /// Wraps from December to January of the next year.
  void _onNext(HomeNotifier notifier, DateTime current) {
    final next = current.month == 12
        ? DateTime(current.year + 1, 1)
        : DateTime(current.year, current.month + 1);
    notifier.changeMonth(next.year, next.month);
  }
}
