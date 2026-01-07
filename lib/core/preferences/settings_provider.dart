import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:variance/core/preferences/preferences_keys.dart';
import 'package:variance/core/utils/logger.dart';

/// color, dynamic color settings, currency code, and locale. All changes are
/// persisted to [SharedPreferences] and loaded on application startup.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color? _accentColor;
  bool _useDynamicColor = true;
  String _currencyCode = 'INR';
  String _locale = 'en_IN';

  /// The current theme mode (system, light, or dark).
  ThemeMode get themeMode => _themeMode;

  /// The custom accent color selected by the user, if any.
  ///
  /// If null and [useDynamicColor] is false, a default theme color will be
  /// used.
  Color? get accentColor => _accentColor;

  /// Whether to use dynamic colors from the system wallpaper.
  bool get useDynamicColor => _useDynamicColor;

  /// The user's preferred currency code (ISO 4217, e.g., "USD", "INR").
  String get currencyCode => _currencyCode;

  /// The user's preferred locale string (e.g., "en_US", "en_IN").
  String get locale => _locale;

  /// Loads user preferences from persistent storage.
  ///
  /// This method should be called once during application initialization,
  /// before [runApp]. It populates all settings from [SharedPreferences].
  Future<void> loadFromPrefs() async {
    VarianceLogger.info('Loading user preferences from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();

    // load theme mode
    final themeModeString = prefs.getString(kThemeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    // load accent color
    final accentColorValue = prefs.getInt(kAccentColorKey);
    if (accentColorValue != null) {
      _accentColor = Color(accentColorValue);
    }

    // load dynamic color preference
    _useDynamicColor = prefs.getBool(kUseDynamicColorKey) ?? true;

    // load currency and locale
    _currencyCode = prefs.getString(kCurrencyCodeKey) ?? 'INR';
    _locale = prefs.getString(kLocaleKey) ?? 'en_IN';

    VarianceLogger.info(
      'Preferences loaded: themeMode=$_themeMode, '
      'dynamicColor=$_useDynamicColor, currency=$_currencyCode, '
      'locale=$_locale',
    );
    notifyListeners();
  }

  /// Sets the theme mode and persists the change.
  ///
  /// Parameters:
  /// - [mode]: The new theme mode to apply.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kThemeModeKey, mode.name);
      VarianceLogger.info('Theme mode set to: $mode');
    }
  }

  /// Toggles between light and dark mode.
  ///
  /// If the current mode is system, it defaults to dark.
  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Sets the custom accent color and persists the change.
  ///
  /// This will automatically disable dynamic colors if a color is provided.
  ///
  /// Parameters:
  /// - [color]: The accent color to set. Pass null to clear the custom color.
  Future<void> setAccentColor(Color? color) async {
    if (_accentColor != color) {
      _accentColor = color;
      if (color != null) {
        _useDynamicColor = false;
      }
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      if (color != null) {
        await prefs.setInt(kAccentColorKey, color.toARGB32());
        await prefs.setBool(kUseDynamicColorKey, false);
      } else {
        await prefs.remove(kAccentColorKey);
      }
      VarianceLogger.info('Accent color set to: $color');
    }
  }

  /// Toggles the usage of dynamic colors and persists the change.
  ///
  /// Parameters:
  /// - [value]: Whether dynamic colors should be enabled.
  Future<void> toggleDynamicColor(bool value) async {
    if (_useDynamicColor != value) {
      _useDynamicColor = value;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kUseDynamicColorKey, value);
      VarianceLogger.info('Dynamic color toggled to: $value');
    }
  }

  /// Sets the currency code and persists the change.
  ///
  /// Parameters:
  /// - [code]: The ISO 4217 currency code (e.g., "USD", "EUR", "INR").
  Future<void> setCurrencyCode(String code) async {
    if (_currencyCode != code) {
      _currencyCode = code;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kCurrencyCodeKey, code);
      VarianceLogger.info('Currency code set to: $code');
    }
  }

  /// Sets the locale and persists the change.
  ///
  /// Parameters:
  /// - [localeString]: The locale string (e.g., "en_US", "en_IN").
  Future<void> setLocale(String localeString) async {
    if (_locale != localeString) {
      _locale = localeString;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kLocaleKey, localeString);
      VarianceLogger.info('Locale set to: $localeString');
    }
  }
}
