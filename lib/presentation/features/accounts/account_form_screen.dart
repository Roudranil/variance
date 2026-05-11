// lib/presentation/features/accounts/account_form_screen.dart
//
// AccountFormScreen — create and edit modes for financial accounts.
//
// Modes (UX Flows §8.3 / §8.4, UI Spec §7.3 / §7.4):
//   Create (existingAccount == null):
//     - Route: /accounts/new
//     - Title: "New Account"
//     - All fields editable
//     - Initial balance field visible
//     - Calls CreateAccountUseCase on Save
//
//   Edit (existingAccount != null):
//     - Route: /accounts/:id/edit
//     - Title: "Edit Account"
//     - Immutable fields (category, currency) shown read-only with lock icon
//     - Initial balance hidden (balance changes happen via transactions)
//     - Calls UpdateAccountUseCase on Save
//
// Fields (UI Spec §7.3.1, §7.4.1):
//   Common: name, category, currency, include_in_net_worth, notes
//   Create only: initial_balance
//   Category-specific: animates in with AnimatedSize when category selected
//
// Validation:
//   - Name required; inline error shown under field
//   - Category required before Save enables
//   - Duplicate name → inline error
//   - ReinstateOfferFailure → AlertDialog offering reinstatement (TC-035)
//
// Test cases (see test/presentation/features/accounts/account_form_screen_test.dart):
//   1. create mode: shows "New Account" title
//   2. create mode: Save button disabled until required fields filled
//   3. create mode: category field is enabled (not read-only)
//   4. create mode: category-specific fields animate in when category selected
//   5. edit mode: shows "Edit Account" title
//   6. edit mode: category field is disabled (read-only)
//   7. edit mode: currency field is read-only
//   8. edit mode: initial balance field is hidden
//   9. edit mode: form is pre-filled with existing account values
//  10. duplicate name shows inline validation error
//  11. reinstatement dialog fires on name conflict

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/account/create_account_use_case.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ignore: prefer_const_constructors — required for Uuid
final _uuid = Uuid();

/// Screen for creating or editing a financial account.
///
/// Pass [existingAccount] to open in edit mode; null opens in create mode.
class AccountFormScreen extends ConsumerStatefulWidget {
  /// Creates the [AccountFormScreen].
  ///
  /// Parameters:
  /// - [existingAccount]: Pre-populated account for edit mode; null for create.
  const AccountFormScreen({super.key, this.existingAccount});

  /// The account to edit, or null when creating a new account.
  final Account? existingAccount;

  /// Test helper: creates a [CreateAccountUseCase] backed by [repo].
  ///
  /// Used in widget tests to inject a fake repository without a real
  /// [LedgerEngine]. Because test accounts have zero initial balance,
  /// the ledger posting path is never reached.
  ///
  /// Parameters:
  /// - [repo]: The fake [IAccountRepository] to back the use case.
  static CreateAccountUseCase makeCreateUseCase(IAccountRepository repo) {
    return CreateAccountUseCase(repo, const LedgerEngine(_NoOpLedgerRepository()));
  }

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

// ---------------------------------------------------------------------------
// Minimal no-op LedgerRepository for use in widget tests
// ---------------------------------------------------------------------------

/// A [LedgerRepository] that throws [UnsupportedError] on all methods.
///
/// Used in widget tests where [CreateAccountUseCase] is backed by a fake
/// [IAccountRepository] that returns [Ok] from [create] directly, meaning
/// the ledger posting path (and thus this repository) is never reached.
class _NoOpLedgerRepository implements LedgerRepository {
  const _NoOpLedgerRepository();

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) {
    throw UnsupportedError('_NoOpLedgerRepository should never be called');
  }

  @override
  Future<bool> eqAccountExists(String currencyCode) {
    throw UnsupportedError('_NoOpLedgerRepository should never be called');
  }

