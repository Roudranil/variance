// lib/data/database/tables/accounts_table.dart
//
// Drift table definition for `accounts`.
//
// Test cases (see test/data/database/schema_verifier_test.dart):
//   - accounts table exists in sqlite_master
//   - all required columns are present
//   - foreign key to currencies(code) is respected

import 'package:drift/drift.dart';

/// Drift table for user-facing financial accounts and system equity accounts.
///
/// Account balances are computed from `entries`, never stored.
/// System EQ accounts are flagged [isSystem] = true and hidden from all views.
class Accounts extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Display name. Uniqueness enforced at app layer (including soft-deleted).
  TextColumn get name => text()();

  /// Account type. CHECK constraint enforced at domain layer.
  TextColumn get accountCategory => text()();

  /// Opening balance in minor units. Applied once as a ledger entry.
  IntColumn get initialBalanceMinor =>
      integer().withDefault(const Constant(0))();

  /// ISO 4217 currency code. Immutable after creation.
  TextColumn get currencyCode => text()();

  /// Whether this account is included in net worth computation.
  BoolColumn get includeInNetWorth =>
      boolean().withDefault(const Constant(true))();

  /// Optional free-form note.
  TextColumn get notes => text().nullable()();

  /// Soft-delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Unix epoch seconds set when account is soft-deleted.
  IntColumn get deletedAt => integer().nullable()();

  /// True for EQ and BAI/BAE accounts; blocks user deletion.
  BoolColumn get isProtected => boolean().withDefault(const Constant(false))();

  /// True for system-generated accounts (e.g. EQ per currency). Hidden from
  /// all user views.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  /// User-defined sort position; NULL means alphabetical ordering.
  IntColumn get displayOrder => integer().nullable()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  /// JSON escape hatch for future extensibility.
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
