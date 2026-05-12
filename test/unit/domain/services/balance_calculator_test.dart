// test/unit/domain/services/balance_calculator_test.dart
//
// Unit tests for BalanceCalculator.
//
// Formula: balance = Σ(amountMinor WHERE side=debit) − Σ(amountMinor WHERE side=credit)
// Multi-currency: each entry converted via exchangeRateMicro (rate × 1,000,000).
//
// Test cases:
//   1. Zero entries → balance = 0
//   2. Single debit → positive balance
//   3. Single credit → negative balance
//   4. Balanced pair (debit = credit) → zero balance
//   5. Multi-entry: Σdebit > Σcredit → positive
//   6. Multi-entry: Σdebit < Σcredit → negative
//   7. Multi-currency: home-currency conversion via exchangeRateMicro
//   8. Multi-currency: mixed home and foreign entries
//   9. Null exchangeRateMicro treated as rate = 1 (same currency as home)
//  10. BalanceCalculator is stateless (two calls on same instance yield same result)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/services/balance_calculator.dart';

void main() {
  const calculator = BalanceCalculator();
  const homeCurrency = 'INR';
  const now = 1715000000;

  /// Builds a minimal [Entry] for testing.
  Entry makeEntry({
    required String id,
    required EntrySide side,
    required int amountMinor,
    String currencyCode = 'INR',
    int? exchangeRateMicro,
  }) {
    return Entry(
      id: id,
      transactionId: 'tx1',
      accountId: 'a1',
      side: side,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      exchangeRateMicro: exchangeRateMicro,
      createdAt: now,
    );
  }

  group('BalanceCalculator — basic cases', () {
    test('1. empty entries → 0', () {
      expect(
        calculator.compute(entries: [], homeCurrency: homeCurrency),
        equals(0),
      );
    });

    test('2. single debit → positive balance', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 10000),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(10000),
      );
    });

    test('3. single credit → negative balance', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.credit, amountMinor: 10000),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(-10000),
      );
    });

    test('4. balanced debit + credit pair → 0', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 5000),
        makeEntry(id: 'e2', side: EntrySide.credit, amountMinor: 5000),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(0),
      );
    });

    test('5. Σdebit > Σcredit → positive', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 15000),
        makeEntry(id: 'e2', side: EntrySide.credit, amountMinor: 5000),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(10000),
      );
    });

    test('6. Σdebit < Σcredit → negative', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 3000),
        makeEntry(id: 'e2', side: EntrySide.credit, amountMinor: 8000),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(-5000),
      );
    });
  });

  group('BalanceCalculator — multi-currency conversion', () {
    // USD entry with rate 83.0 → rateMicro = 83_000_000
    // 100 USD minor units × (83_000_000 / 1_000_000) = 8300 INR minor units
    test('7. foreign debit converted via exchangeRateMicro', () {
      final entries = [
        makeEntry(
          id: 'e1',
          side: EntrySide.debit,
          amountMinor: 100,
          currencyCode: 'USD',
          exchangeRateMicro: 83000000, // 1 USD = 83 INR
        ),
      ];
      // 100 × 83.0 = 8300
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(8300),
      );
    });

    test('8. mixed home and foreign entries', () {
      final entries = [
        // 200 INR debit (no conversion needed)
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 200),
        // 1 USD credit at 83 INR/USD → 83 INR
        makeEntry(
          id: 'e2',
          side: EntrySide.credit,
          amountMinor: 1,
          currencyCode: 'USD',
          exchangeRateMicro: 83000000,
        ),
      ];
      // Σdebit = 200; Σcredit = 83 → balance = 117
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(117),
      );
    });

    test('9. null exchangeRateMicro treated as rate=1 (same currency)', () {
      final entries = [
        makeEntry(
          id: 'e1',
          side: EntrySide.debit,
          amountMinor: 500,
          currencyCode: 'INR',
          // ignore: avoid_redundant_argument_values
          exchangeRateMicro: null,
        ),
      ];
      expect(
        calculator.compute(entries: entries, homeCurrency: homeCurrency),
        equals(500),
      );
    });
  });

  group('BalanceCalculator — statelessness', () {
    test('10. same inputs always produce same output', () {
      final entries = [
        makeEntry(id: 'e1', side: EntrySide.debit, amountMinor: 7500),
        makeEntry(id: 'e2', side: EntrySide.credit, amountMinor: 2500),
      ];
      final r1 =
          calculator.compute(entries: entries, homeCurrency: homeCurrency);
      final r2 =
          calculator.compute(entries: entries, homeCurrency: homeCurrency);
      expect(r1, equals(r2));
      expect(r1, equals(5000));
    });
  });
}
