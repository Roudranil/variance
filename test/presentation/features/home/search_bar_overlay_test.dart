// test/presentation/features/home/search_bar_overlay_test.dart
//
// Widget tests for SearchBarOverlay (T-58).
//
// Test cases:
//   1. renders SearchBar in collapsed state
//   2. empty text shows hint after opening view
//   3. loading state while typing shows loading tile
//   4. data state with results shows transaction tiles when query is present
//   5. error state shows error tile when query is present

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/home/widgets/search_bar_overlay.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// Fake SearchNotifier for tests
// ---------------------------------------------------------------------------

class _FakeSearchNotifier extends SearchNotifier {
  @override
  AsyncValue<List<Transaction>> build() => const AsyncValue.data([]);

  @override
  void setQuery(String query) {
    // No-op — state is controlled via setStateForTest in tests.
  }

  @override
  void clear() {
    state = const AsyncValue.data([]);
  }

  /// Expose state mutation for tests.
  void setStateForTest(AsyncValue<List<Transaction>> s) => state = s;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Transaction _makeTx(String id, String title) => Transaction(
      id: id,
      type: TransactionType.expense,
      status: TransactionStatus.posted,
      dateTime: 1748000000,
      amountMinor: 1500,
      currencyCode: 'INR',
      title: title,
      createdAt: 0,
      updatedAt: 0,
    );

Widget _buildApp(_FakeSearchNotifier notifier) {
  return ProviderScope(
    overrides: [
      searchProvider.overrideWith(() => notifier),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [SearchBarOverlay()],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SearchBarOverlay', () {
    testWidgets('1. renders SearchBar in collapsed state', (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets('2. empty text shows hint after opening view', (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // Open the search view by tapping the bar.
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      // With empty text, hint is shown.
      expect(find.text('Type to search transactions'), findsOneWidget);
    });

    testWidgets('3. loading state while typing shows loading tile',
        (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // Open the search view.
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      // Type a character so the controller text is non-empty.
      // After opening the view, the text field inside the SearchView is active.
      await tester.enterText(find.byType(TextField).last, 'a');
      // Set provider to loading — simulates the debounce firing.
      notifier.setStateForTest(const AsyncValue.loading());
      await tester.pump();

      expect(find.text('Searching…'), findsOneWidget);
    });

    testWidgets('4. data state with results shows transaction tiles',
        (tester) async {
      final notifier = _FakeSearchNotifier();
      final txns = [_makeTx('t1', 'Coffee'), _makeTx('t2', 'Groceries')];

      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // Open search view and type to make the query non-empty.
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'cof');
      notifier.setStateForTest(AsyncValue.data(txns));
      await tester.pump();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('5. error state shows error tile when query is present',
        (tester) async {
      final notifier = _FakeSearchNotifier();

      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'err');
      notifier.setStateForTest(
        AsyncValue.error('Search failed', StackTrace.empty),
      );
      await tester.pump();

      expect(find.text('Search failed'), findsOneWidget);
    });
  });
}
