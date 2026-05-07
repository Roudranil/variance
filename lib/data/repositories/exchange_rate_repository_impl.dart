// lib/data/repositories/exchange_rate_repository_impl.dart
//
// Concrete implementation of IExchangeRateRepository backed by Drift via
// ExchangeRateDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic (HTTP fetch, staleness checks) is implemented in the
// infrastructure layer in later feature tasks.

import 'package:decimal/decimal.dart';
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';

/// Drift-backed implementation of [IExchangeRateRepository].
///
/// Delegates cache reads/writes to [ExchangeRateDao]. The remote fetch is
/// coordinated by the infrastructure layer (ExchangeRateService).
class ExchangeRateRepositoryImpl implements IExchangeRateRepository {
  /// Creates an [ExchangeRateRepositoryImpl] backed by [dao].
  const ExchangeRateRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
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
}
