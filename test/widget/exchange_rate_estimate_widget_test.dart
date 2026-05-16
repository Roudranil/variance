// test/widget/exchange_rate_estimate_widget_test.dart
//
// Widget tests for ExchangeRateEstimateWidget (T-94).
//
// Test cases:
//   1. same currency → renders nothing (SizedBox.shrink)
//   2. exchangeRate null → renders "Exchange rate unavailable." note
//   3. rate stale → renders estimate amount + "Rate may be outdated" warning
//   4. rate fresh → renders estimate amount without warning text

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/presentation/widgets/exchange_rate_estimate_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// Builds a fresh exchange rate (USD → INR, rate = 83.0).
ExchangeRate _freshRate() => ExchangeRate(
      id: 1,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      fetchedAt: _nowEpoch,
      rateDate: '2025-01-01',
    );

/// Builds a stale exchange rate (fetchedAt 20 days ago).
ExchangeRate _staleRate() => ExchangeRate(
      id: 2,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      fetchedAt: _nowEpoch - (20 * 86400),
      rateDate: '2024-12-12',
    );

/// Wraps widget in a minimal MaterialApp for theming.
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ExchangeRateEstimateWidget', () {
    testWidgets('1. same currency → renders nothing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ExchangeRateEstimateWidget(
            fromCurrency: 'INR',
            toCurrency: 'INR',
            amount: 1000.0,
          ),
        ),
      );

      // Only a SizedBox.shrink is rendered; no text content.
      expect(find.text('Exchange rate unavailable.'), findsNothing);
      expect(find.text('Rate may be outdated'), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('2. exchangeRate null → renders unavailable note',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ExchangeRateEstimateWidget(
            fromCurrency: 'USD',
            toCurrency: 'INR',
            amount: 100.0,
            exchangeRate: null,
          ),
        ),
      );

      expect(find.text('Exchange rate unavailable.'), findsOneWidget);
      expect(find.text('Rate may be outdated'), findsNothing);
    });

    testWidgets('3. rate stale → renders estimate + staleness warning',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExchangeRateEstimateWidget(
            fromCurrency: 'USD',
            toCurrency: 'INR',
            amount: 100.0,
            exchangeRate: _staleRate(),
          ),
        ),
      );

      // Estimate: 100 * 83.0 = 8300.00
      expect(find.textContaining('≈ INR 8300'), findsOneWidget);
      // Staleness warning must appear.
      expect(find.text('Rate may be outdated'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('4. rate fresh → renders estimate without staleness warning',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExchangeRateEstimateWidget(
            fromCurrency: 'USD',
            toCurrency: 'INR',
            amount: 100.0,
            exchangeRate: _freshRate(),
          ),
        ),
      );

      // Estimate: 100 * 83.0 = 8300.00
      expect(find.textContaining('≈ INR 8300'), findsOneWidget);
      // No staleness warning.
      expect(find.text('Rate may be outdated'), findsNothing);
    });
  });
}
