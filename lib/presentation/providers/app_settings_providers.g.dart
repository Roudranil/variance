// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the live [AppSettings] entity from the database.
///
/// Emits the full settings object on every change to any setting key.
/// Emits defaults when the database is empty (first launch).

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// Watches the live [AppSettings] entity from the database.
///
/// Emits the full settings object on every change to any setting key.
/// Emits defaults when the database is empty (first launch).

final class AppSettingsProvider extends $FunctionalProvider<
        AsyncValue<AppSettings>, AppSettings, Stream<AppSettings>>
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// Watches the live [AppSettings] entity from the database.
  ///
  /// Emits the full settings object on every change to any setting key.
  /// Emits defaults when the database is empty (first launch).
  AppSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'3a8c31f20d7e3d1b51445b4ec4b2e15ae691d981';
