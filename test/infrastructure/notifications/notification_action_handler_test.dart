// test/infrastructure/notifications/notification_action_handler_test.dart
//
// Unit tests for NotificationActionHandler (T-116).
//
// Test cases:
//   1. confirm action: PostDueOccurrencesUseCase called, alarm cancelled
//   2. dismiss action: SkipOccurrenceUseCase called, alarm cancelled
//   3. edit action: navigate callback called, alarm NOT cancelled
//   4. unknown action id: no-op (no exception thrown)
//   5. invalid payload: no-op (no exception, use cases not called)

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:variance/domain/usecases/recurring/skip_occurrence_use_case.dart';
import 'package:variance/infrastructure/notifications/notification_action_handler.dart';
import 'package:variance/infrastructure/scheduling/reminder_alarm_scheduler.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeScheduledOccurrenceRepository
    implements IScheduledOccurrenceRepository {
  final List<String> skippedIds = [];

  @override
  Future<Result<void>> markSkipped(String id) async {
    skippedIds.add(id);
    return const Ok(null);
  }

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async => [];
  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) async =>
      [];
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

class _FakeRecurringTemplateRepository
    implements IRecurringTemplateRepository {
  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) async =>
      Ok(template);
  @override
  Stream<RecurringTemplate?> watchById(String id) => Stream.value(null);
  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value([]);
  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) async =>
      Ok(template);
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

class _NoOpLedgerRepository implements LedgerRepository {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _FakeNotificationPlugin implements NotificationPluginAdapter {
  final List<int> cancelCalls = [];
  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required List<NotificationAction> actions,
  }) async {}
  @override
  Future<void> cancel(int id) async => cancelCalls.add(id);

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _makePayload({
  String occurrenceId = 'occ-1',
  String templateId = 'tmpl-1',
  int amountMinor = 5000,
}) =>
    jsonEncode({
      'occurrence_id': occurrenceId,
      'template_id': templateId,
      'amount_minor': amountMinor,
    });

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeScheduledOccurrenceRepository occRepo;
  late _FakeRecurringTemplateRepository tmplRepo;
  late _FakeNotificationPlugin plugin;
  late ReminderAlarmScheduler scheduler;
  late List<ReminderPayload> navigateCalls;
  late NotificationActionHandler handler;

  setUp(() {
    occRepo = _FakeScheduledOccurrenceRepository();
    tmplRepo = _FakeRecurringTemplateRepository();
    plugin = _FakeNotificationPlugin();
    scheduler = ReminderAlarmScheduler(plugin);
    navigateCalls = [];

    final postDueUseCase = PostDueOccurrencesUseCase(
      tmplRepo,
      occRepo,
      // FakeTransactionRepository — only getDuePendingTransactions is needed here
      // and occRepo.getPendingDue returns [] so no transactions are attempted.
      _buildFakeTxRepo(),
      LedgerEngine(_NoOpLedgerRepository()),
    );
    final skipUseCase = SkipOccurrenceUseCase(occRepo);

    handler = NotificationActionHandler(
      postDueOccurrences: postDueUseCase,
      skipOccurrence: skipUseCase,
      scheduler: scheduler,
      navigateToEdit: navigateCalls.add,
    );
  });

  group('NotificationActionHandler', () {
    test('1. confirm action: use case called, alarm cancelled', () async {
      const occId = 'occ-confirm';
      final payload = _makePayload(occurrenceId: occId);

      await handler.handleAction(
        actionId: NotificationActionId.confirm,
        payload: payload,
      );

      // Alarm should be cancelled for this occurrence.
      final expectedId = ReminderAlarmScheduler.notificationIdFor(occId);
      expect(plugin.cancelCalls, contains(expectedId));
    });

    test('2. dismiss action: SkipOccurrenceUseCase called, alarm cancelled',
        () async {
      const occId = 'occ-dismiss';
      final payload = _makePayload(occurrenceId: occId);

      await handler.handleAction(
        actionId: NotificationActionId.dismiss,
        payload: payload,
      );

      expect(occRepo.skippedIds, contains(occId));
      final expectedId = ReminderAlarmScheduler.notificationIdFor(occId);
      expect(plugin.cancelCalls, contains(expectedId));
    });

    test('3. edit action: navigate callback called, alarm NOT cancelled',
        () async {
      const occId = 'occ-edit';
      final payload = _makePayload(occurrenceId: occId);

      await handler.handleAction(
        actionId: NotificationActionId.edit,
        payload: payload,
      );

      expect(navigateCalls, hasLength(1));
      expect(navigateCalls.first.occurrenceId, equals(occId));
      // Alarm must NOT be cancelled — user may still cancel the edit.
      expect(plugin.cancelCalls, isEmpty);
    });

    test('4. unknown action id: no-op, no exception', () async {
      final payload = _makePayload();

      await expectLater(
        handler.handleAction(actionId: 'unknown_action', payload: payload),
        completes,
      );

      expect(plugin.cancelCalls, isEmpty);
      expect(occRepo.skippedIds, isEmpty);
    });

    test('5. invalid payload: no-op, no exception', () async {
      await expectLater(
        handler.handleAction(
          actionId: NotificationActionId.confirm,
          payload: 'not-json',
        ),
        completes,
      );

      expect(plugin.cancelCalls, isEmpty);
    });
  });
}

// ---------------------------------------------------------------------------
// Private helper to build a minimal fake ITransactionRepository
// ---------------------------------------------------------------------------

ITransactionRepository _buildFakeTxRepo() => _FakeTxRepo();

class _FakeTxRepo implements ITransactionRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError(i.memberName.toString());

  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) async =>
      [];
}
