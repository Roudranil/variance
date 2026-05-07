// lib/domain/entities/currency.dart
//
// Currency domain entity.
//
// ISO 4217 currency reference. Read-only at runtime; populated from the
// bundled currencies.json asset at first launch (~180 currencies).
//
// Amount storage rule: all monetary amounts are stored as INTEGER in minor
// units (e.g. JPY minor_units=0, USD minor_units=2, BHD minor_units=3).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';

/// Immutable domain entity for an ISO 4217 currency.
@freezed
abstract class Currency with _$Currency {
  const factory Currency({
    /// ISO 4217 three-letter code (e.g. 'USD', 'INR', 'JPY').
    required String code,

    /// Full English name (e.g. 'US Dollar').
    required String name,

    /// Display symbol (e.g. '$', '₹').
    required String symbol,

    /// Number of decimal places: 0 for JPY, 2 for USD, 3 for BHD.
    @Default(2) int minorUnits,

    /// False for retired ISO currencies.
    @Default(true) bool isActive,
  }) = _Currency;
}
