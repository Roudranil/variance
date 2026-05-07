// lib/domain/repositories/i_app_settings_repository.dart
//
// Abstract repository interface for the AppSettings aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';

/// Partial patch object for AppSettings updates.
///
/// Only non-null fields are applied; null means "leave unchanged".
class AppSettingsPatch {
  const AppSettingsPatch({
    this.homeCurrency,
    this.theme,
    this.colorSchemeMode,
    this.colorSeed,
    this.animationsEnabled,
    this.weekStart,
    this.percentagePrecision,
    this.descriptionMaxLength,
    this.backButtonBehaviour,
    this.lockTimeoutSeconds,
    this.displayName,
    this.onboardingComplete,
    this.lastExchangeRateFetch,
  });

  final String? homeCurrency;
  final AppTheme? theme;
  final ColorSchemeMode? colorSchemeMode;
  final String? colorSeed;
  final bool? animationsEnabled;
  final WeekStart? weekStart;
  final int? percentagePrecision;
  final int? descriptionMaxLength;
  final BackButtonBehaviour? backButtonBehaviour;
  final int? lockTimeoutSeconds;
  final String? displayName;
  final bool? onboardingComplete;
  final int? lastExchangeRateFetch;
}

/// Contract for all AppSettings data-access operations.
abstract interface class IAppSettingsRepository {
  /// Watches the live settings object; emits on every change.
  Stream<AppSettings> watch();

  /// Applies a partial patch to the settings.
  Future<Result<void>> update(AppSettingsPatch patch);
}
