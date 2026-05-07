// lib/domain/repositories/i_exchange_rate_repository.dart
//
// Abstract repository interface for the ExchangeRate aggregate.

import 'package:decimal/decimal.dart';
import 'package:variance/domain/core/result.dart';

/// Contract for all ExchangeRate data-access and fetch operations.
abstract interface class IExchangeRateRepository {
  /// Returns the exchange rate for [from] → [to] on [date] (ISO 8601 string).
  ///
  /// Cache-first: reads the cached value if available. Returns a staleness
  /// warning in the failure message if the cached rate is older than 14 days.
  Future<Result<Decimal>> getRate(String from, String to, String date);

  /// Synchronously returns the cached rate for [from] → [to] on [date].
  ///
  /// Returns Err(NotFoundFailure) if the pair is not in the local cache.
  Result<Decimal> getCachedRate(String from, String to, String date);

  /// Fetches the latest rates from the remote API and upserts them into the
  /// local cache. Called by WorkManager on a background schedule.
  Future<Result<void>> fetchAndCache();
}
