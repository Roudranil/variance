import 'package:flutter/material.dart';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';

import 'package:variance/core/theme/extensions/semantic_color_extension.dart';
import 'package:variance/core/theme/extensions/text_sizes_extension.dart';

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
      fontFamily: 'NunitoSans',
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        // selected state uses primary background (the indicator)
        indicatorColor: colorScheme.primary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            // filled icons with surfaceContainer color on primary background
            // increase weight if filled variant is unavailable (M3 guideline)
            return IconThemeData(
              color: colorScheme.surfaceContainer,
              fill: 1.0,
              weight: 600,
            );
          }
          // outlined icons with primary color
          // decrease weight if outlined variant is unavailable (M3 guideline)
          return IconThemeData(
            color: colorScheme.primary,
            fill: 0.0,
            weight: 400,
          );
        }),
      ),
      extensions: [
        const TextSizesExtension(),
        SemanticColorsExtension(flavor: flavor, general: effectiveSeed),
      ],
    );
  }
}
