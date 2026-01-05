import 'package:drift/drift.dart';

import 'package:variance/core/utils/logger.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/accounts/data/account_repository.dart';

/// Manages [Transactions] and [LedgerEntries] for double-entry bookkeeping.
///
/// This repository enforces the fundamental DEB invariant: for every
/// transaction, sum(debits) = sum(credits). Transactions are immutable once
/// created; to "edit" a transaction, the original is voided and a new one is
/// created.
class TransactionRepository {
  final AppDatabase _db;
  final AccountRepository _accountRepository;

  /// Creates a new instance of [TransactionRepository].
  ///
  /// Parameters:
  /// - [db]: The database instance to use.
  /// - [accountRepository]: The account repository for accessing Opening
  ///   Balances account.
  TransactionRepository(this._db, this._accountRepository);

  /// Watches all non-void transactions ordered by date (newest first).
  ///
  /// Returns a [Stream] of [Transaction] lists that updates when data changes.
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..where((t) => t.isVoid.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  /// Gets a single transaction by ID.
  ///
  /// Returns null if the transaction does not exist.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the transaction.
  Future<Transaction?> getTransaction(int id) {
    return (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets all ledger entries for a transaction.
  ///
  /// Returns a list of [LedgerEntry] objects for the given transaction.
  ///
  /// Parameters:
  /// - [transactionId]: The unique identifier of the transaction.
  Future<List<LedgerEntry>> getLedgerEntries(int transactionId) {
    return (_db.select(
      _db.ledgerEntries,
    )..where((e) => e.transactionId.equals(transactionId))).get();
  }

  /// Creates an expense transaction.
  ///
  /// An expense represents money leaving a user account to an expense category.
  ///
  /// Ledger entries created:
  /// - DEBIT: Category's linked account (expense increases)
  /// - CREDIT: Source account (asset decreases)
  ///
  /// Returns the unique identifier of the created transaction.
  ///
  /// Parameters:
  /// - [accountId]: The source account (money leaves this account).
  /// - [categoryId]: The expense category.
  /// - [amount]: The transaction amount (must be positive).
  /// - [date]: The date of the transaction.
  /// - [note]: Optional user note.
  /// - [externalReference]: Optional external reference (e.g., SMS ID).
  Future<int> createExpense({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? externalReference,
  }) async {
    return _db.transaction(() async {
      // get the category's linked account
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingle();

      // create the transaction
      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              transactionDate: date,
              type: TransactionType.expense,
              userNote: Value(note),
              externalReference: Value(externalReference),
            ),
          );

      // create ledger entries
      // debit the expense account (expense increases)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: category.linkedAccountId,
              amount: amount,
              side: LedgerSide.debit,
            ),
          );

      // credit the source account (asset decreases)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: accountId,
              amount: amount,
              side: LedgerSide.credit,
            ),
          );

