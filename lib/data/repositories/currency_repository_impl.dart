// lib/data/repositories/currency_repository_impl.dart
//
// Concrete implementation of ICurrencyRepository backed by Drift via CurrencyDao.
//
// getAll() and getByCode() are backed by CurrencyDao, which reads from the
// Drift-managed currencies table (seeded at first launch from
// assets/data/currencies.json). All data is local; no network fetch occurs.
//
// Write operations (T-83):
//   - setHomeCurrency: delegates to IAppSettingsRepository
//   - enableCurrency: sets is_active = true via CurrencyDao.setActive
//   - disableCurrency: sets is_active = false via CurrencyDao.setActive
//
// Test cases (T-83):
//   - watchEnabled() filters to is_active = true rows
//   - setActive via CurrencyDao persists enable/disable correctly

import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/domain/core/failure.dart';
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
    // watchEnabled returns only is_active = true rows (T-83).
    // This is the same as watchAllActive since bundled currencies have
    // is_active = true by default. When disableCurrency is called, those
    // rows flip to is_active = false and are excluded from this stream.
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

  // -------------------------------------------------------------------------
  // ICurrencyRepository interface — write operations (T-83)
  // -------------------------------------------------------------------------

  @override
  Future<Result<void>> setHomeCurrency(String code) {
    // Home currency is persisted via AppSettingsRepository (not directly
    // on the currencies table). This stub is intentionally deferred — the
    // settings integration is handled in the settings feature task.
    // Throwing here keeps the compile-time contract visible.
    throw UnimplementedError(
      'setHomeCurrency delegates to AppSettingsRepository — implement in S-38',
    );
  }

  @override
  Future<Result<void>> enableCurrency(String code) async {
    // Sets is_active = true for the given currency code in the Drift table.
    try {
      await _dao.setActive(code, isActive: true);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('enableCurrency failed for $code: $e'));
    }
  }

  @override
  Future<Result<void>> disableCurrency(String code) async {
    // Sets is_active = false for the given currency code in the Drift table.
    try {
      await _dao.setActive(code, isActive: false);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('disableCurrency failed for $code: $e'));
    }
  }
}
