// lib/presentation/providers/repository_providers.dart
//
// Riverpod providers for all concrete repository implementations.
//
// Provider tree (all keepAlive — constructed once, never disposed):
//   transactionRepositoryProvider  ← transactionDaoProvider
//   accountRepositoryProvider      ← accountDaoProvider
//   categoryRepositoryProvider     ← categoryDaoProvider
//   recurringTemplateRepositoryProvider ← templateDaoProvider
//   exchangeRateRepositoryProvider ← exchangeRateDaoProvider
//   currencyRepositoryProvider     ← currencyDaoProvider
//   currenciesProvider             ← currencyRepositoryProvider (keepAlive list cache)
//
// Rules (SDS §2.2.3, §2.2.4):
//   - All providers use @riverpod annotation; raw Provider(...) is forbidden.
//   - keepAlive: true — repositories are global singletons.
//   - Dependencies injected via ref.watch, not constructed internally.
//
// Test cases (see test/providers/repository_providers_test.dart):
//   - Each provider resolves without error when appDatabaseProvider is overridden
//     with an in-memory AppDatabase.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/data/repositories/account_repository_impl.dart';
import 'package:variance/data/repositories/app_settings_repository_impl.dart';
import 'package:variance/data/repositories/category_repository_impl.dart';
import 'package:variance/data/repositories/currency_repository_impl.dart';
import 'package:variance/data/repositories/exchange_rate_repository_impl.dart';
import 'package:variance/data/repositories/recurring_template_repository_impl.dart';
import 'package:variance/data/repositories/transaction_repository_impl.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/repositories/i_currency_repository.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/presentation/providers/database_providers.dart';

part 'repository_providers.g.dart';

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

/// Provides the [ITransactionRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [transactionDaoProvider].
@Riverpod(keepAlive: true)
Future<ITransactionRepository> transactionRepository(Ref ref) async {
  final dao = await ref.watch(transactionDaoProvider.future);
  return TransactionRepositoryImpl(dao);
}

/// Provides the [IAccountRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [accountDaoProvider].
@Riverpod(keepAlive: true)
Future<IAccountRepository> accountRepository(Ref ref) async {
  final dao = await ref.watch(accountDaoProvider.future);
  return AccountRepositoryImpl(dao);
}

/// Provides the [ICategoryRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [categoryDaoProvider].
@Riverpod(keepAlive: true)
Future<ICategoryRepository> categoryRepository(Ref ref) async {
  final dao = await ref.watch(categoryDaoProvider.future);
  return CategoryRepositoryImpl(dao);
}

/// Provides the [IRecurringTemplateRepository] implementation for the lifetime
/// of the app.
///
/// Depends on [templateDaoProvider].
@Riverpod(keepAlive: true)
Future<IRecurringTemplateRepository> recurringTemplateRepository(
  Ref ref,
) async {
  final dao = await ref.watch(templateDaoProvider.future);
  return RecurringTemplateRepositoryImpl(dao);
}

/// Provides the [IExchangeRateRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [exchangeRateDaoProvider].
@Riverpod(keepAlive: true)
Future<IExchangeRateRepository> exchangeRateRepository(Ref ref) async {
  final dao = await ref.watch(exchangeRateDaoProvider.future);
  return ExchangeRateRepositoryImpl(dao);
}

/// Provides the [ICurrencyRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [currencyDaoProvider].
@Riverpod(keepAlive: true)
Future<ICurrencyRepository> currencyRepository(Ref ref) async {
  final dao = await ref.watch(currencyDaoProvider.future);
  return CurrencyRepositoryImpl(dao);
}

/// Provides the [IAppSettingsRepository] implementation for the lifetime of
/// the app.
///
/// Backed by [AppSettingsDao]. Used by the GoRouter redirect guard, the
/// AppSettingsNotifier, and the theme provider.
@Riverpod(keepAlive: true)
Future<IAppSettingsRepository> appSettingsRepository(Ref ref) async {
  final dao = await ref.watch(appSettingsDaoProvider.future);
  return AppSettingsRepositoryImpl(dao);
}

// ---------------------------------------------------------------------------
// Currency list cache (T-23)
// ---------------------------------------------------------------------------

/// Loads all active [Currency] entities from the local database once on app
/// startup and keeps the result alive for the entire session.
///
/// The currency list is populated from the bundled `assets/data/currencies.json`
/// asset during the Drift `onCreate` migration (T-22). No runtime network
/// fetch is ever performed (SDS §2.16.1).
///
/// Consumers should prefer this provider over calling the repository directly
/// to avoid repeated DAO round-trips for a static list.
@Riverpod(keepAlive: true)
Future<List<Currency>> currencies(Ref ref) async {
  final repo = await ref.watch(currencyRepositoryProvider.future);
  // watchAll() returns a Stream from the Drift DAO. We take the first
  // emission to get the full list; keepAlive ensures this runs only once.
  return repo.watchAll().first;
}
