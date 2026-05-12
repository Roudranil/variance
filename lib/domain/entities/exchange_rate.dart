// lib/domain/entities/exchange_rate.dart
//
// ExchangeRate domain entity.
//
// Cached exchange rate pair from the fawazahmed0 API. Upserted on each
// successful fetch. Staleness threshold: 14 days (SDS §2.7).
//
// Rate precision: stored as INTEGER micro units (rate × 1,000,000).
//
// Computed getters (T-80):
//   - rate: rateMicro / 1,000,000 as double
//   - isStale: true when (now - fetchedAt) > 14 * 86400 seconds

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate.freezed.dart';

/// Staleness threshold in seconds: 14 days.
const _kStaleThresholdSeconds = 14 * 86400;

/// Micro-unit divisor for rate conversion.
const _kRateMicroDivisor = 1000000.0;

/// Immutable domain entity for a cached currency exchange rate.
@freezed
abstract class ExchangeRate with _$ExchangeRate {
  // Private constructor required for computed getters in Freezed.
  const ExchangeRate._();

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

  // ---------------------------------------------------------------------------
  // Computed getters (T-80)
  // ---------------------------------------------------------------------------

  /// The exchange rate as a [double], derived from [rateMicro] / 1,000,000.
  ///
  /// Example: rateMicro = 83_000_000 → rate = 83.0 (USD → INR).
  double get rate => rateMicro / _kRateMicroDivisor;

  /// Returns true when the cached rate is older than 14 days.
  ///
  /// Staleness threshold: (DateTime.now().difference(fetchedAt)) > 14 * 86400
  /// seconds. The UI shows a disclaimer when this is true (SDS §2.7).
  bool get isStale {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (nowEpoch - fetchedAt) > _kStaleThresholdSeconds;
  }
}
