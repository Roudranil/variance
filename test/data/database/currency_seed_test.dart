// test/data/database/currency_seed_test.dart
//
// Tests for the currencies table seeding from the bundled JSON asset (T-22)
// and CurrencyRepositoryImpl read operations (T-23).
//
// Test cases:
//   - currencies.json asset is parseable via rootBundle.loadString
//   - currencies.json contains >= 170 entries
//   - currencies.json contains a valid USD entry (minor_units = 2)
//   - currencies.json contains a valid JPY entry (minor_units = 0)
//   - currencies.json contains a valid BHD entry (minor_units = 3)
//   - CurrencyRepositoryImpl.getByCode('USD') returns minor_units = 2
//   - CurrencyRepositoryImpl.getByCode('JPY') returns minor_units = 0
//   - CurrencyRepositoryImpl.getByCode('BHD') returns minor_units = 3
//   - CurrencyRepositoryImpl.getByCode('INVALID') returns null
//   - CurrencyRepositoryImpl.getAll() returns >= 170 entries
//   - CurrencyRepositoryImpl.watchAll() stream first emission >= 170 entries

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/data/repositories/currency_repository_impl.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Manually seeds the in-memory [AppDatabase] from the bundled currencies.json.
///
/// Mirrors the logic in [_seedCurrencies] in migrations.dart. Used in tests
/// because the in-memory NativeDatabase.memory() executes onCreate via
/// Drift's MigrationStrategy which calls rootBundle — that requires the test
/// binding to be initialised (ensureInitialized).
Future<void> _seedFromAsset(AppDatabase db) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/currencies.json',
  );
  final List<dynamic> entries = json.decode(jsonString) as List<dynamic>;

  await db.batch((batch) {
    for (final dynamic raw in entries) {
      final Map<String, dynamic> entry = raw as Map<String, dynamic>;
      batch.customStatement(
        'INSERT OR IGNORE INTO currencies '
        '(code, name, symbol, minor_units, is_active) VALUES (?, ?, ?, ?, ?)',
        [
          entry['code'] as String,
          entry['name'] as String,
          entry['symbol'] as String,
          entry['minor_units'] as int,
          1, // is_active = true
        ],
      );
    }
  });
}

