// lib/presentation/theme/variance_typography.dart
//
// VarianceTypography ThemeExtension — compile-time font size constants.
//
// Eliminates magic numeric font size literals in widgets. All widget font-size
// references MUST use these constants (SDS §2.18.3).
//
// The extension is registered in ThemeData.extensions alongside VarianceColors
// regardless of color_scheme_mode.
//
// Usage:
//   final typo = Theme.of(context).extension<VarianceTypography>()!;
//   Text('\$100', style: TextStyle(fontSize: typo.numericLarge));
//
// Font families are placeholders until the UX Flows stage finalises the
// type pairing (SDS §2.18.3 note).

import 'package:flutter/material.dart';

/// Compile-time font size constants and font family tokens for Variance.
///
/// Registered as a [ThemeExtension] on both light and dark [ThemeData]
/// instances. Widgets access constants via
/// `Theme.of(context).extension<VarianceTypography>()!`.
///
/// All font-size references in widgets must use these constants rather than
/// raw `double` literals (SDS §2.18.3).
@immutable
class VarianceTypography extends ThemeExtension<VarianceTypography> {
  /// Creates a [VarianceTypography] token set.
  ///
  /// Font family fields are placeholder strings until UX Flows finalises the
  /// type pairing.
  ///
  /// Parameters:
  /// - [displayFont]: Font family for hero/display text.
  /// - [bodyFont]: Font family for body and label text.
  /// - [numericFont]: Monospaced/tabular font family for amounts.
  /// - Font size constants: see individual field documentation.
  const VarianceTypography({
    this.displayFont = '',
    this.bodyFont = '',
    this.numericFont = '',
    this.displayHeroAmount = 48,
    this.displayLargeAmount = 36,
    this.sectionHeading = 20,
    this.bodyLarge = 16,
    this.bodyMedium = 14,
    this.bodySmall = 12,
    this.numericLarge = 24,
    this.numericMedium = 16,
    this.numericSmall = 13,
    this.label = 11,
    this.tabLabel = 12,
    this.chipText = 12,
    this.buttonText = 14,
  });

  // -------------------------------------------------------------------------
  // Font families (placeholder strings until UX Flows stage)
  // -------------------------------------------------------------------------

  /// Font family for hero and display text.
  final String displayFont;

  /// Font family for body and label text.
  final String bodyFont;

  /// Monospaced or tabular-numeric font family for financial amounts.
  final String numericFont;

  // -------------------------------------------------------------------------
  // Font size constants (sp)
  // -------------------------------------------------------------------------

  /// 48sp — home screen balance hero amount.
  final double displayHeroAmount;

  /// 36sp — account detail hero amount.
  final double displayLargeAmount;

  /// 20sp — section / group headers.
  final double sectionHeading;

  /// 16sp — primary body text and transaction titles.
  final double bodyLarge;

  /// 14sp — secondary body text and descriptions.
  final double bodyMedium;

  /// 12sp — captions, timestamps, metadata.
  final double bodySmall;

  /// 24sp — transaction amount in the detail view.
  final double numericLarge;

  /// 16sp — transaction amount in a list row.
  final double numericMedium;

  /// 13sp — inline balance and running totals.
  final double numericSmall;

  /// 11sp — form field labels and input hints.
  final double label;

  /// 12sp — bottom nav / tab bar labels.
  final double tabLabel;

  /// 12sp — category chip and filter chip text.
  final double chipText;

  /// 14sp — filled / text button label.
  final double buttonText;

  // -------------------------------------------------------------------------
  // Pre-built token set (singleton for the default configuration)
  // -------------------------------------------------------------------------

  /// The default [VarianceTypography] token set with all standard size values.
  ///
  /// Font family fields are left as empty strings pending UX Flows decisions.
  static const VarianceTypography defaults = VarianceTypography();

  // -------------------------------------------------------------------------
  // ThemeExtension API
  // -------------------------------------------------------------------------

