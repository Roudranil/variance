// lib/data/database/daos/exchange_rate_dao.dart
//
// DAO for the `exchange_rates` cache table.
//
// Responsibilities:
//   - Read/write on exchange_rates using INSERT OR REPLACE upsert semantics
//   - Staleness check query

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/exchange_rates_table.dart';

part 'exchange_rate_dao.g.dart';

/// DAO for the exchange rate cache.
///
/// Rates are upserted via [upsertRate] on each successful API fetch. The
/// UNIQUE constraint on (from_currency, to_currency) ensures INSERT OR
/// REPLACE deduplications the pair.
@DriftAccessor(tables: [ExchangeRates])
class ExchangeRateDao extends DatabaseAccessor<AppDatabase>
    with _$ExchangeRateDaoMixin {
  /// Creates a new [ExchangeRateDao] bound to [db].
  ExchangeRateDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns the cached [ExchangeRate] for the given currency pair, or null
  /// if no row exists.
  ///
  /// Parameters:
  /// - [fromCurrency]: ISO 4217 base currency code.
  /// - [toCurrency]: ISO 4217 target currency code.
  Future<ExchangeRate?> getRate(String fromCurrency, String toCurrency) {
    return (select(exchangeRates)
          ..where(
            (r) =>
                r.fromCurrency.equals(fromCurrency) &
                r.toCurrency.equals(toCurrency),
          ))
        .getSingleOrNull();
  }

  /// Upserts an exchange rate using ON CONFLICT DO UPDATE semantics.
  ///
  /// The UNIQUE constraint on (from_currency, to_currency) is the conflict
  /// target. When a row with the same pair already exists, its [rateMicro],
  /// [fetchedAt], and [rateDate] columns are updated in-place.
  ///
  /// Parameters:
  /// - [rate]: The companion carrying the rate values to upsert.
  Future<int> upsertRate(ExchangeRatesCompanion rate) {
    return into(exchangeRates).insert(
      rate,
      onConflict: DoUpdate(
        (old) => ExchangeRatesCompanion.custom(
          // Variable() wraps a plain Dart value as a Drift Expression.
          rateMicro: Variable(rate.rateMicro.value),
          fetchedAt: Variable(rate.fetchedAt.value),
          rateDate: Variable(rate.rateDate.value),
        ),
        target: [exchangeRates.fromCurrency, exchangeRates.toCurrency],
      ),
    );
  }

  /// Returns all cached rates fetched before the [thresholdEpoch] (i.e.
  /// potentially stale rows).
  ///
  /// The staleness threshold is 14 days (SDS §2.7.4).
  ///
  /// Parameters:
  /// - [thresholdEpoch]: Unix epoch seconds. Rates with [fetchedAt] before
  ///   this value are considered stale.
  Future<List<ExchangeRate>> getStaleRates(int thresholdEpoch) {
    return (select(exchangeRates)
          ..where((r) => r.fetchedAt.isSmallerThanValue(thresholdEpoch)))
        .get();
  }

  /// Watches all cached exchange rate rows as a reactive stream.
  ///
  /// Emits a new list whenever any row in the `exchange_rates` table changes.
  /// Consumed by [IExchangeRateRepository.watchAllRates] and UI staleness
  /// indicators.
  Stream<List<ExchangeRate>> watchAllRates() {
    return select(exchangeRates).watch();
  }
}
