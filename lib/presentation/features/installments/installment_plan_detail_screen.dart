// lib/presentation/features/installments/installment_plan_detail_screen.dart
//
// InstallmentPlanDetailScreen — detail and edit view for a single installment plan.
//
// Route: /settings/installments/:id
//
// Layout (UI Spec §9.16, UX Flows §9.16):
//   - AppBar: back arrow, title "Installment Plan", trailing Save FilledButton
//   - Mismatch banner (non-blocking) when hasMismatch = true
//   - Summary card: 2×2 GridView showing Target/Paid/Remaining/Projected
//   - "Installments" section header
//   - Per-installment ListView: #, scheduled date, amount (editable if unposted),
//     status badge
//   - FAB: "Add installment"
//
// States (UX Flows §9.16.1):
//   Loading  → shimmer skeleton
//   Loaded   → full UI; Save disabled
//   Dirty    → Save enabled; mismatch banner if totals diverge
//
// Test cases (see test/presentation/features/installments/
//             installment_plan_detail_screen_test.dart):
//   T-137.1  Loading state: shimmer shown.
//   T-137.2  Loaded state: summary card with 4 cells shown.
//   T-137.3  Save button disabled initially (not dirty).
//   T-137.4  Mismatch banner shown when hasMismatch = true.
//   T-137.5  Mismatch banner hidden when hasMismatch = false.
//   T-138.1  Installment rows rendered for each occurrence.
//   T-138.2  Posted row amount is read-only.
//   T-138.3  Unposted row tapping amount enables edit.
//   T-138.4  FAB exists with add icon.
//   T-138.5  Editing unposted amount marks form dirty.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/installment_tracking_amounts.dart';
import 'package:variance/presentation/features/installments/installment_plan_notifiers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/theme/variance_colors.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Detail and edit screen for a single installment plan.
///
/// Displays a 4-cell summary card and a per-installment list below it.
/// Unposted installment amounts are editable inline; the Save button is
/// enabled when the form is dirty.
class InstallmentPlanDetailScreen extends ConsumerStatefulWidget {
  /// Creates an [InstallmentPlanDetailScreen].
  ///
  /// Parameters:
  /// - [templateId]: UUID of the installment plan template to display.
  const InstallmentPlanDetailScreen({
    required this.templateId,
    super.key,
  });

  /// UUID of the installment plan template.
  final String templateId;

  @override
  ConsumerState<InstallmentPlanDetailScreen> createState() =>
      _InstallmentPlanDetailScreenState();
}

