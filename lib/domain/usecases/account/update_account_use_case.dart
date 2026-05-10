// lib/domain/usecases/account/update_account_use_case.dart
//
// Use case: update mutable fields of an existing account.
//
// Business rules enforced here:
//   1. account_category is immutable after creation — rejects changes.
//   2. currency_code is immutable after creation — rejects changes.
//   3. Name uniqueness is re-checked if the name changed.
//   4. Only editable fields are accepted: name, notes, include_in_net_worth,
//      display_order.
//
// The caller must pass the account with the desired new values.
// The updated_at timestamp is set by the repository layer.
//
// Test cases (see test/unit/domain/usecases/update_account_use_case_test.dart):
//   1. valid edit of name → Ok(Account) with new name
//   2. empty name → Err(ValidationFailure)
//   3. name changed to an existing active name → Err(ValidationFailure)
//   4. category changed → Err(ValidationFailure)
//   5. currency_code changed → Err(ValidationFailure)
//   6. account not found → Err(NotFoundFailure)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Updates mutable fields of an existing account.
///
/// Immutable fields (account_category, currency_code) are validated against the
/// persisted values to reject unauthorised changes at the domain layer.
class UpdateAccountUseCase {
  /// Creates an [UpdateAccountUseCase].
  ///
  /// Parameters:
  /// - [repository]: Account data access interface.
  const UpdateAccountUseCase(this._repository);

  final IAccountRepository _repository;

  /// Validates and persists edits to [account].
  ///
  /// The [account] object must carry the desired new values; the [account.id]
  /// is used to load the current persisted state for immutability checks.
  ///
  /// Returns [Ok] wrapping the updated [Account] on success.
  /// Returns [Err] wrapping a [Failure] on validation or persistence error.
  ///
  /// Parameters:
  /// - [account]: Updated account entity.
  Future<Result<Account>> call(Account account) async {
    // --- Load current state to enforce immutability ---
    final current = await _loadCurrent(account.id);
    if (current == null) {
      return Err(
        NotFoundFailure('Account ${account.id} not found.'),
      );
    }

    // --- Immutability guards ---
    if (account.accountCategory != current.accountCategory) {
      return const Err(
        ValidationFailure('Account category cannot be changed after creation.'),
      );
    }
    if (account.currencyCode != current.currencyCode) {
      return const Err(
        ValidationFailure('Currency code cannot be changed after creation.'),
      );
    }

    // --- Name validation ---
    if (account.name.trim().isEmpty) {
      return const Err(ValidationFailure('Account name must not be empty.'));
    }

    // --- Name uniqueness (only when name changed) ---
    if (account.name != current.name) {
      final taken = await _repository.isNameTaken(account.name);
      if (taken) {
        return Err(
          ValidationFailure(
            'An account named "${account.name}" already exists.',
          ),
        );
      }
    }

    return _repository.update(account);
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Returns the currently persisted account for [id], using a single emission
  /// of the watch stream.
  Future<Account?> _loadCurrent(String id) async {
    return _repository.watchById(id).first;
  }
}
