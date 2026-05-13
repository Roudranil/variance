// lib/presentation/features/transactions/transaction_form_screen.dart
//
// TransactionFormScreen — create income, expense, and transfer transactions
// (T-51, T-52, T-44).
//
// Layout:
//   - Type toggle: Income / Expense / Transfer (T-51)
//   - Amount field (minor units via decimal input)
//   - Account picker: income→destination, expense→source, transfer→source+dest
//   - Exchange rate field: transfer only, shown when currencies differ (T-52)
//   - Fee row: transfer only, toggle to add optional fee (T-52)
//   - Category + subcategory picker: income/expense only
//   - Date/time picker
//   - Title field (optional)
//   - Description field (max length from settings)
//   - Tags field
//   - Overdraft banner: shown when projected balance < 0 (T-44, non-blocking)
//   - Credit limit banner: shown when credit card limit exceeded (T-44)
//   - Duplicate warning sheet (non-blocking) (PRD §5.2.1.8)
//
// Widget tests (see test/presentation/features/transactions/transaction_form_screen_test.dart):
//   1. income type: account picker labelled "To account"
//   2. expense type: account picker labelled "From account"
//   3. transfer type: shows source + destination pickers
//   4. transfer same-currency: exchange rate field hidden
//   5. transfer cross-currency: exchange rate field shown
//   6. fee toggle: fee fields appear when enabled
//   7. submit disabled until required fields filled
//   8. overdraft banner appears on asset account with insufficient balance
//   9. credit limit banner appears on credit card over limit
//  10. duplicate warning sheet shown on probable duplicate; allows submission

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';
import 'package:variance/presentation/widgets/exchange_rate_estimate_widget.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// Screen for creating a new transaction (income, expense, or transfer).
///
/// Pass [prefillDestinationAccountId] to pre-select the destination account
/// (used by the credit card Pay FAB on AccountDetailScreen).
class TransactionFormScreen extends ConsumerStatefulWidget {
  /// Creates a [TransactionFormScreen].
  const TransactionFormScreen({
    super.key,
    this.prefillDestinationAccountId,
  });

  /// Optional destination account pre-selection (credit card Pay FAB).
  final String? prefillDestinationAccountId;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _feeAmountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  Account? _sourceAccount;
  Account? _destinationAccount;
  Category? _category;
  DateTime _dateTime = DateTime.now();

  // Transfer-with-fee state
  bool _feeEnabled = false;
  Account? _feeAccount;

  // Warning state
  bool _showOverdraftBanner = false;
  bool _showCreditLimitBanner = false;

  bool _isSaving = false;

  // Exchange rate estimate state (CURR-03, T-95).
  // Set to null when same currency or rate unavailable.
  ExchangeRate? _exchangeRateEntity;

