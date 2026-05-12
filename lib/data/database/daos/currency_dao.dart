// lib/data/database/daos/currency_dao.dart
//
// DAO for the `currencies` reference table.
//
// Read-only access only. The currencies table is populated from a static
// JSON asset at first launch and never mutated at runtime.

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/currencies_table.dart';

part 'currency_dao.g.dart';

/// DAO for read-only access to the bundled ISO 4217 currency reference table.
///
/// No write methods are exposed — the table is populated once from the
/// bundled JSON asset and treated as read-only thereafter.
@DriftAccessor(tables: [Currencies])
class CurrencyDao extends DatabaseAccessor<AppDatabase>
    with _$CurrencyDaoMixin {
  /// Creates a new [CurrencyDao] bound to [db].
  CurrencyDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns all active currencies ordered by code.
  Future<List<Currency>> getAllActive() {
    return (select(currencies)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.code)]))
        .get();
  }

  /// Returns the [Currency] row for the given ISO 4217 [code], or null if
  /// not found.
  ///
  /// Parameters:
  /// - [code]: ISO 4217 3-letter currency code (e.g. `'USD'`, `'INR'`).
  Future<Currency?> getByCode(String code) {
    return (select(currencies)..where((c) => c.code.equals(code)))
        .getSingleOrNull();
  }

  /// Returns a reactive stream of all active currencies.
  Stream<List<Currency>> watchAllActive() {
    return (select(currencies)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.code)]))
        .watch();
  }

  /// Returns a reactive stream of all currencies (including inactive).
  Stream<List<Currency>> watchAll() {
    return (select(currencies)..orderBy([(c) => OrderingTerm.asc(c.code)]))
        .watch();
  }

  // -----------------------------------------------------------------------
  // Write operations (T-83)
  // -----------------------------------------------------------------------

  /// Sets [isActive] = true for the currency with [code].
  ///
  /// Parameters:
  /// - [code]: ISO 4217 3-letter currency code.
  Future<void> setActive(String code, {required bool isActive}) {
    return (update(currencies)..where((c) => c.code.equals(code))).write(
      CurrenciesCompanion(isActive: Value(isActive)),
    );
  }
}
