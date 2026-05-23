// lib/presentation/features/home/widgets/active_filter_chip_strip.dart
//
// ActiveFilterChipStrip — horizontal chip strip for active Home screen filters.
//
// Architecture (T-163, UI spec §6.6.2, UX flows §7.7.5):
//   - Horizontally scrollable Row of InputChip widgets; one per active
//     filter criterion.
//   - Each chip label summarises the criterion (e.g. "Type: Income",
//     "Account: 2 selected").
//   - Trailing × on each chip calls the appropriate FilterNotifier method.
//   - "Clear all" InputChip (errorContainer / onErrorContainer fill) clears
//     everything.
//   - Strip hidden when no active filters (SizedBox.shrink).
//   - Shown above the transaction list when ≥1 filter is active.
//
// 0-results behaviour (T-163 spec):
//   When [isEmpty] is true (no transactions match active filters), show an
//   empty-state text below the strip. This is handled by the parent widget
//   (HomeScreen) — the strip itself only manages the chip row.
//
// Test cases (see test/presentation/features/home/active_filter_chip_strip_test.dart):
//   T-163.1. chip strip hidden when no active filters
//   T-163.2. chip strip visible when at least one filter is active
//   T-163.3. tapping the type chip × calls setTypes([])
//   T-163.4. tapping "Clear all" chip calls filterNotifier.reset()

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

// ---------------------------------------------------------------------------
// ActiveFilterChipStrip
// ---------------------------------------------------------------------------

/// Horizontal scrollable chip strip showing currently active filter criteria.
///
/// Hidden when no filters are active. Each chip summarises one criterion and
/// provides a delete button to remove it. A "Clear all" chip appears at the
/// end when any filter is active.
class ActiveFilterChipStrip extends ConsumerWidget {
  /// Creates an [ActiveFilterChipStrip].
  const ActiveFilterChipStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filterProvider);

    if (!state.hasActiveFilters) return const SizedBox.shrink();

    final notifier = ref.read(filterProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    final chips = <Widget>[
      // --- Type chips (one per active type) ---
      ...state.types.map(
        (t) => _ActiveChip(
          label: 'Type: ${_typeLabel(t)}',
          onDismiss: () {
            final updated = List<TransactionType>.from(state.types)..remove(t);
            notifier.setTypes(updated);
          },
        ),
      ),

      // --- Date range chip ---
      if (state.dateRange != null)
        _ActiveChip(
          label: 'Date: ${_dateLabel(state.dateRange!)}',
          onDismiss: () => notifier.setDateRange(null),
        ),

      // --- Account chip (summarised) ---
      if (state.accountIds.isNotEmpty)
        _ActiveChip(
          label: 'Account: ${state.accountIds.length} selected',
          onDismiss: () => notifier.setAccountIds([]),
        ),

      // --- Category chip (summarised) ---
      if (state.categoryIds.isNotEmpty)
        _ActiveChip(
          label: 'Category: ${state.categoryIds.length} selected',
          onDismiss: () => notifier.setCategoryIds([]),
        ),

      // --- Amount range chip ---
      if (state.minAmountMinor != null || state.maxAmountMinor != null)
        _ActiveChip(
          label: _amountLabel(state),
          // setAmountRange has optional named params — suppress lint.
          // ignore: unnecessary_lambdas
          onDismiss: () => notifier.setAmountRange(),
        ),

      // --- Boolean flag chips ---
      if (state.hasPhoto)
        _ActiveChip(
          label: 'Has photo',
          onDismiss: () => notifier.toggleBoolean('hasPhoto'),
        ),
      if (state.hasTitle)
        _ActiveChip(
          label: 'Has title',
          onDismiss: () => notifier.toggleBoolean('hasTitle'),
        ),
      if (state.hasDescription)
        _ActiveChip(
          label: 'Has description',
          onDismiss: () => notifier.toggleBoolean('hasDescription'),
        ),
      if (state.isRecurring)
        _ActiveChip(
          label: 'Is recurring',
          onDismiss: () => notifier.toggleBoolean('isRecurring'),
        ),
      if (state.isVoided)
        _ActiveChip(
          label: 'Is voided',
          onDismiss: () => notifier.toggleBoolean('isVoided'),
        ),

      // --- Clear all chip (errorContainer fill per UI spec §6.6.2) ---
      InputChip(
        key: const Key('clear_all_chip'),
        label: const Text('Clear all'),
        backgroundColor: colorScheme.errorContainer,
        labelStyle: TextStyle(color: colorScheme.onErrorContainer),
        deleteIconColor: colorScheme.onErrorContainer,
        onPressed: notifier.reset,
        onDeleted: notifier.reset,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  String _typeLabel(TransactionType t) => switch (t) {
        TransactionType.expense => 'Expense',
        TransactionType.income => 'Income',
        TransactionType.transfer => 'Transfer',
      };

  String _dateLabel(DateTimeRange r) {
    final s = r.start;
    final e = r.end;
    return '${s.day}/${s.month}–${e.day}/${e.month}';
  }

  String _amountLabel(FilterState s) {
    final min = s.minAmountMinor != null
        ? '₹${(s.minAmountMinor! / 100).toStringAsFixed(0)}'
        : '₹0';
    final max = s.maxAmountMinor != null
        ? '₹${(s.maxAmountMinor! / 100).toStringAsFixed(0)}'
        : 'any';
    return 'Amount: $min–$max';
  }
}

// ---------------------------------------------------------------------------
// Individual active chip
// ---------------------------------------------------------------------------

/// A single InputChip representing one active filter criterion.
class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onDismiss});

  final String label;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputChip(
      label: Text(label),
      onDeleted: onDismiss,
      deleteIcon: const Icon(Icons.close, size: 16),
      // accentPastel approximation: use secondaryContainer per M3.
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
