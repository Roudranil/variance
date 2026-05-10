// lib/domain/repositories/i_account_repository.dart
//
// Abstract repository interface for the Account aggregate.
//
// All write operations return Future<Result<T>> — never throw across the
// layer boundary (SDS §2.9.3).
// All read-only queries that must stay in sync with the database return
// Stream<T> and do NOT use Result<T> (errors surface via StreamController).

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/money.dart';

/// Contract for all Account data-access operations.
abstract interface class IAccountRepository {
  /// Watches the full list of non-system, non-deleted accounts.
  Stream<List<Account>> watchAll();

  /// Watches a single account by its UUID.
  ///
  /// Emits null if the account does not exist or has been soft-deleted.
  Stream<Account?> watchById(String id);

  /// Persists a new account.
  Future<Result<Account>> create(Account account);

  /// Updates an existing account (non-financial fields only after first post).
  Future<Result<Account>> update(Account account);

  /// Soft-deletes the account with [id].
  Future<Result<void>> softDelete(String id);

  /// Watches the computed balance of [id] denominated in [currencyCode].
  ///
  /// Balance = Σ debit entries − Σ credit entries for all posted transactions.
  Stream<Money> watchBalance(String id, String currencyCode);

  /// Returns true if an account with [name] and [category] exists (including
  /// soft-deleted accounts).
  ///
  /// Used by [CreateAccountUseCase] to enforce unique names and detect
  /// reinstatement candidates.
  ///
  /// Parameters:
  /// - [name]: The account display name to check.
  Future<bool> isNameTaken(String name);

  /// Returns the soft-deleted account with [name] and [category], or null if
  /// no such account exists.
  ///
  /// Used by [CreateAccountUseCase] to offer a reinstatement option when the
  /// user tries to create an account with a name that was previously deleted.
  ///
  /// Parameters:
  /// - [name]: The account display name.
  /// - [category]: The [AccountCategory] to match.
  Future<Account?> findSoftDeletedByNameAndCategory(
    String name,
    AccountCategory category,
  );

  /// Saves (inserts or replaces) a list of [AccountDetail] rows for the given
  /// [accountId].
  ///
  /// Sensitive keys (card_number, account_number) must have their value
  /// pre-encrypted before calling this method; the repository stores the
  /// provided bytes without additional transformation.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  /// - [details]: Detail rows to persist.
  Future<Result<void>> saveAccountDetails(
    String accountId,
    List<AccountDetail> details,
  );

  /// Returns all [AccountDetail] rows for [accountId].
  ///
  /// Encrypted values are returned as raw ciphertext; call
  /// [revealEncryptedDetail] to obtain plaintext.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the parent account.
  Future<List<AccountDetail>> getAccountDetails(String accountId);
}
