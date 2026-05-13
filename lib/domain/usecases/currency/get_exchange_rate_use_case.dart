// lib/domain/usecases/currency/get_exchange_rate_use_case.dart
//
// Use case: retrieve the cached ExchangeRate entity for a currency pair.
//
// Specification: T-93, CURR-03, SDS §2.7.4
//
// Behaviour:
//   - Calls IExchangeRateRepository.getRateEntity(from, to)
//   - Returns Ok(ExchangeRate) on cache hit (entity includes isStale getter)
//   - Returns Err(RateUnavailableFailure) when no cached rate exists
//
// Test cases (see test/unit/domain/usecases/get_exchange_rate_use_case_test.dart):
//   1. rate present (fresh)   → Ok(ExchangeRate) with isStale=false
//   2. rate present (stale)   → Ok(ExchangeRate) with isStale=true
//   3. rate absent            → Err(RateUnavailableFailure)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';

/// Input for retrieving a cached exchange rate.
class GetExchangeRateInput {
  /// Creates a [GetExchangeRateInput].
  ///
  /// Parameters:
  /// - [from]: ISO 4217 source currency code.
  /// - [to]: ISO 4217 target currency code.
  const GetExchangeRateInput({
    required this.from,
    required this.to,
  });

  /// ISO 4217 source currency code.
  final String from;

  /// ISO 4217 target currency code.
  final String to;
}

/// Retrieves the cached [ExchangeRate] entity for a given currency pair.
///
/// Uses the local cache only (no network call). The returned entity includes
/// the [ExchangeRate.isStale] computed getter so callers can decide whether
/// to show a staleness warning in the UI (SDS §2.7.4).
class GetExchangeRateUseCase {
  /// Creates a [GetExchangeRateUseCase] bound to [repository].
  const GetExchangeRateUseCase(this._repository);

  final IExchangeRateRepository _repository;

  /// Executes the use case for the given [input].
  ///
  /// Returns [Ok<ExchangeRate>] when a cached rate exists, or
  /// [Err<RateUnavailableFailure>] when no row is in the local cache for
  /// the [from]→[to] pair.
  Future<Result<ExchangeRate>> call(GetExchangeRateInput input) async {
    final entity = await _repository.getRateEntity(input.from, input.to);
    if (entity == null) {
      return Err(
        RateUnavailableFailure(
          'No cached rate for ${input.from} → ${input.to}',
        ),
      );
    }
    return Ok(entity);
  }
}
