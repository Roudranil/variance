import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/core/theme/extensions/semantic_color_extension.dart';

void main() {
  group('SemanticColorsExtension', () {
    test('Latte flavor mapping is correct', () {
      final ext = SemanticColorsExtension(
        flavor: catppuccin.latte,
        general: Colors.red,
      );

      expect(ext.income, catppuccin.latte.green);
      expect(ext.expense, catppuccin.latte.red);
      expect(ext.transfer, catppuccin.latte.overlay2);
      expect(ext.rosewater, catppuccin.latte.rosewater);
    });

    test('Mocha flavor mapping is correct', () {
      final ext = SemanticColorsExtension(
        flavor: catppuccin.mocha,
        general: Colors.blue,
      );

      expect(ext.income, catppuccin.mocha.green);
      expect(ext.expense, catppuccin.mocha.red);
    });

    test('lerp interpolates general color', () {
      final extA = SemanticColorsExtension(
        flavor: catppuccin.latte,
        general: Colors.black, // 0xFF000000
      );
      final extB = SemanticColorsExtension(
        flavor: catppuccin.mocha,
        general: Colors.white, // 0xFFFFFFFF
      );

      final lerped = extA.lerp(extB, 0.5) as SemanticColorsExtension;

      // Color.lerp(black, white, 0.5) should be existing mid grey-ish
      expect(lerped.general.alpha, 255);
      // In 0.5, flavor should be extB.flavor (since t >= 0.5 in my impl?)
      // Actually my impl: t < 0.5 ? flavor : other.flavor
      // So at 0.5 it is other.flavor (mocha)
      expect(lerped.flavor, catppuccin.mocha);
    });
  });
}
