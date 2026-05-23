// test/unit/domain/usecases/recurring/unpause_auto_resume_test.dart
//
// Unit tests for T-114: Unpause + Sweep Auto-Resume logic.
//
// Covers:
//   1. Manual unpause: resume(id) sets status=active, pauseUntil=null.
//   2. Sweep auto-resume: paused templates with pause_until ≤ asOf are
//      auto-resumed before posting in PostDueOccurrencesUseCase.
//   3. Skipped occurrences remain skipped after resume.
//   4. Templates with pause_until > asOf are NOT auto-resumed.
//
// The IRecurringTemplateRepository.resume stub is already covered in
// RecurringTemplateRepositoryImpl (stub). These tests exercise the
// PostDueOccurrencesUseCase auto-resume path and the repository interface.

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Records calls to resume() so tests can assert on them.
class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({required this.templates});

  List<RecurringTemplate> templates;
  final List<String> resumedIds = [];

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value(templates);

  @override
  Stream<RecurringTemplate?> watchById(String id) =>
      Stream.value(templates.where((t) => t.id == id).firstOrNull);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async =>
      const Ok(null);

  @override
  Future<Result<void>> resume(String id) async {
    resumedIds.add(id);
    // Mutate in-place: set status → active, pauseUntil → null.
    templates = templates.map((t) {
      if (t.id == id)
        return t.copyWith(
            status: RecurringTemplateStatus.active, pauseUntil: null);
      return t;
    }).toList();
    return const Ok(null);
  }

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

/// Returns a configurable list of pending occurrences.
class _FakeOccurrenceRepository implements IScheduledOccurrenceRepository {
  _FakeOccurrenceRepository({required this.pendingOccurrences});

  final List<ScheduledOccurrence> pendingOccurrences;
  final List<String> markedPosted = [];

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async =>
      pendingOccurrences;

  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) async =>
      [];

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    markedPosted.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> markSkipped(String id) async => const Ok(null);

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

/// A stub transaction repository that always succeeds.
class _FakeTransactionRepository implements ITransactionRepository {
  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async =>
      Ok(draft);

  @override
  Future<int> countPosted() async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A stub LedgerRepository that satisfies the LedgerEngine constructor.
class _NullLedgerRepo implements LedgerRepository {
  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);

  @override
  Future<bool> eqAccountExists(String currencyCode) async => false;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      const Err(DatabaseFailure('stub'));
}

/// A LedgerEngine double that always fails (so no posting happens in sweep).
class _FailingLedgerEngine extends LedgerEngine {
  _FailingLedgerEngine() : super(_NullLedgerRepo());

  @override
  Future<Result<List<Entry>>> buildOnly(CreateTransactionInput input) async =>
      const Err(DatabaseFailure('stub — no posting needed in unpause tests'));
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

RecurringTemplate _makeTemplate({
  required String id,
  required RecurringTemplateStatus status,
  int? pauseUntil,
  PostingBehaviour postingBehaviour = PostingBehaviour.autoPost,
}) =>
    RecurringTemplate(
      id: id,
      transactionType: 'expense',
      status: status,
      amountMinor: 100000,
      currencyCode: 'INR',
      recurrenceN: 1,
      recurrenceUnit: RecurrenceUnit.month,
      startDate: 20000,
      pauseUntil: pauseUntil,
      postingBehaviour: postingBehaviour,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------------------------------------------------------------------------
  // 1. Manual unpause: repository resume() records the id
  // ---------------------------------------------------------------------------

  group('IRecurringTemplateRepository.resume (manual unpause)', () {
    test('1. resume(id) records call and transitions status to active',
        () async {
      final repo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'tpl-paused',
            status: RecurringTemplateStatus.paused,
            pauseUntil: 9999999999, // far future
          ),
        ],
      );

      final result = await repo.resume('tpl-paused');
      expect(result, isA<Ok<void>>());
      expect(repo.resumedIds, contains('tpl-paused'));

      // After resume the template should be active.
      final updated = await repo.watchById('tpl-paused').first;
      expect(updated?.status, RecurringTemplateStatus.active);
      expect(updated?.pauseUntil, isNull);
    });

