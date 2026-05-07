// lib/domain/entities/app_settings.dart
//
// AppSettings domain entity.
//
// Flat value object mirroring all v1 app_settings key-value rows as typed
// Dart fields. The data layer reads the KV rows and maps them into this
// entity; the domain and presentation layers work with this typed object.
//
// Defined keys match data model §9.1.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Visual theme mode.
enum AppTheme {
  light,
  dark,
  system,
}

/// Color scheme source.
enum ColorSchemeMode {
  dynamic,
  custom,
}

/// Decimal separator for number display.
enum DecimalSeparator {
  comma,
  period,
}

/// Thousands grouping style.
enum ThousandsGrouping {
  standard,
  indian,
}

/// Currency symbol placement.
enum CurrencySymbolPlacement {
  prefix,
  suffix,
}

/// Spacing between currency symbol and amount.
enum CurrencySymbolSpacing {
  none,
  space,
}

/// Start of week.
enum WeekStart {
  monday,
  sunday,
}

/// Clock format preference.
enum TimeFormat {
  h12,
  h24,
}

/// Back-button behaviour on transaction entry form.
enum BackButtonBehaviour {
  ask,
  autoSaveDraft,
  discard,
}

/// Immutable flat domain entity for all v1 user preferences.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// ISO 4217 home currency code; set during onboarding.
    @Default('INR') String homeCurrency,

    /// Light/dark/system theme.
    @Default(AppTheme.system) AppTheme theme,

    /// Dynamic (wallpaper) or custom seed color scheme.
    @Default(ColorSchemeMode.dynamic) ColorSchemeMode colorSchemeMode,

    /// Hex seed color for custom color scheme; null when dynamic.
    String? colorSeed,

    /// Whether in-app animations are enabled.
    @Default(true) bool animationsEnabled,

    /// Decimal separator preference.
    DecimalSeparator? numberDecimalSeparator,

    /// Thousands grouping style.
    ThousandsGrouping? numberThousandsGrouping,

    /// Currency symbol placement.
    CurrencySymbolPlacement? currencySymbolPlacement,

    /// Spacing between currency symbol and amount.
    CurrencySymbolSpacing? currencySymbolSpacing,

    /// Week start day.
    @Default(WeekStart.monday) WeekStart weekStart,

    /// 12h or 24h time display.
    TimeFormat? timeFormat,

    /// Percentage display precision (0, 1, or 2).
    @Default(0) int percentagePrecision,

    /// Maximum character count for transaction descriptions.
    @Default(1000) int descriptionMaxLength,

    /// Back button behaviour on unsaved form.
    @Default(BackButtonBehaviour.ask) BackButtonBehaviour backButtonBehaviour,

    /// Idle timeout before app-lock; 0 = lock immediately.
    @Default(0) int lockTimeoutSeconds,

    /// Optional greeting name shown on the home screen.
    String? displayName,

    /// Whether onboarding has been completed.
    @Default(false) bool onboardingComplete,

    /// Backup format version (TC-054).
    @Default(1) int schemaBackupVersion,

    /// Unix epoch of the last successful exchange rate fetch.
    int? lastExchangeRateFetch,
  }) = _AppSettings;
}
