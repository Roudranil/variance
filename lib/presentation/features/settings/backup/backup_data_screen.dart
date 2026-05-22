// lib/presentation/features/settings/backup/backup_data_screen.dart
//
// BackupDataScreen — settings screen for triggering a local data backup (T-187).
//
// Route: /settings/backup
//
// Functionality:
//   - Shows last backup timestamp from app_settings.last_backup_at.
//   - "Backup Now" button launches the Android SAF directory picker via
//     FilePicker.getDirectoryPath(). On selection, calls BackupNotifier.runBackup.
//   - Falls back to app external storage if SAF returns null or throws.
//   - Shows CircularProgressIndicator during export.
//   - Shows success SnackBar with the output file path on completion.
//   - Shows error SnackBar on failure.
//
// Spec: T-187, SET-07, SDS §2.17
//
// Test cases (see test/presentation/features/settings/backup/
//             backup_data_screen_test.dart):
//   T-187.W1 loaded state with no previous backup shows 'Never backed up'
//   T-187.W2 loaded state with previous backup shows formatted timestamp
//   T-187.W3 in-progress state shows CircularProgressIndicator
//   T-187.W4 success state shows success snackbar message
//   T-187.W5 error state shows error snackbar message

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:variance/presentation/features/settings/backup/backup_providers.dart';

/// Settings screen for the local data backup feature.
///
/// Displays the last backup timestamp and a button to trigger a new export.
/// Integrates with the Android SAF file picker for destination selection.
class BackupDataScreen extends ConsumerStatefulWidget {
  /// Creates a [BackupDataScreen].
  const BackupDataScreen({super.key});

  @override
  ConsumerState<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends ConsumerState<BackupDataScreen> {
  // Track the last state we already showed a SnackBar for to prevent duplicate
  // SnackBars on rebuilds.
  BackupState? _lastHandledState;

  @override
  Widget build(BuildContext context) {
    final backupAsync = ref.watch(backupProvider);

    // Show SnackBar feedback on success / failure transitions.
    ref.listen<AsyncValue<BackupState>>(
      backupProvider,
      (_, AsyncValue<BackupState> next) {
        if (!mounted) return;
        final value = next.value;
        if (value == null || identical(value, _lastHandledState)) return;

        if (value is BackupDoneState) {
          _lastHandledState = value;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup saved to ${value.filePath}'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        } else if (value is BackupFailedState) {
          _lastHandledState = value;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup failed: ${value.message}'),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Data'),
      ),
      body: backupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (BackupState backupState) => _BackupBody(
          backupState: backupState,
          onBackupTap: _handleBackupTap,
        ),
      ),
    );
  }

  Future<void> _handleBackupTap() async {
    // Launch SAF directory picker (static API in file_picker 11.x).
    String? selectedDir;
    try {
      selectedDir = await FilePicker.getDirectoryPath();
    } on Object {
      // SAF unavailable or user cancelled; BackupService falls back to
      // external storage / documents directory.
      selectedDir = null;
    }

    if (!mounted) return;
    await ref
        .read(backupProvider.notifier)
        .runBackup(destinationDir: selectedDir);
  }
}

// ---------------------------------------------------------------------------
// Body widget
// ---------------------------------------------------------------------------

/// The scrollable content body of [BackupDataScreen].
class _BackupBody extends StatelessWidget {
  const _BackupBody({
    required this.backupState,
    required this.onBackupTap,
  });

  final BackupState backupState;
  final VoidCallback onBackupTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LastBackupCard(backupState: backupState),
        const SizedBox(height: 24),
        _BackupActionSection(
          backupState: backupState,
          onBackupTap: onBackupTap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Last backup info card
// ---------------------------------------------------------------------------

/// Card displaying when the last backup was made (or 'Never backed up').
class _LastBackupCard extends StatelessWidget {
  const _LastBackupCard({required this.backupState});

  final BackupState backupState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int? lastBackupAt = backupState is BackupIdleState
        ? (backupState as BackupIdleState).lastBackupAt
        : null;

    final String lastBackupLabel;
    if (lastBackupAt != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(lastBackupAt * 1000);
      lastBackupLabel = DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } else {
      lastBackupLabel = 'Never backed up';
    }

    return Card.filled(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last backup',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastBackupLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backup action section
// ---------------------------------------------------------------------------

/// The backup button and in-progress indicator section.
class _BackupActionSection extends StatelessWidget {
  const _BackupActionSection({
    required this.backupState,
    required this.onBackupTap,
  });

  final BackupState backupState;
  final VoidCallback onBackupTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInProgress = backupState is BackupInProgressState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create a local backup of all your data. The backup file will be '
          'saved to the location you choose.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (isInProgress) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Creating backup…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ] else
          FilledButton.icon(
            onPressed: onBackupTap,
            icon: const Icon(Icons.backup_outlined),
            label: const Text('Backup Now'),
          ),
        const SizedBox(height: 16),
        const _InfoRow(
          icon: Icons.lock_outline,
          text: 'Your data is exported to a local ZIP file. '
              'No data is sent to any server.',
        ),
        const SizedBox(height: 8),
        const _InfoRow(
          icon: Icons.restore_outlined,
          text:
              'Import/restore from backup will be available in a future update.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Info row helper
// ---------------------------------------------------------------------------

/// A small inline row combining a leading icon with an informational text line.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
