// lib/domain/services/search_ranker.dart
//
// SearchRanker — Dart-side scoring pass for FTS5 search candidates.
//
// Architecture (T-158, SDS §2.8.3):
//   Stage 2 of the two-stage search pipeline:
//   1. FTS5 returns ≤500 candidate rows (SQL stage in SearchDao).
//   2. SearchRanker applies field-weight composite scoring (this class).
//
// Scoring weights (SDS §2.8.3):
//   | Signal                          | Weight |
//   |---------------------------------|--------|
//   | Exact match on title            | 1.00   |
//   | Prefix match on title           | 0.80   |
//   | Prefix match on account name    | 0.70   |
//   | Substring match on title        | 0.60   |
//   | Substring match on description  | 0.30   |
//   | Substring match on category     | 0.25   |
//   | Typo-tolerant match on title    | 0.40   |
//   | Typo-tolerant on other fields   | 0.20   |
//
// Tiebreaker: equal scores → transaction_date DESC (most recent first).
// Zero-score candidates are excluded from the returned list.
//
// This service is pure Dart — no Flutter dependency (SDS §1.6.3).

import 'package:variance/domain/entities/transaction.dart';

/// A ranked transaction candidate returned by [SearchRanker].
///
/// Pairs a [Transaction] with the denormalized account/category names needed
/// for scoring (these are not fields on [Transaction] itself).
class SearchCandidate {
  /// Creates a [SearchCandidate].
  ///
  /// Parameters:
  /// - [transaction]: The domain transaction entity.
  /// - [accountName]: Display name of the source or destination account.
  /// - [categoryName]: Display name of the category (empty string if none).
  const SearchCandidate({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
  });

  /// The underlying transaction entity.
  final Transaction transaction;

  /// Account name associated with this transaction (source or destination).
  final String accountName;

  /// Category name associated with this transaction; empty string when absent.
  final String categoryName;
}

/// Ranks FTS5 candidate transactions by field-weight composite score.
///
/// Instances are stateless and can be shared as constants.
class SearchRanker {
  /// Creates a [SearchRanker].
  const SearchRanker();

  // Field weights (SDS §2.8.3).
  static const double _wExactTitle = 1.00;
  static const double _wPrefixTitle = 0.80;
  static const double _wPrefixAccount = 0.70;
  static const double _wSubstringTitle = 0.60;
  static const double _wSubstringDescription = 0.30;
  static const double _wSubstringCategory = 0.25;
  static const double _wTypoTitle = 0.40;
  static const double _wTypoOther = 0.20;

  /// Ranks [candidates] against [query] and returns them sorted by descending
  /// composite score, then by [Transaction.dateTime] descending for ties.
  ///
  /// Zero-score candidates (no match on any field at any distance) are
  /// excluded from the returned list.
  ///
  /// Parameters:
  /// - [candidates]: FTS5-sourced candidate set; at most 500 entries.
  /// - [query]: The original user query string (lowercased internally).
  List<SearchCandidate> rank(List<SearchCandidate> candidates, String query) {
    if (candidates.isEmpty) return const [];

    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];

    final scored = <({SearchCandidate candidate, double score})>[];

    for (final c in candidates) {
      final score = _score(c, q);
      if (score > 0.0) {
        scored.add((candidate: c, score: score));
      }
    }

