// lib/data/database/daos/transaction_dao.dart
//
// DAO for the `transactions` and `entries` aggregates.
//
// Responsibilities:
//   - CRUD on the transactions table
//   - Atomic write of transaction header + entry rows in one transaction
//   - FTS5 sync triggers (defined here; applied during database setup)
//
// DAOs execute queries only — no domain logic belongs here.

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/data/database/tables/entries_table.dart';

part 'transaction_dao.g.dart';

/// DAO for transactional (pun intended) operations on `transactions` and
/// `entries`.
///
/// All writes that touch both tables must use [transaction()] to ensure
/// atomicity (SDS §1.6.2). FTS5 index sync is handled via SQL triggers
/// installed during [AppDatabase] setup.
@DriftAccessor(tables: [Transactions, Entries])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  /// Creates a new [TransactionDao] bound to [db].
  TransactionDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns a stream of all non-voided, non-reversal posted transactions
  /// ordered by date descending.
  ///
  /// This is the default list view filter (TC-001, TC-015).
  Stream<List<Transaction>> watchPostedTransactions() {
    return (select(transactions)
          ..where(
            (t) =>
                t.status.equals('posted') &
                t.purpose.isIn(['user', 'correction', 'system']),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Returns all [Entry] rows for the given [transactionId].
  ///
  /// Parameters:
  /// - [transactionId]: The UUID of the parent transaction.
  Future<List<Entry>> getEntriesForTransaction(String transactionId) {
    return (select(entries)
          ..where((e) => e.transactionId.equals(transactionId)))
        .get();
  }

  /// Inserts a single entry row.
  ///
  /// Used by [DriftLedgerRepository] when building ledger entry sets outside
  /// of a full transaction-with-header write (e.g. opening balance for account
  /// creation).
  ///
  /// Parameters:
  /// - [entry]: The entry companion to insert.
  Future<int> insertEntry(EntriesCompanion entry) {
    return into(entries).insert(entry);
  }

  /// Inserts a transaction header and its entry rows atomically.
  ///
  /// Both inserts are wrapped in a database [transaction()] to ensure that
  /// a failure on entries leaves no orphan transaction row.
  ///
  /// Parameters:
  /// - [txn]: The transaction companion to insert.
  /// - [entryList]: The entry companions to insert.
  Future<void> insertTransactionWithEntries(
    TransactionsCompanion txn,
    List<EntriesCompanion> entryList,
  ) async {
    await transaction(() async {
      await into(transactions).insert(txn);
      await batch((b) => b.insertAll(entries, entryList));
    });
  }
}
