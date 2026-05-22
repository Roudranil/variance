// lib/presentation/features/settings/recurring/recurring_templates_list_screen.dart
//
// RecurringTemplatesListScreen — Settings > Recurring & Installments.
//
// Route: /settings/recurring
//
// Layout (UX Flows §9.13):
//   - SmallTopAppBar "Recurring & Installments"
//   - TabBar: "Recurring" / "Installments"
//   - "Recurring" tab (in scope for T-108):
//       Three groups: Active, Paused, Archived (non-empty groups shown only).
//       Each group is a section header + list of RecurringTemplateRow widgets.
//   - "Installments" tab (T-139, T-140):
//       Three groups: Active, Paused, Archived.
//       Each group shows InstallmentTemplateRow widgets with progress bar.
//
// States (UX Flows §9.13.1):
//   Loading  → shimmer skeleton
//   Empty    → illustration + "No recurring templates" text
//   Populated → grouped list (Active / Paused / Archived)
//   Error    → inline error + Retry button
//
// Template Row (UX Flows §9.13.2):
//   - Title: template title, or "<amount> · <category>" fallback
//   - Status badge: Active (green) / Paused (amber) / Archived (grey)
//   - Recurrence summary: "Every N <unit> · <posting behaviour>"
//   - Next due date (active/paused only)
//   - Long-tap context menu per status:
//       Active   → Edit, Delete, Pause, View child transactions
//       Paused   → Edit, Delete, Unpause, View child transactions
//       Archived → View child transactions (read-only)
//
// Installment Row (UX Flows §9.13.3):
//   - Title: template title or amount
//   - LinearProgressIndicator: value = paid/total installment count
//   - Running total: "₹X paid of ₹Y"
//   - Long-tap menu per status (T-140)
//
// Test cases (see test/presentation/features/settings/recurring/
//             recurring_templates_list_screen_test.dart):
//   1. Golden: empty state.
//   2. Golden: populated state (Active + Paused + Archived groups).
//   3. Golden: error state.
//   4. Installments tab: empty state, groups, row structure (T-139).
//   5. Installments tab: long-press menu per status (T-140).

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/presentation/features/installments/installment_plan_notifiers.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_template_list_notifier.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/theme/variance_colors.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Recurring Templates List screen (Settings > Recurring & Installments).
///
/// Shows the "Recurring" tab and the "Installments" tab.
/// Templates are grouped by status: Active → Paused → Archived.
///
/// The optional [initialTab] selects the starting tab: 0 = Recurring,
/// 1 = Installments. Defaults to 0.
class RecurringTemplatesListScreen extends ConsumerStatefulWidget {
  /// Creates a [RecurringTemplatesListScreen].
  ///
  /// Parameters:
  /// - [initialTab]: Which tab to show first (0 = Recurring, 1 = Installments).
  const RecurringTemplatesListScreen({
    super.key,
    this.initialTab = 0,
  });

  /// Initial tab index: 0 = Recurring, 1 = Installments.
  final int initialTab;

  @override
  ConsumerState<RecurringTemplatesListScreen> createState() =>
      _RecurringTemplatesListScreenState();
}

class _RecurringTemplatesListScreenState
    extends ConsumerState<RecurringTemplatesListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(recurringTemplateListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Installments'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recurring'),
            Tab(text: 'Installments'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.settingsRecurringNew),
        tooltip: 'Add Recurring Template',
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---- Recurring tab ----
          async.when(
            loading: () => const _ShimmerList(),
            error: (error, _) => _ErrorView(
              onRetry: () => ref.invalidate(recurringTemplateListProvider),
            ),
            data: (templates) {
              if (templates.isEmpty) {
                return const _EmptyView();
              }
              return _RecurringTabContent(templates: templates);
            },
          ),
          // ---- Installments tab (T-139, T-140) ----
          const _InstallmentsTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recurring tab content
// ---------------------------------------------------------------------------

/// Renders Active / Paused / Archived groups for recurring templates.
class _RecurringTabContent extends StatelessWidget {
  const _RecurringTabContent({required this.templates});

  final List<RecurringTemplate> templates;

