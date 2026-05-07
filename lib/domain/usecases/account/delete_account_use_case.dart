// lib/domain/usecases/account/delete_account_use_case.dart
//
// Use case: soft-delete an account.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Soft-deletes the account identified by [id].
///
/// Protected accounts (EQ, BAI/BAE) return a BusinessRuleFailure.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  // ignore: unused_field
  final IAccountRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(String id) {
    throw UnimplementedError('DeleteAccountUseCase.call is not implemented');
  }
}
