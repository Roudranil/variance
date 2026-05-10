// lib/data/repositories/drift_ledger_repository.dart
//
// Drift-backed implementation of LedgerRepository.
//
// This repository is used exclusively by LedgerEngine to persist balanced
// entry sets. No domain logic belongs here — all invariant checks live in
// LedgerEngine.
//
// EQ account operations use the accounts table directly. The EQ account
// naming convention is __EQ_{currencyCode} (SDS §1.4.2, TC-045).

import 'dart:developer' as dev;

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart'
    show AppDatabase, AccountsCompanion, EntriesCompanion;
import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/data/database/daos/transaction_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/services/ledger_engine.dart';

/// Drift-backed implementation of [LedgerRepository].
///
/// All writes are intended to be called within an outer database transaction
/// (managed by the calling use case or [AppDatabase.transaction]).
class DriftLedgerRepository implements LedgerRepository {
  /// Creates a [DriftLedgerRepository].
  ///
  /// Parameters:
  /// - [accountDao]: Used for EQ account existence check and creation.
  /// - [transactionDao]: Used for inserting entries.
  /// - [database]: The underlying [AppDatabase] for raw transaction wrapper.
  const DriftLedgerRepository({
    required this.accountDao,
    required this.transactionDao,
    required this.database,
  });

  /// DAO for account operations (EQ account management).
  final AccountDao accountDao;

  /// DAO for entry insert operations.
  final TransactionDao transactionDao;

  /// The underlying database (for transaction() wrapper access).
  final AppDatabase database;

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async {
    try {
      for (final entry in entries) {
        await transactionDao.insertEntry(_entryToCompanion(entry));
      }
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'DriftLedgerRepository.insertEntries error: $e',
        name: 'LedgerRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to insert ledger entries: $e'));
    }
  }

  @override
  Future<bool> eqAccountExists(String currencyCode) async {
    final eqId = _eqAccountId(currencyCode);
    final row = await (accountDao.select(accountDao.accounts)
          ..where((a) => a.id.equals(eqId)))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async {
    final eqId = _eqAccountId(currencyCode);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      await accountDao.insertAccount(
        AccountsCompanion(
          id: Value(eqId),
          name: Value('__EQ_$currencyCode'),
          accountCategory: const Value('equity'),
          initialBalanceMinor: const Value(0),
          currencyCode: Value(currencyCode),
          includeInNetWorth: const Value(false),
          isProtected: const Value(true),
          isSystem: const Value(true),
          createdAt: Value(nowEpoch),
          updatedAt: Value(nowEpoch),
        ),
      );
      return Ok(eqId);
    } on Object catch (e, st) {
      dev.log(
        'DriftLedgerRepository.createEqAccount error: $e',
        name: 'LedgerRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to create EQ account: $e'));
    }
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Returns the deterministic EQ account ID for [currencyCode].
  ///
  /// Uses a fixed prefix rather than a UUID so the ID is predictable and the
  /// [eqAccountExists] check avoids a name-based query.
  String _eqAccountId(String currencyCode) => '__EQ_$currencyCode';

  /// Converts a domain [Entry] to a Drift [EntriesCompanion].
  EntriesCompanion _entryToCompanion(Entry entry) {
    return EntriesCompanion(
      id: Value(entry.id),
      transactionId: Value(entry.transactionId),
      accountId: Value(entry.accountId),
      categoryId: Value(entry.categoryId),
      side: Value(entry.side == EntrySide.debit ? 'debit' : 'credit'),
      amountMinor: Value(entry.amountMinor),
      currencyCode: Value(entry.currencyCode),
      exchangeRateMicro: Value(entry.exchangeRateMicro),
      createdAt: Value(entry.createdAt),
    );
  }
}
