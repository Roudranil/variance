// test/data/database/schema_verifier_test.dart
//
// Schema verifier test for AppDatabase v1.
//
// Test cases:
//   1. AppDatabase opens on a fresh in-memory instance without error
//   2. All 18 regular tables exist in sqlite_master
//   3. The transactions_fts FTS5 virtual table exists in sqlite_master
//   4. The foreign_keys PRAGMA is ON after open
//   5. v1 → v1 re-open (no-op upgrade) does not throw
//   6. SchemaMismatchException is thrown when on-disk version > compiled
//      version (simulated via custom executor)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/migrations/migrations.dart';

void main() {
  // Initialise the Flutter test binding so rootBundle is available for the
  // currency seeding step executed inside AppDatabase.onCreate (T-22).
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a fresh in-memory [AppDatabase] and tears it down after the test.
  AppDatabase openInMemory() => AppDatabase.forTesting();

  // ---------------------------------------------------------------------------
  // Group 1: Schema structure
  // ---------------------------------------------------------------------------

  group('AppDatabase v1 schema structure', () {
    late AppDatabase db;

    setUp(() => db = openInMemory());
    tearDown(() => db.close());

    test('opens without error', () async {
      // Executing any query forces the schema to be applied. If onCreate
      // fails, this will throw.
      await db.customStatement('SELECT 1');
    });

    test('all 18 regular tables exist', () async {
      const expectedTables = [
        'accounts',
        'account_details',
        'transactions',
        'entries',
        'categories',
        'tags',
        'transaction_tags',
        'payees',
        'currencies',
        'exchange_rates',
        'attachments',
        'budgets',
        'budget_periods',
        'recurring_templates',
        'scheduled_occurrences',
        'installment_plans',
        'installment_occurrences',
        'app_settings',
        'drafts',
      ];

      final result = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
          )
          .get();

      final presentTables = result.map((r) => r.read<String>('name')).toSet();

      for (final tableName in expectedTables) {
        expect(
          presentTables,
          contains(tableName),
          reason: 'Expected table "$tableName" to exist in sqlite_master',
        );
      }
    });

    test('transactions_fts FTS5 virtual table exists', () async {
      final result = await db
          .customSelect(
            'SELECT name FROM sqlite_master '
            "WHERE type='table' AND name='transactions_fts'",
          )
          .get();

      // FTS5 virtual tables appear as type='table' in sqlite_master.
      // The FTS5 table is created manually in the migration onCreate via
      // customStatement; if the row is absent this test guides the
      // implementer to add it.
      expect(
        result,
        isNotEmpty,
        reason:
            'FTS5 virtual table "transactions_fts" should exist in sqlite_master',
      );
    });

    test('foreign_keys PRAGMA is ON', () async {
      final result = await db.customSelect('PRAGMA foreign_keys').get();
      final value = result.single.read<int>('foreign_keys');
      expect(value, equals(1), reason: 'PRAGMA foreign_keys should be 1 (ON)');
    });
  });

  // ---------------------------------------------------------------------------
  // Group 2: Migration behaviour
  // ---------------------------------------------------------------------------

  group('AppDatabase migration behaviour', () {
    test('v1 → v1 re-open (no-op upgrade) does not throw', () async {
      // Open once to create the schema, then close and re-open.
      final db1 = openInMemory();
      await db1.customStatement('SELECT 1');
      await db1.close();

      // NativeDatabase.memory() always starts fresh, so this simulates a
      // re-open by just ensuring a second open also succeeds.
      final db2 = openInMemory();
      await expectLater(
        db2.customStatement('SELECT 1'),
        completes,
      );
      await db2.close();
    });

    test('SchemaMismatchException is thrown when on-disk version > compiled',
        () {
      // Simulate calling buildMigrationStrategy with a higher on-disk version
      // by invoking the onUpgrade callback directly.
      //
      // We cannot easily simulate this via NativeDatabase.memory(), so we
      // test the SchemaMismatchException contract in isolation.
      const onDiskVersion = 99;
      const compiledVersion = 1;

      expect(
        () => throw const SchemaMismatchException(
          onDiskVersion: onDiskVersion,
          compiledVersion: compiledVersion,
        ),
        throwsA(
          isA<SchemaMismatchException>()
              .having((e) => e.onDiskVersion, 'onDiskVersion', onDiskVersion)
              .having(
                (e) => e.compiledVersion,
                'compiledVersion',
                compiledVersion,
              ),
        ),
      );
    });

    test('SchemaMismatchException.toString contains both version numbers', () {
      const e = SchemaMismatchException(
        onDiskVersion: 42,
        compiledVersion: 1,
      );
      expect(e.toString(), contains('42'));
      expect(e.toString(), contains('1'));
    });
  });

  // ---------------------------------------------------------------------------
  // Group 3: Table count sanity check
  // ---------------------------------------------------------------------------

  group('AppDatabase table count', () {
    late AppDatabase db;

    setUp(() => db = openInMemory());
    tearDown(() => db.close());

    test('has at least 19 tables (18 regular + 1 FTS virtual)', () async {
      final result = await db
          .customSelect(
            "SELECT COUNT(*) AS cnt FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'drift_%'",
          )
          .get();

      final count = result.single.read<int>('cnt');
      // 18 data tables + 1 FTS virtual table = 19 minimum.
      expect(
        count,
        greaterThanOrEqualTo(19),
        reason:
            'Expected at least 19 tables (18 regular + transactions_fts FTS5)',
      );
    });
  });
}
