// lib/presentation/features/accounts/widgets/loan_installment_suggestion_sheet.dart
//
// Bottom sheet shown after a loan account is created with a negative initial
// balance or with EMI details set.
//
// The sheet pre-fills a recurring template create flow with:
//   destination = the newly created loan account
//   amount      = emi_amount_minor (if present)
//   recurrence  = monthly on emi_date (if present)
//   start_date  = today
//
// CTAs:
//   "Set up installment" → navigates to recurring template create flow.
//   "Not now"            → dismisses the sheet.
//
// Test cases (see test/presentation/features/accounts/widgets/
//              loan_installment_suggestion_sheet_test.dart):
//   1. renders with loan account name in heading
//   2. "Not now" closes the sheet
//   3. "Set up installment" calls onSetUpInstallment callback
//   4. emi_amount_minor pre-fill is shown when provided
//   5. does not appear for positive-balance non-loan accounts

import 'package:flutter/material.dart';

import 'package:variance/domain/entities/account.dart';

/// A modal bottom sheet that suggests setting up a recurring installment
/// template after a loan account is created.
///
/// Shown when [account.initialBalanceMinor] < 0 or when [emiAmountMinor] or
/// [emiDate] is provided.
///
/// Callers are responsible for determining whether to show this sheet via
/// [LoanInstallmentSuggestionSheet.shouldShow].
class LoanInstallmentSuggestionSheet extends StatelessWidget {
  /// Creates a [LoanInstallmentSuggestionSheet].
  ///
  /// Parameters:
  /// - [account]: The newly created loan account.
  /// - [emiAmountMinor]: Optional pre-fill amount for the EMI (minor units).
  /// - [emiDate]: Optional day-of-month for the recurring EMI trigger.
  /// - [onSetUpInstallment]: Callback invoked when the user taps "Set up installment".
  const LoanInstallmentSuggestionSheet({
    required this.account,
    this.emiAmountMinor,
    this.emiDate,
    required this.onSetUpInstallment,
    super.key,
  });

  /// The newly created loan account.
  final Account account;

  /// Pre-fill amount for the EMI in minor currency units.
  final int? emiAmountMinor;

  /// Day-of-month for the recurring installment (1–31).
  final int? emiDate;

  /// Invoked when the user confirms they want to set up an installment plan.
  final VoidCallback onSetUpInstallment;

  // -----------------------------------------------------------------------
  // Factory helpers
  // -----------------------------------------------------------------------

  /// Returns true when the suggestion sheet should be shown for [account].
  ///
  /// Shows when:
  ///   - initial balance is negative (loan with outstanding balance), or
  ///   - EMI amount or EMI date is provided (scheduled installment exists).
  ///
  /// Parameters:
  /// - [account]: The account to evaluate.
  /// - [emiAmountMinor]: Optional EMI amount from account details.
  /// - [emiDate]: Optional EMI date from account details.
  static bool shouldShow(
    Account account, {
    int? emiAmountMinor,
    int? emiDate,
  }) {
    return account.initialBalanceMinor < 0 ||
        (emiAmountMinor != null && emiAmountMinor > 0) ||
        emiDate != null;
  }

  /// Shows the sheet as a modal bottom sheet.
  ///
  /// Returns a [Future] that completes when the sheet is dismissed.
  ///
  /// Parameters:
  /// - [context]: BuildContext to use for [showModalBottomSheet].
  /// - [account]: The newly created loan account.
  /// - [emiAmountMinor]: Optional pre-fill amount.
  /// - [emiDate]: Optional EMI day-of-month.
  /// - [onSetUpInstallment]: Callback for the "Set up installment" CTA.
  static Future<void> show(
    BuildContext context, {
    required Account account,
    int? emiAmountMinor,
    int? emiDate,
    required VoidCallback onSetUpInstallment,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => LoanInstallmentSuggestionSheet(
        account: account,
        emiAmountMinor: emiAmountMinor,
        emiDate: emiDate,
        onSetUpInstallment: onSetUpInstallment,
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Handle indicator ---
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Heading ---
            Text(
              'Set up automatic installments?',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // --- Description ---
            Text(
              'Create a monthly recurring reminder for "${account.name}" '
              'so you never miss a payment.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // --- EMI pre-fill info (shown when available) ---
            if (emiAmountMinor != null || emiDate != null) ...[
              const SizedBox(height: 16),
              _EmiPreFillCard(
                emiAmountMinor: emiAmountMinor,
                emiDate: emiDate,
                currencyCode: account.currencyCode,
              ),
            ],

            const SizedBox(height: 24),

            // --- CTAs ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSetUpInstallment();
                  },
                  child: const Text('Set up installment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal card widget that shows the pre-filled EMI details.
class _EmiPreFillCard extends StatelessWidget {
  const _EmiPreFillCard({
    this.emiAmountMinor,
    this.emiDate,
    required this.currencyCode,
  });

  final int? emiAmountMinor;
  final int? emiDate;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emiAmountMinor != null)
            _EmiDetailRow(
              label: 'Amount',
              // Display in major units with 2-decimal formatting.
              value:
                  '$currencyCode ${(emiAmountMinor! / 100).toStringAsFixed(2)}',
            ),
          if (emiDate != null)
            _EmiDetailRow(
              label: 'Due day',
              value: 'Day $emiDate of each month',
            ),
        ],
      ),
    );
  }
}

/// A single label-value row inside [_EmiPreFillCard].
class _EmiDetailRow extends StatelessWidget {
  const _EmiDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
