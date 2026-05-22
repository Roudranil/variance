// test/presentation/features/transactions/filter_sheet_test.dart
//
// Widget tests for FilterSheet and FilterNotifier (T-59).
//
// Test cases:
//   1. FilterState is initially empty (no filters active)
//   2. FilterNotifier.setTypes updates types list
//   3. FilterNotifier.setAccountIds updates account list
//   4. FilterNotifier.setCategoryIds updates category list
//   5. FilterNotifier.clear resets all fields
//   6. FilterNotifier.setDateRange updates date range
//   7. FilterNotifier.setAmountRange updates amount range
//   8. hasActiveFilters returns false when all fields are empty
//   9. hasActiveFilters returns true when any field is set
//  10. FilterSheet renders date range, account, category, type chips

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/transactions/filter_sheet.dart';
import 'package:variance/presentation/providers/filter_providers.dart';

// ---------------------------------------------------------------------------
// Helper widget
// ---------------------------------------------------------------------------

Widget _buildApp({WidgetRef? externalRef}) {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox.shrink(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FilterState', () {
    test('1. FilterState is initially empty', () {
      const state = FilterState();
      expect(state.types, isEmpty);
      expect(state.accountIds, isEmpty);
      expect(state.categoryIds, isEmpty);
      expect(state.dateRange, isNull);
      expect(state.minAmountMinor, isNull);
      expect(state.maxAmountMinor, isNull);
    });

    test('8. hasActiveFilters returns false when all fields are empty', () {
      const state = FilterState();
      expect(state.hasActiveFilters, isFalse);
    });

    test('9. hasActiveFilters returns true when types are set', () {
      const state = FilterState(types: [TransactionType.expense]);
      expect(state.hasActiveFilters, isTrue);
    });

    test('9b. hasActiveFilters returns true when accountIds are set', () {
      const state = FilterState(accountIds: ['acc-1']);
      expect(state.hasActiveFilters, isTrue);
    });

    test('9c. hasActiveFilters returns true when dateRange is set', () {
      final dr = DateTimeRange(
        start: DateTime(2025),
        end: DateTime(2025, 2),
      );
      final state = FilterState(dateRange: dr);
      expect(state.hasActiveFilters, isTrue);
    });
  });

  group('FilterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is empty FilterState', () {
      final state = container.read(filterProvider);
      expect(state.types, isEmpty);
      expect(state.accountIds, isEmpty);
    });

    test('2. setTypes updates types', () {
      container.read(filterProvider.notifier).setTypes(
        [TransactionType.expense, TransactionType.income],
      );
      final state = container.read(filterProvider);
      expect(state.types, containsAll([TransactionType.expense, TransactionType.income]));
    });

    test('3. setAccountIds updates accountIds', () {
      container.read(filterProvider.notifier).setAccountIds(['acc-1', 'acc-2']);
      final state = container.read(filterProvider);
      expect(state.accountIds, containsAll(['acc-1', 'acc-2']));
    });

    test('4. setCategoryIds updates categoryIds', () {
      container.read(filterProvider.notifier).setCategoryIds(['cat-1']);
      final state = container.read(filterProvider);
      expect(state.categoryIds, contains('cat-1'));
    });

    test('5. clear resets all fields', () {
      container.read(filterProvider.notifier)
        ..setTypes([TransactionType.expense])
        ..setAccountIds(['acc-1'])
        ..setCategoryIds(['cat-1'])
        ..clear();

      final state = container.read(filterProvider);
      expect(state.types, isEmpty);
      expect(state.accountIds, isEmpty);
      expect(state.categoryIds, isEmpty);
      expect(state.hasActiveFilters, isFalse);
    });

    test('6. setDateRange updates dateRange', () {
      final range = DateTimeRange(
        start: DateTime(2025),
        end: DateTime(2025, 6),
      );
      container.read(filterProvider.notifier).setDateRange(range);
      final state = container.read(filterProvider);
      expect(state.dateRange, equals(range));
    });

    test('7. setAmountRange updates amount range', () {
      container.read(filterProvider.notifier).setAmountRange(
        minMinor: 5000,
        maxMinor: 50000,
      );
      final state = container.read(filterProvider);
      expect(state.minAmountMinor, equals(5000));
      expect(state.maxAmountMinor, equals(50000));
    });
  });

  group('FilterSheet widget', () {
    testWidgets('10. renders filter sections', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterSheet(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Filter sheet has a title.
      expect(find.text('Filter Transactions'), findsOneWidget);
      // Type chips section header.
      expect(find.text('Transaction Type'), findsOneWidget);
      // Clear button.
      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('type chips render expense/income/transfer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterSheet(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });
  });
}
