// lib/presentation/features/home/widgets/transaction_date_group_header.dart
//
// TransactionDateGroupHeader — date group separator for the transaction list.
//
// Architecture (T-156, UI spec §5.1.1, UX flows §6.8.3):
//   - Text widget: bodyMedium bold, onSurfaceVariant, left-aligned.
//   - 8 dp vertical padding (top and bottom).
//   - Rendered as a non-pinned sliver element inside the SliverList builder.
//   - The date is formatted using the user's locale (via intl DateFormat).
//   - "Today" / "Yesterday" labels when applicable.
//
// Test cases: covered by home_screen_test.dart (2 headers for 2 days).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date group header row for the Home screen transaction list.
///
/// Displays the calendar date in a human-readable format (e.g. "Today",
/// "Yesterday", "Jan 15, 2025"). Styled per UI spec §5.1.1.
class TransactionDateGroupHeader extends StatelessWidget {
  /// Creates a [TransactionDateGroupHeader].
  ///
  /// Parameters:
  /// - [date]: The calendar date this header represents.
  const TransactionDateGroupHeader({
    super.key,
    required this.date,
  });

  /// The calendar date this header represents.
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      key: const Key('date_group_header'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        _formatDate(date),
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Formats [date] as a human-readable string.
  ///
  /// Returns "Today", "Yesterday", or a locale-formatted date (e.g.
  /// "Jan 15, 2025").
  static String formatDate(DateTime date) => _formatDate(date);

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == yesterday) return 'Yesterday';
    return DateFormat.yMMMd().format(date);
  }
}
