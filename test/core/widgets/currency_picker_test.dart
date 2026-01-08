import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/core/widgets/currency_picker.dart';

void main() {
  group('CurrencyPickerSheet', () {
    testWidgets('renders all 9 supported currencies', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => CurrencyPickerSheet.show(context, 'USD'),
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      // Open the picker
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Select Currency'), findsOneWidget);

      // Verify all 9 currencies are present
      for (final currency in CurrencyData.supported) {
        expect(find.text(currency.code), findsOneWidget);
        // Symbols replaced by icons. Verify Icon widget exists.
        // Multiple currencies share icons (e.g. attach_money), so we use findsWidgets
        expect(find.byIcon(currency.icon), findsWidgets);
        expect(find.text(currency.name), findsOneWidget);
      }
    });

    testWidgets('populates initially selected currency', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CurrencyPickerSheet(selectedCode: 'INR')),
        ),
      );

      expect(find.text('INR'), findsOneWidget);
      expect(find.text('Indian Rupee'), findsOneWidget);
      expect(find.byIcon(Icons.currency_rupee), findsOneWidget);
    });

    testWidgets('returns selected currency code on tap', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await CurrencyPickerSheet.show(context, 'USD');
                  },
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      // Open picker
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Tap EUR
      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();

      // Verify result
      expect(result, 'EUR');
    });

    testWidgets('uses provided color scheme', (tester) async {
      const customScheme = ColorScheme.light(primary: Colors.red);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => CurrencyPickerSheet.show(
                    context,
                    'USD',
                    colorScheme: customScheme,
                  ),
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify header shows up (verification that custom scheme didn't crash)
      expect(find.text('Select Currency'), findsOneWidget);
    });
  });

  group('CurrencyData', () {
    test('byCode returns correct data', () {
      final usd = CurrencyData.byCode('USD');
      expect(usd?.code, 'USD');
      expect(usd?.name, 'US Dollar');
      expect(usd?.icon, Icons.attach_money);
    });

    test('byCode returns null for invalid code', () {
      expect(CurrencyData.byCode('XYZ'), null);
    });
  });
}
