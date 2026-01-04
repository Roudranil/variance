import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/accounts/data/account_repository.dart';
import 'package:variance/features/transactions/data/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repository;
  late AccountRepository accountRepository;

  late int sourceId;
  late int destId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TransactionRepository(db);
    accountRepository = AccountRepository(db);

    // Setup initial accounts
    sourceId = await accountRepository.createAccount(
      AccountsCompanion.insert(
        name: 'Source',
        type: AccountType.cash,
        currentBalance: const Value(1000.0), // Start with 1000
      ),
    );

    destId = await accountRepository.createAccount(
      AccountsCompanion.insert(
        name: 'Dest',
        type: AccountType.savings,
        currentBalance: const Value(500.0), // Start with 500
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepository Double-Entry', () {
    test('createTransaction (Expense) reduces source balance', () async {
      await repository.createTransaction(
        amount: 100.0,
        type: TransactionType.expense,
        date: DateTime.now(),
        sourceAccountId: sourceId,
        destinationAccountId: null,
        categoryId: null,
      );

      final source = await accountRepository.getAccount(sourceId);
      expect(source!.currentBalance, 900.0); // 1000 - 100

      final txs = await repository.watchAllTransactions().first;
      expect(txs.length, 1);
      expect(txs.first.amount, 100.0);
    });

    test('createTransaction (Income) increases destination balance', () async {
      await repository.createTransaction(
        amount: 200.0,
        type: TransactionType.income,
        date: DateTime.now(),
        sourceAccountId: null,
        destinationAccountId: destId,
        categoryId: null,
      );

      final dest = await accountRepository.getAccount(destId);
      expect(dest!.currentBalance, 700.0); // 500 + 200
    });

    test('createTransaction (Transfer) moves money between accounts', () async {
      await repository.createTransaction(
        amount: 300.0,
        type: TransactionType.transfer,
        date: DateTime.now(),
        sourceAccountId: sourceId,
        destinationAccountId: destId,
        categoryId: null,
      );

      final source = await accountRepository.getAccount(sourceId);
      final dest = await accountRepository.getAccount(destId);

      expect(source!.currentBalance, 700.0); // 1000 - 300
      expect(dest!.currentBalance, 800.0); // 500 + 300
    });
  });

  group('TransactionRepository Cascade/Revert', () {
    test('deleteTransaction reverts balance changes', () async {
      // Setup: Create expense of 100
      await repository.createTransaction(
        amount: 100.0,
        type: TransactionType.expense,
        date: DateTime.now(),
        sourceAccountId: sourceId,
        destinationAccountId: null,
        categoryId: null,
      );

      // Verify initial state
      var source = await accountRepository.getAccount(sourceId);
      expect(source!.currentBalance, 900.0);

      final txs = await repository.watchAllTransactions().first;
      final txId = txs.first.id;

      // Act: Delete
      await repository.deleteTransaction(txId);

      // Assert: Balance reverted
      source = await accountRepository.getAccount(sourceId);
      expect(source!.currentBalance, 1000.0);

      // Transaction gone
      final remainingTxs = await repository.watchAllTransactions().first;
      expect(remainingTxs.isEmpty, true);
    });

    test(
      'updateTransaction (Amount Change) adjusts balances correctly',
      () async {
        // Setup: Expense of 100. Source: 1000 -> 900
        await repository.createTransaction(
          amount: 100.0,
          type: TransactionType.expense,
          date: DateTime.now(),
          sourceAccountId: sourceId,
          destinationAccountId: null,
          categoryId: null,
        );

        final txs = await repository.watchAllTransactions().first;
        final originalTx = txs.first;

        // Act: Update amount to 200. Should revert 100 (Back to 1000), then apply 200 (Down to 800).
        final updatedTx = originalTx.copyWith(amount: 200.0);
        await repository.updateTransaction(updatedTx);

        // Assert
        final source = await accountRepository.getAccount(sourceId);
        expect(source!.currentBalance, 800.0);
      },
    );

    test('updateTransaction (Account Change) moves balance effect', () async {
      // Setup: Expense of 100 on Source. Source: 900, Dest: 500.
      await repository.createTransaction(
        amount: 100.0,
        type: TransactionType.expense,
        date: DateTime.now(),
        sourceAccountId: sourceId,
        destinationAccountId: null,
        categoryId: null,
      );

      final txs = await repository.watchAllTransactions().first;
      final originalTx = txs.first;

      // Act: Change Source to Dest (Mistake correction).
      // Should revert Source (900 -> 1000)
      // Should apply to Dest (500 -> 400)
      final updatedTx = originalTx.copyWith(sourceAccountId: Value(destId));
      await repository.updateTransaction(updatedTx);

      // Assert
      final source = await accountRepository.getAccount(sourceId);
      expect(source!.currentBalance, 1000.0);

      final dest = await accountRepository.getAccount(destId);
      expect(dest!.currentBalance, 400.0);
    });
  });
}
