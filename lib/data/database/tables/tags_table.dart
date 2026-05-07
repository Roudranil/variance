// lib/data/database/tables/tags_table.dart
//
// Drift table definition for `tags`.
//
// Free-form tags for cross-cutting transaction grouping. Schema-ready in v1
// but not surfaced in the v1 UI.

import 'package:drift/drift.dart';

/// Drift table for free-form transaction tags.
///
/// Tags are schema-ready in v1 to avoid a migration when tag support is
/// introduced. The many-to-many join with transactions lives in
/// [TransactionTags].
class Tags extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Tag label. Case-insensitive uniqueness enforced at app layer.
  TextColumn get name => text()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
