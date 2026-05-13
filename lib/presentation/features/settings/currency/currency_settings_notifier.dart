// lib/presentation/features/settings/currency/currency_settings_notifier.dart
//
// CurrencySettingsNotifier — Riverpod AsyncNotifier for the Currency Settings
// screen (T-96, S-40).
//
// State includes:
//   - homeCurrency: the current app-level home currency code
//   - secondaryCurrencies: list of active-account currencies (excluding home)
//     joined with their latest exchange rate entity; isStale computed per entry
//
// Spec: UX Flows §9.10, API Contracts §2.5.4
//
// Test cases (see test/unit/.../currency_settings_notifier_test.dart):
//   1. loaded state — secondaryCurrencies populated from accounts + rates
//   2. stale secondary currency — isStale=true when rate > 14 days old
//   3. home currency change — calls ICurrencyRepository.setHomeCurrency
//   4. home currency = account currency — excluded from secondaryCurrencies

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/repositories/i_currency_repository.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'currency_settings_notifier.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// State of the Currency Settings screen.
///
/// [homeCurrency] is the currently configured home currency code.
/// [secondaryCurrencies] lists the active-account currencies excluding home,
/// each paired with the latest cached exchange rate (if any).
class CurrencySettingsState {
  /// Creates a [CurrencySettingsState].
  const CurrencySettingsState({
    required this.homeCurrency,
    required this.secondaryCurrencies,
  });

  /// The home currency ISO 4217 code.
  final String homeCurrency;

  /// Active-account currencies (excluding home) with rate metadata.
  final List<SecondaryCurrencyEntry> secondaryCurrencies;
}

/// A single entry in the secondary currencies list.
///
/// Pairs a [Currency] entity with the latest cached exchange rate (or null)
/// and the pre-computed [isStale] flag derived from [ExchangeRate.isStale].
class SecondaryCurrencyEntry {
  /// Creates a [SecondaryCurrencyEntry].
  const SecondaryCurrencyEntry({
    required this.currency,
    this.latestRate,
  });

  /// The currency entity (code, name, symbol, minorUnits).
  final Currency currency;

  /// Cached exchange rate for [currency] → home currency; null if not fetched.
  final ExchangeRate? latestRate;

  /// True when [latestRate] is older than the 14-day staleness threshold.
  bool get isStale => latestRate?.isStale ?? false;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Reactive notifier for the [CurrencySettingsState].
///
/// Rebuilds whenever the account list, app settings (home currency), or
/// exchange rate cache changes.
@riverpod
class CurrencySettingsNotifier extends _$CurrencySettingsNotifier {
  @override
  Future<CurrencySettingsState> build() async {
    final accountRepo = await ref.watch(accountRepositoryProvider.future);
    final currencyRepo = await ref.watch(currencyRepositoryProvider.future);
    final exchangeRateRepo =
        await ref.watch(exchangeRateRepositoryProvider.future);

    final settings = ref.watch(appSettingsProvider).value;
    final homeCurrency = settings?.homeCurrency ?? 'INR';

    // Completer bridges the account stream into the AsyncNotifier future.
    final completer = Completer<CurrencySettingsState>();

    StreamSubscription<List<Account>>? sub;
    sub = accountRepo.watchAll().listen(
      (accounts) async {
        final secondaryCurrencies = await _buildSecondaryEntries(
          accounts: accounts,
          homeCurrency: homeCurrency,
          currencyRepo: currencyRepo,
          exchangeRateRepo: exchangeRateRepo,
        );
        final newState = CurrencySettingsState(
          homeCurrency: homeCurrency,
          secondaryCurrencies: secondaryCurrencies,
        );
        if (!completer.isCompleted) {
          completer.complete(newState);
        } else if (ref.mounted) {
          state = AsyncData(newState);
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      },
    );

    ref.onDispose(() => sub?.cancel());
    return completer.future;
  }

  /// Changes the home currency by calling [ICurrencyRepository.setHomeCurrency].
  ///
  /// Throws [Exception] on repository failure so the UI can display the error.
  ///
  /// Parameters:
  /// - [code]: ISO 4217 currency code to set as the new home currency.
  Future<void> changeHomeCurrency(String code) async {
    final currencyRepo = await ref.read(currencyRepositoryProvider.future);
    final result = await currencyRepo.setHomeCurrency(code);
    switch (result) {
      case Ok():
        break;
      case Err(:final failure):
        throw Exception('Failed to change home currency: ${failure.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Builds the secondary currency list from active-account currencies.
  ///
  /// Excludes the home currency and looks up the latest rate for each.
  Future<List<SecondaryCurrencyEntry>> _buildSecondaryEntries({
    required List<Account> accounts,
    required String homeCurrency,
    required ICurrencyRepository currencyRepo,
    required IExchangeRateRepository exchangeRateRepo,
  }) async {
    // Collect unique currency codes from active (non-deleted) accounts,
    // excluding the home currency.
    final distinctCodes = accounts
        .where((a) => !a.isDeleted && a.currencyCode != homeCurrency)
        .map((a) => a.currencyCode)
        .toSet();

    if (distinctCodes.isEmpty) return const [];

    // Fetch the full currency list once to resolve Currency entities.
    final allCurrencies = await currencyRepo.watchAll().first;
    final currencyByCode = {for (final c in allCurrencies) c.code: c};

    final entries = <SecondaryCurrencyEntry>[];
    for (final code in distinctCodes) {
      final currency = currencyByCode[code];
      if (currency == null) continue;

      // Look up the cached exchange rate for this code → home currency pair.
      final rate = await exchangeRateRepo.getRateEntity(code, homeCurrency);
      entries.add(SecondaryCurrencyEntry(currency: currency, latestRate: rate));
    }

    // Sort alphabetically by code for deterministic ordering.
    entries.sort((a, b) => a.currency.code.compareTo(b.currency.code));
    return entries;
  }
}
