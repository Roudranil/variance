// lib/domain/usecases/currency/refresh_exchange_rates_use_case.dart
//
// Use case: refresh exchange rates from the remote API.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';

/// Fetches the latest exchange rates and upserts them into the local cache.
///
/// Called by WorkManager on a background schedule and on manual user refresh.
class RefreshExchangeRatesUseCase {
  const RefreshExchangeRatesUseCase(this._repository);

  // ignore: unused_field
  final IExchangeRateRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call() {
    throw UnimplementedError(
      'RefreshExchangeRatesUseCase.call is not implemented',
    );
  }
}
