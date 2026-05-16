// test/data/database/exchange_rate_dao_test.dart
//
// Unit tests for ExchangeRateDao (T-84).
// Uses in-memory AppDatabase.
//
// Test cases:
//   T-84.1. upsertRate inserts a new rate row
//   T-84.2. upsertRate overwrites stale rate for the same pair (unique constraint)
//   T-84.3. getRate returns null for unknown pair
//   T-84.4. getRate returns the row after insert
//   T-84.5. watchAllRates emits inserted rows
//   T-84.6. getStaleRates returns rows with fetchedAt before threshold

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/exchange_rate_dao.dart';

const _kFrom = 'INR';
const _kTo = 'USD';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExchangeRateDao dao;

  setUp(() async {
    db = AppDatabase.forTesting();
    await db.customStatement('SELECT 1'); // trigger onCreate
    await _insertCurrencies(db);
    dao = db.exchangeRateDao;
  });

  tearDown(() => db.close());

  // T-84.1. upsertRate inserts a new rate row
  test('T-84.1 upsertRate inserts a new rate row', () async {
    const companion = ExchangeRatesCompanion(
      fromCurrency: Value(_kFrom),
      toCurrency: Value(_kTo),
      rateMicro: Value(83000000),
      fetchedAt: Value(1000000),
      rateDate: Value('2025-05-01'),
    );

    await dao.upsertRate(companion);

    final row = await dao.getRate(_kFrom, _kTo);
    expect(row, isNotNull);
    expect(row!.rateMicro, 83000000);
    expect(row.rateDate, '2025-05-01');
  });

  // T-84.2. upsertRate overwrites stale rate for the same pair
  test('T-84.2 upsertRate overwrites stale rate for same pair', () async {
    const first = ExchangeRatesCompanion(
      fromCurrency: Value(_kFrom),
      toCurrency: Value(_kTo),
      rateMicro: Value(80000000),
      fetchedAt: Value(1000000),
      rateDate: Value('2025-04-01'),
    );
    await dao.upsertRate(first);

    const second = ExchangeRatesCompanion(
      fromCurrency: Value(_kFrom),
      toCurrency: Value(_kTo),
      rateMicro: Value(85000000),
      fetchedAt: Value(2000000),
      rateDate: Value('2025-05-01'),
    );
    await dao.upsertRate(second);

    final row = await dao.getRate(_kFrom, _kTo);
    expect(row, isNotNull);
    // Only the second (newer) rate should be present
    expect(row!.rateMicro, 85000000);
    expect(row.rateDate, '2025-05-01');

    // Verify there's exactly one row for this pair
    final all = await db.select(db.exchangeRates).get();
    expect(
      all.where((r) => r.fromCurrency == _kFrom && r.toCurrency == _kTo),
      hasLength(1),
    );
  });

  // T-84.3. getRate returns null for unknown pair
  test('T-84.3 getRate returns null for unknown pair', () async {
    final row = await dao.getRate('EUR', 'JPY');
    expect(row, isNull);
  });

  // T-84.4. getRate returns the row after insert
  test('T-84.4 getRate returns the row after insert', () async {
    const companion = ExchangeRatesCompanion(
      fromCurrency: Value(_kFrom),
      toCurrency: Value(_kTo),
      rateMicro: Value(83500000),
      fetchedAt: Value(1715000000),
      rateDate: Value('2025-05-07'),
    );
    await dao.upsertRate(companion);

    final row = await dao.getRate(_kFrom, _kTo);
    expect(row, isNotNull);
    expect(row!.fromCurrency, _kFrom);
    expect(row.toCurrency, _kTo);
    expect(row.rateMicro, 83500000);
    expect(row.fetchedAt, 1715000000);
  });

  // T-84.5. watchAllRates emits inserted rows
  test('T-84.5 watchAllRates emits inserted rows', () async {
    const companion = ExchangeRatesCompanion(
      fromCurrency: Value(_kFrom),
      toCurrency: Value(_kTo),
      rateMicro: Value(83000000),
      fetchedAt: Value(1000000),
      rateDate: Value('2025-05-01'),
    );
    await dao.upsertRate(companion);

    final rows = await dao.watchAllRates().first;
    expect(rows, hasLength(greaterThanOrEqualTo(1)));
    expect(
      rows.any((r) => r.fromCurrency == _kFrom && r.toCurrency == _kTo),
      isTrue,
    );
  });

  // T-84.6. getStaleRates returns rows with fetchedAt before threshold
  test('T-84.6 getStaleRates returns rows fetched before threshold', () async {
    // Old rate
    await dao.upsertRate(
      const ExchangeRatesCompanion(
        fromCurrency: Value(_kFrom),
        toCurrency: Value(_kTo),
        rateMicro: Value(80000000),
        fetchedAt: Value(1000000),
        rateDate: Value('2025-01-01'),
      ),
    );
    // Recent rate (different pair)
    await dao.upsertRate(
      const ExchangeRatesCompanion(
        fromCurrency: Value('EUR'),
        toCurrency: Value(_kTo),
        rateMicro: Value(1100000),
        fetchedAt: Value(9999999),
        rateDate: Value('2025-05-01'),
      ),
    );

    // Threshold: anything before epoch 2000000 is stale
    final stale = await dao.getStaleRates(2000000);
    expect(stale, hasLength(1));
    expect(stale.first.fromCurrency, _kFrom);
  });
}

/// Inserts the currencies referenced by the exchange rate rows.
Future<void> _insertCurrencies(AppDatabase db) async {
  for (final code in [_kFrom, _kTo, 'EUR']) {
    await db.customStatement(
      'INSERT OR IGNORE INTO currencies (code, name, symbol, minor_units, is_active) '
      "VALUES ('$code', '$code Name', '${code[0]}', 2, 1)",
    );
  }
}