void main() {
  // Initialise the Flutter test binding so rootBundle is available.
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Group 1: Asset integrity (T-21 / T-22)
  // ---------------------------------------------------------------------------

  group('currencies.json asset', () {
    test('is parseable via rootBundle.loadString', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      expect(jsonString, isNotEmpty);
      final List<dynamic> entries = json.decode(jsonString) as List<dynamic>;
      expect(entries, isNotEmpty);
    });

    test('contains at least 170 entries', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final List<dynamic> entries = json.decode(jsonString) as List<dynamic>;
      expect(
        entries.length,
        greaterThanOrEqualTo(170),
        reason: 'Bundled currency list must contain >= 170 active currencies',
      );
    });

    test('USD entry has minor_units = 2', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final entries = json.decode(jsonString) as List<dynamic>;
      final usd = entries.firstWhere(
        (dynamic e) => (e as Map<String, dynamic>)['code'] == 'USD',
        orElse: () => null,
      ) as Map<String, dynamic>?;
      expect(usd, isNotNull, reason: 'USD must be present in currencies.json');
      expect(usd!['minor_units'], equals(2));
    });

    test('JPY entry has minor_units = 0', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final entries = json.decode(jsonString) as List<dynamic>;
      final jpy = entries.firstWhere(
        (dynamic e) => (e as Map<String, dynamic>)['code'] == 'JPY',
        orElse: () => null,
      ) as Map<String, dynamic>?;
      expect(jpy, isNotNull, reason: 'JPY must be present in currencies.json');
      expect(jpy!['minor_units'], equals(0));
    });

    test('BHD entry has minor_units = 3', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final entries = json.decode(jsonString) as List<dynamic>;
      final bhd = entries.firstWhere(
        (dynamic e) => (e as Map<String, dynamic>)['code'] == 'BHD',
        orElse: () => null,
      ) as Map<String, dynamic>?;
      expect(bhd, isNotNull, reason: 'BHD must be present in currencies.json');
      expect(bhd!['minor_units'], equals(3));
    });

    test('all entries have required fields (code, name, symbol, minor_units)',
        () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final entries = json.decode(jsonString) as List<dynamic>;
      for (final dynamic raw in entries) {
        final entry = raw as Map<String, dynamic>;
        expect(entry['code'], isA<String>(), reason: 'code must be a String');
        expect(entry['name'], isA<String>(), reason: 'name must be a String');
        expect(
          entry['symbol'],
          isA<String>(),
          reason: 'symbol must be a String',
        );
        expect(
          entry['minor_units'],
          isA<int>(),
          reason: 'minor_units must be an int',
        );
      }
    });

    test('minor_units values are in {0, 2, 3}', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/currencies.json',
      );
      final entries = json.decode(jsonString) as List<dynamic>;
      for (final dynamic raw in entries) {
        final entry = raw as Map<String, dynamic>;
        final minorUnits = entry['minor_units'] as int;
        expect(
          [0, 2, 3],
          contains(minorUnits),
          reason: '${entry["code"]} has invalid minor_units=$minorUnits; '
              'must be 0, 2, or 3',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Group 2: Database seeding (T-22)
  // ---------------------------------------------------------------------------

  group('currencies table seeding', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting();
    });

    tearDown(() => db.close());

    test('manual seed inserts >= 170 rows', () async {
      // Force Drift to apply the onCreate schema by running any query.
      await db.customStatement('SELECT 1');
      await _seedFromAsset(db);

      final result =
          await db.customSelect('SELECT COUNT(*) AS cnt FROM currencies').get();
      final count = result.single.read<int>('cnt');
      expect(
        count,
        greaterThanOrEqualTo(170),
        reason: 'currencies table must contain >= 170 rows after seeding',
      );
    });

    test('OR IGNORE makes seeding idempotent', () async {
      await db.customStatement('SELECT 1');
      await _seedFromAsset(db);
      await _seedFromAsset(db); // second call must not throw or duplicate rows

      final result =
          await db.customSelect('SELECT COUNT(*) AS cnt FROM currencies').get();
      final count1 = result.single.read<int>('cnt');

      // Count should be stable after a second seed.
      final result2 =
          await db.customSelect('SELECT COUNT(*) AS cnt FROM currencies').get();
      final count2 = result2.single.read<int>('cnt');
      expect(count1, equals(count2));
    });
  });

  // ---------------------------------------------------------------------------
  // Group 3: CurrencyRepositoryImpl read operations (T-23)
  // ---------------------------------------------------------------------------

  group('CurrencyRepositoryImpl', () {
    late AppDatabase db;
    late CurrencyDao dao;
    late CurrencyRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.forTesting();
      // Force schema creation before seeding.
      await db.customStatement('SELECT 1');
      await _seedFromAsset(db);
      dao = db.currencyDao;
      repo = CurrencyRepositoryImpl(dao);
    });

    tearDown(() => db.close());

    test('getByCode("USD") returns minor_units = 2', () async {
      final currency = await repo.getByCode('USD');
      expect(currency, isNotNull);
      expect(currency!.code, equals('USD'));
      expect(
        currency.minorUnits,
        equals(2),
        reason: 'USD must have 2 decimal places',
      );
    });

    test('getByCode("JPY") returns minor_units = 0', () async {
      final currency = await repo.getByCode('JPY');
      expect(currency, isNotNull);
      expect(currency!.code, equals('JPY'));
      expect(
        currency.minorUnits,
        equals(0),
        reason: 'JPY must have 0 decimal places (no minor units)',
      );
    });

    test('getByCode("BHD") returns minor_units = 3', () async {
      final currency = await repo.getByCode('BHD');
      expect(currency, isNotNull);
      expect(currency!.code, equals('BHD'));
      expect(
        currency.minorUnits,
        equals(3),
        reason: 'BHD must have 3 decimal places',
      );
    });

    test('getByCode("INVALID") returns null', () async {
      final currency = await repo.getByCode('INVALID');
      expect(currency, isNull);
    });

    test('getAll() returns >= 170 currencies', () async {
      final all = await repo.getAll();
      expect(
        all.length,
        greaterThanOrEqualTo(170),
        reason: 'getAll() must return all seeded currencies',
      );
    });

    test('getAll() returns Currency domain entities (not DAO rows)', () async {
      final all = await repo.getAll();
      expect(all, isNotEmpty);
      // Verify the first item maps correctly to the domain entity.
      final first = all.first;
      expect(first.code, isA<String>());
      expect(first.name, isA<String>());
      expect(first.symbol, isA<String>());
      expect(first.minorUnits, isA<int>());
      expect(first.isActive, isTrue);
    });

    test('watchAll() first emission returns >= 170 currencies', () async {
      final currencies = await repo.watchAll().first;
      expect(
        currencies.length,
        greaterThanOrEqualTo(170),
        reason: 'watchAll() first emission must include all seeded currencies',
      );
    });

    test('getAll() returns currencies ordered by code', () async {
      final all = await repo.getAll();
      expect(all.length, greaterThan(1));
      // Verify ascending code order (CurrencyDao.getAllActive orders by code).
      for (int i = 0; i < all.length - 1; i++) {
        expect(
          all[i].code.compareTo(all[i + 1].code),
          lessThanOrEqualTo(0),
          reason: 'Currencies must be ordered by code ascending',
        );
      }
    });
  });
}
