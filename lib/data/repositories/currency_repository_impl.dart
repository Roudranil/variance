// lib/data/repositories/currency_repository_impl.dart
//
// Concrete implementation of ICurrencyRepository backed by Drift via CurrencyDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic is implemented in later feature tasks.

import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/repositories/i_currency_repository.dart';

/// Drift-backed implementation of [ICurrencyRepository].
///
/// Delegates all data access to [CurrencyDao]. The currency table is
/// populated from a bundled JSON asset at first launch and treated as
/// read-only thereafter.
class CurrencyRepositoryImpl implements ICurrencyRepository {
  /// Creates a [CurrencyRepositoryImpl] backed by [dao].
  const CurrencyRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
  final CurrencyDao _dao;

  @override
  Stream<List<Currency>> watchAll() {
    // TODO(dev): Map Drift Currency rows to domain Currency entities.
    throw UnimplementedError('watchAll not yet implemented');
  }

  @override
  Stream<List<Currency>> watchEnabled() {
    // TODO(dev): Filter to user-enabled currencies only.
    throw UnimplementedError('watchEnabled not yet implemented');
  }

  @override
  Future<Result<void>> setHomeCurrency(String code) {
    // TODO(dev): Persist home_currency setting via AppSettingsRepository.
    throw UnimplementedError('setHomeCurrency not yet implemented');
  }

  @override
  Future<Result<void>> enableCurrency(String code) {
    // TODO(dev): Set is_active = true for the given code.
    throw UnimplementedError('enableCurrency not yet implemented');
  }

  @override
  Future<Result<void>> disableCurrency(String code) {
    // TODO(dev): Set is_active = false for the given code.
    throw UnimplementedError('disableCurrency not yet implemented');
  }
}
