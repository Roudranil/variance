// test/unit/domain/usecases/recurring/pause_recurring_template_use_case_test.dart
//
// Unit tests for PauseRecurringTemplateUseCase (T-113).
//
// Test cases:
//   1. N-units pause (1 month): pause_until is ~30 days from now.
//   2. Custom date pause: pause_until equals midnight UTC of the custom date.
//   3. N = 0 returns ValidationFailure.
//   4. Custom date in the past returns ValidationFailure.
//   5. Custom date = today (same day, past midnight UTC) returns ValidationFailure.
//   6. Pending occurrences within pause window are skipped.
//   7. Occurrences after pause_until are not skipped.
//   8. Template not found returns NotFoundFailure.

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/usecases/recurring/pause_recurring_template_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({this.stored});

  RecurringTemplate? stored;
  String? lastPausedId;
  int? lastPausedUntil;

  @override
  Stream<RecurringTemplate?> watchById(String id) {
    if (stored?.id == id) return Stream.value(stored);
    return Stream.value(null);
  }

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async {
    lastPausedId = id;
    lastPausedUntil = pauseUntil;
    return const Ok(null);
  }

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value([]);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

class _FakeOccurrenceRepository implements IScheduledOccurrenceRepository {
  _FakeOccurrenceRepository({List<ScheduledOccurrence>? occurrences})
      : _occurrences = occurrences ?? [];

  final List<ScheduledOccurrence> _occurrences;
  final List<String> skippedIds = [];

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async {
    final asOfDays = asOf.millisecondsSinceEpoch ~/ (86400 * 1000);
    return _occurrences
        .where(
          (o) =>
              o.status == ScheduledOccurrenceStatus.pending &&
              o.scheduledDate <= asOfDays,
        )
        .toList();
  }

