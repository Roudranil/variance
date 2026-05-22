// test/widget/features/home/month_selector_test.dart
//
// Widget tests for MonthSelector (T-151).
//
// Test cases:
//   1. displays current month and year on first render
//   2. tapping left arrow calls changeMonth with previous month
//   3. tapping right arrow calls changeMonth with next month
//   4. navigating backwards from January wraps to previous December

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/presentation/features/home/widgets/month_selector.dart';
import 'package:variance/presentation/providers/home_providers.dart';

// ---------------------------------------------------------------------------
// Controllable fake HomeNotifier
// ---------------------------------------------------------------------------

class _ControllableHomeNotifier extends HomeNotifier {
  _ControllableHomeNotifier(this._initialMonth);

  final DateTime _initialMonth;

  int changeMonthYear = 0;
  int changeMonthMonth = 0;
  int changeMonthCalls = 0;

  @override
  Future<HomeState> build() async => HomeState(
        selectedMonth: _initialMonth,
        netWorthMinor: 0,
        netWorthCurrencyCode: 'INR',
        hasStaleFx: false,
        monthlySummary: const MonthlySummary(
          incomeMinor: 0,
          expensesMinor: 0,
          netMinor: 0,
          currencyCode: 'INR',
          hasStaleFx: false,
        ),
      );

  @override
  Future<void> changeMonth(int year, int month) async {
    changeMonthCalls++;
    changeMonthYear = year;
    changeMonthMonth = month;
    // Update state to simulate reactive change.
    state = AsyncData(
      HomeState(
        selectedMonth: DateTime(year, month),
        netWorthMinor: 0,
        netWorthCurrencyCode: 'INR',
        hasStaleFx: false,
        monthlySummary: const MonthlySummary(
          incomeMinor: 0,
          expensesMinor: 0,
          netMinor: 0,
          currencyCode: 'INR',
          hasStaleFx: false,
        ),
      ),
    );
  }
}

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: Scaffold(body: MonthSelector()),
    ),
  );
}

void main() {
  group('MonthSelector', () {
    testWidgets('displays current month on first render', (tester) async {
      final now = DateTime.now();
      final notifier = _ControllableHomeNotifier(now);

      final container = ProviderContainer(
        overrides: [homeProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      // Month name and year should appear.
      expect(find.byKey(const Key('month_selector_text')), findsOneWidget);
    });

    testWidgets('tapping left arrow calls changeMonth with previous month',
        (tester) async {
      // Start in May 2025.
      final notifier = _ControllableHomeNotifier(DateTime(2025, 5));

      final container = ProviderContainer(
        overrides: [homeProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.byKey(const Key('month_prev_button')));
      await tester.pump();

      expect(notifier.changeMonthCalls, 1);
      expect(notifier.changeMonthYear, 2025);
      expect(notifier.changeMonthMonth, 4); // April
    });

    testWidgets('tapping right arrow calls changeMonth with next month',
        (tester) async {
      final notifier = _ControllableHomeNotifier(DateTime(2025, 5));

      final container = ProviderContainer(
        overrides: [homeProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.byKey(const Key('month_next_button')));
      await tester.pump();

      expect(notifier.changeMonthCalls, 1);
      expect(notifier.changeMonthYear, 2025);
      expect(notifier.changeMonthMonth, 6); // June
    });

    testWidgets('navigating back from January wraps to December of prev year',
        (tester) async {
      final notifier = _ControllableHomeNotifier(DateTime(2025, 1));

      final container = ProviderContainer(
        overrides: [homeProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.byKey(const Key('month_prev_button')));
      await tester.pump();

      expect(notifier.changeMonthYear, 2024);
      expect(notifier.changeMonthMonth, 12);
    });

    testWidgets(
        'navigating forward from December wraps to January of next year',
        (tester) async {
      final notifier = _ControllableHomeNotifier(DateTime(2025, 12));

      final container = ProviderContainer(
        overrides: [homeProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.byKey(const Key('month_next_button')));
      await tester.pump();

      expect(notifier.changeMonthYear, 2026);
      expect(notifier.changeMonthMonth, 1);
    });
  });
}
