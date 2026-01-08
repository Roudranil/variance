import 'package:flutter/material.dart';

import 'package:drift/drift.dart' show Value;
import 'package:provider/provider.dart';

import 'package:variance/core/utils/logger.dart';
import 'package:variance/core/widgets/currency_picker.dart';
import 'package:variance/core/widgets/themed_edit_scaffold.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Screen for editing or adding an account.
///
/// If [account] is provided, the screen is in edit mode.
/// If [accountType] is provided, the screen is in add mode for that type.
class AccountEditScreen extends StatefulWidget {
  /// Creates a new instance of [AccountEditScreen].
  ///
  /// Provide either [account] for edit mode or [accountType] for add mode.
  const AccountEditScreen({this.account, this.accountType, super.key})
    : assert(
        account != null || accountType != null,
        'Either account or accountType must be provided',
      );

  /// The account to edit. Null for add mode.
  final Account? account;

  /// The type of account to add. Null for edit mode.
  final AccountType? accountType;

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // form fields
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _currencyCode;
  late double _initialBalance;
  late bool _includeInTotals;
  Color? _color;

  // type-specific fields
  int? _statementDay;
  int? _paymentDueDay;
  double? _creditLimit;
  double? _interestRate;
  double? _principal;
  double? _installmentAmount;
  DateTime? _nextDueDate;
  DateTime? _maturityDate;

  bool get _isEditMode => widget.account != null;
  AccountType get _accountType => widget.account?.type ?? widget.accountType!;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final account = widget.account;

    _nameController = TextEditingController(text: account?.name ?? '');
    _descriptionController = TextEditingController(
      text: account?.description ?? '',
    );
    _currencyCode = account?.currencyCode ?? 'INR';
    _initialBalance = 0.0; // balance is computed, not stored
    _includeInTotals = account?.includeInTotals ?? true;
    _color = account?.color != null ? Color(account!.color!) : null;

