// lib/domain/usecases/currency/refresh_exchange_rates_use_case.dart
//
// Use case: refresh exchange rates from the remote API (T-87).
//
// Orchestration:
//   1. Query DISTINCT active account currencies via IAccountRepository.
//   2. If only the home currency is present → return Ok(null) immediately;
//      no network fetch needed.
//   3. Call ExchangeRateService.fetchRatesForBase() for the home currency to
//      get rates for all target currencies in one request.
//   4. For each target currency, upsert the rate via IRateUpsertSink.
//   5. On service failure, return Err without propagating to the UI.
//
// Business rules:
//   - Only active (non-deleted) accounts are considered (SDS §2.7.2).
//   - Fetch is scoped to currencies where the user holds accounts — no
//     speculative pre-fetching.
//   - Silent failure: the WorkManager task caller handles Err silently.
//
// Test cases (see test/unit/domain/usecases/refresh_exchange_rates_use_case_test.dart):
//   T-87.1. single-home-currency path — no fetch issued
//   T-87.2. multi-currency path — fetch and upsert called
//   T-87.3. service-failure path — returns Err(NetworkFailure)

import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_service.dart';

/// Abstract sink for upserting exchange rate rows.
///
/// Implemented by [ExchangeRateRepositoryImpl]; exposed as an interface so
/// the use case does not depend on a Drift-specific concrete class (which
/// would prevent pure-Dart unit testing).
abstract interface class IRateUpsertSink {
  /// Upserts a single exchange rate into the local cache.
  ///
  /// Parameters:
  /// - [from]: ISO 4217 base currency code.
  /// - [to]: ISO 4217 target currency code.
  /// - [rateMicro]: Exchange rate × 1,000,000.
  /// - [fetchedAt]: Unix epoch seconds when the rate was fetched.
  /// - [rateDate]: ISO 8601 date string from the API `date` field.
  Future<Result<void>> upsertRate({
    required String from,
    required String to,
    required int rateMicro,
    required int fetchedAt,
    required String rateDate,
  });
}

/// Fetches the latest exchange rates and upserts them into the local cache.
///
/// Intended to be called by the WorkManager background task on a daily cadence
/// and on manual user refresh. Silently no-ops when the user has only one
/// currency (the home currency).
class RefreshExchangeRatesUseCase {
  /// Creates a [RefreshExchangeRatesUseCase].
  ///
  /// Parameters:
  /// - [accountRepository]: Used to query distinct active account currencies.
  /// - [rateUpsertSink]: Receives the fetched rates for persistence.
  /// - [exchangeRateService]: HTTP client for fetching rates.
  /// - [homeCurrency]: ISO 4217 home currency code from app settings.
  const RefreshExchangeRatesUseCase({
    required IAccountRepository accountRepository,
    required IRateUpsertSink rateUpsertSink,
    required ExchangeRateService exchangeRateService,
    required String homeCurrency,
  })  : _accountRepository = accountRepository,
        _rateUpsertSink = rateUpsertSink,
        _exchangeRateService = exchangeRateService,
        _homeCurrency = homeCurrency;

  final IAccountRepository _accountRepository;
  final IRateUpsertSink _rateUpsertSink;
  final ExchangeRateService _exchangeRateService;
  final String _homeCurrency;

  /// Executes the exchange rate refresh.
  ///
  /// Returns [Ok(null)] when: (a) single-currency — no fetch needed, or
  /// (b) multi-currency — fetch and upsert succeeded.
  /// Returns [Err] when the network fetch fails.
  Future<Result<void>> call() async {
    // Step 1: query distinct active currencies.
    final currencies = await _accountRepository.getDistinctActiveCurrencies();

    // Step 2: if only home currency → skip fetch.
    final foreignCurrencies =
        currencies.where((c) => c != _homeCurrency).toList();
    if (foreignCurrencies.isEmpty) {
      dev.log(
        'RefreshExchangeRatesUseCase: only home currency present; skipping fetch.',
        name: 'RefreshExchangeRatesUseCase',
      );
      return const Ok(null);
    }

    // Step 3: fetch rates for home currency (one request returns all targets).
    final fetchResult =
        await _exchangeRateService.fetchRatesForBase(_homeCurrency);
    switch (fetchResult) {
      case Err(:final failure):
        dev.log(
          'RefreshExchangeRatesUseCase: service fetch failed — ${failure.message}',
          name: 'RefreshExchangeRatesUseCase',
        );
        return Err(failure);
      case Ok(:final value):
        // Step 4: upsert a rate row for each foreign currency present.
        final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        for (final target in foreignCurrencies) {
          final targetLower = target.toLowerCase();
          final rate = value.rates[targetLower];
          if (rate == null) {
            dev.log(
              'RefreshExchangeRatesUseCase: no rate for $target in response; skipping.',
              name: 'RefreshExchangeRatesUseCase',
            );
            continue;
          }
          // Convert double rate to micro units (× 1,000,000).
          final rateMicro = (rate * 1000000).round();
          await _rateUpsertSink.upsertRate(
            from: _homeCurrency,
            to: target,
            rateMicro: rateMicro,
            fetchedAt: nowEpoch,
            rateDate: value.rateDate,
          );
        }
        return const Ok(null);
    }
  }
}
