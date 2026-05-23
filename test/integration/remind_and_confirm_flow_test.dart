// test/integration/remind_and_confirm_flow_test.dart
//
// Integration test: Remind-and-Confirm Full Flow (T-123).
//
// Tests the full remind_and_confirm lifecycle using in-memory fakes.
//
// Test cases:
//   T-123.1  Confirm action: occurrence is posted, alarm cancelled,
//            child_transaction_id set on occurrence row.
//   T-123.2  Dismiss action: confirmation dialog accepted → occurrence is
//            skipped (status = 'skipped'), no transaction created.
//   T-123.3  24-hour auto-post: occurrence older than 24h + sweep →
//            auto-approved (status = 'posted') with original scheduled_date.
//   T-123.4  Reminder alarm is scheduled for remind_and_confirm template.
//            (Verifies NotificationPluginAdapter.zonedSchedule called.)

import 'dart:convert';

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
import 'package:variance/domain/usecases/recurring/skip_occurrence_use_case.dart';
import 'package:variance/infrastructure/notifications/notification_action_handler.dart';
import 'package:variance/infrastructure/scheduling/reminder_alarm_scheduler.dart';

// ---------------------------------------------------------------------------
// Fakes
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
      Ok(_templates);
}

class _InMemoryOccurrenceRepo implements IScheduledOccurrenceRepository {
  final List<ScheduledOccurrence> _occurrences;

  _InMemoryOccurrenceRepo([List<ScheduledOccurrence>? initial])
      : _occurrences = List.of(initial ?? []);

