// test/unit/domain/entities/entities_test.dart
//
// Smoke tests for all 16 Freezed domain entities.
// Verifies: constructability, copyWith, equality, default values.
//
// Test cases:
//   1. Account: constructs with required fields; default isDeleted = false
//   2. Account: copyWith produces a new immutable instance
//   3. Account: structural equality (two same-field instances are equal)
//   4. Transaction: constructs; default purpose = user
//   5. Transaction: status field round-trips via copyWith
//   6. Entry: constructs; mutually exclusive account/category fields nullable
//   7. Category: constructs; default isProtected = false
//   8. Tag: constructs minimal fields
//   9. Payee: constructs; default isDeleted = false
//  T-80.1. ExchangeRate.rate: rateMicro 83_000_000 → 83.0
//  T-80.2. ExchangeRate.isStale: false within 14 days
//  T-80.3. ExchangeRate.isStale: true beyond 14 days
//  T-80.4. ExchangeRate.rate: rateMicro 1_000_000 → 1.0 (identity rate)
//  10. Currency: constructs; default minorUnits = 2
//  11. ExchangeRate: constructs all required fields
//  12. Budget: constructs; default rollover = false
//  13. BudgetPeriod: constructs; default carriedOverMinor = 0
//  14. RecurringTemplate: constructs; default status = active
//  15. ScheduledOccurrence: constructs; default status = pending
//  16. InstallmentPlan: constructs all required fields
//  17. InstallmentOccurrence: constructs; default status = pending
//  18. AppSettings: constructs with all defaults; homeCurrency = INR
//  19. Draft: constructs with required fields
//  20. Money: constructs; used in equality check

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/budget.dart';
import 'package:variance/domain/entities/budget_period.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/entities/draft.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/entities/payee.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/entities/tag.dart';
import 'package:variance/domain/entities/transaction.dart';