    // type-specific
    _statementDay = account?.statementDay;
    _paymentDueDay = account?.paymentDueDay;
    _creditLimit = account?.creditLimit;
    _interestRate = account?.interestRate;
    _principal = account?.principal;
    _installmentAmount = account?.installmentAmount;
    _nextDueDate = account?.nextDueDate;
    _maturityDate = account?.maturityDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedEditScaffold(
      seedColor: _color,
      appBarBuilder: (colorScheme) => AppBar(
        leading: const BackButton(),
        title: Text(
          _isEditMode ? 'Edit Account' : 'Add ${_typeLabel(_accountType)}',
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Account',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      bodyBuilder: (colorScheme) => Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // color and name row
            _buildColorNameRow(colorScheme),
            const SizedBox(height: 24),

            // currency and balance row
            _buildCurrencyBalanceRow(colorScheme),
            const SizedBox(height: 24),

            // description row
            _buildDescriptionRow(colorScheme),
            const SizedBox(height: 24),

            // common metadata
            _buildCommonMetadata(colorScheme),

            // type-specific metadata
            ..._buildTypeSpecificFields(colorScheme),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBarBuilder: (colorScheme) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(_isEditMode ? 'Save Changes' : 'Create Account'),
          ),
        ),
      ),
    );
  }

  /// Builds the color circle and name field row.
  Widget _buildColorNameRow(ColorScheme colorScheme) {
    return Row(
      children: [
        // color selector
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _color ?? colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline.withAlpha(77),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: _color != null
                  ? (_color!.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // name field
        Expanded(
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Builds the description field row.
  Widget _buildDescriptionRow(ColorScheme colorScheme) {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// Builds the currency picker and balance display row.
  Widget _buildCurrencyBalanceRow(ColorScheme colorScheme) {
    return Row(
      children: [
        // currency picker
        OutlinedButton.icon(
          onPressed: () => _showCurrencyPicker(colorScheme),
          icon: const Icon(Icons.currency_exchange),
          label: Text(_currencyCode),
        ),
        const SizedBox(width: 16),
        // balance display (read-only, computed)
        Expanded(
          child: _isEditMode
              ? _buildBalanceDisplay(colorScheme)
              : TextFormField(
                  initialValue: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _initialBalance = double.tryParse(value) ?? 0;
                  },
                ),
        ),
      ],
    );
  }

  /// Builds the balance display for edit mode.
  Widget _buildBalanceDisplay(ColorScheme colorScheme) {
    final db = Provider.of<AppDatabase>(context);

    return FutureBuilder<double>(
      future: db.accountRepository.getAccountBalance(widget.account!.id),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              Text(
                '$_currencyCode ${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds common metadata fields.
  Widget _buildCommonMetadata(ColorScheme colorScheme) {
    return Card(
      child: SwitchListTile(
        title: const Text('Include in Totals'),
        subtitle: const Text('Count this account in net worth'),
        value: _includeInTotals,
        onChanged: (value) => setState(() => _includeInTotals = value),
      ),
    );
  }

  /// Builds type-specific metadata fields.
  List<Widget> _buildTypeSpecificFields(ColorScheme colorScheme) {
    return switch (_accountType) {
      AccountType.creditCard => _buildCreditCardFields(colorScheme),
      AccountType.loan => _buildLoanFields(colorScheme),
      AccountType.savings => _buildSavingsFields(colorScheme),
      _ => [],
    };
  }

  List<Widget> _buildCreditCardFields(ColorScheme colorScheme) {
    return [
      const SizedBox(height: 16),
      Text(
        'Credit Card Details',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _statementDay?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Statement Day',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _statementDay = int.tryParse(v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: _paymentDueDay?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Due Day',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _paymentDueDay = int.tryParse(v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: _creditLimit?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Credit Limit',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => _creditLimit = double.tryParse(v),
      ),
    ];
  }

  List<Widget> _buildLoanFields(ColorScheme colorScheme) {
    return [
      const SizedBox(height: 16),
      Text('Loan Details', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _interestRate?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _interestRate = double.tryParse(v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: _principal?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Principal',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _principal = double.tryParse(v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: _installmentAmount?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Monthly Installment (EMI)',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => _installmentAmount = double.tryParse(v),
      ),
    ];
  }

  List<Widget> _buildSavingsFields(ColorScheme colorScheme) {
    return [
      const SizedBox(height: 16),
      Text('Savings Details', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: _interestRate?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Interest Rate (%)',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => _interestRate = double.tryParse(v),
      ),
    ];
  }

  /// Shows the color picker bottom sheet.
  void _showColorPicker() {
    final theme = Theme.of(context);
    final accents = getCatppuccinAccents(theme.brightness);

    showModalBottomSheet<Color?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Color', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                // app default option
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: const Text('Same as App'),
                  onTap: () => Navigator.pop(context, null),
                ),
                const Divider(),
                // catppuccin accents
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: accents.map((accent) {
                    final (name, color) = accent;
                    return Tooltip(
                      message: name,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, color),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _color == color
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ).then((selectedColor) {
      if (mounted) {
        setState(() => _color = selectedColor);
      }
    });
  }

  /// Shows the currency picker.
  Future<void> _showCurrencyPicker(ColorScheme colorScheme) async {
    final selectedCode = await CurrencyPickerSheet.show(
      context,
      _currencyCode,
      colorScheme: colorScheme,
    );
    if (selectedCode != null) {
      setState(() => _currencyCode = selectedCode);
    }
  }

  /// Confirms and executes account deletion.
  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will soft-delete the account. It can only be deleted if the balance is zero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && mounted) {
        await _deleteAccount();
      }
    });
  }

  Future<void> _deleteAccount() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final account = widget.account!;

    final canDelete = await db.accountRepository.canSoftDelete(account.id);
    if (!canDelete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete account with non-zero balance'),
          ),
        );
      }
      return;
    }

    await db.accountRepository.softDeleteAccount(account.id);
    VarianceLogger.info('Deleted account: ${account.name}');

    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Saves the account (create or update).
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = Provider.of<AppDatabase>(context, listen: false);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isEditMode) {
      await _updateAccount(db, name, description);
    } else {
      await _createAccount(db, name, description);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Updates an existing account with the current form values.
  ///
  /// Parameters:
  /// - [db]: The database instance.
  /// - [name]: The updated account name.
  Future<void> _updateAccount(
    AppDatabase db,
    String name,
    String description,
  ) async {
    final account = widget.account!;

    // construct updated account object with new values
    final updatedAccount = account.copyWith(
      name: name,
      currencyCode: _currencyCode,
      includeInTotals: _includeInTotals,
      color: Value(_color?.toARGB32()),
      statementDay: Value(_statementDay),
      paymentDueDay: Value(_paymentDueDay),
      creditLimit: Value(_creditLimit),
      interestRate: Value(_interestRate),
      principal: Value(_principal),
      installmentAmount: Value(_installmentAmount),
      nextDueDate: Value(_nextDueDate),
      maturityDate: Value(_maturityDate),
      description: Value(description),
    );

    await db.accountRepository.updateAccount(updatedAccount);
    VarianceLogger.info('Updated account: id=${account.id}, name=$name');
  }

  Future<void> _createAccount(
    AppDatabase db,
    String name,
    String description,
  ) async {
    await db.accountRepository.createAccount(
      name: name,
      type: _accountType,
      nature: _natureFromType(_accountType),
      initialBalance: _initialBalance,
      currencyCode: _currencyCode,
      includeInTotals: _includeInTotals,
      statementDay: _statementDay,
      paymentDueDay: _paymentDueDay,
      creditLimit: _creditLimit,
      interestRate: _interestRate,
      principal: _principal,
      installmentAmount: _installmentAmount,
      nextDueDate: _nextDueDate,
      maturityDate: _maturityDate,
      color: _color?.toARGB32(),
      description: description,
    );

    VarianceLogger.info('Created account: $name (${_accountType.name})');
  }

  String _typeLabel(AccountType type) {
    return switch (type) {
      AccountType.cash => 'Cash',
      AccountType.savings => 'Savings',
      AccountType.bankAccount => 'Bank Account',
      AccountType.creditCard => 'Credit Card',
      AccountType.loan => 'Loan',
      AccountType.investment => 'Investment',
      AccountType.insurance => 'Insurance',
      AccountType.wallet => 'Wallet',
    };
  }

  /// Derives the accounting nature from an account type.
  ///
  /// - Assets: cash, savings, bank, wallet, investment, insurance
  /// - Liabilities: credit card, loan
  AccountNature _natureFromType(AccountType type) {
    return switch (type) {
      AccountType.cash => AccountNature.asset,
      AccountType.savings => AccountNature.asset,
      AccountType.bankAccount => AccountNature.asset,
      AccountType.wallet => AccountNature.asset,
      AccountType.investment => AccountNature.asset,
      AccountType.insurance => AccountNature.asset,
      AccountType.creditCard => AccountNature.liability,
      AccountType.loan => AccountNature.liability,
    };
  }
}
