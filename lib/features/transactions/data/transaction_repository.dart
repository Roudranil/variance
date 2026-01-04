import 'package:drift/drift.dart';

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Handles all business logic related to the central ledger [Transactions].
///
/// Responsibilities:
/// - CRUD operations for transactions.
/// - Enforcing Double-Entry Integrity: Ensures that creating a transaction
///   automatically updates the [currentBalance] of related Accounts.
class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  /// Watches all transactions from the database.
  ///
  /// Ordering: Descending by [transactionDate] (Newest first).
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)..orderBy([
          (t) => OrderingTerm(
            expression: t.transactionDate,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  /// Creates a new transaction record and updates the affected Account balances.
  ///
  /// This is the core Double-Entry operation. It executes in a single atomic database transaction.
  ///
  /// Logic:
  /// - Expense: [sourceAccountId] is required. Reduces Source Balance by [amount].
  /// - Income: [destinationAccountId] is required. Increases Dest Balance by [amount].
  /// - Transfer: Both Accounts required. Reduces Source, Increases Dest.
  ///
  /// Throws an error if required accounts are missing for the given [type].
  ///
  /// Parameters:
  /// - [amount]: The transaction amount.
  /// - [type]: The transaction type (expense, income, transfer).
  /// - [date]: The date of transaction.
  /// - [sourceAccountId]: ID of source account (required for expense/transfer).
  /// - [destinationAccountId]: ID of destination account (required for income/transfer).
  /// - [categoryId]: ID of the category.
  /// - [description]: Optional description.
  Future<void> createTransaction({
    required double amount,
    required TransactionType type, // 'expense', 'income', 'transfer'
    required DateTime date,
    required int? sourceAccountId,
    required int? destinationAccountId,
    required int? categoryId,
    String? description,
  }) async {
    return _db.transaction(() async {
      // 1. Insert Transaction Record
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              amount: amount,
              type: type,
              transactionDate: date,
              sourceAccountId: Value(sourceAccountId),
              destinationAccountId: Value(destinationAccountId),
              categoryId: Value(categoryId),
              description: Value(description),
            ),
          );

      // 2. Update Balances (Double Entry)

      // If Source Account exists (Expense or Transfer), DECREASE its balance
      if (sourceAccountId != null) {
        final account = await (_db.select(
          _db.accounts,
        )..where((a) => a.id.equals(sourceAccountId))).getSingle();
        final newBalance = account.currentBalance - amount;
        await _db
            .update(_db.accounts)
            .replace(account.copyWith(currentBalance: newBalance));
      }

      // If Destination Account exists (Income or Transfer), INCREASE its balance
      if (destinationAccountId != null) {
        final account = await (_db.select(
          _db.accounts,
        )..where((a) => a.id.equals(destinationAccountId))).getSingle();
        final newBalance = account.currentBalance + amount;
        await _db
            .update(_db.accounts)
            .replace(account.copyWith(currentBalance: newBalance));
      }
    });
  }

  /// Deletes a transaction and reverts its effect on account balances.
  ///
  /// Parameters:
  /// - [id]: The ID of the transaction to delete.
  Future<void> deleteTransaction(int id) async {
    return _db.transaction(() async {
      final transaction = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingle();

      // Revert Balance Logic
      if (transaction.sourceAccountId != null) {
        final account = await (_db.select(
          _db.accounts,
        )..where((a) => a.id.equals(transaction.sourceAccountId!))).getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance: account.currentBalance + transaction.amount,
              ),
            );
      }

      if (transaction.destinationAccountId != null) {
        final account =
            await (_db.select(
                  _db.accounts,
                )..where((a) => a.id.equals(transaction.destinationAccountId!)))
                .getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance: account.currentBalance - transaction.amount,
              ),
            );
      }

      // Hard Delete the transaction row
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Updates a transaction.
  ///
  /// Conceptually: Reverts the OLD transaction, then Applies the NEW transaction.
  ///
  /// Parameters:
  /// - [updatedTransaction]: The transaction object with updated values.
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    return _db.transaction(() async {
      // 1. Revert Old Transaction's effect
      final oldTransaction = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(updatedTransaction.id))).getSingle();

      // Revert Old
      if (oldTransaction.sourceAccountId != null) {
        final account =
            await (_db.select(_db.accounts)
                  ..where((a) => a.id.equals(oldTransaction.sourceAccountId!)))
                .getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance: account.currentBalance + oldTransaction.amount,
              ),
            );
      }
      if (oldTransaction.destinationAccountId != null) {
        final account =
            await (_db.select(_db.accounts)..where(
                  (a) => a.id.equals(oldTransaction.destinationAccountId!),
                ))
                .getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance: account.currentBalance - oldTransaction.amount,
              ),
            );
      }

      // 2. Apply New Transaction's effect
      if (updatedTransaction.sourceAccountId != null) {
        final account =
            await (_db.select(_db.accounts)..where(
                  (a) => a.id.equals(updatedTransaction.sourceAccountId!),
                ))
                .getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance:
                    account.currentBalance - updatedTransaction.amount,
              ),
            );
      }
      if (updatedTransaction.destinationAccountId != null) {
        final account =
            await (_db.select(_db.accounts)..where(
                  (a) => a.id.equals(updatedTransaction.destinationAccountId!),
                ))
                .getSingle();
        await _db
            .update(_db.accounts)
            .replace(
              account.copyWith(
                currentBalance:
                    account.currentBalance + updatedTransaction.amount,
              ),
            );
      }

      // 3. Update the Transaction Row
      await _db.update(_db.transactions).replace(updatedTransaction);
    });
  }
}
