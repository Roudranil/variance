// lib/domain/usecases/account/delete_account_use_case.dart
//
// Use case: soft-delete an account.
//
// Business rules enforced here:
//   1. Protected accounts (EQ, BAI/BAE — is_protected = true) cannot be
//      deleted; returns BusinessRuleFailure.
//   2. The last remaining active account cannot be deleted; at least one must
//      always exist → LastAccountFailure.
//   3. Sets is_deleted = true, deleted_at = now.
//
// Test cases (see test/unit/domain/usecases/delete_account_use_case_test.dart):
//   1. non-protected account with siblings → Ok(void)
//   2. protected account → Err(BusinessRuleFailure)
//   3. last active account → Err(LastAccountFailure)
//   4. non-existent id → Err(NotFoundFailure)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Soft-deletes the account identified by [id].
///
/// Protected accounts (EQ and system accounts) and the last remaining account
/// are guarded against deletion.
class DeleteAccountUseCase {
  /// Creates a [DeleteAccountUseCase].
  ///
  /// Parameters:
  /// - [repository]: Account data access interface.
  const DeleteAccountUseCase(this._repository);

  final IAccountRepository _repository;

  /// Soft-deletes the account with [id].
  ///
  /// Returns [Ok] wrapping void on success.
  /// Returns [Err] wrapping a typed [Failure] when a guard rail is violated.
  ///
  /// Parameters:
  /// - [id]: UUID of the account to delete.
  Future<Result<void>> call(String id) async {
    // --- Load current state ---
    final account = await _repository.watchById(id).first;
    if (account == null) {
      return Err(NotFoundFailure('Account $id not found.'));
    }

    // --- Protected-account guard ---
    if (account.isProtected) {
      return const Err(
        BusinessRuleFailure(
          'This account is protected and cannot be deleted.',
        ),
      );
    }

    // --- Last-account guard ---
    // Watch the full list and check count on first emission.
    final allAccounts = await _repository.watchAll().first;
    if (allAccounts.length <= 1) {
      return const Err(
        LastAccountFailure(
          'Cannot delete the last account. At least one account must remain.',
        ),
      );
    }

    return _repository.softDelete(id);
  }
}