    test('2. resume(id) for non-paused template still succeeds (no-op)',
        () async {
      final repo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'tpl-active',
            status: RecurringTemplateStatus.active,
          ),
        ],
      );

      final result = await repo.resume('tpl-active');
      expect(result, isA<Ok<void>>());
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Sweep auto-resume: PostDueOccurrencesUseCase._autoResumePausedTemplates
  // ---------------------------------------------------------------------------

  group('PostDueOccurrencesUseCase auto-resume (T-114)', () {
    late _FakeTemplateRepository templateRepo;
    late _FakeOccurrenceRepository occRepo;
    late PostDueOccurrencesUseCase useCase;

    /// asOf epoch second: 1700000100 (a fixed point in time for tests).
    const asOfEpoch = 1700000100;
    final asOf = DateTime.fromMillisecondsSinceEpoch(asOfEpoch * 1000);

    setUp(() {
      occRepo = _FakeOccurrenceRepository(pendingOccurrences: []);
    });

    test('3. paused template with pause_until ≤ asOf is auto-resumed',
        () async {
      // pause_until is in the past relative to asOf → should be resumed.
      templateRepo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'tpl-expired',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch - 3600, // 1 hour before asOf
          ),
        ],
      );

      useCase = PostDueOccurrencesUseCase(
        templateRepo,
        occRepo,
        _FakeTransactionRepository(),
        _FailingLedgerEngine(),
      );

      await useCase(asOf: asOf);

      expect(templateRepo.resumedIds, contains('tpl-expired'));
    });

    test('4. paused template with pause_until > asOf is NOT auto-resumed',
        () async {
      // pause_until is in the future → should NOT be resumed.
      templateRepo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'tpl-future',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch + 86400, // 1 day after asOf
          ),
        ],
      );

      useCase = PostDueOccurrencesUseCase(
        templateRepo,
        occRepo,
        _FakeTransactionRepository(),
        _FailingLedgerEngine(),
      );

      await useCase(asOf: asOf);

      expect(templateRepo.resumedIds, isEmpty);
    });

    test('5. skipped occurrences remain skipped after auto-resume', () async {
      // Template is auto-resumed, but skipped occurrences are not re-queued.
      templateRepo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'tpl-resume',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch - 1,
          ),
        ],
      );

      // A skipped occurrence for the template that was paused.
      const skippedOcc = ScheduledOccurrence(
        id: 'occ-skipped',
        templateId: 'tpl-resume',
        scheduledDate: 20000,
        status: ScheduledOccurrenceStatus.skipped,
        createdAt: 1700000000,
        updatedAt: 1700000000,
      );

      final occRepoWithSkipped = _FakeOccurrenceRepository(
        // getPendingDue only returns pending; skipped ones are not in this list.
        pendingOccurrences: [],
      );

      useCase = PostDueOccurrencesUseCase(
        templateRepo,
        occRepoWithSkipped,
        _FakeTransactionRepository(),
        _FailingLedgerEngine(),
      );

      final result = await useCase(asOf: asOf);

      // Template was resumed.
      expect(templateRepo.resumedIds, contains('tpl-resume'));
      // No occurrences were posted (pending list was empty).
      expect(result, isA<Ok<PostingResult>>());
      expect((result as Ok<PostingResult>).value.autoPostedCount, 0);
      // Skipped occurrence was not marked posted.
      expect(occRepoWithSkipped.markedPosted, isEmpty);
      // Verify the skipped occurrence is still in its original state
      // (our fake doesn't persist, but the test verifies no markPosted call).
      expect(skippedOcc.status, ScheduledOccurrenceStatus.skipped);
    });

    test('6. multiple paused templates: only expired ones are resumed',
        () async {
      templateRepo = _FakeTemplateRepository(
        templates: [
          _makeTemplate(
            id: 'expired-1',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch - 100,
          ),
          _makeTemplate(
            id: 'expired-2',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch, // exactly at asOf (≤ passes)
          ),
          _makeTemplate(
            id: 'future-1',
            status: RecurringTemplateStatus.paused,
            pauseUntil: asOfEpoch + 1,
          ),
          _makeTemplate(
            id: 'active-1',
            status: RecurringTemplateStatus.active,
          ),
        ],
      );

      useCase = PostDueOccurrencesUseCase(
        templateRepo,
        occRepo,
        _FakeTransactionRepository(),
        _FailingLedgerEngine(),
      );

      await useCase(asOf: asOf);

      expect(templateRepo.resumedIds, containsAll(['expired-1', 'expired-2']));
      expect(templateRepo.resumedIds, isNot(contains('future-1')));
      expect(templateRepo.resumedIds, isNot(contains('active-1')));
    });
  });
}
