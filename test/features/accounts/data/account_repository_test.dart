import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/accounts/data/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository repository;

  setUp(() {
    // strict: true enables detailed verification of query usage in drift
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountRepository CRUD', () {
    test('createAccount adds a new account with correct defaults', () async {
      final companion = AccountsCompanion.insert(
        name: 'Test Account',
        type: AccountType.savings,
        initialBalance: const Value(1000.0),
        currentBalance: const Value(1000.0),
      );

      final id = await repository.createAccount(companion);
      expect(id, isNotNull);

      final validAccount = await repository.getAccount(id);
      expect(validAccount, isNotNull);
      expect(validAccount!.name, 'Test Account');
      expect(validAccount.initialBalance, 1000.0);
      expect(validAccount.includeInTotals, true); // Default
      expect(validAccount.currencyCode, 'INR'); // Default
      expect(validAccount.isDeleted, false); // Default
    });

    test('deleteAccount sets isDeleted to true', () async {
      final id = await repository.createAccount(
        AccountsCompanion.insert(
          name: 'To Delete',
          type: AccountType.cash,
          currentBalance: const Value(0),
        ),
      );

      await repository.deleteAccount(id);

      // getAccount should still return it (repository.getAccount doesn't filter deleted?
      // Checking implementation... yes, getAccount filters by ID only, doesn't check isDeleted.
      // But watchAllAccounts DOES filter.)
      final deletedAccount = await repository.getAccount(id);
      expect(deletedAccount!.isDeleted, true);

      final activeAccounts = await repository.watchAllAccounts().first;
      expect(activeAccounts.any((a) => a.id == id), false);
    });

    test('watchAllAccounts returns ordered active accounts', () async {
      await repository.createAccount(
        AccountsCompanion.insert(
          name: 'B Account',
          type: AccountType.cash,
          currentBalance: const Value(0),
        ),
      );
      await repository.createAccount(
        AccountsCompanion.insert(
          name: 'A Account',
          type: AccountType.cash,
          currentBalance: const Value(0),
        ),
      );

      final accounts = await repository.watchAllAccounts().first;
      expect(accounts.length, 2);
      expect(accounts[0].name, 'A Account'); // Ordered by name
      expect(accounts[1].name, 'B Account');
    });
  });

  group('AccountRepository Logic (Auto-Adjustment)', () {
    late int accountId;

    setUp(() async {
      accountId = await repository.createAccount(
        AccountsCompanion.insert(
          name: 'Logic Test',
          type: AccountType.bankAccount,
          currentBalance: const Value(5000.0),
          initialBalance: const Value(5000.0),
        ),
      );
    });

    test('Updating name does NOT create an adjustment transaction', () async {
      final account = await repository.getAccount(accountId);
      final updated = account!.copyWith(name: 'New Name');

      await repository.updateAccount(updated);

      final transactions = await db.select(db.transactions).get();
      expect(transactions.isEmpty, true);

      final stored = await repository.getAccount(accountId);
      expect(stored!.name, 'New Name');
      expect(stored.currentBalance, 5000.0);
    });

    test('Increasing balance creates an "Income-like" adjustment', () async {
      // Balance 5000 -> 6000 (Diff +1000)
      final account = await repository.getAccount(accountId);
      final updated = account!.copyWith(currentBalance: 6000.0);

      await repository.updateAccount(updated);

      // Verify Account
      final stored = await repository.getAccount(accountId);
      expect(stored!.currentBalance, 6000.0);

      // Verify Transaction
      final transactions = await db.select(db.transactions).get();
      expect(transactions.length, 1);

      final txn = transactions.first;
      expect(txn.type, TransactionType.adjustment);
      expect(txn.amount, 1000.0);
      expect(txn.destinationAccountId, accountId); // Income-like
      expect(txn.sourceAccountId, isNull);
    });

    test('Decreasing balance creates an "Expense-like" adjustment', () async {
      // Balance 5000 -> 4000 (Diff -1000)
      final account = await repository.getAccount(accountId);
      final updated = account!.copyWith(currentBalance: 4000.0);

      await repository.updateAccount(updated);

      // Verify Account
      final stored = await repository.getAccount(accountId);
      expect(stored!.currentBalance, 4000.0);

      // Verify Transaction
      final transactions = await db.select(db.transactions).get();
      expect(transactions.length, 1);

      final txn = transactions.first;
      expect(txn.type, TransactionType.adjustment);
      expect(txn.amount, 1000.0);
      expect(txn.destinationAccountId, isNull);
      expect(txn.sourceAccountId, accountId); // Expense-like
    });
  });
}
