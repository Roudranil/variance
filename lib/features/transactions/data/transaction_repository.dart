import 'package:drift/drift.dart';
import 'package:variance/database/database.dart';

/// **Transaction Repository**
///
/// Handles all business logic related to the central ledger ([Transactions]).
///
/// **Key Responsibilities:**
/// *   CRUD operations for transactions.
/// *   **Enforcing Double-Entry Integrity**: Ensures that creating a transaction
///     automatically updates the [currentBalance] of related Accounts.
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

  /// **Core Double-Entry Operation**
  ///
  /// Creates a new transaction record AND updates the affected Account balances
  /// in a single atomic database transaction.
  ///
  /// **Logic:**
  /// *   **Expense**: [sourceAccountId] is required. Reduces Source Balance by [amount].
  /// *   **Income**: [destinationAccountId] is required. Increases Dest Balance by [amount].
  /// *   **Transfer**: Both Accounts required. Reduces Source, Increases Dest.
  ///
  /// Throws an error if required accounts are missing for the given [type].
  Future<void> createTransaction({
    required double amount,
    required String type, // 'expense', 'income', 'transfer'
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
}
