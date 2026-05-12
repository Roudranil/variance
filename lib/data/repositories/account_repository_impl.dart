// lib/data/repositories/account_repository_impl.dart
//
// Concrete implementation of IAccountRepository backed by Drift via AccountDao.
//
// All domain-to-DTO mapping is performed in private helpers (_rowToEntity,
// _detailRowToEntity). The repository does NOT execute business logic —
// that belongs in use cases.
//
// Naming note: The Drift-generated row class for the `accounts` table is also
// named `Account`. To avoid ambiguity, the domain entity is imported with an
// alias (`AccountEntity`) while the Drift row type is used unqualified within
// DAO calls. The public API surface always returns domain entities.
//
// Integration tests (see test/data/repositories/account_repository_impl_test.dart):
//   1. create — inserted account watchable via watchAll
//   2. create — duplicate name returns Err(ValidationFailure)
//   3. update — changed field reflected in watchById stream
//   4. softDelete — account disappears from watchAll; watchById emits null
//   5. watchBalance — reflects entries after create/update
//   6. isNameTaken — true for active; true for soft-deleted
//   7. findSoftDeletedByNameAndCategory — returns deleted match
//   8. saveAccountDetails — details readable via getAccountDetails

import 'dart:developer' as dev;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

// AppDatabase defines the Drift row classes used for DTO mapping.
// AccountDao exports AppDatabase via its part file.
import 'package:variance/data/database/app_database.dart'
    show Account, AccountDetail, AccountsCompanion, AccountDetailsCompanion;
import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart' as domain;
import 'package:variance/domain/entities/account_detail.dart' as domain;
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';

// ---------------------------------------------------------------------------
// UUID generator
// ---------------------------------------------------------------------------

// ignore: prefer_const_constructors
final _uuid = Uuid();

/// Drift-backed implementation of [IAccountRepository].
///
/// Delegates all data access to [AccountDao]. Business rules (name uniqueness,
/// soft-delete guards, balance logic) live in use cases.
class AccountRepositoryImpl implements IAccountRepository {
  /// Creates an [AccountRepositoryImpl] backed by [dao].
  ///
  /// Parameters:
  /// - [dao]: The [AccountDao] used for all account data access.
  const AccountRepositoryImpl(this._dao);

  final AccountDao _dao;

  // -----------------------------------------------------------------------
  // IAccountRepository — read streams
  // -----------------------------------------------------------------------

  @override
  Stream<List<domain.Account>> watchAll() {
    return _dao.watchVisibleAccounts().map(
          (rows) => rows.map(_rowToEntity).toList(),
        );
  }

  @override
  Stream<domain.Account?> watchById(String id) {
    return _dao
        .watchById(id)
        .map((row) => row == null ? null : _rowToEntity(row));
  }

  @override
  Stream<Money> watchBalance(String id, String currencyCode) {
    return _dao.watchBalance(id).map(
          (minor) => Money(amountMinor: minor, currencyCode: currencyCode),
        );
  }

  // -----------------------------------------------------------------------
  // IAccountRepository — write operations
  // -----------------------------------------------------------------------

