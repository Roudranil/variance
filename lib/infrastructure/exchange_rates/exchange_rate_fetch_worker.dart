// lib/infrastructure/exchange_rates/exchange_rate_fetch_worker.dart
//
// WorkManager background task for fetching exchange rates (T-88).
//
// Task name: 'exchange_rate_fetch'
//
// Behaviour:
//   1. Read last_exchange_rate_fetch from app_settings.
//   2. If (now - lastFetch) < 23 * 3600 → return true (skip; already fresh).
//   3. Otherwise call RefreshExchangeRatesUseCase.call().
//   4. On success → update last_exchange_rate_fetch in app_settings.
//   5. On failure → return true (silent failure; WorkManager will NOT retry).
//
// Registration:
//   Call [ExchangeRateFetchWorker.register] on app startup.
//   Uses NetworkType.connected constraint — skips when offline.
//
// Test cases (see test/infrastructure/exchange_rates/exchange_rate_fetch_worker_test.dart):
//   T-88.1. within 23 hours — no fetch, returns true
//   T-88.2. outside 23 hours — fetch triggered, timestamp updated, returns true
//   T-88.3. fetch failure — silent failure, returns true

import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart';
import 'package:workmanager/workmanager.dart';

/// Unique task name registered with WorkManager.
const kExchangeRateFetchTaskName = 'exchange_rate_fetch';

/// Unique task tag used for deduplication in WorkManager.
const kExchangeRateFetchTaskTag = 'exchange_rate_fetch_tag';

/// Minimum interval between fetches in seconds (23 hours).
///
/// Allows a 1-hour jitter window over a 24-hour day, matching WorkManager
/// scheduling precision (SDS §2.7.2).
const kMinFetchIntervalSeconds = 23 * 3600;

/// Stateless helper for registering and executing the exchange rate WorkManager
/// task.
///
/// All collaborators are passed into [execute] rather than the constructor, so
/// that the task callback (which is a top-level function) can build them from
/// the DI container at runtime without holding a reference to long-lived
/// instances.
class ExchangeRateFetchWorker {
  const ExchangeRateFetchWorker._();

  /// Registers a one-off WorkManager task to be triggered as soon as the
  /// device is connected.
  ///
  /// The task will not run more than once per [kMinFetchIntervalSeconds] due to
  /// the gate in [execute]. Calling this on every app start is safe because
  /// WorkManager deduplicates by [kExchangeRateFetchTaskTag].
  static Future<void> register() async {
    await Workmanager().registerOneOffTask(
      kExchangeRateFetchTaskName,
      kExchangeRateFetchTaskName,
      tag: kExchangeRateFetchTaskTag,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// Executes the exchange rate fetch logic.
  ///
  /// Called from the WorkManager callback. Applies the 23-hour gate, delegates
  /// to [useCase] on a cache miss, and updates [settingsRepository] on success.
  ///
  /// Always returns `true` — WorkManager success signal; errors are silent.
  ///
  /// Parameters:
  /// - [settingsRepository]: Provides the last-fetch timestamp and receives the
  ///   updated timestamp on success.
  /// - [useCase]: Performs the actual network fetch and cache upsert.
  static Future<bool> execute({
    required IAppSettingsRepository settingsRepository,
    required RefreshExchangeRatesUseCase useCase,
  }) async {
    try {
      final settings = await settingsRepository.watch().first;
      final lastFetch = settings.lastExchangeRateFetch ?? 0;
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Gate: skip if already fetched within 23 hours.
      if ((nowEpoch - lastFetch) < kMinFetchIntervalSeconds) {
        dev.log(
          'ExchangeRateFetchWorker: skipping — last fetch was '
          '${nowEpoch - lastFetch}s ago (< ${kMinFetchIntervalSeconds}s)',
          name: 'ExchangeRateFetchWorker',
        );
        return true;
      }

      final result = await useCase.call();
      switch (result) {
        case Ok():
          // Update the last-fetch timestamp on success.
          await settingsRepository.update(
            AppSettingsPatch(lastExchangeRateFetch: nowEpoch),
          );
          dev.log(
            'ExchangeRateFetchWorker: fetch succeeded; timestamp updated.',
            name: 'ExchangeRateFetchWorker',
          );
        case Err(:final failure):
          dev.log(
            'ExchangeRateFetchWorker: fetch failed (silent) — ${failure.message}',
            name: 'ExchangeRateFetchWorker',
          );
      }
    } on Exception catch (e) {
      dev.log(
        'ExchangeRateFetchWorker: unexpected error (silent) — $e',
        name: 'ExchangeRateFetchWorker',
      );
    }

    return true;
  }
}
