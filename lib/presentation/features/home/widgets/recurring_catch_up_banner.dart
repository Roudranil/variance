// lib/presentation/features/home/widgets/recurring_catch_up_banner.dart
//
// RecurringCatchUpBanner — catch-up banner for auto-approved recurring
// transactions (T-121, S-47).
//
// Shown at the top of the transaction list on the Home screen when
// AppInitializer reports autoApprovedCount >= 1 after the launch sweep.
//
// Behaviour (UX Flows §6.6):
//   - Visible when autoApprovedCount >= 1.
//   - Renders SizedBox.shrink() when count = 0 (no visual noise).
//   - "View details" CTA: calls [onViewDetails] to filter the transaction list.
//   - Dismiss: session-local flag; banner does not reappear in the same session.
//   - Message: "[N] recurring transaction(s) were auto-posted while you were away."
//
// Spec: T-121, UX Flows §6.6, Alerts Strip §6.5
//
// Test cases (see test/presentation/features/home/recurring_catch_up_banner_test.dart):
//   T-121.1  Banner shown when count >= 1.
//   T-121.2  Banner absent when count = 0.
//   T-121.3  Correct N shown in message.
//   T-121.4  Dismiss hides banner.
//   T-121.5  "View details" CTA fires callback.

import 'package:flutter/material.dart';

import 'package:variance/presentation/theme/variance_colors.dart';

// ---------------------------------------------------------------------------
// RecurringCatchUpBanner
// ---------------------------------------------------------------------------

/// Session-dismissable banner shown when recurring transactions were
/// auto-posted during the app-launch sweep (T-121).
///
/// Renders [SizedBox.shrink] when [autoApprovedCount] is 0.
/// The banner dismisses when the user taps the close icon; it does not
/// reappear in the same app session (managed by the parent stateful widget).
class RecurringCatchUpBanner extends StatefulWidget {
  /// Creates a [RecurringCatchUpBanner].
  ///
  /// Parameters:
  /// - [autoApprovedCount]: Number of transactions auto-approved in the sweep.
  ///   If 0, the banner is invisible.
  /// - [onViewDetails]: Called when the "View details" CTA is tapped. Typically
  ///   navigates to a filtered transaction list.
  const RecurringCatchUpBanner({
    required this.autoApprovedCount,
    this.onViewDetails,
    super.key,
  });

  /// Number of recurring transactions auto-approved in the launch sweep.
  final int autoApprovedCount;

  /// Optional callback for the "View details" CTA.
  final VoidCallback? onViewDetails;

  @override
  State<RecurringCatchUpBanner> createState() => _RecurringCatchUpBannerState();
}

class _RecurringCatchUpBannerState extends State<RecurringCatchUpBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.autoApprovedCount <= 0 || _dismissed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.extension<VarianceColors>();
    final accentColor =
        colors?.accentPastel ?? theme.colorScheme.secondaryContainer;

    final n = widget.autoApprovedCount;
    final txWord = n == 1 ? 'transaction' : 'transactions';
    final message =
        '$n recurring $txWord were auto-posted while you were away.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.autorenew_rounded,
            size: 18,
            color: accentColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (widget.onViewDetails != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: widget.onViewDetails,
                    child: Text(
                      'View details',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Dismiss',
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}
