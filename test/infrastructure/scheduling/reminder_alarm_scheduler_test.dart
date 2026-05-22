// test/infrastructure/scheduling/reminder_alarm_scheduler_test.dart
//
// Unit tests for ReminderAlarmScheduler (T-115).
//
// Tests verify the scheduler delegates correctly to FlutterLocalNotificationsPlugin.
//
// Test cases:
//   1. scheduleAlarm calls plugin.zonedSchedule with correct notificationId
//   2. scheduleAlarm encodes occurrence_id, template_id, amount, account, category in payload
//   3. cancelAlarm calls plugin.cancel with the correct notification ID
//   4. scheduleAlarm action buttons include Confirm, Edit, Dismiss
//   5. notificationIdFor is deterministic (same occurrence → same id)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/infrastructure/scheduling/reminder_alarm_scheduler.dart';

// ---------------------------------------------------------------------------
// Fake FlutterLocalNotificationsPlugin interface
// ---------------------------------------------------------------------------

/// Records calls made to the notification plugin for assertion.
class _FakeNotificationPlugin implements NotificationPluginAdapter {
  final List<_ZonedScheduleCall> scheduleCalls = [];
  final List<int> cancelCalls = [];

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required List<NotificationAction> actions,
  }) async {
    scheduleCalls.add(
      _ZonedScheduleCall(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
        actions: actions,
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls.add(id);
  }
}

class _ZonedScheduleCall {
  const _ZonedScheduleCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
    required this.actions,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String payload;
  final List<NotificationAction> actions;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ScheduledOccurrence _makeOccurrence({
  String id = 'occ-1',
  String templateId = 'tmpl-1',
  int scheduledDate = 20000, // epoch days
}) =>
    ScheduledOccurrence(
      id: id,
      templateId: templateId,
      scheduledDate: scheduledDate,
      createdAt: 0,
      updatedAt: 0,
    );

RecurringTemplate _makeTemplate({
  String id = 'tmpl-1',
  int amountMinor = 5000,
  String currencyCode = 'INR',
  String? title = 'Electricity Bill',
  String? accountSourceId = 'acc-1',
  String? categoryId = 'cat-1',
}) =>
    RecurringTemplate(
      id: id,
      transactionType: 'expense',
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      title: title,
      accountSourceId: accountSourceId,
      categoryId: categoryId,
      recurrenceN: 1,
      recurrenceUnit: RecurrenceUnit.month,
      startDate: 19000,
      createdAt: 0,
      updatedAt: 0,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeNotificationPlugin plugin;
  late ReminderAlarmScheduler scheduler;

  setUp(() {
    plugin = _FakeNotificationPlugin();
    scheduler = ReminderAlarmScheduler(plugin);
  });

  group('ReminderAlarmScheduler', () {
    test('1. scheduleAlarm calls plugin.zonedSchedule with correct id',
        () async {
      final occ = _makeOccurrence();
      final tmpl = _makeTemplate();

      await scheduler.scheduleAlarm(occ, tmpl);

      expect(plugin.scheduleCalls, hasLength(1));
      final call = plugin.scheduleCalls.first;
      // Notification id is derived from occurrence id.
      expect(call.id, equals(ReminderAlarmScheduler.notificationIdFor(occ.id)));
    });

    test('2. scheduleAlarm encodes occurrence/template id and amount in payload',
        () async {
      final occ = _makeOccurrence(id: 'occ-42', templateId: 'tmpl-99');
      // Template id matches the occurrence templateId.
      final tmpl = _makeTemplate(id: 'tmpl-99', amountMinor: 15000, title: 'Rent');

      await scheduler.scheduleAlarm(occ, tmpl);

      final payload = plugin.scheduleCalls.first.payload;
      expect(payload, contains('occ-42'));
      expect(payload, contains('tmpl-99'));
      expect(payload, contains('15000'));
    });

    test('3. cancelAlarm calls plugin.cancel with correct id', () async {
      const occurrenceId = 'occ-delete-me';
      await scheduler.cancelAlarm(occurrenceId);

      expect(plugin.cancelCalls, hasLength(1));
      expect(
        plugin.cancelCalls.first,
        equals(ReminderAlarmScheduler.notificationIdFor(occurrenceId)),
      );
    });

    test('4. scheduleAlarm includes Confirm, Edit, Dismiss action buttons',
        () async {
      final occ = _makeOccurrence();
      final tmpl = _makeTemplate();

      await scheduler.scheduleAlarm(occ, tmpl);

      final actions = plugin.scheduleCalls.first.actions;
      final actionIds = actions.map((a) => a.id).toList();
      expect(actionIds, contains(NotificationActionId.confirm));
      expect(actionIds, contains(NotificationActionId.edit));
      expect(actionIds, contains(NotificationActionId.dismiss));
    });

    test('5. notificationIdFor is deterministic for the same occurrence id',
        () {
      const id = 'occ-stable';
      expect(
        ReminderAlarmScheduler.notificationIdFor(id),
        equals(ReminderAlarmScheduler.notificationIdFor(id)),
      );
    });
  });
}
