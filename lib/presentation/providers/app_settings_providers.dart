// lib/presentation/providers/app_settings_providers.dart
//
// Riverpod providers for the AppSettings stream.
//
// appSettingsProvider is a StreamProvider that exposes the live AppSettings
// entity. It is keepAlive because the settings are read by the GoRouter
// redirect guard and must never be auto-disposed.
//
// Used by:
//   - GoRouter redirect guard (onboarding check)
//   - Theme provider (future task)
//   - Settings screen notifier (future task)
//
// Test cases (see test/providers/database_providers_test.dart):
//   - appSettingsProvider emits AppSettings with onboardingComplete=false
//     for a fresh in-memory database.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'app_settings_providers.g.dart';

/// Watches the live [AppSettings] entity from the database.
///
/// Emits the full settings object on every change to any setting key.
/// Emits defaults when the database is empty (first launch).
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) async* {
  final repo = await ref.watch(appSettingsRepositoryProvider.future);
  yield* repo.watch();
}
