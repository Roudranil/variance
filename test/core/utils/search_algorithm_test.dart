import 'package:flutter_test/flutter_test.dart';

import 'package:variance/core/utils/search_algorithm.dart';

/// Tests for [SearchAlgorithmV1] fuzzy search implementation.
void main() {
  group('SearchAlgorithmV1', () {
    // sample data class for testing
    final items = [
      _TestItem('Apple', 'fruit'),
      _TestItem('Banana', 'fruit'),
      _TestItem('Carrot', 'vegetable'),
      _TestItem('Date', 'fruit'),
      _TestItem('Eggplant', 'vegetable'),
    ];

    List<String> getFields(_TestItem item) => [item.name, item.category];

    test('returns all items when query is empty', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: '',
        getSearchableFields: getFields,
      );

      expect(result, items);
    });

    test('returns empty list when no matches found', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'xyz',
        getSearchableFields: getFields,
      );

      expect(result, isEmpty);
    });

    test('finds exact matches with highest priority', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'apple',
        getSearchableFields: getFields,
      );

      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('finds partial matches (contains)', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'an',
        getSearchableFields: getFields,
      );

      // 'banana' and 'eggplant' contain 'an'
      expect(result.length, 2);
      expect(result.map((i) => i.name), containsAll(['Banana', 'Eggplant']));
    });

    test('prioritizes starts-with over contains', () {
      // 'date' starts with 'da', 'banana' contains 'a' but not 'da'
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'da',
        getSearchableFields: getFields,
      );

      expect(result.first.name, 'Date');
    });

    test('searches across multiple fields', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'fruit',
        getSearchableFields: getFields,
      );

      expect(result.length, 3); // apple, banana, date are fruits
    });

    test('is case insensitive', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: items,
        query: 'APPLE',
        getSearchableFields: getFields,
      );

      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('handles empty items list', () {
      final result = SearchAlgorithmV1.search<_TestItem>(
        items: [],
        query: 'test',
        getSearchableFields: getFields,
      );

      expect(result, isEmpty);
    });
  });
}

/// Test data class for search tests.
class _TestItem {
  final String name;
  final String category;

  _TestItem(this.name, this.category);
}
