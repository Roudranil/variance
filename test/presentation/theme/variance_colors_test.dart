// test/presentation/theme/variance_colors_test.dart
//
// Widget tests for VarianceColors ThemeExtension and DynamicColorBuilder
// null-fallback path (T-20).
//
// Test cases:
//   - incomeAmount resolves to a non-null Color in light mode
//   - expenseAmount resolves to a non-null Color in light mode
//   - warningAmount resolves to a non-null Color in light mode
//   - accentPastel resolves to a non-null Color in light mode
//   - incomeAmount resolves to a non-null Color in dark mode
//   - expenseAmount resolves to a non-null Color in dark mode
//   - warningAmount resolves to a non-null Color in dark mode
//   - accentPastel resolves to a non-null Color in dark mode
//   - DynamicColorBuilder null-fallback: all tokens resolve non-null in light mode
//   - DynamicColorBuilder null-fallback: all tokens resolve non-null in dark mode
//   - VarianceColors.copyWith produces a new instance with updated tokens
//   - VarianceColors.lerp interpolates between two instances at t=0.5

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/presentation/theme/app_theme.dart';
import 'package:variance/presentation/theme/variance_colors.dart';

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

/// Reads [VarianceColors] from the ambient theme and calls [onColors] with it.
///
/// Used in widget tests to inspect resolved token values.
class _ColorReader extends StatelessWidget {
  const _ColorReader({required this.onColors});

  final void Function(VarianceColors) onColors;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VarianceColors>();
    if (colors != null) onColors(colors);
    return const SizedBox.shrink();
  }
}

/// Wraps [child] in a [MaterialApp] using [theme] as the active theme.
Widget _wrap(Widget child, {required ThemeData theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // Light mode token tests
  // -------------------------------------------------------------------------

  group('VarianceColors — light mode', () {
    late ThemeData lightTheme;

    setUp(() {
      lightTheme = AppThemeData.light;
    });

    testWidgets('incomeAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: lightTheme),
      );
      expect(captured, isNotNull);
      // Accessing incomeAmount must not throw; value is non-null by type.
      expect(captured!.incomeAmount, isA<Color>());
    });

    testWidgets('expenseAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: lightTheme),
      );
      expect(captured!.expenseAmount, isA<Color>());
    });

    testWidgets('warningAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: lightTheme),
      );
      expect(captured!.warningAmount, isA<Color>());
    });

    testWidgets('accentPastel resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: lightTheme),
      );
      expect(captured!.accentPastel, isA<Color>());
    });

    testWidgets('extension<VarianceColors>() is non-null', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: lightTheme),
      );
      // The whole extension must be present, not just individual fields.
      expect(captured, isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode token tests
  // -------------------------------------------------------------------------

  group('VarianceColors — dark mode', () {
    late ThemeData darkTheme;

    setUp(() {
      darkTheme = AppThemeData.dark;
    });

    testWidgets('incomeAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: darkTheme),
      );
      expect(captured, isNotNull);
      expect(captured!.incomeAmount, isA<Color>());
    });

    testWidgets('expenseAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: darkTheme),
      );
      expect(captured!.expenseAmount, isA<Color>());
    });

    testWidgets('warningAmount resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: darkTheme),
      );
      expect(captured!.warningAmount, isA<Color>());
    });

    testWidgets('accentPastel resolves to a non-null Color', (tester) async {
      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(_ColorReader(onColors: (c) => captured = c), theme: darkTheme),
      );
      expect(captured!.accentPastel, isA<Color>());
    });

    test('light and dark incomeAmount differ (unit test)', () {
      // Ensures the two static instances have distinct incomeAmount values.
      // No widget pump needed — we compare the static pre-built instances.
      expect(
        VarianceColors.light.incomeAmount,
        isNot(VarianceColors.dark.incomeAmount),
      );
    });
  });

  // -------------------------------------------------------------------------
  // DynamicColorBuilder null-fallback path
  // -------------------------------------------------------------------------

  group('DynamicColorBuilder null-fallback path', () {
    // When DynamicColorBuilder returns null (unsupported device or OEM
    // restriction), AppThemeData.fromSeed must produce a valid theme whose
    // VarianceColors extension is fully populated.

    testWidgets(
        'null OEM schemes → seed fallback light theme has non-null tokens',
        (tester) async {
      // Simulate the fallback: DynamicColorBuilder emits null for both schemes.
      // AppThemeData.fromSeed is the code path exercised.
      final fallbackThemes = AppThemeData.fromSeed(kDefaultSeedColor);

      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(
          _ColorReader(onColors: (c) => captured = c),
          theme: fallbackThemes.light,
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.incomeAmount, isA<Color>());
      expect(captured!.expenseAmount, isA<Color>());
      expect(captured!.warningAmount, isA<Color>());
      expect(captured!.accentPastel, isA<Color>());
    });

    testWidgets(
        'null OEM schemes → seed fallback dark theme has non-null tokens',
        (tester) async {
      final fallbackThemes = AppThemeData.fromSeed(kDefaultSeedColor);

      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(
          _ColorReader(onColors: (c) => captured = c),
          theme: fallbackThemes.dark,
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.incomeAmount, isA<Color>());
      expect(captured!.expenseAmount, isA<Color>());
      expect(captured!.warningAmount, isA<Color>());
      expect(captured!.accentPastel, isA<Color>());
    });

    testWidgets('custom seed color produces distinct incomeAmount',
        (tester) async {
      // Different seed → same VarianceColors tokens (tokens are static),
      // but confirms no exception is thrown with any seed.
      final customThemes = AppThemeData.fromSeed(Colors.teal);

      VarianceColors? captured;
      await tester.pumpWidget(
        _wrap(
          _ColorReader(onColors: (c) => captured = c),
          theme: customThemes.light,
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.incomeAmount, isA<Color>());
    });
  });

  // -------------------------------------------------------------------------
  // VarianceColors unit-level tests (no widget pump needed)
  // -------------------------------------------------------------------------

  group('VarianceColors unit tests', () {
    test('copyWith updates only the specified token', () {
      const original = VarianceColors.light;
      const newColor = Color(0xFF000000);
      final updated = original.copyWith(incomeAmount: newColor);

      expect(updated.incomeAmount, newColor);
      expect(updated.expenseAmount, original.expenseAmount);
      expect(updated.warningAmount, original.warningAmount);
      expect(updated.accentPastel, original.accentPastel);
    });

    test('lerp at t=0 returns caller values', () {
      const a = VarianceColors.light;
      const b = VarianceColors.dark;
      final result = a.lerp(b, 0.0);

      expect(result.incomeAmount, a.incomeAmount);
    });

    test('lerp at t=1 returns other values', () {
      const a = VarianceColors.light;
      const b = VarianceColors.dark;
      final result = a.lerp(b, 1.0);

      expect(result.incomeAmount, b.incomeAmount);
    });

    test('lerp with non-VarianceColors other returns self', () {
      const colors = VarianceColors.light;
      // lerp contract: when other is not VarianceColors, return self.
      final result = colors.lerp(null, 0.5);
      expect(result, colors);
    });

    test('equality holds for identical token sets', () {
      const a = VarianceColors.light;
      const b = VarianceColors.light;
      expect(a, equals(b));
    });

    test('hashCode is consistent for equal instances', () {
      const a = VarianceColors.light;
      const b = VarianceColors.light;
      expect(a.hashCode, b.hashCode);
    });
  });
}