  @override
  VarianceTypography copyWith({
    String? displayFont,
    String? bodyFont,
    String? numericFont,
    double? displayHeroAmount,
    double? displayLargeAmount,
    double? sectionHeading,
    double? bodyLarge,
    double? bodyMedium,
    double? bodySmall,
    double? numericLarge,
    double? numericMedium,
    double? numericSmall,
    double? label,
    double? tabLabel,
    double? chipText,
    double? buttonText,
  }) {
    return VarianceTypography(
      displayFont: displayFont ?? this.displayFont,
      bodyFont: bodyFont ?? this.bodyFont,
      numericFont: numericFont ?? this.numericFont,
      displayHeroAmount: displayHeroAmount ?? this.displayHeroAmount,
      displayLargeAmount: displayLargeAmount ?? this.displayLargeAmount,
      sectionHeading: sectionHeading ?? this.sectionHeading,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      numericLarge: numericLarge ?? this.numericLarge,
      numericMedium: numericMedium ?? this.numericMedium,
      numericSmall: numericSmall ?? this.numericSmall,
      label: label ?? this.label,
      tabLabel: tabLabel ?? this.tabLabel,
      chipText: chipText ?? this.chipText,
      buttonText: buttonText ?? this.buttonText,
    );
  }

  /// Linearly interpolates between two [VarianceTypography] instances.
  ///
  /// Font family strings are not interpolated — the [other] value is returned
  /// immediately for string fields when [t] >= 0.5.
  ///
  /// Returns the caller instance when [other] is not a [VarianceTypography].
  @override
  VarianceTypography lerp(ThemeExtension<VarianceTypography>? other, double t) {
    if (other is! VarianceTypography) return this;

    // Interpolate numeric size constants linearly.
    // Font family strings switch at the midpoint.
    return VarianceTypography(
      displayFont: t < 0.5 ? displayFont : other.displayFont,
      bodyFont: t < 0.5 ? bodyFont : other.bodyFont,
      numericFont: t < 0.5 ? numericFont : other.numericFont,
      displayHeroAmount:
          _lerpDouble(displayHeroAmount, other.displayHeroAmount, t),
      displayLargeAmount:
          _lerpDouble(displayLargeAmount, other.displayLargeAmount, t),
      sectionHeading: _lerpDouble(sectionHeading, other.sectionHeading, t),
      bodyLarge: _lerpDouble(bodyLarge, other.bodyLarge, t),
      bodyMedium: _lerpDouble(bodyMedium, other.bodyMedium, t),
      bodySmall: _lerpDouble(bodySmall, other.bodySmall, t),
      numericLarge: _lerpDouble(numericLarge, other.numericLarge, t),
      numericMedium: _lerpDouble(numericMedium, other.numericMedium, t),
      numericSmall: _lerpDouble(numericSmall, other.numericSmall, t),
      label: _lerpDouble(label, other.label, t),
      tabLabel: _lerpDouble(tabLabel, other.tabLabel, t),
      chipText: _lerpDouble(chipText, other.chipText, t),
      buttonText: _lerpDouble(buttonText, other.buttonText, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VarianceTypography &&
        other.displayFont == displayFont &&
        other.bodyFont == bodyFont &&
        other.numericFont == numericFont &&
        other.displayHeroAmount == displayHeroAmount &&
        other.displayLargeAmount == displayLargeAmount &&
        other.sectionHeading == sectionHeading &&
        other.bodyLarge == bodyLarge &&
        other.bodyMedium == bodyMedium &&
        other.bodySmall == bodySmall &&
        other.numericLarge == numericLarge &&
        other.numericMedium == numericMedium &&
        other.numericSmall == numericSmall &&
        other.label == label &&
        other.tabLabel == tabLabel &&
        other.chipText == chipText &&
        other.buttonText == buttonText;
  }

  @override
  int get hashCode => Object.hashAll([
        displayFont,
        bodyFont,
        numericFont,
        displayHeroAmount,
        displayLargeAmount,
        sectionHeading,
        bodyLarge,
        bodyMedium,
        bodySmall,
        numericLarge,
        numericMedium,
        numericSmall,
        label,
        tabLabel,
        chipText,
        buttonText,
      ]);
}
