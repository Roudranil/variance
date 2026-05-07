// lib/domain/usecases/account/update_account_use_case.dart
//
// Use case: update an existing account's mutable fields.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Updates mutable fields of an existing account.
class UpdateAccountUseCase {
  const UpdateAccountUseCase(this._repository);

  // ignore: unused_field
  final IAccountRepository _repository;

  /// Executes the use case.
  Future<Result<Account>> call(Account account) {
    throw UnimplementedError('UpdateAccountUseCase.call is not implemented');
  }
}
