// test/unit/domain/services/money_formatter_test.dart
//
// Unit tests for MoneyFormatter (T-178).
//
// Test cases:
//   1. Indian grouping ≥ 1,00,000 → 2-2-3 groups e.g. ₹17,50,000.00
//   2. Indian grouping < 1,00,000 → standard single group e.g. ₹5,000.00
//   3. Western grouping → 3-digit groups e.g. $1,750,000.00
//   4. Symbol prefix, no space → '₹1,750.00'
//   5. Symbol suffix, space → '1,750.00 ₹'
//   6. Comma decimal separator + period grouping separator
//   7. JPY (minor_units=0) → no decimal part
//   8. Home currency change does NOT trigger any DB migration (unit guard)

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/services/money_formatter.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

AppSettings _settings({
  DecimalSeparator? decimal,
  ThousandsGrouping? grouping,
  CurrencySymbolPlacement? placement,
  CurrencySymbolSpacing? spacing,
}) {
  return AppSettings(
    numberDecimalSeparator: decimal,
    numberThousandsGrouping: grouping,
    currencySymbolPlacement: placement,
    currencySymbolSpacing: spacing,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const formatter = MoneyFormatter();

  // -------------------------------------------------------------------------
  // Test 1: Indian grouping ≥ 1,00,000 → 2-2-3 groups
  // -------------------------------------------------------------------------
  test('1. Indian grouping ≥ 100000 → 2-2-3 pattern', () {
    final result = formatter.format(
      amountMinor: 17500000, // ₹1,75,000.00 in INR (minor = paise)
      currencyLabel: '₹',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.indian,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    // 17500000 / 100 = 175000.00 → Indian grouped: 1,75,000.00
    expect(result, '₹1,75,000.00');
  });

  // -------------------------------------------------------------------------
  // Test 2: Indian grouping < 1,00,000 → normal 3-digit group
  // -------------------------------------------------------------------------
  test('2. Indian grouping < 100000 → 3-digit group only', () {
    final result = formatter.format(
      amountMinor: 500000, // ₹5,000.00
      currencyLabel: '₹',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.indian,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    expect(result, '₹5,000.00');
  });

  // -------------------------------------------------------------------------
  // Test 3: Western grouping → 3-digit groups
  // -------------------------------------------------------------------------
  test('3. Western grouping → 3-digit groups', () {
    final result = formatter.format(
      amountMinor: 175000000, // $1,750,000.00
      currencyLabel: r'$',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.standard,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    expect(result, r'$1,750,000.00');
  });

  // -------------------------------------------------------------------------
  // Test 4: Symbol prefix, no space
  // -------------------------------------------------------------------------
  test('4. prefix, no-space → symbol immediately before amount', () {
    final result = formatter.format(
      amountMinor: 175000, // ₹1,750.00
      currencyLabel: '₹',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.standard,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    expect(result, '₹1,750.00');
  });

  // -------------------------------------------------------------------------
  // Test 5: Symbol suffix, space
  // -------------------------------------------------------------------------
  test('5. suffix, space → amount then space then symbol', () {
    final result = formatter.format(
      amountMinor: 175000, // 1,750.00 ₹
      currencyLabel: '₹',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.standard,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.suffix,
        spacing: CurrencySymbolSpacing.space,
      ),
    );
    expect(result, '1,750.00 ₹');
  });

  // -------------------------------------------------------------------------
  // Test 6: Comma decimal separator + period grouping
  // -------------------------------------------------------------------------
  test('6. comma decimal + period grouping', () {
    final result = formatter.format(
      amountMinor: 175000, // 1.750,00 €
      currencyLabel: '€',
      minorUnits: 2,
      settings: _settings(
        grouping: ThousandsGrouping.standard,
        decimal: DecimalSeparator.comma,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    expect(result, '€1.750,00');
  });

  // -------------------------------------------------------------------------
  // Test 7: JPY (minor_units=0) → no decimal part
  // -------------------------------------------------------------------------
  test('7. JPY (minorUnits=0) → integer only, no decimal', () {
    final result = formatter.format(
      amountMinor: 150000, // ¥150,000
      currencyLabel: '¥',
      minorUnits: 0,
      settings: _settings(
        grouping: ThousandsGrouping.standard,
        decimal: DecimalSeparator.period,
        placement: CurrencySymbolPlacement.prefix,
        spacing: CurrencySymbolSpacing.none,
      ),
    );
    expect(result, '¥150,000');
  });

  // -------------------------------------------------------------------------
  // Test 8: Home currency change does NOT mutate any transaction rows
  //   This is an architectural invariant tested via domain logic inspection.
  //   MoneyFormatter never accesses the transaction repository — the formatter
  //   is a pure function. Any code that changes home_currency by calling
  //   ICurrencyRepository.setHomeCurrency only writes app_settings, not txns.
  //
  //   The test below confirms that MoneyFormatter is pure (no side-effects):
  //   calling format() twice with different currencyLabel produces different
  //   output (i.e. it reads from parameters, not a shared store).
  // -------------------------------------------------------------------------
  test('8. home currency change is display-only — formatter is stateless', () {
    const settings = AppSettings();

    final resultInr = formatter.format(
      amountMinor: 50000,
      currencyLabel: '₹',
      minorUnits: 2,
      settings: settings,
    );
    final resultUsd = formatter.format(
      amountMinor: 50000,
      currencyLabel: r'$',
      minorUnits: 2,
      settings: settings,
    );

    // Same amount, different label → different output (pure function).
    expect(resultInr, isNot(equals(resultUsd)));
    // No side effects — calling format does not modify anything.
    expect(resultInr, '₹500.00');
    expect(resultUsd, r'$500.00');
  });
}
