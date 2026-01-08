import 'package:flutter/material.dart';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';

import 'package:variance/core/utils/logger.dart';

/// A scaffold that adapts its color scheme based on an entity's color.
///
/// This widget is used for edit screens (Account, Category) where the screen
/// theme should reflect the entity's assigned color. It provides the generated
/// [ColorScheme] to child builders so they can style widgets accordingly.
///
/// Exactly one of [seedColor] or [colorScheme] must be provided:
/// - [seedColor] → Generate ColorScheme from seed (like the app does)
/// - [colorScheme] → Use a pre-generated ColorScheme directly
/// - Both null → Use app's current color scheme
class ThemedEditScaffold extends StatelessWidget {
  /// Creates a new instance of [ThemedEditScaffold].
  ///
  /// Parameters:
  /// - [seedColor]: Seed color to generate ColorScheme from.
  /// - [colorScheme]: Pre-generated ColorScheme to use directly.
  /// - [appBarBuilder]: Builder for the app bar, receives colorScheme.
  /// - [bodyBuilder]: Builder for the body, receives colorScheme.
  /// - [bottomNavigationBarBuilder]: Optional builder for bottom bar.
  /// - [floatingActionButton]: Optional FAB.
  const ThemedEditScaffold({
    this.seedColor,
    this.colorScheme,
    required this.appBarBuilder,
    required this.bodyBuilder,
    this.bottomNavigationBarBuilder,
    this.floatingActionButton,
    super.key,
  }) : assert(
         seedColor == null || colorScheme == null,
         'Cannot provide both seedColor and colorScheme',
       );

  /// Seed color to generate the ColorScheme from.
  ///
  /// If null and [colorScheme] is also null, uses the app's current scheme.
  final Color? seedColor;

  /// Pre-generated ColorScheme to use directly.
  ///
  /// If null and [seedColor] is also null, uses the app's current scheme.
  final ColorScheme? colorScheme;

  /// Builder for the app bar widget.
  ///
  /// Receives the resolved [ColorScheme] for consistent styling.
  final PreferredSizeWidget Function(ColorScheme colorScheme) appBarBuilder;

  /// Builder for the body widget.
  ///
  /// Receives the resolved [ColorScheme] for consistent styling.
  final Widget Function(ColorScheme colorScheme) bodyBuilder;

  /// Optional builder for bottom navigation bar.
  ///
  /// Receives the resolved [ColorScheme] for consistent styling.
  final Widget Function(ColorScheme colorScheme)? bottomNavigationBarBuilder;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final brightness = parentTheme.brightness;

    VarianceLogger.debug(
      'ThemedEditScaffold: seedColor=$seedColor, '
      'colorScheme=${colorScheme != null ? "provided" : "null"}, '
      'brightness=$brightness',
    );

    // resolve the color scheme
    final resolvedColorScheme =
        colorScheme ??
        (seedColor != null
            ? ColorScheme.fromSeed(
                seedColor: seedColor!,
                brightness: brightness,
              )
            : parentTheme.colorScheme);

    VarianceLogger.info(
      'ThemedEditScaffold: resolved primary=${resolvedColorScheme.primary}, '
      'surface=${resolvedColorScheme.surface}, '
      'usingSeed=${seedColor != null}',
    );

    // create themed version ENTIRELY from colorScheme
    // using ThemeData.from() ensures all color roles derive from colorScheme
    // (copyWith doesn't re-derive legacy properties from the new colorScheme)
    final entityTheme =
        ThemeData.from(
          colorScheme: resolvedColorScheme,
          useMaterial3: true,
        ).copyWith(
          // preserve non-color settings from parent
          textTheme: parentTheme.textTheme,
          extensions: parentTheme.extensions.values,
        );

    VarianceLogger.debug(
      'ThemedEditScaffold: entityTheme.scaffoldBackgroundColor='
      '${entityTheme.scaffoldBackgroundColor}',
    );

    return Theme(
      data: entityTheme,
      child: Scaffold(
        appBar: appBarBuilder(resolvedColorScheme),
        body: bodyBuilder(resolvedColorScheme),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBarBuilder?.call(
          resolvedColorScheme,
        ),
      ),
    );
  }
}

/// Color options for entity theming.
///
/// Used in the color picker to select whether an entity uses:
/// - App's theme
/// - Dynamic color
/// - A specific Catppuccin accent
enum EntityColorOption {
  /// Use the app's current color scheme.
  appDefault,

  /// Use the system's dynamic color (Material You).
  dynamic,

  /// A specific Catppuccin accent color.
  accent,
}

/// Returns the Catppuccin accent colors for the color picker.
///
/// Selects the appropriate flavor (Latte or Mocha) based on the given
/// brightness and returns a list of (name, color) tuples.
///
/// Parameters:
/// - [brightness]: The current theme brightness.
List<(String name, Color color)> getCatppuccinAccents(Brightness brightness) {
  final flavor = brightness == Brightness.light
      ? catppuccin.latte
      : catppuccin.mocha;

  return [
    ('Rosewater', flavor.rosewater),
    ('Flamingo', flavor.flamingo),
    ('Pink', flavor.pink),
    ('Mauve', flavor.mauve),
    ('Red', flavor.red),
    ('Maroon', flavor.maroon),
    ('Peach', flavor.peach),
    ('Yellow', flavor.yellow),
    ('Green', flavor.green),
    ('Teal', flavor.teal),
    ('Sky', flavor.sky),
    ('Sapphire', flavor.sapphire),
    ('Blue', flavor.blue),
    ('Lavender', flavor.lavender),
  ];
}
