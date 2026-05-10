// lib/presentation/providers/account_providers.dart
//
// Riverpod stream providers for account-related reactive data.
//
// Provider graph:
//   accountsProvider          ← accountRepositoryProvider (via use case)
//   accountBalanceProvider    ← accountRepositoryProvider
//
// Rules (SDS §2.2.3, §2.2.4):
//   - All providers use @riverpod annotation.
//   - accountsProvider uses keepAlive: false (auto-dispose) — consumed by list
//     screens that have their own lifecycle.
//   - accountBalanceProvider is parameterised; each (accountId) tuple is
//     auto-disposed when no longer watched.
//
// Test cases (see test/providers/account_providers_test.dart):
//   1. accountsProvider emits list of accounts from in-memory DB
//   2. accountBalanceProvider emits 0 for a new account

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/account.dart';
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