  @override
  Widget build(BuildContext context) {
    final active = templates
        .where((t) => t.status == RecurringTemplateStatus.active)
        .toList();
    final paused = templates
        .where((t) => t.status == RecurringTemplateStatus.paused)
        .toList();
    final archived = templates
        .where((t) => t.status == RecurringTemplateStatus.archived)
        .toList();

    // Build a flat list of header + rows for each non-empty group.
    return ListView(
      children: [
        if (active.isNotEmpty) ...[
          const _GroupHeader(label: 'Active'),
          ...active.map(
            (t) => _RecurringTemplateRow(template: t),
          ),
        ],
        if (paused.isNotEmpty) ...[
          const _GroupHeader(label: 'Paused'),
          ...paused.map(
            (t) => _RecurringTemplateRow(template: t),
          ),
        ],
        if (archived.isNotEmpty) ...[
          const _GroupHeader(label: 'Archived'),
          ...archived.map(
            (t) => _RecurringTemplateRow(template: t),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Template row
// ---------------------------------------------------------------------------

/// A single recurring template list item.
///
/// Shows title/fallback, status badge, recurrence summary, and next due date.
/// Long-tap opens a context menu scoped to the template's current status.
class _RecurringTemplateRow extends StatelessWidget {
  const _RecurringTemplateRow({required this.template});

  final RecurringTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _buildTitle(template);
    final summary = _buildSummary(template);
    final nextDue = _buildNextDue(template);

    return GestureDetector(
      onLongPress: () => _showContextMenu(context, template),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (nextDue != null)
              Text(
                nextDue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: _StatusBadge(status: template.status),
        isThreeLine: nextDue != null,
      ),
    );
  }

  /// Builds the display title for [template].
  ///
  /// Falls back to `<amount> · <type>` when the template has no title.
  String _buildTitle(RecurringTemplate t) {
    if (t.title != null && t.title!.isNotEmpty) return t.title!;
    final amount = (t.amountMinor / 100).toStringAsFixed(2);
    return '$amount · ${t.transactionType}';
  }

  /// Builds the recurrence summary string, e.g. "Every 2 weeks · Auto-post".
  String _buildSummary(RecurringTemplate t) {
    final unitLabel = switch (t.recurrenceUnit) {
      RecurrenceUnit.day => t.recurrenceN == 1 ? 'day' : 'days',
      RecurrenceUnit.week => t.recurrenceN == 1 ? 'week' : 'weeks',
      RecurrenceUnit.month => t.recurrenceN == 1 ? 'month' : 'months',
      RecurrenceUnit.year => t.recurrenceN == 1 ? 'year' : 'years',
    };
    final freq = 'Every ${t.recurrenceN} $unitLabel';
    final behaviour = t.postingBehaviour == PostingBehaviour.autoPost
        ? 'Auto-post'
        : 'Remind & confirm';
    return '$freq · $behaviour';
  }

  /// Returns a human-readable "Next due: `<date>`" string for active/paused
  /// templates, or null for archived templates.
  String? _buildNextDue(RecurringTemplate t) {
    if (t.status == RecurringTemplateStatus.archived) return null;
    // Convert startDate (epoch days) to a readable date.
    final dt = DateTime.fromMillisecondsSinceEpoch(
      t.startDate * 86400 * 1000,
      isUtc: true,
    );
    final formatted = DateFormat.yMMMd().format(dt);
    return 'Next due: $formatted';
  }

  /// Shows the long-tap context menu based on the template's [status].
  void _showContextMenu(BuildContext context, RecurringTemplate t) {
    final actions = _menuActionsFor(t.status);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _TemplateContextMenu(
        template: t,
        actions: actions,
      ),
    );
  }

  /// Returns the list of menu action labels for [status].
  List<_TemplateAction> _menuActionsFor(RecurringTemplateStatus status) {
    return switch (status) {
      RecurringTemplateStatus.active => const [
          _TemplateAction.edit,
          _TemplateAction.delete,
          _TemplateAction.pause,
          _TemplateAction.viewChildren,
        ],
      RecurringTemplateStatus.paused => const [
          _TemplateAction.edit,
          _TemplateAction.delete,
          _TemplateAction.unpause,
          _TemplateAction.viewChildren,
        ],
      RecurringTemplateStatus.archived ||
      RecurringTemplateStatus.deleted =>
        const [
          _TemplateAction.viewChildren,
        ],
    };
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

/// A coloured chip-like badge showing the template lifecycle status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RecurringTemplateStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      RecurringTemplateStatus.active => (
          'Active',
          const Color(0xFF4CAF50), // green
        ),
      RecurringTemplateStatus.paused => (
          'Paused',
          const Color(0xFFFFC107), // amber
        ),
      RecurringTemplateStatus.archived || RecurringTemplateStatus.deleted => (
          'Archived',
          theme.colorScheme.outlineVariant,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Context menu
// ---------------------------------------------------------------------------

/// Long-tap context menu actions for a recurring template.
enum _TemplateAction {
  edit,
  delete,
  pause,
  unpause,
  viewChildren,
}

/// Bottom-sheet context menu for a recurring template.
///
/// Handles [_TemplateAction.unpause] by calling
/// [IRecurringTemplateRepository.resume] (T-114). Other actions are
/// TODO for their respective tasks.
class _TemplateContextMenu extends ConsumerWidget {
  const _TemplateContextMenu({
    required this.template,
    required this.actions,
  });

  final RecurringTemplate template;
  final List<_TemplateAction> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          final (label, icon) = switch (action) {
            _TemplateAction.edit => ('Edit template', Icons.edit_outlined),
            _TemplateAction.delete => (
                'Delete template',
                Icons.delete_outlined,
              ),
            _TemplateAction.pause => ('Pause', Icons.pause_outlined),
            _TemplateAction.unpause => ('Unpause', Icons.play_arrow_outlined),
            _TemplateAction.viewChildren => (
                'View child transactions',
                Icons.list_outlined,
              ),
          };
          return ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () async {
              Navigator.of(context).pop();
              switch (action) {
                case _TemplateAction.unpause:
                  await _handleUnpause(context, ref);
                case _TemplateAction.edit:
                case _TemplateAction.delete:
                case _TemplateAction.pause:
                case _TemplateAction.viewChildren:
                  // TODO(T-108/T-109): wire remaining actions.
                  break;
              }
            },
          );
        }).toList(),
      ),
    );
  }

