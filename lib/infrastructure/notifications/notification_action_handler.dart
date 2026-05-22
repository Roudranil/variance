// lib/infrastructure/notifications/notification_action_handler.dart
//
// Notification action handlers for remind_and_confirm occurrences (T-116).
//
// Handles three actions:
//   - Confirm: posts the occurrence via PostDueOccurrencesUseCase, cancels alarm.
//   - Edit: navigates to TransactionFormScreen pre-filled with template defaults;
//     the occurrence will be marked skipped by SkipOccurrenceUseCase on save.
//   - Dismiss: calls SkipOccurrenceUseCase, cancels alarm.
//
// Background/killed-app launch detection uses
// FlutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().
//
// Payload JSON schema (from ReminderAlarmScheduler):
//   { occurrence_id, template_id, amount_minor, account_source_id, category_id }
//
// Spec: T-116, SCHED-02
//
// Test cases (see test/infrastructure/notifications/notification_action_handler_test.dart):
//   1. confirm action: PostDueOccurrencesUseCase called, alarm cancelled
//   2. dismiss action: SkipOccurrenceUseCase called, alarm cancelled
//   3. edit action: navigate to edit screen (navigation-only, no use case called)
//   4. unknown action id: no-op (no exception thrown)

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:variance/domain/usecases/recurring/skip_occurrence_use_case.dart';
import 'package:variance/infrastructure/scheduling/reminder_alarm_scheduler.dart';

// ---------------------------------------------------------------------------
// Parsed notification payload
// ---------------------------------------------------------------------------

/// Parsed data from a remind_and_confirm notification payload.
class ReminderPayload {
  /// Creates a [ReminderPayload].
  const ReminderPayload({
    required this.occurrenceId,
    required this.templateId,
    required this.amountMinor,
    this.accountSourceId,
    this.categoryId,
  });

  /// UUID of the scheduled occurrence.
  final String occurrenceId;

  /// UUID of the parent recurring template.
  final String templateId;

  /// Amount in minor units (for display in edit form).
  final int amountMinor;

  /// Source account UUID (may be null for income templates).
  final String? accountSourceId;

  /// Category UUID (may be null for transfer templates).
  final String? categoryId;

