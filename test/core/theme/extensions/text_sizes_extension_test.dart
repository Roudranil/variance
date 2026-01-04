import 'package:flutter_test/flutter_test.dart';

import 'package:variance/core/theme/extensions/text_sizes_extension.dart';

void main() {
  group('TextSizesExtension', () {
    test('Default values are correct at scale 1.0', () {
      const ext = TextSizesExtension();
      expect(ext.scaleFactor, 1.0);
      expect(ext.xs, 12.0);
      expect(ext.sm, 14.0);
      expect(ext.base, 16.0);
      expect(ext.xl, 20.0);
      expect(ext.xl9, 128.0);
    });

    test('Scaling works correctly', () {
      const ext = TextSizesExtension(scaleFactor: 1.5);
      expect(ext.base, 24.0); // 16 * 1.5
      expect(ext.xs, 18.0); // 12 * 1.5
    });

    test('Rounding works correctly with odd scales', () {
      const ext = TextSizesExtension(scaleFactor: 1.1);
      // 16 * 1.1 = 17.6 -> 18.0
      expect(ext.base, 18.0);
    });

    test('lerp interpolates scale factor', () {
      const extA = TextSizesExtension(scaleFactor: 1.0);
      const extB = TextSizesExtension(scaleFactor: 1.5);

      final lerped = extA.lerp(extB, 0.5) as TextSizesExtension;
      expect(lerped.scaleFactor, 1.25);
    });

    test('copyWith updates scaleFactor', () {
      const ext = TextSizesExtension(scaleFactor: 1.0);
      final copy = ext.copyWith(scaleFactor: 1.5) as TextSizesExtension;
      expect(copy.scaleFactor, 1.5);
    });
  });
}
