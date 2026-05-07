// lib/data/database/tables/account_details_table.dart
//
// Drift table definition for `account_details`.
//
// Stores category-specific fields per account to avoid a wide nullable-column
// design on `accounts`. Sensitive fields use [detailValueEncrypted].

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/accounts_table.dart';

/// Drift table for category-specific account fields.
///
/// Each row represents a single key-value pair for an account. The
/// [detailKey] column identifies the field name (e.g. `bank_name`,
/// `card_number_encrypted`). Sensitive values are stored in
/// [detailValueEncrypted] as AES-encrypted blobs.
class AccountDetails extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → accounts(id) ON DELETE CASCADE.
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();

  /// Field name (e.g. `bank_name`, `card_number`). Valid values are
  /// enforced at the application layer.
  TextColumn get detailKey => text()();

  /// Plain-text value (used for non-sensitive fields).
  TextColumn get detailValue => text().nullable()();

  /// AES-encrypted blob for sensitive fields (e.g. card_number, account_number).
  TextColumn get detailValueEncrypted => text().nullable()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
