// test/infrastructure/security/permission_gate_service_test.dart
//
// Unit tests for PermissionGateService (T-118).
//
// Test cases:
//   1. granted path: both permissions return true → allGranted = true
//   2. SCHEDULE_EXACT_ALARM denied → exactAlarmGranted = false
//   3. POST_NOTIFICATIONS denied → postNotificationsGranted = false
//   4. both denied → allGranted = false
//   5. already-granted permissions are not re-requested (request not called)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/infrastructure/security/permission_gate_service.dart';

// ---------------------------------------------------------------------------
// Fake PermissionChecker
// ---------------------------------------------------------------------------

class _FakePermissionChecker implements PermissionChecker {
  _FakePermissionChecker({
    required bool exactAlarmGranted,
    required bool postNotificationsGranted,
    bool exactAlarmAlreadyGranted = false,
    bool postNotificationsAlreadyGranted = false,
  })  : _exactAlarmGranted = exactAlarmGranted,
        _postNotificationsGranted = postNotificationsGranted,
        _exactAlarmAlreadyGranted = exactAlarmAlreadyGranted,
        _postNotificationsAlreadyGranted = postNotificationsAlreadyGranted;

  final bool _exactAlarmGranted;
  final bool _postNotificationsGranted;
  final bool _exactAlarmAlreadyGranted;
  final bool _postNotificationsAlreadyGranted;

  int exactAlarmRequestCount = 0;
  int postNotificationsRequestCount = 0;

  @override
  Future<bool> isExactAlarmGranted() async => _exactAlarmAlreadyGranted;

  @override
  Future<bool> requestExactAlarm() async {
    exactAlarmRequestCount++;
    return _exactAlarmGranted;
  }

  @override
  Future<bool> isPostNotificationsGranted() async =>
      _postNotificationsAlreadyGranted;

  @override
  Future<bool> requestPostNotifications() async {
    postNotificationsRequestCount++;
    return _postNotificationsGranted;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PermissionGateService', () {
    test('1. granted path: both permissions return allGranted = true',
        () async {
      final checker = _FakePermissionChecker(
        exactAlarmGranted: true,
        postNotificationsGranted: true,
      );
      final service = PermissionGateService(checker);

      final result = await service.requestSchedulingPermissions();

      expect(result.exactAlarmGranted, isTrue);
      expect(result.postNotificationsGranted, isTrue);
      expect(result.allGranted, isTrue);
    });

    test('2. SCHEDULE_EXACT_ALARM denied → exactAlarmGranted = false',
        () async {
      final checker = _FakePermissionChecker(
        exactAlarmGranted: false,
        postNotificationsGranted: true,
      );
      final service = PermissionGateService(checker);

      final result = await service.requestSchedulingPermissions();

      expect(result.exactAlarmGranted, isFalse);
      expect(result.postNotificationsGranted, isTrue);
      expect(result.allGranted, isFalse);
    });

    test('3. POST_NOTIFICATIONS denied → postNotificationsGranted = false',
        () async {
      final checker = _FakePermissionChecker(
        exactAlarmGranted: true,
        postNotificationsGranted: false,
      );
      final service = PermissionGateService(checker);

      final result = await service.requestSchedulingPermissions();

      expect(result.exactAlarmGranted, isTrue);
      expect(result.postNotificationsGranted, isFalse);
      expect(result.allGranted, isFalse);
    });

    test('4. both denied → allGranted = false', () async {
      final checker = _FakePermissionChecker(
        exactAlarmGranted: false,
        postNotificationsGranted: false,
      );
      final service = PermissionGateService(checker);

      final result = await service.requestSchedulingPermissions();

      expect(result.allGranted, isFalse);
    });

    test('5. already-granted permissions are not re-requested', () async {
      final checker = _FakePermissionChecker(
        exactAlarmGranted: true,
        postNotificationsGranted: true,
        exactAlarmAlreadyGranted: true,
        postNotificationsAlreadyGranted: true,
      );
      final service = PermissionGateService(checker);

      await service.requestSchedulingPermissions();

      // Request should not have been called — permission was already granted.
      expect(checker.exactAlarmRequestCount, isZero);
      expect(checker.postNotificationsRequestCount, isZero);
    });
  });
}
