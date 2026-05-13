// lib/presentation/providers/use_case_providers.dart
//
// Riverpod providers for all use case instances.
//
// Use case providers are auto-dispose by default (no keepAlive) — they are
// inexpensive value objects that hold only a repository reference. The
// repository they hold is keepAlive, so the repository itself is not released.
//
// Rules (SDS §2.2.3, §2.2.4):
//   - All providers use @riverpod annotation; raw Provider(...) is forbidden.
//   - Use cases receive repositories via constructor injection from providers.
//   - No keepAlive — use cases are lightweight; auto-dispose is appropriate.
//
// Grouped by domain aggregate for discoverability.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/data/repositories/drift_ledger_repository.dart';
import 'package:variance/data/repositories/exchange_rate_repository_impl.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/account/create_account_use_case.dart';
import 'package:variance/domain/usecases/account/delete_account_use_case.dart';
import 'package:variance/domain/usecases/account/get_account_balance_use_case.dart';
import 'package:variance/domain/usecases/account/update_account_use_case.dart';
import 'package:variance/domain/usecases/account/watch_accounts_use_case.dart';
import 'package:variance/domain/usecases/category/create_category_use_case.dart';
import 'package:variance/domain/usecases/category/delete_category_use_case.dart';
import 'package:variance/domain/usecases/category/update_category_use_case.dart';
import 'package:variance/domain/usecases/recurring/create_recurring_template_use_case.dart';
import 'package:variance/domain/usecases/recurring/skip_occurrence_use_case.dart';
import 'package:variance/domain/usecases/recurring/update_recurring_template_use_case.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart';
import 'package:variance/domain/usecases/transaction/create_transaction_use_case.dart';
import 'package:variance/domain/usecases/transaction/search_transactions_use_case.dart';
import 'package:variance/domain/usecases/transaction/watch_monthly_transactions_use_case.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_service.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/database_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'use_case_providers.g.dart';

// ---------------------------------------------------------------------------
// Transaction use cases
// ---------------------------------------------------------------------------

/// Provides a [CreateTransactionUseCase] bound to the transaction repository
/// and [LedgerEngine] (T-49, T-50).
@riverpod
Future<CreateTransactionUseCase> createTransactionUseCase(Ref ref) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  final engine = await ref.watch(ledgerEngineProvider.future);
  return CreateTransactionUseCase(repo, engine);
}

/// Provides a [WatchMonthlyTransactionsUseCase] bound to the transaction
/// repository.
@riverpod
Future<WatchMonthlyTransactionsUseCase> watchMonthlyTransactionsUseCase(
  Ref ref,
) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return WatchMonthlyTransactionsUseCase(repo);
}

/// Provides a [SearchTransactionsUseCase] bound to the transaction repository.
@riverpod
Future<SearchTransactionsUseCase> searchTransactionsUseCase(Ref ref) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return SearchTransactionsUseCase(repo);
}

// ---------------------------------------------------------------------------
// Account use cases
// ---------------------------------------------------------------------------

/// Provides a [WatchAccountsUseCase] bound to the account repository.
@riverpod
Future<WatchAccountsUseCase> watchAccountsUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  return WatchAccountsUseCase(repo);
}

/// Provides a [LedgerEngine] wired to the Drift-backed ledger repository.
///
/// The ledger repository requires both [AccountDao] and [TransactionDao]
/// to handle EQ account creation and entry inserts.
@riverpod
Future<LedgerEngine> ledgerEngine(Ref ref) async {
  final accountDao = await ref.watch(accountDaoProvider.future);
  final txDao = await ref.watch(transactionDaoProvider.future);
  final db = await ref.watch(appDatabaseProvider.future);
  final ledgerRepo = DriftLedgerRepository(
    accountDao: accountDao,
    transactionDao: txDao,
    database: db,
  );
  return LedgerEngine(ledgerRepo);
}

/// Provides a [CreateAccountUseCase] bound to the account repository and
/// [LedgerEngine].
@riverpod
Future<CreateAccountUseCase> createAccountUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  final engine = await ref.watch(ledgerEngineProvider.future);
  return CreateAccountUseCase(repo, engine);
}