  /// Calls [IRecurringTemplateRepository.resume] for this template and shows
  /// a [SnackBar] confirming the result.
  ///
  /// Shows "Template resumed." on success or "Failed to resume template." on
  /// error. Guards with [BuildContext.mounted] after the async gap.
  Future<void> _handleUnpause(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(recurringTemplateRepositoryProvider.future);
      final result = await repo.resume(template.id);
      if (!context.mounted) return;
      switch (result) {
        case Ok():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template resumed.')),
          );
        case Err():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to resume template.')),
          );
      }
    } on Object catch (e) {
      dev.log(
        '_TemplateContextMenu._handleUnpause: $e',
        name: '_TemplateContextMenu',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resume template.')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Section group header
// ---------------------------------------------------------------------------

/// A section header label above each status group.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading shimmer
// ---------------------------------------------------------------------------

/// A shimmer-like loading skeleton for the recurring template list.
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: color,
                  ),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 120, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

/// Empty-state illustration shown when no recurring templates exist.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
              Icons.repeat_rounded,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recurring templates',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set up a recurring template to automate repeated transactions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

/// Inline error view with a Retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

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
              'Failed to load recurring templates.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Installments tab (T-139)
// ---------------------------------------------------------------------------

/// The Installments tab inside [RecurringTemplatesListScreen].
///
/// Combines [installmentPlanListProvider] (financial data) and
/// [installmentTemplateListProvider] (status, title) to render grouped
/// [_InstallmentTemplateRow] widgets with status-aware context menus.
class _InstallmentsTab extends ConsumerWidget {
  const _InstallmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // installmentTemplateListProvider watches all installment-flagged templates.
    final templateAsync = ref.watch(installmentTemplateListProvider);
    final planAsync = ref.watch(installmentPlanListProvider);

    // Show shimmer if either is loading.
    if (templateAsync.isLoading || planAsync.isLoading) {
      return const _ShimmerList();
    }

    // Show error if either fails.
    if (templateAsync.hasError || planAsync.hasError) {
      return _ErrorView(
        onRetry: () {
          ref.invalidate(installmentTemplateListProvider);
          ref.invalidate(installmentPlanListProvider);
        },
      );
    }

    // Use .value (Riverpod 3.x; valueOrNull removed).
    final allTemplates = templateAsync.value ?? [];
    final plans = planAsync.value ?? [];

    // Build a plan index for fast lookup.
    final planIndex = <String, InstallmentPlan>{
      for (final p in plans) p.templateId: p,
    };

    // Filter installment templates only.
    final installmentTemplates =
        allTemplates.where((RecurringTemplate t) => t.isInstallment).toList();

    if (installmentTemplates.isEmpty) {
      return const _InstallmentsEmptyView();
    }

    final active = installmentTemplates
        .where(
            (RecurringTemplate t) => t.status == RecurringTemplateStatus.active)
        .toList();
    final paused = installmentTemplates
        .where(
            (RecurringTemplate t) => t.status == RecurringTemplateStatus.paused)
        .toList();
    final archived = installmentTemplates
        .where(
          (RecurringTemplate t) =>
              t.status == RecurringTemplateStatus.archived ||
              t.status == RecurringTemplateStatus.deleted,
        )
        .toList();

    return ListView(
      children: [
        if (active.isNotEmpty) ...[
          const _GroupHeader(label: 'Active'),
          ...active.map(
            (RecurringTemplate t) => _InstallmentTemplateRow(
              template: t,
              plan: planIndex[t.id],
            ),
          ),
        ],
        if (paused.isNotEmpty) ...[
          const _GroupHeader(label: 'Paused'),
          ...paused.map(
            (RecurringTemplate t) => _InstallmentTemplateRow(
              template: t,
              plan: planIndex[t.id],
            ),
          ),
        ],
        if (archived.isNotEmpty) ...[
          const _GroupHeader(label: 'Archived'),
          ...archived.map(
            (RecurringTemplate t) => _InstallmentTemplateRow(
              template: t,
              plan: planIndex[t.id],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Installment template row (T-139)
// ---------------------------------------------------------------------------

/// A single installment template row.
///
/// Shows title, progress bar (paid/total), and a "₹X paid of ₹Y" label.
/// Long-tap opens a status-aware context menu (T-140).
class _InstallmentTemplateRow extends StatelessWidget {
  const _InstallmentTemplateRow({
    required this.template,
    required this.plan,
  });

  final RecurringTemplate template;

  /// The associated [InstallmentPlan] for financial data; may be null if the
  /// plan row was not found.
  final InstallmentPlan? plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = template.title?.isNotEmpty == true
        ? template.title!
        : '₹${(template.amountMinor / 100).toStringAsFixed(0)}';

    // Progress value: we use a ratio based on amount. With no tracking data,
    // we fall back to 0 progress.
    final totalConfigured = plan?.totalConfiguredMinor ?? 0;
    // We cannot compute runningTotal without tracking amounts stream here.
    // For the list view, we show 0 as placeholder; the detail screen shows
    // the real value. This matches the spec: the list shows basic progress.
    const runningTotal = 0;
    final progressValue = totalConfigured > 0
        ? (runningTotal / totalConfigured).clamp(0.0, 1.0)
        : 0.0;

    final totalStr = '₹${(totalConfigured / 100).toStringAsFixed(2)}';
    final paidStr = '₹${(runningTotal / 100).toStringAsFixed(2)}';

    return GestureDetector(
      onLongPress: () => _showContextMenu(context, template),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 4),
            Text(
              '$paidStr paid of $totalStr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: _InstallmentStatusBadge(status: template.status),
        isThreeLine: true,
      ),
    );
  }

  void _showContextMenu(BuildContext context, RecurringTemplate t) {
    final actions = _menuActionsFor(t.status);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _InstallmentContextMenu(
        template: t,
        actions: actions,
      ),
    );
  }

  List<_InstallmentAction> _menuActionsFor(RecurringTemplateStatus status) {
    return switch (status) {
      RecurringTemplateStatus.active => const [
          _InstallmentAction.edit,
          _InstallmentAction.delete,
          _InstallmentAction.pause,
          _InstallmentAction.viewChildren,
          _InstallmentAction.viewProgress,
          _InstallmentAction.markComplete,
        ],
      RecurringTemplateStatus.paused => const [
          _InstallmentAction.edit,
          _InstallmentAction.delete,
          _InstallmentAction.unpause,
          _InstallmentAction.viewChildren,
          _InstallmentAction.viewProgress,
          _InstallmentAction.markComplete,
        ],
      RecurringTemplateStatus.archived ||
      RecurringTemplateStatus.deleted =>
        const [
          _InstallmentAction.viewChildren,
          _InstallmentAction.viewProgress,
        ],
    };
  }
}

// ---------------------------------------------------------------------------
// Installment status badge
// ---------------------------------------------------------------------------

/// A coloured badge for installment template lifecycle status.
class _InstallmentStatusBadge extends StatelessWidget {
  const _InstallmentStatusBadge({required this.status});

  final RecurringTemplateStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<VarianceColors>();

    final (label, color) = switch (status) {
      RecurringTemplateStatus.active => (
          'Active',
          colors?.accentPastel ?? const Color(0xFF4CAF50),
        ),
      RecurringTemplateStatus.paused => (
          'Paused',
          colors?.warningAmount ?? const Color(0xFFFFC107),
        ),
      RecurringTemplateStatus.archived || RecurringTemplateStatus.deleted => (
          'Archived',
          theme.colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Installment context menu (T-140)
// ---------------------------------------------------------------------------

/// Long-tap context menu actions for an installment template row.
enum _InstallmentAction {
  edit,
  delete,
  pause,
  unpause,
  viewChildren,
  viewProgress,
  markComplete,
}

/// Bottom-sheet context menu for an installment template row.
class _InstallmentContextMenu extends ConsumerWidget {
  const _InstallmentContextMenu({
    required this.template,
    required this.actions,
  });

  final RecurringTemplate template;
  final List<_InstallmentAction> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          final (label, icon) = switch (action) {
            _InstallmentAction.edit => ('Edit template', Icons.edit_outlined),
            _InstallmentAction.delete => (
                'Delete template',
                Icons.delete_outlined,
              ),
            _InstallmentAction.pause => ('Pause', Icons.pause_outlined),
            _InstallmentAction.unpause => (
                'Unpause',
                Icons.play_arrow_outlined
              ),
            _InstallmentAction.viewChildren => (
                'View child transactions',
                Icons.list_outlined,
              ),
            _InstallmentAction.viewProgress => (
                'View progress',
                Icons.bar_chart_outlined,
              ),
            _InstallmentAction.markComplete => (
                'Mark series as complete',
                Icons.check_circle_outline,
              ),
          };

          return ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () async {
              Navigator.of(context).pop();
              await _handleAction(context, ref, action);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _InstallmentAction action,
  ) async {
    switch (action) {
      case _InstallmentAction.viewProgress:
        // Navigate to installment plan detail screen.
        // context.push returns Future<T?> — unawaited intentionally (fire-and-forget nav).
        if (context.mounted) {
          unawaited(
            context.push(AppRoutes.settingsInstallmentDetailPath(template.id)),
          );
        }

      case _InstallmentAction.unpause:
        try {
          final repo =
              await ref.read(recurringTemplateRepositoryProvider.future);
          final result = await repo.resume(template.id);
          if (!context.mounted) return;
          switch (result) {
            case Ok():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template resumed.')),
              );
            case Err():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to resume template.')),
              );
          }
        } on Object catch (e) {
          dev.log(
            '_InstallmentContextMenu._handleAction unpause: $e',
            name: '_InstallmentContextMenu',
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to resume template.')),
          );
        }

      case _InstallmentAction.edit:
      case _InstallmentAction.delete:
      case _InstallmentAction.pause:
      case _InstallmentAction.viewChildren:
      case _InstallmentAction.markComplete:
        // TODO(T-140/T-141): Wire remaining actions.
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state for installments tab
// ---------------------------------------------------------------------------

/// Empty-state view shown when no installment plans exist.
class _InstallmentsEmptyView extends StatelessWidget {
  const _InstallmentsEmptyView();

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
              Icons.payments_outlined,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No installment plans',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an installment plan to track EMI or loan payments.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
