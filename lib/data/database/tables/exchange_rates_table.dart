// lib/data/database/tables/exchange_rates_table.dart
//
// Drift table definition for `exchange_rates`.
//
// Cached exchange rates from the fawazahmed0 API. Uses INTEGER AUTOINCREMENT
// as PK (no UUID needed — internal cache row). UNIQUE constraint on the
// currency pair acts as the deduplication key for INSERT OR REPLACE upserts.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/currencies_table.dart';

/// Drift table for cached currency exchange rates.
///
/// Rates are stored as integers scaled by 1,000,000 ([rateMicro]) to avoid
/// floating-point precision loss. Staleness threshold is 14 days, checked
/// via [fetchedAt].
class ExchangeRates extends Table {
  /// Auto-incrementing row identifier (internal cache; no sync requirement).
  IntColumn get id => integer().autoIncrement()();

  /// Base currency code.
  TextColumn get fromCurrency => text().references(Currencies, #code)();

  /// Target currency code.
  TextColumn get toCurrency => text().references(Currencies, #code)();

  /// Exchange rate × 1,000,000 (6 decimal places). Must be > 0.
  IntColumn get rateMicro => integer()();

  /// Wall-clock Unix epoch seconds when this rate was fetched.
  IntColumn get fetchedAt => integer()();

  /// ISO 8601 date string from the API `date` field (e.g. `2025-05-07`).
  TextColumn get rateDate => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {fromCurrency, toCurrency},
      ];
}