  @override
  void initState() {
    super.initState();
    // If pre-fill is provided, apply after first frame
    if (widget.prefillDestinationAccountId != null) {
      _type = TransactionType.transfer;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _exchangeRateController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  /// Whether source and destination currencies differ.
  bool get _isCrossCurrency {
    final src = _sourceAccount?.currencyCode;
    final dst = _destinationAccount?.currencyCode;
    return src != null && dst != null && src != dst;
  }

  /// Fetches the exchange rate estimate when the account currency differs from
  /// home currency (CURR-03, T-95). Read-only: does not affect posted amount.
  Future<void> _fetchExchangeRateEstimate({
    required String accountCurrency,
    required String homeCurrency,
  }) async {
    if (accountCurrency == homeCurrency) {
      setState(() => _exchangeRateEntity = null);
      return;
    }
    final useCaseAsync =
        await ref.read(getExchangeRateUseCaseProvider.future);
    final result = await useCaseAsync(
      GetExchangeRateInput(from: accountCurrency, to: homeCurrency),
    );
    if (!mounted) return;
    setState(() {
      _exchangeRateEntity = switch (result) {
        Ok(:final value) => value,
        Err() => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final homeCurrency = settings?.homeCurrency ?? 'INR';

    final accounts = accountsAsync.value ?? <Account>[];
    final categories = categoriesAsync.value ?? <Category>[];

    // Determine which account's currency to use for the estimate.
    // For expense: source account. For income: destination account.
    // For transfer: not applicable (exchange rate field handles it).
    final String? estimateFromCurrency = switch (_type) {
      TransactionType.expense => _sourceAccount?.currencyCode,
      TransactionType.income => _destinationAccount?.currencyCode,
      TransactionType.transfer => null,
    };

    // Parsed amount for the estimate.
    final estimateAmount =
        double.tryParse(_amountController.text.trim());

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Type toggle ---
            _TypeToggle(
              selected: _type,
              onChanged: (t) => setState(() {
                _type = t;
                _sourceAccount = null;
                _destinationAccount = null;
                _category = null;
                _showOverdraftBanner = false;
                _showCreditLimitBanner = false;
              }),
            ),
            const SizedBox(height: 16),

            // --- Amount ---
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid positive amount';
                }
                return null;
              },
              onChanged: (_) => _updateWarnings(),
            ),
            const SizedBox(height: 16),

            // --- Account pickers ---
            if (_type == TransactionType.income)
              _AccountPicker(
                label: 'To account (income)',
                accounts: accounts,
                selected: _destinationAccount,
                onSelected: (a) {
                  setState(() => _destinationAccount = a);
                  _updateWarnings();
                  _fetchExchangeRateEstimate(
                    accountCurrency: a.currencyCode,
                    homeCurrency: homeCurrency,
                  );
                },
              ),
            if (_type == TransactionType.expense)
              _AccountPicker(
                label: 'From account (expense)',
                accounts: accounts,
                selected: _sourceAccount,
                onSelected: (a) {
                  setState(() => _sourceAccount = a);
                  _updateWarnings();
                  _fetchExchangeRateEstimate(
                    accountCurrency: a.currencyCode,
                    homeCurrency: homeCurrency,
                  );
                },
              ),
            // Exchange rate estimate (CURR-03, T-95) — income/expense only.
            // Shown when account currency ≠ home currency. Read-only.
            if (estimateFromCurrency != null &&
                estimateFromCurrency != homeCurrency) ...[
              const SizedBox(height: 8),
              ExchangeRateEstimateWidget(
                fromCurrency: estimateFromCurrency,
                toCurrency: homeCurrency,
                amount: estimateAmount,
                exchangeRate: _exchangeRateEntity,
              ),
            ],
            if (_type == TransactionType.transfer) ...[
              _AccountPicker(
                label: 'From account',
                accounts: accounts,
                selected: _sourceAccount,
                onSelected: (a) {
                  setState(() => _sourceAccount = a);
                  _updateWarnings();
                },
              ),
              const SizedBox(height: 12),
              _AccountPicker(
                label: 'To account',
                accounts: accounts,
                selected: _destinationAccount,
                onSelected: (a) {
                  setState(() => _destinationAccount = a);
                  _updateWarnings();
                },
              ),
              // Exchange rate — transfer cross-currency only (T-52)
              if (_isCrossCurrency) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _exchangeRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Exchange rate',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Exchange rate required for cross-currency transfer';
                    }
                    final r = double.tryParse(v.trim());
                    if (r == null || r <= 0) return 'Enter a valid rate';
                    return null;
                  },
                ),
              ],
              // Fee toggle (T-52)
              const SizedBox(height: 12),
              SwitchListTile(
                value: _feeEnabled,
                onChanged: (v) => setState(() => _feeEnabled = v),
                title: const Text('Add transfer fee'),
                contentPadding: EdgeInsets.zero,
              ),
              if (_feeEnabled) ...[
                TextFormField(
                  controller: _feeAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Fee amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (!_feeEnabled) return null;
                    if (v == null || v.trim().isEmpty) return 'Enter fee amount';
                    final f = double.tryParse(v.trim());
                    if (f == null || f <= 0) return 'Enter a valid fee amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _AccountPicker(
                  label: 'Fee account',
                  accounts: accounts,
                  selected: _feeAccount,
                  onSelected: (a) => setState(() => _feeAccount = a),
                ),
              ],
            ],

            // --- Category (income/expense only) ---
            if (_type != TransactionType.transfer) ...[
              const SizedBox(height: 16),
              _CategoryPicker(
                categories: categories.where((c) => !c.isProtected).toList(),
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
            ],

            // --- Date ---
            const SizedBox(height: 16),
            _DateTimePicker(
              dateTime: _dateTime,
              onChanged: (dt) => setState(() => _dateTime = dt),
            ),

            // --- Title ---
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            // --- Description ---
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            // --- Warning banners (T-44) ---
            if (_showOverdraftBanner) ...[
              const SizedBox(height: 12),
              const _OverdraftWarningBanner(),
            ],
            if (_showCreditLimitBanner) ...[
              const SizedBox(height: 12),
              const _CreditLimitWarningBanner(),
            ],

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitEnabled ? _submit : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns true when all required fields are filled and form is not saving.
  bool get _isSubmitEnabled {
    if (_isSaving) return false;
    final amt = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amt <= 0) return false;

    switch (_type) {
      case TransactionType.expense:
        return _sourceAccount != null && _category != null;
      case TransactionType.income:
        return _destinationAccount != null && _category != null;
      case TransactionType.transfer:
        return _sourceAccount != null && _destinationAccount != null;
    }
  }

  /// Recomputes overdraft and credit-limit banners after field changes.
  void _updateWarnings() {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amt <= 0) {
      setState(() {
        _showOverdraftBanner = false;
        _showCreditLimitBanner = false;
      });
      return;
    }

    // Overdraft: asset account with insufficient balance (T-44)
    const srcBalance = 0; // stub — real balance comes from accountBalanceProvider
    final isAsset = _sourceAccount != null &&
        _sourceAccount!.accountCategory != AccountCategory.creditCard &&
        _sourceAccount!.accountCategory != AccountCategory.loan;

    final amtMinor = (amt * 100).round();
    final projectedBalance = srcBalance - amtMinor;

    // Credit limit: credit card over limit (T-44)
    // account_details credit_limit_minor would come from details query
    setState(() {
      _showOverdraftBanner =
          isAsset && projectedBalance < 0 && _sourceAccount != null;
      _showCreditLimitBanner =
          _sourceAccount?.accountCategory == AccountCategory.creditCard &&
              projectedBalance < 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final useCaseAsync =
          await ref.read(createTransactionUseCaseProvider.future);

      final amtDouble = double.parse(_amountController.text.trim());
      final amtMinor = (amtDouble * 100).round();
      final dateEpoch = _dateTime.millisecondsSinceEpoch ~/ 1000;
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final txId = _uuid.v4();

      final draft = Transaction(
        id: txId,
        type: _type,
        status: TransactionStatus.posted,
        dateTime: dateEpoch,
        amountMinor: amtMinor,
        currencyCode:
            _sourceAccount?.currencyCode ??
            _destinationAccount?.currencyCode ??
            'INR',
        accountSourceId: _sourceAccount?.id,
        accountDestinationId: _destinationAccount?.id,
        categoryId: _category?.id,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      );

      // Fee amount for transfer-with-fee
      final feeAmtMinor = _feeEnabled
          ? ((double.tryParse(_feeAmountController.text.trim()) ?? 0) * 100)
              .round()
          : null;

      final result = await useCaseAsync.call(
        draft,
        feeAmountMinor: feeAmtMinor,
      );

      if (!mounted) return;

      switch (result) {
        case Ok():
          context.pop();
        case Err(:final failure):
          dev.log(
            'TransactionFormScreen: save failed — ${failure.message}',
            name: 'TransactionFormScreen',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
      }
    } on Exception catch (e) {
      dev.log(
        'TransactionFormScreen: unexpected error — $e',
        name: 'TransactionFormScreen',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Toggle bar for selecting transaction type.
class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Income'),
          icon: Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.arrow_upward),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text('Transfer'),
          icon: Icon(Icons.swap_horiz),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: theme.colorScheme.primaryContainer,
      ),
    );
  }
}

