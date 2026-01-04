import 'package:flutter/material.dart';

/// Manages the theme state of the application.
///
/// This provider handles handling the active [ThemeMode], the user's preferred
/// accent color, and whether to use dynamic (wallpaper-based) colors.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color? _accentColor;
  bool _useDynamicColor = true;

  /// The current theme mode (system, light, or dark).
  ThemeMode get themeMode => _themeMode;

  /// The custom accent color selected by the user, if any.
  ///
  /// If null and [_useDynamicColor] is false, a default theme color will be used.
  Color? get accentColor => _accentColor;

  /// Whether to use dynamic colors from the system wallpaper.
  bool get useDynamicColor => _useDynamicColor;

  /// Sets the theme mode.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Toggles between light and dark mode.
  ///
  /// If the current mode is system, it defaults to dark.
  void toggleThemeMode() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  /// Sets the custom accent color.
  ///
  /// This will automatically disable dynamic colors if a color is provided.
  void setAccentColor(Color? color) {
    if (_accentColor != color) {
      _accentColor = color;
      if (color != null) {
        _useDynamicColor = false;
      }
      notifyListeners();
    }
  }

  /// Toggles the usage of dynamic colors.
  void toggleDynamicColor(bool value) {
    if (_useDynamicColor != value) {
      _useDynamicColor = value;
      notifyListeners();
    }
  }
}
