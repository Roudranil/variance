// lib/data/database/daos/app_settings_dao.dart
//
// DAO for the `app_settings` key-value table.
//
// Responsibilities:
//   - Reactive stream of all settings rows (watch)
//   - Upsert (INSERT OR REPLACE) for a single key-value pair
//   - Bulk seed (INSERT OR IGNORE) for default settings on first launch
//   - Table-empty check to guard the seed call
//
// Test cases (see test/data/database/app_settings_dao_test.dart):
//   1. watch — emits empty list for a fresh database (before seeding)
//   2. upsert — inserted row appears in watch stream
//   3. upsert — updating an existing key emits the new value
//   4. upsert — updating one key does not affect other keys
//   5. isEmpty — returns true for a fresh database
//   6. isEmpty — returns false after at least one row is written
//   7. seedDefaults — inserts all default rows; watch emits them
//   8. seedDefaults — idempotent; second call does not overwrite existing values

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

// ---------------------------------------------------------------------------
// Default key-value pairs (data model §9.1)
// ---------------------------------------------------------------------------

/// The canonical set of v1 default rows inserted into `app_settings` on first
/// launch.
///
/// Stored as a list of `(key, value)` tuples. NULL values (optional settings
/// with no default) are intentionally omitted — their absence causes the
/// repository mapper to use the entity default.
const _kDefaults = <(String, String)>[
  ('home_currency', 'INR'),
  ('theme', 'system'),
  ('color_scheme_mode', 'dynamic'),
  ('animations_enabled', '1'),
  ('week_start', 'monday'),
  ('percentage_precision', '0'),
  ('description_max_length', '1000'),
  ('back_button_behaviour', 'ask'),
  ('lock_timeout_seconds', '0'),
  ('onboarding_complete', '0'),
  ('schema_backup_version', '1'),
];

// ---------------------------------------------------------------------------
// DAO
// ---------------------------------------------------------------------------

/// DAO for the `app_settings` key-value table.
///
/// Exposes a reactive stream of all rows and upsert/seed helpers. The
/// repository layer is responsible for mapping rows to the typed [AppSettings]
/// domain entity.
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  /// Creates a new [AppSettingsDao] bound to [db].
  AppSettingsDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns a reactive stream of all rows in the `app_settings` table.
  ///
  /// The stream emits a new list whenever any row is inserted, updated, or
  /// deleted. An empty list is emitted for a fresh database before seeding.
  Stream<List<AppSetting>> watch() => select(appSettings).watch();

  /// Returns true when the `app_settings` table contains no rows.
  ///
  /// Used to decide whether default seeding is required on first launch.
  Future<bool> isEmpty() async {
    final count = await (selectOnly(appSettings)
          ..addColumns([appSettings.key.count()]))
        .map((row) => row.read(appSettings.key.count()) ?? 0)
        .getSingle();
    return count == 0;
  }

  // -----------------------------------------------------------------------
  // Writes
  // -----------------------------------------------------------------------

  /// Inserts or replaces the row for [key] with [value].
  ///
  /// Uses `INSERT OR REPLACE` semantics so the call is idempotent and safe to
  /// call whether or not the row already exists.
  ///
  /// Parameters:
  /// - [key]: Setting identifier (see data model §9.1).
  /// - [value]: String representation of the value; null clears the field.
  /// - [updatedAtEpoch]: Unix epoch seconds for the `updated_at` column.
  Future<void> upsert(
    String key,
    String? value,
    int updatedAtEpoch,
  ) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: Value(value),
        updatedAt: updatedAtEpoch,
      ),
    );
  }

  /// Seeds the default settings rows if the table is currently empty.
  ///
  /// Uses `INSERT OR IGNORE` so that pre-existing rows (e.g. from onboarding
  /// writes) are preserved — this call will never overwrite an existing value.
  ///
  /// Designed to be called once from the app initialisation path before the
  /// first paint.
  ///
  /// Parameters:
  /// - [nowEpoch]: Unix epoch seconds used for all `updated_at` values.
  Future<void> seedDefaults(int nowEpoch) async {
    await batch((b) {
      for (final (k, v) in _kDefaults) {
        // customStatement gives us OR IGNORE semantics. Drift's
        // insertOnConflictUpdate would silently replace; we want to skip
        // pre-existing rows (e.g. written by onboarding before seedDefaults).
        b.customStatement(
          'INSERT OR IGNORE INTO app_settings (key, value, updated_at) '
          'VALUES (?, ?, ?)',
          [k, v, nowEpoch],
        );
      }
    });
  }
}
