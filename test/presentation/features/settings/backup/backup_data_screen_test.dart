// test/presentation/features/settings/backup/backup_data_screen_test.dart
//
// Widget tests for BackupDataScreen (T-187).
//
// Tests use overridden Riverpod providers to control backup state without
// invoking the real BackupService or FilePicker.
//
// Test cases:
//   T-187.W1 loaded state with no previous backup shows 'Never backed up'
//   T-187.W2 loaded state with previous backup shows formatted timestamp
//   T-187.W3 in-progress state shows CircularProgressIndicator
//   T-187.W4 success state: SnackBar shown with file path
//   T-187.W5 error state: SnackBar shown with error message
//   T-187.W6 screen title is 'Backup & Data'
//   T-187.W7 'Backup Now' button is visible when idle

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/presentation/features/settings/backup/backup_data_screen.dart';
import 'package:variance/presentation/features/settings/backup/backup_providers.dart';

// ---------------------------------------------------------------------------
// Fake BackupNotifier
// ---------------------------------------------------------------------------

/// Fake notifier that starts in [BackupIdleState] and allows direct state
/// injection for testing.
class _FakeBackupNotifier extends BackupNotifier {
  _FakeBackupNotifier(this._initial);

  final BackupState _initial;

  @override
  Future<BackupState> build() async => _initial;

  /// Drives the state to [newState] for testing state transitions.
  void driveState(BackupState newState) {
    state = AsyncData(newState);
  }

  @override
  Future<void> runBackup({String? destinationDir}) async {
    // No-op: tests drive state manually.
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildApp({
  required BackupState initialState,
  _FakeBackupNotifier? notifier,
}) {
  final fakeNotifier = notifier ?? _FakeBackupNotifier(initialState);
  return ProviderScope(
    overrides: [
      backupProvider.overrideWith(() => fakeNotifier),
    ],
    child: const MaterialApp(
      home: BackupDataScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BackupDataScreen', () {
    // ---- T-187.W6 AppBar title -----------------------------------------------

    testWidgets('T-187.W6 screen title is Backup & Data', (tester) async {
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(),
      ));
      await tester.pump();

      expect(find.text('Backup & Data'), findsOneWidget);
    });

    // ---- T-187.W1 No previous backup ----------------------------------------

    testWidgets('T-187.W1 no previous backup shows Never backed up',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(lastBackupAt: null),
      ));
      await tester.pump();

      expect(find.text('Never backed up'), findsOneWidget);
    });

    // ---- T-187.W2 Previous backup timestamp ----------------------------------

    testWidgets('T-187.W2 previous backup shows formatted timestamp',
        (tester) async {
      // Use a known epoch in 2025 (Jan 16 local time).
      // Exact local format varies; we verify a non-"Never backed up" label.
      const epoch = 1737034200; // 2025-01-16 (local)
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(lastBackupAt: epoch),
      ));
      await tester.pump();

      expect(find.text('Never backed up'), findsNothing);
      // A formatted date string should appear; check "Jan" or a digit pattern.
      expect(find.textContaining('Jan'), findsOneWidget);
    });

    // ---- T-187.W3 In-progress state ------------------------------------------

    testWidgets('T-187.W3 in-progress state shows CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        initialState: BackupInProgressState(),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Creating backup…'), findsOneWidget);
    });

    // ---- T-187.W7 Backup Now button ------------------------------------------

    testWidgets('T-187.W7 Backup Now button visible when idle', (tester) async {
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(),
      ));
      await tester.pump();

      expect(find.text('Backup Now'), findsOneWidget);
    });

    // ---- T-187.W4 Success SnackBar -------------------------------------------

    testWidgets('T-187.W4 success state triggers SnackBar with file path',
        (tester) async {
      final notifier = _FakeBackupNotifier(BackupIdleState());
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(),
        notifier: notifier,
      ));
      await tester.pump();

      // Drive to success state.
      notifier.driveState(BackupDoneState('/data/backup.zip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('/data/backup.zip'), findsOneWidget);
    });

    // ---- T-187.W5 Error SnackBar ---------------------------------------------

    testWidgets('T-187.W5 error state triggers SnackBar with error message',
        (tester) async {
      final notifier = _FakeBackupNotifier(BackupIdleState());
      await tester.pumpWidget(_buildApp(
        initialState: BackupIdleState(),
        notifier: notifier,
      ));
      await tester.pump();

      // Drive to error state.
      notifier.driveState(BackupFailedState('Disk full'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Disk full'), findsOneWidget);
    });
  });
}
