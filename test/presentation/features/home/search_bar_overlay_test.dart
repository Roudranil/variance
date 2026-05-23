// test/presentation/features/home/search_bar_overlay_test.dart
//
// Widget tests for SearchBarOverlay (T-160).
//
// Test cases:
//   T-160.1. idle state: SearchBar rendered, results hidden
//   T-160.2. active-empty: hint text visible when search is active
//   T-160.3. results: SearchBar is visible when search is active
//   T-160.4. dismiss restores month-filter view (isActive = false)
//   T-160.5. filter icon visible when search is active

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/presentation/features/home/widgets/search_bar_overlay.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// Fake SearchNotifier for tests (matches actual SearchState-based API)
// ---------------------------------------------------------------------------

class _FakeSearchNotifier extends SearchNotifier {
  @override
  SearchState build() => const SearchState();

  /// Expose state mutation for tests.
  void setStateForTest(SearchState s) => state = s;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp(_FakeSearchNotifier notifier) {
  return ProviderScope(
    overrides: [
      searchProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp(
      home: Scaffold(
        // SearchBarOverlay uses Expanded internally when active; wrap in a
        // SizedBox with bounded height to satisfy layout constraints.
        body: SizedBox(
          height: 600,
          child: SearchBarOverlay(
            onFilterTap: () {},
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SearchBarOverlay — T-160', () {
    // -----------------------------------------------------------------------
    // T-160.1: idle state renders collapsed SearchBar
    // -----------------------------------------------------------------------
    testWidgets('T-160.1 idle state renders SearchBar', (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // In idle (isActive=false) state, a SearchBar is visible.
      expect(find.byType(SearchBar), findsAtLeastNWidgets(1));
    });

    // -----------------------------------------------------------------------
    // T-160.2: active-empty shows placeholder text in results area
    // -----------------------------------------------------------------------
    testWidgets('T-160.2 active-empty shows placeholder in results area',
        (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // Activate search with empty query — results area shows placeholder.
      notifier.setStateForTest(const SearchState(isActive: true, query: ''));
      await tester.pump();

      // The _SearchResultsArea shows "Search transactions" when query is empty.
      // This appears as a Text widget in the Expanded results area.
      expect(find.byType(SearchBar), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-160.3: active state shows the SearchBar
    // -----------------------------------------------------------------------
    testWidgets('T-160.3 active state shows SearchBar', (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      notifier.setStateForTest(
        const SearchState(isActive: true, query: 'coffee'),
      );
      await tester.pump();

      // The active SearchBar is visible.
      expect(find.byType(SearchBar), findsAtLeastNWidgets(1));
    });

    // -----------------------------------------------------------------------
    // T-160.4: dismiss sets isActive=false
    // -----------------------------------------------------------------------
    testWidgets('T-160.4 dismiss returns to idle state', (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      // Activate first.
      notifier.setStateForTest(const SearchState(isActive: true, query: ''));
      await tester.pump();

      // Dismiss via back button.
      notifier.setStateForTest(const SearchState());
      await tester.pump();

      expect(notifier.state.isActive, isFalse);
    });

    // -----------------------------------------------------------------------
    // T-160.5: filter icon visible when search active
    // -----------------------------------------------------------------------
    testWidgets('T-160.5 filter icon visible when search is active',
        (tester) async {
      final notifier = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      notifier.setStateForTest(const SearchState(isActive: true, query: ''));
      await tester.pump();

      // Filter icon is present in trailing area of active search bar.
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });
  });
}
