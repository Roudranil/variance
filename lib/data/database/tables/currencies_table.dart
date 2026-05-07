// lib/data/database/tables/currencies_table.dart
//
// Drift table definition for `currencies`.
//
// Read-only at runtime. Populated from a static JSON asset at first launch.
// Uses the ISO 4217 3-letter code as the primary key (no UUID).

import 'package:drift/drift.dart';

/// Drift table for the bundled ISO 4217 currency reference data.
///
/// This table is read-only at runtime. No indexes are needed as the table
/// is small (~180 rows) and accessed only by primary key.
class Currencies extends Table {
  /// ISO 4217 3-letter currency code (e.g. 'USD', 'INR').
  TextColumn get code => text()();

  /// Full currency name (e.g. 'US Dollar').
  TextColumn get name => text()();

  /// Display symbol (e.g. '$', '₹').
  TextColumn get symbol => text()();

  /// Number of decimal places. Valid values: 0 (JPY), 2 (USD), 3 (BHD).
  IntColumn get minorUnits => integer().withDefault(const Constant(2))();

  /// False for retired ISO currencies.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {code};
}
