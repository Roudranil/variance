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
//   - "Installments" tab: placeholder (scoped to E-7)
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
// Test cases (see test/presentation/features/settings/recurring/
//             recurring_templates_list_screen_test.dart):
//   1. Golden: empty state.
//   2. Golden: populated state (Active + Paused + Archived groups).
//   3. Golden: error state.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_template_list_notifier.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Recurring Templates List screen (Settings > Recurring & Installments).
///
/// Shows the "Recurring" tab and a placeholder "Installments" tab.
/// Templates are grouped by status: Active → Paused → Archived.
class RecurringTemplatesListScreen extends ConsumerStatefulWidget {
  /// Creates a [RecurringTemplatesListScreen].
  const RecurringTemplatesListScreen({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
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
          // ---- Installments tab — placeholder (E-7) ----
          const _InstallmentsPlaceholder(),
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
// Installments tab placeholder
// ---------------------------------------------------------------------------

/// Placeholder for the Installments tab (scoped to E-7).
class _InstallmentsPlaceholder extends StatelessWidget {
  const _InstallmentsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Installments — coming soon',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