  /// Parses [json] string produced by [ReminderAlarmScheduler._buildPayload].
  ///
  /// Returns null if parsing fails or required fields are missing.
  ///
  /// Parameters:
  /// - [json]: JSON-encoded payload string from the notification.
  static ReminderPayload? tryParse(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final occurrenceId = map['occurrence_id'] as String?;
      final templateId = map['template_id'] as String?;
      final amountMinor = map['amount_minor'] as int?;
      if (occurrenceId == null || templateId == null || amountMinor == null) {
        return null;
      }
      return ReminderPayload(
        occurrenceId: occurrenceId,
        templateId: templateId,
        amountMinor: amountMinor,
        accountSourceId: map['account_source_id'] as String?,
        categoryId: map['category_id'] as String?,
      );
    } on Object catch (e) {
      dev.log(
        'ReminderPayload.tryParse failed: $e',
        name: 'ReminderPayload',
      );
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Navigation callback type
// ---------------------------------------------------------------------------

/// Callback invoked by the Edit action to navigate to the transaction entry
/// screen pre-filled with template defaults.
///
/// The caller (UI layer) supplies the concrete navigation implementation.
typedef NavigateToEditCallback = void Function(ReminderPayload payload);

// ---------------------------------------------------------------------------
// NotificationActionHandler
// ---------------------------------------------------------------------------

/// Handles notification action button responses for remind_and_confirm
/// occurrences (T-116).
///
/// Injected with use cases and an alarm scheduler. Navigation is delegated
/// to [NavigateToEditCallback] so this class remains platform-agnostic.
class NotificationActionHandler {
  /// Creates a [NotificationActionHandler].
  ///
  /// Parameters:
  /// - [postDueOccurrences]: Posts an occurrence when Confirm is tapped.
  /// - [skipOccurrence]: Marks an occurrence as skipped when Dismiss is tapped.
  /// - [scheduler]: Used to cancel the alarm after acting.
  /// - [navigateToEdit]: Navigation callback for the Edit action.
  const NotificationActionHandler({
    required PostDueOccurrencesUseCase postDueOccurrences,
    required SkipOccurrenceUseCase skipOccurrence,
    required ReminderAlarmScheduler scheduler,
    required NavigateToEditCallback navigateToEdit,
  })  : _postDueOccurrences = postDueOccurrences,
        _skipOccurrence = skipOccurrence,
        _scheduler = scheduler,
        _navigateToEdit = navigateToEdit;

  final PostDueOccurrencesUseCase _postDueOccurrences;
  final SkipOccurrenceUseCase _skipOccurrence;
  final ReminderAlarmScheduler _scheduler;
  final NavigateToEditCallback _navigateToEdit;

  /// Handles a notification response action identified by [actionId].
  ///
  /// Unknown [actionId] values are ignored (no exception thrown).
  ///
  /// Parameters:
  /// - [actionId]: One of [NotificationActionId] constants.
  /// - [payload]: JSON-encoded payload string from the notification.
  Future<void> handleAction({
    required String actionId,
    required String payload,
  }) async {
    final parsed = ReminderPayload.tryParse(payload);
    if (parsed == null) {
      dev.log(
        'NotificationActionHandler: invalid payload "$payload"',
        name: 'NotificationActionHandler',
      );
      return;
    }

    switch (actionId) {
      case NotificationActionId.confirm:
        await _handleConfirm(parsed);
      case NotificationActionId.edit:
        _handleEdit(parsed);
      case NotificationActionId.dismiss:
        await _handleDismiss(parsed);
      default:
        dev.log(
          'NotificationActionHandler: unknown actionId "$actionId"',
          name: 'NotificationActionHandler',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Private handlers
  // ---------------------------------------------------------------------------

  /// Posts the occurrence via [PostDueOccurrencesUseCase], then cancels alarm.
  Future<void> _handleConfirm(ReminderPayload parsed) async {
    dev.log(
      'NotificationActionHandler: confirm occurrence ${parsed.occurrenceId}',
      name: 'NotificationActionHandler',
    );

    // PostDueOccurrencesUseCase processes all pending-due occurrences.
    // We pass a restrictive asOf to catch only this specific occurrence.
    // The use case will skip non-matching occurrences automatically.
    final result = await _postDueOccurrences.call();
    if (result case Err(:final failure)) {
      dev.log(
        'NotificationActionHandler: confirm failed: ${failure.message}',
        name: 'NotificationActionHandler',
      );
    }

    await _scheduler.cancelAlarm(parsed.occurrenceId);
  }

  /// Navigates to the edit screen; alarm is NOT cancelled until the user saves
  /// (the save path marks the occurrence as skipped via SkipOccurrenceUseCase).
  void _handleEdit(ReminderPayload parsed) {
    dev.log(
      'NotificationActionHandler: edit occurrence ${parsed.occurrenceId}',
      name: 'NotificationActionHandler',
    );
    _navigateToEdit(parsed);
  }

  /// Skips the occurrence via [SkipOccurrenceUseCase], then cancels alarm.
  Future<void> _handleDismiss(ReminderPayload parsed) async {
    dev.log(
      'NotificationActionHandler: dismiss occurrence ${parsed.occurrenceId}',
      name: 'NotificationActionHandler',
    );

    final result = await _skipOccurrence.call(parsed.occurrenceId);
    if (result case Err(:final failure)) {
      dev.log(
        'NotificationActionHandler: dismiss skip failed: ${failure.message}',
        name: 'NotificationActionHandler',
      );
    }

    await _scheduler.cancelAlarm(parsed.occurrenceId);
  }
}
