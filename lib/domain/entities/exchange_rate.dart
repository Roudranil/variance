// lib/domain/entities/exchange_rate.dart
//
// ExchangeRate domain entity.
//
// Cached exchange rate pair from the fawazahmed0 API. Upserted on each
// successful fetch. Staleness threshold: 14 days (SDS §2.7).
//
// Rate precision: stored as INTEGER micro units (rate × 1,000,000).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate.freezed.dart';

/// Immutable domain entity for a cached currency exchange rate.
@freezed
abstract class ExchangeRate with _$ExchangeRate {
  const factory ExchangeRate({
    /// Row identifier (auto-increment, not UUID, per data model §4.2).
    required int id,

    /// Base currency ISO 4217 code.
    required String fromCurrency,

    /// Target currency ISO 4217 code.
    required String toCurrency,

    /// Exchange rate × 1,000,000 (6 decimal precision).
    required int rateMicro,

    /// Wall-clock epoch when the rate was fetched from the API.
    required int fetchedAt,

    /// Publication date from the API `date` field (ISO 8601, e.g. '2025-05-07').
    required String rateDate,
  }) = _ExchangeRate;
}
