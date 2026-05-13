// lib/presentation/features/settings/recurring/create_recurring_template_screen.dart
//
// CreateRecurringTemplateScreen — create a new recurring transaction template.
//
// Route: /transaction/new (recurring mode)
// UX Flows §7.3, §7.16, §9.23
//
// Layout:
//   - Transaction type selector: Expense / Income / Transfer
//   - Amount field (decimal input → minor units)
//   - Account picker(s): source (expense/transfer) + destination (income/transfer)
//   - Category / subcategory picker: expense/income only
//   - Title / description fields
//   - Recurrence section:
//       N (integer) + unit dropdown (day/week/month/year)
//       Constraints: multi-select chips
//       Start date / end date pickers
//       Live "First scheduled date" preview
//   - Posting behaviour: Auto-post / Remind and confirm
//   - Transfer fee panel (Transfer type only; collapsed by default)
//   - Save button → CreateRecurringTemplateUseCase
//
// States (UX Flows §7.3.1):
//   Empty   → all fields blank, Save disabled
//   Filled  → live first-date preview shown, Save enabled
//   Saving  → loading indicator on Save button
//   Saved   → screen dismissed
//
// Test cases (see test/presentation/features/settings/recurring/
//             create_recurring_template_screen_test.dart):
//   1. Golden: empty state.
//   2. Golden: filled state (expense type, recurrence section expanded).
//   3. Type switch shows/hides account and category fields.
//   4. First-date preview updates on recurrence field change.
//   5. Save button disabled when required fields missing.
//   6. Save calls CreateRecurringTemplateUseCase and navigates back.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/services/recurrence_preview_service.dart';
import 'package:variance/domain/usecases/recurring/create_recurring_template_use_case.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// The "Create Recurring Template" screen.
///
/// Collects all required fields for a [RecurringTemplate] and delegates to
/// [CreateRecurringTemplateUseCase] on save. Navigates back on success.
class CreateRecurringTemplateScreen extends ConsumerStatefulWidget {
  /// Creates a [CreateRecurringTemplateScreen].
  const CreateRecurringTemplateScreen({super.key});

  @override
  ConsumerState<CreateRecurringTemplateScreen> createState() =>
      _CreateRecurringTemplateScreenState();
}

