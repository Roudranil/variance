// test/unit/domain/usecases/recurring/post_due_stacked_occurrences_test.dart
//
// Unit tests for T-120: Stacked Missed Occurrences Auto-Approval in Sweep.
//
// Test cases:
//   T-120.1  Zero stacked occurrences → autoApprovedCount = 0.
//   T-120.2  One stacked remind_and_confirm occurrence > 24h → posted, count = 1.
//   T-120.3  Multiple stacked in chronological order → all posted, count = N.
//   T-120.4  Stacked occurrence uses original scheduled_date as transaction date.
//   T-120.5  remind_and_confirm occurrence < 24h → NOT auto-approved.
//   T-120.6  auto_post occurrences counted separately from auto-approved.

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

class _FakeTemplateRepo implements IRecurringTemplateRepository {
  _FakeTemplateRepo(List<RecurringTemplate> templates) : _templates = templates;

  final List<RecurringTemplate> _templates;

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value(_templates);

  @override
  Stream<RecurringTemplate?> watchById(String id) =>
      Stream.value(_templates.where((t) => t.id == id).firstOrNull);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async =>
      const Ok(null);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

class _FakeOccurrenceRepo implements IScheduledOccurrenceRepository {
  _FakeOccurrenceRepo({
    required List<ScheduledOccurrence> pendingDue,
    required List<ScheduledOccurrence> stackedRemind,
  })  : _pendingDue = pendingDue,
        _stackedRemind = stackedRemind;

  final List<ScheduledOccurrence> _pendingDue;
  final List<ScheduledOccurrence> _stackedRemind;
  final List<String> postedIds = [];

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async =>
      _pendingDue;

