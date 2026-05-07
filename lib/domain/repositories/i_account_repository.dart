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
}
