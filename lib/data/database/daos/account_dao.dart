// lib/data/database/daos/account_dao.dart
//
// DAO for the `accounts` and `account_details` aggregates.
//
// Responsibilities:
//   - CRUD on accounts and account_details tables
//   - Reactive stream for the account list screen
//   - Balance query helpers (debit-credit aggregation from entries)
//
// DAOs execute queries only — no domain logic belongs here.

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/account_details_table.dart';
import 'package:variance/data/database/tables/accounts_table.dart';

part 'account_dao.g.dart';

/// DAO for CRUD operations on `accounts` and `account_details`.
///
/// System accounts ([Account.isSystem] = true) are excluded from the default
/// watch stream. Balance computation is delegated to [EntryDao] or performed
/// via a raw query at the repository layer.
@DriftAccessor(tables: [Accounts, AccountDetails])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  /// Creates a new [AccountDao] bound to [db].
  AccountDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns a reactive stream of all non-deleted, non-system accounts,
  /// ordered by [displayOrder] ascending (NULLs last), then by name.
  Stream<List<Account>> watchVisibleAccounts() {
    return (select(accounts)
          ..where((a) => a.isDeleted.equals(false) & a.isSystem.equals(false))
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.displayOrder,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last,
                ),
            (a) => OrderingTerm.asc(a.name),
          ]))
        .watch();
  }

  /// Returns all [AccountDetail] rows for the given [accountId].
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  Future<List<AccountDetail>> getDetailsForAccount(String accountId) {
    return (select(accountDetails)..where((d) => d.accountId.equals(accountId)))
        .get();
  }

  /// Inserts a new account row.
  ///
  /// Returns the number of affected rows (always 1 on success).
  ///
  /// Parameters:
  /// - [account]: The companion carrying the column values to insert.
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }
}
