// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive notifier for the live [AppSettings] entity with write support.
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle
/// using the Completer pattern (same approach as [CategoryList]):
/// - Subscribes once in [build] and forwards stream events to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.
///
/// Exposes [save] to apply partial patches. On repository error the method
/// throws an [Exception] so that the calling widget can display the failure.
///
/// NOTE: The write method is named [save] (not `update`) to avoid a name clash
/// with the built-in `AsyncNotifier.update` provided by Riverpod 3.x.

@ProviderFor(AppSettingsNotifier)
final appSettingsProvider = AppSettingsNotifierProvider._();

/// Reactive notifier for the live [AppSettings] entity with write support.
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle
/// using the Completer pattern (same approach as [CategoryList]):
/// - Subscribes once in [build] and forwards stream events to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.
///
/// Exposes [save] to apply partial patches. On repository error the method
/// throws an [Exception] so that the calling widget can display the failure.
///
/// NOTE: The write method is named [save] (not `update`) to avoid a name clash
/// with the built-in `AsyncNotifier.update` provided by Riverpod 3.x.
final class AppSettingsNotifierProvider
    extends $AsyncNotifierProvider<AppSettingsNotifier, AppSettings> {
  /// Reactive notifier for the live [AppSettings] entity with write support.
  ///
  /// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle
  /// using the Completer pattern (same approach as [CategoryList]):
  /// - Subscribes once in [build] and forwards stream events to [state].
  /// - Cancels the subscription via [ref.onDispose].
  /// - Returns a [Completer] future so [build] resolves after the first event.
  ///
  /// Exposes [save] to apply partial patches. On repository error the method
  /// throws an [Exception] so that the calling widget can display the failure.
  ///
  /// NOTE: The write method is named [save] (not `update`) to avoid a name clash
  /// with the built-in `AsyncNotifier.update` provided by Riverpod 3.x.
  AppSettingsNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();
}

String _$appSettingsNotifierHash() =>
    r'16f77086a8eca6766a439011ea6d3d97e2506c89';

/// Reactive notifier for the live [AppSettings] entity with write support.
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle
/// using the Completer pattern (same approach as [CategoryList]):
/// - Subscribes once in [build] and forwards stream events to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.
///
/// Exposes [save] to apply partial patches. On repository error the method
/// throws an [Exception] so that the calling widget can display the failure.
///
/// NOTE: The write method is named [save] (not `update`) to avoid a name clash
/// with the built-in `AsyncNotifier.update` provided by Riverpod 3.x.

abstract class _$AppSettingsNotifier extends $AsyncNotifier<AppSettings> {
  FutureOr<AppSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSettings>, AppSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AppSettings>, AppSettings>,
        AsyncValue<AppSettings>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
