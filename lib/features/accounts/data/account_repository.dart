import 'package:drift/drift.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// **Account Repository**
///
/// Manages the lifecycle of [Accounts] entities.
///
/// **Responsibilities:**
/// *   Creating new accounts with initial balances.
/// *   Updating account details (name, type, limits).
/// *   Watching account balances for the UI.
class AccountRepository {
  final AppDatabase _db;

  AccountRepository(this._db);

  /// Watches all accounts ordered by name.
  /// Excluding deleted accounts.
  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Gets a single account by ID.
  Future<Account?> getAccount(int id) {
    return (_db.select(
      _db.accounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new account.
  Future<int> createAccount(AccountsCompanion account) {
    return _db.into(_db.accounts).insert(account);
  }

  /// Updates an existing account.
  /// If [currentBalance] is changed, creates an 'adjustment' Transaction.
  Future<void> updateAccount(Account account) async {
    return _db.transaction(() async {
      // 1. Fetch old account state to check for balance change
      final oldAccount = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(account.id))).getSingle();

      // 2. Check for Balance Discrepancy
      if (oldAccount.currentBalance != account.currentBalance) {
        final diff = account.currentBalance - oldAccount.currentBalance;
        // If diff is positive: Income/Adjustment (+). If negative: Expense/Adjustment (-)
        // We use ABS(diff) for amount and rely on logic or context if needed?
        // Actually, just creating a transaction with 'adjustment' type.
        // For adjustment, we can assign it to the account.
        // If diff is positive: 'Income' semantics (but type=adjustment). Destination = Account.
        // If diff is negative: 'Expense' semantics. Source = Account.

        final isPositive = diff > 0;
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                amount: diff.abs(),
                type: TransactionType.adjustment,
                transactionDate: DateTime.now(),
                // If positive, money came INTO account
                destinationAccountId: isPositive
                    ? Value(account.id)
                    : const Value(null),
                // If negative, money left account
                sourceAccountId: isPositive
                    ? const Value(null)
                    : Value(account.id),
                description: const Value('Manual Balance Adjustment'),
              ),
            );
      }

      // 3. Update the Account record
      await _db.update(_db.accounts).replace(account);
    });
  }

  /// Soft deletes an account.
  Future<void> deleteAccount(int id) {
    return (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(id))).write(
      AccountsCompanion(isDeleted: const Value(true)),
    );
  }
}
