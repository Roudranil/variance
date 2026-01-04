import 'dart:ui';

import 'package:flutter/material.dart';

/// Defines standardized text sizes used across the application.
///
/// This extension implements a scaling mechanism via [scaleFactor] to allow
/// global resizing of text elements. Sizes are inspired by Tailwind CSS.
@immutable
class TextSizesExtension extends ThemeExtension<TextSizesExtension> {
  /// Creates a new instance of [TextSizesExtension].
  ///
  /// The [scaleFactor] defaults to 1.0 and is clamped between 0.5 and 1.5.
  const TextSizesExtension({this.scaleFactor = 1.0})
    : assert(
        scaleFactor >= 0.5 && scaleFactor <= 1.5,
        'Scale factor must be between 0.5 and 1.5',
      );

  /// The global scaling factor for text sizes.
  final double scaleFactor;

  // --- Computed Properties ---

  /// Extra small text size.
  ///
  /// Base value: 12.0.
  double get xs => (12.0 * scaleFactor).roundToDouble();

  /// Small text size.
  ///
  /// Base value: 14.0.
  double get sm => (14.0 * scaleFactor).roundToDouble();

  /// Base text size.
  ///
  /// Base value: 16.0.
  double get base => (16.0 * scaleFactor).roundToDouble();

  /// Large text size.
  ///
  /// Base value: 18.0.
  double get lg => (18.0 * scaleFactor).roundToDouble();

  /// Extra large text size.
  ///
  /// Base value: 20.0.
  double get xl => (20.0 * scaleFactor).roundToDouble();

  /// 2x Extra large text size.
  ///
  /// Base value: 24.0.
  double get xl2 => (24.0 * scaleFactor).roundToDouble();

  /// 3x Extra large text size.
  ///
  /// Base value: 30.0.
  double get xl3 => (30.0 * scaleFactor).roundToDouble();

  /// 4x Extra large text size.
  ///
  /// Base value: 36.0.
  double get xl4 => (36.0 * scaleFactor).roundToDouble();

  /// 5x Extra large text size.
  ///
  /// Base value: 48.0.
  double get xl5 => (48.0 * scaleFactor).roundToDouble();

  /// 6x Extra large text size.
  ///
  /// Base value: 60.0.
  double get xl6 => (60.0 * scaleFactor).roundToDouble();

  /// 7x Extra large text size.
  ///
  /// Base value: 72.0.
  double get xl7 => (72.0 * scaleFactor).roundToDouble();

  /// 8x Extra large text size.
  ///
  /// Base value: 96.0.
  double get xl8 => (96.0 * scaleFactor).roundToDouble();

  /// 9x Extra large text size.
  ///
  /// Base value: 128.0.
  double get xl9 => (128.0 * scaleFactor).roundToDouble();

  @override
  ThemeExtension<TextSizesExtension> copyWith({double? scaleFactor}) {
    return TextSizesExtension(scaleFactor: scaleFactor ?? this.scaleFactor);
  }

  @override
  ThemeExtension<TextSizesExtension> lerp(
    covariant ThemeExtension<TextSizesExtension>? other,
    double t,
  ) {
    if (other is! TextSizesExtension) {
      return this;
    }

    return TextSizesExtension(
      scaleFactor: lerpDouble(scaleFactor, other.scaleFactor, t) ?? scaleFactor,
    );
  }
}
