// lib/data/repositories/app_settings_repository_impl.dart
//
// Concrete implementation of IAppSettingsRepository backed by Drift.
//
// Reads from and writes to the app_settings key-value table directly via
// the AppDatabase (no dedicated DAO — the table is queried inline).
//
// This implementation provides only the onboarding flag lookup required for
// the GoRouter redirect guard (T-16). Full settings management is implemented
// in later feature tasks (S-9).

import 'package:drift/drift.dart';
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

/// Drift-backed implementation of [IAppSettingsRepository].
///
/// Reads the full key-value set from [AppSettings] rows and maps them to
/// the typed [AppSettings] domain entity. Partial updates are applied by
/// writing only the changed keys.
class AppSettingsRepositoryImpl implements IAppSettingsRepository {
  /// Creates an [AppSettingsRepositoryImpl] that reads from and writes to [db].
  const AppSettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  // -----------------------------------------------------------------------
  // IAppSettingsRepository
  // -----------------------------------------------------------------------

  @override
  Stream<AppSettings> watch() {
    // Watch all rows in the app_settings table; rebuild the entity on each
    // emission. The KV store is small enough that a full-table re-read on
    // every change is acceptable.
    return (_db.select(_db.appSettings)).watch().map(_rowsToEntity);
  }

  @override
  Future<Result<void>> update(AppSettingsPatch patch) async {
    try {
      await _db.transaction(() async {
        await _maybeWrite(_kHomeCurrency, patch.homeCurrency);
        await _maybeWrite(
          _kTheme,
          patch.theme?.name,
        );
        await _maybeWrite(_kColorSchemeMode, patch.colorSchemeMode?.name);
        await _maybeWrite(_kColorSeed, patch.colorSeed);
        if (patch.animationsEnabled != null) {
          await _maybeWrite(
            _kAnimationsEnabled,
            patch.animationsEnabled! ? '1' : '0',
          );
        }
        await _maybeWrite(_kWeekStart, patch.weekStart?.name);
        if (patch.percentagePrecision != null) {
          await _maybeWrite(
            _kPercentagePrecision,
            patch.percentagePrecision!.toString(),
          );
        }
        if (patch.descriptionMaxLength != null) {
          await _maybeWrite(
            _kDescriptionMaxLength,
            patch.descriptionMaxLength!.toString(),
          );
        }
        await _maybeWrite(
          _kBackButtonBehaviour,
          patch.backButtonBehaviour?.name,
        );
        if (patch.lockTimeoutSeconds != null) {
          await _maybeWrite(
            _kLockTimeoutSeconds,
            patch.lockTimeoutSeconds!.toString(),
          );
        }
        await _maybeWrite(_kDisplayName, patch.displayName);
        if (patch.onboardingComplete != null) {
          await _maybeWrite(
            _kOnboardingComplete,
            patch.onboardingComplete! ? '1' : '0',
          );
        }
        if (patch.lastExchangeRateFetch != null) {
          await _maybeWrite(
            _kLastExchangeRateFetch,
            patch.lastExchangeRateFetch!.toString(),
          );
        }
      });
      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure(e.toString()));
    }
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Writes [value] for [key] only when [value] is non-null.
  ///
  /// Uses upsert semantics (INSERT OR REPLACE) so the call is idempotent.
  Future<void> _maybeWrite(String key, String? value) async {
    if (value == null) return;
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: Value(value),
            updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        );
  }

  /// Maps a list of [AppSetting] Drift rows into the typed [AppSettings]
  /// domain entity.
  ///
  /// Unknown keys are ignored silently. Missing keys use the entity defaults.
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

// DatabaseFailure is defined in domain/core/failure.dart.
