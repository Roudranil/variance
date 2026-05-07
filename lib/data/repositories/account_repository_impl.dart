// lib/data/repositories/account_repository_impl.dart
//
// Concrete implementation of IAccountRepository backed by Drift via AccountDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic is implemented in later feature tasks (S-6 onward).

import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

/// Drift-backed implementation of [IAccountRepository].
///
/// Delegates all data access to [AccountDao]. Business rules live in use cases.
class AccountRepositoryImpl implements IAccountRepository {
  /// Creates an [AccountRepositoryImpl] backed by [dao].
  const AccountRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
  final AccountDao _dao;

  @override
  Stream<List<Account>> watchAll() {
    // TODO(dev): Map Drift rows to Account domain entities (S-6).
    throw UnimplementedError('watchAll not yet implemented');
  }

  @override
  Stream<Account?> watchById(String id) {
    // TODO(dev): Implement single-account stream (S-6).
    throw UnimplementedError('watchById not yet implemented');
  }

  @override
  Future<Result<Account>> create(Account account) {
    // TODO(dev): Implement account creation with initial balance entry (S-6).
    throw UnimplementedError('create not yet implemented');
  }

  @override
  Future<Result<Account>> update(Account account) {
    // TODO(dev): Implement non-financial field update (S-6).
    throw UnimplementedError('update not yet implemented');
  }

  @override
  Future<Result<void>> softDelete(String id) {
    // TODO(dev): Implement soft-delete with balance guard (S-6).
    throw UnimplementedError('softDelete not yet implemented');
  }

  @override
  Stream<Money> watchBalance(String id, String currencyCode) {
    // TODO(dev): Implement balance aggregation stream (S-6).
    throw UnimplementedError('watchBalance not yet implemented');
  }
}
