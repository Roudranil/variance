// lib/domain/repositories/i_entry_repository.dart
//
// Abstract repository interface for the Entry aggregate.
//
// This is an internal repository — called only by the LedgerEngine inside a
// database transaction. It is not exposed to use cases directly.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';

/// Contract for raw DEB ledger-line access.
///
/// Not intended for direct use by feature use cases; the LedgerEngine
/// orchestrates entry writes as part of transaction creation/correction.
abstract interface class IEntryRepository {
  /// Watches all entries for an account, ordered by creation epoch.
  Stream<List<Entry>> watchByAccount(String accountId);

  /// Inserts a debit/credit pair atomically.
  ///
  /// Both entries must belong to the same transaction and satisfy
  /// debit.amountMinor == credit.amountMinor (enforced by LedgerEngine).
  Future<Result<void>> insertPair(Entry debit, Entry credit);
}
