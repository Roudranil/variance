// lib/presentation/features/settings/transaction_entry/exact_alarm_permission_notice.dart
//
// ExactAlarmPermissionNotice — persistent info banner for T-119.
//
// Shown in TransactionEntrySettingsScreen (UX Flows §9.4) when the
// SCHEDULE_EXACT_ALARM permission is denied.
//
// When shown, the notice reads:
//   "Exact alarm permission denied — remind and confirm templates will
//    auto-post at launch"
//
// The notice is a Card with a info icon, informational text, and a Settings
// deep-link button that opens Android notification settings.
//
// Test cases (see test/presentation/features/settings/transaction_entry/
//             exact_alarm_permission_notice_test.dart):
//   1. widget hidden when exactAlarmGranted = true
//   2. widget visible when exactAlarmGranted = false
//   3. notice text contains expected degradation message

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/presentation/providers/permission_providers.dart';

/// Info banner displayed when SCHEDULE_EXACT_ALARM is denied (T-119).
///
/// Visible only when [SchedulingPermissionNotifier.exactAlarmDenied] is true.
/// Hidden (renders nothing) when the permission is granted.
class ExactAlarmPermissionNotice extends ConsumerWidget {
  /// Creates an [ExactAlarmPermissionNotice].
  const ExactAlarmPermissionNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permState = ref.watch(schedulingPermissionProvider);

    if (!permState.exactAlarmDenied) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.secondaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: cs.onSecondaryContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Exact alarm permission denied — remind and confirm '
                'templates will auto-post at launch',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