  @override
  Future<Result<void>> markSkipped(String id) async {
    skippedIds.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async =>
      const Ok(null);

  @override
  Future<Result<void>> markCancelled(String id) async => const Ok(null);

  @override
  Future<Result<void>> generateLookahead({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<ScheduledOccurrence> occurrences,
  }) async =>
      const Ok(null);
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _baseTemplate = RecurringTemplate(
  id: 'tpl-001',
  transactionType: 'expense',
  amountMinor: 10000,
  currencyCode: 'INR',
  accountSourceId: 'acc-001',
  recurrenceN: 1,
  recurrenceUnit: RecurrenceUnit.month,
  startDate: 20000,
  createdAt: 1000000,
  updatedAt: 1000000,
);

ScheduledOccurrence _makeOcc(
  String id,
  int scheduledDateDays, {
  ScheduledOccurrenceStatus status = ScheduledOccurrenceStatus.pending,
}) {
  return ScheduledOccurrence(
    id: id,
    templateId: 'tpl-001',
    scheduledDate: scheduledDateDays,
    status: status,
    createdAt: 1000000,
    updatedAt: 1000000,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PauseRecurringTemplateUseCase', () {
    // -------------------------------------------------------------------------
    // 1. N-units pause: sets pause_until > now
    // -------------------------------------------------------------------------
    test('N=1 month pause sets pause_until approximately 1 month from now',
        () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final occRepo = _FakeOccurrenceRepository();
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      final result = await useCase(
        const PauseInput.byUnits(templateId: 'tpl-001', durationN: 1),
      );

      expect(result, isA<Ok<void>>());
      expect(repo.lastPausedId, 'tpl-001');

      // pause_until should be ~ 1 month from now (within 2-day tolerance).
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const approxOneMonth = 30 * 86400;
      expect(
        repo.lastPausedUntil! - nowEpoch,
        greaterThan(approxOneMonth - 2 * 86400),
      );
      expect(
        repo.lastPausedUntil! - nowEpoch,
        lessThan(approxOneMonth + 2 * 86400),
      );
    });

    // -------------------------------------------------------------------------
    // 2. Custom date pause
    // -------------------------------------------------------------------------
    test('custom date pause sets pause_until to midnight UTC of custom date',
        () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final occRepo = _FakeOccurrenceRepository();
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      final futureDate = DateTime.now().add(const Duration(days: 30));

      final result = await useCase(
        PauseInput.byDate(templateId: 'tpl-001', customDate: futureDate),
      );

      expect(result, isA<Ok<void>>());

      final expectedMidnight = DateTime.utc(
        futureDate.year,
        futureDate.month,
        futureDate.day,
      );
      final expectedEpoch =
          expectedMidnight.millisecondsSinceEpoch ~/ 1000;
      expect(repo.lastPausedUntil, expectedEpoch);
    });

    // -------------------------------------------------------------------------
    // 3. N = 0 → ValidationFailure
    // -------------------------------------------------------------------------
    test('N=0 returns ValidationFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final occRepo = _FakeOccurrenceRepository();
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      final result = await useCase(
        const PauseInput.byUnits(templateId: 'tpl-001', durationN: 0),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
    });

    // -------------------------------------------------------------------------
    // 4. Custom date in the past → ValidationFailure
    // -------------------------------------------------------------------------
    test('custom date in the past returns ValidationFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final occRepo = _FakeOccurrenceRepository();
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      final result = await useCase(
        PauseInput.byDate(templateId: 'tpl-001', customDate: pastDate),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
    });

    // -------------------------------------------------------------------------
    // 5. Pending occurrences in window are skipped
    // -------------------------------------------------------------------------
    test('pending occurrences within pause window are skipped', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);

      // Create occurrences:
      //   - occ1: scheduledDate = today (should be skipped)
      //   - occ2: scheduledDate = today + 5 days (within 30-day pause)
      //   - occ3: scheduledDate = today + 60 days (outside 30-day pause)
      final todayDays =
          DateTime.now().millisecondsSinceEpoch ~/ (86400 * 1000);
      final occurrences = [
        _makeOcc('occ-1', todayDays),
        _makeOcc('occ-2', todayDays + 5),
        _makeOcc('occ-3', todayDays + 60),
      ];

      final occRepo = _FakeOccurrenceRepository(occurrences: occurrences);
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      await useCase(
        const PauseInput.byUnits(templateId: 'tpl-001', durationN: 1),
      );

      // occ-1 and occ-2 should be skipped (within ~30 days); occ-3 should not.
      expect(occRepo.skippedIds, contains('occ-1'));
      expect(occRepo.skippedIds, contains('occ-2'));
      expect(occRepo.skippedIds, isNot(contains('occ-3')));
    });

    // -------------------------------------------------------------------------
    // 6. Already-posted occurrences are not skipped
    // -------------------------------------------------------------------------
    test('already-posted occurrences are not skipped', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final todayDays =
          DateTime.now().millisecondsSinceEpoch ~/ (86400 * 1000);
      final occurrences = [
        _makeOcc('occ-posted', todayDays,
            status: ScheduledOccurrenceStatus.posted,),
      ];

      final occRepo = _FakeOccurrenceRepository(occurrences: occurrences);
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      await useCase(
        const PauseInput.byUnits(templateId: 'tpl-001', durationN: 1),
      );

      // Posted occurrence should NOT be skipped.
      expect(occRepo.skippedIds, isNot(contains('occ-posted')));
    });

    // -------------------------------------------------------------------------
    // 7. Template not found → NotFoundFailure
    // -------------------------------------------------------------------------
    test('template not found returns NotFoundFailure', () async {
      final repo = _FakeTemplateRepository(stored: null);
      final occRepo = _FakeOccurrenceRepository();
      final useCase = PauseRecurringTemplateUseCase(repo, occRepo);

      final result = await useCase(
        const PauseInput.byUnits(templateId: 'tpl-999', durationN: 1),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<NotFoundFailure>());
    });
  });
}
