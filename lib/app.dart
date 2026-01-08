import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

import 'core/preferences/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'database/database.dart';
import 'features/home/screens/home_screen.dart';

/// The root widget of the application.
///
/// This widget initializes the [MaterialApp] with the application theme and
/// home page. It sets up the [SettingsProvider] and [DynamicColorBuilder] to
/// handle dynamic and custom theming. The [SettingsProvider] is passed in
/// after being pre-initialized with persisted preferences.
class VarianceApp extends StatelessWidget {
  /// Creates a new instance of [VarianceApp].
  ///
  /// Parameters:
  /// - [settingsProvider]: The pre-initialized settings provider with loaded
  ///   preferences.
  /// - [database]: Optional database instance for testing.
  const VarianceApp({required this.settingsProvider, this.database, super.key});

  /// The settings provider instance, pre-loaded with user preferences.
  final SettingsProvider settingsProvider;

  /// Optional database instance. If null, creates a new AppDatabase.
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    VarianceLogger.info('Building VarianceApp');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        Provider<AppDatabase>(
          create: (_) => database ?? AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final useDynamic = settings.useDynamicColor;
              final accent = settings.accentColor;
              VarianceLogger.info('Building MaterialApp');
              return MaterialApp(
                title: 'Variance',
                theme: AppTheme.define(
                  brightness: Brightness.light,
                  seedColor: useDynamic ? lightDynamic?.primary : accent,
                ),
                darkTheme: AppTheme.define(
                  brightness: Brightness.dark,
                  seedColor: useDynamic ? darkDynamic?.primary : accent,
                ),
                themeMode: settings.themeMode,
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
