// lib/domain/services/money_formatter.dart
//
// MoneyFormatter — locale-aware amount display utility (T-178).
//
// Reads AppSettings locale keys:
//   - numberDecimalSeparator  (comma | period | null → period)
//   - numberThousandsGrouping (standard | indian | null → standard)
//   - currencySymbolPlacement (prefix | suffix | null → prefix)
//   - currencySymbolSpacing   (none | space | null → none)
//
// Specification:
//   - Indian grouping: 2-2-3 pattern for amounts >= 1,00,000
//     e.g. 1,75,000.00 (₹ prefix, period decimal, comma grouping)
//   - Western grouping: 3-digit groups e.g. 1,750,000.00
//   - Decimal separator: '.' or ',' based on setting
//   - Grouping separator: the OPPOSITE character from decimal separator
//     (period decimal → comma grouping; comma decimal → period grouping)
//   - Symbol placement: before or after the amount
//   - Symbol spacing: none or single space between symbol and amount
//   - Currency symbol comes from CurrencySymbolResolver output (display label)
//
// Home currency change note (TC-029):
//   Changing home_currency writes ONLY app_settings.home_currency.
//   No existing transaction.exchange_rate_to_home rows are touched.
//   The MoneyFormatter simply uses the new homeCurrency from settings on
//   next render — no migration or bulk update is triggered.
//
// Test cases (see test/unit/domain/services/money_formatter_test.dart):
//   1. Indian grouping ≥ 1,00,000 → 2-2-3 groups
//   2. Indian grouping < 1,00,000 → 3-digit group (no split)
//   3. Western grouping → 3-digit groups
//   4. Symbol prefix, no space → '₹1,750.00'
//   5. Symbol suffix, space → '1,750.00 ₹'
//   6. Comma decimal separator + period grouping separator
//   7. JPY (minor_units=0) → no decimal part

import 'package:variance/domain/entities/app_settings.dart';

/// Formats a monetary amount in minor units to a display string using the
/// configured locale settings from [AppSettings].
///
/// The formatter is stateless and pure — all state is carried in the
/// [AppSettings] passed to [format].
class MoneyFormatter {
  /// Creates a const [MoneyFormatter].
  const MoneyFormatter();

  /// Formats [amountMinor] using the locale settings in [settings].
  ///
  /// Parameters:
  /// - [amountMinor]: Integer minor-unit amount (e.g. 500000 for ₹5000.00).
  /// - [currencyLabel]: Display label for the currency (e.g. '₹', '\$USD').
  ///   Should be the output of [CurrencySymbolResolver].
  /// - [minorUnits]: Number of decimal places for the currency (0 for JPY,
  ///   2 for USD/INR, 3 for BHD).
  /// - [settings]: Current [AppSettings]; locale fields may be null
  ///   (falls back to period decimal, western grouping, prefix, no-space).
  /// - [isNegative]: When true, prepends a minus sign before the symbol.
  String format({
    required int amountMinor,
    required String currencyLabel,
    required int minorUnits,
    required AppSettings settings,
    bool isNegative = false,
  }) {
    final decimalSep =
        _decimalSeparator(settings.numberDecimalSeparator);
    final groupSep = _groupingSeparator(settings.numberDecimalSeparator);
    final grouping = settings.numberThousandsGrouping ?? ThousandsGrouping.standard;
    final placement =
        settings.currencySymbolPlacement ?? CurrencySymbolPlacement.prefix;
    final spacing =
        settings.currencySymbolSpacing ?? CurrencySymbolSpacing.none;

    // Split amount into integer and fractional parts.
    final absMinor = amountMinor.abs();
    final intPart = absMinor ~/ _pow10(minorUnits);
    final fracPart =
        minorUnits > 0 ? absMinor % _pow10(minorUnits) : null;

    // Format integer part with grouping.
    final intFormatted = _applyGrouping(intPart, grouping, groupSep);

    // Build the numeric string.
    final numericStr = fracPart != null
        ? '$intFormatted$decimalSep${fracPart.toString().padLeft(minorUnits, '0')}'
        : intFormatted;

    // Build the full display string with sign + symbol + numeric.
    final space = spacing == CurrencySymbolSpacing.space ? ' ' : '';
    final sign = isNegative ? '-' : '';

    return switch (placement) {
      CurrencySymbolPlacement.prefix =>
        '$sign$currencyLabel$space$numericStr',
      CurrencySymbolPlacement.suffix =>
        '$sign$numericStr$space$currencyLabel',
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns the decimal separator character for the given [sep] setting.
  String _decimalSeparator(DecimalSeparator? sep) {
    return switch (sep) {
      DecimalSeparator.comma => ',',
      DecimalSeparator.period || null => '.',
    };
  }

  /// Returns the grouping separator — the opposite of the decimal separator.
  String _groupingSeparator(DecimalSeparator? sep) {
    return switch (sep) {
      DecimalSeparator.comma => '.',
      DecimalSeparator.period || null => ',',
    };
  }

  /// Formats [value] with thousands grouping applied.
  ///
  /// Indian grouping: 2-2-3 pattern from the right for values >= 100000.
  ///   e.g. 1750000 → "17,50,000"
  /// Standard grouping: 3-digit groups from the right.
  ///   e.g. 1750000 → "1,750,000"
  String _applyGrouping(
    int value,
    ThousandsGrouping grouping,
    String sep,
  ) {
    final s = value.toString();
    if (s.length <= 3) return s;

    return switch (grouping) {
      ThousandsGrouping.indian => _indianGrouping(s, sep),
      ThousandsGrouping.standard => _standardGrouping(s, sep),
    };
  }

  /// Applies Indian (2-2-3) grouping.
  ///
  /// The rightmost group is 3 digits; all subsequent groups to the left
  /// are 2 digits.
  String _indianGrouping(String s, String sep) {
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    // Rightmost 3 digits first.
    final right = s.substring(s.length - 3);
    var remaining = s.substring(0, s.length - 3);
    // Now group remaining in pairs from the right.
    final groups = <String>[];
    while (remaining.length > 2) {
      groups.add(remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.add(remaining);
    // Build string: leftmost group ... separator ... right
    buf.write(groups.reversed.join(sep));
    buf.write(sep);
    buf.write(right);
    return buf.toString();
  }

  /// Applies standard western 3-digit grouping.
  String _standardGrouping(String s, String sep) {
    final buf = StringBuffer();
    final offset = s.length % 3;
    if (offset > 0) {
      buf.write(s.substring(0, offset));
    }
    for (var i = offset; i < s.length; i += 3) {
      if (buf.isNotEmpty) buf.write(sep);
      buf.write(s.substring(i, i + 3));
    }
    return buf.toString();
  }

  /// Returns 10^[exp] as an integer.
  int _pow10(int exp) {
    var result = 1;
    for (var i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }
}
