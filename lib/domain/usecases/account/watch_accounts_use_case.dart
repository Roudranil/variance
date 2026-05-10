// lib/domain/usecases/account/watch_accounts_use_case.dart
//
// Use case: watch the live list of accounts.
//
// Filters out system accounts (EQ) which are never shown in user-facing views.
// The underlying repository already excludes soft-deleted and system accounts
// via the DAO's watchVisibleAccounts query.

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Returns a reactive stream of all non-system, non-deleted accounts.
///
/// System accounts (EQ — [Account.isSystem] = true) are excluded by the
/// repository layer and never surface to callers of this use case.
class WatchAccountsUseCase {
  /// Creates a [WatchAccountsUseCase].
  ///
  /// Parameters:
  /// - [repository]: Account data access interface.
  const WatchAccountsUseCase(this._repository);

  final IAccountRepository _repository;

  /// Returns a stream that emits the full list of visible accounts whenever
  /// the underlying data changes.
  Stream<List<Account>> call() => _repository.watchAll();
}
