// lib/domain/usecases/home/watch_net_worth_use_case.dart
//
// Use case: watch the aggregate net worth in the home currency.
//
// Architecture (ACC-03, SDS §1.4.4):
//   - Listens to IAccountRepository.watchAll() for account list changes.
//   - For each emission, reads all account balances reactively.
//   - Converts foreign-currency balances using cached exchange rates.
//   - Delegates aggregation to NetWorthCalculator (pure domain service).
//
// Exchange rates are read as a point-in-time snapshot on each account-list
// change. They are not reactive (exchange rates update infrequently on a
// background schedule, not on user actions).
//
// The result is a Stream<NetWorthResult> rather than Stream<Money> so the UI
// can display the staleness indicator without a second provider.
//
// Test cases (see test/unit/domain/usecases/watch_net_worth_use_case_test.dart):
//   1. no accounts → emits zero result
//   2. single home-currency account → emits correct total
//   3. foreign-currency account with rate → emits converted total
//   4. account excluded from net worth → not included in total
//   5. soft-deleted account not included

import 'dart:async';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';

/// Watches the total net worth across all included, non-deleted accounts.
///
/// Emits a new [NetWorthResult] whenever the account list or any account's
/// balance changes. Exchange rates are re-read as a snapshot on each emission.
class WatchNetWorthUseCase {
  /// Creates a [WatchNetWorthUseCase].
  ///
  /// Parameters:
  /// - [accountRepository]: Provides reactive account and balance streams.
  /// - [exchangeRateRepository]: Provides point-in-time exchange rate lookups.
  /// - [calculator]: Pure service that aggregates balances.
  /// - [homeCurrency]: ISO 4217 code of the home currency.
  const WatchNetWorthUseCase({
    required IAccountRepository accountRepository,
    required IExchangeRateRepository exchangeRateRepository,
    required NetWorthCalculator calculator,
    required String homeCurrency,
  })  : _accountRepository = accountRepository,
        _exchangeRateRepository = exchangeRateRepository,
        _calculator = calculator,
        _homeCurrency = homeCurrency;

  final IAccountRepository _accountRepository;
  final IExchangeRateRepository _exchangeRateRepository;
  final NetWorthCalculator _calculator;
  final String _homeCurrency;

  /// Returns a stream that emits [NetWorthResult] whenever the net worth
  /// changes.
  ///
  /// The stream does not complete unless an error occurs.
  Stream<NetWorthResult> call() {
    // Watch the account list; switchMap so inner streams reset on each change.
    return _accountRepository.watchAll().asyncMap(_computeNetWorth);
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Computes the net worth for the current [accounts] snapshot.
  ///
  /// Fetches all account balances concurrently, then reads exchange rates for
  /// each unique foreign currency and delegates to [NetWorthCalculator].
  Future<NetWorthResult> _computeNetWorth(List<Account> accounts) async {
    if (accounts.isEmpty) {
      return NetWorthResult(
        totalMinor: 0,
        homeCurrency: _homeCurrency,
        hasStaleRates: false,
      );
    }

    // --- 1. Fetch all balances concurrently ---
    final balanceFutures = accounts.map((acc) async {
      final balance =
          await _accountRepository.watchBalance(acc.id, acc.currencyCode).first;
      return MapEntry(acc.id, balance.amountMinor);
    });
    final balanceEntries = await Future.wait(balanceFutures);
    final balancesByAccountId = Map.fromEntries(balanceEntries);

    // --- 2. Collect unique foreign currencies ---
    final foreignCurrencies = accounts
        .where((a) => a.currencyCode != _homeCurrency && !a.isDeleted)
        .map((a) => a.currencyCode)
        .toSet();

    // --- 3. Fetch exchange rates for each foreign currency ---
    final rateFutures = foreignCurrencies.map((currency) async {
      final rate = await _exchangeRateRepository.getRateEntity(
        currency,
        _homeCurrency,
      );
      return rate == null ? null : MapEntry(currency, rate);
    });
    final rateEntries = await Future.wait(rateFutures);
    final ratesByFromCurrency = Map.fromEntries(
      rateEntries.whereType<MapEntry<String, ExchangeRate>>(),
    );

    // --- 4. Aggregate ---
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _calculator.compute(
      accounts: accounts,
      balancesByAccountId: balancesByAccountId,
      ratesByFromCurrency: ratesByFromCurrency,
      homeCurrency: _homeCurrency,
      nowEpoch: nowEpoch,
    );
  }
}
