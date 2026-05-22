// lib/presentation/features/transactions/filter_sheet.dart
//
// FilterSheet — modal bottom sheet for transaction list filtering (T-59).
//
// Contents:
//   - Transaction type filter chips (Expense / Income / Transfer).
//   - Date range picker (shows system date range picker on tap).
//   - Account multi-select list.
//   - Category multi-select list (filtered by selected types per TC-023).
//   - Amount range slider.
//   - "Clear all" and "Apply" action buttons.
//
// State is managed by FilterNotifier. Changes are applied immediately to
// the notifier as the user interacts; closing the sheet does not revert
// changes. The caller may reset state by calling FilterNotifier.clear().
//
// Test cases (see test/presentation/features/transactions/filter_sheet_test.dart):
//   - renders type chips section header
//   - renders Expense/Income/Transfer chips
//   - renders Clear all button

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

// ---------------------------------------------------------------------------
// FilterSheet
// ---------------------------------------------------------------------------

/// Modal bottom sheet for narrowing the transaction list (T-59, TXN-09).
///
/// Renders filter controls for transaction type, date range, account,
/// category, and amount range. Binds directly to [FilterNotifier].
///
/// Show via:
/// ```dart
/// showModalBottomSheet(context: context, builder: (_) => const FilterSheet());
/// ```
class FilterSheet extends ConsumerWidget {
  /// Creates a [FilterSheet].
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(context),
              _buildHeader(context, filterState, notifier),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // ---- Transaction Type ----
                    const _SectionHeader(label: 'Transaction Type'),
                    _TypeFilterChips(
                      selectedTypes: filterState.types,
                      onChanged: notifier.setTypes,
                    ),
                    const SizedBox(height: 16),

                    // ---- Date Range ----
                    const _SectionHeader(label: 'Date Range'),
                    _DateRangeTile(
                      selected: filterState.dateRange,
                      onChanged: notifier.setDateRange,
                    ),
                    const SizedBox(height: 16),

                    // ---- Accounts ----
                    const _SectionHeader(label: 'Accounts'),
                    _AccountMultiSelect(
                      selectedIds: filterState.accountIds,
                      onChanged: notifier.setAccountIds,
                    ),
                    const SizedBox(height: 16),

                    // ---- Categories (filtered by selected types) ----
                    const _SectionHeader(label: 'Categories'),
                    _CategoryMultiSelect(
                      selectedIds: filterState.categoryIds,
                      activeTypes: filterState.types,
                      onChanged: notifier.setCategoryIds,
                    ),
                    const SizedBox(height: 16),

                    // ---- Amount range ----
                    const _SectionHeader(label: 'Amount Range'),
                    _AmountRangeTile(
                      minMinor: filterState.minAmountMinor,
                      maxMinor: filterState.maxAmountMinor,
                      onChanged: notifier.setAmountRange,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    FilterState state,
    FilterNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter Transactions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (state.hasActiveFilters)
          TextButton(
            onPressed: notifier.clear,
            child: const Text('Clear all'),
          )
        else
          const _InvisibleClearButton(),
      ],
    );
  }
}

