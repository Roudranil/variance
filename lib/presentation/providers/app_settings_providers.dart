// lib/presentation/providers/app_settings_providers.dart
//
// Riverpod providers for AppSettingsNotifier.
//
// Provider graph:
//   appSettingsProvider (AppSettingsNotifierProvider, keepAlive)
//     ← appSettingsRepositoryProvider
//
// AppSettingsNotifier is an AsyncNotifier<AppSettings> that:
//   - Subscribes to IAppSettingsRepository.watch() in build().
//   - Forwards each stream event to state using the Completer bridge pattern.
//   - Exposes save(patch) to apply partial settings updates.
//   - Is keepAlive so it is accessible from all settings screens and the
//     theme layer (INFRA-5).
//
// NOTE: The single appSettingsProvider replaces the previous StreamProvider of
// the same name. It is an AsyncNotifier, so it exposes both .future (for
// awaiting the first value) and .notifier (for calling save(patch)).
//
// Consumers that previously accessed the StreamProvider as
// AsyncValue<AppSettings> continue to work unchanged — the AsyncNotifier
// exposes the same AsyncValue<AppSettings> state type.
//
// Test cases (see test/providers/app_settings_providers_test.dart):
//   1. appSettingsProvider emits AppSettings with onboardingComplete=false
//      for a fresh in-memory database.
//   2. AppSettingsNotifier initial build resolves with default AppSettings.
//   3. AppSettingsNotifier.save propagates a theme patch; stream emits new value.
//   4. AppSettingsNotifier.save throws when repository returns Err.

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'app_settings_providers.g.dart';

// ---------------------------------------------------------------------------
// AppSettingsNotifier
// ---------------------------------------------------------------------------

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
@Riverpod(keepAlive: true)
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final repo = await ref.watch(appSettingsRepositoryProvider.future);
    final stream = repo.watch();

    // Completer bridges the one-shot Future<AppSettings> required by
    // AsyncNotifier.build() with the ongoing stream subscription.
    final completer = Completer<AppSettings>();

    final sub = stream.listen(
      (settings) {
        // Complete the build future on the first event.
        if (!completer.isCompleted) {
          completer.complete(settings);
        } else {
          // Guard: only update state while the notifier is still mounted.
          if (ref.mounted) state = AsyncData(settings);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<AppSettings>(error, stack);
          }
        }
      },
    );

    // Cancel the stream subscription when the notifier is disposed.
    ref.onDispose(sub.cancel);

    return completer.future;
  }

  /// Applies a partial [patch] to the settings via the repository.
  ///
  /// The method awaits the repository write; the reactive stream in [build]
  /// then automatically emits the updated [AppSettings] and updates [state].
  ///
  /// Throws an [Exception] with the failure message when the repository
  /// returns [Err], so that callers can surface the error in the UI.
  ///
  /// Parameters:
  /// - [patch]: Partial settings update; only non-null fields are written.
  Future<void> save(AppSettingsPatch patch) async {
    final repo = await ref.read(appSettingsRepositoryProvider.future);
    final result = await repo.update(patch);

    switch (result) {
      case Ok():
        // State updates reactively via the stream subscription in build().
        break;
      case Err(:final failure):
        throw Exception(failure.message);
    }
  }
}