  ScheduledOccurrence? getById(String id) =>
      _occurrences.where((o) => o.id == id).firstOrNull;

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
  Future<Result<void>> markSkipped(String id) async {
    final idx = _occurrences.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _occurrences[idx] = _occurrences[idx].copyWith(
        status: ScheduledOccurrenceStatus.skipped,
      );
    }
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
  }) async {
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
  Future<int> countPosted() async => created.length;

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

/// Tracking fake NotificationPluginAdapter.
class _FakeNotificationPlugin implements NotificationPluginAdapter {
  final List<int> cancelledIds = [];
  final List<Map<String, dynamic>> scheduledAlarms = [];
  final List<int> shownIds = [];

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required List<NotificationAction> actions,
  }) async {
    scheduledAlarms.add({'id': id, 'title': title, 'payload': payload});
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    shownIds.add(id);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RecurringTemplate _makeRemindTemplate({String id = 'templ-1'}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return RecurringTemplate(
    id: id,
    title: 'Remind Test',
    transactionType: 'expense',
    amountMinor: 10000,
    currencyCode: 'INR',
    recurrenceUnit: RecurrenceUnit.month,
    recurrenceN: 1,
    startDate: DateTime.now().millisecondsSinceEpoch ~/ 86400000,
    postingBehaviour: PostingBehaviour.remindAndConfirm,
    status: RecurringTemplateStatus.active,
    accountSourceId: 'acc-1',
    createdAt: now,
    updatedAt: now,
  );
}

ScheduledOccurrence _makeOcc({
  required String id,
  required String templateId,
  required int scheduledDate,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return ScheduledOccurrence(
    id: id,
    templateId: templateId,
    scheduledDate: scheduledDate,
    status: ScheduledOccurrenceStatus.pending,
    createdAt: now,
    updatedAt: now,
  );
}

String _buildPayload(String occurrenceId, String templateId) => jsonEncode({
      'occurrence_id': occurrenceId,
      'template_id': templateId,
      'amount_minor': 10000,
      'account_source_id': 'acc-1',
    });

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final todayDay = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  final pastDay = todayDay - 2; // 2 days ago

  group('T-123 Remind-and-Confirm Full Flow', () {
    test('T-123.1 Confirm action posts occurrence and cancels alarm', () async {
      final template = _makeRemindTemplate();
      final occ = _makeOcc(
        id: 'occ-1',
        templateId: template.id,
        scheduledDate: pastDay,
      );

      final occRepo = _InMemoryOccurrenceRepo([occ]);
      final txRepo = _InMemoryTxRepo();
      final notificationPlugin = _FakeNotificationPlugin();

      final postDue = PostDueOccurrencesUseCase(
        _InMemoryTemplateRepo([template]),
        occRepo,
        txRepo,
        LedgerEngine(_NoOpLedgerRepo()),
      );
      final skipUseCase = SkipOccurrenceUseCase(occRepo);
      final scheduler = ReminderAlarmScheduler(notificationPlugin);
      final handler = NotificationActionHandler(
        postDueOccurrences: postDue,
        skipOccurrence: skipUseCase,
        scheduler: scheduler,
        navigateToEdit: (_) {},
      );

      // Act: simulate Confirm action.
      await handler.handleAction(
        actionId: NotificationActionId.confirm,
        payload: _buildPayload(occ.id, template.id),
      );

      // Assert: occurrence is now posted.
      final updatedOcc = occRepo.getById(occ.id);
      expect(updatedOcc?.status, ScheduledOccurrenceStatus.posted);
      expect(updatedOcc?.childTransactionId, isNotNull);

      // Transaction was created.
      expect(txRepo.created, isNotEmpty);

      // Alarm was cancelled.
      expect(notificationPlugin.cancelledIds, isNotEmpty);
    });

    test('T-123.2 Dismiss action skips occurrence and cancels alarm', () async {
      final template = _makeRemindTemplate();
      final occ = _makeOcc(
        id: 'occ-2',
        templateId: template.id,
        scheduledDate: pastDay,
      );

      final occRepo = _InMemoryOccurrenceRepo([occ]);
      final txRepo = _InMemoryTxRepo();
      final notificationPlugin = _FakeNotificationPlugin();

      final postDue = PostDueOccurrencesUseCase(
        _InMemoryTemplateRepo([template]),
        occRepo,
        txRepo,
        LedgerEngine(_NoOpLedgerRepo()),
      );
      final skipUseCase = SkipOccurrenceUseCase(occRepo);
      final scheduler = ReminderAlarmScheduler(notificationPlugin);
      final handler = NotificationActionHandler(
        postDueOccurrences: postDue,
        skipOccurrence: skipUseCase,
        scheduler: scheduler,
        navigateToEdit: (_) {},
      );

      // Act: simulate Dismiss action.
      await handler.handleAction(
        actionId: NotificationActionId.dismiss,
        payload: _buildPayload(occ.id, template.id),
      );

      // Assert: occurrence is skipped, no transaction created.
      final updatedOcc = occRepo.getById(occ.id);
      expect(updatedOcc?.status, ScheduledOccurrenceStatus.skipped);
      expect(txRepo.created, isEmpty);

      // Alarm was cancelled.
      expect(notificationPlugin.cancelledIds, isNotEmpty);
    });

    test('T-123.3 24-hour auto-post: stacked occ auto-approved with original date',
        () async {
      final template = _makeRemindTemplate(id: 'templ-3');
      // Occurrence more than 24h old.
      final stackedDay = todayDay - 3;
      final occ = _makeOcc(
        id: 'occ-3',
        templateId: template.id,
        scheduledDate: stackedDay,
      );

      final occRepo = _InMemoryOccurrenceRepo([occ]);
      final txRepo = _InMemoryTxRepo();

      final postDue = PostDueOccurrencesUseCase(
        _InMemoryTemplateRepo([template]),
        occRepo,
        txRepo,
        LedgerEngine(_NoOpLedgerRepo()),
      );

      // Act: run the sweep now.
      final result = await postDue.call();

      // Assert: auto-approved count = 1.
      expect(result, isA<Ok<PostingResult>>());
      final posting = (result as Ok<PostingResult>).value;
      expect(posting.autoApprovedCount, 1);

      // Occurrence is posted.
      final updatedOcc = occRepo.getById(occ.id);
      expect(updatedOcc?.status, ScheduledOccurrenceStatus.posted);

      // Transaction date equals original scheduled_date.
      expect(txRepo.created, isNotEmpty);
      expect(txRepo.created.first.dateTime, stackedDay * 86400);
    });

    test('T-123.4 zonedSchedule called when alarm is scheduled', () async {
      final notificationPlugin = _FakeNotificationPlugin();
      final scheduler = ReminderAlarmScheduler(notificationPlugin);

      // Act: schedule an alarm for a remind_and_confirm occurrence.
      final occ = _makeOcc(
        id: 'occ-4',
        templateId: 'templ-1',
        scheduledDate: todayDay + 1,
      );
      final template = _makeRemindTemplate();

      await scheduler.scheduleAlarm(occ, template);

      // Assert: alarm was scheduled via the plugin.
      expect(notificationPlugin.scheduledAlarms, isNotEmpty);
      final alarm = notificationPlugin.scheduledAlarms.first;
      expect(alarm['id'], isA<int>());
    });
  });
}
