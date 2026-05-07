// lib/domain/usecases/currency/get_exchange_rate_use_case.dart
//
// Use case: retrieve an exchange rate for a currency pair.

import 'package:decimal/decimal.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';

/// Input for retrieving an exchange rate.
class GetExchangeRateInput {
  const GetExchangeRateInput({
    required this.from,
    required this.to,
    required this.date,
  });

  /// ISO 4217 source currency code.
  final String from;

  /// ISO 4217 target currency code.
  final String to;

  /// ISO 8601 date string (e.g. '2025-05-07').
  final String date;
}

/// Retrieves the exchange rate for a given currency pair and date.
///
/// Cache-first: reads the local cache and falls back to indicating staleness.
class GetExchangeRateUseCase {
  const GetExchangeRateUseCase(this._repository);

  // ignore: unused_field
  final IExchangeRateRepository _repository;

  /// Executes the use case.
  Future<Result<Decimal>> call(GetExchangeRateInput input) {
    throw UnimplementedError('GetExchangeRateUseCase.call is not implemented');
  }
}