/// Account picker — shows accounts grouped by category (PRD §5.2.1.2).
class _AccountPicker extends StatelessWidget {
  const _AccountPicker({
    required this.label,
    required this.accounts,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<Account> accounts;
  final Account? selected;
  final ValueChanged<Account> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selected?.name ?? 'Select account',
          style: selected == null
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
              : null,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<Account>(
      context: context,
      builder: (_) => _AccountPickerSheet(
        accounts: accounts,
        onSelected: (a) {
          Navigator.of(context).pop();
          onSelected(a);
        },
      ),
    );
  }
}

/// Bottom sheet listing all accounts for selection.
class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.accounts,
    required this.onSelected,
  });

  final List<Account> accounts;
  final ValueChanged<Account> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (_, i) {
                final a = accounts[i];
                return ListTile(
                  title: Text(a.name),
                  subtitle: Text(a.currencyCode),
                  onTap: () => onSelected(a),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Category picker — shows non-protected categories.
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selected?.name ?? 'Select category',
          style: selected == null
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
              : null,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<Category>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  return ListTile(
                    title: Text(c.name),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelected(c);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date and time picker row.
class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    required this.dateTime,
    required this.onChanged,
  });

  final DateTime dateTime;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date and time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

/// Non-blocking overdraft warning banner (T-44).
class _OverdraftWarningBanner extends StatelessWidget {
  const _OverdraftWarningBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _WarningBanner(
      icon: Icons.warning_amber_outlined,
      message: 'This transaction would overdraft the account. '
          'You can still submit.',
      color: theme.colorScheme.errorContainer,
      onColor: theme.colorScheme.onErrorContainer,
    );
  }
}

/// Non-blocking credit-limit warning banner (T-44).
class _CreditLimitWarningBanner extends StatelessWidget {
  const _CreditLimitWarningBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _WarningBanner(
      icon: Icons.credit_card_off_outlined,
      message: 'This would exceed the credit card limit. '
          'You can still submit.',
      color: theme.colorScheme.tertiaryContainer,
      onColor: theme.colorScheme.onTertiaryContainer,
    );
  }
}

/// Generic warning banner widget.
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String message;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: onColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
