// lib/presentation/theme/app_theme.dart
//
// Centralised ThemeData factory for Variance.
//
// Provides:
//   - [AppThemeData.light] — static light ThemeData (seed: deep purple)
//   - [AppThemeData.dark]  — static dark ThemeData (seed: deep purple)
//   - [AppThemeData.fromSeed] — builds a pair from an arbitrary seed color
//   - [AppThemeData.fromColorSchemes] — builds a pair from pre-built schemes
//     (used by DynamicColorBuilder when OEM wallpaper extraction succeeds)
//   - [AppThemeData.fromCatppuccin] — builds a pair using the Catppuccin palette
//     (Latte for light, Mocha for dark) per SDS §2.18.2
//
// Dynamic color (T-18):
//   DynamicColorBuilder is wired at the root widget (AppRouterWidget). When
//   OEM extraction succeeds, the provided ColorScheme is passed to
//   [AppThemeData.fromColorSchemes]. When it returns null (restriction or
//   unsupported device), [AppThemeData.fromSeed] is called with the seed
//   stored in app_settings.color_seed (or the default purple seed).
//
// ThemeExtensions registered in every ThemeData:
//   - VarianceColors (T-19)  — financial semantic color tokens
//   - VarianceTypography (T-19 / SDS §2.18.3) — compile-time size constants
//
// Test cases (see test/presentation/theme/variance_colors_test.dart):
//   - incomeAmount resolves to non-null Color in light mode
//   - incomeAmount resolves to non-null Color in dark mode
//   - DynamicColorBuilder null-fallback path produces a valid theme with
//     non-null VarianceColors tokens

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import 'package:variance/presentation/theme/variance_colors.dart';
import 'package:variance/presentation/theme/variance_typography.dart';

// ---------------------------------------------------------------------------
// Default seed color
// ---------------------------------------------------------------------------

/// Default Material 3 seed color used when no custom seed is set by the user.
///
/// Applied when [ColorSchemeMode.dynamic] is unavailable (OEM restriction or
/// API level < 31) and no custom seed is stored in `app_settings.color_seed`.
const Color kDefaultSeedColor = Color(0xFF6750A4); // M3 baseline purple

// ---------------------------------------------------------------------------
// AppThemeData
// ---------------------------------------------------------------------------

/// Factory class for Variance [ThemeData] instances.
///
/// All [ThemeData] objects produced here enable Material 3
/// (`useMaterial3: true`) and register both [VarianceColors] and
/// [VarianceTypography] extensions.
// ignore: avoid_classes_with_only_static_members — intentional namespace
abstract final class AppThemeData {
  // -------------------------------------------------------------------------
  // Static singletons (default seed)
  // -------------------------------------------------------------------------

  /// Light [ThemeData] built from [kDefaultSeedColor].
  ///
  /// Used as fallback when both dynamic color and user seed are unavailable.
  static final ThemeData light = fromSeed(kDefaultSeedColor).light;

  /// Dark [ThemeData] built from [kDefaultSeedColor].
  ///
  /// Used as fallback when both dynamic color and user seed are unavailable.
  static final ThemeData dark = fromSeed(kDefaultSeedColor).dark;

  // -------------------------------------------------------------------------
  // Seed-based factory
  // -------------------------------------------------------------------------