class _CreateRecurringTemplateScreenState
    extends ConsumerState<CreateRecurringTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recurrenceNController = TextEditingController(text: '1');
  final _feeAmountController = TextEditingController();

  // Selected transaction type.
  String _transactionType = 'expense';

  // Account and category selections.
  Account? _sourceAccount;
  Account? _destinationAccount;
  Category? _category;

  // Recurrence fields.
  RecurrenceUnit _recurrenceUnit = RecurrenceUnit.month;
  final Set<RecurrenceConstraint> _selectedConstraints = {};

  // Date fields (stored as epoch days for the domain entity).
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // Posting behaviour.
  PostingBehaviour _postingBehaviour = PostingBehaviour.autoPost;

  // Transfer fee panel.
  bool _feeEnabled = false;
  FeeMode _feeMode = FeeMode.flat;

  // First-date preview (updated on recurrence field change).
  DateTime? _firstDate;
  String? _firstDateError;

  bool _isSaving = false;

  static const _previewService = RecurrencePreviewService();

  @override
  void initState() {
    super.initState();
    _recurrenceNController.addListener(_updateFirstDate);
    _updateFirstDate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _recurrenceNController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  /// Recomputes the first scheduled date from the current recurrence fields.
  void _updateFirstDate() {
    final n = int.tryParse(_recurrenceNController.text) ?? 0;
    final startDay = _startDate.millisecondsSinceEpoch ~/ (86400 * 1000);

    final result = _previewService.computeFirstDate(
      recurrenceN: n,
      recurrenceUnit: _recurrenceUnit,
      recurrenceConstraints: _selectedConstraints.toList(),
      startDate: startDay,
    );

    setState(() {
      switch (result) {
        case Ok(:final value):
          _firstDate = value;
          _firstDateError = null;
        case Err(:final failure):
          _firstDate = null;
          _firstDateError = failure.message;
      }
    });
  }

  /// Whether the Save button should be enabled.
  bool get _canSave {
    if (_isSaving) return false;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return false;
    final n = int.tryParse(_recurrenceNController.text);
    if (n == null || n <= 0) return false;
    if (_transactionType == 'expense' && _sourceAccount == null) return false;
    if (_transactionType == 'income' && _destinationAccount == null) {
      return false;
    }
    if (_transactionType == 'transfer' &&
        (_sourceAccount == null || _destinationAccount == null)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recurring Template'),
        centerTitle: false,
        actions: [
          _SaveButton(
            enabled: _canSave,
            isSaving: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Transaction type selector ----
            _TypeSelector(
              selected: _transactionType,
              onChanged: (type) {
                setState(() {
                  _transactionType = type;
                  // Clear type-specific fields on type change.
                  _category = null;
                  if (type != 'transfer' && type != 'expense') {
                    _sourceAccount = null;
                  }
                  if (type != 'transfer' && type != 'income') {
                    _destinationAccount = null;
                  }
                  _feeEnabled = false;
                });
              },
            ),
            const SizedBox(height: 16),

            // ---- Amount field ----
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final amount = double.tryParse(v ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ---- Account pickers ----
            _AccountPickers(
              transactionType: _transactionType,
              sourceAccount: _sourceAccount,
              destinationAccount: _destinationAccount,
              onSourceChanged: (a) => setState(() => _sourceAccount = a),
              onDestinationChanged: (a) =>
                  setState(() => _destinationAccount = a),
            ),
            const SizedBox(height: 16),

            // ---- Category picker (expense/income only) ----
            if (_transactionType != 'transfer') ...[
              _CategoryPicker(
                selected: _category,
                transactionType: _transactionType,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 16),
            ],

            // ---- Recurrence section ----
            _RecurrenceSection(
              recurrenceNController: _recurrenceNController,
              recurrenceUnit: _recurrenceUnit,
              selectedConstraints: _selectedConstraints,
              startDate: _startDate,
              endDate: _endDate,
              firstDate: _firstDate,
              firstDateError: _firstDateError,
              onUnitChanged: (unit) {
                setState(() => _recurrenceUnit = unit);
                _updateFirstDate();
              },
              onConstraintToggled: (c) {
                setState(() {
                  if (_selectedConstraints.contains(c)) {
                    _selectedConstraints.remove(c);
                  } else {
                    _selectedConstraints.add(c);
                  }
                });
                _updateFirstDate();
              },
              onStartDateChanged: (d) {
                setState(() => _startDate = d);
                _updateFirstDate();
              },
              onEndDateChanged: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 16),

            // ---- Posting behaviour ----
            _PostingBehaviourSelector(
              selected: _postingBehaviour,
              onChanged: (pb) => setState(() => _postingBehaviour = pb),
            ),
            const SizedBox(height: 16),

            // ---- Transfer fee panel (Transfer type only) ----
            if (_transactionType == 'transfer') ...[
              _FeePanelToggle(
                enabled: _feeEnabled,
                onToggle: (v) => setState(() => _feeEnabled = v),
                feeMode: _feeMode,
                feeAmountController: _feeAmountController,
                onFeeModeChanged: (m) => setState(() => _feeMode = m),
              ),
              const SizedBox(height: 16),
            ],

            // ---- Title / description ----
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds the [RecurringTemplate] and calls [CreateRecurringTemplateUseCase].
  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      final useCaseAsync =
          await ref.read(createRecurringTemplateUseCaseProvider.future);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final startDay = _startDate.millisecondsSinceEpoch ~/ (86400 * 1000);
      final endDay = _endDate != null
          ? _endDate!.millisecondsSinceEpoch ~/ (86400 * 1000)
          : null;
      final amountMinor =
          ((double.parse(_amountController.text)) * 100).round();

      final template = RecurringTemplate(
        id: _uuid.v4(),
        transactionType: _transactionType,
        amountMinor: amountMinor,
        currencyCode: _sourceAccount?.currencyCode ??
            _destinationAccount?.currencyCode ??
            'INR',
        accountSourceId:
            _transactionType == 'income' ? null : _sourceAccount?.id,
        accountDestinationId:
            _transactionType == 'expense' ? null : _destinationAccount?.id,
        categoryId: _category?.id,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recurrenceN: int.parse(_recurrenceNController.text),
        recurrenceUnit: _recurrenceUnit,
        recurrenceConstraints:
            _selectedConstraints.isEmpty ? null : _selectedConstraints.toList(),
        startDate: startDay,
        endDate: endDay,
        postingBehaviour: _postingBehaviour,
        feeMode: _feeEnabled ? _feeMode : null,
        feeAmountMinor: _feeEnabled && _feeMode == FeeMode.flat
            ? (double.tryParse(_feeAmountController.text) ?? 0).round() * 100
            : null,
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCaseAsync(template);

      if (!mounted) return;

      switch (result) {
        case Ok():
          context.pop();
        case Err(:final failure):
          _showError(context, failure);
      }
    } on Object catch (e) {
      dev.log(
        'CreateRecurringTemplateScreen: save error: $e',
        name: 'CreateRecurringTemplateScreen',
      );
      if (mounted) {
        _showError(
          context,
          DatabaseFailure('Unexpected error: $e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction type selector
// ---------------------------------------------------------------------------

/// Segmented button that selects expense / income / transfer.
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'expense', label: Text('Expense')),
        ButtonSegment(value: 'income', label: Text('Income')),
        ButtonSegment(value: 'transfer', label: Text('Transfer')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}

// ---------------------------------------------------------------------------
// Account pickers
// ---------------------------------------------------------------------------

/// Renders source / destination account picker(s) based on [transactionType].
class _AccountPickers extends ConsumerWidget {
  const _AccountPickers({
    required this.transactionType,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  final String transactionType;
  final Account? sourceAccount;
  final Account? destinationAccount;
  final ValueChanged<Account?> onSourceChanged;
  final ValueChanged<Account?> onDestinationChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(activeAccountsProvider);
    final accounts = accountsAsync.value ?? const [];

    return Column(
      children: [
        if (transactionType == 'expense' || transactionType == 'transfer')
          _AccountDropdown(
            label: 'From account',
            selected: sourceAccount,
            accounts: accounts,
            onChanged: onSourceChanged,
          ),
        if (transactionType == 'transfer') const SizedBox(height: 12),
        if (transactionType == 'income' || transactionType == 'transfer')
          _AccountDropdown(
            label: 'To account',
            selected: destinationAccount,
            accounts: accounts,
            onChanged: onDestinationChanged,
          ),
      ],
    );
  }
}

/// A simple account dropdown.
class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.label,
    required this.selected,
    required this.accounts,
    required this.onChanged,
  });

  final String label;
  final Account? selected;
  final List<Account> accounts;
  final ValueChanged<Account?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Use ValueKey(selected?.id) so the field re-creates when selection changes.
    return DropdownButtonFormField<Account>(
      key: ValueKey(selected?.id),
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: accounts
          .map(
            (a) => DropdownMenuItem(
              value: a,
              child: Text(a.name),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Category picker
// ---------------------------------------------------------------------------

/// Simple category dropdown picker.
class _CategoryPicker extends ConsumerWidget {
  const _CategoryPicker({
    required this.selected,
    required this.transactionType,
    required this.onChanged,
  });

  final Category? selected;
  final String transactionType;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.value ?? const [];

    // Filter by tree type based on transaction type.
    final treeType = transactionType == 'income'
        ? CategoryTreeType.income
        : CategoryTreeType.expense;
    final relevant = categories
        .where((c) => c.treeType == treeType && !c.isProtected && !c.isDeleted)
        .toList();

    return DropdownButtonFormField<Category>(
      key: ValueKey(selected?.id),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Category (optional)',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<Category>(
          value: null,
          child: Text('None'),
        ),
        ...relevant.map(
          (c) => DropdownMenuItem(
            value: c,
            child: Text(c.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Recurrence section
// ---------------------------------------------------------------------------

/// Recurrence configuration section: N + unit, constraints, date pickers,
/// and the "First scheduled date" preview.
class _RecurrenceSection extends StatelessWidget {
  const _RecurrenceSection({
    required this.recurrenceNController,
    required this.recurrenceUnit,
    required this.selectedConstraints,
    required this.startDate,
    required this.endDate,
    required this.firstDate,
    required this.firstDateError,
    required this.onUnitChanged,
    required this.onConstraintToggled,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final TextEditingController recurrenceNController;
  final RecurrenceUnit recurrenceUnit;
  final Set<RecurrenceConstraint> selectedConstraints;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? firstDate;
  final String? firstDateError;
  final ValueChanged<RecurrenceUnit> onUnitChanged;
  final ValueChanged<RecurrenceConstraint> onConstraintToggled;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurrence',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // N + unit row.
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: recurrenceNController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Every',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<RecurrenceUnit>(
                    key: ValueKey(recurrenceUnit),
                    initialValue: recurrenceUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: RecurrenceUnit.values
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(u.name),
                          ),
                        )
                        .toList(),
                    onChanged: (u) {
                      if (u != null) onUnitChanged(u);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Constraint chips.
            Wrap(
              spacing: 8,
              children: RecurrenceConstraint.values.map((c) {
                return FilterChip(
                  label: Text(_constraintLabel(c)),
                  selected: selectedConstraints.contains(c),
                  onSelected: (_) => onConstraintToggled(c),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Start date picker.
            _DatePickerRow(
              label: 'Start date',
              date: startDate,
              onChanged: (d) {
                if (d != null) onStartDateChanged(d);
              },
            ),
            const SizedBox(height: 8),

            // End date picker (optional).
            _DatePickerRow(
              label: 'End date (optional)',
              date: endDate,
              onChanged: onEndDateChanged,
              nullable: true,
            ),
            const SizedBox(height: 12),

            // First scheduled date preview.
            _FirstDatePreview(
              firstDate: firstDate,
              error: firstDateError,
            ),
          ],
        ),
      ),
    );
  }

  /// Human-readable label for a [RecurrenceConstraint].
  String _constraintLabel(RecurrenceConstraint c) {
    return switch (c) {
      RecurrenceConstraint.weekdaysOnly => 'Weekdays only',
      RecurrenceConstraint.weekendsOnly => 'Weekends only',
      RecurrenceConstraint.startOfMonth => 'Start of month',
      RecurrenceConstraint.endOfMonth => 'End of month',
      RecurrenceConstraint.startOfYear => 'Start of year',
      RecurrenceConstraint.endOfYear => 'End of year',
    };
  }
}

// ---------------------------------------------------------------------------
// First-date preview widget
// ---------------------------------------------------------------------------

/// Displays the computed first scheduled date or an error message.
class _FirstDatePreview extends StatelessWidget {
  const _FirstDatePreview({this.firstDate, this.error});

  final DateTime? firstDate;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (error != null) {
      return Text(
        'First date: —',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }
    if (firstDate == null) {
      return const SizedBox.shrink();
    }
    final formatted = DateFormat.yMMMd().format(firstDate!);
    return Row(
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          'First scheduled: $formatted',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date picker row
// ---------------------------------------------------------------------------

/// A tappable row that opens a date picker dialog.
class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onChanged,
    this.nullable = false,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;
  final bool nullable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted =
        date != null ? DateFormat.yMMMd().format(date!) : 'Not set';
    return InkWell(
      onTap: () => _pickDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          formatted,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    } else if (nullable && date != null) {
      // Allow clearing the date by picking null when nullable is true.
      // (No-op on cancel; clearing requires a separate clear button — kept
      // simple for V1.)
    }
  }
}

// ---------------------------------------------------------------------------
// Posting behaviour selector
// ---------------------------------------------------------------------------

/// Radio-style selector for Auto-post vs Remind and confirm.
///
/// Uses [RadioGroup] (Flutter 3.32+) to avoid deprecated [RadioListTile]
/// [groupValue] and [onChanged] parameters.
class _PostingBehaviourSelector extends StatelessWidget {
  const _PostingBehaviourSelector({
    required this.selected,
    required this.onChanged,
  });

  final PostingBehaviour selected;
  final ValueChanged<PostingBehaviour> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posting behaviour',
          style: theme.textTheme.titleSmall,
        ),
        RadioGroup<PostingBehaviour>(
          groupValue: selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: const Column(
            children: [
              RadioListTile<PostingBehaviour>(
                title: Text('Auto-post'),
                subtitle: Text('Transaction posted automatically'),
                value: PostingBehaviour.autoPost,
              ),
              RadioListTile<PostingBehaviour>(
                title: Text('Remind and confirm'),
                subtitle: Text('You confirm each occurrence manually'),
                value: PostingBehaviour.remindAndConfirm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Transfer fee panel
// ---------------------------------------------------------------------------

/// Expandable transfer fee panel toggle.
class _FeePanelToggle extends StatelessWidget {
  const _FeePanelToggle({
    required this.enabled,
    required this.onToggle,
    required this.feeMode,
    required this.feeAmountController,
    required this.onFeeModeChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final FeeMode feeMode;
  final TextEditingController feeAmountController;
  final ValueChanged<FeeMode> onFeeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Transfer fee'),
          subtitle: const Text('Include a transfer service fee'),
          value: enabled,
          onChanged: onToggle,
        ),
        if (enabled) ...[
          SegmentedButton<FeeMode>(
            segments: const [
              ButtonSegment(value: FeeMode.flat, label: Text('Flat')),
              ButtonSegment(
                value: FeeMode.percentage,
                label: Text('Percentage'),
              ),
            ],
            selected: {feeMode},
            onSelectionChanged: (s) => onFeeModeChanged(s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: feeAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText:
                  feeMode == FeeMode.flat ? 'Fee amount' : 'Fee percentage',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Save button
// ---------------------------------------------------------------------------

/// Save button shown in the app bar.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: const Text('Save'),
    );
  }
}