void main() {
  const now = 1715000000; // fixed epoch for tests

  group('Account', () {
    const account = Account(
      id: 'a1',
      name: 'Savings',
      accountCategory: AccountCategory.bankAccount,
      currencyCode: 'INR',
      createdAt: now,
      updatedAt: now,
    );

    test('1. constructs with required fields; default isDeleted = false', () {
      expect(account.id, equals('a1'));
      expect(account.isDeleted, isFalse);
      expect(account.initialBalanceMinor, equals(0));
    });

    test('2. copyWith produces a new immutable instance', () {
      final updated = account.copyWith(name: 'Checking');
      expect(updated.name, equals('Checking'));
      expect(account.name, equals('Savings')); // original unchanged
    });

    test('3. structural equality holds', () {
      const same = Account(
        id: 'a1',
        name: 'Savings',
        accountCategory: AccountCategory.bankAccount,
        currencyCode: 'INR',
        createdAt: now,
        updatedAt: now,
      );
      expect(account, equals(same));
    });
  });

  group('Transaction', () {
    const tx = Transaction(
      id: 't1',
      type: TransactionType.expense,
      status: TransactionStatus.pending,
      dateTime: now,
      amountMinor: 5000,
      currencyCode: 'INR',
      createdAt: now,
      updatedAt: now,
    );

    test('4. constructs; default purpose = user', () {
      expect(tx.purpose, equals(TransactionPurpose.user));
    });

    test('5. status field round-trips via copyWith', () {
      final posted = tx.copyWith(status: TransactionStatus.posted);
      expect(posted.status, equals(TransactionStatus.posted));
      expect(tx.status, equals(TransactionStatus.pending));
    });
  });

  group('Entry', () {
    test('6. constructs; account/category fields are nullable', () {
      const entry = Entry(
        id: 'e1',
        transactionId: 't1',
        accountId: 'a1',
        side: EntrySide.debit,
        amountMinor: 5000,
        currencyCode: 'INR',
        createdAt: now,
      );
      expect(entry.categoryId, isNull);
    });
  });

  group('Category', () {
    test('7. constructs; default isProtected = false', () {
      const cat = Category(
        id: 'c1',
        treeType: CategoryTreeType.expense,
        name: 'Food',
        iconRef: 'restaurant',
        createdAt: now,
        updatedAt: now,
      );
      expect(cat.isProtected, isFalse);
      expect(cat.parentId, isNull);
    });
  });

  group('Tag', () {
    test('8. constructs minimal fields', () {
      const tag = Tag(id: 'tg1', name: 'groceries', createdAt: now);
      expect(tag.name, equals('groceries'));
    });
  });

  group('Payee', () {
    test('9. constructs; default isDeleted = false', () {
      const payee = Payee(
        id: 'p1',
        name: 'Amazon',
        createdAt: now,
        updatedAt: now,
      );
      expect(payee.isDeleted, isFalse);
    });
  });

  group('Currency', () {
    test('10. constructs; default minorUnits = 2', () {
      const currency = Currency(code: 'USD', name: 'US Dollar', symbol: '\$');
      expect(currency.minorUnits, equals(2));
      expect(currency.isActive, isTrue);
    });
  });

  group('ExchangeRate', () {
    test('11. constructs all required fields', () {
      const rate = ExchangeRate(
        id: 1,
        fromCurrency: 'USD',
        toCurrency: 'INR',
        rateMicro: 83000000,
        fetchedAt: now,
        rateDate: '2025-05-07',
      );
      expect(rate.rateMicro, equals(83000000));
    });

    // T-80 computed getter tests
    test('T-80.1. rate: rateMicro 83_000_000 → 83.0', () {
      const rate = ExchangeRate(
        id: 1,
        fromCurrency: 'USD',
        toCurrency: 'INR',
        rateMicro: 83000000,
        fetchedAt: now,
        rateDate: '2025-05-07',
      );
      expect(rate.rate, closeTo(83.0, 0.000001));
    });

    test('T-80.2. isStale: false within 14 days', () {
      // fetchedAt = 7 days ago → still fresh
      final sevenDaysAgoEpoch =
          DateTime.now()
              .subtract(const Duration(days: 7))
              .millisecondsSinceEpoch ~/
          1000;
      final rate = ExchangeRate(
        id: 2,
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        rateMicro: 1100000,
        fetchedAt: sevenDaysAgoEpoch,
        rateDate: '2025-05-05',
      );
      expect(rate.isStale, isFalse);
    });

    test('T-80.3. isStale: true beyond 14 days', () {
      // fetchedAt = 15 days ago → stale
      final fifteenDaysAgoEpoch =
          DateTime.now()
              .subtract(const Duration(days: 15))
              .millisecondsSinceEpoch ~/
          1000;
      final rate = ExchangeRate(
        id: 3,
        fromCurrency: 'GBP',
        toCurrency: 'USD',
        rateMicro: 1250000,
        fetchedAt: fifteenDaysAgoEpoch,
        rateDate: '2025-04-27',
      );
      expect(rate.isStale, isTrue);
    });

    test('T-80.4. rate: rateMicro 1_000_000 → 1.0 (identity rate)', () {
      const rate = ExchangeRate(
        id: 4,
        fromCurrency: 'USD',
        toCurrency: 'USD',
        rateMicro: 1000000,
        fetchedAt: now,
        rateDate: '2025-05-07',
      );
      expect(rate.rate, closeTo(1.0, 0.000001));
    });
  });

  group('Budget', () {
    test('12. constructs; default rollover = false', () {
      const budget = Budget(
        id: 'b1',
        name: 'Monthly groceries',
        amountMinor: 1000000,
        currencyCode: 'INR',
        periodType: BudgetPeriodType.monthly,
        createdAt: now,
        updatedAt: now,
      );
      expect(budget.rollover, isFalse);
      expect(budget.isActive, isTrue);
    });
  });

  group('BudgetPeriod', () {
    test('13. constructs; default carriedOverMinor = 0', () {
      const period = BudgetPeriod(
        id: 'bp1',
        budgetId: 'b1',
        periodStart: now,
        periodEnd: now + 2592000,
        budgetedMinor: 1000000,
        createdAt: now,
      );
      expect(period.carriedOverMinor, equals(0));
    });
  });

  group('RecurringTemplate', () {
    test('14. constructs; default status = active', () {
      const template = RecurringTemplate(
        id: 'rt1',
        transactionType: 'expense',
        amountMinor: 50000,
        currencyCode: 'INR',
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(template.status, equals(RecurringTemplateStatus.active));
      expect(template.isInstallment, isFalse);
    });
  });

  group('ScheduledOccurrence', () {
    test('15. constructs; default status = pending', () {
      const occ = ScheduledOccurrence(
        id: 'so1',
        templateId: 'rt1',
        scheduledDate: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(occ.status, equals(ScheduledOccurrenceStatus.pending));
    });
  });

  group('InstallmentPlan', () {
    test('16. constructs all required fields', () {
      const plan = InstallmentPlan(
        templateId: 'rt2',
        totalConfiguredMinor: 600000,
        numberOfInstallments: 6,
        createdAt: now,
      );
      expect(plan.numberOfInstallments, equals(6));
    });
  });

  group('InstallmentOccurrence', () {
    test('17. constructs; default status = pending', () {
      const occ = InstallmentOccurrence(
        id: 'io1',
        templateId: 'rt2',
        sequenceNumber: 1,
        scheduledDate: now,
        amountMinor: 100000,
        createdAt: now,
        updatedAt: now,
      );
      expect(occ.status, equals(InstallmentOccurrenceStatus.pending));
    });
  });

  group('AppSettings', () {
    test('18. constructs with defaults; homeCurrency = INR', () {
      const settings = AppSettings();
      expect(settings.homeCurrency, equals('INR'));
      expect(settings.animationsEnabled, isTrue);
      expect(settings.onboardingComplete, isFalse);
    });
  });

  group('Draft', () {
    test('19. constructs with required fields', () {
      const draft = Draft(
        id: 'd1',
        payloadJson: '{"type":"expense"}',
        createdAt: now,
        updatedAt: now,
      );
      expect(draft.payloadJson, contains('expense'));
    });
  });

  group('Money', () {
    test('20. structural equality holds across two instances', () {
      const a = Money(amountMinor: 50000, currencyCode: 'USD');
      const b = Money(amountMinor: 50000, currencyCode: 'USD');
      expect(a, equals(b));
    });
  });

  group('AccountDetail', () {
    test('21. constructs with required fields', () {
      const detail = AccountDetail(
        id: 'det-1',
        accountId: 'acc-1',
        detailKey: 'bank_name',
        detailValue: 'HDFC',
        updatedAt: now,
      );
      expect(detail.detailKey, equals('bank_name'));
      expect(detail.detailValueEncrypted, isNull);
    });

    test('22. copyWith produces updated instance', () {
      const detail = AccountDetail(
        id: 'det-1',
        accountId: 'acc-1',
        detailKey: 'bank_name',
        detailValue: 'HDFC',
        updatedAt: now,
      );
      final updated = detail.copyWith(detailValue: 'SBI');
      expect(updated.detailValue, equals('SBI'));
      expect(detail.detailValue, equals('HDFC'));
    });

    test('23. AccountDetailKey.fromString resolves known key', () {
      final key = AccountDetailKey.fromString('card_number');
      expect(key, equals(AccountDetailKey.cardNumber));
      expect(key?.encrypted, isTrue);
    });

    test('24. AccountDetailKey.fromString returns null for unknown key', () {
      final key = AccountDetailKey.fromString('non_existent_key');
      expect(key, isNull);
    });

    test('25. non-sensitive key has encrypted = false', () {
      expect(AccountDetailKey.bankName.encrypted, isFalse);
    });

    test('26. sensitive key has encrypted = true', () {
      expect(AccountDetailKey.accountNumber.encrypted, isTrue);
    });
  });
}
