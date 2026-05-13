// lib/data/database/tables/categories_table.dart
//
// Drift table definition for `categories`.
//
// Two-level category hierarchy (parent/child). Income and expense trees
// are kept separate by [treeType]. System-protected categories cannot be
// deleted.

import 'package:drift/drift.dart';

/// Drift table for two-level category hierarchy.
///
/// Root categories have [parentId] = NULL. Subcategories reference a root
/// via [parentId]. Deletion is blocked by [isProtected] for system categories.
class Categories extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Parent category id for subcategories; NULL for root categories.
  TextColumn get parentId => text().nullable().references(Categories, #id)();

  /// Which category tree: `income` or `expense`.
  TextColumn get treeType => text()();

  /// Display name. Case-insensitive uniqueness enforced at app layer.
  TextColumn get name => text()();

  /// Material Symbols icon identifier.
  TextColumn get iconRef => text()();

  /// Soft-delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Unix epoch seconds set on soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  /// True for BAI/BAE and "Balance Adjustment" parent. Blocks user deletion.
  BoolColumn get isProtected => boolean().withDefault(const Constant(false))();

  /// Manual sort position. NULL = alphabetical (v1 default).
  IntColumn get sortOrder => integer().nullable()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  /// Per-category large-transaction warning threshold in home-currency minor
  /// units. NULL means no threshold is configured.
  ///
  /// Always denominated in the app's home currency (TC-047). Set to NULL by
  /// default; user configures via Settings > Warnings & Limits >
  /// Per-Category Limits.
  IntColumn get largeTxnThresholdMinor => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
