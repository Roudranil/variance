// lib/presentation/features/settings/backup/backup_providers.dart
//
// Riverpod providers for the BackupDataScreen (T-187, T-188).
//
// Provider graph:
//   backupServiceProvider (keepAlive)
//     ← appDatabaseProvider
//
//   backupNotifierProvider (AsyncNotifier, auto-dispose)
//     ← backupServiceProvider
//     ← appSettingsProvider (to read last_backup_at and write it on success)
//
// BackupState models the backup UI state (idle, inProgress, done, failed).
//
// Test cases (see test/presentation/features/settings/backup/backup_providers_test.dart):
//   T-187.1 initial state is BackupIdleState with lastBackupAt from settings
//   T-187.2 BackupInProgressState emitted during export
//   T-187.3 BackupDoneState contains file path on success
//   T-187.4 BackupFailedState on service failure
//   T-187.5 last_backup_at written to settings on success

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/infrastructure/backup/backup_service.dart' as svc;
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/database_providers.dart';

part 'backup_providers.g.dart';

// ---------------------------------------------------------------------------
// Backup UI state
// ---------------------------------------------------------------------------

/// Represents the current state of the backup UI.
sealed class BackupState {}

/// No backup in progress; shows last backup timestamp (or null if never).
final class BackupIdleState extends BackupState {
  /// Creates a [BackupIdleState].
  ///
  /// Parameters:
  /// - [lastBackupAt]: Unix epoch seconds of the last backup, or null.
  BackupIdleState({this.lastBackupAt});

  /// Unix epoch seconds of the last successful backup, or null if never.
  final int? lastBackupAt;
}

/// Backup export is currently running.
final class BackupInProgressState extends BackupState {}

/// Backup completed successfully.
final class BackupDoneState extends BackupState {
  /// Creates a [BackupDoneState] with the archive [filePath].
  BackupDoneState(this.filePath);

  /// Absolute path to the written ZIP archive.
  final String filePath;
}

/// Backup failed.
final class BackupFailedState extends BackupState {
  /// Creates a [BackupFailedState] with an error [message].
  BackupFailedState(this.message);

  /// Human-readable error description.
  final String message;
}

// ---------------------------------------------------------------------------
// BackupService provider
// ---------------------------------------------------------------------------

/// Provides a singleton [svc.BackupService] backed by the app database.
@Riverpod(keepAlive: true)
Future<svc.BackupService> backupService(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return svc.BackupService(db);
}

// ---------------------------------------------------------------------------
// BackupNotifier
// ---------------------------------------------------------------------------

/// Manages the backup UI state and triggers export.
///
/// Reads [lastBackupAt] from [appSettingsProvider] for the initial idle state.
///
/// Call [runBackup] with an optional SAF-selected directory path to begin
/// export. On success, writes `last_backup_at` to [AppSettingsNotifier].
@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  Future<BackupState> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    return BackupIdleState(lastBackupAt: settings.lastBackupAt);
  }

  /// Triggers a backup export.
  ///
  /// Transitions through [BackupInProgressState] → [BackupDoneState] or
  /// [BackupFailedState]. On success, writes `last_backup_at` to settings.
  ///
  /// Parameters:
  /// - [destinationDir]: SAF-provided directory path; null uses the default
  ///   Downloads fallback.
  Future<void> runBackup({String? destinationDir}) async {
    state = AsyncData<BackupState>(BackupInProgressState());

    final service = await ref.read(backupServiceProvider.future);
    final result = await service.export(destinationDir: destinationDir);

    switch (result) {
      case svc.BackupSuccess(:final filePath):
        // Record the backup timestamp in app settings.
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await ref
            .read(appSettingsProvider.notifier)
            .save(AppSettingsPatch(lastBackupAt: now));
        state = AsyncData<BackupState>(BackupDoneState(filePath));

      case svc.BackupFailure(:final message):
        state = AsyncData<BackupState>(BackupFailedState(message));
    }
  }
}
