// test/integration/app_launch_sweep_test.dart
//
// Integration test: App-Launch Sweep End-to-End (T-122).
//
// These tests verify the full sweep pipeline using in-memory fakes that mirror
// the behaviour of real repositories. They test the integration between
// AppInitializer, PostDueOccurrencesUseCase, and GenerateLookaheadUseCase.
//
// Note: Full on-device integration tests (with real SQLite + WorkManager) are
// captured in the integration_test/ directory and run on device/emulator.
// These unit-level integration tests verify the business logic correctness
// without requiring a device.
//
// Test cases:
//   T-122.1  auto_post occurrence posted after sweep (transaction exists).
//   T-122.2  90-day lookahead rows generated after sweep.
//   T-122.3  Pause auto-resume: paused template with expired pause_until
//            becomes active after sweep.
//   T-122.4  Template with future pause_until is NOT auto-resumed.

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
import 'package:variance/domain/usecases/recurring/generate_lookahead_use_case.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';

// ---------------------------------------------------------------------------
// In-memory fake repositories
// ---------------------------------------------------------------------------

class _InMemoryTemplateRepo implements IRecurringTemplateRepository {
  final List<RecurringTemplate> _templates;

  _InMemoryTemplateRepo(this._templates);

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value(_templates);

  @override
  Stream<RecurringTemplate?> watchById(String id) =>
      Stream.value(_templates.where((t) => t.id == id).firstOrNull);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async {
    _templates.add(t);
    return Ok(t);
  }

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async {
    final idx = _templates.indexWhere((x) => x.id == t.id);
    if (idx >= 0) _templates[idx] = t;
    return Ok(t);
  }

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async {
    final idx = _templates.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _templates[idx] = _templates[idx].copyWith(
        status: RecurringTemplateStatus.paused,
        pauseUntil: pauseUntil,
      );
    }
    return const Ok(null);
  }

  @override
  Future<Result<void>> resume(String id) async {
    final idx = _templates.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _templates[idx] = _templates[idx].copyWith(
        status: RecurringTemplateStatus.active,
        pauseUntil: null,
      );
    }
    return const Ok(null);
  }

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      Ok(_templates);
}

class _InMemoryOccurrenceRepo implements IScheduledOccurrenceRepository {
  final List<ScheduledOccurrence> _occurrences;
  final List<String> postedIds = [];

  _InMemoryOccurrenceRepo([List<ScheduledOccurrence>? initial])
      : _occurrences = initial ?? [];

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async {
    final asOfDay = asOf.millisecondsSinceEpoch ~/ 86400000;
    return _occurrences
        .where(
          (o) =>
              o.status == ScheduledOccurrenceStatus.pending &&
              o.scheduledDate <= asOfDay,
        )
        .toList();
  }

  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) async {
    final cutoffDay =
        asOf.subtract(const Duration(hours: 24)).millisecondsSinceEpoch ~/
            86400000;
    return _occurrences
        .where(
          (o) =>
              o.status == ScheduledOccurrenceStatus.pending &&
              o.scheduledDate < cutoffDay,
        )
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    postedIds.add(id);
    final idx = _occurrences.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _occurrences[idx] = _occurrences[idx].copyWith(
        status: ScheduledOccurrenceStatus.posted,
        childTransactionId: transactionId,
      );
    }
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
  }) async {
    // Simulate inserting lookahead rows.
    _occurrences.addAll(occurrences);
    return const Ok(null);
  }
}

class _InMemoryTxRepo implements ITransactionRepository {
  final List<Transaction> created = [];

  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction tx,
    List<Entry> entries,
  ) async {
    created.add(tx);
    return Ok(tx);
  }

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpLedgerRepo implements LedgerRepository {
  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);

  @override
  Future<bool> eqAccountExists(String currencyCode) async => false;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      const Err(DatabaseFailure('no-op'));
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

