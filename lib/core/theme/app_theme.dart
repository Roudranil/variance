import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import 'extensions/semantic_color_extension.dart';
import 'extensions/text_sizes_extension.dart';

/// Defines the configuration for the application theme.
///
/// This class provides static methods to generate [ThemeData] based on
/// brightness, seed color, and configured extensions.
class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  /// Generates the [ThemeData] for the application.
  ///
  /// The [brightness] determines if the theme is light or dark.
  /// The [seedColor] is used to generate the [ColorScheme]. If null, a default
  /// Catppuccin color is used (Mauve).
  ///
  /// Returns a configured [ThemeData] instance with:
  /// - Material 3 enabled.
  /// - [SemanticColorsExtension] configured with the appropriate Catppuccin flavor.
  /// - [TextSizesExtension] with default scaling.
  static ThemeData define({required Brightness brightness, Color? seedColor}) {
    final isLight = brightness == Brightness.light;
    final flavor = isLight ? catppuccin.latte : catppuccin.mocha;

    // Default seed color if none provided (Mauve is a safe, neutral choice)
    final effectiveSeed = seedColor ?? flavor.mauve;

    // Create the color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectiveSeed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        TextSizesExtension(),
        SemanticColorsExtension(flavor: flavor, general: effectiveSeed),
      ],
    );
  }
}
