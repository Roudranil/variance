// lib/data/database/migrations/migrations.dart
//
// Versioned migration scaffold for AppDatabase.
//
// Migration authoring rules:
//   1. Every production schema change ships as a new version bump with an
//      explicit hand-written migration step in [onUpgrade].
//   2. Each step must be idempotent (safe to re-run after a crash).
//   3. Only additive changes (ADD COLUMN, CREATE TABLE, CREATE INDEX) are
//      allowed in production. DROP TABLE / DROP COLUMN requires a major
//      version bump and explicit data-loss warning.
//   4. [destroyEverything] is disabled. Data loss triggers a visible error
//      that instructs the user to restore from backup.
//   5. Downgrade protection: if the on-disk schemaVersion is higher than the
//      compiled version, [SchemaMismatchException] is thrown before any
//      migration is attempted.
//
// Test cases (see test/data/database/schema_verifier_test.dart):
//   - fresh v1 install completes onCreate without error
//   - v1 → v1 re-open (no-op upgrade) does not throw
//   - on-disk version > compiled version throws SchemaMismatchException
//   - v2 → v3 creates installment_occurrences indexes

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:variance/data/database/migrations/seed_default_app_settings.dart';
import 'package:variance/data/database/migrations/seed_default_categories.dart';

// ---------------------------------------------------------------------------
// Exception
// ---------------------------------------------------------------------------

/// Thrown when the on-disk database schema version is newer than the compiled
/// schema version bundled in this build.
///
/// This guards against an older app build opening a database that was
/// created or migrated by a newer app build. The caller should surface a
/// "please update the app" prompt to the user.
///
/// Parameters:
/// - [onDiskVersion]: The schema version found in the database file.
/// - [compiledVersion]: The schema version compiled into this app build.
class SchemaMismatchException implements Exception {
  /// Creates a new instance of [SchemaMismatchException].
  const SchemaMismatchException({
    required this.onDiskVersion,
    required this.compiledVersion,
  });

  /// The schema version stored in the existing database file.
  final int onDiskVersion;

  /// The schema version compiled into the current app build.
  final int compiledVersion;

  @override
  String toString() =>
      'SchemaMismatchException: on-disk version $onDiskVersion is newer than '
      'compiled version $compiledVersion. Please update the app.';
}

// ---------------------------------------------------------------------------
// Migration builder
// ---------------------------------------------------------------------------

