// lib/infrastructure/security/permission_gate_service.dart
//
// PermissionGateService — runtime permission request flow for scheduling
// and notification permissions (T-118, SCHED-02).
//
// Android permission model:
//   - SCHEDULE_EXACT_ALARM (API 31+ / Android 12+): requires runtime user
//     grant. If denied, remind_and_confirm templates fall back to app-launch
//     posting.
//   - POST_NOTIFICATIONS (API 33+ / Android 13+): requires runtime user
//     grant. If denied, notifications are not delivered but occurrences still
//     auto-post on launch after 24 hours.
//
// This service uses a [PermissionChecker] abstraction so the grant-status
// logic can be tested without platform channels.
//
// Spec: T-118, T-119, SCHED-02, SDS §2.6.1
//
// Test cases (see test/infrastructure/security/permission_gate_service_test.dart):
//   1. granted path: requestSchedulingPermissions returns SchedulingPermissions.allGranted
//   2. SCHEDULE_EXACT_ALARM denied path: exactAlarmGranted = false
//   3. POST_NOTIFICATIONS denied path: postNotificationsGranted = false

import 'dart:developer' as dev;
import 'dart:io';

// ---------------------------------------------------------------------------
// Value types
// ---------------------------------------------------------------------------

/// Result of a scheduling permission request sequence.
class SchedulingPermissionResult {
  /// Creates a [SchedulingPermissionResult].
  const SchedulingPermissionResult({
    required this.exactAlarmGranted,
    required this.postNotificationsGranted,
  });

  /// True when SCHEDULE_EXACT_ALARM is granted (or not required for the
  /// current API level).
  final bool exactAlarmGranted;

  /// True when POST_NOTIFICATIONS is granted (or not required for the
  /// current API level).
  final bool postNotificationsGranted;

  /// Convenience: true when both permissions are granted.
  bool get allGranted => exactAlarmGranted && postNotificationsGranted;
}

// ---------------------------------------------------------------------------
// PermissionChecker abstraction
// ---------------------------------------------------------------------------

/// Thin platform abstraction for checking and requesting runtime permissions.
///
/// The real implementation delegates to `permission_handler` or
/// [MethodChannel]. Tests substitute a fake.
abstract interface class PermissionChecker {
  /// Checks whether the SCHEDULE_EXACT_ALARM permission is currently granted.
  ///
  /// Always returns true on API levels below 31.
  Future<bool> isExactAlarmGranted();

  /// Requests the SCHEDULE_EXACT_ALARM permission.
  ///
  /// Returns true if the user grants the permission. On API < 31, returns true
  /// immediately without showing a dialog.
  Future<bool> requestExactAlarm();

  /// Checks whether the POST_NOTIFICATIONS permission is currently granted.
  ///
  /// Always returns true on API levels below 33.
  Future<bool> isPostNotificationsGranted();

  /// Requests the POST_NOTIFICATIONS permission.
  ///
  /// Returns true if the user grants the permission. On API < 33, returns true
  /// immediately without showing a dialog.
  Future<bool> requestPostNotifications();
}

// ---------------------------------------------------------------------------
// Platform channel implementation
// ---------------------------------------------------------------------------

/// Android platform-channel implementation of [PermissionChecker].
///
/// Uses [flutter_local_notifications] plugin to check and request
/// notification permission. For SCHEDULE_EXACT_ALARM, delegates to the
/// same plugin's Android-specific permission API.
///
/// On non-Android platforms (e.g. iOS), both permissions are treated as
/// automatically granted (notifications use APNS with its own flow; exact
/// alarms are not applicable).
class AndroidPermissionChecker implements PermissionChecker {
  /// Creates an [AndroidPermissionChecker] backed by [_plugin].
  ///
  /// Parameters:
  /// - [_plugin]: Initialised [FlutterLocalNotificationsPlugin]-compatible
  ///   plugin instance (typed as dynamic to avoid hard build-time dependency).
  const AndroidPermissionChecker(this._plugin);

  final dynamic _plugin;

