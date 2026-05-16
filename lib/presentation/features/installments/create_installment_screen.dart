// lib/presentation/features/installments/create_installment_screen.dart
//
// CreateInstallmentScreen — create a new installment plan.
//
// Route: /settings/installments/new (modal-slide-up transition)
// UI Spec: §6.4, §6.4.1, §6.4.2
// UX Flows: §7.4, §7.4.1, §7.17
// Input Fields: §5.1 Template Creation
//
// Layout:
//   - Transaction type selector: Expense / Income / Transfer
//   - Total amount field (required, displayHeroAmount style)
//   - Number of installments field (required, numeric)
//   - Per-installment amount (auto-calculated, overridable, bodyLarge)
//   - End date display (read-only, bodyMedium, onSurfaceVariant)
//   - Account pickers (source + destination for transfer)
//   - Category / subcategory picker (expense/income only)
//   - Recurrence section: N + unit + start date
//   - Transfer fee panel (Transfer type only; optional)
//   - Mismatch warning card (when per-installment sum ≠ total; non-blocking)
//   - Save button
//
// States (UI Spec §6.4.2):
//   empty   → blank fields, Save disabled
//   filled  → end date computed, Save enabled
//   mismatch → warning card above Save; Save still enabled (non-blocking)
//   saving  → loading on Save
//   saved   → modal dismissed, Snackbar "Installment plan saved"
//
// Test cases:
// (see test/presentation/features/installments/create_installment_screen_test.dart)
//   1. Golden: empty state — Save disabled.
//   2. Golden: filled state (expense type).
//   3. Golden: transfer-with-fee state.
//   4. Golden: mismatch warning visible.
//   5. Type switch shows/hides account and category fields.
//   6. End date updates when count or recurrence changes.
//   7. Mismatch warning appears when per-installment override causes sum ≠ total.
//   8. Save calls CreateInstallmentPlanUseCase and shows snackbar on success.
//   9. Save shows error snackbar on failure; form state preserved.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/services/period_calculator.dart';
import 'package:variance/domain/usecases/installment/create_installment_plan_use_case.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Full-screen modal for creating a new installment plan.
///
/// Collects all required fields and delegates to [CreateInstallmentPlanUseCase]
/// on save. Dismisses on success and shows a snackbar.
class CreateInstallmentScreen extends ConsumerStatefulWidget {
  /// Creates a [CreateInstallmentScreen].
  const CreateInstallmentScreen({super.key});

  @override
  ConsumerState<CreateInstallmentScreen> createState() =>
      _CreateInstallmentScreenState();
}