  /// Builds a light/dark [ThemePair] from [seedColor].
  ///
  /// Both themes include [VarianceColors] and [VarianceTypography] extensions.
  ///
  /// Parameters:
  /// - [seedColor]: The seed `Color` passed to [ColorScheme.fromSeed].
  static ThemePair fromSeed(Color seedColor) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return ThemePair(
      light: _buildTheme(lightScheme, Brightness.light),
      dark: _buildTheme(darkScheme, Brightness.dark),
    );
  }

  // -------------------------------------------------------------------------
  // ColorScheme-based factory (for DynamicColorBuilder)
  // -------------------------------------------------------------------------

  /// Builds a [ThemePair] from pre-built [lightScheme] and [darkScheme].
  ///
  /// Called by the root widget when [DynamicColorBuilder] provides OEM-
  /// extracted color schemes. Both schemes are enriched with the
  /// [VarianceColors] and [VarianceTypography] extensions.
  ///
  /// Parameters:
  /// - [lightScheme]: The light [ColorScheme] from [DynamicColorBuilder].
  /// - [darkScheme]: The dark [ColorScheme] from [DynamicColorBuilder].
  static ThemePair fromColorSchemes(
    ColorScheme lightScheme,
    ColorScheme darkScheme,
  ) {
    return ThemePair(
      light: _buildTheme(lightScheme, Brightness.light),
      dark: _buildTheme(darkScheme, Brightness.dark),
    );
  }

  // -------------------------------------------------------------------------
  // Catppuccin-based factory (SDS §2.18.2)
  // -------------------------------------------------------------------------

  /// Builds a [ThemePair] using the Catppuccin palette.
  ///
  /// Light mode uses the Latte flavour; dark mode uses the Mocha flavour.
  /// The seed color is [Flavor.mauve] per the SDS decision table.
  ///
  /// [VarianceColors] tokens are mapped to Catppuccin palette colors:
  /// - incomeAmount → Catppuccin green
  /// - expenseAmount → Catppuccin red
  /// - warningAmount → Catppuccin peach
  /// - accentPastel → Catppuccin lavender
  static ThemePair fromCatppuccin() {
    final latte = catppuccin.latte;
    final mocha = catppuccin.mocha;

    final lightScheme = ColorScheme.fromSeed(
      seedColor: latte.mauve,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: mocha.mauve,
      brightness: Brightness.dark,
    );

    return ThemePair(
      light: _buildThemeWithCatppuccin(lightScheme, Brightness.light, latte),
      dark: _buildThemeWithCatppuccin(darkScheme, Brightness.dark, mocha),
    );
  }

  // -------------------------------------------------------------------------
  // Internal builders
  // -------------------------------------------------------------------------

  /// Constructs a single [ThemeData] with M3 enabled, the given [scheme] and
  /// [brightness], and the [VarianceColors] + [VarianceTypography] extensions.
  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      extensions: [
        // Financial semantic color tokens (income/expense/warning/accent).
        isLight ? VarianceColors.light : VarianceColors.dark,
        // Compile-time font size constants (no light/dark variation needed).
        VarianceTypography.defaults,
      ],
    );
  }

  /// Constructs a single [ThemeData] with [VarianceColors] mapped to
  /// the given Catppuccin [flavor] palette colors.
  ///
  /// Parameters:
  /// - [scheme]: The M3 [ColorScheme] built from the Catppuccin mauve seed.
  /// - [brightness]: The brightness mode.
  /// - [flavor]: The Catppuccin [Flavor] (Latte for light, Mocha for dark).
  static ThemeData _buildThemeWithCatppuccin(
    ColorScheme scheme,
    Brightness brightness,
    Flavor flavor,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      extensions: [
        // Catppuccin-mapped VarianceColors tokens (SDS §2.18.2).
        // Flavor colors are dart:ui Color — they are directly assignable.
        VarianceColors(
          incomeAmount: flavor.green,
          expenseAmount: flavor.red,
          warningAmount: flavor.peach,
          accentPastel: flavor.lavender,
        ),
        VarianceTypography.defaults,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ThemePair
// ---------------------------------------------------------------------------

/// A pair of [ThemeData] objects for light and dark modes.
///
/// Produced by [AppThemeData] factories and consumed by [MaterialApp] via
/// `theme:` and `darkTheme:` properties.
@immutable
class ThemePair {
  /// Creates a [ThemePair].
  ///
  /// Parameters:
  /// - [light]: The light-mode [ThemeData].
  /// - [dark]: The dark-mode [ThemeData].
  const ThemePair({required this.light, required this.dark});

  /// The light-mode [ThemeData].
  final ThemeData light;

  /// The dark-mode [ThemeData].
  final ThemeData dark;
}
