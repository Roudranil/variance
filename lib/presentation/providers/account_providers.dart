// lib/presentation/providers/account_providers.dart
//
// Riverpod stream providers for account-related reactive data.
//
// Provider graph:
//   accountsProvider              ← accountRepositoryProvider (via use case)
//   accountBalanceProvider        ← accountRepositoryProvider
//   netWorthProvider              ← accountRepositoryProvider, exchangeRateRepositoryProvider,
//                                   appSettingsProvider (home currency)
//   currencySymbolLabelsProvider  ← accountsProvider, currenciesProvider
//                                   (CURR-02 symbol disambiguation, T-91)
//
// Rules (SDS §2.2.3, §2.2.4):
//   - All providers use @riverpod annotation.
//   - accountsProvider uses keepAlive: false (auto-dispose) — consumed by list
//     screens that have their own lifecycle.
//   - accountBalanceProvider is parameterised; each (accountId) tuple is
//     auto-disposed when no longer watched.
//   - netWorthProvider auto-disposes with the accounts screen.
//
// Test cases (see test/providers/account_providers_test.dart):
//   1. accountsProvider emits list of accounts from in-memory DB
//   2. accountBalanceProvider emits 0 for a new account
//   3. netWorthProvider emits zero result when no accounts exist

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/currency/currency_symbol_resolver.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';
import 'package:variance/domain/usecases/home/watch_net_worth_use_case.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'account_providers.g.dart';

// ---------------------------------------------------------------------------
// accountsProvider
// ---------------------------------------------------------------------------

/// Reactive stream of all non-system, non-deleted accounts.
///
/// Emits a new list whenever the underlying accounts table changes.
/// Consumers should prefer this provider over calling the repository directly.
@riverpod
Stream<List<Account>> accounts(Ref ref) async* {
  final repo = await ref.watch(accountRepositoryProvider.future);
  yield* repo.watchAll();
}

// ---------------------------------------------------------------------------
// accountBalanceProvider
// ---------------------------------------------------------------------------

/// Reactive stream of the computed balance for account [accountId].
///
/// The balance is expressed in the account's own currency (minor units).
/// Emits a new value whenever the underlying entries change.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.
/// - [currencyCode]: ISO 4217 code used to denominate the balance stream.
@riverpod
Stream<int> accountBalance(
  Ref ref,
  String accountId,
  String currencyCode,
) async* {
  final repo = await ref.watch(accountRepositoryProvider.future);
  yield* repo.watchBalance(accountId, currencyCode).map((m) => m.amountMinor);
}

// ---------------------------------------------------------------------------
// netWorthProvider
// ---------------------------------------------------------------------------

/// Reactive stream of the aggregate net worth in the home currency.
///
/// Emits a [NetWorthResult] whenever the account list or any account balance
/// changes. The staleness flag in [NetWorthResult.hasStaleRates] drives the
/// "Rate may be outdated" indicator in the UI.
@riverpod
Stream<NetWorthResult> netWorth(Ref ref) async* {
  final accountRepo = await ref.watch(accountRepositoryProvider.future);
  final exchangeRateRepo =
      await ref.watch(exchangeRateRepositoryProvider.future);

  // Read home currency from app settings; fall back to 'INR' while loading.
  final settings = ref.watch(appSettingsProvider).value;
  final homeCurrency = settings?.homeCurrency ?? 'INR';

  const calculator = NetWorthCalculator();

  final useCase = WatchNetWorthUseCase(
    accountRepository: accountRepo,
    exchangeRateRepository: exchangeRateRepo,
    calculator: calculator,
    homeCurrency: homeCurrency,
  );

  yield* useCase.call();
}

// ---------------------------------------------------------------------------
// activeAccountsProvider (T-106)
// ---------------------------------------------------------------------------

/// Async snapshot of all non-deleted, non-system accounts.
///
/// Thin convenience provider over [accountsProvider] for use in form screens
/// that need a one-time or auto-refreshed list of accounts to populate
/// dropdowns.
@riverpod
Stream<List<Account>> activeAccounts(Ref ref) async* {
  final repo = await ref.watch(accountRepositoryProvider.future);
  yield* repo
      .watchAll()
      .map((list) => list.where((a) => !a.isDeleted).toList());
}

// ---------------------------------------------------------------------------
// accountByIdProvider (T-41)
// ---------------------------------------------------------------------------

/// Watches a single account by [accountId].
///
/// Emits null if the account does not exist or has been soft-deleted.
/// Used by [AccountDetailScreen] and anywhere a single-account stream
/// is needed outside the list view.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.
@riverpod
Stream<Account?> accountById(Ref ref, String accountId) async* {
  final repo = await ref.watch(accountRepositoryProvider.future);
  yield* repo.watchById(accountId);
}

// ---------------------------------------------------------------------------
// currencySymbolLabelsProvider (CURR-02, T-91)
// ---------------------------------------------------------------------------

/// Derives display labels for all active-account currencies.
///
/// Uses [CurrencySymbolResolver] to detect symbol collisions among the
/// currencies that actually appear on active accounts. When two or more
/// accounts share a currency symbol (e.g. '$' for USD and CAD), each
/// conflicting currency gets an ISO-code suffix: '$USD', '$CAD'.
///
/// Returns a [Map] of currency code → display label. Consumers should read
/// this map and look up the account's [Account.currencyCode] to get the
/// correct label to show in the row.
///
/// Depends on [accountsProvider] (reactive) and [currenciesProvider]
/// (keepAlive static list from seed data).
@riverpod
Stream<Map<String, String>> currencySymbolLabels(Ref ref) async* {
  // Re-emit whenever the account list changes (new accounts → new currencies).
  final accountsAsync = ref.watch(accountsProvider);
  final allCurrencies = await ref.watch(currenciesProvider.future);

  // Build a lookup for fast code → Currency access.
  final currencyByCode = <String, Currency>{
    for (final c in allCurrencies) c.code: c,
  };

  final accounts = accountsAsync.value ?? [];

  // Collect distinct currency codes used by active (non-deleted) accounts.
  final activeCodes =
      accounts.where((a) => !a.isDeleted).map((a) => a.currencyCode).toSet();

  final activeCurrencies = activeCodes
      .where(currencyByCode.containsKey)
      .map((code) => currencyByCode[code]!)
      .toList();

  const resolver = CurrencySymbolResolver();
  yield resolver.resolve(activeCurrencies);
}
