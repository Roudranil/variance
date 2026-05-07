// lib/domain/usecases/account/watch_accounts_use_case.dart
//
// Use case: watch the live list of accounts.

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Returns a reactive stream of all non-system, non-deleted accounts.
class WatchAccountsUseCase {
  const WatchAccountsUseCase(this._repository);

  // ignore: unused_field
  final IAccountRepository _repository;

  /// Executes the use case.
  Stream<List<Account>> call() {
    throw UnimplementedError('WatchAccountsUseCase.call is not implemented');
  }
}
