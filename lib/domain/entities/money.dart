// lib/domain/entities/money.dart
//
// Money value object: amount in minor units + ISO 4217 currency code.
//
// All monetary amounts in the domain are represented as integer minor units
// (the smallest denomination of a currency). Never use double for money.
//
// Examples:
//   Money(amountMinor: 50000, currencyCode: 'USD') → $500.00
//   Money(amountMinor: 500, currencyCode: 'JPY')   → ¥500
//   Money(amountMinor: 500000, currencyCode: 'BHD') → BHD 500.000

import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';

/// Immutable value object representing a monetary amount.
///
/// [amountMinor] is always a non-negative integer in the currency's minor
/// unit (e.g. cents for USD, paise for INR, yen for JPY).
@freezed
abstract class Money with _$Money {
  const factory Money({
    /// Amount in the smallest denomination of [currencyCode].
    required int amountMinor,

    /// ISO 4217 three-letter currency code (e.g. 'USD', 'INR', 'JPY').
    required String currencyCode,
  }) = _Money;
}
