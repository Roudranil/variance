// test/unit/domain/services/posting_case_selector_test.dart
//
// Unit tests for PostingCaseSelector.
//
// Test cases:
//   1. select(createExpense, ...) → PostingCase.createExpense
//   2. select(createIncome, ...) → PostingCase.createIncome
//   3. select(createTransfer, ...) → PostingCase.createTransfer
//   4. select(createTransferWithFee, ...) → PostingCase.createTransferWithFee
//   5. select(editExpense, ...) → PostingCase.modifyExpense
//   6. select(editIncome, ...) → PostingCase.modifyIncome
//   7. select(editTransfer, ...) → PostingCase.modifyTransfer
//   8. select(deleteExpense, ...) → PostingCase.reverseExpense
//   9. select(deleteIncome, ...) → PostingCase.reverseIncome
//  10. select(deleteTransfer, ...) → PostingCase.reverseTransfer
//  11. select(openingBalancePositive, ...) → PostingCase.openingBalancePositive
//  12. select(openingBalanceNegative, ...) → PostingCase.openingBalanceNegative
//  13. select(balanceEditVisibleIncrease, ...) → PostingCase.balanceEditVisibleIncrease
//  14. select(balanceEditVisibleDecrease, ...) → PostingCase.balanceEditVisibleDecrease
//  15. select(balanceEditInvisibleIncrease, ...) → PostingCase.balanceEditInvisibleIncrease
//  16. select(balanceEditInvisibleDecrease, ...) → PostingCase.balanceEditInvisibleDecrease
//  17. select(accountDeletionTransferPositive, ...) → PostingCase.accountDeletionTransferPositive
//  18. select(accountDeletionTransferNegative, ...) → PostingCase.accountDeletionTransferNegative
//  19. select(recurringAutoPost, expense) → PostingCase.createExpense
//  20. PostingCaseSelector has no mutable state (same instance yields same output)

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

void main() {
  final selector = PostingCaseSelector();

  group('PostingCaseSelector — Transaction Lifecycle (Group 1)', () {
    test('1. createExpense event → createExpense case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.createExpense,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createExpense),
      );
    });

    test('2. createIncome event → createIncome case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.createIncome,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createIncome),
      );
    });

    test('3. createTransfer event → createTransfer case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.createTransfer,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createTransfer),
      );
    });

    test('4. createTransferWithFee event → createTransferWithFee case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.createTransferWithFee,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createTransferWithFee),
      );
    });

    test('5. editExpense event → modifyExpense case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.editExpense,
          entityState: const EntityState(),
        ),
        equals(PostingCase.modifyExpense),
      );
    });

    test('6. editIncome event → modifyIncome case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.editIncome,
          entityState: const EntityState(),
        ),
        equals(PostingCase.modifyIncome),
      );
    });

    test('7. editTransfer event → modifyTransfer case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.editTransfer,
          entityState: const EntityState(),
        ),
        equals(PostingCase.modifyTransfer),
      );
    });

    test('8. deleteExpense event → reverseExpense case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.deleteExpense,
          entityState: const EntityState(),
        ),
        equals(PostingCase.reverseExpense),
      );
    });

    test('9. deleteIncome event → reverseIncome case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.deleteIncome,
          entityState: const EntityState(),
        ),
        equals(PostingCase.reverseIncome),
      );
    });

    test('10. deleteTransfer event → reverseTransfer case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.deleteTransfer,
          entityState: const EntityState(),
        ),
        equals(PostingCase.reverseTransfer),
      );
    });
  });

  group('PostingCaseSelector — Account Lifecycle (Group 2)', () {
    test('11. openingBalancePositive event → openingBalancePositive case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.openingBalancePositive,
          entityState: const EntityState(),
        ),
        equals(PostingCase.openingBalancePositive),
      );
    });

    test('12. openingBalanceNegative event → openingBalanceNegative case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.openingBalanceNegative,
          entityState: const EntityState(),
        ),
        equals(PostingCase.openingBalanceNegative),
      );
    });

    test(
      '13. balanceEditVisibleIncrease event → balanceEditVisibleIncrease case',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.balanceEditVisibleIncrease,
            entityState: const EntityState(),
          ),
          equals(PostingCase.balanceEditVisibleIncrease),
        );
      },
    );

    test(
      '14. balanceEditVisibleDecrease event → balanceEditVisibleDecrease case',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.balanceEditVisibleDecrease,
            entityState: const EntityState(),
          ),
          equals(PostingCase.balanceEditVisibleDecrease),
        );
      },
    );

    test(
      '15. balanceEditInvisibleIncrease → balanceEditInvisibleIncrease case',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.balanceEditInvisibleIncrease,
            entityState: const EntityState(),
          ),
          equals(PostingCase.balanceEditInvisibleIncrease),
        );
      },
    );

    test(
      '16. balanceEditInvisibleDecrease → balanceEditInvisibleDecrease case',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.balanceEditInvisibleDecrease,
            entityState: const EntityState(),
          ),
          equals(PostingCase.balanceEditInvisibleDecrease),
        );
      },
    );

    test(
      '17. accountDeletionTransferPositive → accountDeletionTransferPositive',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.accountDeletionTransferPositive,
            entityState: const EntityState(),
          ),
          equals(PostingCase.accountDeletionTransferPositive),
        );
      },
    );

    test(
      '18. accountDeletionTransferNegative → accountDeletionTransferNegative',
      () {
        expect(
          selector.select(
            eventType: LedgerEventType.accountDeletionTransferNegative,
            entityState: const EntityState(),
          ),
          equals(PostingCase.accountDeletionTransferNegative),
        );
      },
    );
  });

  group('PostingCaseSelector — Recurring Auto-Post (Group 3)', () {
    test('19. recurringAutoPostExpense → createExpense case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.recurringAutoPostExpense,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createExpense),
      );
    });

    test('recurringAutoPostIncome → createIncome case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.recurringAutoPostIncome,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createIncome),
      );
    });

    test('recurringAutoPostTransfer → createTransfer case', () {
      expect(
        selector.select(
          eventType: LedgerEventType.recurringAutoPostTransfer,
          entityState: const EntityState(),
        ),
        equals(PostingCase.createTransfer),
      );
    });
  });

  group('PostingCaseSelector — statelessness', () {
    test(
      '20. same selector instance returns same result across multiple calls',
      () {
        final result1 = selector.select(
          eventType: LedgerEventType.createExpense,
          entityState: const EntityState(),
        );
        final result2 = selector.select(
          eventType: LedgerEventType.createExpense,
          entityState: const EntityState(),
        );
        expect(result1, equals(result2));
      },
    );
  });
}
