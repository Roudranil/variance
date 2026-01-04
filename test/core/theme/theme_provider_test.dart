import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/core/theme/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('Initial state is correct', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.useDynamicColor, true);
      expect(provider.accentColor, null);
    });

    test('toggleThemeMode updates mode', () {
      final provider = ThemeProvider();

      // System -> Light (toggle logic: if light -> dark, else light)
      // Initial is System.

      provider.toggleThemeMode(); // System != Light -> set Light
      expect(provider.themeMode, ThemeMode.light);

      provider.toggleThemeMode(); // Light -> set Dark
      expect(provider.themeMode, ThemeMode.dark);

      provider.toggleThemeMode(); // Dark != Light -> set Light
      expect(provider.themeMode, ThemeMode.light);
    });

    test('setAccentColor disables dynamic color', () {
      final provider = ThemeProvider();

      expect(provider.useDynamicColor, true);

      provider.setAccentColor(Colors.blue);
      expect(provider.accentColor, Colors.blue);
      expect(provider.useDynamicColor, false);

      provider.setAccentColor(null);
      // Logic says: if color != null -> _useDynamicColor = false.
      // But if color == null? It just sets _accentColor to null. It DOES NOT re-enable dynamic color automatically.
      expect(provider.accentColor, null);
      expect(provider.useDynamicColor, false);
    });

    test('toggleDynamicColor works', () {
      final provider = ThemeProvider();
      expect(provider.useDynamicColor, true);

      provider.toggleDynamicColor(false);
      expect(provider.useDynamicColor, false);
    });
  });
}
