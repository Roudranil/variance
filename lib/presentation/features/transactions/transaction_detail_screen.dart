// lib/presentation/features/transactions/transaction_detail_screen.dart
//
// TransactionDetailScreen — displays all fields of a single transaction (T-54).
//
// Content (PRD §5.2.1.6):
//   - Header: type badge, amount + currency, exchange rate if cross-currency
//   - Date and time
//   - Title (if provided)
//   - Description (only here, not in list)
//   - Account info (source/destination names)
//   - Category info (icon + name, subcategory)
//   - Fee breakdown (compound transfer with fee only)
//   - Photo carousel (PageView, max 2 photos; full-screen tap; per-photo delete)
//   - Overflow menu: Edit → TransactionFormScreen; Delete → confirmation dialog
//   - Pending transaction: all fields unlocked for in-place edit
//
// Currency symbol disambiguation (CURR-02, T-92):
//   - _AmountRow reads currencySymbolLabelsProvider to resolve the currency
//     display label, appending ISO code when there is a symbol collision.
//
// Widget tests:
//   1. compound transfer shows fee breakdown section
//   2. empty photo carousel shows placeholder
//   3. pending transaction shows "Pending" badge
//   4. collision scenario: ISO-suffixed label rendered in amount header (T-92)
//   5. no-collision scenario: bare symbol rendered in amount header (T-92)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/transaction_providers.dart';

/// Detail screen for a single transaction.
///
/// Watches the transaction reactively; re-renders when it changes (e.g. after
/// a correction).
class TransactionDetailScreen extends ConsumerWidget {
  /// Creates a [TransactionDetailScreen].
  const TransactionDetailScreen({super.key, required this.transactionId});

  /// UUID of the transaction to display.
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionByIdProvider(transactionId));

    return txAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Transaction')),
            body: const Center(child: Text('Transaction not found.')),
          );
        }
        return _TransactionDetailView(transaction: tx);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _TransactionDetailView extends StatelessWidget {
  const _TransactionDetailView({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final isPending = tx.status == TransactionStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: Text(_typeLabel(tx.type)),
        actions: [
          PopupMenuButton<_TxAction>(
            onSelected: (action) => _handleAction(context, action),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _TxAction.edit,
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: _TxAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pending badge
          if (isPending) const _PendingBadge(),

          // Amount + currency
          _AmountRow(transaction: tx),

          const Divider(),

          // Date/time
          _DetailRow(
            label: 'Date',
            value: _formatEpoch(tx.dateTime),
          ),

          // Title
          if (tx.title != null)
            _DetailRow(label: 'Title', value: tx.title!),

          // Description
          if (tx.description != null)
            _DetailRow(label: 'Description', value: tx.description!),

          // Account info
          _AccountInfoSection(transaction: tx),

          // Category (not for transfers)
          if (tx.type != TransactionType.transfer &&
              tx.categoryId != null)
            _DetailRow(
              label: 'Category',
              value: tx.categoryId ?? '-',
            ),

          // Fee breakdown (compound transfer with fee)
          if (tx.compoundGroupId != null)
            _FeeBreakdownSection(transaction: tx),

          const Divider(),

          // Photo carousel stub
          const _PhotoCarouselStub(),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, _TxAction action) {
    switch (action) {
      case _TxAction.edit:
        context.push(AppRoutes.transactionEditPath(transaction.id));
      case _TxAction.delete:
        _confirmDelete(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'This will void the transaction and post a reversal entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO(T-53): call VoidTransactionUseCase
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _typeLabel(TransactionType type) => switch (type) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
        TransactionType.transfer => 'Transfer',
      };

  String _formatEpoch(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

enum _TxAction { edit, delete }

/// Badge shown for pending transactions.
class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: const Text('Pending'),
      backgroundColor: theme.colorScheme.tertiaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onTertiaryContainer),
    );
  }
}

/// Row displaying amount with currency and optional exchange rate.
///
/// Reads [currencySymbolLabelsProvider] (CURR-02, T-92) to resolve the
/// display label for the transaction's currency. When multiple active accounts
/// share a symbol (e.g. '$' for USD and CAD), the ISO-code suffix is shown.
class _AmountRow extends ConsumerWidget {
  const _AmountRow({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tx = transaction;
    final isIncome = tx.type == TransactionType.income;
    final isExpense = tx.type == TransactionType.expense;
    final amountColor = isIncome
        ? Colors.green
        : isExpense
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface;

    // Resolve the display label from the CURR-02 disambiguation map.
    // Falls back to bare ISO code when the provider hasn't emitted yet.
    final symbolLabels =
        ref.watch(currencySymbolLabelsProvider).value ?? {};
    final currencyLabel =
        symbolLabels[tx.currencyCode] ?? tx.currencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$currencyLabel ${(tx.amountMinor / 100).toStringAsFixed(2)}',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (tx.exchangeRateMicro != null) ...[
          const SizedBox(height: 4),
          Text(
            'Rate: ${tx.exchangeRateMicro! / 1000000}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Generic key-value detail row.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Account info section (source → destination or single account).
class _AccountInfoSection extends StatelessWidget {
  const _AccountInfoSection({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    return switch (tx.type) {
      TransactionType.expense => _DetailRow(
          label: 'Account',
          value: tx.accountSourceId ?? '-',
        ),
      TransactionType.income => _DetailRow(
          label: 'Account',
          value: tx.accountDestinationId ?? '-',
        ),
      TransactionType.transfer => _DetailRow(
          label: 'Transfer',
          value:
              '${tx.accountSourceId ?? '-'} → ${tx.accountDestinationId ?? '-'}',
        ),
    };
  }
}

/// Fee breakdown section for compound transfer-with-fee.
class _FeeBreakdownSection extends StatelessWidget {
  const _FeeBreakdownSection({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          'Fee breakdown',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        _DetailRow(
          label: 'Role',
          value: transaction.compoundRole ?? '-',
        ),
        _DetailRow(
          label: 'Group',
          value: transaction.compoundGroupId ?? '-',
        ),
      ],
    );
  }
}

/// Photo carousel placeholder — replaced when T-55 PhotoService is integrated.
class _PhotoCarouselStub extends StatelessWidget {
  const _PhotoCarouselStub();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'No photos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
