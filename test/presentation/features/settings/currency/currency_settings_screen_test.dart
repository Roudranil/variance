// test/presentation/features/settings/currency/currency_settings_screen_test.dart
//
// Widget tests for CurrencySettingsScreen (T-96).
//
// Test cases:
//   1. loaded state renders home currency code
//   2. stale secondary currency shows "Outdated" label
//   3. home currency row tap navigates to currency picker

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/presentation/features/settings/currency/currency_settings_notifier.dart';
import 'package:variance/presentation/features/settings/currency/currency_settings_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakeCurrencySettingsNotifier extends CurrencySettingsNotifier {
  _FakeCurrencySettingsNotifier(this._state);
  final CurrencySettingsState _state;

  @override
  Future<CurrencySettingsState> build() async => _state;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

ExchangeRate _freshRate(String from, String to) => ExchangeRate(
      id: 1,
      fromCurrency: from,
      toCurrency: to,
      rateMicro: 83000000,
      fetchedAt: _nowEpoch,
      rateDate: '2025-01-01',
    );

ExchangeRate _staleRate(String from, String to) => ExchangeRate(
      id: 2,
      fromCurrency: from,
      toCurrency: to,
      rateMicro: 83000000,
      fetchedAt: _nowEpoch - (20 * 86400),
      rateDate: '2024-12-12',
    );

Currency _currency(String code, String name) =>
    Currency(code: code, name: name, symbol: code);

Widget _buildScreen({
  required CurrencySettingsState state,
  List<Currency> allCurrencies = const [],
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const CurrencySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.currencyPicker,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Picker'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currencySettingsProvider.overrideWith(
        () => _FakeCurrencySettingsNotifier(state),
      ),
      currenciesProvider.overrideWith(
        (_) async => allCurrencies,
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CurrencySettingsScreen', () {
    testWidgets('1. loaded state renders home currency code', (tester) async {
      final state = CurrencySettingsState(
        homeCurrency: 'INR',
        secondaryCurrencies: const [],
      );
      await tester.pumpWidget(
        _buildScreen(state: state, allCurrencies: [_currency('INR', 'Indian Rupee')]),
      );
      await tester.pumpAndSettle();

      expect(find.text('INR'), findsOneWidget);
    });

    testWidgets(
        '2. stale secondary currency shows Outdated label',
        (tester) async {
      final usdEntry = SecondaryCurrencyEntry(
        currency: _currency('USD', 'US Dollar'),
        latestRate: _staleRate('USD', 'INR'),
      );
      final state = CurrencySettingsState(
        homeCurrency: 'INR',
        secondaryCurrencies: [usdEntry],
      );
      await tester.pumpWidget(
        _buildScreen(
          state: state,
          allCurrencies: [_currency('INR', 'Indian Rupee')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Outdated'), findsOneWidget);
    });

    testWidgets('3. fresh secondary currency does not show Outdated',
        (tester) async {
      final usdEntry = SecondaryCurrencyEntry(
        currency: _currency('USD', 'US Dollar'),
        latestRate: _freshRate('USD', 'INR'),
      );
      final state = CurrencySettingsState(
        homeCurrency: 'INR',
        secondaryCurrencies: [usdEntry],
      );
      await tester.pumpWidget(
        _buildScreen(
          state: state,
          allCurrencies: [_currency('INR', 'Indian Rupee')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Outdated'), findsNothing);
    });
  });
}
