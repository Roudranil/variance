import 'package:flutter/material.dart';

import 'package:variance/core/utils/logger.dart';
import 'package:variance/database/enums.dart';

/// A bottom sheet menu for selecting an account type when adding a new account.
///
/// Returns the selected [AccountType] or null if dismissed.
class AccountTypeMenu extends StatelessWidget {
  /// Creates a new instance of [AccountTypeMenu].
  const AccountTypeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Text(
                'Select account type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // account type options grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AccountType.values.map((type) {
                return _AccountTypeChip(
                  type: type,
                  onTap: () {
                    VarianceLogger.debug('Selected account type: $type');
                    Navigator.of(context).pop(type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A chip displaying an account type with icon and label.
class _AccountTypeChip extends StatelessWidget {
  const _AccountTypeChip({required this.type, required this.onTap});

  final AccountType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconForType(type), size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(_labelForType(type), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  String _labelForType(AccountType type) {
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

  IconData _iconForType(AccountType type) {
    return switch (type) {
      AccountType.cash => Icons.payments_outlined,
      AccountType.savings => Icons.savings_outlined,
      AccountType.bankAccount => Icons.account_balance_outlined,
      AccountType.creditCard => Icons.credit_card_outlined,
      AccountType.loan => Icons.request_quote_outlined,
      AccountType.investment => Icons.trending_up_outlined,
      AccountType.insurance => Icons.health_and_safety_outlined,
      AccountType.wallet => Icons.account_balance_wallet_outlined,
    };
  }
}
