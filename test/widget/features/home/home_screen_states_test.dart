// test/widget/features/home/home_screen_states_test.dart
//
// Widget tests for HomeScreen skeleton, error, and FX banner states (T-152).
//
// Test cases:
//   1. loading state shows skeleton shimmer (greeting + 4 card + 6 row placeholders)
//   2. error state shows ErrorCard with retry button
//   3. retry button calls homeNotifier.reload()
//   4. stale FX banner shown when hasStaleFx = true
//   5. stale FX banner can be dismissed (local session state)
//   6. no-FX-rate state: net worth card shows "—" disclaimer
//   7. future month shows "Projected" label

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/presentation/features/home/widgets/home_screen_body.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/home_providers.dart';

// ---------------------------------------------------------------------------
// Fake AppSettingsNotifier
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}

// ---------------------------------------------------------------------------
// Fake HomeNotifiers
// ---------------------------------------------------------------------------

class _LoadingHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() => Completer<HomeState>().future;
}

class _ErrorHomeNotifier extends HomeNotifier {
  int reloadCalls = 0;

  @override
  Future<HomeState> build() {
    state = AsyncError<HomeState>(Exception('db error'), StackTrace.empty);
    return Completer<HomeState>().future;
  }

  @override
  void reload() {
    reloadCalls++;
  }
}

class _StaleFxHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => HomeState(
        selectedMonth: DateTime.now(),
        netWorthMinor: 100000,
        netWorthCurrencyCode: 'INR',
        hasStaleFx: true,
        monthlySummary: const MonthlySummary(
          incomeMinor: 0,
          expensesMinor: 0,
          netMinor: 0,
          currencyCode: 'INR',
          hasStaleFx: true,
        ),
      );
}

class _NoFxRateHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => HomeState(
        selectedMonth: DateTime.now(),
        netWorthMinor: 0,
        netWorthCurrencyCode: 'INR',
        hasStaleFx: false,
        hasNoFxRate: true,
        monthlySummary: const MonthlySummary(
          incomeMinor: 0,
          expensesMinor: 0,
          netMinor: 0,
          currencyCode: 'INR',
          hasStaleFx: false,
        ),
      );
}

class _FutureMonthHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async {
    final future = DateTime.now().add(const Duration(days: 40));
    return HomeState(
      selectedMonth: DateTime(future.year, future.month),
      netWorthMinor: 0,
      netWorthCurrencyCode: 'INR',
      hasStaleFx: false,
      isFutureMonth: true,
      monthlySummary: const MonthlySummary(
        incomeMinor: 0,
        expensesMinor: 0,
        netMinor: 0,
        currencyCode: 'INR',
        hasStaleFx: false,
      ),
    );
  }
}

ProviderContainer _buildContainer(HomeNotifier Function() notifierFactory) {
  final container = ProviderContainer(
    overrides: [
      homeProvider.overrideWith(notifierFactory),
      appSettingsProvider.overrideWith(_FakeAppSettingsNotifier.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: Scaffold(body: HomeScreenBody()),
    ),
  );
}

void main() {
  group('HomeScreen states', () {
    testWidgets('loading state shows skeleton placeholders', (tester) async {
      final container = _buildContainer(_LoadingHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      // Skeleton greeting line should be visible.
      expect(find.byKey(const Key('skeleton_greeting')), findsOneWidget);
      // 4 card skeleton placeholders (unique ValueKey per card).
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(ValueKey('skeleton_card_$i')), findsOneWidget);
      }
      // 6 row placeholders (unique ValueKey per row).
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('skeleton_row_$i')), findsOneWidget);
      }
    });

    testWidgets('error state shows ErrorCard with retry button',
        (tester) async {
      final container = _buildContainer(_ErrorHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byKey(const Key('home_error_card')), findsOneWidget);
      expect(find.byKey(const Key('home_retry_button')), findsOneWidget);
    });

    testWidgets('retry button calls homeNotifier.reload()', (tester) async {
      final notifier = _ErrorHomeNotifier();
      final container = _buildContainer(() => notifier);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.byKey(const Key('home_retry_button')));
      await tester.pump();

      expect(notifier.reloadCalls, 1);
    });

    testWidgets('stale FX banner is shown when hasStaleFx is true',
        (tester) async {
      final container = _buildContainer(_StaleFxHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byKey(const Key('stale_fx_banner')), findsOneWidget);
    });

    testWidgets('stale FX banner can be dismissed', (tester) async {
      final container = _buildContainer(_StaleFxHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      // Dismiss the banner.
      await tester.tap(find.byKey(const Key('stale_fx_dismiss')));
      await tester.pump();

      expect(find.byKey(const Key('stale_fx_banner')), findsNothing);
    });

    testWidgets('no-FX-rate state shows "—" in net worth card', (tester) async {
      final container = _buildContainer(_NoFxRateHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byKey(const Key('no_fx_rate_disclaimer')), findsOneWidget);
    });

    testWidgets('future month shows "Projected" label', (tester) async {
      final container = _buildContainer(_FutureMonthHomeNotifier.new);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Projected'), findsOneWidget);
    });
  });
}