  @override
  Future<Result<domain.Account>> create(domain.Account account) async {
    try {
      await _dao.insertAccount(_entityToCompanion(account));
      final inserted = await _dao.findById(account.id);
      if (inserted == null) {
        return const Err(
          DatabaseFailure('Account insert succeeded but row not found'),
        );
      }
      return Ok(_rowToEntity(inserted));
    } on Object catch (e, st) {
      dev.log(
        'AccountRepositoryImpl.create error: $e',
        name: 'AccountRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to create account: $e'));
    }
  }

  @override
  Future<Result<domain.Account>> update(domain.Account account) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final companion = _entityToCompanion(account).copyWith(
        updatedAt: Value(nowEpoch),
      );
      final updated = await _dao.updateAccount(companion);
      if (!updated) {
        return Err(
          NotFoundFailure('Account ${account.id} not found for update'),
        );
      }
      final row = await _dao.findById(account.id);
      if (row == null) {
        return const Err(DatabaseFailure('Account row missing after update'));
      }
      return Ok(_rowToEntity(row));
    } on Object catch (e, st) {
      dev.log(
        'AccountRepositoryImpl.update error: $e',
        name: 'AccountRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to update account: $e'));
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final affected = await _dao.softDeleteAccount(id, nowEpoch);
      if (affected == 0) {
        return Err(NotFoundFailure('Account $id not found for soft-delete'));
      }
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'AccountRepositoryImpl.softDelete error: $e',
        name: 'AccountRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to soft-delete account: $e'));
    }
  }

  // -----------------------------------------------------------------------
  // IAccountRepository — name uniqueness helpers
  // -----------------------------------------------------------------------

  @override
  Future<bool> isNameTaken(String name) {
    return _dao.isNameTaken(name);
  }

  @override
  Future<domain.Account?> findSoftDeletedByNameAndCategory(
    String name,
    domain.AccountCategory category,
  ) async {
    final row = await _dao.findSoftDeletedByNameAndCategory(
      name,
      _categoryToString(category),
    );
    return row == null ? null : _rowToEntity(row);
  }

  // -----------------------------------------------------------------------
  // IAccountRepository — account details
  // -----------------------------------------------------------------------

  @override
  Future<Result<void>> saveAccountDetails(
    String accountId,
    List<domain.AccountDetail> details,
  ) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (final detail in details) {
        final companion = AccountDetailsCompanion(
          id: Value(detail.id.isEmpty ? _uuid.v4() : detail.id),
          accountId: Value(accountId),
          detailKey: Value(detail.detailKey),
          detailValue: Value(detail.detailValue),
          detailValueEncrypted: Value(detail.detailValueEncrypted),
          updatedAt: Value(nowEpoch),
        );
        await _dao.insertOrReplaceDetail(companion);
      }
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'AccountRepositoryImpl.saveAccountDetails error: $e',
        name: 'AccountRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to save account details: $e'));
    }
  }

  @override
  Future<List<domain.AccountDetail>> getAccountDetails(String accountId) async {
    final rows = await _dao.getDetailsForAccount(accountId);
    return rows.map(_detailRowToEntity).toList();
  }

  @override
  Future<List<String>> getDistinctActiveCurrencies() {
    return _dao.getDistinctActiveCurrencies();
  }

  // -----------------------------------------------------------------------
  // Private mapping helpers
  // -----------------------------------------------------------------------

  /// Maps a Drift-generated [Account] row to the domain [domain.Account] entity.
  domain.Account _rowToEntity(Account row) {
    return domain.Account(
      id: row.id,
      name: row.name,
      accountCategory: _categoryFromString(row.accountCategory),
      initialBalanceMinor: row.initialBalanceMinor,
      currencyCode: row.currencyCode,
      includeInNetWorth: row.includeInNetWorth,
      notes: row.notes,
      isDeleted: row.isDeleted,
      deletedAt: row.deletedAt,
      isProtected: row.isProtected,
      isSystem: row.isSystem,
      displayOrder: row.displayOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      metadata: row.metadata,
    );
  }

  /// Maps a domain [domain.Account] entity to an [AccountsCompanion] for Drift.
  AccountsCompanion _entityToCompanion(domain.Account entity) {
    return AccountsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      accountCategory: Value(_categoryToString(entity.accountCategory)),
      initialBalanceMinor: Value(entity.initialBalanceMinor),
      currencyCode: Value(entity.currencyCode),
      includeInNetWorth: Value(entity.includeInNetWorth),
      notes: Value(entity.notes),
      isDeleted: Value(entity.isDeleted),
      deletedAt: Value(entity.deletedAt),
      isProtected: Value(entity.isProtected),
      isSystem: Value(entity.isSystem),
      displayOrder: Value(entity.displayOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      metadata: Value(entity.metadata),
    );
  }

  /// Maps a Drift-generated [AccountDetail] row to the domain entity.
  domain.AccountDetail _detailRowToEntity(AccountDetail row) {
    return domain.AccountDetail(
      id: row.id,
      accountId: row.accountId,
      detailKey: row.detailKey,
      detailValue: row.detailValue,
      detailValueEncrypted: row.detailValueEncrypted,
      updatedAt: row.updatedAt,
    );
  }

  /// Converts a [domain.AccountCategory] to its database string representation.
  String _categoryToString(domain.AccountCategory category) {
    return switch (category) {
      domain.AccountCategory.cash => 'cash',
      domain.AccountCategory.bankAccount => 'bank_account',
      domain.AccountCategory.creditCard => 'credit_card',
      domain.AccountCategory.debitCard => 'debit_card',
      domain.AccountCategory.topUpWallet => 'top_up_wallet',
      domain.AccountCategory.loan => 'loan',
      domain.AccountCategory.investment => 'investment',
      domain.AccountCategory.other => 'other',
      domain.AccountCategory.equity => 'equity',
    };
  }

  /// Parses a database category string to [domain.AccountCategory].
  ///
  /// Falls back to [domain.AccountCategory.other] for unrecognised values
  /// (forward-compat guard).
  domain.AccountCategory _categoryFromString(String value) {
    return switch (value) {
      'cash' => domain.AccountCategory.cash,
      'bank_account' => domain.AccountCategory.bankAccount,
      'credit_card' => domain.AccountCategory.creditCard,
      'debit_card' => domain.AccountCategory.debitCard,
      'top_up_wallet' => domain.AccountCategory.topUpWallet,
      'loan' => domain.AccountCategory.loan,
      'investment' => domain.AccountCategory.investment,
      'equity' => domain.AccountCategory.equity,
      _ => domain.AccountCategory.other,
    };
  }
}
