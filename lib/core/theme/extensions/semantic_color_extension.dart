import 'dart:ui';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

/// Defines the semantic colors used across the application.
///
/// This extension provides a consistent way to access colors that have specific
/// meanings in the context of the application, such as [income], [expense],
/// and [transfer], as well as the full Catppuccin palette.
@immutable
class SemanticColorsExtension extends ThemeExtension<SemanticColorsExtension> {
  /// Creates a new instance of [SemanticColorsExtension].
  ///
  /// The [flavor] parameter determines the specific Catppuccin palette used.
  /// The [general] color is the primary accent color.
  const SemanticColorsExtension({required this.flavor, required this.general});

  /// The Catppuccin flavor used for this theme (Latte or Mocha).
  final Flavor flavor;

  /// The general accent color for the application.
  final Color general;

  // --- Semantic Roles ---

  /// Color representing income, assets, and positive financial flows.
  ///
  /// Maps to the 'green' color of the current flavor.
  Color get income => flavor.green;

  /// Color representing expenses, liabilities, and negative financial flows.
  ///
  /// Maps to the 'red' color of the current flavor.
  Color get expense => flavor.red;

  /// Color representing transfers and neutral financial actions.
  ///
  /// Maps to the 'overlay2' color of the current flavor.
  Color get transfer => flavor.overlay2;

  // --- Catppuccin Palette Proxies ---

  /// The 'rosewater' color of the current flavor.
  Color get rosewater => flavor.rosewater;

  /// The 'flamingo' color of the current flavor.
  Color get flamingo => flavor.flamingo;

  /// The 'pink' color of the current flavor.
  Color get pink => flavor.pink;

  /// The 'mauve' color of the current flavor.
  Color get mauve => flavor.mauve;

  /// The 'red' color of the current flavor.
  Color get red => flavor.red;

  /// The 'maroon' color of the current flavor.
  Color get maroon => flavor.maroon;

  /// The 'peach' color of the current flavor.
  Color get peach => flavor.peach;

  /// The 'yellow' color of the current flavor.
  Color get yellow => flavor.yellow;

  /// The 'green' color of the current flavor.
  Color get green => flavor.green;

  /// The 'teal' color of the current flavor.
  Color get teal => flavor.teal;

  /// The 'sky' color of the current flavor.
  Color get sky => flavor.sky;

  /// The 'sapphire' color of the current flavor.
  Color get sapphire => flavor.sapphire;

  /// The 'blue' color of the current flavor.
  Color get blue => flavor.blue;

  /// The 'lavender' color of the current flavor.
  Color get lavender => flavor.lavender;

  @override
  ThemeExtension<SemanticColorsExtension> copyWith({
    Flavor? flavor,
    Color? general,
  }) {
    return SemanticColorsExtension(
      flavor: flavor ?? this.flavor,
      general: general ?? this.general,
    );
  }

  @override
  ThemeExtension<SemanticColorsExtension> lerp(
    covariant ThemeExtension<SemanticColorsExtension>? other,
    double t,
  ) {
    if (other is! SemanticColorsExtension) {
      return this;
    }

    // optimizing lerp for flavor switch might be overkill, usually direct switch.
    // We linearly interpolate the general color.
    return SemanticColorsExtension(
      flavor: t < 0.5 ? flavor : other.flavor,
      general: Color.lerp(general, other.general, t)!,
    );
  }
}
