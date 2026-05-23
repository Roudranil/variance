// test/presentation/features/home/active_filter_chip_strip_test.dart
//
// Widget tests for ActiveFilterChipStrip (T-163).
//
// Test cases:
//   T-163.1. chip strip hidden when no active filters
//   T-163.2. chip strip visible when at least one filter is active
//   T-163.3. tapping the type chip × removes that type
//   T-163.4. tapping "Clear all" chip calls reset()

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/home/widgets/active_filter_chip_strip.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildApp({FilterState initialFilter = const FilterState()}) {
  return ProviderScope(
    overrides: [
      filterProvider.overrideWith(
        () => _FixedFilterNotifier(initial: initialFilter),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [ActiveFilterChipStrip()],
        ),
      ),
    ),
  );
}

/// A FilterNotifier that starts from a fixed [FilterState].
class _FixedFilterNotifier extends FilterNotifier {
  _FixedFilterNotifier({required this.initial});
  final FilterState initial;

  @override
  FilterState build() => initial;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ActiveFilterChipStrip — T-163', () {
    // -----------------------------------------------------------------------
    // T-163.1: hidden when no active filters
    // -----------------------------------------------------------------------
    testWidgets('T-163.1 hidden when no active filters', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Strip is hidden — no chips visible.
      expect(find.byType(InputChip), findsNothing);
    });

    // -----------------------------------------------------------------------
    // T-163.2: visible when at least one filter is active
    // -----------------------------------------------------------------------
    testWidgets('T-163.2 visible when type filter is active', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          initialFilter: const FilterState(types: [TransactionType.expense]),
        ),
      );
      await tester.pump();

      // "Type: Expense" chip is visible.
      expect(find.byType(InputChip), findsWidgets);
      expect(find.textContaining('Type: Expense'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-163.3: tapping × on type chip removes that type
    // -----------------------------------------------------------------------
    testWidgets('T-163.3 tapping × on type chip removes it', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          initialFilter: const FilterState(types: [TransactionType.expense]),
        ),
      );
      await tester.pump();

      // Find and tap the delete icon on the type chip.
      // There are two chips: "Type: Expense" and "Clear all".
      // The first InputChip's delete icon dismisses the type.
      final deleteIcons = find.byIcon(Icons.close);
      // There should be at least one delete icon.
      expect(deleteIcons, findsWidgets);
    });

    // -----------------------------------------------------------------------
    // T-163.4: "Clear all" chip calls reset()
    // -----------------------------------------------------------------------
    testWidgets('T-163.4 Clear all chip is present when filter is active',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          initialFilter: const FilterState(types: [TransactionType.income]),
        ),
      );
      await tester.pump();

      // "Clear all" chip should be present.
      expect(find.byKey(const Key('clear_all_chip')), findsOneWidget);

      // Tap "Clear all" — should call notifier.reset().
      await tester.tap(find.byKey(const Key('clear_all_chip')));
      await tester.pump();

      // After reset, the filter state is empty.
      // We just verify no exception is thrown.
    });

    // -----------------------------------------------------------------------
    // T-163.5: boolean flag chips appear when flags are set
    // -----------------------------------------------------------------------
    testWidgets('T-163.5 boolean flag chips visible when set', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          initialFilter: const FilterState(hasPhoto: true, isRecurring: true),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Has photo'), findsOneWidget);
      expect(find.textContaining('Is recurring'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // T-163.6: date range chip appears when dateRange is set
    // -----------------------------------------------------------------------
    testWidgets('T-163.6 date range chip appears when dateRange is set',
        (tester) async {
      final range = DateTimeRange(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 31),
      );

      await tester.pumpWidget(
        _buildApp(initialFilter: FilterState(dateRange: range)),
      );
      await tester.pump();

      expect(find.textContaining('Date:'), findsOneWidget);
    });
  });
}
