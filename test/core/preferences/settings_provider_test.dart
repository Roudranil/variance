import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:variance/core/preferences/preferences_keys.dart';
import 'package:variance/core/preferences/settings_provider.dart';

void main() {
  // set up the mock for shared_preferences before each test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider', () {
    group('Default Values', () {
      test('should have correct default values before loading', () {
        final provider = SettingsProvider();

        expect(provider.themeMode, ThemeMode.system);
        expect(provider.accentColor, isNull);
        expect(provider.useDynamicColor, isTrue);
        expect(provider.currencyCode, 'INR');
        expect(provider.locale, 'en_IN');
      });
    });

    group('loadFromPrefs', () {
      test('should load theme mode from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({kThemeModeKey: 'dark'});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.themeMode, ThemeMode.dark);
      });

      test('should load light theme mode correctly', () async {
        SharedPreferences.setMockInitialValues({kThemeModeKey: 'light'});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.themeMode, ThemeMode.light);
      });

      test('should default to system theme for invalid value', () async {
        SharedPreferences.setMockInitialValues({kThemeModeKey: 'invalid'});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.themeMode, ThemeMode.system);
      });

      test('should load accent color from SharedPreferences', () async {
        const testColor = 0xFF123456;
        SharedPreferences.setMockInitialValues({kAccentColorKey: testColor});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.accentColor, const Color(testColor));
      });

      test(
        'should load dynamic color setting from SharedPreferences',
        () async {
          SharedPreferences.setMockInitialValues({kUseDynamicColorKey: false});

          final provider = SettingsProvider();
          await provider.loadFromPrefs();

          expect(provider.useDynamicColor, isFalse);
        },
      );

      test('should load currency code from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({kCurrencyCodeKey: 'USD'});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.currencyCode, 'USD');
      });

      test('should load locale from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({kLocaleKey: 'en_US'});

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.locale, 'en_US');
      });

      test('should load all settings together', () async {
        SharedPreferences.setMockInitialValues({
          kThemeModeKey: 'dark',
          kAccentColorKey: 0xFFABCDEF,
          kUseDynamicColorKey: false,
          kCurrencyCodeKey: 'EUR',
          kLocaleKey: 'de_DE',
        });

        final provider = SettingsProvider();
        await provider.loadFromPrefs();

        expect(provider.themeMode, ThemeMode.dark);
        expect(provider.accentColor, const Color(0xFFABCDEF));
        expect(provider.useDynamicColor, isFalse);
        expect(provider.currencyCode, 'EUR');
        expect(provider.locale, 'de_DE');
      });

      test('should notify listeners after loading', () async {
        SharedPreferences.setMockInitialValues({kThemeModeKey: 'dark'});

        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.loadFromPrefs();

        expect(notified, isTrue);
      });
    });

    group('setThemeMode', () {
      test('should update theme mode and notify listeners', () async {
        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.setThemeMode(ThemeMode.dark);

        expect(provider.themeMode, ThemeMode.dark);
        expect(notified, isTrue);
      });

      test('should persist theme mode to SharedPreferences', () async {
        final provider = SettingsProvider();
        await provider.setThemeMode(ThemeMode.dark);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(kThemeModeKey), 'dark');
      });

      test('should not notify if value is unchanged', () async {
        final provider = SettingsProvider();
        await provider.setThemeMode(ThemeMode.system);

        var notified = false;
        provider.addListener(() => notified = true);

        // setting to same value
        await provider.setThemeMode(ThemeMode.system);

        expect(notified, isFalse);
      });
    });

    group('toggleThemeMode', () {
      test('should toggle from light to dark', () async {
        final provider = SettingsProvider();
        await provider.setThemeMode(ThemeMode.light);

        await provider.toggleThemeMode();

        expect(provider.themeMode, ThemeMode.dark);
      });

      test('should toggle from dark to light', () async {
        final provider = SettingsProvider();
        await provider.setThemeMode(ThemeMode.dark);

        await provider.toggleThemeMode();

        expect(provider.themeMode, ThemeMode.light);
      });

      test('should toggle from system to light', () async {
        final provider = SettingsProvider();
        // default is system
        await provider.toggleThemeMode();

        expect(provider.themeMode, ThemeMode.light);
      });
    });

    group('setAccentColor', () {
      test('should update accent color and notify listeners', () async {
        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.setAccentColor(Colors.red);

        expect(provider.accentColor, Colors.red);
        expect(notified, isTrue);
      });

      test('should disable dynamic color when setting accent color', () async {
        final provider = SettingsProvider();
        expect(provider.useDynamicColor, isTrue);

        await provider.setAccentColor(Colors.blue);

        expect(provider.useDynamicColor, isFalse);
      });

      test('should persist accent color to SharedPreferences', () async {
        final provider = SettingsProvider();
        await provider.setAccentColor(const Color(0xFF123456));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(kAccentColorKey), 0xFF123456);
      });

      test('should remove accent color from prefs when set to null', () async {
        final provider = SettingsProvider();
        await provider.setAccentColor(Colors.red);
        await provider.setAccentColor(null);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(kAccentColorKey), isNull);
      });

      test('should not notify if value is unchanged', () async {
        final provider = SettingsProvider();

        var notified = false;
        provider.addListener(() => notified = true);

        // accent color is already null
        await provider.setAccentColor(null);

        expect(notified, isFalse);
      });
    });

    group('toggleDynamicColor', () {
      test('should toggle dynamic color and notify listeners', () async {
        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.toggleDynamicColor(false);

        expect(provider.useDynamicColor, isFalse);
        expect(notified, isTrue);
      });

      test(
        'should persist dynamic color setting to SharedPreferences',
        () async {
          final provider = SettingsProvider();
          await provider.toggleDynamicColor(false);

          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool(kUseDynamicColorKey), isFalse);
        },
      );

      test('should not notify if value is unchanged', () async {
        final provider = SettingsProvider();

        var notified = false;
        provider.addListener(() => notified = true);

        // dynamic color is already true
        await provider.toggleDynamicColor(true);

        expect(notified, isFalse);
      });
    });

    group('setCurrencyCode', () {
      test('should update currency code and notify listeners', () async {
        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.setCurrencyCode('USD');

        expect(provider.currencyCode, 'USD');
        expect(notified, isTrue);
      });

      test('should persist currency code to SharedPreferences', () async {
        final provider = SettingsProvider();
        await provider.setCurrencyCode('EUR');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(kCurrencyCodeKey), 'EUR');
      });

      test('should not notify if value is unchanged', () async {
        final provider = SettingsProvider();

        var notified = false;
        provider.addListener(() => notified = true);

        // currency is already INR
        await provider.setCurrencyCode('INR');

        expect(notified, isFalse);
      });
    });

    group('setLocale', () {
      test('should update locale and notify listeners', () async {
        final provider = SettingsProvider();
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.setLocale('en_US');

        expect(provider.locale, 'en_US');
        expect(notified, isTrue);
      });

      test('should persist locale to SharedPreferences', () async {
        final provider = SettingsProvider();
        await provider.setLocale('de_DE');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(kLocaleKey), 'de_DE');
      });

      test('should not notify if value is unchanged', () async {
        final provider = SettingsProvider();

        var notified = false;
        provider.addListener(() => notified = true);

        // locale is already en_IN
        await provider.setLocale('en_IN');

        expect(notified, isFalse);
      });
    });

    group('Integration', () {
      test('should persist and reload settings correctly', () async {
        // first session: set some preferences
        final provider1 = SettingsProvider();
        await provider1.setThemeMode(ThemeMode.dark);
        await provider1.setAccentColor(const Color(0xFFFF0000));
        await provider1.setCurrencyCode('JPY');
        await provider1.setLocale('ja_JP');

        // simulate app restart: create new provider and load
        final provider2 = SettingsProvider();
        await provider2.loadFromPrefs();

        expect(provider2.themeMode, ThemeMode.dark);
        expect(provider2.accentColor, const Color(0xFFFF0000));
        expect(provider2.useDynamicColor, isFalse); // disabled when accent set
        expect(provider2.currencyCode, 'JPY');
        expect(provider2.locale, 'ja_JP');
      });
    });
  });
}