      VarianceLogger.info(
        'Created expense: txId=$transactionId, amount=$amount, account=$accountId, category=$categoryId',
      );
      return transactionId;
    });
  }

  /// Creates an income transaction.
  ///
  /// An income represents money entering a user account from an income
  /// category.
  ///
  /// Ledger entries created:
  /// - DEBIT: Destination account (asset increases)
  /// - CREDIT: Category's linked account (income increases)
  ///
  /// Returns the unique identifier of the created transaction.
  ///
  /// Parameters:
  /// - [accountId]: The destination account (money enters this account).
  /// - [categoryId]: The income category.
  /// - [amount]: The transaction amount (must be positive).
  /// - [date]: The date of the transaction.
  /// - [note]: Optional user note.
  /// - [externalReference]: Optional external reference (e.g., SMS ID).
  Future<int> createIncome({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? externalReference,
  }) async {
    return _db.transaction(() async {
      // get the category's linked account
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingle();

      // create the transaction
      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              transactionDate: date,
              type: TransactionType.income,
              userNote: Value(note),
              externalReference: Value(externalReference),
            ),
          );

      // create ledger entries
      // debit the destination account (asset increases)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: accountId,
              amount: amount,
              side: LedgerSide.debit,
            ),
          );

      // credit the income account (income increases)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: category.linkedAccountId,
              amount: amount,
              side: LedgerSide.credit,
            ),
          );

      VarianceLogger.info(
        'Created income: txId=$transactionId, amount=$amount, account=$accountId, category=$categoryId',
      );
      return transactionId;
    });
  }

  /// Creates a transfer transaction between two user accounts.
  ///
  /// A transfer represents money moving from one account to another.
  ///
  /// Ledger entries created:
  /// - DEBIT: Destination account (receives money)
  /// - CREDIT: Source account (sends money)
  ///
  /// Returns the unique identifier of the created transaction.
  ///
  /// Parameters:
  /// - [fromAccountId]: The source account (money leaves).
  /// - [toAccountId]: The destination account (money enters).
  /// - [amount]: The transaction amount (must be positive).
  /// - [date]: The date of the transaction.
  /// - [note]: Optional user note.
  /// - [externalReference]: Optional external reference.
  Future<int> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
    String? externalReference,
  }) async {
    return _db.transaction(() async {
      // create the transaction
      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              transactionDate: date,
              type: TransactionType.transfer,
              userNote: Value(note),
              externalReference: Value(externalReference),
            ),
          );

      // create ledger entries
      // debit the destination account (receives money)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: toAccountId,
              amount: amount,
              side: LedgerSide.debit,
            ),
          );

      // credit the source account (sends money)
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: fromAccountId,
              amount: amount,
              side: LedgerSide.credit,
            ),
          );

      VarianceLogger.info(
        'Created transfer: txId=$transactionId, amount=$amount, from=$fromAccountId, to=$toAccountId',
      );
      return transactionId;
    });
  }

  /// Creates an adjustment transaction to correct an account balance.
  ///
  /// This creates a transaction against the Opening Balances equity account
  /// to adjust the balance to the specified target value.
  ///
  /// Returns the unique identifier of the created transaction.
  ///
  /// Parameters:
  /// - [accountId]: The account to adjust.
  /// - [newBalance]: The target balance after adjustment.
  Future<int> createAdjustment({
    required int accountId,
    required double newBalance,
  }) async {
    return _db.transaction(() async {
      // get current balance
      final currentBalance = await _accountRepository.getAccountBalance(
        accountId,
      );
      final difference = newBalance - currentBalance;

      if (difference.abs() < 0.01) {
        // no adjustment needed
        VarianceLogger.warning(
          'Adjustment skipped: balance already at target for account $accountId',
        );
        throw ArgumentError('Balance is already at the target value');
      }

      // get account nature to determine entry sides
      final account = await _accountRepository.getAccount(accountId);
      if (account == null) {
        throw ArgumentError('Account not found');
      }

      final openingBalancesId = await _accountRepository
          .getOrCreateOpeningBalancesAccount();

      // create the transaction
      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              transactionDate: DateTime.now(),
              type: TransactionType.adjustment,
              userNote: const Value('Balance adjustment'),
            ),
          );

      // determine entry sides based on account nature and difference sign
      final isPositive = difference > 0;
      LedgerSide accountSide;
      LedgerSide equitySide;

      if (account.nature == AccountNature.asset ||
          account.nature == AccountNature.expense) {
        // asset/expense: increase = debit, decrease = credit
        accountSide = isPositive ? LedgerSide.debit : LedgerSide.credit;
        equitySide = isPositive ? LedgerSide.credit : LedgerSide.debit;
      } else {
        // liability/equity/income: increase = credit, decrease = debit
        accountSide = isPositive ? LedgerSide.credit : LedgerSide.debit;
        equitySide = isPositive ? LedgerSide.debit : LedgerSide.credit;
      }

      // create ledger entries
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: accountId,
              amount: difference.abs(),
              side: accountSide,
            ),
          );

      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: openingBalancesId,
              amount: difference.abs(),
              side: equitySide,
            ),
          );

      VarianceLogger.info(
        'Created adjustment: txId=$transactionId, account=$accountId, diff=${difference.abs()}, newBalance=$newBalance',
      );
      return transactionId;
    });
  }

  /// Voids a transaction.
  ///
  /// The transaction and its ledger entries remain in the database but are
  /// excluded from balance calculations and hidden from the UI.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the transaction to void.
  Future<void> voidTransaction(int id) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isVoid: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    VarianceLogger.info('Voided transaction $id');
  }

  /// Edits a transaction by voiding the original and creating a new one.
  ///
  /// This method implements the void + recreate pattern for immutable ledger
  /// integrity.
  ///
  /// Returns the unique identifier of the new transaction.
  ///
  /// Parameters:
  /// - [originalTransactionId]: The transaction to void.
  /// - [type]: The type of the new transaction.
  /// - [accountId]: The primary account for the new transaction.
  /// - [categoryId]: The category (required for expense/income).
  /// - [secondaryAccountId]: The secondary account (required for transfers).
  /// - [amount]: The new amount.
  /// - [date]: The new date.
  /// - [note]: The new note.
  Future<int> editTransaction({
    required int originalTransactionId,
    required TransactionType type,
    required int accountId,
    int? categoryId,
    int? secondaryAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    return _db.transaction(() async {
      // void the original
      await voidTransaction(originalTransactionId);

      // create the new transaction based on type
      switch (type) {
        case TransactionType.expense:
          if (categoryId == null) {
            throw ArgumentError('categoryId is required for expense');
          }
          return createExpense(
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            date: date,
            note: note,
          );

        case TransactionType.income:
          if (categoryId == null) {
            throw ArgumentError('categoryId is required for income');
          }
          return createIncome(
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            date: date,
            note: note,
          );

        case TransactionType.transfer:
          if (secondaryAccountId == null) {
            throw ArgumentError('secondaryAccountId is required for transfer');
          }
          return createTransfer(
            fromAccountId: accountId,
            toAccountId: secondaryAccountId,
            amount: amount,
            date: date,
            note: note,
          );

        case TransactionType.adjustment:
          throw ArgumentError(
            'Use createAdjustment directly for adjustment transactions',
          );
      }
    });
  }
}
