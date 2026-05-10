// test/presentation/features/accounts/widgets/loan_installment_suggestion_sheet_test.dart
//
// Widget tests for LoanInstallmentSuggestionSheet.
//
// Test cases:
//   1. renders with account name in heading text
//   2. "Not now" closes the sheet
//   3. "Set up installment" calls onSetUpInstallment callback
//   4. EMI amount and date pre-fill card shown when provided
//   5. EMI pre-fill card not shown when both are null
//   6. shouldShow — true for negative initial balance
//   7. shouldShow — true when emiAmountMinor > 0
//   8. shouldShow — true when emiDate is provided
//   9. shouldShow — false for positive balance with no EMI details

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/presentation/features/accounts/widgets/loan_installment_suggestion_sheet.dart';

void main() {
  const now = 1715000000;

  Account makeLoanAccount({int initialBalance = -100000}) {
    return Account(
      id: 'loan-1',
      name: 'Home Loan',
      accountCategory: AccountCategory.loan,
      currencyCode: 'INR',
      initialBalanceMinor: initialBalance,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildSheet({
    required Account account,
    int? emiAmountMinor,
    int? emiDate,
    VoidCallback? onSetUpInstallment,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LoanInstallmentSuggestionSheet(
          account: account,
          emiAmountMinor: emiAmountMinor,
          emiDate: emiDate,
          onSetUpInstallment: onSetUpInstallment ?? () {},
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Rendering
  // -----------------------------------------------------------------------

  group('rendering', () {
    testWidgets('1. renders with account name in heading', (tester) async {
      await tester.pumpWidget(buildSheet(account: makeLoanAccount()));
      expect(find.text('Set up automatic installments?'), findsOneWidget);
      expect(find.textContaining('Home Loan'), findsWidgets);
    });

    testWidgets('4. EMI pre-fill card shown when amount and date provided',
        (tester) async {
      await tester.pumpWidget(
        buildSheet(
          account: makeLoanAccount(),
          emiAmountMinor: 500000,
          emiDate: 5,
        ),
      );
      // Pre-fill card with 'Amount' and 'Due day' labels.
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Due day'), findsOneWidget);
    });

    testWidgets('5. EMI pre-fill card not shown when both are null',
        (tester) async {
      await tester.pumpWidget(
        buildSheet(account: makeLoanAccount()),
      );
      expect(find.text('Amount'), findsNothing);
      expect(find.text('Due day'), findsNothing);
    });
  });

  // -----------------------------------------------------------------------
  // Interactions
  // -----------------------------------------------------------------------

  group('interactions', () {
    testWidgets('2. "Not now" dismisses the sheet', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => LoanInstallmentSuggestionSheet(
                      account: makeLoanAccount(),
                      onSetUpInstallment: () {},
                    ),
                  ).then((_) => dismissed = true),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Not now'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('3. "Set up installment" calls onSetUpInstallment',
        (tester) async {
      var callbackInvoked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoanInstallmentSuggestionSheet(
              account: makeLoanAccount(),
              onSetUpInstallment: () => callbackInvoked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Set up installment'));
      await tester.pump();
      expect(callbackInvoked, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // shouldShow
  // -----------------------------------------------------------------------

  group('shouldShow', () {
    test('6. true for negative initial balance', () {
      expect(
        LoanInstallmentSuggestionSheet.shouldShow(
          makeLoanAccount(initialBalance: -10000),
        ),
        isTrue,
      );
    });

    test('7. true when emiAmountMinor > 0', () {
      expect(
        LoanInstallmentSuggestionSheet.shouldShow(
          makeLoanAccount(initialBalance: 0),
          emiAmountMinor: 30000,
        ),
        isTrue,
      );
    });

    test('8. true when emiDate is provided', () {
      expect(
        LoanInstallmentSuggestionSheet.shouldShow(
          makeLoanAccount(initialBalance: 0),
          emiDate: 15,
        ),
        isTrue,
      );
    });

    test('9. false for positive balance with no EMI details', () {
      expect(
        LoanInstallmentSuggestionSheet.shouldShow(
          makeLoanAccount(initialBalance: 50000),
        ),
        isFalse,
      );
    });
  });
}
