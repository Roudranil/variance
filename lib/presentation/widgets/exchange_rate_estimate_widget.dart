// lib/presentation/widgets/exchange_rate_estimate_widget.dart
//
// ExchangeRateEstimateWidget — inline exchange rate estimate for the
// transaction entry form (T-94, CURR-03).
//
// Render states (UX Flows §7.2.6):
//   same currency    → empty SizedBox (no display)
//   rate == null     → "Exchange rate unavailable." note
//   rate.isStale     → "≈ [label][amount]" + "⚠ Rate may be outdated" warning
//   rate fresh       → "≈ [label][amount]"
//
// The estimate is computed as: amount * exchangeRate.rate, formatted to the
// home currency's minor_units decimal places.
//
// This widget is purely presentational (StatelessWidget). The parent ViewModel
// is responsible for fetching the rate and providing it here.
//
// Test cases (see test/widget/exchange_rate_estimate_widget_test.dart):
//   1. same currency → renders nothing
//   2. exchangeRate null → renders unavailable note
//   3. rate stale → renders amount with staleness warning
//   4. rate fresh → renders amount without warning

import 'package:flutter/material.dart';

import 'package:variance/domain/entities/exchange_rate.dart';

/// Inline estimate showing the home-currency equivalent for a cross-currency
/// transaction amount.
///
/// Renders nothing when [fromCurrency] == [toCurrency]. Displays a staleness
/// warning when [exchangeRate] is older than the 14-day threshold
/// ([ExchangeRate.isStale]).
class ExchangeRateEstimateWidget extends StatelessWidget {
  /// Creates an [ExchangeRateEstimateWidget].
  ///
  /// Parameters:
  /// - [amount]: The transaction amount to convert. May be null while the
  ///   user is still typing; in that case the estimated display is omitted.
  /// - [fromCurrency]: ISO 4217 source currency code.
  /// - [toCurrency]: ISO 4217 target currency code (typically home currency).
  /// - [exchangeRate]: Cached rate entity; null when no rate is available.
  /// - [homeMinorUnits]: Decimal places of the home currency (default 2).
  const ExchangeRateEstimateWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.amount,
    this.exchangeRate,
    this.homeMinorUnits = 2,
  });

  /// Source currency ISO 4217 code.
  final String fromCurrency;

  /// Target (home) currency ISO 4217 code.
  final String toCurrency;

  /// Transaction amount to estimate; null hides the numeric estimate.
  final double? amount;

  /// Cached rate for [fromCurrency] → [toCurrency]; null = unavailable.
  final ExchangeRate? exchangeRate;

  /// Decimal places for the home currency (default: 2, e.g. INR, USD).
  final int homeMinorUnits;

  @override
  Widget build(BuildContext context) {
    // Same currency: no estimate needed.
    if (fromCurrency == toCurrency) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Rate unavailable state.
    if (exchangeRate == null) {
      return _NoteText(
        text: 'Exchange rate unavailable.',
        color: colorScheme.onSurfaceVariant,
      );
    }

    // Compute estimate text.
    final estimateText = _buildEstimateText();

    // Fresh rate: show estimate only.
    if (!exchangeRate!.isStale) {
      return _NoteText(
        text: estimateText,
        color: colorScheme.onSurfaceVariant,
      );
    }

    // Stale rate: estimate + warning.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NoteText(
          text: estimateText,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 2),
        _StalenessWarning(colorScheme: colorScheme),
      ],
    );
  }

  /// Builds the "≈ [toCurrency][estimatedAmount]" string.
  ///
  /// Returns a placeholder when [amount] is null or the rate is absent.
  String _buildEstimateText() {
    if (amount == null || exchangeRate == null) {
      return '≈ $toCurrency --';
    }
    final estimated = amount! * exchangeRate!.rate;
    final formatted = estimated.toStringAsFixed(homeMinorUnits);
    return '≈ $toCurrency $formatted';
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// Small note-style text line.
class _NoteText extends StatelessWidget {
  const _NoteText({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }
}

/// Inline staleness warning row: warning icon + label text.
class _StalenessWarning extends StatelessWidget {
  const _StalenessWarning({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 14,
          color: colorScheme.error,
        ),
        const SizedBox(width: 4),
        Text(
          'Rate may be outdated',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
        ),
      ],
    );
  }
}
