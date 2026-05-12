// lib/data/repositories/exchange_rate_repository_impl.dart
//
// Concrete implementation of IExchangeRateRepository backed by Drift via
// ExchangeRateDao.
//
// Responsibilities (T-85):
//   - getRate: async cache-first lookup; returns Err when pair absent.
//   - getCachedRate: synchronous access not supported (Drift is async);
//     always returns Err(NotFoundFailure) with an explanatory message.
//   - fetchAndCache: no-op stub — actual network fetch is orchestrated by
//     RefreshExchangeRatesUseCase → ExchangeRateService (T-86/T-87).
//   - upsertRate: called by RefreshExchangeRatesUseCase to persist fetched rates.
//   - getRateEntity: returns full domain entity for staleness evaluation.
//
// Naming note: The Drift-generated row class for exchange_rates is also named
// `ExchangeRate`. The domain entity is imported with an alias to avoid
// ambiguity.

import 'dart:developer' as dev;

import 'package:decimal/decimal.dart';

// Drift-generated row and companion classes — used for DAO mapping only.
import 'package:variance/data/database/app_database.dart'
    show ExchangeRate, ExchangeRatesCompanion; // Drift row + companion
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart'
    as domain; // domain entity
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart'
    show IRateUpsertSink;

/// Drift-backed implementation of [IExchangeRateRepository].
///
/// Delegates cache reads/writes to [ExchangeRateDao]. The remote fetch is
/// coordinated by the infrastructure layer (ExchangeRateService) via the
/// [RefreshExchangeRatesUseCase].
class ExchangeRateRepositoryImpl
    implements IExchangeRateRepository, IRateUpsertSink {
  /// Creates an [ExchangeRateRepositoryImpl] backed by [dao].
  const ExchangeRateRepositoryImpl(this._dao);

  final ExchangeRateDao _dao;

  /// Scale factor: rateMicro is rate × 1,000,000 (6 decimal places).
  static const int _microScale = 1000000;

  @override
  Future<Result<Decimal>> getRate(String from, String to, String date) async {
    try {
      final row = await _dao.getRate(from, to);
      if (row == null) {
        return Err(NotFoundFailure('No cached rate for $from → $to'));
      }
      // Decimal / Decimal returns Rational; convert back with toDecimal().
      final rational =
          Decimal.fromInt(row.rateMicro) / Decimal.fromInt(_microScale);
      final rate = rational.toDecimal(scaleOnInfinitePrecision: 6);
      return Ok(rate);
    } on Exception catch (e) {
      dev.log(
        'ExchangeRateRepositoryImpl.getRate failed: $e',
        name: 'ExchangeRateRepositoryImpl',
      );
      return Err(DatabaseFailure('Failed to read exchange rate: $e'));
    }
  }

  @override
  Result<Decimal> getCachedRate(String from, String to, String date) {
    // Drift is async-only — true synchronous reads are not possible.
    // Callers requiring synchronous access must pre-load and hold the value.
    return const Err(
      NotFoundFailure(
        'Synchronous exchange rate access is not supported by '
        'ExchangeRateRepositoryImpl; use getRate() for async lookup.',
      ),
    );
  }

  @override
  Future<Result<void>> fetchAndCache() async {
    // Stub: fetch coordination lives in ExchangeRateService (T-86) and
    // RefreshExchangeRatesUseCase (T-87). Actual upserts are done via
    // [upsertRate] called from the use case after a successful HTTP fetch.
    return const Ok(null);
  }

  /// Upserts a single exchange rate into the local cache.
  ///
  /// Called by [RefreshExchangeRatesUseCase] after a successful network fetch.
  ///
  /// Parameters:
  /// - [from]: ISO 4217 base currency code.
  /// - [to]: ISO 4217 target currency code.
  /// - [rateMicro]: Exchange rate × 1,000,000.
  /// - [fetchedAt]: Unix epoch seconds when the rate was fetched.
  /// - [rateDate]: ISO 8601 date string from API `date` field.
  @override
  Future<Result<void>> upsertRate({
    required String from,
    required String to,
    required int rateMicro,
    required int fetchedAt,
    required String rateDate,
  }) async {
    try {
      await _dao.upsertRate(
        ExchangeRatesCompanion.insert(
          fromCurrency: from,
          toCurrency: to,
          rateMicro: rateMicro,
          fetchedAt: fetchedAt,
          rateDate: rateDate,
        ),
      );
      return const Ok(null);
    } on Exception catch (e) {
      dev.log(
        'ExchangeRateRepositoryImpl.upsertRate failed: $e',
        name: 'ExchangeRateRepositoryImpl',
      );
      return Err(DatabaseFailure('Failed to upsert exchange rate: $e'));
    }
  }

  @override
  Future<domain.ExchangeRate?> getRateEntity(String from, String to) async {
    final row = await _dao.getRate(from, to);
    return row == null ? null : _rowToEntity(row);
  }

  // -----------------------------------------------------------------------
  // Private mapping helpers
  // -----------------------------------------------------------------------

  /// Maps a Drift-generated [ExchangeRate] row to the domain entity.
  domain.ExchangeRate _rowToEntity(ExchangeRate row) {
    return domain.ExchangeRate(
      id: row.id,
      fromCurrency: row.fromCurrency,
      toCurrency: row.toCurrency,
      rateMicro: row.rateMicro,
      fetchedAt: row.fetchedAt,
      rateDate: row.rateDate,
    );
  }
}