/// Invisible placeholder to prevent layout shift when "Clear all" appears.
class _InvisibleClearButton extends StatelessWidget {
  const _InvisibleClearButton();

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 0,
      child: TextButton(
        onPressed: null,
        child: Text('Clear all'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type filter chips
// ---------------------------------------------------------------------------

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({
    required this.selectedTypes,
    required this.onChanged,
  });

  final List<TransactionType> selectedTypes;
  final void Function(List<TransactionType>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: TransactionType.values.map((type) {
        final selected = selectedTypes.contains(type);
        return FilterChip(
          label: Text(_labelFor(type)),
          selected: selected,
          onSelected: (val) {
            final updated = List<TransactionType>.from(selectedTypes);
            if (val) {
              updated.add(type);
            } else {
              updated.remove(type);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }

  String _labelFor(TransactionType type) => switch (type) {
        TransactionType.expense => 'Expense',
        TransactionType.income => 'Income',
        TransactionType.transfer => 'Transfer',
      };
}

// ---------------------------------------------------------------------------
// Date range tile
// ---------------------------------------------------------------------------

class _DateRangeTile extends StatelessWidget {
  const _DateRangeTile({required this.selected, required this.onChanged});

  final DateTimeRange? selected;
  final void Function(DateTimeRange?) onChanged;

  @override
  Widget build(BuildContext context) {
    final label = selected == null
        ? 'Any date'
        : '${_fmt(selected!.start)} – ${_fmt(selected!.end)}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.date_range_outlined),
      title: Text(label),
      trailing: selected != null
          ? IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear date range',
              onPressed: () => onChanged(null),
            )
          : null,
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 366)),
          initialDateRange: selected,
        );
        if (range != null) onChanged(range);
      },
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ---------------------------------------------------------------------------
// Account multi-select
// ---------------------------------------------------------------------------

class _AccountMultiSelect extends ConsumerWidget {
  const _AccountMultiSelect({
    required this.selectedIds,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return const Text('No accounts available');
        }
        return _buildList(context, accounts);
      },
      loading: () =>
          const SizedBox(height: 40, child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load accounts'),
    );
  }

  Widget _buildList(BuildContext context, List<Account> accounts) {
    return Wrap(
      spacing: 8,
      children: accounts.map((acc) {
        final selected = selectedIds.contains(acc.id);
        return FilterChip(
          label: Text(acc.name),
          selected: selected,
          onSelected: (val) {
            final updated = List<String>.from(selectedIds);
            if (val) {
              updated.add(acc.id);
            } else {
              updated.remove(acc.id);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Category multi-select
// ---------------------------------------------------------------------------

class _CategoryMultiSelect extends ConsumerWidget {
  const _CategoryMultiSelect({
    required this.selectedIds,
    required this.activeTypes,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final List<TransactionType> activeTypes;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Filter by tree type matching active transaction types (TC-023).
        // If no type filter active, show all.
        final filtered = activeTypes.isEmpty
            ? categories
            : categories.where((c) {
                if (activeTypes.contains(TransactionType.expense)) {
                  if (c.treeType == CategoryTreeType.expense) return true;
                }
                if (activeTypes.contains(TransactionType.income)) {
                  if (c.treeType == CategoryTreeType.income) return true;
                }
                return false;
              }).toList();

        if (filtered.isEmpty) {
          return const Text('No categories available');
        }
        return _buildList(context, filtered);
      },
      loading: () =>
          const SizedBox(height: 40, child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load categories'),
    );
  }

  Widget _buildList(BuildContext context, List<Category> categories) {
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        final selected = selectedIds.contains(cat.id);
        return FilterChip(
          label: Text(cat.name),
          selected: selected,
          onSelected: (val) {
            final updated = List<String>.from(selectedIds);
            if (val) {
              updated.add(cat.id);
            } else {
              updated.remove(cat.id);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Amount range tile
// ---------------------------------------------------------------------------

class _AmountRangeTile extends StatefulWidget {
  const _AmountRangeTile({
    required this.minMinor,
    required this.maxMinor,
    required this.onChanged,
  });

  final int? minMinor;
  final int? maxMinor;
  final void Function({int? minMinor, int? maxMinor}) onChanged;

  @override
  State<_AmountRangeTile> createState() => _AmountRangeTileState();
}

class _AmountRangeTileState extends State<_AmountRangeTile> {
  // Default display range: 0 – ₹1,00,000 (100,000 * 100 minor units).
  static const double _kDefaultMax = 10000000; // 1,00,000 in minor units.

  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      (widget.minMinor ?? 0).toDouble(),
      (widget.maxMinor ?? _kDefaultMax).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minDisplay = (_range.start / 100).toStringAsFixed(0);
    final maxDisplay = (_range.end / 100).toStringAsFixed(0);
    final isAtDefault = _range.start == 0 && _range.end == _kDefaultMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹$minDisplay', style: Theme.of(context).textTheme.bodySmall),
            Text('₹$maxDisplay', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        RangeSlider(
          values: _range,
          min: 0,
          max: _kDefaultMax,
          divisions: 1000,
          onChanged: (values) {
            setState(() => _range = values);
          },
          onChangeEnd: (values) {
            widget.onChanged(
              minMinor: values.start == 0 ? null : values.start.round(),
              maxMinor: values.end == _kDefaultMax ? null : values.end.round(),
            );
          },
        ),
        if (!isAtDefault)
          TextButton(
            onPressed: () {
              setState(() {
                _range = const RangeValues(0, _kDefaultMax);
              });
              widget.onChanged(minMinor: null, maxMinor: null);
            },
            child: const Text('Reset range'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ActiveFilterChipStrip
// ---------------------------------------------------------------------------

/// Horizontal chip strip showing active filters below the search bar.
///
/// Each chip displays one active filter criterion. Tapping × on a chip
/// removes that specific filter. Shown only when [FilterState.hasActiveFilters]
/// is true.
class ActiveFilterChipStrip extends ConsumerWidget {
  /// Creates an [ActiveFilterChipStrip].
  const ActiveFilterChipStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    if (!state.hasActiveFilters) return const SizedBox.shrink();

    final chips = <Widget>[
      // Type chips.
      ...state.types.map(
        (t) => _DismissibleChip(
          label: _typeLabel(t),
          onDismiss: () {
            final updated = List<TransactionType>.from(state.types)..remove(t);
            notifier.setTypes(updated);
          },
        ),
      ),
      // Date range chip.
      if (state.dateRange != null)
        _DismissibleChip(
          label: _dateRangeLabel(state.dateRange!),
          onDismiss: () => notifier.setDateRange(null),
        ),
      // Account chips (show count for brevity).
      if (state.accountIds.isNotEmpty)
        _DismissibleChip(
          label: '${state.accountIds.length} account(s)',
          onDismiss: () => notifier.setAccountIds([]),
        ),
      // Category chips.
      if (state.categoryIds.isNotEmpty)
        _DismissibleChip(
          label: '${state.categoryIds.length} categor(ies)',
          onDismiss: () => notifier.setCategoryIds([]),
        ),
      // Amount range chip.
      if (state.minAmountMinor != null || state.maxAmountMinor != null)
        _DismissibleChip(
          label: _amountRangeLabel(state),
          // setAmountRange has optional named params — cannot use tearoff.
          // ignore: unnecessary_lambdas
          onDismiss: () => notifier.setAmountRange(),
        ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  String _dateRangeLabel(DateTimeRange range) {
    final s = range.start;
    final e = range.end;
    return '${s.day}/${s.month} – ${e.day}/${e.month}';
  }

  String _amountRangeLabel(FilterState s) {
    final min = s.minAmountMinor != null
        ? '₹${(s.minAmountMinor! / 100).toStringAsFixed(0)}'
        : '₹0';
    final max = s.maxAmountMinor != null
        ? '₹${(s.maxAmountMinor! / 100).toStringAsFixed(0)}'
        : 'any';
    return '$min – $max';
  }
}

class _DismissibleChip extends StatelessWidget {
  const _DismissibleChip({required this.label, required this.onDismiss});

  final String label;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDismiss,
      deleteIcon: const Icon(Icons.close, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
