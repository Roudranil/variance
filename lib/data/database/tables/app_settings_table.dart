// lib/data/database/tables/app_settings_table.dart
//
// Drift table definition for `app_settings`.
//
// Key-value store for all user preferences and app configuration. Avoids
// the competitor anti-pattern (AP-1) of a single JSON blob in
// SharedPreferences.

import 'package:drift/drift.dart';

/// Drift table for application settings and user preferences.
///
/// Each row stores a single setting identified by [key]. The [value] column
/// is TEXT; the application layer is responsible for interpreting the type
/// based on the known key. All v1 keys are documented in the data model
/// §9.1.
class AppSettings extends Table {
  /// Setting identifier (PK). See data model §9.1 for the full key list.
  TextColumn get key => text()();

  /// Setting value as a TEXT string. Type is inferred by the key.
  TextColumn get value => text().nullable()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
