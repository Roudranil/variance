import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/accounts/data/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountRepository CRUD', () {
    test('createAccount creates account with correct fields', () async {
      final id = await repository.createAccount(
        name: 'Test Account',
        type: AccountType.cash,
        nature: AccountNature.asset,
        initialBalance: 1000.0,
      );

      final account = await repository.getAccount(id);
      expect(account, isNotNull);
      expect(account!.name, 'Test Account');
      expect(account.type, AccountType.cash);
      expect(account.nature, AccountNature.asset);
      expect(account.isUserVisible, true);
    });

    test('watchAllAccounts excludes deleted accounts', () async {
      final id = await repository.createAccount(
        name: 'To Delete',
        type: AccountType.cash,
        nature: AccountNature.asset,
      );

      // verify account appears
      var accounts = await repository.watchAllAccounts().first;
      expect(accounts.any((a) => a.id == id), true);

      // soft delete
      await repository.softDeleteAccount(id);

      // verify account is hidden
      accounts = await repository.watchAllAccounts().first;
      expect(accounts.any((a) => a.id == id), false);
    });

    test('watchAllAccounts excludes system accounts', () async {
      // create a user-visible account
      final visibleId = await repository.createAccount(
        name: 'Visible',
        type: AccountType.cash,
        nature: AccountNature.asset,
      );

      // create Opening Balances (system account)
      final systemId = await repository.getOrCreateOpeningBalancesAccount();

      final accounts = await repository.watchAllAccounts().first;

      expect(accounts.any((a) => a.id == visibleId), true);
      expect(accounts.any((a) => a.id == systemId), false);
    });
  });

  group('AccountRepository Balance Computation', () {
    test(
      'createAccount with initialBalance creates opening balance txn',
      () async {
        final id = await repository.createAccount(
          name: 'With Balance',
          type: AccountType.savings,
          nature: AccountNature.asset,
          initialBalance: 5000.0,
        );

        // balance should be computed from ledger entries
        final balance = await repository.getAccountBalance(id);
        expect(balance, 5000.0);

        // verify transaction was created
        final txs = await db.select(db.transactions).get();
        expect(txs.length, 1);
        expect(txs.first.type, TransactionType.adjustment);

        // verify ledger entries
        final entries = await db.select(db.ledgerEntries).get();
        expect(entries.length, 2); // debit to account, credit to equity
      },
    );

    test(
      'getAccountBalance returns 0 for new account without balance',
      () async {
        final id = await repository.createAccount(
          name: 'Empty',
          type: AccountType.cash,
          nature: AccountNature.asset,
          initialBalance: 0.0,
        );

        final balance = await repository.getAccountBalance(id);
        expect(balance, 0.0);
      },
    );

    test('canSoftDelete returns true for zero-balance account', () async {
      final id = await repository.createAccount(
        name: 'Zero Balance',
        type: AccountType.cash,
        nature: AccountNature.asset,
        initialBalance: 0.0,
      );

      final canDelete = await repository.canSoftDelete(id);
      expect(canDelete, true);
    });

    test('canSoftDelete returns false for non-zero balance account', () async {
      final id = await repository.createAccount(
        name: 'Has Balance',
        type: AccountType.cash,
        nature: AccountNature.asset,
        initialBalance: 100.0,
      );

      final canDelete = await repository.canSoftDelete(id);
      expect(canDelete, false);
    });
  });

  group('AccountRepository Metadata', () {
    test('updateAccount updates metadata fields', () async {
      final id = await repository.createAccount(
        name: 'Original',
        type: AccountType.creditCard,
        nature: AccountNature.liability,
        creditLimit: 50000.0,
      );

      var account = await repository.getAccount(id);
      expect(account!.creditLimit, 50000.0);

      // update metadata
      await repository.updateAccount(
        account.copyWith(name: 'Updated', creditLimit: const Value(75000.0)),
      );

      account = await repository.getAccount(id);
      expect(account!.name, 'Updated');
      expect(account.creditLimit, 75000.0);
    });
  });

  group('AccountRepository Opening Balances', () {
    test('getOrCreateOpeningBalancesAccount creates equity account', () async {
      final id = await repository.getOrCreateOpeningBalancesAccount();

      final account = await repository.getAccount(id);
      expect(account, isNotNull);
      expect(account!.name, AccountRepository.openingBalancesAccountName);
      expect(account.nature, AccountNature.equity);
      expect(account.isUserVisible, false);
    });

    test(
      'getOrCreateOpeningBalancesAccount returns same ID on second call',
      () async {
        final id1 = await repository.getOrCreateOpeningBalancesAccount();
        final id2 = await repository.getOrCreateOpeningBalancesAccount();

        expect(id1, id2);
      },
    );
  });
}
