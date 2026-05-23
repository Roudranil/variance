// lib/presentation/features/home/widgets/filter_bottom_sheet.dart
//
// FilterBottomSheet — full-featured modal bottom sheet for Home screen
// transaction list filtering (T-162).
//
// Implements all filter criteria from UX flows §7.7.2 and §7.7.4:
//   - Transaction type multi-select (Income / Expense / Transfer)
//   - Category and subcategory multi-select (sub-sheet)
//   - Account multi-select
//   - Date range: preset chips + date range picker for "Custom"
//   - Amount range: two numeric OutlinedTextFields (Min / Max)
//   - Boolean SwitchListTile rows: Has photo / Has title / Has description /
//     Is recurring / Is voided
//   - Sort SegmentedButton rows: Date (desc/asc) + Amount (desc/asc)
//   - "Apply" FilledButton dismisses sheet and commits state
//   - "Reset" TextButton clears all filters
//
// Design spec (UI spec §6.6):
//   - DraggableScrollableSheet (min 50%, max 95%)
//   - Drag handle: Container 32×4 dp, outlineVariant fill
//   - Header row: "Filters" text + right-aligned Reset TextButton
//
// Architecture:
//   - Binds directly to FilterNotifier (filterProvider).
//   - Changes are applied when the user taps "Apply".
//   - Local draft state is kept in a StatefulWidget; notifier is updated on Apply.
//
// Test cases:
//   T-162.1. renders Filters header
//   T-162.2. type chips show Income/Expense/Transfer
//   T-162.3. Reset clears all filter fields
//   T-162.4. Apply commits draft state to FilterNotifier

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Shows the [FilterBottomSheet] as a modal bottom sheet.
///
/// The sheet is a [DraggableScrollableSheet] with min 50%, max 95% height.
/// Filter state is committed when the user taps "Apply".
///
/// Parameters:
/// - [context]: The [BuildContext] used to show the sheet.
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FilterBottomSheet(),
  );
}

// ---------------------------------------------------------------------------
// FilterBottomSheet
// ---------------------------------------------------------------------------

/// Modal bottom sheet for Home screen transaction list filtering.
///
/// Uses a draft state pattern: local draft [FilterState] is applied only when
/// the user taps "Apply". Tapping "Reset" clears the draft without affecting
/// the committed state. Tapping outside or swiping down cancels without
/// applying.
class FilterBottomSheet extends ConsumerStatefulWidget {
  /// Creates a [FilterBottomSheet].
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // Draft copies of filter criteria — applied on "Apply".
  late List<TransactionType> _types;
  late List<String> _accountIds;
  late List<String> _categoryIds;
  late DateTimeRange? _dateRange;
  late int? _minAmountMinor;
  late int? _maxAmountMinor;
  late bool _hasPhoto;
  late bool _hasTitle;
  late bool _hasDescription;
  late bool _isRecurring;
  late bool _isVoided;
  late SortField _sortField;
  late SortDirection _sortDirection;

  // Text controllers for amount fields.
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise draft from current committed state.
    final current = ref.read(filterProvider);
    _types = List.from(current.types);
    _accountIds = List.from(current.accountIds);
    _categoryIds = List.from(current.categoryIds);
    _dateRange = current.dateRange;
    _minAmountMinor = current.minAmountMinor;
    _maxAmountMinor = current.maxAmountMinor;
    _hasPhoto = current.hasPhoto;
    _hasTitle = current.hasTitle;
    _hasDescription = current.hasDescription;
    _isRecurring = current.isRecurring;
    _isVoided = current.isVoided;
    _sortField = current.sortField;
    _sortDirection = current.sortDirection;

