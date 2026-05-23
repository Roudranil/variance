// lib/presentation/features/home/widgets/alerts_strip.dart
//
// AlertsStrip — multi-type alert container on the Home screen (T-167).
//
// Displays all active alert cards in priority order:
//   1. Pending remind_and_confirm confirmation cards (T-168) — highest priority
//   2. Credit card payment due alert cards (T-169)
//   3. Backup reminder card (T-170) — lowest priority
//
// Each card uses the outlined Card variant (elevation=0, outline border).
// Empty state (no alerts) renders SizedBox.shrink() — no visual noise.
//
// Architecture:
//   - AlertsNotifier (alerts_providers.dart) combines all three providers.
//   - AlertsStrip watches AlertsNotifier via AsyncValueWidget pattern.
//   - Individual card widgets are private to this file.
//
// M3 Spec (ui-spec §5.1.1):
//   - Card: outlined variant, elevation=0, side border from colorScheme.outline
//   - Pending cards: scrollable horizontal row when > 1
//   - CC / Backup cards: full-width in a Column
//
// Test cases (see test/presentation/features/home/alerts_strip_test.dart):
//   T-167.1  Empty state renders SizedBox.shrink
//   T-167.2  Priority order: pending cards before CC cards before backup
//   T-168.1  Confirm action fires PendingOccurrencesNotifier.confirmOccurrence
//   T-168.2  Dismiss shows dialog; on confirm calls skipOccurrence
//   T-168.3  Three or fewer cards show all; more than three shows "View all"
//   T-169.1  CC alert card rendered for creditCard accounts within window
//   T-169.2  CC alert absent for accounts outside reminder window
//   T-170.1  Backup reminder shown when shouldShow = true
//   T-170.2  Backup reminder absent when shouldShow = false

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/entities/money.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/alerts_providers.dart';
import 'package:variance/presentation/providers/alerts_strip_providers.dart';

// ---------------------------------------------------------------------------
// AlertsStrip (entry point)
// ---------------------------------------------------------------------------