/// Provides an [UpdateAccountUseCase] bound to the account repository.
@riverpod
Future<UpdateAccountUseCase> updateAccountUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  return UpdateAccountUseCase(repo);
}

/// Provides a [DeleteAccountUseCase] bound to the account repository.
@riverpod
Future<DeleteAccountUseCase> deleteAccountUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  return DeleteAccountUseCase(repo);
}

/// Provides a [GetAccountBalanceUseCase] bound to the account repository.
@riverpod
Future<GetAccountBalanceUseCase> getAccountBalanceUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  return GetAccountBalanceUseCase(repo);
}

// ---------------------------------------------------------------------------
// Category use cases
// ---------------------------------------------------------------------------

/// Provides a [CreateCategoryUseCase] bound to the category repository.
@riverpod
Future<CreateCategoryUseCase> createCategoryUseCase(Ref ref) async {
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return CreateCategoryUseCase(repo);
}

/// Provides an [UpdateCategoryUseCase] bound to the category repository.
@riverpod
Future<UpdateCategoryUseCase> updateCategoryUseCase(Ref ref) async {
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return UpdateCategoryUseCase(repo);
}

/// Provides a [DeleteCategoryUseCase] bound to the category repository.
@riverpod
Future<DeleteCategoryUseCase> deleteCategoryUseCase(Ref ref) async {
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return DeleteCategoryUseCase(repo);
}

// ---------------------------------------------------------------------------
// Recurring template use cases (T-106, T-110, T-112)
// ---------------------------------------------------------------------------

/// Provides a [CreateRecurringTemplateUseCase] bound to the template
/// repository.
@riverpod
Future<CreateRecurringTemplateUseCase> createRecurringTemplateUseCase(
  Ref ref,
) async {
  final repo = await ref.watch(recurringTemplateRepositoryProvider.future);
  return CreateRecurringTemplateUseCase(repo);
}

/// Provides an [UpdateRecurringTemplateUseCase] bound to the template
/// repository.
@riverpod
Future<UpdateRecurringTemplateUseCase> updateRecurringTemplateUseCase(
  Ref ref,
) async {
  final repo = await ref.watch(recurringTemplateRepositoryProvider.future);
  return UpdateRecurringTemplateUseCase(repo);
}

/// Provides a [SkipOccurrenceUseCase] bound to the scheduled occurrence
/// repository.
@riverpod
Future<SkipOccurrenceUseCase> skipOccurrenceUseCase(Ref ref) async {
  final repo = await ref.watch(scheduledOccurrenceRepositoryProvider.future);
  return SkipOccurrenceUseCase(repo);
}

// ---------------------------------------------------------------------------
// Currency / exchange rate use cases
// ---------------------------------------------------------------------------

/// Provides a [GetExchangeRateUseCase] bound to the exchange rate repository.
@riverpod
Future<GetExchangeRateUseCase> getExchangeRateUseCase(Ref ref) async {
  final repo = await ref.watch(exchangeRateRepositoryProvider.future);
  return GetExchangeRateUseCase(repo);
}

/// Provides a [RefreshExchangeRatesUseCase] wired with account repository,
/// exchange rate upsert sink, HTTP service, and home currency from settings.
@riverpod
Future<RefreshExchangeRatesUseCase> refreshExchangeRatesUseCase(Ref ref) async {
  final accountRepo = await ref.watch(accountRepositoryProvider.future);
  final exchangeRateRepo =
      await ref.watch(exchangeRateRepositoryProvider.future);
  final settings = ref.watch(appSettingsProvider).value;
  final homeCurrency = settings?.homeCurrency ?? 'INR';

  // ExchangeRateRepositoryImpl implements IRateUpsertSink; cast is safe.
  final upsertSink = exchangeRateRepo as ExchangeRateRepositoryImpl;

  return RefreshExchangeRatesUseCase(
    accountRepository: accountRepo,
    rateUpsertSink: upsertSink,
    exchangeRateService: ExchangeRateService(),
    homeCurrency: homeCurrency,
  );
}