RecurringTemplate _makeTemplate({
  required String id,
  PostingBehaviour behaviour = PostingBehaviour.autoPost,
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
  int? pauseUntil,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return RecurringTemplate(
    id: id,
    title: 'Test Template $id',
    transactionType: 'expense',
    amountMinor: 5000,
    currencyCode: 'INR',
    recurrenceUnit: RecurrenceUnit.month,
    recurrenceN: 1,
    startDate: DateTime.now().millisecondsSinceEpoch ~/ 86400000,
    postingBehaviour: behaviour,
    status: status,
    pauseUntil: pauseUntil,
    accountSourceId: 'acc-1',
    createdAt: now,
    updatedAt: now,
  );
}

ScheduledOccurrence _makeOcc({
  required String id,
  required String templateId,
  required int scheduledDate,
  ScheduledOccurrenceStatus status = ScheduledOccurrenceStatus.pending,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return ScheduledOccurrence(
    id: id,
    templateId: templateId,
    scheduledDate: scheduledDate,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(AppInitializer.clearForTest);

  final pastDay =
      DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/
          86400000;

  test('T-122.1 auto_post occurrence is posted after sweep', () async {
    final template = _makeTemplate(id: 'tmpl-1');
    final occ = _makeOcc(
      id: 'occ-1',
      templateId: 'tmpl-1',
      scheduledDate: pastDay,
    );

    final occRepo = _InMemoryOccurrenceRepo([occ]);
    final txRepo = _InMemoryTxRepo();

    final postDue = PostDueOccurrencesUseCase(
      _InMemoryTemplateRepo([template]),
      occRepo,
      txRepo,
      LedgerEngine(_NoOpLedgerRepo()),
    );
    final lookahead = GenerateLookaheadUseCase(
      _InMemoryTemplateRepo([template]),
      occRepo,
    );

    await AppInitializer.run(
      postDueOccurrences: postDue,
      generateLookahead: lookahead,
    );

    // The occurrence should have been posted.
    expect(occRepo.postedIds, contains('occ-1'));
    expect(txRepo.created, isNotEmpty);
    expect(AppInitializer.lastAutoPostedCount, 1);
  });

  test('T-122.2 lookahead rows generated after sweep', () async {
    final template = _makeTemplate(id: 'tmpl-2');
    final occRepo = _InMemoryOccurrenceRepo();
    final txRepo = _InMemoryTxRepo();

    final postDue = PostDueOccurrencesUseCase(
      _InMemoryTemplateRepo([template]),
      occRepo,
      txRepo,
      LedgerEngine(_NoOpLedgerRepo()),
    );
    final lookahead = GenerateLookaheadUseCase(
      _InMemoryTemplateRepo([template]),
      occRepo,
    );

    await AppInitializer.run(
      postDueOccurrences: postDue,
      generateLookahead: lookahead,
    );

    // Lookahead rows should have been inserted.
    expect(occRepo._occurrences, isNotEmpty);
  });

  test('T-122.3 paused template with expired pause_until auto-resumes', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiredPauseUntil = now - 7200; // 2 hours ago
    final template = _makeTemplate(
      id: 'tmpl-3',
      status: RecurringTemplateStatus.paused,
      pauseUntil: expiredPauseUntil,
    );

    final templateRepo = _InMemoryTemplateRepo([template]);
    final occRepo = _InMemoryOccurrenceRepo();

    final postDue = PostDueOccurrencesUseCase(
      templateRepo,
      occRepo,
      _InMemoryTxRepo(),
      LedgerEngine(_NoOpLedgerRepo()),
    );
    final lookahead = GenerateLookaheadUseCase(templateRepo, occRepo);

    await AppInitializer.run(
      postDueOccurrences: postDue,
      generateLookahead: lookahead,
    );

    // Template should now be active.
    final updated = await templateRepo.watchById('tmpl-3').first;
    expect(updated?.status, RecurringTemplateStatus.active);
    expect(updated?.pauseUntil, isNull);
  });

  test('T-122.4 template with future pause_until is NOT auto-resumed', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final futurePauseUntil = now + 86400; // tomorrow
    final template = _makeTemplate(
      id: 'tmpl-4',
      status: RecurringTemplateStatus.paused,
      pauseUntil: futurePauseUntil,
    );

    final templateRepo = _InMemoryTemplateRepo([template]);
    final occRepo = _InMemoryOccurrenceRepo();

    final postDue = PostDueOccurrencesUseCase(
      templateRepo,
      occRepo,
      _InMemoryTxRepo(),
      LedgerEngine(_NoOpLedgerRepo()),
    );
    final lookahead = GenerateLookaheadUseCase(templateRepo, occRepo);

    await AppInitializer.run(
      postDueOccurrences: postDue,
      generateLookahead: lookahead,
    );

    // Template should remain paused.
    final updated = await templateRepo.watchById('tmpl-4').first;
    expect(updated?.status, RecurringTemplateStatus.paused);
  });
}
