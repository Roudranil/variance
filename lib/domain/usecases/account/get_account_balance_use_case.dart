// lib/domain/usecases/account/get_account_balance_use_case.dart
//
// Use case: watch the live balance of an account.

import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Returns a reactive stream of the computed balance for account [id],
/// denominated in [currencyCode].
class GetAccountBalanceUseCase {
  const GetAccountBalanceUseCase(this._repository);

  // ignore: unused_field
  final IAccountRepository _repository;

  /// Executes the use case.
  Stream<Money> call(String id, String currencyCode) {
    throw UnimplementedError(
      'GetAccountBalanceUseCase.call is not implemented',
    );
  }
}
