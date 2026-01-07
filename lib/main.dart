import 'package:flutter/material.dart';

import 'app.dart';
import 'core/preferences/settings_provider.dart';
import 'core/utils/logger.dart';

/// The entry point of the application.
///
/// Initializes essential services before running the app, including loading
/// user preferences from persistent storage.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VarianceLogger.info('Application starting...');

  // load user preferences from shared_preferences before building the UI
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadFromPrefs();

  runApp(VarianceApp(settingsProvider: settingsProvider));
}
