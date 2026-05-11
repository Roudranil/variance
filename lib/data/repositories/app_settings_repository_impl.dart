// lib/data/repositories/app_settings_repository_impl.dart
//
// Concrete implementation of IAppSettingsRepository backed by AppSettingsDao.
//
// Reads from and writes to the app_settings key-value table via the dedicated
// AppSettingsDao. Partial updates are applied by writing only the changed keys.
//
// Test cases (see test/data/repositories/app_settings_repository_impl_test.dart):
//   1. watch — emits defaults after seedDefaults
//   2. watch — emits updated value after update(patch)
//   3. update — patch with single field only writes that key
//   4. update — upsert idempotency: calling update twice yields last value
//   5. update — returns Err(DatabaseFailure) on DAO exception

import 'package:variance/data/database/daos/app_settings_dao.dart';
import 'package:variance/data/database/app_database.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';

// ---------------------------------------------------------------------------
// Key constants
// ---------------------------------------------------------------------------

/// app_settings key for the onboarding completion flag.
///
/// Stored as '0' (false) or '1' (true). Default is '0'.
const _kOnboardingComplete = 'onboarding_complete';

/// app_settings key for the home currency code.
const _kHomeCurrency = 'home_currency';

/// app_settings key for the theme mode.
const _kTheme = 'theme';

/// app_settings key for the color scheme mode.
const _kColorSchemeMode = 'color_scheme_mode';

/// app_settings key for the color seed hex string.
const _kColorSeed = 'color_seed';

/// app_settings key for animations enabled flag.
const _kAnimationsEnabled = 'animations_enabled';

/// app_settings key for week start day.
const _kWeekStart = 'week_start';

/// app_settings key for percentage precision.
const _kPercentagePrecision = 'percentage_precision';

/// app_settings key for description max length.
const _kDescriptionMaxLength = 'description_max_length';

/// app_settings key for back button behaviour.
const _kBackButtonBehaviour = 'back_button_behaviour';

/// app_settings key for lock timeout in seconds.
const _kLockTimeoutSeconds = 'lock_timeout_seconds';

/// app_settings key for display name.
const _kDisplayName = 'display_name';

/// app_settings key for last exchange rate fetch epoch.
const _kLastExchangeRateFetch = 'last_exchange_rate_fetch';

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Drift DAO-backed implementation of [IAppSettingsRepository].
///
/// Delegates all table access to [AppSettingsDao]. Partial updates are applied
/// by writing only the non-null fields from [AppSettingsPatch]; null fields are
/// left unchanged. The typed [AppSettings] entity is assembled from all current
/// KV rows on every stream emission.
class AppSettingsRepositoryImpl implements IAppSettingsRepository {
  /// Creates an [AppSettingsRepositoryImpl] backed by [dao].
  const AppSettingsRepositoryImpl(this._dao);

  final AppSettingsDao _dao;

  // -----------------------------------------------------------------------
  // IAppSettingsRepository
  // -----------------------------------------------------------------------

  @override
  Stream<AppSettings> watch() {
    // Watch all rows in app_settings; rebuild the typed entity on each
    // emission. The KV table is small so a full-table re-read on every
    // change is acceptable.
    return _dao.watch().map(_rowsToEntity);
  }

  @override
  Future<Result<void>> update(AppSettingsPatch patch) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Write only the non-null patch fields; each is an independent upsert.
      await _maybeUpsert(_kHomeCurrency, patch.homeCurrency, now);
      await _maybeUpsert(_kTheme, patch.theme?.name, now);
      await _maybeUpsert(_kColorSchemeMode, patch.colorSchemeMode?.name, now);
      await _maybeUpsert(_kColorSeed, patch.colorSeed, now);

      if (patch.animationsEnabled != null) {
        await _dao.upsert(
          _kAnimationsEnabled,
          patch.animationsEnabled! ? '1' : '0',
          now,
        );
      }

      await _maybeUpsert(_kWeekStart, patch.weekStart?.name, now);

      if (patch.percentagePrecision != null) {
        await _dao.upsert(
          _kPercentagePrecision,
          patch.percentagePrecision!.toString(),
          now,
        );
      }

      if (patch.descriptionMaxLength != null) {
        await _dao.upsert(
          _kDescriptionMaxLength,
          patch.descriptionMaxLength!.toString(),
          now,
        );
      }

      await _maybeUpsert(
        _kBackButtonBehaviour,
        patch.backButtonBehaviour?.name,
        now,
      );

      if (patch.lockTimeoutSeconds != null) {
        await _dao.upsert(
          _kLockTimeoutSeconds,
          patch.lockTimeoutSeconds!.toString(),
          now,
        );
      }

      await _maybeUpsert(_kDisplayName, patch.displayName, now);

      if (patch.onboardingComplete != null) {
        await _dao.upsert(
          _kOnboardingComplete,
          patch.onboardingComplete! ? '1' : '0',
          now,
        );
      }

      if (patch.lastExchangeRateFetch != null) {
        await _dao.upsert(
          _kLastExchangeRateFetch,
          patch.lastExchangeRateFetch!.toString(),
          now,
        );
      }

      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure(e.toString()));
    }
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Upserts [key] → [value] only when [value] is non-null.
  Future<void> _maybeUpsert(String key, String? value, int nowEpoch) async {
    if (value == null) return;
    await _dao.upsert(key, value, nowEpoch);
  }

  /// Maps a list of [AppSetting] Drift rows into the typed [AppSettings]
  /// domain entity.
  ///
  /// Unknown keys are ignored silently. Missing keys fall back to the entity
  /// defaults declared on the [AppSettings] Freezed factory.
  AppSettings _rowsToEntity(List<AppSetting> rows) {
    // Build a key → value lookup map.
    final kv = {for (final row in rows) row.key: row.value};

    return AppSettings(
      homeCurrency: kv[_kHomeCurrency] ?? 'INR',
      theme: _parseEnum(kv[_kTheme], AppTheme.values) ?? AppTheme.system,
      colorSchemeMode:
          _parseEnum(kv[_kColorSchemeMode], ColorSchemeMode.values) ??
              ColorSchemeMode.dynamic,
      colorSeed: kv[_kColorSeed],
      animationsEnabled: kv[_kAnimationsEnabled] != '0',
      weekStart:
          _parseEnum(kv[_kWeekStart], WeekStart.values) ?? WeekStart.monday,
      percentagePrecision: int.tryParse(kv[_kPercentagePrecision] ?? '') ?? 0,
      descriptionMaxLength:
          int.tryParse(kv[_kDescriptionMaxLength] ?? '') ?? 1000,
      backButtonBehaviour:
          _parseEnum(kv[_kBackButtonBehaviour], BackButtonBehaviour.values) ??
              BackButtonBehaviour.ask,
      lockTimeoutSeconds: int.tryParse(kv[_kLockTimeoutSeconds] ?? '') ?? 0,
      displayName: kv[_kDisplayName],
      onboardingComplete: kv[_kOnboardingComplete] == '1',
      lastExchangeRateFetch: int.tryParse(kv[_kLastExchangeRateFetch] ?? ''),
    );
  }

  /// Parses an enum value by [name] from [values], returning null if not found.
  T? _parseEnum<T extends Enum>(String? name, List<T> values) {
    if (name == null) return null;
    return values.where((v) => v.name == name).firstOrNull;
  }
}