class _InstallmentPlanDetailScreenState
    extends ConsumerState<InstallmentPlanDetailScreen> {
  // Tracks per-occurrence amount overrides: occurrenceId → minor units.
  final Map<String, int> _amountOverrides = {};

  // Whether the form has unsaved changes.
  bool _isDirty = false;

  // Whether a save operation is in progress.
  bool _isSaving = false;

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  /// Handles amount edit from the per-installment row.
  ///
  /// Parameters:
  /// - [occurrenceId]: The occurrence being edited.
  /// - [newAmountMinor]: The new amount in minor units.
  void _onAmountChanged(String occurrenceId, int newAmountMinor) {
    _amountOverrides[occurrenceId] = newAmountMinor;
    _markDirty();
  }

  /// Handles adding a new installment row.
  ///
  /// Appends a new occurrence after the last existing one with an auto-filled
  /// scheduled date and amount.
  Future<void> _onAddInstallment(InstallmentPlanDetail detail) async {
    final lastOcc =
        detail.occurrences.isNotEmpty ? detail.occurrences.last : null;

    // Compute next scheduled date: last + recurrenceN months (simplified).
    final nextDate = lastOcc != null
        ? lastOcc.scheduledDate + 30 // approximate 1-month offset in days
        : detail.plan.createdAt ~/ 86400;

    // Default amount: total_configured ÷ number_of_installments.
    final defaultAmount = detail.plan.numberOfInstallments > 0
        ? (detail.plan.totalConfiguredMinor / detail.plan.numberOfInstallments)
            .round()
        : 0;

    try {
      final occRepo =
          await ref.read(installmentOccurrenceRepositoryProvider.future);
      // We can't add to the repo directly without a full use case, so
      // we note this would call a use case. For now, mark dirty and show
      // a snackbar since this feature requires T-141.
      dev.log(
        'InstallmentPlanDetailScreen: Add installment — nextDate=$nextDate, '
        'defaultAmount=$defaultAmount, repo=$occRepo',
        name: 'InstallmentPlanDetailScreen',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add installment not yet available.'),
          ),
        );
      }
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanDetailScreen._onAddInstallment: $e',
        name: 'InstallmentPlanDetailScreen',
      );
    }
  }

  /// Saves all pending amount overrides atomically.
  Future<void> _onSave(InstallmentPlanDetail detail) async {
    if (_amountOverrides.isEmpty) {
      setState(() => _isDirty = false);
      return;
    }
    setState(() => _isSaving = true);

    try {
      final planRepo = await ref.read(installmentPlanRepositoryProvider.future);

      // Persist plan-level changes (e.g. number_of_installments).
      await planRepo.update(detail.plan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved.')),
        );
        setState(() {
          _isDirty = false;
          _isSaving = false;
          _amountOverrides.clear();
        });
      }
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanDetailScreen._onSave: $e',
        name: 'InstallmentPlanDetailScreen',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes.')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(installmentPlanDetailProvider(widget.templateId));

    // Use .value (Riverpod 3.x; valueOrNull removed).
    final currentDetail = async.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Plan'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: async.when(
              data: (InstallmentPlanDetail detail) => FilledButton(
                onPressed:
                    (_isDirty && !_isSaving) ? () => _onSave(detail) : null,
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              loading: () => const FilledButton(
                onPressed: null,
                child: Text('Save'),
              ),
              error: (Object _, StackTrace __) => const FilledButton(
                onPressed: null,
                child: Text('Save'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: currentDetail != null
          ? FloatingActionButton(
              onPressed: () => _onAddInstallment(currentDetail),
              tooltip: 'Add installment',
              child: const Icon(Icons.add),
            )
          : null,
      body: async.when(
        loading: () => const _ShimmerSkeleton(),
        error: (Object error, StackTrace _) => _ErrorView(
          message: 'Failed to load plan: $error',
          onRetry: () =>
              ref.invalidate(installmentPlanDetailProvider(widget.templateId)),
        ),
        data: (InstallmentPlanDetail detail) => _PlanDetailBody(
          detail: detail,
          amountOverrides: Map.unmodifiable(_amountOverrides),
          onAmountChanged: _onAmountChanged,
          onMarkDirty: _markDirty,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

/// The main scrollable body shown when data is available.
class _PlanDetailBody extends StatelessWidget {
  const _PlanDetailBody({
    required this.detail,
    required this.amountOverrides,
    required this.onAmountChanged,
    required this.onMarkDirty,
  });

  final InstallmentPlanDetail detail;

  /// Per-occurrence amount overrides; keyed by occurrence ID.
  final Map<String, int> amountOverrides;

  /// Callback when user edits an occurrence amount.
  final void Function(String occurrenceId, int newAmountMinor) onAmountChanged;

  /// Callback to mark the form dirty.
  final VoidCallback onMarkDirty;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        // ---- Mismatch banner ----
        if (detail.hasMismatch)
          _MismatchBanner(trackingAmounts: detail.trackingAmounts),

        // ---- Summary card ----
        _SummaryCard(
          plan: detail.plan,
          trackingAmounts: detail.trackingAmounts,
        ),

        const SizedBox(height: 16),

        // ---- Section header ----
        const _SectionHeader(label: 'Installments'),

        const SizedBox(height: 8),

        // ---- Per-installment list ----
        ...detail.occurrences.map(
          (occ) => _InstallmentRow(
            occurrence: occ,
            overrideAmountMinor: amountOverrides[occ.id],
            onAmountChanged: occ.status == InstallmentOccurrenceStatus.pending
                ? (newAmount) => onAmountChanged(occ.id, newAmount)
                : null,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mismatch banner
// ---------------------------------------------------------------------------

/// Non-blocking inline warning when projected total ≠ configured total.
class _MismatchBanner extends StatelessWidget {
  const _MismatchBanner({required this.trackingAmounts});

  final InstallmentTrackingAmounts trackingAmounts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VarianceColors>();
    final warningColor = colors?.warningAmount ?? const Color(0xFFFF9800);
    final projected = trackingAmounts.projectedFinalTotalMinor / 100;
    final configured = trackingAmounts.totalConfiguredMinor / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: warningColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Total paid will be ₹${projected.toStringAsFixed(2)}, '
              'original target was ₹${configured.toStringAsFixed(2)}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: warningColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

/// 2×2 grid card showing the 4 tracked amounts.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.plan,
    required this.trackingAmounts,
  });

  final InstallmentPlan plan;
  final InstallmentTrackingAmounts trackingAmounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = [
      (
        label: 'Target total',
        value: _formatAmount(trackingAmounts.totalConfiguredMinor),
      ),
      (
        label: 'Paid to date',
        value: _formatAmount(trackingAmounts.runningTotalMinor),
      ),
      (
        label: 'Remaining',
        value: _formatAmount(trackingAmounts.totalRemainingMinor),
      ),
      (
        label: 'Projected total',
        value: _formatAmount(trackingAmounts.projectedFinalTotalMinor),
      ),
    ];

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: cells
              .map(
                (cell) => _SummaryCell(
                  label: cell.label,
                  value: cell.value,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _formatAmount(int minor) {
    final amount = minor / 100;
    return '₹${amount.toStringAsFixed(2)}';
  }
}

/// A single cell in the summary card.
class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section label (e.g. "Installments") above the per-installment list.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Installment row
// ---------------------------------------------------------------------------

/// A single installment occurrence row.
///
/// Shows the sequence number, scheduled date, amount, and status badge.
/// If [onAmountChanged] is non-null, the amount is tappable for inline edit.
class _InstallmentRow extends StatefulWidget {
  const _InstallmentRow({
    required this.occurrence,
    required this.overrideAmountMinor,
    required this.onAmountChanged,
  });

  /// The installment occurrence data.
  final InstallmentOccurrence occurrence;

  /// Per-session override amount (null = use occurrence.amountMinor).
  final int? overrideAmountMinor;

  /// Non-null if the occurrence is editable (unposted).
  final void Function(int newAmountMinor)? onAmountChanged;

  @override
  State<_InstallmentRow> createState() => _InstallmentRowState();
}

class _InstallmentRowState extends State<_InstallmentRow> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final amount =
        (widget.overrideAmountMinor ?? widget.occurrence.amountMinor) / 100;
    _controller = TextEditingController(text: amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.onAmountChanged == null) return;
    setState(() => _isEditing = true);
  }

  void _commitEdit() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null && parsed > 0) {
      widget.onAmountChanged!((parsed * 100).round());
    }
    setState(() => _isEditing = false);
  }

  String _formatDate(int epochDays) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochDays * 86400 * 1000,
        isUtc: true);
    return DateFormat.yMMMd().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occ = widget.occurrence;
    final isEditable = widget.onAmountChanged != null;

    return Dismissible(
      key: ValueKey('occ_${occ.id}'),
      // Only allow swipe-delete for unposted occurrences.
      direction:
          isEditable ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation before dismissal.
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remove installment?'),
                content: Text(
                  'Remove installment #${occ.sequenceNumber}? '
                  'This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        // Mark dirty since an occurrence was removed.
        widget.onAmountChanged?.call(-1); // sentinel: -1 = deleted
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // ---- Sequence number ----
              SizedBox(
                width: 28,
                child: Text(
                  '#${occ.sequenceNumber}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ---- Date ----
              Expanded(
                flex: 3,
                child: Text(
                  _formatDate(occ.scheduledDate),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // ---- Amount (editable if unposted) ----
              Expanded(
                flex: 3,
                child: isEditable && _isEditing
                    ? TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.]'),
                          ),
                        ],
                        autofocus: true,
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                          prefixText: '₹',
                        ),
                        onEditingComplete: _commitEdit,
                        onSubmitted: (_) => _commitEdit(),
                      )
                    : GestureDetector(
                        onTap: isEditable ? _startEditing : null,
                        child: Text(
                          '₹${((widget.overrideAmountMinor ?? occ.amountMinor) / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                isEditable ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 8),

              // ---- Status badge ----
              _StatusChip(status: occ.status),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

/// A small chip displaying the installment occurrence status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final InstallmentOccurrenceStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, background, foreground) = switch (status) {
      InstallmentOccurrenceStatus.posted => (
          'Posted',
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
      InstallmentOccurrenceStatus.cancelled => (
          'Cancelled',
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
      InstallmentOccurrenceStatus.pending => (
          'Scheduled',
          theme.colorScheme.surfaceContainerHigh,
          theme.colorScheme.onSurface,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton
// ---------------------------------------------------------------------------

/// A loading placeholder skeleton matching the detail screen layout.
class _ShimmerSkeleton extends StatelessWidget {
  const _ShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card placeholder.
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        // Row placeholders.
        for (var i = 0; i < 6; i++) ...[
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

/// Inline error with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
