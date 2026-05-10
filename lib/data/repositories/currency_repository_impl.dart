// lib/data/repositories/currency_repository_impl.dart
//
// Concrete implementation of ICurrencyRepository backed by Drift via CurrencyDao.
//
// getAll() and getByCode() are backed by CurrencyDao, which reads from the
// Drift-managed currencies table (seeded at first launch from
// assets/data/currencies.json). All data is local; no network fetch occurs.
//
// The remaining write operations (setHomeCurrency, enableCurrency,
// disableCurrency) are stubs — implemented in later feature tasks.

import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/repositories/i_currency_repository.dart';

/// Drift-backed implementation of [ICurrencyRepository].
///
/// Delegates all read operations to [CurrencyDao]. The currency table is
/// populated from a bundled JSON asset at first launch and is treated as
/// read-only at runtime.
class CurrencyRepositoryImpl implements ICurrencyRepository {
  /// Creates a [CurrencyRepositoryImpl] backed by [dao].
  ///
  /// Parameters:
  /// - [dao]: The [CurrencyDao] used for all currency data access.
  const CurrencyRepositoryImpl(this._dao);

  final CurrencyDao _dao;

  // -------------------------------------------------------------------------
  // Read operations (T-23)
  // -------------------------------------------------------------------------

  /// Returns all active currencies ordered by ISO 4217 code.
  ///
  /// Reads from the local Drift database populated on first launch from
  /// `assets/data/currencies.json`. No network fetch is performed.
  Future<List<Currency>> getAll() async {
    final rows = await _dao.getAllActive();
    return rows
        .map(
          (row) => Currency(
            code: row.code,
            name: row.name,
            symbol: row.symbol,
            minorUnits: row.minorUnits,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  /// Returns the [Currency] entity for [code], or null when not found.
  ///
  /// Parameters:
  /// - [code]: ISO 4217 3-letter currency code (e.g. `'USD'`, `'JPY'`).
  Future<Currency?> getByCode(String code) async {
    final row = await _dao.getByCode(code);
    if (row == null) return null;
    return Currency(
      code: row.code,
      name: row.name,
      symbol: row.symbol,
      minorUnits: row.minorUnits,
      isActive: row.isActive,
    );
  }

  // -------------------------------------------------------------------------
  // ICurrencyRepository interface — read streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<Currency>> watchAll() {
    return _dao.watchAllActive().map(
          (rows) => rows
              .map(
                (row) => Currency(
                  code: row.code,
                  name: row.name,
                  symbol: row.symbol,
                  minorUnits: row.minorUnits,
                  isActive: row.isActive,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Currency>> watchEnabled() {
    // watchEnabled and watchAll are equivalent for now — all bundled
    // currencies are active. This will diverge when user-enable/disable is
    // implemented in a later task.
    return watchAll();
  }

  // -------------------------------------------------------------------------
  // ICurrencyRepository interface — write operations (stubs)
  // -------------------------------------------------------------------------

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
