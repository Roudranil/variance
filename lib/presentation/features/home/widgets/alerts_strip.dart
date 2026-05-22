// lib/presentation/features/home/widgets/alerts_strip.dart
//
// AlertsStrip — horizontal strip of pending-confirmation cards on HomeScreen
// (T-117, SCHED-02, SCHED-03).
//
// Responsibilities:
//   - Watches PendingOccurrencesNotifier for all remind_and_confirm occurrences
//     with status = pending.
//   - Renders a scrollable row of cards, one per pending occurrence.
//   - Each card shows: template title, amount, date.
//   - Confirm button: calls PendingOccurrencesNotifier.confirmOccurrence.
//   - Dismiss button: shows "Skip this occurrence?" dialog; on confirm calls
//     PendingOccurrencesNotifier.skipOccurrence.
//   - Edit button: navigates to TransactionFormScreen (T-116 edit path).
//   - Empty state (no pending): renders SizedBox.shrink() — no visual noise.
//
// Test cases (see test/presentation/features/home/alerts_strip_test.dart):
//   1. empty state shows nothing
//   2. single pending card rendered with title
//   3. multiple pending cards
//   4. Confirm removes card
//   5. Dismiss shows dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:variance/presentation/providers/alerts_strip_providers.dart';

// ---------------------------------------------------------------------------
// AlertsStrip
// ---------------------------------------------------------------------------

/// Horizontal strip of pending remind_and_confirm occurrence cards.
///
/// Shows one card per pending occurrence. Empty state renders nothing.
class AlertsStrip extends ConsumerWidget {
  /// Creates an [AlertsStrip].
  const AlertsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(pendingOccurrencesProvider);

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _AlertsStripContent(items: items);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _AlertsStripContent extends StatelessWidget {
  const _AlertsStripContent({required this.items});

  final List<PendingOccurrenceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Pending confirmations',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _PendingConfirmationCard(item: items[i]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PendingConfirmationCard
// ---------------------------------------------------------------------------

/// A single pending-occurrence confirmation card.
///
/// Shows the template title, amount, and date. Action buttons: Confirm /
/// Dismiss.
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
      elevation: 1,
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
                  const SizedBox(width: 8),
                  TextButton(
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
