import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/logger.dart';
import 'features/home/screens/home_screen.dart';

/// The root widget of the application.
///
/// This widget initializes the [MaterialApp] with the application theme and
/// home page. It sets up the [ThemeProvider] and [DynamicColorBuilder] to
/// handle dynamic and custom theming.
class VarianceApp extends StatelessWidget {
  /// Creates a new instance of [VarianceApp].
  const VarianceApp({super.key});

  @override
  Widget build(BuildContext context) {
    VarianceLogger.info('Building VarianceApp');
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final useDynamic = themeProvider.useDynamicColor;
              final accent = themeProvider.accentColor;
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
                themeMode: themeProvider.themeMode,
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
