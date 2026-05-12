// test/data/repositories/exchange_rate_repository_impl_test.dart
//
// Unit tests for ExchangeRateRepositoryImpl (T-85).
// Uses in-memory AppDatabase.
//
// Test cases:
//   T-85.1. getRate returns Err(NotFoundFailure) when pair absent
//   T-85.2. getRate returns Ok(Decimal) after upsertRate
//   T-85.3. getCachedRate always returns Err (synchronous access unsupported)
//   T-85.4. upsertRate persists a rate row
//   T-85.5. upsertRate overwrites existing rate for same pair
//   T-85.6. fetchAndCache returns Ok(null) (no-op stub)
//   T-85.7. getRateEntity returns null when pair absent
//   T-85.8. getRateEntity returns domain entity after upsert

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/repositories/exchange_rate_repository_impl.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';

const _kFrom = 'INR';
const _kTo = 'USD';
const _kDate = '2025-05-01';
const _kNow = 1715000000;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExchangeRateRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting();
    await db.customStatement('SELECT 1'); // trigger onCreate
    await _insertCurrencies(db);
    repo = ExchangeRateRepositoryImpl(db.exchangeRateDao);
  });

  tearDown(() => db.close());

  // T-85.1
  test('T-85.1 getRate returns Err(NotFoundFailure) when pair absent',
      () async {
    final result = await repo.getRate(_kFrom, _kTo, _kDate);
    expect(result, isA<Err<Decimal>>());
    final err = result as Err<Decimal>;
    expect(err.failure, isA<NotFoundFailure>());
  });

  // T-85.2
  test('T-85.2 getRate returns Ok(Decimal) after upsertRate', () async {
    // 83.5 = 83500000 / 1_000_000
    await repo.upsertRate(
      from: _kFrom,
      to: _kTo,
      rateMicro: 83500000,
      fetchedAt: _kNow,
      rateDate: _kDate,
    );

    final result = await repo.getRate(_kFrom, _kTo, _kDate);
    expect(result, isA<Ok<Decimal>>());
    final ok = result as Ok<Decimal>;
    expect(ok.value, equals(Decimal.parse('83.5')));
  });

  // T-85.3
  test('T-85.3 getCachedRate always returns Err(NotFoundFailure)', () {
    final result = repo.getCachedRate(_kFrom, _kTo, _kDate);
    expect(result, isA<Err<Decimal>>());
    final err = result as Err<Decimal>;
    expect(err.failure, isA<NotFoundFailure>());
  });

  // T-85.4
  test('T-85.4 upsertRate persists a rate row', () async {
    final upsertResult = await repo.upsertRate(
      from: _kFrom,
      to: _kTo,
      rateMicro: 83000000,
      fetchedAt: _kNow,
      rateDate: _kDate,
    );
    expect(upsertResult, isA<Ok<void>>());

    final row = await db.exchangeRateDao.getRate(_kFrom, _kTo);
    expect(row, isNotNull);
    expect(row!.rateMicro, 83000000);
  });

  // T-85.5
  test('T-85.5 upsertRate overwrites existing rate for same pair', () async {
    await repo.upsertRate(
      from: _kFrom,
      to: _kTo,
      rateMicro: 80000000,
      fetchedAt: _kNow,
      rateDate: '2025-04-01',
    );
    await repo.upsertRate(
      from: _kFrom,
      to: _kTo,
      rateMicro: 85000000,
      fetchedAt: _kNow + 86400,
      rateDate: _kDate,
    );

    final result = await repo.getRate(_kFrom, _kTo, _kDate);
    expect((result as Ok<Decimal>).value, equals(Decimal.parse('85')));
  });

  // T-85.6
  test('T-85.6 fetchAndCache returns Ok(null) (no-op stub)', () async {
    final result = await repo.fetchAndCache();
    expect(result, isA<Ok<void>>());
  });

  // T-85.7
  test('T-85.7 getRateEntity returns null when pair absent', () async {
    final entity = await repo.getRateEntity(_kFrom, _kTo);
    expect(entity, isNull);
  });

  // T-85.8
  test('T-85.8 getRateEntity returns domain entity after upsert', () async {
    await repo.upsertRate(
      from: _kFrom,
      to: _kTo,
      rateMicro: 83000000,
      fetchedAt: _kNow,
      rateDate: _kDate,
    );

    final entity = await repo.getRateEntity(_kFrom, _kTo);
    expect(entity, isNotNull);
    expect(entity!.fromCurrency, _kFrom);
    expect(entity.toCurrency, _kTo);
    expect(entity.rateMicro, 83000000);
    expect(entity.rateDate, _kDate);
  });
}

/// Inserts currencies used by the exchange rate rows.
Future<void> _insertCurrencies(AppDatabase db) async {
  for (final code in [_kFrom, _kTo]) {
    await db.customStatement(
      'INSERT OR IGNORE INTO currencies (code, name, symbol, minor_units, is_active) '
      "VALUES ('$code', '$code Name', '${code[0]}', 2, 1)",
    );
  }
}
