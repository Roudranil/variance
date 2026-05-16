// test/presentation/features/settings/currency/currency_picker_screen_test.dart
//
// Widget tests for CurrencyPickerScreen (T-97).
//
// Test cases:
//   1. populated state — list of currencies visible
//   2. search field filters list by name/code/symbol
//   3. popular currencies pinned at top of the list
//   4. current selection shows checkmark icon

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/presentation/features/settings/currency/currency_picker_screen.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Currency _c(String code, String name, String symbol) =>
    Currency(code: code, name: name, symbol: symbol);

Widget _buildPicker({
  required List<Currency> currencies,
  String? currentCode,
}) {
  return ProviderScope(
    overrides: [
      currenciesProvider.overrideWith((_) async => currencies),
    ],
    child: MaterialApp(
      home: CurrencyPickerScreen(currentCode: currentCode),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CurrencyPickerScreen', () {
    final currencies = [
      _c('INR', 'Indian Rupee', '₹'),
      _c('USD', 'US Dollar', r'$'),
      _c('EUR', 'Euro', '€'),
      _c('GBP', 'British Pound', '£'),
      _c('JPY', 'Japanese Yen', '¥'),
      _c('CHF', 'Swiss Franc', 'CHF'),
      _c('AUD', 'Australian Dollar', r'$'),
    ];

    testWidgets('1. populated state — list of currencies visible',
        (tester) async {
      await tester.pumpWidget(_buildPicker(currencies: currencies));
      await tester.pumpAndSettle();

      // At least the popular currencies should be visible.
      expect(find.text('INR'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('2. search field filters list by name', (tester) async {
      await tester.pumpWidget(_buildPicker(currencies: currencies));
      await tester.pumpAndSettle();

      // Type 'Swiss' into the search field.
      await tester.enterText(find.byType(TextField), 'Swiss');
      await tester.pumpAndSettle();

      // CHF appears at least once (as code; symbol = 'CHF' so may appear twice).
      expect(find.text('CHF'), findsWidgets);
      // INR should be filtered out.
      expect(find.text('INR'), findsNothing);
    });

    testWidgets('3. popular currencies pinned at top before remainder',
        (tester) async {
      await tester.pumpWidget(_buildPicker(currencies: currencies));
      await tester.pumpAndSettle();

      // INR is popular; CHF is remainder. Both should appear.
      // Use findsWidgets since CHF is also used as symbol text in the tile.
      expect(find.text('CHF'), findsWidgets);

      // Verify INR (popular) is above Swiss Franc (CHF) in the list by
      // checking the tile subtitle 'Indian Rupee' appears above 'Swiss Franc'.
      final inrOffset = tester.getTopLeft(find.text('Indian Rupee')).dy;
      final chfOffset = tester.getTopLeft(find.text('Swiss Franc')).dy;
      expect(inrOffset, lessThan(chfOffset));
    });

    testWidgets('4. current selection shows checkmark icon', (tester) async {
      await tester.pumpWidget(
        _buildPicker(currencies: currencies, currentCode: 'EUR'),
      );
      await tester.pumpAndSettle();

      // A check icon should be visible (for the selected EUR row).
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('5. no results state shows appropriate message',
        (tester) async {
      await tester.pumpWidget(_buildPicker(currencies: currencies));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ZZZNOTFOUND');
      await tester.pumpAndSettle();

      expect(find.textContaining('No currencies match'), findsOneWidget);
    });
  });
}
