// test/presentation/features/home/filter_bottom_sheet_test.dart
//
// Widget tests for FilterBottomSheet (T-162).
//
// Test cases:
//   T-162.1. renders "Filters" header
//   T-162.2. type chips show Expense/Income/Transfer
//   T-162.3. Apply button is present
//   T-162.4. Reset button is present

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/presentation/features/home/widgets/filter_bottom_sheet.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        // Render FilterBottomSheet directly (not as a modal) for testability.
        body: SizedBox(
          height: 800,
          child: FilterBottomSheet(),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FilterBottomSheet — T-162', () {
    // -----------------------------------------------------------------------
    // T-162.1: renders "Filters" header
    // -----------------------------------------------------------------------
    testWidgets('T-162.1 renders Filters header', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.text('Filters'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-162.2: type chips
    // -----------------------------------------------------------------------
    testWidgets('T-162.2 type chips show Expense/Income/Transfer',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-162.3: Apply button present
    // -----------------------------------------------------------------------
    testWidgets('T-162.3 Apply button is present', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byKey(const Key('filter_sheet_apply')), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-162.4: Reset button present
    // -----------------------------------------------------------------------
    testWidgets('T-162.4 Reset button is present', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byKey(const Key('filter_sheet_reset')), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-162.5: Apply and Reset buttons are interactive
    // -----------------------------------------------------------------------
    testWidgets('T-162.5 Apply and Reset buttons are tappable', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Both action buttons are present and tappable (no exception on tap).
      await tester.tap(find.byKey(const Key('filter_sheet_reset')));
      await tester.pump();

      // Apply should also be tappable.
      await tester.tap(find.byKey(const Key('filter_sheet_apply')));
      // Navigator.maybePop is called — no GoRouter, so this is a no-op.
      await tester.pump();
    });
  });
}
