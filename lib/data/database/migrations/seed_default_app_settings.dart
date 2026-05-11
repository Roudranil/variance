// lib/data/database/migrations/seed_default_app_settings.dart
//
// Default app_settings seed data (data model §9.1).
//
// Inserts all v1 default key-value pairs into the app_settings table on a
// fresh install. Uses INSERT OR IGNORE so onboarding writes that precede this
// call are preserved.
//
// Seeded keys and their defaults:
//   home_currency        → 'INR'
//   theme                → 'system'
//   color_scheme_mode    → 'dynamic'
//   animations_enabled   → '1'
//   week_start           → 'monday'
//   percentage_precision → '0'
//   description_max_length → '1000'
//   back_button_behaviour → 'ask'
//   lock_timeout_seconds → '0'
//   onboarding_complete  → '0'
//   schema_backup_version → '1'
//
// Nullable keys (color_seed, display_name, last_exchange_rate_fetch) are
// intentionally omitted — their absence causes the repository mapper to
// return null, matching the entity defaults.
//
// Test cases (see test/data/database/app_settings_seed_test.dart):
//   1. All expected keys are present after onCreate
//   2. Each seeded key has the correct default value
//   3. Running seed twice produces no duplicate rows (idempotency)
//   4. A pre-existing value (e.g. home_currency='USD') is not overwritten

import 'package:drift/drift.dart';

/// Seeds the default app_settings rows into [database].
///
/// Uses `INSERT OR IGNORE` so calling this function multiple times is safe and
/// any rows already present (e.g. from onboarding writes) are left unchanged.
///
/// Called from [buildMigrationStrategy]'s `onCreate` callback.
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] used to execute the INSERT
///   statements.
Future<void> seedDefaultAppSettings(GeneratedDatabase database) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  const defaults = <(String, String)>[
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

  await database.batch((batch) {
    for (final (key, value) in defaults) {
      batch.customStatement(
        'INSERT OR IGNORE INTO app_settings (key, value, updated_at) '
        'VALUES (?, ?, ?)',
        [key, value, now],
      );
    }
  });
}
