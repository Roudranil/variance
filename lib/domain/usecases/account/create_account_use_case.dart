// lib/domain/usecases/account/create_account_use_case.dart
//
// Use case: create a new financial account.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Creates a new account and persists it.
class CreateAccountUseCase {
  const CreateAccountUseCase(this._repository);

  // ignore: unused_field
  final IAccountRepository _repository;

  /// Executes the use case.
  Future<Result<Account>> call(Account account) {
    throw UnimplementedError('CreateAccountUseCase.call is not implemented');
  }
}
