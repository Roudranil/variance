// test/unit/domain/usecases/post_due_occurrences_use_case_test.dart
//
// Unit tests for PostDueOccurrencesUseCase (T-101).
//
// Test cases:
//   1. zero due occurrences → Ok(0), no transactions created
//   2. one due auto_post expense → Ok(1), occurrence marked posted
//   3. multiple due occurrences → Ok(n), all posted
//   4. paused template with pause_until <= now is auto-resumed before posting
//   5. remind_and_confirm template → skipped, not posted
//   6. non-active (paused, not resumable) template → skipped

import 'package:flutter_test/flutter_test.dart';
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
// Helpers
// ---------------------------------------------------------------------------

/// Epoch day for a date in the past (always "due").
final _kPastEpochDay = (DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch ~/
    86400000);

/// Epoch seconds for now.
final _kNowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// Builds a minimal active recurring template.
RecurringTemplate _template({
  String id = 'tmpl-1',
  String transactionType = 'expense',
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
  PostingBehaviour postingBehaviour = PostingBehaviour.autoPost,
  int? pauseUntil,
  String? accountSourceId = 'acc-src',
  String? accountDestinationId,
  String? categoryId = 'cat-1',
}) =>
    RecurringTemplate(
      id: id,
      transactionType: transactionType,
      status: status,
      amountMinor: 1000,
      currencyCode: 'INR',
      accountSourceId: accountSourceId,
      accountDestinationId: accountDestinationId,
      categoryId: categoryId,
      recurrenceN: 1,
      recurrenceUnit: RecurrenceUnit.month,
      startDate: _kPastEpochDay,
      postingBehaviour: postingBehaviour,
      pauseUntil: pauseUntil,
      createdAt: _kNowEpoch,
      updatedAt: _kNowEpoch,
    );

/// Builds a minimal pending scheduled occurrence.
ScheduledOccurrence _occurrence({
  String id = 'occ-1',
  String templateId = 'tmpl-1',
}) =>
    ScheduledOccurrence(
      id: id,
      templateId: templateId,
      scheduledDate: _kPastEpochDay,
      createdAt: _kNowEpoch,
      updatedAt: _kNowEpoch,
    );

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({List<RecurringTemplate>? templates})
      : _templates = templates ?? [];

  List<RecurringTemplate> _templates;

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value(_templates);

  @override
  Stream<RecurringTemplate?> watchById(String id) =>
      Stream.value(_templates.where((t) => t.id == id).firstOrNull);

  final _resumed = <String>[];
  List<String> get resumed => List.unmodifiable(_resumed);

  @override
  Future<Result<void>> resume(String id) async {
    _resumed.add(id);
    _templates = _templates
        .map(
          (t) => t.id == id
              ? t.copyWith(
                  status: RecurringTemplateStatus.active,
                  pauseUntil: null,
                )
              : t,
        )
        .toList();
    return const Ok(null);
  }

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) =>
      throw UnimplementedError();

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) => throw UnimplementedError();

  @override
  Future<Result<void>> softDelete(String id) => throw UnimplementedError();

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      Ok(_templates);
}

class _FakeOccurrenceRepository implements IScheduledOccurrenceRepository {
  _FakeOccurrenceRepository({List<ScheduledOccurrence>? pending})
      : _pending = pending ?? [];

  final List<ScheduledOccurrence> _pending;
  final _posted = <String, String>{};
  final _skipped = <String>[];

  Map<String, String> get posted => Map.unmodifiable(_posted);
  List<String> get skipped => List.unmodifiable(_skipped);

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async =>
      _pending;

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    _posted[id] = transactionId;
    return const Ok(null);
  }

  @override
  Future<Result<void>> markSkipped(String id) async {
    _skipped.add(id);
    return const Ok(null);
  }

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

class _FakeTransactionRepository implements ITransactionRepository {
  final _created = <String>[];
  List<String> get created => List.unmodifiable(_created);

  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async {
    _created.add(draft.id);
    return Ok(draft);
  }

  @override
  Future<Result<Transaction>> create(Transaction draft) =>
      throw UnimplementedError();

  @override
  Stream<List<Transaction>> watchByMonth(int year, int month,
          {TransactionFilters? filters,}) =>
      throw UnimplementedError();