class _CreateInstallmentScreenState
    extends ConsumerState<CreateInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---- Controllers ----
  final _totalAmountController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _perInstallmentController = TextEditingController();
  final _recurrenceNController = TextEditingController(text: '1');
  final _feeAmountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ---- Transaction type ----
  String _transactionType = 'expense';

  // ---- Account / category ----
  Account? _sourceAccount;
  Account? _destinationAccount;
  Category? _category;

  // ---- Recurrence ----
  RecurrenceUnit _recurrenceUnit = RecurrenceUnit.month;

  // ---- Start date (for end date computation) ----
  DateTime _startDate = DateTime.now();

  // ---- Computed end date (read-only display) ----
  DateTime? _endDate;

  // ---- Per-installment override state ----
  /// True when the user has manually edited the per-installment field.
  bool _perInstallmentOverridden = false;

  // ---- Mismatch detection ----
  bool _hasMismatch = false;

  // ---- Transfer fee ----
  bool _feeEnabled = false;
  FeeMode _feeMode = FeeMode.flat;

  // ---- Saving state ----
  bool _isSaving = false;

  static const _periodCalculator = PeriodCalculator();
  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_onFormChanged);
    _installmentCountController.addListener(_onFormChanged);
    _perInstallmentController.addListener(_onPerInstallmentChanged);
    _recurrenceNController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _installmentCountController.dispose();
    _perInstallmentController.dispose();
    _recurrenceNController.dispose();
    _feeAmountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Reactive computation
  // ---------------------------------------------------------------------------

  /// Called whenever any form field changes. Recomputes end date and mismatch.
  void _onFormChanged() {
    _recomputeEndDate();
    if (!_perInstallmentOverridden) {
      _autoFillPerInstallment();
    }
    _recomputeMismatch();
    setState(() {});
  }

  /// Called when the per-installment field changes (user-initiated).
  void _onPerInstallmentChanged() {
    _perInstallmentOverridden = true;
    _recomputeMismatch();
    setState(() {});
  }

  /// Recomputes the end date from current form fields using [PeriodCalculator].
  ///
  /// end_date = start_date + (numberOfInstallments × recurrence_period), O(1).
  void _recomputeEndDate() {
    final count = int.tryParse(_installmentCountController.text);
    final n = int.tryParse(_recurrenceNController.text);
    if (count == null || count <= 0 || n == null || n <= 0) {
      _endDate = null;
      return;
    }

    final startEpochSeconds =
        _startDate.millisecondsSinceEpoch ~/ 1000;

    // Use fixed arithmetic for day/week; PeriodCalculator for month/year.
    final endEpochSeconds = switch (_recurrenceUnit) {
      RecurrenceUnit.day =>
        startEpochSeconds + (count * n * 86400),
      RecurrenceUnit.week =>
        startEpochSeconds + (count * n * 7 * 86400),
      RecurrenceUnit.month || RecurrenceUnit.year => _computeVariableEnd(
          startEpochSeconds: startEpochSeconds,
          recurrenceN: n,
          recurrenceUnit: _recurrenceUnit,
          numberOfInstallments: count,
        ),
    };

    _endDate = DateTime.fromMillisecondsSinceEpoch(
      endEpochSeconds * 1000,
      isUtc: false,
    );
  }

  int _computeVariableEnd({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int numberOfInstallments,
  }) {
    final avgSecondsPerPeriod = switch (recurrenceUnit) {
      RecurrenceUnit.month => recurrenceN * 30 * 86400,
      RecurrenceUnit.year => recurrenceN * 365 * 86400,
      _ => throw StateError('Only month/year handled here'),
    };
    final referenceEpoch = startEpochSeconds +
        ((numberOfInstallments - 1) * avgSecondsPerPeriod) +
        (avgSecondsPerPeriod ~/ 2);

    final range = _periodCalculator.compute(
      startEpochSeconds: startEpochSeconds,
      recurrenceN: recurrenceN,
      recurrenceUnit: recurrenceUnit,
      referenceEpochSeconds: referenceEpoch,
    );
    return range.endEpochSeconds;
  }

  /// Auto-fills the per-installment field when not overridden.
  void _autoFillPerInstallment() {
    final total = double.tryParse(_totalAmountController.text);
    final count = int.tryParse(_installmentCountController.text);
    if (total == null || total <= 0 || count == null || count <= 0) return;

    final perMinor = (total * 100).round() ~/ count;
    final perAmount = (perMinor / 100);
    _perInstallmentController.removeListener(_onPerInstallmentChanged);
    _perInstallmentController.text =
        perAmount.toStringAsFixed(2);
    _perInstallmentController.addListener(_onPerInstallmentChanged);
    _perInstallmentOverridden = false;
  }

  /// Recomputes the mismatch flag.
  ///
  /// hasMismatch = (numberOfInstallments × perInstallmentAmount) ≠ totalAmount
  void _recomputeMismatch() {
    if (!_perInstallmentOverridden) {
      _hasMismatch = false;
      return;
    }
    final total = double.tryParse(_totalAmountController.text);
    final count = int.tryParse(_installmentCountController.text);
    final perAmount = double.tryParse(_perInstallmentController.text);
    if (total == null || count == null || perAmount == null) {
      _hasMismatch = false;
      return;
    }
    final totalMinor = (total * 100).round();
    final projectedMinor = (perAmount * 100).round() * count;
    _hasMismatch = projectedMinor != totalMinor;
  }

  // ---------------------------------------------------------------------------
  // Save guard
  // ---------------------------------------------------------------------------

  bool get _canSave {
    if (_isSaving) return false;
    final total = double.tryParse(_totalAmountController.text);
    if (total == null || total <= 0) return false;
    final count = int.tryParse(_installmentCountController.text);
    if (count == null || count <= 0) return false;
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Installment Plan'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Transaction type selector ----
              _TypeSelector(
                selected: _transactionType,
                onChanged: (type) {
                  setState(() {
                    _transactionType = type;
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

              // ---- Total amount field ----
              TextFormField(
                controller: _totalAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: theme.textTheme.displaySmall,
                decoration: const InputDecoration(
                  labelText: 'Total amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                  helperText: 'The target total for this installment plan',
                ),
                validator: (v) {
                  final amt = double.tryParse(v ?? '');
                  if (amt == null || amt <= 0) {
                    return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Number of installments field ----
              TextFormField(
                controller: _installmentCountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Number of installments',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'Enter a valid count greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Per-installment amount (auto-calculated, overridable) ----
              TextFormField(
                controller: _perInstallmentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Per-installment amount',
                  border: OutlineInputBorder(),
                  helperText: 'Auto: total ÷ count',
                  prefixIcon: Icon(Icons.calculate_outlined),
                ),
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
              _InstallmentRecurrenceSection(
                recurrenceNController: _recurrenceNController,
                recurrenceUnit: _recurrenceUnit,
                startDate: _startDate,
                onUnitChanged: (unit) {
                  setState(() => _recurrenceUnit = unit);
                  _onFormChanged();
                },
                onStartDateChanged: (d) {
                  setState(() => _startDate = d);
                  _onFormChanged();
                },
              ),
              const SizedBox(height: 12),

              // ---- End date read-only display ----
              _EndDateDisplay(endDate: _endDate),
              const SizedBox(height: 16),

              // ---- Transfer fee panel ----
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

              // ---- Title / description (optional) ----
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
              const SizedBox(height: 16),

              // ---- Mismatch warning card (non-blocking) ----
              if (_hasMismatch) ...[
                _MismatchWarningCard(
                  totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
                  count: int.tryParse(_installmentCountController.text) ?? 0,
                  perAmount: double.tryParse(_perInstallmentController.text) ?? 0,
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save handler
  // ---------------------------------------------------------------------------

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      final useCase =
          await ref.read(createInstallmentPlanUseCaseProvider.future);

      final totalMinor =
          (double.parse(_totalAmountController.text) * 100).round();
      final count = int.parse(_installmentCountController.text);
      final n = int.parse(_recurrenceNController.text);
      final startDay = _startDate.millisecondsSinceEpoch ~/ (86400 * 1000);

      // Build optional per-installment overrides.
      List<int>? overrides;
      if (_perInstallmentOverridden) {
        final perAmount =
            double.tryParse(_perInstallmentController.text) ?? 0;
        final perMinor = (perAmount * 100).round();
        // All occurrences use the same override amount; the last gets the
        // remainder relative to totalMinor. The use case handles distribution.
        overrides = List.filled(count, perMinor);
      }

      final currencyCode = _sourceAccount?.currencyCode ??
          _destinationAccount?.currencyCode ??
          'INR';

      final input = CreateInstallmentPlanInput(
        transactionType: _transactionType,
        totalConfiguredMinor: totalMinor,
        numberOfInstallments: count,
        startDate: startDay,
        recurrenceN: n,
        recurrenceUnit: _recurrenceUnit,
        currencyCode: currencyCode,
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
        feeMode: _feeEnabled ? _feeMode : null,
        feeAmountMinor: _feeEnabled && _feeMode == FeeMode.flat
            ? ((double.tryParse(_feeAmountController.text) ?? 0) * 100).round()
            : null,
        feeCategoryId: null,
        perInstallmentAmountsMinor: overrides,
      );

      final result = await useCase(input);

      if (!mounted) return;

      switch (result) {
        case Ok():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Installment plan saved')),
          );
          Navigator.of(context).maybePop();
        case Err(:final failure):
          _showError(failure);
      }
    } on Object catch (e) {
      dev.log(
        'CreateInstallmentScreen: save error: $e',
        name: 'CreateInstallmentScreen',
      );
      if (mounted) {
        _showError(DatabaseFailure('Unexpected error: $e'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    );
  }
}

// ---------------------------------------------------------------------------
// Save button widget
// ---------------------------------------------------------------------------

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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: enabled ? onPressed : null,
              child: const Text('Save'),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction type selector
// ---------------------------------------------------------------------------

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
    final accounts = ref.watch(activeAccountsProvider).value ?? const [];

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
    final categories = ref.watch(categoryListProvider).value ?? const [];
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
          (c) => DropdownMenuItem(value: c, child: Text(c.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Installment-specific recurrence section (simplified — no end date picker)
// ---------------------------------------------------------------------------

/// Recurrence section for installment templates.
///
/// Shows N + unit and start date only; end date is computed and read-only.
class _InstallmentRecurrenceSection extends StatelessWidget {
  const _InstallmentRecurrenceSection({
    required this.recurrenceNController,
    required this.recurrenceUnit,
    required this.startDate,
    required this.onUnitChanged,
    required this.onStartDateChanged,
  });

  final TextEditingController recurrenceNController;
  final RecurrenceUnit recurrenceUnit;
  final DateTime startDate;
  final ValueChanged<RecurrenceUnit> onUnitChanged;
  final ValueChanged<DateTime> onStartDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recurrence', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            // N + unit row.
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: recurrenceNController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

            // Start date picker.
            _DatePickerRow(
              label: 'Start date',
              date: startDate,
              onChanged: (d) {
                if (d != null) onStartDateChanged(d);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// End date read-only display
// ---------------------------------------------------------------------------

/// Displays the computed end date or a placeholder when not yet computable.
class _EndDateDisplay extends StatelessWidget {
  const _EndDateDisplay({this.endDate});

  final DateTime? endDate;

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = endDate != null
        ? 'Ends: ${_dateFmt.format(endDate!)}'
        : 'Ends: —';

    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date picker row
// ---------------------------------------------------------------------------

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

  static final _fmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: Text(
            date != null ? _fmt.format(date!) : 'Select',
          ),
        ),
        if (nullable && date != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => onChanged(null),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fee panel toggle
// ---------------------------------------------------------------------------

/// Optional transfer fee panel.
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
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Transfer fee'),
              value: enabled,
              onChanged: onToggle,
              contentPadding: EdgeInsets.zero,
            ),
            if (enabled) ...[
              const SizedBox(height: 8),
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
                  labelText: feeMode == FeeMode.flat
                      ? 'Fee amount'
                      : 'Fee percentage (%)',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mismatch warning card
// ---------------------------------------------------------------------------

/// Displays a non-blocking warning when per-installment amounts sum ≠ total.
///
/// Save remains enabled despite the mismatch (PRD §5.2.8.1).
class _MismatchWarningCard extends StatelessWidget {
  const _MismatchWarningCard({
    required this.totalAmount,
    required this.count,
    required this.perAmount,
  });

  final double totalAmount;
  final int count;
  final double perAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projected = perAmount * count;

    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Projected total (${projected.toStringAsFixed(2)}) '
                'does not match configured total '
                '(${totalAmount.toStringAsFixed(2)}). '
                'You can still save — the mismatch will be recorded.',
                style: theme.textTheme.bodySmall?.copyWith(
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