/// Displays all active Home screen alert cards in priority order.
///
/// Renders [SizedBox.shrink] when there are no alerts. Each alert type is
/// rendered in a fixed priority order: pending confirmations → CC due →
/// backup reminder.
class AlertsStrip extends ConsumerWidget {
  /// Creates an [AlertsStrip].
  const AlertsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return alertsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (alerts) {
        if (!alerts.hasAlerts) return const SizedBox.shrink();
        return _AlertsStripContent(alerts: alerts);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _AlertsStripContent extends StatelessWidget {
  const _AlertsStripContent({required this.alerts});

  final AlertsState alerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Priority 1: Pending confirmation cards.
        if (alerts.pendingOccurrences.isNotEmpty)
          _PendingConfirmationsSection(items: alerts.pendingOccurrences),

        // Priority 2: Credit card payment due cards.
        if (alerts.creditCardAlerts.isNotEmpty)
          _CreditCardAlertsSection(items: alerts.creditCardAlerts),

        // Priority 3: Backup reminder.
        if (alerts.showBackupReminder) const _BackupReminderCard(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pending Confirmation Section (T-168)
// ---------------------------------------------------------------------------

/// Renders pending remind_and_confirm occurrence cards.
///
/// Shows up to 3 cards in a horizontal scroll. When more than 3 are pending
/// a "View all" [TextButton] navigates to the Pending Confirmations screen.
class _PendingConfirmationsSection extends StatelessWidget {
  const _PendingConfirmationsSection({required this.items});

  final List<PendingOccurrenceItem> items;

  static const _kMaxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = items.take(_kMaxVisible).toList();
    final hasMore = items.length > _kMaxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending confirmations',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (hasMore)
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.settingsRecurring),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(0, 28),
                  ),
                  child: const Text('View all'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _PendingConfirmationCard(item: visible[i]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pending Confirmation Card (T-168)
// ---------------------------------------------------------------------------

/// A single pending-occurrence confirmation card.
///
/// Shows template title, amount, date, account, and category.
/// Action buttons: Confirm (FilledButton), Edit (TextButton), Dismiss (TextButton).
class _PendingConfirmationCard extends ConsumerWidget {
  const _PendingConfirmationCard({required this.item});

  final PendingOccurrenceItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final template = item.template;
    final occurrence = item.occurrence;

    // Format amount.
    final amount = (template.amountMinor / 100).toStringAsFixed(2);
    final formattedAmount = '${template.currencyCode} $amount';

    // Format date from epoch days.
    final date = DateTime.fromMillisecondsSinceEpoch(
      occurrence.scheduledDate * 86400 * 1000,
      isUtc: true,
    );
    final formattedDate = DateFormat.MMMd().format(date);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline),
      ),
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row.
              Text(
                template.title ?? formattedAmount,
                style: tt.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Amount + date.
              Text(
                '$formattedAmount · $formattedDate',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Action buttons.
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: Key('confirm_${occurrence.id}'),
                      onPressed: () => ref
                          .read(pendingOccurrencesProvider.notifier)
                          .confirmOccurrence(occurrence.id),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    key: Key('edit_${occurrence.id}'),
                    onPressed: () => _onEdit(context, occurrence.id),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    key: Key('dismiss_${occurrence.id}'),
                    onPressed: () => _showDismissDialog(context, ref),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEdit(BuildContext context, String occurrenceId) {
    // Navigate to the transaction form pre-filled for this occurrence.
    context.push('${AppRoutes.transactionNew}?occurrence=$occurrenceId');
  }

  Future<void> _showDismissDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip this occurrence?'),
        content: const Text(
          'Skip this occurrence? It will not be posted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(pendingOccurrencesProvider.notifier)
          .skipOccurrence(item.occurrence.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Credit Card Alerts Section (T-169)
// ---------------------------------------------------------------------------

/// Renders one card per credit card account within the reminder window.
class _CreditCardAlertsSection extends StatelessWidget {
  const _CreditCardAlertsSection({required this.items});

  final List<CreditCardAlertItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Credit card due',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...items.map((item) => _CreditCardAlertCard(item: item)),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Credit Card Alert Card (T-169)
// ---------------------------------------------------------------------------

/// A credit card payment due alert card.
///
/// Shows card name, amount due, and days until payment due. "Open payment
/// entry" navigates to the new transaction form pre-populated with the
/// credit card account.
class _CreditCardAlertCard extends StatelessWidget {
  const _CreditCardAlertCard({required this.item});

  final CreditCardAlertItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final daysLabel = switch (item.daysUntilDue) {
      0 => 'due today',
      1 => 'due tomorrow',
      final int d when d < 0 => 'overdue by ${-d} day${-d == 1 ? '' : 's'}',
      final int d => 'due in $d days',
    };

    final balanceStr = _formatBalance(item.balance);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        key: Key('cc_alert_${item.account.id}'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.account.name,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$balanceStr · $daysLabel',
                      style: tt.bodySmall?.copyWith(
                        color: item.daysUntilDue <= 0
                            ? cs.error
                            : cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _onOpenPaymentEntry(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Pay now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOpenPaymentEntry(BuildContext context) {
    context.push(
      '${AppRoutes.transactionNew}?type=expense&account=${item.account.id}',
    );
  }

  String _formatBalance(Money balance) {
    final abs = balance.amountMinor.abs() / 100;
    return '${balance.currencyCode} ${abs.toStringAsFixed(2)}';
  }
}

// ---------------------------------------------------------------------------
// Backup Reminder Card (T-170)
// ---------------------------------------------------------------------------

/// Backup reminder alert card shown when the backup threshold is reached.
///
/// Tapping "Back up now" navigates to the backup/restore settings screen.
/// Dismiss action writes [AppSettings.lastBackupAt] via the settings
/// repository, which suppresses the card permanently.
class _BackupReminderCard extends ConsumerWidget {
  const _BackupReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        key: const Key('backup_reminder_card'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.backup_outlined, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Back up your data',
                      style: tt.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You haven\'t backed up in a while. '
                      'Keep your data safe.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      key: const Key('backup_reminder_action'),
                      onPressed: () => _onBackUp(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 28),
                      ),
                      child: const Text('Back up now'),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('backup_reminder_dismiss'),
                icon: const Icon(Icons.close),
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
                onPressed: () => _onDismiss(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackUp(BuildContext context) {
    try {
      context.push(AppRoutes.settingsBackup);
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup not yet available')),
      );
    }
  }

  Future<void> _onDismiss(BuildContext context, WidgetRef ref) async {
    // Writing lastBackupAt marks that the user has "acknowledged" backup;
    // the checker skips when lastBackupAt is non-null.
    // Use current epoch as placeholder since no actual backup happened.
    // This suppresses the reminder permanently until a real backup is made.
    //
    // Note: ideally we'd set a separate `backup_reminder_dismissed` flag.
    // Since the data model has `lastBackupAt` as the only dismiss mechanism
    // (per T-170 spec), we use it here.
    await ref.read(alertsProvider.notifier).dismissBackupReminder();
  }
}