  @override
  Future<bool> isExactAlarmGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      // ignore: avoid_dynamic_calls
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<dynamic>();
      if (androidPlugin == null) return true;
      // ignore: avoid_dynamic_calls
      final dynamic result = await androidPlugin.canScheduleExactAlarms();
      return (result as bool?) ?? true;
    } on Object catch (e) {
      dev.log(
        'isExactAlarmGranted check failed: $e',
        name: 'AndroidPermissionChecker',
      );
      return false;
    }
  }

  @override
  Future<bool> requestExactAlarm() async {
    if (!Platform.isAndroid) return true;
    try {
      // ignore: avoid_dynamic_calls
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<dynamic>();
      if (androidPlugin == null) return true;
      // ignore: avoid_dynamic_calls
      final dynamic result = await androidPlugin.requestExactAlarmsPermission();
      return (result as bool?) ?? false;
    } on Object catch (e) {
      dev.log(
        'requestExactAlarm failed: $e',
        name: 'AndroidPermissionChecker',
      );
      return false;
    }
  }

  @override
  Future<bool> isPostNotificationsGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      // ignore: avoid_dynamic_calls
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<dynamic>();
      if (androidPlugin == null) return true;
      // ignore: avoid_dynamic_calls
      final dynamic result = await androidPlugin.areNotificationsEnabled();
      return (result as bool?) ?? true;
    } on Object catch (e) {
      dev.log(
        'isPostNotificationsGranted check failed: $e',
        name: 'AndroidPermissionChecker',
      );
      return false;
    }
  }

  @override
  Future<bool> requestPostNotifications() async {
    if (!Platform.isAndroid) return true;
    try {
      // ignore: avoid_dynamic_calls
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<dynamic>();
      if (androidPlugin == null) return true;
      // ignore: avoid_dynamic_calls
      final dynamic result =
          await androidPlugin.requestNotificationsPermission();
      return (result as bool?) ?? false;
    } on Object catch (e) {
      dev.log(
        'requestPostNotifications failed: $e',
        name: 'AndroidPermissionChecker',
      );
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// PermissionGateService
// ---------------------------------------------------------------------------

/// Requests and checks scheduling-related runtime permissions (T-118).
///
/// Call [requestSchedulingPermissions] when:
///   (a) the user creates a `remind_and_confirm` template, or
///   (b) the user switches posting_behaviour to `remind_and_confirm`.
///
/// The result is used by T-119 to decide whether to schedule exact alarms or
/// fall back to app-launch posting.
class PermissionGateService {
  /// Creates a [PermissionGateService].
  ///
  /// Parameters:
  /// - [checker]: Platform abstraction for runtime permission requests.
  const PermissionGateService(this._checker);

  final PermissionChecker _checker;

  /// Requests SCHEDULE_EXACT_ALARM and POST_NOTIFICATIONS in sequence.
  ///
  /// Returns a [SchedulingPermissionResult] describing which permissions were
  /// granted. Never throws — failures are logged and mapped to denied.
  ///
  /// Both requests are made only if not already granted. The sequence is:
  ///   1. SCHEDULE_EXACT_ALARM (API 31+)
  ///   2. POST_NOTIFICATIONS (API 33+)
  Future<SchedulingPermissionResult> requestSchedulingPermissions() async {
    final exactAlarmGranted = await _requestIfNeeded(
      check: _checker.isExactAlarmGranted,
      request: _checker.requestExactAlarm,
      name: 'SCHEDULE_EXACT_ALARM',
    );

    final postNotificationsGranted = await _requestIfNeeded(
      check: _checker.isPostNotificationsGranted,
      request: _checker.requestPostNotifications,
      name: 'POST_NOTIFICATIONS',
    );

    dev.log(
      'PermissionGateService: exactAlarm=$exactAlarmGranted '
      'postNotifications=$postNotificationsGranted',
      name: 'PermissionGateService',
    );

    return SchedulingPermissionResult(
      exactAlarmGranted: exactAlarmGranted,
      postNotificationsGranted: postNotificationsGranted,
    );
  }

  /// Checks current SCHEDULE_EXACT_ALARM status without requesting.
  ///
  /// Used by T-119 degradation logic on app start.
  Future<bool> isExactAlarmGranted() => _checker.isExactAlarmGranted();

  /// Checks current POST_NOTIFICATIONS status without requesting.
  ///
  /// Used by T-119 degradation logic on app start.
  Future<bool> isPostNotificationsGranted() =>
      _checker.isPostNotificationsGranted();

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  /// Checks and optionally requests a permission.
  ///
  /// Returns true immediately if already granted. Returns the request result
  /// otherwise.
  Future<bool> _requestIfNeeded({
    required Future<bool> Function() check,
    required Future<bool> Function() request,
    required String name,
  }) async {
    try {
      if (await check()) return true;
      final granted = await request();
      dev.log(
        'PermissionGateService: $name result: $granted',
        name: 'PermissionGateService',
      );
      return granted;
    } on Object catch (e) {
      dev.log(
        'PermissionGateService: $name request failed: $e',
        name: 'PermissionGateService',
      );
      return false;
    }
  }
}