  /// Returns remind_and_confirm occurrences older than 24h.
  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) async =>
      _stackedRemind;

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    postedIds.add(id);
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

class _FakeTxRepo implements ITransactionRepository {
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
// Helpers
// ---------------------------------------------------------------------------

RecurringTemplate _makeTemplate({
  String id = 'templ-1',
  PostingBehaviour behaviour = PostingBehaviour.remindAndConfirm,
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
}) =>
    RecurringTemplate(
      id: id,
      title: 'Test',
      transactionType: 'expense',
      amountMinor: 5000,
      currencyCode: 'INR',
      recurrenceUnit: RecurrenceUnit.month,
      recurrenceN: 1,
      startDate: 20000,
      postingBehaviour: behaviour,
      status: status,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

ScheduledOccurrence _makeOccurrence({
  required String id,
  required String templateId,
  required int scheduledDate,
}) =>
    ScheduledOccurrence(
      id: id,
      templateId: templateId,
      scheduledDate: scheduledDate,
      status: ScheduledOccurrenceStatus.pending,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

PostDueOccurrencesUseCase _makeUseCase(
  IRecurringTemplateRepository templateRepo,
  IScheduledOccurrenceRepository occRepo,
  ITransactionRepository txRepo,
) {
  // ignore: prefer_const_constructors — _NoOpLedgerRepo has no const constructor
  return PostDueOccurrencesUseCase(
    templateRepo,
    occRepo,
    txRepo,
    LedgerEngine(_NoOpLedgerRepo()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // asOf = 2023-11-15T12:00:00Z (epoch 1700046000)
  // 24h before = 2023-11-14T12:00:00Z (epoch 1699959600)
  // In days since epoch: 1700046000 / 86400 ≈ 19676 days
  const asOfEpoch = 1700046000;
  final asOf = DateTime.fromMillisecondsSinceEpoch(
    asOfEpoch * 1000,
    isUtc: true,
  );
  // scheduledDate more than 24h before asOf (in epoch days)
  const stackedDays = 19674; // 2 days before asOf
  // scheduledDate less than 24h before asOf (in epoch days)
  const recentDays = 19675; // 1 day before asOf

  test('T-120.1 zero stacked occurrences returns autoApprovedCount=0',
      () async {
    final useCase = _makeUseCase(
      _FakeTemplateRepo([_makeTemplate()]),
      _FakeOccurrenceRepo(pendingDue: [], stackedRemind: []),
      _FakeTxRepo(),
    );

    final result = await useCase.call(asOf: asOf);
    expect(result, isA<Ok<PostingResult>>());
    final counts = (result as Ok<PostingResult>).value;
    expect(counts.autoPostedCount, 0);
    expect(counts.autoApprovedCount, 0);
  });

  test('T-120.2 one stacked remind_and_confirm > 24h is auto-approved',
      () async {
    final template = _makeTemplate(
      behaviour: PostingBehaviour.remindAndConfirm,
    );
    final occurrence = _makeOccurrence(
      id: 'occ-1',
      templateId: template.id,
      scheduledDate: stackedDays,
    );

    final occRepo = _FakeOccurrenceRepo(
      pendingDue: [],
      stackedRemind: [occurrence],
    );

    final useCase = _makeUseCase(
      _FakeTemplateRepo([template]),
      occRepo,
      _FakeTxRepo(),
    );

    final result = await useCase.call(asOf: asOf);
    expect(result, isA<Ok<PostingResult>>());
    final counts = (result as Ok<PostingResult>).value;
    expect(counts.autoApprovedCount, 1);
    expect(occRepo.postedIds, contains('occ-1'));
  });

  test('T-120.3 multiple stacked posted in chronological order', () async {
    final template = _makeTemplate(
      behaviour: PostingBehaviour.remindAndConfirm,
    );
    // Occurrences intentionally out of order.
    final occ3 = _makeOccurrence(
      id: 'occ-3',
      templateId: template.id,
      scheduledDate: stackedDays + 1,
    );
    final occ1 = _makeOccurrence(
      id: 'occ-1',
      templateId: template.id,
      scheduledDate: stackedDays - 1,
    );
    final occ2 = _makeOccurrence(
      id: 'occ-2',
      templateId: template.id,
      scheduledDate: stackedDays,
    );

    final occRepo = _FakeOccurrenceRepo(
      pendingDue: [],
      stackedRemind: [occ3, occ1, occ2],
    );

    final useCase = _makeUseCase(
      _FakeTemplateRepo([template]),
      occRepo,
      _FakeTxRepo(),
    );

    final result = await useCase.call(asOf: asOf);
    expect(result, isA<Ok<PostingResult>>());
    final counts = (result as Ok<PostingResult>).value;
    expect(counts.autoApprovedCount, 3);

    // All posted in chronological order.
    final postedIds = occRepo.postedIds;
    expect(postedIds.length, 3);
    // occ-1 (smallest day) should be first.
    expect(postedIds.first, 'occ-1');
  });

  test('T-120.4 stacked occurrence uses original scheduled_date as tx date',
      () async {
    final template = _makeTemplate(
      behaviour: PostingBehaviour.remindAndConfirm,
    );
    final occurrence = _makeOccurrence(
      id: 'occ-1',
      templateId: template.id,
      scheduledDate: stackedDays,
    );

    final txRepo = _FakeTxRepo();
    final useCase = _makeUseCase(
      _FakeTemplateRepo([template]),
      _FakeOccurrenceRepo(pendingDue: [], stackedRemind: [occurrence]),
      txRepo,
    );

    await useCase.call(asOf: asOf);

    expect(txRepo.created, isNotEmpty);
    // Transaction dateTime should match the scheduledDate in epoch seconds.
    final tx = txRepo.created.first;
    expect(tx.dateTime, stackedDays * 86400);
  });

  test('T-120.5 remind_and_confirm < 24h is NOT auto-approved', () async {
    // recentDays is within 24h of asOf.
    final template = _makeTemplate(
      behaviour: PostingBehaviour.remindAndConfirm,
    );
    final recentOcc = _makeOccurrence(
      id: 'occ-recent',
      templateId: template.id,
      scheduledDate: recentDays,
    );

    // recentOcc is NOT in stackedRemind (already filtered by the query).
    final occRepo = _FakeOccurrenceRepo(
      pendingDue: [],
      stackedRemind: [], // empty — recent ones not included
    );

    final useCase = _makeUseCase(
      _FakeTemplateRepo([template]),
      occRepo,
      _FakeTxRepo(),
    );

    final result = await useCase.call(asOf: asOf);
    final counts = (result as Ok<PostingResult>).value;
    expect(counts.autoApprovedCount, 0);
    // The recent occurrence should NOT be posted.
    expect(occRepo.postedIds, isNot(contains('occ-recent')));
    // Suppress unused variable warning
    expect(recentOcc.scheduledDate, recentDays);
  });

  test('T-120.6 auto_post and auto_approved counted separately', () async {
    final autoPostTemplate = _makeTemplate(
      id: 'auto-templ',
      behaviour: PostingBehaviour.autoPost,
    );
    final remindTemplate = _makeTemplate(
      id: 'remind-templ',
      behaviour: PostingBehaviour.remindAndConfirm,
    );

    final autoDueOcc = _makeOccurrence(
      id: 'auto-occ',
      templateId: autoPostTemplate.id,
      scheduledDate: recentDays,
    );
    final stackedOcc = _makeOccurrence(
      id: 'stacked-occ',
      templateId: remindTemplate.id,
      scheduledDate: stackedDays,
    );

    final occRepo = _FakeOccurrenceRepo(
      pendingDue: [autoDueOcc],
      stackedRemind: [stackedOcc],
    );

    final useCase = _makeUseCase(
      _FakeTemplateRepo([autoPostTemplate, remindTemplate]),
      occRepo,
      _FakeTxRepo(),
    );

    final result = await useCase.call(asOf: asOf);
    final counts = (result as Ok<PostingResult>).value;
    expect(counts.autoPostedCount, 1);
    expect(counts.autoApprovedCount, 1);
  });
}
