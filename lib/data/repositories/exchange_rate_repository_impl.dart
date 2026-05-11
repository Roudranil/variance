// lib/data/repositories/exchange_rate_repository_impl.dart
//
// Concrete implementation of IExchangeRateRepository backed by Drift via
// ExchangeRateDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic (HTTP fetch, staleness checks) is implemented in the
// infrastructure layer in later feature tasks.
//
// Naming note: The Drift-generated row class for exchange_rates is also named
// `ExchangeRate`. The domain entity is imported with an alias to avoid
// ambiguity.

import 'package:decimal/decimal.dart';

// Drift-generated row class — used for DAO mapping only.
import 'package:variance/data/database/app_database.dart'
    show ExchangeRate; // Drift row
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart'
    as domain; // domain entity
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';

/// Drift-backed implementation of [IExchangeRateRepository].
///
/// Delegates cache reads/writes to [ExchangeRateDao]. The remote fetch is
/// coordinated by the infrastructure layer (ExchangeRateService).
class ExchangeRateRepositoryImpl implements IExchangeRateRepository {
  /// Creates an [ExchangeRateRepositoryImpl] backed by [dao].
  const ExchangeRateRepositoryImpl(this._dao);

  final ExchangeRateDao _dao;

  @override
  Future<Result<Decimal>> getRate(String from, String to, String date) {
    // TODO(dev): Implement cache-first rate lookup with staleness detection.
    throw UnimplementedError('getRate not yet implemented');
  }

  @override
  Result<Decimal> getCachedRate(String from, String to, String date) {
    // TODO(dev): Implement synchronous cache read.
    throw UnimplementedError('getCachedRate not yet implemented');
  }

  @override
  Future<Result<void>> fetchAndCache() {
    // TODO(dev): Implement remote API fetch + upsert via ExchangeRateService.
    throw UnimplementedError('fetchAndCache not yet implemented');
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