    // Sort: descending score, then descending dateTime for ties.
    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return b.candidate.transaction.dateTime
          .compareTo(a.candidate.transaction.dateTime);
    });

    return scored.map((e) => e.candidate).toList();
  }

  /// Computes the composite score for a single [candidate] against [query].
  ///
  /// Returns the maximum matched weight across all field/match-type
  /// combinations. Returns 0.0 when no field matches at any level.
  ///
  /// Parameters:
  /// - [candidate]: The candidate with denormalized name fields.
  /// - [query]: Lower-cased query string.
  double _score(SearchCandidate candidate, String query) {
    final tx = candidate.transaction;
    final title = (tx.title ?? '').toLowerCase();
    final description = (tx.description ?? '').toLowerCase();
    final account = candidate.accountName.toLowerCase();
    final category = candidate.categoryName.toLowerCase();

    double best = 0.0;

    // --- Exact / prefix / substring matching on title ---
    if (title.isNotEmpty) {
      if (title == query) {
        best = _wExactTitle;
      } else if (title.startsWith(query)) {
        best = _max(best, _wPrefixTitle);
      } else if (title.contains(query)) {
        best = _max(best, _wSubstringTitle);
      }
    }

    // --- Prefix / substring matching on account name ---
    if (account.isNotEmpty) {
      if (account.startsWith(query)) {
        best = _max(best, _wPrefixAccount);
      } else if (account.contains(query)) {
        best = _max(best, _wSubstringTitle); // same weight as substring title
      }
    }

    // --- Substring matching on description ---
    if (description.isNotEmpty && description.contains(query)) {
      best = _max(best, _wSubstringDescription);
    }

    // --- Substring matching on category ---
    if (category.isNotEmpty && category.contains(query)) {
      best = _max(best, _wSubstringCategory);
    }

    // --- Typo-tolerant matching (Levenshtein distance 1) ---
    // Only computed when no direct match was found (saves work).
    if (best == 0.0) {
      best = _typoScore(title, account, description, category, query);
    }

    return best;
  }

  /// Applies Levenshtein distance-1 check across all relevant fields.
  ///
  /// Splits each field into whitespace-separated tokens, then checks if any
  /// token is within edit distance 1 of [query]. Returns the best typo weight
  /// found, or 0.0 if none match.
  ///
  /// Parameters:
  /// - [title]: Lower-cased title.
  /// - [account]: Lower-cased account name.
  /// - [description]: Lower-cased description.
  /// - [category]: Lower-cased category name.
  /// - [query]: Lower-cased query string.
  double _typoScore(
    String title,
    String account,
    String description,
    String category,
    String query,
  ) {
    // Skip trivially short queries — fuzzy matching on 1-2 chars produces
    // too many false positives.
    if (query.length < 3) return 0.0;

    double best = 0.0;

    // Title tokens — highest typo weight.
    for (final token in _tokens(title)) {
      if (_levenshtein(token, query) == 1) {
        best = _max(best, _wTypoTitle);
        break;
      }
    }

    // Account + other field tokens — lower typo weight.
    if (best < _wTypoOther) {
      for (final token in [
        ..._tokens(account),
        ..._tokens(description),
        ..._tokens(category),
      ]) {
        if (_levenshtein(token, query) == 1) {
          best = _max(best, _wTypoOther);
          break;
        }
      }
    }

    return best;
  }

  /// Splits [text] into lowercase tokens on whitespace/punctuation boundaries.
  List<String> _tokens(String text) {
    if (text.isEmpty) return const [];
    return text.split(RegExp(r'[\s,.:;/\\()\[\]{}]+'))
      ..removeWhere((t) => t.isEmpty);
  }

  /// Returns the larger of [a] and [b].
  double _max(double a, double b) => a > b ? a : b;

  /// Computes the Levenshtein edit distance between [s] and [t].
  ///
  /// Uses the classic two-row DP approach, bounded to the candidate set
  /// size of ≤500 rows (SDS §2.8.3).
  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    // Prune: if length difference alone exceeds 1, skip the full DP.
    if ((s.length - t.length).abs() > 1) return 2;

    final prev = List<int>.generate(t.length + 1, (i) => i);
    final curr = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      curr[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        curr[j + 1] = _minOf3(
          curr[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        );
      }
      for (int j = 0; j <= t.length; j++) {
        prev[j] = curr[j];
      }
    }

    return curr[t.length];
  }

  int _minOf3(int a, int b, int c) {
    if (a <= b && a <= c) return a;
    if (b <= c) return b;
    return c;
  }
}
