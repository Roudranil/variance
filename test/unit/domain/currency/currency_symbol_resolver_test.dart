// test/unit/domain/currency/currency_symbol_resolver_test.dart
//
// Unit tests for CurrencySymbolResolver (T-90).
//
// Test cases:
//   1. single currency — label equals bare symbol
//   2. two currencies sharing a symbol — both receive ISO-suffixed labels
//   3. three currencies where only two share a symbol — only colliding pair suffixed
//   4. empty input — returns empty map
//   5. currencies with unique symbols — all bare symbols preserved
//   6. all three share a symbol — all three get ISO-suffixed labels

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/currency/currency_symbol_resolver.dart';
import 'package:variance/domain/entities/currency.dart';

void main() {
  const resolver = CurrencySymbolResolver();

  // Helper to build a Currency stub.
  Currency curr(String code, String symbol) =>
      Currency(code: code, name: '$code Currency', symbol: symbol);

  // -------------------------------------------------------------------------
  // Test 1: single currency → bare symbol
  // -------------------------------------------------------------------------
  test('single currency — label equals bare symbol', () {
    final result = resolver.resolve([curr('INR', '₹')]);
    expect(result, {'INR': '₹'});
  });

  // -------------------------------------------------------------------------
  // Test 2: two currencies sharing a symbol → ISO-suffixed labels
  // -------------------------------------------------------------------------
  test(
    'two currencies sharing symbol — both receive ISO-suffixed labels',
    () {
      final result = resolver.resolve([
        curr('USD', r'$'),
        curr('CAD', r'$'),
      ]);
      expect(result, {
        'USD': r'$USD',
        'CAD': r'$CAD',
      });
    },
  );

  // -------------------------------------------------------------------------
  // Test 3: three currencies where only two share a symbol
  // -------------------------------------------------------------------------
  test(
    'only colliding pair suffixed — non-colliding currency keeps bare symbol',
    () {
      final result = resolver.resolve([
        curr('USD', r'$'),
        curr('CAD', r'$'),
        curr('INR', '₹'),
      ]);
      expect(result, {
        'USD': r'$USD',
        'CAD': r'$CAD',
        'INR': '₹',
      });
    },
  );

  // -------------------------------------------------------------------------
  // Test 4: empty input → empty map
  // -------------------------------------------------------------------------
  test('empty input — returns empty map', () {
    final result = resolver.resolve([]);
    expect(result, isEmpty);
  });

  // -------------------------------------------------------------------------
  // Test 5: unique symbols — all bare symbols preserved
  // -------------------------------------------------------------------------
  test('unique symbols — all labels are bare symbols', () {
    final result = resolver.resolve([
      curr('INR', '₹'),
      curr('EUR', '€'),
      curr('GBP', '£'),
    ]);
    expect(result, {
      'INR': '₹',
      'EUR': '€',
      'GBP': '£',
    });
  });

  // -------------------------------------------------------------------------
  // Test 6: all three share a symbol → all ISO-suffixed
  // -------------------------------------------------------------------------
  test('all three share symbol — all receive ISO-suffixed labels', () {
    final result = resolver.resolve([
      curr('USD', r'$'),
      curr('CAD', r'$'),
      curr('AUD', r'$'),
    ]);
    expect(result, {
      'USD': r'$USD',
      'CAD': r'$CAD',
      'AUD': r'$AUD',
    });
  });
}
