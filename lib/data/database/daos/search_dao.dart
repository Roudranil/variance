// lib/data/database/daos/search_dao.dart
//
// SearchDao — dedicated DAO for FTS5 full-text transaction search (T-158).
//
// Architecture (SDS §2.8.2, §2.8.3):
//   - Stage 1 FTS5 query: prefix/exact match on title/account_name; substring
//     match on description/category_name. Returns ≤500 candidates with rank.
//   - Joins FTS candidate IDs back to transactions + accounts + categories for
//     full denormalized row data needed by SearchRanker.
//   - The caller (SearchRanker) performs Stage 2 Dart-side scoring.
//
// FTS5 query pattern (SDS §2.8.3):
//   title/account_name: prefix+exact → higher BM25 rank
//   description/category_name: substring recall
//
// Devlog quirks:
//   - customSelect readsFrom must reference table getters from _$DaoMixin.
//   - customSelect returns QueryRow — use row.read<T>('column') for all fields.
//   - All joined tables must appear in @DriftAccessor(tables:[...]) and
//     readsFrom:{...}.
//   - FTS5 MATCH uses "column:" scoping; always use transaction_id field for
//     the rowid join (SDS §2.8.2 transaction_id UNINDEXED).
//
// Test cases (see test/data/database/search_dao_test.dart):
//   T-158-DAO.1: title exact match returns result
//   T-158-DAO.2: title prefix match returns result
//   T-158-DAO.3: empty query returns empty list
//   T-158-DAO.4: no match returns empty list

import 'dart:developer' as dev;

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/domain/entities/transaction.dart' as domain;
import 'package:variance/domain/services/search_ranker.dart';

part 'search_dao.g.dart';

