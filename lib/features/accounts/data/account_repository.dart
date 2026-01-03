import 'package:drift/drift.dart';
import 'package:variance/database/database.dart';

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
  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(
      _db.accounts,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
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
  Future<bool> updateAccount(Account account) {
    return _db.update(_db.accounts).replace(account);
  }

  /// Deletes an account.
  ///
  /// Note: This logic assumes no cascading delete constraints are blocking the deletion.
  /// If transactions exist, this might fail depending on FK settings.
  Future<int> deleteAccount(int id) {
    return (_db.delete(_db.accounts)..where((tbl) => tbl.id.equals(id))).go();
  }
}
