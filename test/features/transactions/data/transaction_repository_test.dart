import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/database/integrity.dart';
import 'package:variance/features/accounts/data/account_repository.dart';
import 'package:variance/features/categories/data/category_repository.dart';
import 'package:variance/features/transactions/data/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late TransactionRepository repository;
  late IntegrityService integrity;

  late int cashAccountId;
  late int savingsAccountId;
  late int foodCategoryId;
  late int salaryCategoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accountRepository = AccountRepository(db);
    categoryRepository = CategoryRepository(db);
    repository = TransactionRepository(db, accountRepository);
    integrity = IntegrityService(db);

    // setup test accounts
    cashAccountId = await accountRepository.createAccount(
      name: 'Cash',
      type: AccountType.cash,
      nature: AccountNature.asset,
      initialBalance: 10000.0,
    );

    savingsAccountId = await accountRepository.createAccount(
      name: 'Savings',
      type: AccountType.savings,
      nature: AccountNature.asset,
      initialBalance: 50000.0,
    );

    // setup test categories
    foodCategoryId = await categoryRepository.createCategory(
      name: 'Food',
      kind: CategoryKind.expense,
    );

    salaryCategoryId = await categoryRepository.createCategory(
      name: 'Salary',
      kind: CategoryKind.income,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepository Expense', () {
    test('createExpense reduces account balance', () async {
      final initialBalance = await accountRepository.getAccountBalance(
        cashAccountId,
      );
      expect(initialBalance, 10000.0);

      await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
        note: 'Lunch',
      );

      final newBalance = await accountRepository.getAccountBalance(
        cashAccountId,
      );
      expect(newBalance, 9500.0); // 10000 - 500
    });

    test('createExpense creates balanced ledger entries', () async {
      final txId = await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
      );

      final isBalanced = await integrity.checkTransactionBalance(txId);
      expect(isBalanced, true);
    });

    test('createExpense increases category account balance', () async {
      final category = await categoryRepository.getCategory(foodCategoryId);

      await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
      );

      final categoryBalance = await accountRepository.getAccountBalance(
        category!.linkedAccountId,
      );
      expect(categoryBalance, 500.0); // expense account debited = positive
    });
  });

  group('TransactionRepository Income', () {
    test('createIncome increases account balance', () async {
      final initialBalance = await accountRepository.getAccountBalance(
        savingsAccountId,
      );
      expect(initialBalance, 50000.0);

      await repository.createIncome(
        accountId: savingsAccountId,
        categoryId: salaryCategoryId,
        amount: 25000.0,
        date: DateTime.now(),
        note: 'Monthly salary',
      );

      final newBalance = await accountRepository.getAccountBalance(
        savingsAccountId,
      );
      expect(newBalance, 75000.0); // 50000 + 25000
    });

    test('createIncome creates balanced ledger entries', () async {
      final txId = await repository.createIncome(
        accountId: savingsAccountId,
        categoryId: salaryCategoryId,
        amount: 25000.0,
        date: DateTime.now(),
      );

      final isBalanced = await integrity.checkTransactionBalance(txId);
      expect(isBalanced, true);
    });
  });

  group('TransactionRepository Transfer', () {
    test('createTransfer moves money between accounts', () async {
      final initialCash = await accountRepository.getAccountBalance(
        cashAccountId,
      );
      final initialSavings = await accountRepository.getAccountBalance(
        savingsAccountId,
      );

      await repository.createTransfer(
        fromAccountId: savingsAccountId,
        toAccountId: cashAccountId,
        amount: 5000.0,
        date: DateTime.now(),
        note: 'ATM withdrawal',
      );

      final newCash = await accountRepository.getAccountBalance(cashAccountId);
      final newSavings = await accountRepository.getAccountBalance(
        savingsAccountId,
      );

      expect(newCash, initialCash + 5000.0);
      expect(newSavings, initialSavings - 5000.0);
    });

    test('createTransfer creates balanced ledger entries', () async {
      final txId = await repository.createTransfer(
        fromAccountId: savingsAccountId,
        toAccountId: cashAccountId,
        amount: 5000.0,
        date: DateTime.now(),
      );

      final isBalanced = await integrity.checkTransactionBalance(txId);
      expect(isBalanced, true);
    });
  });

  group('TransactionRepository Void', () {
    test('voidTransaction excludes from balance calculation', () async {
      // create expense
      final txId = await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 1000.0,
        date: DateTime.now(),
      );

      // verify balance decreased
      var balance = await accountRepository.getAccountBalance(cashAccountId);
      expect(balance, 9000.0); // 10000 - 1000

      // void the transaction
      await repository.voidTransaction(txId);

      // balance should be restored since voided txs are excluded
      balance = await accountRepository.getAccountBalance(cashAccountId);
      expect(balance, 10000.0);
    });

    test('voidTransaction hides from watchAllTransactions', () async {
      final txId = await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 1000.0,
        date: DateTime.now(),
      );

      // verify transaction appears
      var txs = await repository.watchAllTransactions().first;
      // filter out opening balance transactions
      var userTxs = txs.where((t) => t.type == TransactionType.expense);
      expect(userTxs.any((t) => t.id == txId), true);

      // void
      await repository.voidTransaction(txId);

      // verify transaction is hidden
      txs = await repository.watchAllTransactions().first;
      userTxs = txs.where((t) => t.type == TransactionType.expense);
      expect(userTxs.any((t) => t.id == txId), false);
    });
  });

  group('TransactionRepository Edit', () {
    test('editTransaction voids original and creates new', () async {
      // create original expense
      final originalId = await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
      );

      // edit to different amount
      final newId = await repository.editTransaction(
        originalTransactionId: originalId,
        type: TransactionType.expense,
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 750.0,
        date: DateTime.now(),
      );

      expect(newId, isNot(originalId));

      // original should be voided
      final original = await repository.getTransaction(originalId);
      expect(original!.isVoid, true);

      // new should be active
      final newTx = await repository.getTransaction(newId);
      expect(newTx!.isVoid, false);

      // balance should reflect only the new amount
      // 10000 - 750 = 9250 (not 10000 - 500 - 750)
      final balance = await accountRepository.getAccountBalance(cashAccountId);
      expect(balance, 9250.0);
    });
  });

  group('TransactionRepository Adjustment', () {
    test('createAdjustment corrects balance to target', () async {
      // initial balance is 10000
      expect(await accountRepository.getAccountBalance(cashAccountId), 10000.0);

      // adjust to 8500 (decrease by 1500)
      await repository.createAdjustment(
        accountId: cashAccountId,
        newBalance: 8500.0,
      );

      expect(await accountRepository.getAccountBalance(cashAccountId), 8500.0);
    });

    test('createAdjustment creates balanced entries', () async {
      final txId = await repository.createAdjustment(
        accountId: cashAccountId,
        newBalance: 12000.0,
      );

      final isBalanced = await integrity.checkTransactionBalance(txId);
      expect(isBalanced, true);
    });
  });

  group('Global Integrity', () {
    test('checkGlobalEquation returns balanced after operations', () async {
      // perform various operations
      await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
      );

      await repository.createIncome(
        accountId: savingsAccountId,
        categoryId: salaryCategoryId,
        amount: 25000.0,
        date: DateTime.now(),
      );

      await repository.createTransfer(
        fromAccountId: savingsAccountId,
        toAccountId: cashAccountId,
        amount: 2000.0,
        date: DateTime.now(),
      );

      final result = await integrity.checkGlobalEquation();
      expect(result.isBalanced, true);
    });

    test('checkAllTransactionsBalance returns empty for valid data', () async {
      await repository.createExpense(
        accountId: cashAccountId,
        categoryId: foodCategoryId,
        amount: 500.0,
        date: DateTime.now(),
      );

      final unbalanced = await integrity.checkAllTransactionsBalance();
      expect(unbalanced, isEmpty);
    });
  });
}
