import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:variance/core/preferences/settings_provider.dart';
import 'package:variance/features/settings/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createSettingsScreen() {
    final settingsProvider = SettingsProvider();
    return ChangeNotifierProvider<SettingsProvider>.value(
      value: settingsProvider,
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders with AppBar title', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays Appearance section', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dynamic Color'), findsOneWidget);
    });

    testWidgets('displays Regional section', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Regional'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Locale'), findsOneWidget);
    });

    testWidgets('displays Data Management section', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
    });

    testWidgets('displays About section', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Acknowledgements'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('theme segmented button is present', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    });

    testWidgets('dynamic color switch is present', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('toggling dynamic color updates provider', (tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // initial state should be dynamic color enabled
      expect(settingsProvider.useDynamicColor, isTrue);

      // find the switch and tap it
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // dynamic color should now be disabled
      expect(settingsProvider.useDynamicColor, isFalse);
    });

    testWidgets('selecting theme mode updates provider', (tester) async {
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // default theme mode is system
      expect(settingsProvider.themeMode, ThemeMode.system);

      // tap dark mode button (third segment)
      final darkModeIcon = find.byIcon(Icons.dark_mode);
      await tester.tap(darkModeIcon);
      await tester.pumpAndSettle();

      // theme should now be dark
      expect(settingsProvider.themeMode, ThemeMode.dark);
    });
  });
}
