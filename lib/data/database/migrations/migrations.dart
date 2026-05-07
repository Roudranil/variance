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

import 'dart:developer' as dev;

import 'package:drift/drift.dart';

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

      // v1 → v2: (placeholder — no migrations exist yet)
      // if (from < 2) { await _migrateToV2(m); }
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
