// test/data/repositories/app_settings_repository_impl_test.dart
//
// Integration tests for AppSettingsRepositoryImpl against an in-memory Drift DB.
//
// Test cases:
//   1. watch — emits AppSettings with onboardingComplete=false after seed
//   2. watch — emits updated value after update(patch)
//   3. update — patch with single field only writes that key (others unchanged)
//   4. update — upsert idempotency: second update overwrites previous value
//   5. update — returns Ok(null) on success
//   6. watch — homeCurrency reflects value set via patch

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/app_settings_dao.dart';
import 'package:variance/data/repositories/app_settings_repository_impl.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AppSettingsDao dao;
  late AppSettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.appSettingsDao;
    repo = AppSettingsRepositoryImpl(dao);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // watch
  // ---------------------------------------------------------------------------

  group('watch', () {
    test('1. emits AppSettings with onboardingComplete=false after seed',
        () async {
      // onCreate seeds onboarding_complete='0'.
      final settings = await repo.watch().first;
      expect(settings.onboardingComplete, isFalse);
    });

    test('2. emits updated value after update(patch)', () async {
      await repo.update(
        const AppSettingsPatch(homeCurrency: 'USD'),
      );
      final settings = await repo.watch().first;
      expect(settings.homeCurrency, equals('USD'));
    });

    test('6. homeCurrency reflects value set via patch', () async {
      await repo.update(
        const AppSettingsPatch(homeCurrency: 'EUR'),
      );
      final settings = await repo.watch().first;
      expect(settings.homeCurrency, equals('EUR'));
    });
  });

  // ---------------------------------------------------------------------------
  // update
  // ---------------------------------------------------------------------------

  group('update', () {
    test('3. patch with single field leaves other fields at default', () async {
      // Only update the theme; all other fields should retain seed defaults.
      await repo.update(
        const AppSettingsPatch(theme: AppTheme.dark),
      );
      final settings = await repo.watch().first;
      expect(settings.theme, equals(AppTheme.dark));
      // homeCurrency should still be 'INR' from the seed.
      expect(settings.homeCurrency, equals('INR'));
    });

    test('4. second update overwrites previous value', () async {
      await repo.update(
        const AppSettingsPatch(theme: AppTheme.dark),
      );
      await repo.update(
        const AppSettingsPatch(theme: AppTheme.light),
      );
      final settings = await repo.watch().first;
      expect(settings.theme, equals(AppTheme.light));
    });

    test('5. returns Ok(null) on success', () async {
      final result = await repo.update(
        const AppSettingsPatch(homeCurrency: 'JPY'),
      );
      expect(result, isA<Ok<void>>());
    });
  });
}
