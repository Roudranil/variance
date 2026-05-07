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

import 'package:variance/domain/usecases/account/create_account_use_case.dart';
import 'package:variance/domain/usecases/account/delete_account_use_case.dart';
import 'package:variance/domain/usecases/account/get_account_balance_use_case.dart';
import 'package:variance/domain/usecases/account/update_account_use_case.dart';
import 'package:variance/domain/usecases/account/watch_accounts_use_case.dart';
import 'package:variance/domain/usecases/category/create_category_use_case.dart';
import 'package:variance/domain/usecases/category/delete_category_use_case.dart';
import 'package:variance/domain/usecases/category/update_category_use_case.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart';
import 'package:variance/domain/usecases/transaction/create_transaction_use_case.dart';
import 'package:variance/domain/usecases/transaction/search_transactions_use_case.dart';
import 'package:variance/domain/usecases/transaction/watch_monthly_transactions_use_case.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'use_case_providers.g.dart';

// ---------------------------------------------------------------------------
// Transaction use cases
// ---------------------------------------------------------------------------

/// Provides a [CreateTransactionUseCase] bound to the transaction repository.
@riverpod
Future<CreateTransactionUseCase> createTransactionUseCase(Ref ref) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return CreateTransactionUseCase(repo);
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

/// Provides a [CreateAccountUseCase] bound to the account repository.
@riverpod
Future<CreateAccountUseCase> createAccountUseCase(Ref ref) async {
  final repo = await ref.watch(accountRepositoryProvider.future);
  return CreateAccountUseCase(repo);
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
// Currency / exchange rate use cases
// ---------------------------------------------------------------------------

/// Provides a [GetExchangeRateUseCase] bound to the exchange rate repository.
@riverpod
Future<GetExchangeRateUseCase> getExchangeRateUseCase(Ref ref) async {
  final repo = await ref.watch(exchangeRateRepositoryProvider.future);
  return GetExchangeRateUseCase(repo);
}

/// Provides a [RefreshExchangeRatesUseCase] bound to the exchange rate
/// repository.
@riverpod
Future<RefreshExchangeRatesUseCase> refreshExchangeRatesUseCase(Ref ref) async {
  final repo = await ref.watch(exchangeRateRepositoryProvider.future);
  return RefreshExchangeRatesUseCase(repo);
}
