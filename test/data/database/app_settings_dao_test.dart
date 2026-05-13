// test/data/database/app_settings_dao_test.dart
//
// Unit tests for AppSettingsDao against an in-memory Drift database.
//
// Test cases:
//   1. watch — emits a list containing seeded keys after onCreate
//   2. upsert — new key appears in the next watch emission
//   3. upsert — updating existing key emits the new value
//   4. upsert — updating one key does not affect other keys
//   5. isEmpty — returns false after onCreate (seed inserts rows)
//   6. isEmpty — returns true for a manually emptied table
//   7. seedDefaults — all expected default keys are present
//   8. seedDefaults — idempotent: calling twice does not overwrite values
//   T-194.1. getValue — returns the value for an existing key
//   T-194.2. getValue — returns null for a missing key
//   T-194.3. setValue — inserts a new key and reads it back via getValue
//   T-194.4. getOnboardingComplete — returns false when value is '0'
//   T-194.5. getOnboardingComplete — returns true after setOnboardingComplete
//   T-194.6. getHomeCurrency — returns 'INR' from seeded default
//   T-194.7. setHomeCurrency — updates value readable via getHomeCurrency

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/app_settings_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AppSettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.appSettingsDao;
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // watch
  // ---------------------------------------------------------------------------

  group('watch', () {
    test('1. emits a list containing seeded keys after onCreate', () async {
      // The migrations onCreate seeds default rows; we expect at least
      // 'home_currency' to be present.
      final rows = await dao.watch().first;
      final keys = rows.map((r) => r.key).toSet();
      expect(keys, contains('home_currency'));
      expect(keys, contains('theme'));
    });
  });

  // ---------------------------------------------------------------------------
  // upsert
  // ---------------------------------------------------------------------------

  group('upsert', () {
    test('2. new key appears in the next watch emission', () async {
      const now = 1735689600;
      await dao.upsert('test_new_key', 'hello', now);
      final rows = await dao.watch().first;
      final row = rows.firstWhere((r) => r.key == 'test_new_key');
      expect(row.value, equals('hello'));
    });

    test('3. updating existing key emits the new value', () async {
      const now = 1735689600;
      // Seed inserts 'theme' = 'system'; override it.
      await dao.upsert('theme', 'dark', now);
      final rows = await dao.watch().first;
      final row = rows.firstWhere((r) => r.key == 'theme');
      expect(row.value, equals('dark'));
    });

    test('4. updating one key does not affect other keys', () async {
      const now = 1735689600;
      await dao.upsert('theme', 'light', now);
      final rows = await dao.watch().first;
      // 'home_currency' should still be 'INR' from the seed.
      final row = rows.firstWhere((r) => r.key == 'home_currency');
      expect(row.value, equals('INR'));
    });
  });

  // ---------------------------------------------------------------------------
  // isEmpty
  // ---------------------------------------------------------------------------

  group('isEmpty', () {
    test('5. returns false after onCreate (seed inserts rows)', () async {
      // db.onCreate runs seedDefaultAppSettings so the table is non-empty.
      final empty = await dao.isEmpty();
      expect(empty, isFalse);
    });

    test('6. returns true after manually deleting all rows', () async {
      // Delete all rows to simulate a truly empty table.
      await db.delete(db.appSettings).go();
      final empty = await dao.isEmpty();
      expect(empty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // seedDefaults
  // ---------------------------------------------------------------------------

  group('seedDefaults', () {
    test('7. all expected default keys are present', () async {
      const expectedKeys = [
        'home_currency',
        'theme',
        'color_scheme_mode',
        'animations_enabled',
        'week_start',
        'percentage_precision',
        'description_max_length',
        'back_button_behaviour',
        'lock_timeout_seconds',
        'onboarding_complete',
        'schema_backup_version',
      ];

      final rows = await dao.watch().first;
      final keys = rows.map((r) => r.key).toSet();
      for (final key in expectedKeys) {
        expect(keys, contains(key), reason: 'Missing expected key: $key');
      }
    });

    test('8. seedDefaults is idempotent; does not overwrite existing values',
        () async {
      const now = 1735689600;
      // Pre-write a custom value for 'theme'.
      await dao.upsert('theme', 'dark', now);

      // Re-run seedDefaults — should NOT overwrite the 'dark' value.
      await dao.seedDefaults(now);

      final rows = await dao.watch().first;
      final row = rows.firstWhere((r) => r.key == 'theme');
      expect(row.value, equals('dark'));
    });
  });

  // ---------------------------------------------------------------------------
  // T-194 convenience methods
  // ---------------------------------------------------------------------------

  group('getValue / setValue (T-194)', () {
    test('T-194.1. getValue returns the value for an existing key', () async {
      final value = await dao.getValue('home_currency');
      expect(value, equals('INR'));
    });

    test('T-194.2. getValue returns null for a missing key', () async {
      final value = await dao.getValue('nonexistent_key_xyz');
      expect(value, isNull);
    });

    test('T-194.3. setValue inserts a new key readable via getValue', () async {
      await dao.setValue('test_key_t194', 'hello');
      final value = await dao.getValue('test_key_t194');
      expect(value, equals('hello'));
    });
  });

  group('getOnboardingComplete / setOnboardingComplete (T-194)', () {
    test(
      'T-194.4. getOnboardingComplete returns false when value is "0"',
      () async {
        // Default seed sets onboarding_complete = '0'.
        final result = await dao.getOnboardingComplete();
        expect(result, isFalse);
      },
    );

    test(
      'T-194.5. getOnboardingComplete returns true after setOnboardingComplete',
      () async {
        await dao.setOnboardingComplete();
        final result = await dao.getOnboardingComplete();
        expect(result, isTrue);
      },
    );
  });

  group('getHomeCurrency / setHomeCurrency (T-194)', () {
    test(
      'T-194.6. getHomeCurrency returns "INR" from seeded default',
      () async {
        final code = await dao.getHomeCurrency();
        expect(code, equals('INR'));
      },
    );

    test(
      'T-194.7. setHomeCurrency updates value readable via getHomeCurrency',
      () async {
        await dao.setHomeCurrency('USD');
        final code = await dao.getHomeCurrency();
        expect(code, equals('USD'));
      },
    );
  });
}
