// lib/domain/repositories/i_app_settings_repository.dart
//
// Abstract repository interface for the AppSettings aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';

/// Partial patch object for AppSettings updates.
///
/// Only non-null fields are applied; null means "leave unchanged".
class AppSettingsPatch {
  /// Creates an [AppSettingsPatch].
  ///
  /// All parameters are optional. Only non-null values are written.
  const AppSettingsPatch({
    this.homeCurrency,
    this.theme,
    this.colorSchemeMode,
    this.colorSeed,
    this.animationsEnabled,
    this.numberDecimalSeparator,
    this.numberThousandsGrouping,
    this.currencySymbolPlacement,
    this.currencySymbolSpacing,
    this.weekStart,
    this.timeFormat,
    this.percentagePrecision,
    this.descriptionMaxLength,
    this.backButtonBehaviour,
    this.lockTimeoutSeconds,
    this.displayName,
    this.onboardingComplete,
    this.lastExchangeRateFetch,
    this.lastBackupAt,
  });

  /// ISO 4217 home currency code.
  final String? homeCurrency;

  /// Light/dark/system theme.
  final AppTheme? theme;

  /// Color scheme source (dynamic/custom/catppuccin).
  final ColorSchemeMode? colorSchemeMode;

  /// Hex seed color for custom color scheme.
  final String? colorSeed;

  /// Whether in-app animations are enabled.
  final bool? animationsEnabled;

  /// Decimal separator preference (comma or period).
  final DecimalSeparator? numberDecimalSeparator;

  /// Thousands grouping style.
  final ThousandsGrouping? numberThousandsGrouping;

  /// Currency symbol placement (prefix or suffix).
  final CurrencySymbolPlacement? currencySymbolPlacement;

  /// Spacing between currency symbol and amount.
  final CurrencySymbolSpacing? currencySymbolSpacing;

  /// Week start day.
  final WeekStart? weekStart;

  /// 12h or 24h time display.
  final TimeFormat? timeFormat;

  /// Percentage display precision (0, 1, or 2).
  final int? percentagePrecision;

  /// Maximum character count for transaction descriptions.
  final int? descriptionMaxLength;

  /// Back button behaviour on unsaved form.
  final BackButtonBehaviour? backButtonBehaviour;

  /// Idle timeout before app-lock in seconds; 0 = lock immediately.
  final int? lockTimeoutSeconds;

  /// Optional greeting name shown on the home screen.
  final String? displayName;

  /// Whether onboarding has been completed.
  final bool? onboardingComplete;

  /// Unix epoch of the last successful exchange rate fetch.
  final int? lastExchangeRateFetch;

  /// Unix epoch of the last successful local backup export.
  ///
  /// Written after a successful ZIP export (T-188, SET-07).
  final int? lastBackupAt;
}

/// Contract for all AppSettings data-access operations.
abstract interface class IAppSettingsRepository {
  /// Watches the live settings object; emits on every change.
  Stream<AppSettings> watch();

  /// Applies a partial patch to the settings.
  Future<Result<void>> update(AppSettingsPatch patch);
}