  @override
  Future<Result<String>> createEqAccount(String currencyCode) {
    throw UnsupportedError('_NoOpLedgerRepository should never be called');
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  // Category-specific controllers (loan)
  final _lenderController = TextEditingController();

  // Form state
  AccountCategory? _selectedCategory;
  bool _includeInNetWorth = true;
  bool _isSaving = false;
  String? _nameError;

  bool get _isEditMode => widget.existingAccount != null;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final acc = widget.existingAccount;
    if (acc != null) {
      _nameController.text = acc.name;
      _notesController.text = acc.notes ?? '';
      _selectedCategory = acc.accountCategory;
      _includeInNetWorth = acc.includeInNetWorth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _initialBalanceController.dispose();
    _lenderController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  /// Returns true when the minimum required fields are filled.
  bool get _canSave {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final categoryOk = _isEditMode || _selectedCategory != null;
    return nameOk && categoryOk && !_isSaving;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
      _nameError = null;
    });

    try {
      if (_isEditMode) {
        await _saveEdit();
      } else {
        await _saveCreate();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveCreate() async {
    final useCaseAsync =
        await ref.read(createAccountUseCaseProvider.future);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final initialBalance = int.tryParse(
          _initialBalanceController.text.replaceAll(',', ''),
        ) ??
        0;

    final account = Account(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      accountCategory: _selectedCategory!,
      currencyCode: 'INR', // TODO(dev): wire currency picker
      initialBalanceMinor: initialBalance,
      includeInNetWorth: _includeInNetWorth,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: nowEpoch,
      updatedAt: nowEpoch,
    );

    final result = await useCaseAsync.call(
      account,
      openingBalanceTxId: initialBalance != 0 ? _uuid.v4() : null,
    );

    if (!mounted) return;
    _handleSaveResult(result);
  }

  Future<void> _saveEdit() async {
    final useCaseAsync =
        await ref.read(updateAccountUseCaseProvider.future);
    final existing = widget.existingAccount!;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final updated = existing.copyWith(
      name: _nameController.text.trim(),
      includeInNetWorth: _includeInNetWorth,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      updatedAt: nowEpoch,
    );

    final result = await useCaseAsync.call(updated);

    if (!mounted) return;
    _handleSaveResult(result);
  }

  void _handleSaveResult(Result<Account> result) {
    switch (result) {
      case Ok():
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/accounts');
        }
      case Err(:final failure):
        _handleFailure(failure);
    }
  }

  void _handleFailure(Failure failure) {
    switch (failure) {
      case ValidationFailure():
        setState(() => _nameError = failure.message);
      case ReinstateOfferFailure():
        _showReinstatementDialog(failure);
      case _:
        dev.log('AccountFormScreen save error: ${failure.message}',
            name: 'AccountForm');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Future<void> _showReinstatementDialog(ReinstateOfferFailure failure) async {
    final reinstate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reinstate account?'),
        content: Text(
          'You previously had an account with this name. '
          'Would you like to restore it instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reinstate'),
          ),
        ],
      ),
    );

    if (reinstate == true && mounted) {
      // TODO(dev): Implement reinstate use case (T-later)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reinstatement not yet implemented.')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Account' : 'New Account';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/accounts');
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // re-evaluate _canSave
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              _NameField(
                controller: _nameController,
                externalError: _nameError,
                onChanged: (_) => setState(() => _nameError = null),
              ),
              const SizedBox(height: 16),

              // Category field
              _CategoryField(
                selectedCategory: _selectedCategory,
                readOnly: _isEditMode,
                onSelected: (c) => setState(() => _selectedCategory = c),
              ),
              const SizedBox(height: 16),

              // Currency field (always shown; immutable in edit mode)
              _CurrencyField(
                currencyCode: widget.existingAccount?.currencyCode ?? 'INR',
                readOnly: _isEditMode,
              ),
              const SizedBox(height: 16),

              // Initial balance (create mode only)
              if (!_isEditMode) ...[
                _InitialBalanceField(controller: _initialBalanceController),
                const SizedBox(height: 16),
              ],

              // Include in net worth toggle
              SwitchListTile(
                title: const Text('Include in net worth'),
                value: _includeInNetWorth,
                onChanged: (v) => setState(() => _includeInNetWorth = v),
                contentPadding: EdgeInsets.zero,
              ),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),

              // Category-specific section
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: _selectedCategory != null
                    ? _CategorySpecificFields(
                        category: _selectedCategory!,
                        lenderController: _lenderController,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Save button
              FilledButton(
                onPressed: _canSave ? _onSave : null,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

/// Text field for the account name.
class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.externalError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? externalError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('account_name_field'),
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Account name',
        border: const OutlineInputBorder(),
        errorText: externalError,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
    );
  }
}

/// Category selector field.
///
/// When [readOnly] is true, renders as a non-interactive display field with a
/// lock icon to signal immutability (UI Spec §7.4.2).
class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.selectedCategory,
    required this.readOnly,
    required this.onSelected,
  });

  final AccountCategory? selectedCategory;
  final bool readOnly;
  final ValueChanged<AccountCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = selectedCategory != null
        ? _categoryLabel(selectedCategory!)
        : 'Account category';

    if (readOnly) {
      // Immutable in edit mode — show as read-only with lock icon
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Account category',
          border: const OutlineInputBorder(),
          suffixIcon: Tooltip(
            message: 'Category cannot be changed after creation',
            child: Icon(Icons.lock_outline,
                color: colorScheme.onSurfaceVariant),
          ),
          fillColor: colorScheme.surfaceContainerLow,
          filled: true,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return InkWell(
      key: const Key('account_category_field'),
      onTap: () => _showCategoryPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Account category',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.chevron_right),
        ),
        child: Text(
          selectedCategory != null ? _categoryLabel(selectedCategory!) : '',
          style: TextStyle(
            color: selectedCategory != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker(BuildContext context) async {
    final categories = AccountCategory.values
        .where((c) => c != AccountCategory.equity)
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: categories
            .map(
              (c) => ListTile(
                title: Text(_categoryLabel(c)),
                onTap: () {
                  onSelected(c);
                  Navigator.of(ctx).pop();
                },
              ),
            )
            .toList(),
      ),
    );
  }

  String _categoryLabel(AccountCategory category) {
    return switch (category) {
      AccountCategory.cash => 'Cash',
      AccountCategory.bankAccount => 'Bank Account',
      AccountCategory.creditCard => 'Credit Card',
      AccountCategory.debitCard => 'Debit Card',
      AccountCategory.topUpWallet => 'Top-Up Wallet',
      AccountCategory.loan => 'Loan',
      AccountCategory.investment => 'Investment',
      AccountCategory.other => 'Other',
      AccountCategory.equity => 'Equity',
    };
  }
}

