// test/unit/domain/services/search_ranker_test.dart
//
// Unit tests for SearchRanker (T-158).
//
// Test cases:
//   T-158.1. exact title match scores higher than prefix match
//   T-158.2. prefix title match scores higher than prefix account match
//   T-158.3. prefix account match scores higher than substring title match
//   T-158.4. substring title match scores higher than substring description
//   T-158.5. substring description match scores higher than substring category
//   T-158.6. typo tolerance: "cofee" matches "coffee" (distance 1)
//   T-158.7. typo tolerance: typo match scores lower than exact match
//   T-158.8. tiebreaker: equal scores sort by dateTime descending
//   T-158.9. empty candidate list returns empty list
//   T-158.10. no match returns score 0.0 (transaction still returned with 0)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/services/search_ranker.dart';

void main() {
  group('SearchRanker — T-158', () {
    // Build a minimal Transaction stub with overrides.
    Transaction _makeTx({
      required String id,
      String? title,
      String? description,
      String? accountName,
      String? categoryName,
      int dateTime = 1000,
    }) {
      return Transaction(
        id: id,
        type: TransactionType.expense,
        status: TransactionStatus.posted,
        dateTime: dateTime,
        amountMinor: 5000,
        currencyCode: 'INR',
        createdAt: 1000,
        updatedAt: 1000,
        title: title,
        description: description,
        // accountName / categoryName are passed via the wrapper SearchCandidate,
        // not on Transaction directly.
      );
    }

    SearchCandidate _makeCandidate(
      Transaction tx, {
      String accountName = '',
      String categoryName = '',
    }) =>
        SearchCandidate(
          transaction: tx,
          accountName: accountName,
          categoryName: categoryName,
        );

    const ranker = SearchRanker();

    // -----------------------------------------------------------------------
    // T-158.1: exact title > prefix title
    // -----------------------------------------------------------------------
    test('T-158.1 exact title scores higher than prefix title', () {
      final exact = _makeCandidate(
        _makeTx(id: 'a', title: 'Coffee'),
        accountName: '',
        categoryName: '',
      );
      final prefix = _makeCandidate(
        _makeTx(id: 'b', title: 'Coffee Shop'),
        accountName: '',
        categoryName: '',
      );
      final ranked = ranker.rank([exact, prefix], 'Coffee');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.2: prefix title > prefix account
    // -----------------------------------------------------------------------
    test('T-158.2 prefix title scores higher than prefix account', () {
      final prefixTitle = _makeCandidate(
        _makeTx(id: 'a', title: 'Grocery Shop'),
        accountName: 'HDFC',
        categoryName: '',
      );
      final prefixAccount = _makeCandidate(
        _makeTx(id: 'b', title: 'Misc Expense'),
        accountName: 'Groceries Account',
        categoryName: '',
      );
      final ranked = ranker.rank([prefixAccount, prefixTitle], 'Grocer');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.3: prefix account > substring title
    // -----------------------------------------------------------------------
    test('T-158.3 prefix account scores higher than substring title', () {
      final prefixAccount = _makeCandidate(
        _makeTx(id: 'a', title: 'Misc'),
        accountName: 'Salary Account',
        categoryName: '',
      );
      final substringTitle = _makeCandidate(
        _makeTx(id: 'b', title: 'Grocery Salary Receipt'),
        accountName: 'HDFC',
        categoryName: '',
      );
      final ranked = ranker.rank([substringTitle, prefixAccount], 'Salary');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.4: substring title > substring description
    // -----------------------------------------------------------------------
    test('T-158.4 substring title scores higher than substring description',
        () {
      final substringTitle = _makeCandidate(
        _makeTx(id: 'a', title: 'Weekly Grocery'),
        accountName: '',
        categoryName: '',
      );
      final substringDesc = _makeCandidate(
        _makeTx(id: 'b', title: 'Misc', description: 'Weekly grocery run'),
        accountName: '',
        categoryName: '',
      );
      final ranked = ranker.rank([substringDesc, substringTitle], 'Grocery');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.5: substring description > substring category
    // -----------------------------------------------------------------------
    test('T-158.5 substring description scores higher than substring category',
        () {
      final descMatch = _makeCandidate(
        _makeTx(id: 'a', title: 'Misc', description: 'food delivery order'),
        accountName: '',
        categoryName: '',
      );
      final catMatch = _makeCandidate(
        _makeTx(id: 'b', title: 'Misc'),
        accountName: '',
        categoryName: 'Food & Dining',
      );
      final ranked = ranker.rank([catMatch, descMatch], 'food');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.6: typo tolerance — distance-1 match
    // -----------------------------------------------------------------------
    test('T-158.6 typo "cofee" matches title "coffee"', () {
      final tx = _makeCandidate(
        _makeTx(id: 'a', title: 'Coffee'),
        accountName: '',
        categoryName: '',
      );
      final ranked = ranker.rank([tx], 'cofee');
      // Ranked list should not be empty — typo match included.
      expect(ranked, isNotEmpty);
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.7: typo match scores lower than exact match
    // -----------------------------------------------------------------------
    test('T-158.7 typo match scores lower than exact match', () {
      final exact = _makeCandidate(
        _makeTx(id: 'a', title: 'Coffee'),
        accountName: '',
        categoryName: '',
      );
      final typo = _makeCandidate(
        _makeTx(id: 'b', title: 'Caffee'), // distance-1 typo of "Coffee"
        accountName: '',
        categoryName: '',
      );
      final ranked = ranker.rank([typo, exact], 'Coffee');
      expect(ranked.first.transaction.id, equals('a'));
    });

    // -----------------------------------------------------------------------
    // T-158.8: tiebreaker — equal score → most recent first
    // -----------------------------------------------------------------------
    test('T-158.8 equal scores sort by dateTime descending', () {
      final older = _makeCandidate(
        _makeTx(id: 'a', title: 'Coffee', dateTime: 1000),
        accountName: '',
        categoryName: '',
      );
      final newer = _makeCandidate(
        _makeTx(id: 'b', title: 'Coffee', dateTime: 2000),
        accountName: '',
        categoryName: '',
      );
      final ranked = ranker.rank([older, newer], 'Coffee');
      expect(ranked.first.transaction.id, equals('b'));
    });

    // -----------------------------------------------------------------------
    // T-158.9: empty input
    // -----------------------------------------------------------------------
    test('T-158.9 empty candidate list returns empty list', () {
      final result = ranker.rank([], 'query');
      expect(result, isEmpty);
    });

    // -----------------------------------------------------------------------
    // T-158.10: no match — returns empty (score=0 entries filtered out)
    // -----------------------------------------------------------------------
    test('T-158.10 no-match candidates are excluded from results', () {
      final tx = _makeCandidate(
        _makeTx(id: 'a', title: 'Groceries'),
        accountName: '',
        categoryName: '',
      );
      // Query that cannot match any field with distance-1
      final result = ranker.rank([tx], 'zzzzz');
      // Score = 0.0 → result is empty (filtered out by ranker)
      expect(result, isEmpty);
    });
  });
}
