// lib/data/database/daos/account_dao.dart
//
// DAO for the `accounts` and `account_details` aggregates.
//
// Responsibilities:
//   - CRUD on accounts and account_details tables
//   - Reactive streams for the account list and single-account screens
//   - Balance query helpers (debit-credit aggregation from entries)
//   - Soft-delete support (is_deleted flag, deleted_at epoch)
//   - Name-uniqueness guard including soft-deleted rows
//
// Test cases (see test/data/database/account_dao_test.dart):
//   1. insertAccount — row appears in watchVisibleAccounts stream
//   2. updateAccount — stream emits updated row
//   3. softDeleteAccount — row disappears from watchVisibleAccounts stream
//   4. watchById — emits null after soft-delete
//   5. isNameTaken — returns true for active AND soft-deleted rows
//   6. findSoftDeletedByNameAndCategory — returns soft-deleted match
//   7. watchBalance — returns 0 for a new account; reflects posted entries
//   8. AccountDetailDao: insertOrReplaceDetail — row queryable by accountId
//   9. AccountDetailDao: getDetailsForAccount — returns all rows for account

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/account_details_table.dart';
import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/entries_table.dart';

part 'account_dao.g.dart';

/// DAO for CRUD operations on `accounts` and `account_details`.
///
/// System accounts ([Account.isSystem] = true) are excluded from the default
/// watch stream. Balance computation is derived from the `entries` table.
@DriftAccessor(tables: [Accounts, AccountDetails, Entries])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  /// Creates a new [AccountDao] bound to [db].
  AccountDao(super.db);

  // -----------------------------------------------------------------------
  // Account queries
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

  /// Returns a reactive stream of a single account by [id].
  ///
  /// Emits null when no matching non-deleted account exists.
  ///
  /// Parameters:
  /// - [id]: UUID of the account to watch.
  Stream<Account?> watchById(String id) {
    return (select(accounts)
          ..where((a) => a.id.equals(id) & a.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Returns the account row for [id], or null if not found or soft-deleted.
  ///
  /// Parameters:
  /// - [id]: UUID of the account.
  Future<Account?> findById(String id) {
    return (select(accounts)
          ..where((a) => a.id.equals(id) & a.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Returns true if any account (including soft-deleted) has [name].
  ///
  /// Enforces the uniqueness invariant: names are unique across the full
  /// accounts table, including soft-deleted rows (TC-035).
  ///
  /// Parameters:
  /// - [name]: Display name to check.
  Future<bool> isNameTaken(String name) async {
    final row = await (select(accounts)
          ..where((a) => a.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Returns the soft-deleted account matching [name] and [category], or null.
  ///
  /// Used by [CreateAccountUseCase] to offer reinstatement when the user tries
  /// to create an account whose name was previously deleted.
  ///
  /// Parameters:
  /// - [name]: Exact display name to match.
  /// - [category]: Account category string value.
  Future<Account?> findSoftDeletedByNameAndCategory(
    String name,
    String category,
  ) {
    return (select(accounts)
          ..where(
            (a) =>
                a.name.equals(name) &
                a.accountCategory.equals(category) &
                a.isDeleted.equals(true),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  // -----------------------------------------------------------------------
  // Account writes
  // -----------------------------------------------------------------------

  /// Inserts a new account row.
  ///
  /// Returns the number of affected rows (always 1 on success).
  ///
  /// Parameters:
  /// - [account]: The companion carrying the column values to insert.
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Updates an existing account row.
  ///
  /// Returns the number of affected rows (1 on success, 0 if not found).
  ///
  /// Parameters:
  /// - [account]: The companion carrying only the fields to update.
  Future<bool> updateAccount(AccountsCompanion account) {
    return update(accounts).replace(account);
  }

  /// Soft-deletes the account identified by [id].
  ///
  /// Sets `is_deleted = true` and `deleted_at = [deletedAtEpoch]`.
  ///
  /// Parameters:
  /// - [id]: UUID of the account to soft-delete.
  /// - [deletedAtEpoch]: Unix epoch seconds to record as the deletion time.
  Future<int> softDeleteAccount(String id, int deletedAtEpoch) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAtEpoch),
        updatedAt: Value(deletedAtEpoch),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Balance query
  // -----------------------------------------------------------------------

  /// Returns a reactive stream of the computed balance for account [accountId].
  ///
  /// Balance = Σ(amount WHERE side = 'debit') - Σ(amount WHERE side = 'credit')
  /// across all entries linked to [accountId].
  ///
  /// The stream emits 0 if no entries exist. Minor-unit integer arithmetic is
  /// used throughout — no floating point.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account.
  Stream<int> watchBalance(String accountId) {
    // Custom SQL: SUM with conditional aggregation avoids a self-join.
    // COALESCE ensures 0 is returned when no rows match.
    final query = customSelect(
      '''
      SELECT
        COALESCE(
          SUM(CASE WHEN side = 'debit'  THEN amount_minor ELSE 0 END), 0
        ) -
        COALESCE(
          SUM(CASE WHEN side = 'credit' THEN amount_minor ELSE 0 END), 0
        ) AS balance
      FROM entries
      WHERE account_id = ?
      ''',
      variables: [Variable.withString(accountId)],
      // entries is provided by _$AccountDaoMixin (generated) since Entries
      // is listed in @DriftAccessor tables.
      readsFrom: {entries},
    );

    return query.watchSingle().map(
          (row) => row.readNullable<int>('balance') ?? 0,
        );
  }

  // -----------------------------------------------------------------------
  // Account details
  // -----------------------------------------------------------------------

  /// Returns all [AccountDetail] rows for the given [accountId].
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  Future<List<AccountDetail>> getDetailsForAccount(String accountId) {
    return (select(accountDetails)..where((d) => d.accountId.equals(accountId)))
        .get();
  }

  /// Inserts or replaces a single [AccountDetail] row.
  ///
  /// Uses `INSERT OR REPLACE` semantics based on the primary key [id].
  ///
  /// Parameters:
  /// - [detail]: The companion carrying the values to persist.
  Future<int> insertOrReplaceDetail(AccountDetailsCompanion detail) {
    return into(accountDetails).insertOnConflictUpdate(detail);
  }

  /// Deletes all [AccountDetail] rows for [accountId] with the given [keys].
  ///
  /// Used when rebuilding the detail set for an account.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  /// - [keys]: List of detail key strings to delete.
  Future<int> deleteDetails(String accountId, List<String> keys) {
    return (delete(accountDetails)
          ..where(
            (d) => d.accountId.equals(accountId) & d.detailKey.isIn(keys),
          ))
        .go();
  }
}
