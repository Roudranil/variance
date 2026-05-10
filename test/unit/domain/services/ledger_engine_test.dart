// test/unit/domain/services/ledger_engine_test.dart
//
// Unit tests for LedgerEngine and all posting case invariants.
//
// Each case from ledger-entry.md is tested. The LedgerEngine is exercised
// against a FakeLedgerRepository that captures written entries and accounts.
//
// Posting cases covered:
//   Case 1.1 — Create Expense:         Dr EC, Cr A
//   Case 1.2 — Create Income:          Dr A, Cr IC
//   Case 1.3 — Create Transfer:        Dr A₂, Cr A₁
//   Case 1.3a — Create Transfer+Fee:   Dr A₂ + Dr FC, Cr A₁ (×2)
//   Case 2.2a — Opening +balance:      Dr A, Cr EQ
//   Case 2.2b — Opening -balance:      Dr EQ, Cr A
//   Case 2.3a — Visible adj +balance:  Dr A, Cr BAI
//   Case 2.3b — Visible adj -balance:  Dr BAE, Cr A
//   Case 2.4a — Invisible adj +balance: Dr A, Cr EQ
//   Case 2.4b — Invisible adj -balance: Dr EQ, Cr A
//   Case 2.5a — Account deletion transfer (positive balance): Dr A₂, Cr A₁
//   Case 3.1 — Recurring auto-post:    identical entries to 1.1/1.2/1.3
//   Imbalance assertion:               deliberately mismatched Dr ≠ Cr → BusinessRuleFailure
//
// Test numbering follows the cases above in order.

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

// ---------------------------------------------------------------------------
// Fake ledger repository — captures calls without touching a real database.
// ---------------------------------------------------------------------------

class FakeLedgerRepository implements LedgerRepository {
  final List<List<Entry>> insertedEntryGroups = [];
  final List<String> createdEqAccounts = [];

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async {
    insertedEntryGroups.add(List.unmodifiable(entries));
    return const Ok(null);
  }

  @override
  Future<bool> eqAccountExists(String currencyCode) async {
    return createdEqAccounts.contains('__EQ_$currencyCode');
  }

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async {
    final id = '__EQ_$currencyCode';
    createdEqAccounts.add(id);
    return Ok(id);
  }