/// DAO for full-text search across the `transactions_fts` FTS5 virtual table.
///
/// Returns denormalized [SearchCandidate] objects (transaction + account name
/// + category name) suitable for the [SearchRanker] Stage 2 scoring pass.
@DriftAccessor(tables: [Transactions, Accounts, Categories])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  /// Creates a [SearchDao] bound to [db].
  SearchDao(super.db);

  /// Maximum number of FTS5 candidates to return per query.
  ///
  /// Bounds the Dart-side Levenshtein pass to a tractable set (SDS §2.8.3).
  static const int kFtsCandidateLimit = 500;

  /// Searches transactions via FTS5 and returns denormalized candidates.
  ///
  /// Executes the two-field FTS5 query pattern from SDS §2.8.3:
  /// prefix/exact on `title` and `account_name`; substring recall on
  /// `description` and `category_name`. Limits to [kFtsCandidateLimit] rows
  /// ordered by FTS5 BM25 rank (best first).
  ///
  /// Returns an empty list when [query] is blank or contains only whitespace.
  ///
  /// Parameters:
  /// - [query]: User-supplied search string (NOT pre-escaped).
  Future<List<SearchCandidate>> searchCandidates(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    // Escape FTS5 special characters in user input.
    final escaped = _escapeFts5Query(trimmed);

    // Build the FTS5 MATCH expression (SDS §2.8.3):
    //   {title account_name}: "^{q}"  → prefix match (higher rank)
    //   {description category_name}: "{q}"  → substring/phrase recall
    final matchExpr =
        '{title account_name}: "^$escaped" OR {description category_name}: "$escaped"';

    dev.log(
      'SearchDao.searchCandidates: matchExpr=$matchExpr',
      name: 'SearchDao',
    );

    // Stage 1: FTS5 query — get up to 500 candidate transaction IDs ordered by
    // relevance. We join via the stored transaction_id field (UNINDEXED column
    // in FTS5) to avoid rowid translation issues.
    final rawIdRows = await customSelect(
      'SELECT fts.transaction_id AS tid '
      'FROM transactions_fts fts '
      'WHERE transactions_fts MATCH ? '
      'ORDER BY rank '
      'LIMIT ?',
      variables: [
        Variable.withString(matchExpr),
        Variable.withInt(kFtsCandidateLimit),
      ],
      readsFrom: {transactions},
    ).get();

    if (rawIdRows.isEmpty) return const [];

    final ids = rawIdRows.map((r) => r.read<String>('tid')).toList();

    // Stage 1b: Re-query by IDs with account/category denormalization.
    // Using a full column list to map to domain entities via QueryRow.
    final inPlaceholders = List.filled(ids.length, '?').join(',');
    final candidateRows = await customSelect(
      'SELECT t.id, t.type, t.status, t.purpose, '
      '  t.transaction_date, t.amount_minor, t.currency_code, '
      '  t.exchange_rate_micro, t.home_currency_at_capture, '
      '  t.account_source_id, t.account_destination_id, '
      '  t.category_id, t.subcategory_id, t.payee_id, '
      '  t.compound_group_id, t.compound_role, t.parent_template_id, '
      '  t.corrects_transaction_id, t.is_manually_handled, '
      '  t.created_at, t.updated_at, t.metadata, '
      '  t.title, t.description, '
      '  COALESCE(a_src.name, a_dst.name, \'\') AS account_name, '
      '  COALESCE(c.name, \'\') AS category_name '
      'FROM transactions t '
      '  LEFT JOIN accounts a_src ON a_src.id = t.account_source_id '
      '  LEFT JOIN accounts a_dst ON a_dst.id = t.account_destination_id '
      '  LEFT JOIN categories c ON c.id = t.category_id '
      'WHERE t.id IN ($inPlaceholders)',
      variables: ids.map(Variable.withString).toList(),
      readsFrom: {transactions, accounts, categories},
    ).get();

    return candidateRows.map(_rowToCandidate).toList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts a [QueryRow] from the denormalized search query to a
  /// [SearchCandidate].
  SearchCandidate _rowToCandidate(QueryRow row) {
    final tx = domain.Transaction(
      id: row.read<String>('id'),
      type: _mapType(row.read<String>('type')),
      status: _mapStatus(row.read<String>('status')),
      purpose: _mapPurpose(row.read<String>('purpose')),
      dateTime: row.read<int>('transaction_date'),
      amountMinor: row.read<int>('amount_minor'),
      currencyCode: row.read<String>('currency_code'),
      exchangeRateMicro: row.readNullable<int>('exchange_rate_micro'),
      homeCurrencyAtCapture:
          row.readNullable<String>('home_currency_at_capture'),
      accountSourceId: row.readNullable<String>('account_source_id'),
      accountDestinationId:
          row.readNullable<String>('account_destination_id'),
      categoryId: row.readNullable<String>('category_id'),
      subcategoryId: row.readNullable<String>('subcategory_id'),
      payeeId: row.readNullable<String>('payee_id'),
      title: row.readNullable<String>('title'),
      description: row.readNullable<String>('description'),
      compoundGroupId: row.readNullable<String>('compound_group_id'),
      compoundRole: row.readNullable<String>('compound_role'),
      parentTemplateId: row.readNullable<String>('parent_template_id'),
      correctsTransactionId:
          row.readNullable<String>('corrects_transaction_id'),
      isManuallyHandled: row.read<bool>('is_manually_handled'),
      createdAt: row.read<int>('created_at'),
      updatedAt: row.read<int>('updated_at'),
      metadata: row.readNullable<String>('metadata'),
    );

    return SearchCandidate(
      transaction: tx,
      accountName: row.read<String>('account_name'),
      categoryName: row.read<String>('category_name'),
    );
  }

  /// Escapes FTS5 special characters in [raw] user input to prevent injection.
  ///
  /// Replaces double-quote with two consecutive double-quotes (SQL string
  /// escaping for FTS5 MATCH expressions).
  ///
  /// Parameters:
  /// - [raw]: The unescaped user query string.
  String _escapeFts5Query(String raw) => raw.replaceAll('"', '""');

  domain.TransactionType _mapType(String s) => switch (s) {
        'income' => domain.TransactionType.income,
        'transfer' => domain.TransactionType.transfer,
        _ => domain.TransactionType.expense,
      };

  domain.TransactionStatus _mapStatus(String s) => switch (s) {
        'posted' => domain.TransactionStatus.posted,
        'voided' => domain.TransactionStatus.voided,
        _ => domain.TransactionStatus.pending,
      };

  domain.TransactionPurpose _mapPurpose(String s) => switch (s) {
        'reversal' => domain.TransactionPurpose.reversal,
        'correction' => domain.TransactionPurpose.correction,
        'system' => domain.TransactionPurpose.system,
        _ => domain.TransactionPurpose.user,
      };
}
