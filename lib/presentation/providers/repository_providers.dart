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
/// This provider reads from the AppDatabase directly (no dedicated DAO).
/// Used by the GoRouter redirect guard to check onboarding completion.
@Riverpod(keepAlive: true)
Future<IAppSettingsRepository> appSettingsRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return AppSettingsRepositoryImpl(db);
}
