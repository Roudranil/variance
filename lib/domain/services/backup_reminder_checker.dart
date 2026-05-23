// lib/domain/services/backup_reminder_checker.dart
//
// BackupReminderChecker — domain service that evaluates whether the backup
// reminder alert card should be displayed on the Home screen (T-170).
//
// Trigger conditions (either is sufficient):
//   1. (today - onboarding_complete_date) >= 30 days
//   2. countPosted() >= 50 transactions
//
// Skip condition: AppSettings.lastBackupAt is not null (user has backed up at
// least once).  The task specification used backup_reminder_shown=1 as the
// skip flag; however the AppSettings entity uses [lastBackupAt] (non-null when
// a backup was exported successfully).  We map that as the skip condition
// instead, which is the source of truth that already exists in the data model.
//
// No Flutter dependency — pure Dart domain service.
//
// Test cases (see test/unit/domain/services/backup_reminder_checker_test.dart):
//   T-170.1  shouldShow = true when elapsed days >= 30 and no backup
//   T-170.2  shouldShow = true when transaction count >= 50 and no backup
//   T-170.3  shouldShow = false when both conditions met but lastBackupAt set
//   T-170.4  shouldShow = false when elapsed < 30 days and count < 50
//   T-170.5  shouldShow = false when onboardingComplete = false

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Result returned by [BackupReminderChecker.check].
class BackupReminderResult {
  /// Creates a [BackupReminderResult].
  const BackupReminderResult({
    required this.shouldShow,
    required this.triggerDays,
    required this.transactionCount,
  });

  /// Whether the backup reminder card should be displayed.
  final bool shouldShow;

  /// Number of days since onboarding was completed.
  ///
  /// May be 0 if onboarding is not complete.
  final int triggerDays;

  /// Number of posted, non-deleted transactions.
  final int transactionCount;
}

/// Domain service that evaluates backup-reminder display conditions.
///
/// Stateless; inject and call [check] on each home-screen build.
class BackupReminderChecker {
  /// Creates a [BackupReminderChecker].
  ///
  /// Parameters:
  /// - [transactionRepository]: Used to count posted transactions.
  const BackupReminderChecker({
    required ITransactionRepository transactionRepository,
    DateTime Function()? now,
  })  : _transactionRepository = transactionRepository,
        _now = now ?? _defaultNow;

  final ITransactionRepository _transactionRepository;

  /// Clock override — defaults to [DateTime.now].
  final DateTime Function() _now;

  static DateTime _defaultNow() => DateTime.now();

  /// Evaluates whether the backup reminder should be shown.
  ///
  /// Returns a [BackupReminderResult] with [shouldShow] set to true when:
  ///   - Onboarding is complete, AND
  ///   - [AppSettings.lastBackupAt] is null (no backup made yet), AND
  ///   - At least one trigger is met:
  ///       a. Days since onboarding >= 30, OR
  ///       b. Posted transaction count >= 50.
  ///
  /// Parameters:
  /// - [settings]: Current [AppSettings] snapshot.
  /// - [onboardingCompletedAt]: Unix epoch seconds of onboarding completion.
  ///   Pass null when onboarding is not yet complete.
  Future<BackupReminderResult> check({
    required AppSettings settings,
    required int? onboardingCompletedAt,
  }) async {
    // Onboarding must be complete before we start nagging.
    if (!settings.onboardingComplete || onboardingCompletedAt == null) {
      return const BackupReminderResult(
        shouldShow: false,
        triggerDays: 0,
        transactionCount: 0,
      );
    }

    // Skip if the user has already backed up.
    if (settings.lastBackupAt != null) {
      final count = await _transactionRepository.countPosted();
      return BackupReminderResult(
        shouldShow: false,
        triggerDays: _daysSince(onboardingCompletedAt),
        transactionCount: count,
      );
    }

    final daysSince = _daysSince(onboardingCompletedAt);
    final count = await _transactionRepository.countPosted();

    final shouldShow = daysSince >= 30 || count >= 50;

    return BackupReminderResult(
      shouldShow: shouldShow,
      triggerDays: daysSince,
      transactionCount: count,
    );
  }

  /// Computes days elapsed since [epochSeconds].
  int _daysSince(int epochSeconds) {
    final then = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final today = _now().toUtc();
    return today.difference(then).inDays;
  }
}
