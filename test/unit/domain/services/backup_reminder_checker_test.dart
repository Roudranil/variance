// test/unit/domain/services/backup_reminder_checker_test.dart
//
// Unit tests for BackupReminderChecker (T-170).
//
// Test cases:
//   T-170.1  shouldShow = true when elapsed days >= 30 and no backup made
//   T-170.2  shouldShow = true when transaction count >= 50 and no backup made
//   T-170.3  shouldShow = false when both conditions met but lastBackupAt set
//   T-170.4  shouldShow = false when elapsed < 30 days and count < 50
//   T-170.5  shouldShow = false when onboardingComplete = false
//   T-170.6  shouldShow = false when onboardingCompletedAt is null

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/backup_reminder_checker.dart';

// ---------------------------------------------------------------------------
// Fake TransactionRepository — only countPosted is exercised here.
// ---------------------------------------------------------------------------

class _FakeTransactionRepository implements ITransactionRepository {
  _FakeTransactionRepository({required this.postedCount});

  final int postedCount;

  @override
  Future<int> countPosted() async => postedCount;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        invocation.memberName.toString(),
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a Unix epoch seconds value [daysAgo] days before [now].
int _epochDaysAgo(int daysAgo, {DateTime? now}) {
  final base = now ?? DateTime.now();
  return base.subtract(Duration(days: daysAgo)).millisecondsSinceEpoch ~/ 1000;
}

BackupReminderChecker _makeChecker({
  required int postedCount,
  DateTime? fixedNow,
}) {
  return BackupReminderChecker(
    transactionRepository: _FakeTransactionRepository(postedCount: postedCount),
    now: fixedNow != null ? () => fixedNow : null,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BackupReminderChecker', () {
    final fixedNow = DateTime(2025, 6, 1, 12);

    test(
      'T-170.1 shouldShow = true when elapsed days >= 30 and no backup',
      () async {
        final checker = _makeChecker(postedCount: 5, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(35, now: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isTrue);
        expect(result.triggerDays, greaterThanOrEqualTo(30));
      },
    );

    test(
      'T-170.2 shouldShow = true when count >= 50 and no backup',
      () async {
        final checker = _makeChecker(postedCount: 55, fixedNow: fixedNow);
        // Only 10 days elapsed — day trigger not met.
        final onboardedAt = _epochDaysAgo(10, now: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isTrue);
        expect(result.transactionCount, greaterThanOrEqualTo(50));
      },
    );

    test(
      'T-170.3 shouldShow = false when both conditions met but lastBackupAt is set',
      () async {
        final checker = _makeChecker(postedCount: 55, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(35, now: fixedNow);
        final lastBackupAt = _epochDaysAgo(1, now: fixedNow);

        final result = await checker.check(
          settings: AppSettings(
            onboardingComplete: true,
            lastBackupAt: lastBackupAt,
          ),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isFalse);
      },
    );

    test(
      'T-170.4 shouldShow = false when elapsed < 30 days and count < 50',
      () async {
        final checker = _makeChecker(postedCount: 10, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(15, now: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isFalse);
      },
    );

    test(
      'T-170.5 shouldShow = false when onboardingComplete = false',
      () async {
        final checker = _makeChecker(postedCount: 55, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(35, now: fixedNow);

        final result = await checker.check(
          // onboardingComplete defaults to false.
          settings: const AppSettings(),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isFalse);
      },
    );

    test(
      'T-170.6 shouldShow = false when onboardingCompletedAt is null',
      () async {
        final checker = _makeChecker(postedCount: 55, fixedNow: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: null,
        );

        expect(result.shouldShow, isFalse);
      },
    );

    test(
      'T-170.7 exactly 30 days triggers shouldShow = true',
      () async {
        final checker = _makeChecker(postedCount: 0, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(30, now: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isTrue);
      },
    );

    test(
      'T-170.8 exactly 50 transactions triggers shouldShow = true',
      () async {
        final checker = _makeChecker(postedCount: 50, fixedNow: fixedNow);
        final onboardedAt = _epochDaysAgo(5, now: fixedNow);

        final result = await checker.check(
          settings: const AppSettings(onboardingComplete: true),
          onboardingCompletedAt: onboardedAt,
        );

        expect(result.shouldShow, isTrue);
      },
    );
  });
}
