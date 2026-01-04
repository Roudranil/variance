import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/core/theme/app_theme.dart';
import 'package:variance/core/theme/extensions/semantic_color_extension.dart';
import 'package:variance/core/theme/extensions/text_sizes_extension.dart';

void main() {
  group('AppTheme', () {
    test('define(light) uses latte flavor', () {
      final theme = AppTheme.define(brightness: Brightness.light);

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);

      final semantic = theme.extension<SemanticColorsExtension>();
      expect(semantic, isNotNull);
      expect(semantic!.flavor, catppuccin.latte);

      final textSizes = theme.extension<TextSizesExtension>();
      expect(textSizes, isNotNull);
      expect(textSizes!.scaleFactor, 1.0);
    });

    test('define(dark) uses mocha flavor', () {
      final theme = AppTheme.define(brightness: Brightness.dark);

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);

      final semantic = theme.extension<SemanticColorsExtension>();
      expect(semantic, isNotNull);
      expect(semantic!.flavor, catppuccin.mocha);
    });

    test('define respect seedColor', () {
      const seed = Colors.green;
      final theme = AppTheme.define(
        brightness: Brightness.light,
        seedColor: seed,
      );

      // Checking if primary color *resembles* seed (Material 3 generates palette,
      // so primary might not be exactly seed, but let's check basic mapping logic or extension general color)
      final semantic = theme.extension<SemanticColorsExtension>();
      expect(semantic!.general, seed);
    });
  });
}
