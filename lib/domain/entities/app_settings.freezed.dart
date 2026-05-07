// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {
  /// ISO 4217 home currency code; set during onboarding.
  String get homeCurrency;

  /// Light/dark/system theme.
  AppTheme get theme;

  /// Dynamic (wallpaper) or custom seed color scheme.
  ColorSchemeMode get colorSchemeMode;

  /// Hex seed color for custom color scheme; null when dynamic.
  String? get colorSeed;

  /// Whether in-app animations are enabled.
  bool get animationsEnabled;

  /// Decimal separator preference.
  DecimalSeparator? get numberDecimalSeparator;

  /// Thousands grouping style.
  ThousandsGrouping? get numberThousandsGrouping;

  /// Currency symbol placement.
  CurrencySymbolPlacement? get currencySymbolPlacement;

  /// Spacing between currency symbol and amount.
  CurrencySymbolSpacing? get currencySymbolSpacing;

  /// Week start day.
  WeekStart get weekStart;

  /// 12h or 24h time display.
  TimeFormat? get timeFormat;

  /// Percentage display precision (0, 1, or 2).
  int get percentagePrecision;

  /// Maximum character count for transaction descriptions.
  int get descriptionMaxLength;

  /// Back button behaviour on unsaved form.
  BackButtonBehaviour get backButtonBehaviour;

  /// Idle timeout before app-lock; 0 = lock immediately.
  int get lockTimeoutSeconds;

  /// Optional greeting name shown on the home screen.
  String? get displayName;

  /// Whether onboarding has been completed.
  bool get onboardingComplete;

  /// Backup format version (TC-054).
  int get schemaBackupVersion;

  /// Unix epoch of the last successful exchange rate fetch.
  int? get lastExchangeRateFetch;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppSettings &&
            (identical(other.homeCurrency, homeCurrency) ||
                other.homeCurrency == homeCurrency) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.colorSchemeMode, colorSchemeMode) ||
                other.colorSchemeMode == colorSchemeMode) &&
            (identical(other.colorSeed, colorSeed) ||
                other.colorSeed == colorSeed) &&
            (identical(other.animationsEnabled, animationsEnabled) ||
                other.animationsEnabled == animationsEnabled) &&
            (identical(other.numberDecimalSeparator, numberDecimalSeparator) ||
                other.numberDecimalSeparator == numberDecimalSeparator) &&
            (identical(
                    other.numberThousandsGrouping, numberThousandsGrouping) ||
                other.numberThousandsGrouping == numberThousandsGrouping) &&
            (identical(
                    other.currencySymbolPlacement, currencySymbolPlacement) ||
                other.currencySymbolPlacement == currencySymbolPlacement) &&
            (identical(other.currencySymbolSpacing, currencySymbolSpacing) ||
                other.currencySymbolSpacing == currencySymbolSpacing) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.timeFormat, timeFormat) ||
                other.timeFormat == timeFormat) &&
            (identical(other.percentagePrecision, percentagePrecision) ||
                other.percentagePrecision == percentagePrecision) &&
            (identical(other.descriptionMaxLength, descriptionMaxLength) ||
                other.descriptionMaxLength == descriptionMaxLength) &&
            (identical(other.backButtonBehaviour, backButtonBehaviour) ||
                other.backButtonBehaviour == backButtonBehaviour) &&
            (identical(other.lockTimeoutSeconds, lockTimeoutSeconds) ||
                other.lockTimeoutSeconds == lockTimeoutSeconds) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.schemaBackupVersion, schemaBackupVersion) ||
                other.schemaBackupVersion == schemaBackupVersion) &&
            (identical(other.lastExchangeRateFetch, lastExchangeRateFetch) ||
                other.lastExchangeRateFetch == lastExchangeRateFetch));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        homeCurrency,
        theme,
        colorSchemeMode,
        colorSeed,
        animationsEnabled,
        numberDecimalSeparator,
        numberThousandsGrouping,
        currencySymbolPlacement,
        currencySymbolSpacing,
        weekStart,
        timeFormat,
        percentagePrecision,
        descriptionMaxLength,
        backButtonBehaviour,
        lockTimeoutSeconds,
        displayName,
        onboardingComplete,
        schemaBackupVersion,
        lastExchangeRateFetch
      ]);

  @override
  String toString() {
    return 'AppSettings(homeCurrency: $homeCurrency, theme: $theme, colorSchemeMode: $colorSchemeMode, colorSeed: $colorSeed, animationsEnabled: $animationsEnabled, numberDecimalSeparator: $numberDecimalSeparator, numberThousandsGrouping: $numberThousandsGrouping, currencySymbolPlacement: $currencySymbolPlacement, currencySymbolSpacing: $currencySymbolSpacing, weekStart: $weekStart, timeFormat: $timeFormat, percentagePrecision: $percentagePrecision, descriptionMaxLength: $descriptionMaxLength, backButtonBehaviour: $backButtonBehaviour, lockTimeoutSeconds: $lockTimeoutSeconds, displayName: $displayName, onboardingComplete: $onboardingComplete, schemaBackupVersion: $schemaBackupVersion, lastExchangeRateFetch: $lastExchangeRateFetch)';
  }
}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) _then) =
      _$AppSettingsCopyWithImpl;
  @useResult
  $Res call(
      {String homeCurrency,
      AppTheme theme,
      ColorSchemeMode colorSchemeMode,
      String? colorSeed,
      bool animationsEnabled,
      DecimalSeparator? numberDecimalSeparator,
      ThousandsGrouping? numberThousandsGrouping,
      CurrencySymbolPlacement? currencySymbolPlacement,
      CurrencySymbolSpacing? currencySymbolSpacing,
      WeekStart weekStart,
      TimeFormat? timeFormat,
      int percentagePrecision,
      int descriptionMaxLength,
      BackButtonBehaviour backButtonBehaviour,
      int lockTimeoutSeconds,
      String? displayName,
      bool onboardingComplete,
      int schemaBackupVersion,
      int? lastExchangeRateFetch});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res> implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeCurrency = null,
    Object? theme = null,
    Object? colorSchemeMode = null,
    Object? colorSeed = freezed,
    Object? animationsEnabled = null,
    Object? numberDecimalSeparator = freezed,
    Object? numberThousandsGrouping = freezed,
    Object? currencySymbolPlacement = freezed,
    Object? currencySymbolSpacing = freezed,
    Object? weekStart = null,
    Object? timeFormat = freezed,
    Object? percentagePrecision = null,
    Object? descriptionMaxLength = null,
    Object? backButtonBehaviour = null,
    Object? lockTimeoutSeconds = null,
    Object? displayName = freezed,
    Object? onboardingComplete = null,
    Object? schemaBackupVersion = null,
    Object? lastExchangeRateFetch = freezed,
  }) {
    return _then(_self.copyWith(
      homeCurrency: null == homeCurrency
          ? _self.homeCurrency
          : homeCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      colorSchemeMode: null == colorSchemeMode
          ? _self.colorSchemeMode
          : colorSchemeMode // ignore: cast_nullable_to_non_nullable
              as ColorSchemeMode,
      colorSeed: freezed == colorSeed
          ? _self.colorSeed
          : colorSeed // ignore: cast_nullable_to_non_nullable
              as String?,
      animationsEnabled: null == animationsEnabled
          ? _self.animationsEnabled
          : animationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      numberDecimalSeparator: freezed == numberDecimalSeparator
          ? _self.numberDecimalSeparator
          : numberDecimalSeparator // ignore: cast_nullable_to_non_nullable
              as DecimalSeparator?,
      numberThousandsGrouping: freezed == numberThousandsGrouping
          ? _self.numberThousandsGrouping
          : numberThousandsGrouping // ignore: cast_nullable_to_non_nullable
              as ThousandsGrouping?,
      currencySymbolPlacement: freezed == currencySymbolPlacement
          ? _self.currencySymbolPlacement
          : currencySymbolPlacement // ignore: cast_nullable_to_non_nullable
              as CurrencySymbolPlacement?,
      currencySymbolSpacing: freezed == currencySymbolSpacing
          ? _self.currencySymbolSpacing
          : currencySymbolSpacing // ignore: cast_nullable_to_non_nullable
              as CurrencySymbolSpacing?,
      weekStart: null == weekStart
          ? _self.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as WeekStart,
      timeFormat: freezed == timeFormat
          ? _self.timeFormat
          : timeFormat // ignore: cast_nullable_to_non_nullable
              as TimeFormat?,
      percentagePrecision: null == percentagePrecision
          ? _self.percentagePrecision
          : percentagePrecision // ignore: cast_nullable_to_non_nullable
              as int,
      descriptionMaxLength: null == descriptionMaxLength
          ? _self.descriptionMaxLength
          : descriptionMaxLength // ignore: cast_nullable_to_non_nullable
              as int,
      backButtonBehaviour: null == backButtonBehaviour
          ? _self.backButtonBehaviour
          : backButtonBehaviour // ignore: cast_nullable_to_non_nullable
              as BackButtonBehaviour,
      lockTimeoutSeconds: null == lockTimeoutSeconds
          ? _self.lockTimeoutSeconds
          : lockTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingComplete: null == onboardingComplete
          ? _self.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      schemaBackupVersion: null == schemaBackupVersion
          ? _self.schemaBackupVersion
          : schemaBackupVersion // ignore: cast_nullable_to_non_nullable
              as int,
      lastExchangeRateFetch: freezed == lastExchangeRateFetch
          ? _self.lastExchangeRateFetch
          : lastExchangeRateFetch // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AppSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AppSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AppSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String homeCurrency,
            AppTheme theme,
            ColorSchemeMode colorSchemeMode,
            String? colorSeed,
            bool animationsEnabled,
            DecimalSeparator? numberDecimalSeparator,
            ThousandsGrouping? numberThousandsGrouping,
            CurrencySymbolPlacement? currencySymbolPlacement,
            CurrencySymbolSpacing? currencySymbolSpacing,
            WeekStart weekStart,
            TimeFormat? timeFormat,
            int percentagePrecision,
            int descriptionMaxLength,
            BackButtonBehaviour backButtonBehaviour,
            int lockTimeoutSeconds,
            String? displayName,
            bool onboardingComplete,
            int schemaBackupVersion,
            int? lastExchangeRateFetch)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(
            _that.homeCurrency,
            _that.theme,
            _that.colorSchemeMode,
            _that.colorSeed,
            _that.animationsEnabled,
            _that.numberDecimalSeparator,
            _that.numberThousandsGrouping,
            _that.currencySymbolPlacement,
            _that.currencySymbolSpacing,
            _that.weekStart,
            _that.timeFormat,
            _that.percentagePrecision,
            _that.descriptionMaxLength,
            _that.backButtonBehaviour,
            _that.lockTimeoutSeconds,
            _that.displayName,
            _that.onboardingComplete,
            _that.schemaBackupVersion,
            _that.lastExchangeRateFetch);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String homeCurrency,
            AppTheme theme,
            ColorSchemeMode colorSchemeMode,
            String? colorSeed,
            bool animationsEnabled,
            DecimalSeparator? numberDecimalSeparator,
            ThousandsGrouping? numberThousandsGrouping,
            CurrencySymbolPlacement? currencySymbolPlacement,
            CurrencySymbolSpacing? currencySymbolSpacing,
            WeekStart weekStart,
            TimeFormat? timeFormat,
            int percentagePrecision,
            int descriptionMaxLength,
            BackButtonBehaviour backButtonBehaviour,
            int lockTimeoutSeconds,
            String? displayName,
            bool onboardingComplete,
            int schemaBackupVersion,
            int? lastExchangeRateFetch)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings():
        return $default(
            _that.homeCurrency,
            _that.theme,
            _that.colorSchemeMode,
            _that.colorSeed,
            _that.animationsEnabled,
            _that.numberDecimalSeparator,
            _that.numberThousandsGrouping,
            _that.currencySymbolPlacement,
            _that.currencySymbolSpacing,
            _that.weekStart,
            _that.timeFormat,
            _that.percentagePrecision,
            _that.descriptionMaxLength,
            _that.backButtonBehaviour,
            _that.lockTimeoutSeconds,
            _that.displayName,
            _that.onboardingComplete,
            _that.schemaBackupVersion,
            _that.lastExchangeRateFetch);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String homeCurrency,
            AppTheme theme,
            ColorSchemeMode colorSchemeMode,
            String? colorSeed,
            bool animationsEnabled,
            DecimalSeparator? numberDecimalSeparator,
            ThousandsGrouping? numberThousandsGrouping,
            CurrencySymbolPlacement? currencySymbolPlacement,
            CurrencySymbolSpacing? currencySymbolSpacing,
            WeekStart weekStart,
            TimeFormat? timeFormat,
            int percentagePrecision,
            int descriptionMaxLength,
            BackButtonBehaviour backButtonBehaviour,
            int lockTimeoutSeconds,
            String? displayName,
            bool onboardingComplete,
            int schemaBackupVersion,
            int? lastExchangeRateFetch)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(
            _that.homeCurrency,
            _that.theme,
            _that.colorSchemeMode,
            _that.colorSeed,
            _that.animationsEnabled,
            _that.numberDecimalSeparator,
            _that.numberThousandsGrouping,
            _that.currencySymbolPlacement,
            _that.currencySymbolSpacing,
            _that.weekStart,
            _that.timeFormat,
            _that.percentagePrecision,
            _that.descriptionMaxLength,
            _that.backButtonBehaviour,
            _that.lockTimeoutSeconds,
            _that.displayName,
            _that.onboardingComplete,
            _that.schemaBackupVersion,
            _that.lastExchangeRateFetch);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AppSettings implements AppSettings {
  const _AppSettings(
      {this.homeCurrency = 'INR',
      this.theme = AppTheme.system,
      this.colorSchemeMode = ColorSchemeMode.dynamic,
      this.colorSeed,
      this.animationsEnabled = true,
      this.numberDecimalSeparator,
      this.numberThousandsGrouping,
      this.currencySymbolPlacement,
      this.currencySymbolSpacing,
      this.weekStart = WeekStart.monday,
      this.timeFormat,
      this.percentagePrecision = 0,
      this.descriptionMaxLength = 1000,
      this.backButtonBehaviour = BackButtonBehaviour.ask,
      this.lockTimeoutSeconds = 0,
      this.displayName,
      this.onboardingComplete = false,
      this.schemaBackupVersion = 1,
      this.lastExchangeRateFetch});

  /// ISO 4217 home currency code; set during onboarding.
  @override
  @JsonKey()
  final String homeCurrency;

  /// Light/dark/system theme.
  @override
  @JsonKey()
  final AppTheme theme;

  /// Dynamic (wallpaper) or custom seed color scheme.
  @override
  @JsonKey()
  final ColorSchemeMode colorSchemeMode;

  /// Hex seed color for custom color scheme; null when dynamic.
  @override
  final String? colorSeed;

  /// Whether in-app animations are enabled.
  @override
  @JsonKey()
  final bool animationsEnabled;

  /// Decimal separator preference.
  @override
  final DecimalSeparator? numberDecimalSeparator;

  /// Thousands grouping style.
  @override
  final ThousandsGrouping? numberThousandsGrouping;

  /// Currency symbol placement.
  @override
  final CurrencySymbolPlacement? currencySymbolPlacement;

  /// Spacing between currency symbol and amount.
  @override
  final CurrencySymbolSpacing? currencySymbolSpacing;

  /// Week start day.
  @override
  @JsonKey()
  final WeekStart weekStart;

  /// 12h or 24h time display.
  @override
  final TimeFormat? timeFormat;

  /// Percentage display precision (0, 1, or 2).
  @override
  @JsonKey()
  final int percentagePrecision;

  /// Maximum character count for transaction descriptions.
  @override
  @JsonKey()
  final int descriptionMaxLength;

  /// Back button behaviour on unsaved form.
  @override
  @JsonKey()
  final BackButtonBehaviour backButtonBehaviour;

  /// Idle timeout before app-lock; 0 = lock immediately.
  @override
  @JsonKey()
  final int lockTimeoutSeconds;

  /// Optional greeting name shown on the home screen.
  @override
  final String? displayName;

  /// Whether onboarding has been completed.
  @override
  @JsonKey()
  final bool onboardingComplete;

  /// Backup format version (TC-054).
  @override
  @JsonKey()
  final int schemaBackupVersion;

  /// Unix epoch of the last successful exchange rate fetch.
  @override
  final int? lastExchangeRateFetch;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppSettingsCopyWith<_AppSettings> get copyWith =>
      __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppSettings &&
            (identical(other.homeCurrency, homeCurrency) ||
                other.homeCurrency == homeCurrency) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.colorSchemeMode, colorSchemeMode) ||
                other.colorSchemeMode == colorSchemeMode) &&
            (identical(other.colorSeed, colorSeed) ||
                other.colorSeed == colorSeed) &&
            (identical(other.animationsEnabled, animationsEnabled) ||
                other.animationsEnabled == animationsEnabled) &&
            (identical(other.numberDecimalSeparator, numberDecimalSeparator) ||
                other.numberDecimalSeparator == numberDecimalSeparator) &&
            (identical(
                    other.numberThousandsGrouping, numberThousandsGrouping) ||
                other.numberThousandsGrouping == numberThousandsGrouping) &&
            (identical(
                    other.currencySymbolPlacement, currencySymbolPlacement) ||
                other.currencySymbolPlacement == currencySymbolPlacement) &&
            (identical(other.currencySymbolSpacing, currencySymbolSpacing) ||
                other.currencySymbolSpacing == currencySymbolSpacing) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.timeFormat, timeFormat) ||
                other.timeFormat == timeFormat) &&
            (identical(other.percentagePrecision, percentagePrecision) ||
                other.percentagePrecision == percentagePrecision) &&
            (identical(other.descriptionMaxLength, descriptionMaxLength) ||
                other.descriptionMaxLength == descriptionMaxLength) &&
            (identical(other.backButtonBehaviour, backButtonBehaviour) ||
                other.backButtonBehaviour == backButtonBehaviour) &&
            (identical(other.lockTimeoutSeconds, lockTimeoutSeconds) ||
                other.lockTimeoutSeconds == lockTimeoutSeconds) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.schemaBackupVersion, schemaBackupVersion) ||
                other.schemaBackupVersion == schemaBackupVersion) &&
            (identical(other.lastExchangeRateFetch, lastExchangeRateFetch) ||
                other.lastExchangeRateFetch == lastExchangeRateFetch));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        homeCurrency,
        theme,
        colorSchemeMode,
        colorSeed,
        animationsEnabled,
        numberDecimalSeparator,
        numberThousandsGrouping,
        currencySymbolPlacement,
        currencySymbolSpacing,
        weekStart,
        timeFormat,
        percentagePrecision,
        descriptionMaxLength,
        backButtonBehaviour,
        lockTimeoutSeconds,
        displayName,
        onboardingComplete,
        schemaBackupVersion,
        lastExchangeRateFetch
      ]);

  @override
  String toString() {
    return 'AppSettings(homeCurrency: $homeCurrency, theme: $theme, colorSchemeMode: $colorSchemeMode, colorSeed: $colorSeed, animationsEnabled: $animationsEnabled, numberDecimalSeparator: $numberDecimalSeparator, numberThousandsGrouping: $numberThousandsGrouping, currencySymbolPlacement: $currencySymbolPlacement, currencySymbolSpacing: $currencySymbolSpacing, weekStart: $weekStart, timeFormat: $timeFormat, percentagePrecision: $percentagePrecision, descriptionMaxLength: $descriptionMaxLength, backButtonBehaviour: $backButtonBehaviour, lockTimeoutSeconds: $lockTimeoutSeconds, displayName: $displayName, onboardingComplete: $onboardingComplete, schemaBackupVersion: $schemaBackupVersion, lastExchangeRateFetch: $lastExchangeRateFetch)';
  }
}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(
          _AppSettings value, $Res Function(_AppSettings) _then) =
      __$AppSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String homeCurrency,
      AppTheme theme,
      ColorSchemeMode colorSchemeMode,
      String? colorSeed,
      bool animationsEnabled,
      DecimalSeparator? numberDecimalSeparator,
      ThousandsGrouping? numberThousandsGrouping,
      CurrencySymbolPlacement? currencySymbolPlacement,
      CurrencySymbolSpacing? currencySymbolSpacing,
      WeekStart weekStart,
      TimeFormat? timeFormat,
      int percentagePrecision,
      int descriptionMaxLength,
      BackButtonBehaviour backButtonBehaviour,
      int lockTimeoutSeconds,
      String? displayName,
      bool onboardingComplete,
      int schemaBackupVersion,
      int? lastExchangeRateFetch});
}