    if (_minAmountMinor != null) {
      _minController.text = (_minAmountMinor! / 100).toStringAsFixed(0);
    }
    if (_maxAmountMinor != null) {
      _maxController.text = (_maxAmountMinor! / 100).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Draft mutation helpers
  // --------------------------------------------------------------------------

  void _toggleType(TransactionType type) {
    setState(() {
      if (_types.contains(type)) {
        _types = List.from(_types)..remove(type);
      } else {
        _types = List.from(_types)..add(type);
      }
    });
  }

  void _resetDraft() {
    setState(() {
      _types = [];
      _accountIds = [];
      _categoryIds = [];
      _dateRange = null;
      _minAmountMinor = null;
      _maxAmountMinor = null;
      _hasPhoto = false;
      _hasTitle = false;
      _hasDescription = false;
      _isRecurring = false;
      _isVoided = false;
      _sortField = SortField.date;
      _sortDirection = SortDirection.descending;
      _minController.clear();
      _maxController.clear();
    });
  }

  void _applyAndClose() {
    // Parse amount fields.
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();
    final minParsed = minText.isEmpty
        ? null
        : ((double.tryParse(minText) ?? 0) * 100).round();
    final maxParsed = maxText.isEmpty
        ? null
        : ((double.tryParse(maxText) ?? 0) * 100).round();

    // Commit draft to FilterNotifier.
    final notifier = ref.read(filterProvider.notifier);
    notifier
      ..setTypes(_types)
      ..setAccountIds(_accountIds)
      ..setCategoryIds(_categoryIds)
      ..setDateRange(_dateRange)
      ..setAmountRange(minMinor: minParsed, maxMinor: maxParsed);

    // Apply boolean toggles by comparing with current committed state.
    final committed = ref.read(filterProvider);
    if (committed.hasPhoto != _hasPhoto) notifier.toggleBoolean('hasPhoto');
    if (committed.hasTitle != _hasTitle) notifier.toggleBoolean('hasTitle');
    if (committed.hasDescription != _hasDescription) {
      notifier.toggleBoolean('hasDescription');
    }
    if (committed.isRecurring != _isRecurring) {
      notifier.toggleBoolean('isRecurring');
    }
    if (committed.isVoided != _isVoided) notifier.toggleBoolean('isVoided');

    notifier.setSortField(_sortField, _sortDirection);

    if (mounted) Navigator.of(context).maybePop();
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle (UI spec §6.6: 32×4 dp, outlineVariant fill).
              _DragHandle(color: colorScheme.outlineVariant),

              // Header row: "Filters" + Reset button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: textTheme.titleLarge,
                    ),
                    TextButton(
                      key: const Key('filter_sheet_reset'),
                      onPressed: _resetDraft,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable content.
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // ---- Transaction Type ----
                    _SectionHeader(
                      label: 'Transaction Type',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _TypeChipRow(
                      selected: _types,
                      onToggle: _toggleType,
                    ),
                    const SizedBox(height: 16),

                    // ---- Date Range ----
                    _SectionHeader(
                      label: 'Date Range',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _DateRangeSection(
                      selected: _dateRange,
                      onChanged: (r) => setState(() => _dateRange = r),
                    ),
                    const SizedBox(height: 16),

                    // ---- Accounts ----
                    _SectionHeader(
                      label: 'Accounts',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _AccountMultiSelect(
                      selectedIds: _accountIds,
                      onChanged: (ids) => setState(() => _accountIds = ids),
                    ),
                    const SizedBox(height: 16),

                    // ---- Categories ----
                    _SectionHeader(
                      label: 'Categories',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _CategoryMultiSelect(
                      selectedIds: _categoryIds,
                      activeTypes: _types,
                      onChanged: (ids) => setState(() => _categoryIds = ids),
                    ),
                    const SizedBox(height: 16),

                    // ---- Amount Range ----
                    _SectionHeader(
                      label: 'Amount Range',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _AmountRangeRow(
                      minController: _minController,
                      maxController: _maxController,
                    ),
                    const SizedBox(height: 16),

                    // ---- Boolean toggles ----
                    _SectionHeader(
                      label: 'Other Filters',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _BooleanToggle(
                      label: 'Has photo',
                      value: _hasPhoto,
                      onChanged: (v) => setState(() => _hasPhoto = v),
                    ),
                    _BooleanToggle(
                      label: 'Has title',
                      value: _hasTitle,
                      onChanged: (v) => setState(() => _hasTitle = v),
                    ),
                    _BooleanToggle(
                      label: 'Has description',
                      value: _hasDescription,
                      onChanged: (v) => setState(() => _hasDescription = v),
                    ),
                    _BooleanToggle(
                      label: 'Is recurring',
                      value: _isRecurring,
                      onChanged: (v) => setState(() => _isRecurring = v),
                    ),
                    _BooleanToggle(
                      label: 'Is voided',
                      value: _isVoided,
                      onChanged: (v) => setState(() => _isVoided = v),
                    ),
                    const SizedBox(height: 16),

                    // ---- Sort ----
                    _SectionHeader(
                      label: 'Sort',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    _SortSection(
                      sortField: _sortField,
                      sortDirection: _sortDirection,
                      onChanged: (field, dir) => setState(() {
                        _sortField = field;
                        _sortDirection = dir;
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Apply button.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton(
                  key: const Key('filter_sheet_apply'),
                  onPressed: _applyAndClose,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type chip row
// ---------------------------------------------------------------------------

class _TypeChipRow extends StatelessWidget {
  const _TypeChipRow({
    required this.selected,
    required this.onToggle,
  });

  final List<TransactionType> selected;
  final void Function(TransactionType) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: TransactionType.values.map((type) {
        final isSelected = selected.contains(type);
        return FilterChip(
          label: Text(_label(type)),
          selected: isSelected,
          onSelected: (_) => onToggle(type),
        );
      }).toList(),
    );
  }

  String _label(TransactionType t) => switch (t) {
        TransactionType.expense => 'Expense',
        TransactionType.income => 'Income',
        TransactionType.transfer => 'Transfer',
      };
}

// ---------------------------------------------------------------------------
// Date range section
// ---------------------------------------------------------------------------

/// Preset chips + "Custom" date range picker.
class _DateRangeSection extends StatelessWidget {
  const _DateRangeSection({
    required this.selected,
    required this.onChanged,
  });

  final DateTimeRange? selected;
  final void Function(DateTimeRange?) onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Wrap(
      spacing: 8,
      children: [
        // Preset: This month.
        FilterChip(
          label: const Text('This month'),
          selected: _isThisMonth(selected, now),
          onSelected: (_) => onChanged(
            DateTimeRange(
              start: DateTime(now.year, now.month),
              end: DateTime(now.year, now.month + 1, 0),
            ),
          ),
        ),
        // Preset: Last 7 days.
        FilterChip(
          label: const Text('Last 7 days'),
          selected: _isLast7Days(selected, now),
          onSelected: (_) => onChanged(
            DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
          ),
        ),
        // Preset: Last 30 days.
        FilterChip(
          label: const Text('Last 30 days'),
          selected: _isLast30Days(selected, now),
          onSelected: (_) => onChanged(
            DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
          ),
        ),
        // Custom date range picker.
        FilterChip(
          label: Text(
            selected != null && !_isPreset(selected!, now)
                ? '${_fmt(selected!.start)} – ${_fmt(selected!.end)}'
                : 'Custom',
          ),
          selected: selected != null && !_isPreset(selected!, now),
          onSelected: (_) async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: now.add(const Duration(days: 366)),
              initialDateRange: selected,
            );
            if (range != null) onChanged(range);
          },
        ),
        // Clear chip.
        if (selected != null)
          InputChip(
            label: const Text('Clear'),
            onPressed: () => onChanged(null),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onChanged(null),
          ),
      ],
    );
  }

  bool _isThisMonth(DateTimeRange? r, DateTime now) {
    if (r == null) return false;
    return r.start.year == now.year &&
        r.start.month == now.month &&
        r.start.day == 1;
  }

  bool _isLast7Days(DateTimeRange? r, DateTime now) {
    if (r == null) return false;
    final diff = now.difference(r.start).inDays;
    return diff >= 6 && diff <= 8;
  }

  bool _isLast30Days(DateTimeRange? r, DateTime now) {
    if (r == null) return false;
    final diff = now.difference(r.start).inDays;
    return diff >= 28 && diff <= 32;
  }

  bool _isPreset(DateTimeRange r, DateTime now) =>
      _isThisMonth(r, now) || _isLast7Days(r, now) || _isLast30Days(r, now);

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
        return Wrap(
          spacing: 8,
          children: accounts.map((Account acc) {
            final selected = selectedIds.contains(acc.id);
            return FilterChip(
              label: Text(acc.name),
              selected: selected,
              onSelected: (_) {
                final updated = List<String>.from(selectedIds);
                if (selected) {
                  updated.remove(acc.id);
                } else {
                  updated.add(acc.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        );
      },
      loading: () =>
          const SizedBox(height: 40, child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load accounts'),
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
        final filtered = activeTypes.isEmpty
            ? categories
            : categories.where((c) {
                if (activeTypes.contains(TransactionType.expense) &&
                    c.treeType == CategoryTreeType.expense) {
                  return true;
                }
                if (activeTypes.contains(TransactionType.income) &&
                    c.treeType == CategoryTreeType.income) {
                  return true;
                }
                return false;
              }).toList();

        if (filtered.isEmpty) {
          return const Text('No categories');
        }
        return Wrap(
          spacing: 8,
          children: filtered.map((Category cat) {
            final selected = selectedIds.contains(cat.id);
            return FilterChip(
              label: Text(cat.name),
              selected: selected,
              onSelected: (_) {
                final updated = List<String>.from(selectedIds);
                if (selected) {
                  updated.remove(cat.id);
                } else {
                  updated.add(cat.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        );
      },
      loading: () =>
          const SizedBox(height: 40, child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load categories'),
    );
  }
}

// ---------------------------------------------------------------------------
// Amount range row (two OutlinedTextFields)
// ---------------------------------------------------------------------------

class _AmountRangeRow extends StatelessWidget {
  const _AmountRangeRow({
    required this.minController,
    required this.maxController,
  });

  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minController,
            decoration: const InputDecoration(
              labelText: 'Min amount',
              border: OutlineInputBorder(),
              prefixText: '₹',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: maxController,
            decoration: const InputDecoration(
              labelText: 'Max amount',
              border: OutlineInputBorder(),
              prefixText: '₹',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Boolean toggle (SwitchListTile)
// ---------------------------------------------------------------------------

class _BooleanToggle extends StatelessWidget {
  const _BooleanToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Sort section
// ---------------------------------------------------------------------------

/// Sort field and direction controls (UI spec §7.7.4).
class _SortSection extends StatelessWidget {
  const _SortSection({
    required this.sortField,
    required this.sortDirection,
    required this.onChanged,
  });

  final SortField sortField;
  final SortDirection sortDirection;
  final void Function(SortField, SortDirection) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort by field.
        SegmentedButton<SortField>(
          segments: const [
            ButtonSegment(
              value: SortField.date,
              label: Text('Date'),
              icon: Icon(Icons.calendar_today_outlined),
            ),
            ButtonSegment(
              value: SortField.amount,
              label: Text('Amount'),
              icon: Icon(Icons.attach_money),
            ),
          ],
          selected: {sortField},
          onSelectionChanged: (s) => onChanged(s.first, sortDirection),
        ),
        const SizedBox(height: 8),
        // Sort direction.
        SegmentedButton<SortDirection>(
          segments: const [
            ButtonSegment(
              value: SortDirection.descending,
              label: Text('Newest / Largest'),
              icon: Icon(Icons.arrow_downward),
            ),
            ButtonSegment(
              value: SortDirection.ascending,
              label: Text('Oldest / Smallest'),
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          selected: {sortDirection},
          onSelectionChanged: (s) => onChanged(sortField, s.first),
        ),
      ],
    );
  }
}