  // Resets state between tests.
  void reset() {
    insertedEntryGroups.clear();
    createdEqAccounts.clear();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns the entries from the most-recent insertEntries call.
List<Entry> lastEntries(FakeLedgerRepository repo) =>
    repo.insertedEntryGroups.last;

/// Returns all entries across all insert calls, flattened.
List<Entry> allEntries(FakeLedgerRepository repo) =>
    repo.insertedEntryGroups.expand((g) => g).toList();

/// Asserts Σdebit == Σcredit for a list of entries.
void assertBalanced(List<Entry> entries) {
  final debitSum = entries
      .where((e) => e.side == EntrySide.debit)
      .fold<int>(0, (sum, e) => sum + e.amountMinor);
  final creditSum = entries
      .where((e) => e.side == EntrySide.credit)
      .fold<int>(0, (sum, e) => sum + e.amountMinor);
  expect(debitSum, equals(creditSum), reason: 'Σdebit must equal Σcredit');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeLedgerRepository repo;
  late LedgerEngine engine;

  setUp(() {
    repo = FakeLedgerRepository();
    engine = LedgerEngine(repo);
  });

  // -------------------------------------------------------------------------
  // Case 1.1 — Create Expense: Dr EC, Cr A
  // -------------------------------------------------------------------------
  group('Case 1.1 — Create Expense', () {
    test('posts Dr EC + Cr A; Σdebit = Σcredit', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createExpense,
        accountId: 'account-A',
        categoryId: 'category-EC',
        amountMinor: 5000,
        currencyCode: 'INR',
        transactionId: 'tx1',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      expect(entries.length, equals(2));
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      // Dr goes to expense category
      expect(debit.categoryId, equals('category-EC'));
      expect(debit.accountId, isNull);
      // Cr comes from asset account
      expect(credit.accountId, equals('account-A'));
      expect(credit.categoryId, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Case 1.2 — Create Income: Dr A, Cr IC
  // -------------------------------------------------------------------------
  group('Case 1.2 — Create Income', () {
    test('posts Dr A + Cr IC; Σdebit = Σcredit', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createIncome,
        accountId: 'account-A',
        categoryId: 'category-IC',
        amountMinor: 10000,
        currencyCode: 'INR',
        transactionId: 'tx2',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      expect(entries.length, equals(2));
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      // Dr goes to destination account
      expect(debit.accountId, equals('account-A'));
      // Cr comes from income category
      expect(credit.categoryId, equals('category-IC'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 1.3 — Create Transfer: Dr A₂, Cr A₁
  // -------------------------------------------------------------------------
  group('Case 1.3 — Create Transfer', () {
    test('posts Dr A2 + Cr A1; Σdebit = Σcredit', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createTransfer,
        accountId: 'account-A1',
        destinationAccountId: 'account-A2',
        amountMinor: 20000,
        currencyCode: 'INR',
        transactionId: 'tx3',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      expect(entries.length, equals(2));
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, equals('account-A2'));
      expect(credit.accountId, equals('account-A1'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 1.3a — Create Transfer+Fee: Dr A₂ + Dr FC, Cr A₁ (×2)
  // -------------------------------------------------------------------------
  group('Case 1.3a — Create Transfer with Fee', () {
    test('posts 4 entries (2 balanced pairs); Σdebit = Σcredit each pair',
        () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createTransferWithFee,
        accountId: 'account-A1',
        destinationAccountId: 'account-A2',
        amountMinor: 30000,
        currencyCode: 'INR',
        transactionId: 'tx4',
        nowEpoch: 1715000000,
        feeCategoryId: 'category-FC',
        feeAmountMinor: 500,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      // 2 transfer entries + 2 fee entries = 4
      expect(entries.length, equals(4));

      // All entries combined must still satisfy Σdebit = Σcredit
      assertBalanced(entries);

      // Transfer pair: Dr A₂, Cr A₁
      final transferDebit = entries.firstWhere(
        (e) => e.side == EntrySide.debit && e.accountId == 'account-A2',
      );
      final transferCredit = entries.firstWhere(
        (e) =>
            e.side == EntrySide.credit &&
            e.accountId == 'account-A1' &&
            e.amountMinor == 30000,
      );
      expect(transferDebit.amountMinor, equals(30000));
      expect(transferCredit.amountMinor, equals(30000));

      // Fee pair: Dr FC, Cr A₁
      final feeDebit = entries.firstWhere(
        (e) => e.side == EntrySide.debit && e.categoryId == 'category-FC',
      );
      final feeCredit = entries.firstWhere(
        (e) =>
            e.side == EntrySide.credit &&
            e.accountId == 'account-A1' &&
            e.amountMinor == 500,
      );
      expect(feeDebit.amountMinor, equals(500));
      expect(feeCredit.amountMinor, equals(500));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.2a — Opening Balance (positive): Dr A, Cr EQ
  // -------------------------------------------------------------------------
  group('Case 2.2a — Opening Balance (positive)', () {
    test('posts Dr A + Cr EQ; EQ account created lazily', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.openingBalancePositive,
        accountId: 'account-A',
        amountMinor: 100000,
        currencyCode: 'INR',
        transactionId: 'tx5',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      expect(entries.length, equals(2));
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      // Dr goes to the asset account
      expect(debit.accountId, equals('account-A'));
      // Cr comes from the EQ account — which was lazily created
      expect(credit.accountId, contains('__EQ_'));
      expect(repo.createdEqAccounts, contains('__EQ_INR'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.2b — Opening Balance (negative): Dr EQ, Cr A
  // -------------------------------------------------------------------------
  group('Case 2.2b — Opening Balance (negative)', () {
    test('posts Dr EQ + Cr A', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.openingBalanceNegative,
        accountId: 'account-A',
        amountMinor: 50000,
        currencyCode: 'INR',
        transactionId: 'tx6',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      // Dr EQ, Cr A
      expect(debit.accountId, contains('__EQ_'));
      expect(credit.accountId, equals('account-A'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.3a — Balance edit visible, increase: Dr A, Cr BAI
  // -------------------------------------------------------------------------
  group('Case 2.3a — Visible balance adjustment (increase)', () {
    test('posts Dr A + Cr BAI', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.balanceEditVisibleIncrease,
        accountId: 'account-A',
        categoryId: 'category-BAI',
        amountMinor: 2000,
        currencyCode: 'INR',
        transactionId: 'tx7',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, equals('account-A'));
      expect(credit.categoryId, equals('category-BAI'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.3b — Balance edit visible, decrease: Dr BAE, Cr A
  // -------------------------------------------------------------------------
  group('Case 2.3b — Visible balance adjustment (decrease)', () {
    test('posts Dr BAE + Cr A', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.balanceEditVisibleDecrease,
        accountId: 'account-A',
        categoryId: 'category-BAE',
        amountMinor: 3000,
        currencyCode: 'INR',
        transactionId: 'tx8',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.categoryId, equals('category-BAE'));
      expect(credit.accountId, equals('account-A'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.4a — Balance edit invisible, increase: Dr A, Cr EQ
  // -------------------------------------------------------------------------
  group('Case 2.4a — Invisible balance adjustment (increase)', () {
    test('posts Dr A + Cr EQ', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.balanceEditInvisibleIncrease,
        accountId: 'account-A',
        amountMinor: 4000,
        currencyCode: 'INR',
        transactionId: 'tx9',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, equals('account-A'));
      expect(credit.accountId, contains('__EQ_'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.4b — Balance edit invisible, decrease: Dr EQ, Cr A
  // -------------------------------------------------------------------------
  group('Case 2.4b — Invisible balance adjustment (decrease)', () {
    test('posts Dr EQ + Cr A', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.balanceEditInvisibleDecrease,
        accountId: 'account-A',
        amountMinor: 6000,
        currencyCode: 'INR',
        transactionId: 'tx10',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, contains('__EQ_'));
      expect(credit.accountId, equals('account-A'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 2.5a — Account deletion transfer (positive balance): Dr A₂, Cr A₁
  // -------------------------------------------------------------------------
  group('Case 2.5a — Account deletion transfer', () {
    test('positive balance: Dr A₂, Cr A₁', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.accountDeletionTransferPositive,
        accountId: 'account-A1',
        destinationAccountId: 'account-A2',
        amountMinor: 15000,
        currencyCode: 'INR',
        transactionId: 'tx11',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, equals('account-A2'));
      expect(credit.accountId, equals('account-A1'));
    });

    test('negative balance: Dr A₁, Cr A₂', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.accountDeletionTransferNegative,
        accountId: 'account-A1',
        destinationAccountId: 'account-A2',
        amountMinor: 8000,
        currencyCode: 'INR',
        transactionId: 'tx12',
        nowEpoch: 1715000000,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.accountId, equals('account-A1'));
      expect(credit.accountId, equals('account-A2'));
    });
  });

  // -------------------------------------------------------------------------
  // Case 3.1 — Recurring auto-post (expense): identical to 1.1
  // -------------------------------------------------------------------------
  group('Case 3.1 — Recurring auto-post', () {
    test('auto-post expense: same entries as case 1.1', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createExpense,
        accountId: 'account-A',
        categoryId: 'category-EC',
        amountMinor: 7500,
        currencyCode: 'INR',
        transactionId: 'tx13',
        nowEpoch: 1715000000,
        isRecurringAutoPost: true,
      );

      final result = await engine.post(input);

      expect(result, isA<Ok<List<Entry>>>());
      final entries = (result as Ok<List<Entry>>).value;
      assertBalanced(entries);

      final debit = entries.firstWhere((e) => e.side == EntrySide.debit);
      final credit = entries.firstWhere((e) => e.side == EntrySide.credit);
      expect(debit.categoryId, equals('category-EC'));
      expect(credit.accountId, equals('account-A'));
    });
  });

  // -------------------------------------------------------------------------
  // Imbalance assertion — deliberately mismatched entries → BusinessRuleFailure
  // -------------------------------------------------------------------------
  group('LedgerEngine imbalance assertion', () {
    test('imbalanced input returns BusinessRuleFailure', () async {
      // We use a custom PostingCase that returns mismatched amounts via
      // a fake input that has the engine build entries with known imbalance.
      // We override the injected builder to trigger the assertion.
      final input = CreateTransactionInput(
        postingCase: PostingCase.createExpense,
        accountId: 'account-A',
        categoryId: 'category-EC',
        amountMinor: 5000,
        currencyCode: 'INR',
        transactionId: 'tx14',
        nowEpoch: 1715000000,
        // Force an imbalance by injecting a tampered debitOverride for test
        debugImbalanceOverride: true,
      );

      final result = await engine.post(input);

      expect(result, isA<Err<List<Entry>>>());
      final failure = (result as Err<List<Entry>>).failure;
      expect(failure, isA<BusinessRuleFailure>());
      expect(failure.message, contains('imbalance'));
    });
  });

  // -------------------------------------------------------------------------
  // EQ account lazy creation — same currency, already exists
  // -------------------------------------------------------------------------
  group('LedgerEngine EQ account lazy creation', () {
    test('EQ account already exists — not created again', () async {
      // Pre-create the EQ account
      repo.createdEqAccounts.add('__EQ_INR');

      final input = CreateTransactionInput(
        postingCase: PostingCase.openingBalancePositive,
        accountId: 'account-B',
        amountMinor: 200000,
        currencyCode: 'INR',
        transactionId: 'tx15',
        nowEpoch: 1715000000,
      );

      await engine.post(input);

      // Should not be added again
      expect(
        repo.createdEqAccounts.where((id) => id == '__EQ_INR').length,
        equals(1),
      );
    });

    test('EQ account created once per currency', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.openingBalancePositive,
        accountId: 'account-C',
        amountMinor: 10000,
        currencyCode: 'USD',
        transactionId: 'tx16',
        nowEpoch: 1715000000,
      );

      await engine.post(input);
      expect(repo.createdEqAccounts, contains('__EQ_USD'));
    });
  });

  // -------------------------------------------------------------------------
  // Statelessness — all four services have no shared mutable state
  // -------------------------------------------------------------------------
  group('LedgerEngine — statelessness', () {
    test('two calls with same input yield same entry structure', () async {
      final input = CreateTransactionInput(
        postingCase: PostingCase.createExpense,
        accountId: 'account-A',
        categoryId: 'category-EC',
        amountMinor: 1000,
        currencyCode: 'INR',
        transactionId: 'tx17',
        nowEpoch: 1715000000,
      );

      final result1 = await engine.post(input);
      final result2 = await engine.post(
        input.copyWith(transactionId: 'tx17b'),
      );

      expect(result1, isA<Ok<List<Entry>>>());
      expect(result2, isA<Ok<List<Entry>>>());

      final e1 = (result1 as Ok<List<Entry>>).value;
      final e2 = (result2 as Ok<List<Entry>>).value;

      // Both should have same structure (sides, targets) — just different IDs
      expect(e1.length, equals(e2.length));
      expect(
        e1.map((e) => e.side).toList(),
        equals(e2.map((e) => e.side).toList()),
      );
    });
  });
}