/// @nodoc
class __$AppSettingsCopyWithImpl<$Res> implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? homeCurrency = null,
    Object? theme = null,
    Object? colorSchemeMode = null,
    Object? colorSeed = freezed,
    Object? animationsEnabled = null,
    Object? numberDecimalSeparator = freezed,
    Object? numberThousandsGrouping = freezed,
    Object? currencySymbolPlacement = freezed,
    Object? currencySymbolSpacing = freezed,
    Object? weekStart = null,
    Object? timeFormat = freezed,
    Object? percentagePrecision = null,
    Object? descriptionMaxLength = null,
    Object? backButtonBehaviour = null,
    Object? lockTimeoutSeconds = null,
    Object? displayName = freezed,
    Object? onboardingComplete = null,
    Object? schemaBackupVersion = null,
    Object? lastExchangeRateFetch = freezed,
  }) {
    return _then(_AppSettings(
      homeCurrency: null == homeCurrency
          ? _self.homeCurrency
          : homeCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      colorSchemeMode: null == colorSchemeMode
          ? _self.colorSchemeMode
          : colorSchemeMode // ignore: cast_nullable_to_non_nullable
              as ColorSchemeMode,
      colorSeed: freezed == colorSeed
          ? _self.colorSeed
          : colorSeed // ignore: cast_nullable_to_non_nullable
              as String?,
      animationsEnabled: null == animationsEnabled
          ? _self.animationsEnabled
          : animationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      numberDecimalSeparator: freezed == numberDecimalSeparator
          ? _self.numberDecimalSeparator
          : numberDecimalSeparator // ignore: cast_nullable_to_non_nullable
              as DecimalSeparator?,
      numberThousandsGrouping: freezed == numberThousandsGrouping
          ? _self.numberThousandsGrouping
          : numberThousandsGrouping // ignore: cast_nullable_to_non_nullable
              as ThousandsGrouping?,
      currencySymbolPlacement: freezed == currencySymbolPlacement
          ? _self.currencySymbolPlacement
          : currencySymbolPlacement // ignore: cast_nullable_to_non_nullable
              as CurrencySymbolPlacement?,
      currencySymbolSpacing: freezed == currencySymbolSpacing
          ? _self.currencySymbolSpacing
          : currencySymbolSpacing // ignore: cast_nullable_to_non_nullable
              as CurrencySymbolSpacing?,
      weekStart: null == weekStart
          ? _self.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as WeekStart,
      timeFormat: freezed == timeFormat
          ? _self.timeFormat
          : timeFormat // ignore: cast_nullable_to_non_nullable
              as TimeFormat?,
      percentagePrecision: null == percentagePrecision
          ? _self.percentagePrecision
          : percentagePrecision // ignore: cast_nullable_to_non_nullable
              as int,
      descriptionMaxLength: null == descriptionMaxLength
          ? _self.descriptionMaxLength
          : descriptionMaxLength // ignore: cast_nullable_to_non_nullable
              as int,
      backButtonBehaviour: null == backButtonBehaviour
          ? _self.backButtonBehaviour
          : backButtonBehaviour // ignore: cast_nullable_to_non_nullable
              as BackButtonBehaviour,
      lockTimeoutSeconds: null == lockTimeoutSeconds
          ? _self.lockTimeoutSeconds
          : lockTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingComplete: null == onboardingComplete
          ? _self.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      schemaBackupVersion: null == schemaBackupVersion
          ? _self.schemaBackupVersion
          : schemaBackupVersion // ignore: cast_nullable_to_non_nullable
              as int,
      lastExchangeRateFetch: freezed == lastExchangeRateFetch
          ? _self.lastExchangeRateFetch
          : lastExchangeRateFetch // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
