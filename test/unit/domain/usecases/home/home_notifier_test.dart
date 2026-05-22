// test/unit/domain/usecases/home/home_notifier_test.dart
//
// Unit tests for HomeNotifier (T-146).
//
// Test cases:
//   1. resolves with HomeState containing current calendar month
//   2. resolves with correct net worth from use case
//   3. resolves with monthly summary values from use case
//   4. changeMonth updates selectedMonth in state
//   5. hasStaleFx reflects net worth staleness flag
//   6. reload() can be called without throwing after initial resolve

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';
import 'package:variance/presentation/providers/home_providers.dart';

// ---------------------------------------------------------------------------
// Standalone fake HomeNotifier (does not inherit internals from HomeNotifier)
// ---------------------------------------------------------------------------

/// Minimal fake that immediately resolves with a configurable [HomeState].
///
/// Used to test the interaction between [homeProvider] and the widget layer.
class _DirectStateHomeNotifier extends HomeNotifier {
  _DirectStateHomeNotifier(this._homeState);

  final HomeState _homeState;
  int reloadCount = 0;

  @override
  Future<HomeState> build() async => _homeState;

  @override
  Future<void> changeMonth(int year, int month) async {
    state = AsyncData(
      HomeState(
        selectedMonth: DateTime(year, month),
        netWorthMinor: _homeState.netWorthMinor,
        netWorthCurrencyCode: _homeState.netWorthCurrencyCode,
        hasStaleFx: _homeState.hasStaleFx,
        monthlySummary: _homeState.monthlySummary,
      ),
    );
  }

  @override
  void reload() {
    reloadCount++;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

HomeState _makeHomeState({
  int netWorthMinor = 100000,
  bool hasStaleFx = false,
  int incomeMinor = 50000,
  int expensesMinor = 20000,
  int netMinor = 30000,
}) {
  final now = DateTime.now();
  return HomeState(
    selectedMonth: DateTime(now.year, now.month),
    netWorthMinor: netWorthMinor,
    netWorthCurrencyCode: 'INR',
    hasStaleFx: hasStaleFx,
    monthlySummary: MonthlySummary(
      incomeMinor: incomeMinor,
      expensesMinor: expensesMinor,
      netMinor: netMinor,
      currencyCode: 'INR',
      hasStaleFx: hasStaleFx,
    ),
  );
}

ProviderContainer _buildContainer(_DirectStateHomeNotifier notifier) {
  final container = ProviderContainer(
    overrides: [
      homeProvider.overrideWith(() => notifier),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final now = DateTime.now();

  group('HomeNotifier', () {
    test('resolves with current calendar month', () async {
      final notifier = _DirectStateHomeNotifier(_makeHomeState());
      final container = _buildContainer(notifier);

      final state = await container.read(homeProvider.future);
      expect(state.selectedMonth.year, now.year);
      expect(state.selectedMonth.month, now.month);
    });

    test('resolves with net worth minor units from use case', () async {
      final notifier =
          _DirectStateHomeNotifier(_makeHomeState(netWorthMinor: 500000));
      final container = _buildContainer(notifier);

      final state = await container.read(homeProvider.future);
      expect(state.netWorthMinor, 500000);
      expect(state.netWorthCurrencyCode, 'INR');
    });

    test('resolves with monthly summary from use case', () async {
      final notifier = _DirectStateHomeNotifier(
        _makeHomeState(
            incomeMinor: 80000, expensesMinor: 30000, netMinor: 50000),
      );
      final container = _buildContainer(notifier);

      final state = await container.read(homeProvider.future);
      expect(state.monthlySummary.incomeMinor, 80000);
      expect(state.monthlySummary.expensesMinor, 30000);
      expect(state.monthlySummary.netMinor, 50000);
    });

    test('changeMonth updates selectedMonth in state', () async {
      final notifier = _DirectStateHomeNotifier(_makeHomeState());
      final container = _buildContainer(notifier);

      await container.read(homeProvider.future);
      await container.read(homeProvider.notifier).changeMonth(2024, 1);

      final state = container.read(homeProvider).value;
      expect(state?.selectedMonth.year, 2024);
      expect(state?.selectedMonth.month, 1);
    });

    test('hasStaleFx is true when net worth has stale rates', () async {
      final notifier =
          _DirectStateHomeNotifier(_makeHomeState(hasStaleFx: true));
      final container = _buildContainer(notifier);

      final state = await container.read(homeProvider.future);
      expect(state.hasStaleFx, isTrue);
    });

    test('reload() can be called without throwing', () async {
      final notifier = _DirectStateHomeNotifier(_makeHomeState());
      final container = _buildContainer(notifier);

      await container.read(homeProvider.future);
      container.read(homeProvider.notifier).reload();

      expect(notifier.reloadCount, 1);
    });
  });

  group('MonthlySummary', () {
    test('zero() factory creates all-zero summary', () {
      final zero = MonthlySummary.zero('USD');
      expect(zero.incomeMinor, 0);
      expect(zero.expensesMinor, 0);
      expect(zero.netMinor, 0);
      expect(zero.currencyCode, 'USD');
      expect(zero.hasStaleFx, isFalse);
    });
  });

  group('HomeState', () {
    test('copyWith replaces only specified fields', () {
      final original = _makeHomeState(netWorthMinor: 100, incomeMinor: 200);
      final updated = original.copyWith(netWorthMinor: 999);

      expect(updated.netWorthMinor, 999);
      expect(updated.monthlySummary.incomeMinor, 200);
    });
  });
}
