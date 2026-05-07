// lib/data/database/tables/payees_table.dart
//
// Drift table definition for `payees`.
//
// Optional named payees/merchants. Schema-ready in v1 but not surfaced as
// a managed entity in the v1 UI.

import 'package:drift/drift.dart';

/// Drift table for optional named payees/merchants.
///
/// Transactions may reference a [Payees] row via their `payee_id` column.
/// The payee management screen is deferred to v2.
class Payees extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Payee name. Case-insensitive uniqueness enforced at app layer.
  TextColumn get name => text()();

  /// Soft-delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Unix epoch seconds set on soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
