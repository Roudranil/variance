// lib/presentation/theme/variance_colors.dart
//
// VarianceColors ThemeExtension — compile-time semantic color tokens.
//
// Provides four financial-semantic color tokens that Material 3's built-in
// ColorScheme does not cover:
//   - incomeAmount  : green shade, theme-adaptive
//   - expenseAmount : red shade, theme-adaptive
//   - warningAmount : orange shade, theme-adaptive
//   - accentPastel  : lightened/darkened accent for chips and surfaces
//
// All other color roles use ColorScheme tokens directly. Tokens are added to
// VarianceColors only when ColorScheme roles are insufficient (SDS §2.18.1).
//
// Usage:
//   final colors = Theme.of(context).extension<VarianceColors>()!;
//   Text('\$100', style: TextStyle(color: colors.incomeAmount));
//
// Test cases (see test/presentation/theme/variance_colors_test.dart):
//   - incomeAmount resolves to a non-null Color in light mode
//   - incomeAmount resolves to a non-null Color in dark mode
//   - DynamicColorBuilder null-fallback path produces a valid theme with
//     non-null VarianceColors tokens

import 'package:flutter/material.dart';

/// Compile-time semantic color tokens for financial amounts and accents.
///
/// Registered as a [ThemeExtension] on both light and dark [ThemeData]
/// instances. Widgets access tokens via
/// `Theme.of(context).extension<VarianceColors>()!`.
///
/// Do not add tokens here unless the Material 3 [ColorScheme] is insufficient
/// for the use case (SDS §2.18.1).
@immutable
class VarianceColors extends ThemeExtension<VarianceColors> {
  /// Creates a [VarianceColors] token set.
  ///
  /// Parameters:
  /// - [incomeAmount]: Color for positive financial amounts (e.g. income).
  /// - [expenseAmount]: Color for negative financial amounts (e.g. expenses).
  /// - [warningAmount]: Color for budget-threshold warnings.
  /// - [accentPastel]: Lightened/darkened accent for category chips and
  ///   tonal surfaces.
  const VarianceColors({
    required this.incomeAmount,
    required this.expenseAmount,
    required this.warningAmount,
    required this.accentPastel,
  });

  // -------------------------------------------------------------------------
  // Semantic tokens
  // -------------------------------------------------------------------------

  /// Positive financial amounts — income, credits, gains.
  ///
  /// Green-family hue, adapted for both light and dark themes.
  final Color incomeAmount;

  /// Negative financial amounts — expenses, debits, losses.
  ///
  /// Red-family hue, adapted for both light and dark themes.
  final Color expenseAmount;

  /// Budget-threshold and over-limit warnings.
  ///
  /// Orange-family hue, adapted for both light and dark themes.
  final Color warningAmount;

  /// Lightened/darkened accent for category chips and tonal surface fills.
  ///
  /// Derived from the seed accent color; shifted for legibility in each mode.
  final Color accentPastel;

  // -------------------------------------------------------------------------
  // Pre-built token sets
  // -------------------------------------------------------------------------

  /// Light-mode [VarianceColors] token values.
  ///
  /// Greens are deeper and more saturated for legibility on light surfaces.
  static const VarianceColors light = VarianceColors(
    incomeAmount: Color(0xFF1B8A3B), // deep green on white/light surface
    expenseAmount: Color(0xFFC62828), // deep red on white/light surface
    warningAmount: Color(0xFFE65100), // deep orange on white/light surface
    accentPastel: Color(0xFFD0BCFF), // M3 purple tonal — light pastel
  );

  /// Dark-mode [VarianceColors] token values.
  ///
  /// Colors are lightened for legibility against dark surfaces.
  static const VarianceColors dark = VarianceColors(
    incomeAmount: Color(0xFF69F0AE), // light green on dark surface
    expenseAmount: Color(0xFFEF9A9A), // light red on dark surface
    warningAmount: Color(0xFFFFCC80), // light orange on dark surface
    accentPastel: Color(0xFF4A3F6B), // M3 purple tonal — dark pastel
  );

  // -------------------------------------------------------------------------
  // ThemeExtension API
  // -------------------------------------------------------------------------

  @override
  VarianceColors copyWith({
    Color? incomeAmount,
    Color? expenseAmount,
    Color? warningAmount,
    Color? accentPastel,
  }) {
    return VarianceColors(
      incomeAmount: incomeAmount ?? this.incomeAmount,
      expenseAmount: expenseAmount ?? this.expenseAmount,
      warningAmount: warningAmount ?? this.warningAmount,
      accentPastel: accentPastel ?? this.accentPastel,
    );
  }

  /// Linearly interpolates between two [VarianceColors] instances.
  ///
  /// Returns the caller instance when [other] is not a [VarianceColors].
  @override
  VarianceColors lerp(ThemeExtension<VarianceColors>? other, double t) {
    if (other is! VarianceColors) return this;
    return VarianceColors(
      incomeAmount: Color.lerp(incomeAmount, other.incomeAmount, t)!,
      expenseAmount: Color.lerp(expenseAmount, other.expenseAmount, t)!,
      warningAmount: Color.lerp(warningAmount, other.warningAmount, t)!,
      accentPastel: Color.lerp(accentPastel, other.accentPastel, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VarianceColors &&
        other.incomeAmount == incomeAmount &&
        other.expenseAmount == expenseAmount &&
        other.warningAmount == warningAmount &&
        other.accentPastel == accentPastel;
  }

  @override
  int get hashCode => Object.hash(
        incomeAmount,
        expenseAmount,
        warningAmount,
        accentPastel,
      );
}
