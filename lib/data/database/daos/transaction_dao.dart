// lib/data/database/daos/transaction_dao.dart
//
// DAO for the `transactions` and `entries` aggregates.
//
// Responsibilities:
//   - CRUD on the transactions table
//   - Atomic write of transaction header + entry rows in one transaction
//   - Pagination via (date_time, id) cursor (SDS §1.4.2)
//   - Month-scoped watch queries for the default transaction list
//   - Account-scoped watch queries for the account ledger view
//   - FTS5 sync triggers (defined here; applied during database setup)
//
// DAOs execute queries only — no domain logic belongs here.
//
// Test cases (T-47):
//   - insertTransactionWithEntries is atomic: rollback on entry failure
//   - watchByMonth returns transactions in the correct month ordered desc
//   - watchByAccount returns transactions for the given account
//   - getById returns the transaction or null
//   - FTS5 table receives a matching row on insert (via trigger)

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/entries_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';

part 'transaction_dao.g.dart';

// ---------------------------------------------------------------------------
// Cursor type for paginated queries
// ---------------------------------------------------------------------------

/// Opaque pagination cursor for transaction list queries.
///
/// Encodes (transactionDate, id) so the next page can be fetched with
/// `WHERE (transaction_date, id) < (cursor.date, cursor.id)`.
class TransactionCursor {
  /// Creates a [TransactionCursor].
  ///
  /// Parameters:
  /// - [date]: The Unix epoch seconds of the last transaction on the
  ///   current page.
  /// - [id]: The UUID of the last transaction on the current page.
  const TransactionCursor({required this.date, required this.id});

  /// Unix epoch seconds of the last-seen transaction.
  final int date;

  /// UUID of the last-seen transaction.
  final String id;
}

/// Page size used by all cursor-based pagination queries.
const _kPageSize = 50;

// ---------------------------------------------------------------------------
// DAO
// ---------------------------------------------------------------------------

