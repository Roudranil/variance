// lib/presentation/providers/permission_providers.dart
//
// Riverpod providers for scheduling permission state (T-118, T-119).
//
// SchedulingPermissionState holds the cached grant status for:
//   - SCHEDULE_EXACT_ALARM (API 31+)
//   - POST_NOTIFICATIONS (API 33+)
//
// The state is refreshed at app start and when the user creates a
// remind_and_confirm template.
//
// Degradation rules (T-119):
//   - SCHEDULE_EXACT_ALARM denied: ReminderAlarmScheduler is NOT called;
//     template remains remind_and_confirm in DB but behaves as auto_post.
//   - POST_NOTIFICATIONS denied: notifications not delivered; occurrence still
//     auto-posts on launch after 24 hours.
//
// Test cases (see test/infrastructure/security/permission_gate_service_test.dart).

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

// ---------------------------------------------------------------------------
// SchedulingPermissionState
// ---------------------------------------------------------------------------

/// Cached grant status for scheduling-related Android permissions.
class SchedulingPermissionState {
  /// Creates a [SchedulingPermissionState].
  ///
  /// Parameters:
  /// - [exactAlarmGranted]: SCHEDULE_EXACT_ALARM grant status.
  /// - [postNotificationsGranted]: POST_NOTIFICATIONS grant status.
  const SchedulingPermissionState({
    required this.exactAlarmGranted,
    required this.postNotificationsGranted,
  });

  /// True when SCHEDULE_EXACT_ALARM is granted (or irrelevant for API < 31).
  final bool exactAlarmGranted;

  /// True when POST_NOTIFICATIONS is granted (or irrelevant for API < 33).
  final bool postNotificationsGranted;

  /// True when the exact alarm permission is denied.
  ///
  /// Used by T-119 to decide whether to show the degradation notice and
  /// whether to call [ReminderAlarmScheduler].
  bool get exactAlarmDenied => !exactAlarmGranted;

  /// True when the notification permission is denied.
  bool get postNotificationsDenied => !postNotificationsGranted;

  /// Returns a copy with updated values.
  SchedulingPermissionState copyWith({
    bool? exactAlarmGranted,
    bool? postNotificationsGranted,
  }) {
    return SchedulingPermissionState(
      exactAlarmGranted: exactAlarmGranted ?? this.exactAlarmGranted,
      postNotificationsGranted:
          postNotificationsGranted ?? this.postNotificationsGranted,
    );
  }
}

// ---------------------------------------------------------------------------
// SchedulingPermissionNotifier
// ---------------------------------------------------------------------------

/// Holds and exposes the current scheduling permission grant status.
///
/// Defaults to both permissions as granted (optimistic) until checked.
/// Call [refresh] after requesting permissions to update the state.
@Riverpod(keepAlive: true)
class SchedulingPermissionNotifier extends _$SchedulingPermissionNotifier {
  @override
  SchedulingPermissionState build() {
    // Default: optimistic (both granted). The real check is deferred to
    // the first remind_and_confirm template creation.
    return const SchedulingPermissionState(
      exactAlarmGranted: true,
      postNotificationsGranted: true,
    );
  }

  /// Updates the state with [result] from a permission request.
  ///
  /// Parameters:
  /// - [exactAlarmGranted]: Whether SCHEDULE_EXACT_ALARM is now granted.
  /// - [postNotificationsGranted]: Whether POST_NOTIFICATIONS is now granted.
  void update({
    required bool exactAlarmGranted,
    required bool postNotificationsGranted,
  }) {
    state = SchedulingPermissionState(
      exactAlarmGranted: exactAlarmGranted,
      postNotificationsGranted: postNotificationsGranted,
    );
  }
}