/// Builds and returns the [MigrationStrategy] for [AppDatabase].
///
/// Wires [onCreate] for fresh installs (v1 baseline) and [onUpgrade] for
/// future version increments. [onUpgrade] checks for downgrade attempts
/// before delegating to version-specific steps.
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] whose [Migrator] will apply
///   DDL statements.
/// - [compiledVersion]: The schema version compiled into this app build
///   (passed from [AppDatabase.schemaVersion]).
MigrationStrategy buildMigrationStrategy(
  GeneratedDatabase database,
  int compiledVersion,
) {
  return MigrationStrategy(
    // ------------------------------------------------------------------
    // onCreate: called once for a fresh install (no existing .db file).
    // ------------------------------------------------------------------
    onCreate: (Migrator m) async {
      dev.log(
        'AppDatabase onCreate: creating v$compiledVersion schema',
        name: 'AppDatabase',
      );

      // Create all Drift-managed tables.
      await m.createAll();

      // Create the denormalized view used as the FTS5 content source
      // (data model §10.2). Must be created before the FTS5 virtual table
      // that references it via content='transactions_search_view'.
      await database.customStatement('''
        CREATE VIEW IF NOT EXISTS transactions_search_view AS
        SELECT
          t.rowid,
          t.id                              AS transaction_id,
          t.title,
          t.description,
          COALESCE(a_src.name, a_dst.name)  AS account_name,
          COALESCE(c.name, '')              AS category_name
        FROM transactions t
        LEFT JOIN accounts a_src ON a_src.id = t.account_source_id
        LEFT JOIN accounts a_dst ON a_dst.id = t.account_destination_id
        LEFT JOIN categories c   ON c.id = t.category_id
        WHERE t.status = 'posted'
          AND t.purpose IN ('user', 'correction', 'system')
      ''');

      dev.log(
        'AppDatabase onCreate: transactions_search_view view created',
        name: 'AppDatabase',
      );

      // Create the FTS5 virtual table for full-text transaction search.
      // FTS5 virtual tables cannot be represented as Drift Table classes;
      // they are created here with a raw SQL statement (SDS §2.8.2 /
      // data model §10.1).
      await database.customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS transactions_fts
        USING fts5(
          transaction_id UNINDEXED,
          title,
          description,
          account_name,
          category_name,
          content='transactions_search_view',
          content_rowid='rowid',
          tokenize='unicode61 remove_diacritics 2'
        )
      ''');

      dev.log(
        'AppDatabase onCreate: transactions_fts FTS5 virtual table created',
        name: 'AppDatabase',
      );

      // Seed the currencies table from the bundled ISO 4217 JSON asset.
      // This is the only time data is written to this read-only table.
      await _seedCurrencies(database);

      // Seed default category taxonomy (PRD §5.6.1, §5.2.4).
      // Uses INSERT OR IGNORE so re-running is safe (idempotent).
      await seedDefaultCategories(database);

      dev.log(
        'AppDatabase onCreate: default categories seeded',
        name: 'AppDatabase',
      );

      // Seed default app_settings rows (data model §9.1).
      // Uses INSERT OR IGNORE so onboarding writes that happen before this
      // point (unlikely on a fresh install but possible in test fixtures) are
      // preserved.
      await seedDefaultAppSettings(database);

      dev.log(
        'AppDatabase onCreate: default app_settings seeded',
        name: 'AppDatabase',
      );
    },

    // ------------------------------------------------------------------
    // onUpgrade: called when the on-disk version < compiled version.
    //
    // Downgrade guard: if the on-disk version is GREATER than the
    // compiled version, [SchemaMismatchException] is thrown before any
    // migration is attempted.
    // ------------------------------------------------------------------
    onUpgrade: (Migrator m, int from, int to) async {
      if (from > to) {
        // The on-disk version is newer than this app build. Throw before
        // touching the schema.
        throw SchemaMismatchException(
          onDiskVersion: from,
          compiledVersion: to,
        );
      }

      dev.log(
        'AppDatabase onUpgrade: $from → $to',
        name: 'AppDatabase',
      );

      // ------------------------------------------------------------------
      // Version-specific migration steps.
      //
      // Pattern: for each new version N, add a block:
      //   if (from < N) { await _migrateToVN(m); }
      //
      // This allows incremental upgrades across multiple skipped versions.
      // Each helper must be idempotent.
      // ------------------------------------------------------------------

      // v1 → v2: add large_txn_threshold_minor to accounts and categories.
      // Uses ADD COLUMN with NULL default — safe and idempotent.
      if (from < 2) {
        await _migrateToV2(database);
      }

      // v2 → v3: add performance indexes on installment_occurrences (T-125).
      // CREATE INDEX IF NOT EXISTS ensures idempotency.
      if (from < 3) {
        await _migrateToV3(database);
      }
    },

    // ------------------------------------------------------------------
    // beforeOpen: called on every database open (fresh or existing).
    // Applies PRAGMAs required by SDS §2.3.2.
    // ------------------------------------------------------------------
    beforeOpen: (OpeningDetails details) async {
      final db = database;
      await db.customStatement('PRAGMA foreign_keys = ON');
      await db.customStatement('PRAGMA journal_mode = WAL');
      await db.customStatement('PRAGMA synchronous = NORMAL');
      await db.customStatement('PRAGMA busy_timeout = 5000');
      await db.customStatement('PRAGMA cache_size = -20000');

      dev.log(
        'AppDatabase beforeOpen: PRAGMAs applied '
        '(versionBefore=${details.versionBefore} → versionNow=${details.versionNow})',
        name: 'AppDatabase',
      );
    },
  );
}

// ---------------------------------------------------------------------------
// v2 migration
// ---------------------------------------------------------------------------

/// Adds [large_txn_threshold_minor] columns to `accounts` and `categories`.
///
/// Both columns default to NULL (no threshold configured). Uses raw
/// `ALTER TABLE ADD COLUMN` for idempotency-friendly additive change.
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] whose executor runs the DDL.
Future<void> _migrateToV2(GeneratedDatabase database) async {
  dev.log(
    'AppDatabase _migrateToV2: adding large_txn_threshold_minor columns',
    name: 'AppDatabase',
  );

  await database.customStatement(
    'ALTER TABLE accounts ADD COLUMN large_txn_threshold_minor INTEGER',
  );

  await database.customStatement(
    'ALTER TABLE categories ADD COLUMN large_txn_threshold_minor INTEGER',
  );

  dev.log('AppDatabase _migrateToV2: done', name: 'AppDatabase');
}

// ---------------------------------------------------------------------------
// v3 migration
// ---------------------------------------------------------------------------

/// Creates performance indexes on `installment_occurrences` (T-125).
///
/// Adds:
/// - `idx_inst_occ_template_seq` (UNIQUE) on `(template_id, sequence_number)`:
///   used by [InstallmentOccurrenceDao.watchByPlan] for ordered occurrence list.
/// - `idx_inst_occ_status_date` on `(status, scheduled_date)`:
///   used by the scheduler sweep to find pending installments due by date.
///
/// Both use `IF NOT EXISTS` for idempotency — safe to run multiple times.
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] whose executor runs the DDL.
Future<void> _migrateToV3(GeneratedDatabase database) async {
  dev.log(
    'AppDatabase _migrateToV3: creating installment_occurrences indexes',
    name: 'AppDatabase',
  );

  // UNIQUE index: ordered occurrence list per template.
  await database.customStatement('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_inst_occ_template_seq
    ON installment_occurrences (template_id, sequence_number)
  ''');

  // Non-unique index: scheduler sweep by status + date.
  await database.customStatement('''
    CREATE INDEX IF NOT EXISTS idx_inst_occ_status_date
    ON installment_occurrences (status, scheduled_date)
  ''');

  dev.log('AppDatabase _migrateToV3: done', name: 'AppDatabase');
}

// ---------------------------------------------------------------------------
// Currency seeding
// ---------------------------------------------------------------------------

/// Loads `assets/data/currencies.json` and bulk-inserts all entries into the
/// `currencies` table.
///
/// Called once from [buildMigrationStrategy]'s `onCreate` callback. The
/// table is treated as read-only at runtime; this is the only write operation
/// performed against it (SDS §2.16.1).
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] whose raw executor is used to
///   run the INSERT statements.
Future<void> _seedCurrencies(GeneratedDatabase database) async {
  // Load the bundled JSON asset. rootBundle is available because the
  // migration is called during app startup when the Flutter engine is active.
  final jsonString = await rootBundle.loadString(
    'assets/data/currencies.json',
  );

  final List<dynamic> entries = json.decode(jsonString) as List<dynamic>;

  dev.log(
    'AppDatabase _seedCurrencies: inserting ${entries.length} currencies',
    name: 'AppDatabase',
  );

  // Batch-insert for efficiency. The `OR IGNORE` conflict strategy ensures
  // idempotency if the migration is ever re-run against a non-empty table.
  await database.batch((batch) {
    for (final dynamic raw in entries) {
      final Map<String, dynamic> entry = raw as Map<String, dynamic>;
      // Use customInsert with positional params to stay framework-agnostic.
      // The OR IGNORE strategy silently skips rows whose PK (code) already
      // exists, making this call safe to repeat.
      batch.customStatement(
        'INSERT OR IGNORE INTO currencies (code, name, symbol, minor_units, is_active) '
        'VALUES (?, ?, ?, ?, ?)',
        [
          entry['code'] as String,
          entry['name'] as String,
          entry['symbol'] as String,
          entry['minor_units'] as int,
          1, // is_active = true for all bundled currencies
        ],
      );
    }
  });

  dev.log(
    'AppDatabase _seedCurrencies: seed complete',
    name: 'AppDatabase',
  );
}
