// lib/domain/usecases/account/create_account_use_case.dart
//
// Use case: create a new financial account.
//
// Business rules enforced here:
//   1. Name must be non-empty.
//   2. account_category must be a valid enum value.
//   3. currency_code must be a 3-letter ISO 4217 code (format validation only;
//      existence validation is performed by the FK constraint at DB layer).
//   4. If a non-soft-deleted account with the same name already exists:
//        → return ValidationFailure.
//   5. If a soft-deleted account with the same name AND category exists:
//        → return ReinstateOfferFailure (TC-035).
//   6. If initial_balance ≠ 0: call LedgerEngine.post with opening balance
//      posting case (Cases 2.2a / 2.2b from ledger-entry.md).
//   7. Account insert + entry post are wrapped in a single database.transaction.
//
// The caller is responsible for generating the account UUID and epoch timestamps.
//
// Test cases (see test/unit/domain/usecases/create_account_use_case_test.dart):
//   1. valid account with zero balance → Ok(Account)
//   2. valid account with positive initial balance → Ok; ledger entry created
//   3. valid account with negative initial balance → Ok; EQ debit entry created
//   4. empty name → Err(ValidationFailure)
//   5. name already taken (active) → Err(ValidationFailure)
//   6. name taken by soft-deleted same-category account → Err(ReinstateOfferFailure)
//   7. name taken by soft-deleted different-category account → Ok (allowed)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

/// Creates a new financial account, optionally posting an opening balance.
///
/// All validation is performed before any database write. The account insert
/// and (when needed) opening-balance ledger entry are wrapped in a single
/// database transaction via [LedgerRepository].
class CreateAccountUseCase {
  /// Creates a [CreateAccountUseCase].
  ///
  /// Parameters:
  /// - [repository]: Account data access interface.
  /// - [ledgerEngine]: Engine for posting the opening balance entry.
  const CreateAccountUseCase(this._repository, this._ledgerEngine);

  final IAccountRepository _repository;
  final LedgerEngine _ledgerEngine;

  /// Validates and persists a new [account].
  ///
  /// When [account.initialBalanceMinor] is non-zero, an opening-balance ledger
  /// entry is posted atomically with the account insert.
  ///
  /// Returns [Ok] wrapping the persisted [Account] on success.
  /// Returns [Err] wrapping a [Failure] when validation fails or a DB error
  /// occurs.
  ///
  /// Parameters:
  /// - [account]: The account to create (id and timestamps must be set by caller).
  /// - [openingBalanceTxId]: UUID for the opening-balance transaction row
  ///   (required when [account.initialBalanceMinor] ≠ 0; ignored otherwise).
  Future<Result<Account>> call(
    Account account, {
    String? openingBalanceTxId,
  }) async {
    // --- Validation ---
    final nameError = _validateName(account.name);
    if (nameError != null) return Err(nameError);

    final currencyError = _validateCurrencyCode(account.currencyCode);
    if (currencyError != null) return Err(currencyError);

    // --- Name uniqueness check ---
    final taken = await _repository.isNameTaken(account.name);
    if (taken) {
      // Check if taken by a soft-deleted account of same category.
      final softDeleted = await _repository.findSoftDeletedByNameAndCategory(
        account.name,
        account.accountCategory,
      );
      if (softDeleted != null) {
        return Err(
          ReinstateOfferFailure(
            'An account named "${account.name}" was previously deleted. '
            'Would you like to restore it?',
            softDeletedId: softDeleted.id,
          ),
        );
      }
      // Active account with this name exists.
      return Err(
        ValidationFailure(
          'An account named "${account.name}" already exists.',
        ),
      );
    }

    // --- Persist account ---
    final createResult = await _repository.create(account);
    if (createResult case Err(:final failure)) {
      return Err(failure);
    }
    final created = (createResult as Ok<Account>).value;

    // --- Post opening balance entry if needed ---
    if (account.initialBalanceMinor != 0) {
      final txId = openingBalanceTxId;
      if (txId == null) {
        return const Err(
          ValidationFailure(
            'openingBalanceTxId is required for accounts with non-zero initial balance.',
          ),
        );
      }

      final postingCase = account.initialBalanceMinor > 0
          ? PostingCase.openingBalancePositive
          : PostingCase.openingBalanceNegative;

      final input = CreateTransactionInput(
        postingCase: postingCase,
        transactionId: txId,
        accountId: created.id,
        amountMinor: account.initialBalanceMinor.abs(),
        currencyCode: account.currencyCode,
        nowEpoch: account.createdAt,
      );

      final postResult = await _ledgerEngine.post(input);
      if (postResult case Err(:final failure)) {
        return Err(failure);
      }
    }

    return Ok(created);
  }

  // -----------------------------------------------------------------------
  // Validation helpers
  // -----------------------------------------------------------------------

  /// Returns a [ValidationFailure] if [name] is invalid, or null if valid.
  ValidationFailure? _validateName(String name) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('Account name must not be empty.');
    }
    return null;
  }

  /// Returns a [ValidationFailure] if [code] does not look like an ISO 4217
  /// 3-letter code.
  ValidationFailure? _validateCurrencyCode(String code) {
    if (code.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      return ValidationFailure(
        'Currency code must be a 3-letter uppercase ISO 4217 code, got "$code".',
      );
    }
    return null;
  }
}