/// Currency field.
///
/// In edit mode rendered read-only with a lock icon and tooltip (UI Spec §7.4.1).
class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.currencyCode,
    required this.readOnly,
  });

  final String currencyCode;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (readOnly) {
      return Tooltip(
        message: 'Currency cannot be changed after the account is created.',
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Currency',
            border: const OutlineInputBorder(),
            suffixIcon: Icon(Icons.lock_outline,
                color: colorScheme.onSurfaceVariant),
            fillColor: colorScheme.surfaceContainerLow,
            filled: true,
          ),
          child: Text(
            currencyCode,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    // TODO(dev): Wire full currency picker (scrollable search list)
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.chevron_right),
      ),
      child: Text(currencyCode),
    );
  }
}

/// Numeric field for the initial account balance (create mode only).
class _InitialBalanceField extends StatelessWidget {
  const _InitialBalanceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Initial balance',
        border: OutlineInputBorder(),
        helperText: 'Leave 0 if starting from zero.',
      ),
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      textInputAction: TextInputAction.next,
    );
  }
}

/// Category-specific fields rendered when a category is selected.
///
/// Each category exposes different optional fields per UI Spec §7.3.2.
/// Only the most commonly used optional fields are implemented here;
/// full field set will be added in subsequent iterations.
class _CategorySpecificFields extends StatelessWidget {
  const _CategorySpecificFields({
    required this.category,
    required this.lenderController,
  });

  final AccountCategory category;
  final TextEditingController lenderController;

  @override
  Widget build(BuildContext context) {
    return switch (category) {
      AccountCategory.loan => _LoanFields(lenderController: lenderController),
      AccountCategory.bankAccount => const _BankAccountFields(),
      AccountCategory.creditCard => const _CreditCardFields(),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Optional fields for Loan accounts.
class _LoanFields extends StatelessWidget {
  const _LoanFields({required this.lenderController});

  final TextEditingController lenderController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Loan details',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        TextFormField(
          controller: lenderController,
          decoration: const InputDecoration(
            labelText: 'Lender / Borrower name',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Optional fields for Bank Account category.
class _BankAccountFields extends StatelessWidget {
  const _BankAccountFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Bank details',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Bank name',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Optional fields for Credit Card category.
class _CreditCardFields extends StatelessWidget {
  const _CreditCardFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Credit card details',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card name',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