  @override
  Stream<Transaction?> watchById(String id) => throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> void$(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> bulkVoid(List<String> ids) =>
      throw UnimplementedError();

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Fake LedgerRepository for LedgerEngine
// ---------------------------------------------------------------------------

class _NoOpLedgerRepository implements LedgerRepository {
  const _NoOpLedgerRepository();

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);

  @override
  Future<bool> eqAccountExists(String currencyCode) async => true;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      Ok('__EQ_$currencyCode');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const ledgerEngine = LedgerEngine(_NoOpLedgerRepository());

  PostDueOccurrencesUseCase makeUseCase({
    required _FakeTemplateRepository templateRepo,
    required _FakeOccurrenceRepository occRepo,
    required _FakeTransactionRepository txRepo,
  }) =>
      PostDueOccurrencesUseCase(templateRepo, occRepo, txRepo, ledgerEngine);

  group('PostDueOccurrencesUseCase', () {
    test('1. zero due occurrences → Ok(0), no transactions created', () async {
      final templateRepo = _FakeTemplateRepository(templates: [_template()]);
      final occRepo = _FakeOccurrenceRepository(pending: []);
      final txRepo = _FakeTransactionRepository();

      final result = await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 0);
      expect(txRepo.created, isEmpty);
    });

    test('2. one due auto_post expense → Ok(1), occurrence marked posted',
        () async {
      final tmpl = _template();
      final occ = _occurrence(templateId: tmpl.id);
      final templateRepo = _FakeTemplateRepository(templates: [tmpl]);
      final occRepo = _FakeOccurrenceRepository(pending: [occ]);
      final txRepo = _FakeTransactionRepository();

      final result = await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 1);
      expect(txRepo.created, hasLength(1));
      expect(occRepo.posted.keys, contains(occ.id));
    });

    test('3. multiple due occurrences → Ok(n), all posted', () async {
      final tmpl = _template();
      final occurrences = [
        _occurrence(id: 'occ-1', templateId: tmpl.id),
        _occurrence(id: 'occ-2', templateId: tmpl.id),
        _occurrence(id: 'occ-3', templateId: tmpl.id),
      ];
      final templateRepo = _FakeTemplateRepository(templates: [tmpl]);
      final occRepo = _FakeOccurrenceRepository(pending: occurrences);
      final txRepo = _FakeTransactionRepository();

      final result = await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 3);
      expect(txRepo.created, hasLength(3));
    });

    test('4. paused template with pause_until <= now is auto-resumed',
        () async {
      // pause_until in the past means it should auto-resume.
      final pastEpoch = _kNowEpoch - 86400; // 1 day ago
      final tmpl = _template(
        status: RecurringTemplateStatus.paused,
        pauseUntil: pastEpoch,
      );
      final occ = _occurrence(templateId: tmpl.id);
      final templateRepo = _FakeTemplateRepository(templates: [tmpl]);
      final occRepo = _FakeOccurrenceRepository(pending: [occ]);
      final txRepo = _FakeTransactionRepository();

      await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      // Auto-resume should have been called.
      expect(templateRepo.resumed, contains(tmpl.id));
    });

    test('5. remind_and_confirm template → skipped, not posted', () async {
      final tmpl = _template(
        postingBehaviour: PostingBehaviour.remindAndConfirm,
      );
      final occ = _occurrence(templateId: tmpl.id);
      final templateRepo = _FakeTemplateRepository(templates: [tmpl]);
      final occRepo = _FakeOccurrenceRepository(pending: [occ]);
      final txRepo = _FakeTransactionRepository();

      final result = await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 0);
      expect(txRepo.created, isEmpty);
      expect(occRepo.posted, isEmpty);
    });

    test('6. non-active (paused with future pause_until) template → skipped',
        () async {
      final futureEpoch = _kNowEpoch + 86400 * 30; // 30 days future
      final tmpl = _template(
        status: RecurringTemplateStatus.paused,
        pauseUntil: futureEpoch,
      );
      final occ = _occurrence(templateId: tmpl.id);
      final templateRepo = _FakeTemplateRepository(templates: [tmpl]);
      final occRepo = _FakeOccurrenceRepository(pending: [occ]);
      final txRepo = _FakeTransactionRepository();

      final result = await makeUseCase(
        templateRepo: templateRepo,
        occRepo: occRepo,
        txRepo: txRepo,
      ).call();

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 0);
      expect(txRepo.created, isEmpty);
    });
  });
}
