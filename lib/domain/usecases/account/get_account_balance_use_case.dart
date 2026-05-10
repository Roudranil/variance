// lib/domain/usecases/account/get_account_balance_use_case.dart
//
// Use case: watch the live balance of an account.
//
// Delegates to IAccountRepository.watchBalance which aggregates entries from
// the database. The result is expressed as a Money value object.

import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Returns a reactive stream of the computed balance for account [id],
/// denominated in [currencyCode].
///
/// Balance = Σ debit entries − Σ credit entries (minor units).
class GetAccountBalanceUseCase {
  /// Creates a [GetAccountBalanceUseCase].
  ///
  /// Parameters:
  /// - [repository]: Account data access interface.
  const GetAccountBalanceUseCase(this._repository);

  final IAccountRepository _repository;

  /// Returns a stream that emits the current balance whenever entries change.
  ///
  /// Parameters:
  /// - [id]: UUID of the account to watch.
  /// - [currencyCode]: ISO 4217 code for the returned [Money] value.
  Stream<Money> call(String id, String currencyCode) =>
      _repository.watchBalance(id, currencyCode);
}
