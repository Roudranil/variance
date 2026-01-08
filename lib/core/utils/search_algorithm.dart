/// A simple fuzzy search algorithm for filtering lists.
///
/// This V1 implementation performs case-insensitive substring matching across
/// multiple fields. Results are scored by match quality:
/// - Exact match: highest score
/// - Starts with query: medium score
/// - Contains query: lowest score
class SearchAlgorithmV1 {
  /// Searches a list of items using the given query.
  ///
  /// Parameters:
  /// - [items]: The list of items to search.
  /// - [query]: The search query string.
  /// - [getSearchableFields]: A function that extracts searchable text from an item.
  ///
  /// Returns a list of items that match the query, sorted by relevance.
  static List<T> search<T>({
    required List<T> items,
    required String query,
    required List<String> Function(T item) getSearchableFields,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    final scored = <_ScoredItem<T>>[];

    for (final item in items) {
      final fields = getSearchableFields(item);
      var bestScore = 0;

      for (final field in fields) {
        final lowerField = field.toLowerCase();
        final score = _scoreMatch(lowerField, lowerQuery);
        if (score > bestScore) {
          bestScore = score;
        }
      }

      if (bestScore > 0) {
        scored.add(_ScoredItem(item, bestScore));
      }
    }

    // sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.item).toList();
  }

  /// Scores a match between a field and query.
  ///
  /// Returns:
  /// - 100 for exact match
  /// - 75 for starts with
  /// - 50 for contains
  /// - 0 for no match
  static int _scoreMatch(String field, String query) {
    if (field == query) return 100;
    if (field.startsWith(query)) return 75;
    if (field.contains(query)) return 50;
    return 0;
  }
}

/// Internal class to hold an item with its search score.
class _ScoredItem<T> {
  final T item;
  final int score;

  _ScoredItem(this.item, this.score);
}