/// DAO for transactional operations on `transactions` and `entries`.
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
  // Watch queries
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

  /// Returns a stream of transactions for the given calendar month.
  ///
  /// Applies the default display filter (posted, non-reversal).
  /// Results are ordered by [transactionDate] descending.
  ///
  /// Parameters:
  /// - [year]: Calendar year (e.g. 2025).
  /// - [month]: Calendar month 1–12 (e.g. 5 for May).
  Stream<List<Transaction>> watchByMonth(int year, int month) {
    // Compute Unix epoch bounds for the calendar month in UTC.
    final start = DateTime.utc(year, month).millisecondsSinceEpoch ~/ 1000;
    // Next month's first second is the exclusive upper bound.
    final end = DateTime.utc(year, month + 1).millisecondsSinceEpoch ~/ 1000;

    return (select(transactions)
          ..where(
            (t) =>
                t.status.equals('posted') &
                t.purpose.isIn(['user', 'correction', 'system']) &
                t.transactionDate.isBiggerOrEqualValue(start) &
                t.transactionDate.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Returns a paginated stream of transactions associated with [accountId].
  ///
  /// Matches either [accountSourceId] or [accountDestinationId] against
  /// [accountId]. Applies the default display filter.
  ///
  /// Cursor pagination: when [cursor] is provided, only transactions where
  /// `(transaction_date, id) < (cursor.date, cursor.id)` are returned.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account to filter by.
  /// - [cursor]: Optional pagination cursor from the last item of the
  ///   previous page.
  Stream<List<Transaction>> watchByAccount(
    String accountId, {
    TransactionCursor? cursor,
  }) {
    return (select(transactions)
          ..where(
            (t) {
              final accountFilter = t.accountSourceId.equals(accountId) |
                  t.accountDestinationId.equals(accountId);
              final statusFilter = t.status.equals('posted') &
                  t.purpose.isIn(['user', 'correction', 'system']);

              if (cursor == null) {
                return accountFilter & statusFilter;
              }
              // Cursor pagination: (date, id) < (cursor.date, cursor.id)
              // implemented as date < cursor.date OR
              // (date = cursor.date AND id < cursor.id).
              final cursorFilter =
                  t.transactionDate.isSmallerThanValue(cursor.date) |
                      (t.transactionDate.equals(cursor.date) &
                          t.id.isSmallerThanValue(cursor.id));
              return accountFilter & statusFilter & cursorFilter;
            },
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.transactionDate),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(_kPageSize))
        .watch();
  }

  /// Returns a paginated stream of the default transaction list.
  ///
  /// Applies the default display filter (posted, non-reversal), ordered by
  /// [transactionDate] descending then [id] descending.
  ///
  /// Parameters:
  /// - [cursor]: Optional pagination cursor. When null, returns the first page.
  Stream<List<Transaction>> watchPaginated({TransactionCursor? cursor}) {
    return (select(transactions)
          ..where(
            (t) {
              final statusFilter = t.status.equals('posted') &
                  t.purpose.isIn(['user', 'correction', 'system']);

              if (cursor == null) return statusFilter;

              final cursorFilter =
                  t.transactionDate.isSmallerThanValue(cursor.date) |
                      (t.transactionDate.equals(cursor.date) &
                          t.id.isSmallerThanValue(cursor.id));
              return statusFilter & cursorFilter;
            },
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.transactionDate),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(_kPageSize))
        .watch();
  }

  // -----------------------------------------------------------------------
  // Single-row queries
  // -----------------------------------------------------------------------

  /// Returns the [Transaction] row with [id], or null if not found.
  ///
  /// Parameters:
  /// - [id]: UUID of the transaction to fetch.
  Future<Transaction?> getById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns a stream of the [Transaction] row with [id].
  ///
  /// Emits null when the row does not exist or is deleted.
  Stream<Transaction?> watchById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  // -----------------------------------------------------------------------
  // Entry queries
  // -----------------------------------------------------------------------

  /// Returns all [Entry] rows for the given [transactionId].
  ///
  /// Parameters:
  /// - [transactionId]: The UUID of the parent transaction.
  Future<List<Entry>> getEntriesForTransaction(String transactionId) {
    return (select(entries)
          ..where((e) => e.transactionId.equals(transactionId)))
        .get();
  }

  // -----------------------------------------------------------------------
  // Write operations
  // -----------------------------------------------------------------------

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

  /// Updates non-financial fields (title, description, transactionDate, payeeId)
  /// in-place on an existing transaction row.
  ///
  /// Financial fields are never updated here — corrections use the reversal +
  /// correction pair pattern.
  ///
  /// Parameters:
  /// - [id]: UUID of the transaction to update.
  /// - [companion]: Companion with only the fields to change set to non-absent
  ///   [Value]s.
  Future<void> updateNonFinancial(String id, TransactionsCompanion companion) {
    return (update(transactions)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// Sets [status] = 'voided' on the transaction with [id].
  ///
  /// Parameters:
  /// - [id]: UUID of the transaction to void.
  /// - [updatedAt]: Unix epoch seconds for the update timestamp.
  Future<void> voidTransaction(String id, int updatedAt) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        status: const Value('voided'),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Sets [status] = 'voided' on all transactions whose IDs are in [ids].
  ///
  /// Parameters:
  /// - [ids]: UUIDs of the transactions to void.
  /// - [updatedAt]: Unix epoch seconds for the update timestamp.
  Future<void> bulkVoidTransactions(List<String> ids, int updatedAt) {
    return transaction(() async {
      for (final id in ids) {
        await voidTransaction(id, updatedAt);
      }
    });
  }

  /// Searches transactions via the FTS5 virtual table.
  ///
  /// Returns transactions matching [query] in order of relevance.
  /// Applies the default display filter (posted, non-reversal).
  ///
  /// Parameters:
  /// - [query]: FTS5 match expression (e.g. 'groceries', '"coffee shop"').
  Future<List<Transaction>> searchByFts(String query) async {
    // FTS5 search via the transactions_fts virtual table. The FTS5 table has
    // the same rowid as the corresponding transactions row, so we join on rowid.
    // We re-query transactions by matching IDs to get full typed Drift rows.
    final rawRows = await customSelect(
      'SELECT t.id FROM transactions t '
      'JOIN transactions_fts fts ON fts.rowid = t.rowid '
      'WHERE transactions_fts MATCH ? '
      "AND t.status = 'posted' "
      "AND t.purpose IN ('user', 'correction', 'system') "
      'ORDER BY rank',
      variables: [Variable.withString(query)],
      readsFrom: {transactions},
    ).get();

    final ids = rawRows.map((r) => r.read<String>('id')).toList();
    if (ids.isEmpty) return [];

    return (select(transactions)..where((t) => t.id.isIn(ids))).get();
  }

  /// Returns all transactions with status = 'pending' whose
  /// [transaction_date] is at or before [nowEpoch].
  ///
  /// Used by [PostPendingTransactionsUseCase] on app launch (T-60).
  ///
  /// Parameters:
  /// - [nowEpoch]: Unix epoch seconds threshold.
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) {
    return (select(transactions)
          ..where(
            (t) =>
                t.status.equals('pending') &
                t.transactionDate.isSmallerOrEqualValue(nowEpoch),
          ))
        .get();
  }

  /// Returns the count of all posted, non-voided transactions.
  ///
  /// Used by [BackupReminderChecker] to determine whether the 50-transaction
  /// threshold has been reached (T-170).
  ///
  /// Returns the row count as an [int].
  Future<int> countPosted() async {
    final countExpr = transactions.id.count();
    final query = selectOnly(transactions)
      ..addColumns([countExpr])
      ..where(transactions.status.equals('posted'));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Atomically inserts [entries] and sets status = 'posted' for [id].
  ///
  /// Called by [PostPendingTransactionsUseCase] after building entries for a
  /// due pending transaction (T-60).
  ///
  /// Parameters:
  /// - [id]: UUID of the pending transaction.
  /// - [entries]: Balanced entry companions from [LedgerEngine].
  /// - [nowEpoch]: Current Unix epoch seconds for timestamps.
  Future<void> postPendingTransaction(
    String id,
    List<EntriesCompanion> entries,
    int nowEpoch,
  ) async {
    await db.transaction(() async {
      // Insert entries first.
      for (final entry in entries) {
        await into(this.entries).insert(entry);
      }
      // Promote status to posted.
      await (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          status: const Value('posted'),
          updatedAt: Value(nowEpoch),
        ),
      );
    });
  }
}
