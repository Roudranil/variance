// test/providers/app_settings_providers_test.dart
//
// Tests for AppSettingsNotifier and appSettingsProvider (T-173).
//
// Uses a FakeAppSettingsRepository to avoid requiring a real database.
//
// Test cases:
//   1. appSettingsProvider emits AppSettings with onboardingComplete=false
//      for a fresh in-memory database.
//   2. AppSettingsNotifier initial build resolves with default AppSettings.
//   3. AppSettingsNotifier.save propagates a theme patch; stream emits new value.
//   4. AppSettingsNotifier.save throws when repository returns Err.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/database_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

/// In-memory [IAppSettingsRepository] backed by a [StreamController].
///
/// Allows tests to push new [AppSettings] values and verify that the notifier
/// reacts correctly. An optional [updateError] causes [update] to return an
/// [Err].
class _FakeAppSettingsRepository implements IAppSettingsRepository {
  _FakeAppSettingsRepository({this.updateError})
      : _current = const AppSettings();

  AppSettings _current;

  /// When non-null, [update] returns [Err] with this failure.
  final Failure? updateError;

  // Each watch() call returns a fresh stream that starts with _current and
  // then reflects future updates via the broadcast controller.
  //
  // Using StreamController.broadcast ensures that the notifier's listen() call
  // (inside build()) receives the initial value synchronously on subscription.
  final _updates = StreamController<AppSettings>.broadcast();

  @override
  Stream<AppSettings> watch() async* {
    // Emit the current value immediately upon subscription so the Completer
    // inside AppSettingsNotifier.build() resolves without waiting.
    yield _current;
    // Then forward any subsequent updates pushed via update().
    yield* _updates.stream;
  }

  @override
  Future<Result<void>> update(AppSettingsPatch patch) async {
    if (updateError != null) return Err(updateError!);

    // Apply the patch and push the new value to listeners.
    _current = _current.copyWith(
      theme: patch.theme ?? _current.theme,
      homeCurrency: patch.homeCurrency ?? _current.homeCurrency,
      onboardingComplete:
          patch.onboardingComplete ?? _current.onboardingComplete,
    );
    _updates.add(_current);
    return const Ok(null);
  }

  /// Closes the underlying stream controller.
  Future<void> close() => _updates.close();
}

// ---------------------------------------------------------------------------
// Helper: ProviderContainer with fake repository override
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({Failure? updateError}) {
  final fakeRepo = _FakeAppSettingsRepository(updateError: updateError);

  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWith((_) async => fakeRepo),
    ],
  );

  addTearDown(() async {
    container.dispose();
    await fakeRepo.close();
  });

  return container;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Ensure Flutter bindings are available for the integration test (test 1).
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // appSettingsProvider (StreamProvider) integration test
  // ---------------------------------------------------------------------------

  group('appSettingsProvider (integration)', () {
    test(
        '1. emits AppSettings with onboardingComplete=false for fresh database',
        () async {
      final inMemoryDb = AppDatabase.forTesting();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((_) async => inMemoryDb),
        ],
      );

      addTearDown(() async {
        container.dispose();
        await inMemoryDb.close();
      });

      // Resolve the stream provider (StreamProvider wraps in AsyncValue).
      final asyncValue = await container.read(appSettingsProvider.future);
      expect(asyncValue.onboardingComplete, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // AppSettingsNotifier unit tests (with fake repository)
  // ---------------------------------------------------------------------------

  group('AppSettingsNotifier', () {
    test('2. initial build resolves with default AppSettings', () async {
      final container = _makeContainer();

      final settings = await container.read(appSettingsProvider.future);
      // Default entity has onboardingComplete = false, theme = system.
      expect(settings.onboardingComplete, isFalse);
      expect(settings.theme, equals(AppTheme.system));
    });

    test(
        '3. update propagates a theme patch; subsequent build resolves with '
        'new theme', () async {
      final container = _makeContainer();

      // Ensure initial build completes.
      await container.read(appSettingsProvider.future);

      // Apply the patch via the notifier.
      await container
          .read(appSettingsProvider.notifier)
          .save(const AppSettingsPatch(theme: AppTheme.dark));

      // The stream emission updates state; read the resolved future.
      final settings = await container.read(appSettingsProvider.future);
      expect(settings.theme, equals(AppTheme.dark));
    });

    test('4. update throws when repository returns Err', () async {
      final container = _makeContainer(
        updateError: const DatabaseFailure('write failed'),
      );

      // Ensure build completes first.
      await container.read(appSettingsProvider.future);

      // The update should throw because the repository returned Err.
      await expectLater(
        container.read(appSettingsProvider.notifier).save(
              const AppSettingsPatch(theme: AppTheme.dark),
            ),
        throwsException,
      );
    });
  });
}
