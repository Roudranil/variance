// lib/presentation/features/settings/recurring/recurring_template_detail_screen.dart
//
// RecurringTemplateDetailScreen — view / edit a recurring template.
//
// Route: /settings/recurring/:id
// UX Flows §9.14, §9.14.1–§9.14.5
//
// Layout:
//   - AppBar: template title (or fallback), Save action button
//   - Body (scrollable form):
//       Status chip per §9.14.5
//       Immutable fields card (read-only chips + tooltips) — §9.14.2
//       Editable fields (active form inputs) — §9.14.3
//
// States (§9.14.1):
//   Loading  → shimmer skeleton
//   Loaded   → form rendered; Save disabled until dirty
//   Dirty    → Save enabled
//   Saving   → loading indicator on Save button
//   Error    → Snackbar "Failed to save."
//
// Data loading:
//   Uses a scoped Riverpod AsyncNotifier (RecurringTemplateDetail) that
//   bridges IRecurringTemplateRepository.watchById into AsyncValue<T>.
//   The notifier is family-parameterised on templateId.
//
// Test cases (see test/presentation/features/settings/recurring/
//             recurring_template_detail_screen_test.dart):
//   1. Golden: loaded state (active template).
//   2. Golden: loaded state (paused template).
//   3. Golden: dirty state (amount field changed — Save enabled).
//   4. Save calls UpdateRecurringTemplateUseCase and pops on success.
//   5. Save failure shows Snackbar "Failed to save.".
//   6. Shimmer shown during loading.

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

part 'recurring_template_detail_screen.g.dart';

// ---------------------------------------------------------------------------
// Scoped notifier — loads a single template by id
// ---------------------------------------------------------------------------

/// Bridges [IRecurringTemplateRepository.watchById] into [AsyncValue].
///
/// Family-parameterised on [templateId]. Auto-disposed when the route is
/// popped.
@riverpod
class RecurringTemplateDetail extends _$RecurringTemplateDetail {
  @override
  Future<RecurringTemplate?> build(String templateId) async {
    final repo = await ref.watch(recurringTemplateRepositoryProvider.future);
    final completer = Completer<RecurringTemplate?>();

    final sub = repo.watchById(templateId).listen(
      (template) {
        if (!completer.isCompleted) {
          completer.complete(template);
        } else if (ref.mounted) {
          state = AsyncData(template);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else if (ref.mounted) {
          state = AsyncError<RecurringTemplate?>(error, stack);
        }
      },
    );

    ref.onDispose(sub.cancel);
    return completer.future;
  }
}

// ---------------------------------------------------------------------------
// Screen widget
// ---------------------------------------------------------------------------

/// The Recurring Template Detail / Edit screen.
///
/// Loads [RecurringTemplate] with [templateId] and presents immutable fields
/// as read-only chips and editable fields as form inputs.
/// Delegates saves to [UpdateRecurringTemplateUseCase].
class RecurringTemplateDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [RecurringTemplateDetailScreen].
  ///
  /// Parameters:
  /// - [templateId]: UUID of the recurring template to display and edit.
  const RecurringTemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  /// UUID of the recurring template.
  final String templateId;

  @override
  ConsumerState<RecurringTemplateDetailScreen> createState() =>
      _RecurringTemplateDetailScreenState();
}

class _RecurringTemplateDetailScreenState
    extends ConsumerState<RecurringTemplateDetailScreen> {
  // Cached loaded template (used as base for building the updated entity).
  RecurringTemplate? _loadedTemplate;

  // Editable field controllers.
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeAmountController = TextEditingController();

  // Editable selection state.
  Account? _sourceAccount;
  Account? _destinationAccount;
  Category? _category;
  PostingBehaviour _postingBehaviour = PostingBehaviour.autoPost;
  bool _feeEnabled = false;
  FeeMode _feeMode = FeeMode.flat;

  // Form state flags.
  bool _isDirty = false;
  bool _isSaving = false;
  bool _populated = false; // true once fields have been populated

  @override
  void initState() {
    super.initState();
    // Listen for text changes to mark the form dirty.
    _amountController.addListener(_markDirty);
    _titleController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
    _feeAmountController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  /// Populates editable fields from [template] on first successful load.
  void _populate(RecurringTemplate template) {
    if (_populated) return;
    _populated = true;
    _loadedTemplate = template;

    final amount = (template.amountMinor / 100).toStringAsFixed(2);
    // Temporarily remove listeners to avoid triggering _markDirty during init.
    _amountController.removeListener(_markDirty);
    _amountController.text = amount;
    _amountController.addListener(_markDirty);

    _titleController.removeListener(_markDirty);
    _titleController.text = template.title ?? '';
    _titleController.addListener(_markDirty);

    _descriptionController.removeListener(_markDirty);
    _descriptionController.text = template.description ?? '';
    _descriptionController.addListener(_markDirty);

    _postingBehaviour = template.postingBehaviour;
    _feeEnabled = template.feeMode != null;
    _feeMode = template.feeMode ?? FeeMode.flat;
    if (_feeEnabled && template.feeAmountMinor != null) {
      _feeAmountController.removeListener(_markDirty);
      _feeAmountController.text =
          (template.feeAmountMinor! / 100).toStringAsFixed(2);
      _feeAmountController.addListener(_markDirty);
    }
  }

  /// Marks the form dirty (enables the Save button).
  void _markDirty() {
    if (!_isDirty && mounted) setState(() => _isDirty = true);
  }

  /// Whether Save should be enabled.
  bool get _canSave {
    if (!_isDirty || _isSaving || _loadedTemplate == null) return false;
    final amount = double.tryParse(_amountController.text);
    return amount != null && amount > 0;
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync =
        ref.watch(recurringTemplateDetailProvider(widget.templateId));

    // Populate editable fields on first data emission.
    templateAsync.whenData((template) {
      if (template != null && !_populated) {
        // Schedule for next frame to avoid setState during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _populate(template));
        });
      } else if (template != null) {
        _loadedTemplate = template;
      }
    });

    final appBarTitle = _loadedTemplate?.title?.isNotEmpty == true
        ? _loadedTemplate!.title!
        : 'Recurring Template';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: false,
        actions: [
          _SaveButton(
            enabled: _canSave,
            isSaving: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
      body: templateAsync.when(
        loading: () => const _ShimmerForm(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Failed to load template.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (template) {
          if (template == null) {
            return Center(
              child: Text(
                'Template not found.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          if (!_populated) {
            // Still waiting for addPostFrameCallback; show shimmer briefly.
            return const _ShimmerForm();
          }
          return _TemplateDetailForm(
            template: template,
            amountController: _amountController,
            titleController: _titleController,
            descriptionController: _descriptionController,
            feeAmountController: _feeAmountController,
            sourceAccount: _sourceAccount,
            destinationAccount: _destinationAccount,
            category: _category,
            postingBehaviour: _postingBehaviour,
            feeEnabled: _feeEnabled,
            feeMode: _feeMode,
            onSourceAccountChanged: (a) {
              setState(() => _sourceAccount = a);
              _markDirty();
            },
            onDestinationAccountChanged: (a) {
              setState(() => _destinationAccount = a);
              _markDirty();
            },
            onCategoryChanged: (c) {
              setState(() => _category = c);
              _markDirty();
            },
            onPostingBehaviourChanged: (pb) {
              setState(() => _postingBehaviour = pb);
              _markDirty();
            },
            onFeeEnabledChanged: (v) {
              setState(() => _feeEnabled = v);
              _markDirty();
            },
            onFeeModeChanged: (m) {
              setState(() => _feeMode = m);
              _markDirty();
            },
          );
        },
      ),
    );
  }

  /// Builds the updated [RecurringTemplate] and calls
  /// [UpdateRecurringTemplateUseCase].
  Future<void> _handleSave() async {
    if (!_canSave) return;
    final template = _loadedTemplate;
    if (template == null) return;

    setState(() => _isSaving = true);

    try {
      final useCase =
          await ref.read(updateRecurringTemplateUseCaseProvider.future);
      final amountMinor =
          ((double.parse(_amountController.text)) * 100).round();

      final updated = template.copyWith(
        amountMinor: amountMinor,
        accountSourceId: _sourceAccount?.id ?? template.accountSourceId,
        accountDestinationId:
            _destinationAccount?.id ?? template.accountDestinationId,
        categoryId: _category?.id ?? template.categoryId,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        postingBehaviour: _postingBehaviour,
        feeMode: _feeEnabled ? _feeMode : null,
        feeAmountMinor: _feeEnabled && _feeMode == FeeMode.flat
            ? (double.tryParse(_feeAmountController.text) ?? 0).round() * 100
            : null,
      );

      final result = await useCase(updated);

      if (!mounted) return;

      switch (result) {
        case Ok():
          // Use Navigator.maybePop so widget tests without a full GoRouter
          // context don't throw. In production the GoRouter handles the pop.
          Navigator.of(context).maybePop();
        case Err():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save.')),
          );
      }
    } on Object catch (e) {
      dev.log(
        'RecurringTemplateDetailScreen._handleSave: $e',
        name: 'RecurringTemplateDetailScreen',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Form body
// ---------------------------------------------------------------------------

/// Scrollable form body for a loaded template.
///
/// Renders status chip, immutable fields card, and editable form fields.
class _TemplateDetailForm extends ConsumerWidget {
  const _TemplateDetailForm({
    required this.template,
    required this.amountController,
    required this.titleController,
    required this.descriptionController,
    required this.feeAmountController,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.category,
    required this.postingBehaviour,
    required this.feeEnabled,
    required this.feeMode,
    required this.onSourceAccountChanged,
    required this.onDestinationAccountChanged,
    required this.onCategoryChanged,
    required this.onPostingBehaviourChanged,
    required this.onFeeEnabledChanged,
    required this.onFeeModeChanged,
  });

  final RecurringTemplate template;
  final TextEditingController amountController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController feeAmountController;
  final Account? sourceAccount;
  final Account? destinationAccount;
  final Category? category;
  final PostingBehaviour postingBehaviour;
  final bool feeEnabled;
  final FeeMode feeMode;
  final ValueChanged<Account?> onSourceAccountChanged;
  final ValueChanged<Account?> onDestinationAccountChanged;
  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<PostingBehaviour> onPostingBehaviourChanged;
  final ValueChanged<bool> onFeeEnabledChanged;
  final ValueChanged<FeeMode> onFeeModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status chip (§9.14.5).
        _StatusChip(template: template),
        const SizedBox(height: 16),

        // Immutable fields card (§9.14.2).
        _ImmutableFieldsCard(template: template),
        const SizedBox(height: 16),

        // Amount field.
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee),
            helperText: 'Applies to future unposted occurrences only',
          ),
        ),
        const SizedBox(height: 16),

        // Account pickers.
        _EditableAccountPickers(
          transactionType: template.transactionType,
          sourceAccount: sourceAccount,
          destinationAccount: destinationAccount,
          onSourceChanged: onSourceAccountChanged,
          onDestinationChanged: onDestinationAccountChanged,
        ),
        const SizedBox(height: 16),

        // Category picker (not for transfer).
        if (template.transactionType != 'transfer') ...[
          _EditableCategoryPicker(
            selected: category,
            transactionType: template.transactionType,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 16),
        ],

        // Title.
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // Description.
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Posting behaviour.
        _PostingBehaviourSelector(
          selected: postingBehaviour,
          onChanged: onPostingBehaviourChanged,
        ),
        const SizedBox(height: 16),

        // Transfer fee panel (transfer type only).
        if (template.transactionType == 'transfer') ...[
          _FeePanelToggle(
            enabled: feeEnabled,
            onToggle: onFeeEnabledChanged,
            feeMode: feeMode,
            feeAmountController: feeAmountController,
            onFeeModeChanged: onFeeModeChanged,
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip (§9.14.5)
// ---------------------------------------------------------------------------

/// Coloured chip showing the template lifecycle state per §9.14.5.
///
/// Active → "Next due: <date>"
/// Paused → "Paused until <date>"
/// Archived → "Archived"
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.template});

  final RecurringTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _statusDisplay(theme);

    return Chip(
      avatar: Icon(_statusIcon, size: 16, color: color),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(color: color),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }

  (String, Color) _statusDisplay(ThemeData theme) => switch (template.status) {
        RecurringTemplateStatus.active => (
            'Next due: ${_epochDaysLabel(template.startDate)}',
            theme.colorScheme.primary,
          ),
        RecurringTemplateStatus.paused => (
            template.pauseUntil != null
                ? 'Paused until ${_epochSecsLabel(template.pauseUntil!)}'
                : 'Paused',
            const Color(0xFFFFC107),
          ),
        RecurringTemplateStatus.archived || RecurringTemplateStatus.deleted => (
            'Archived',
            theme.colorScheme.outlineVariant,
          ),
      };

  IconData get _statusIcon => switch (template.status) {
        RecurringTemplateStatus.active => Icons.check_circle_outline,
        RecurringTemplateStatus.paused => Icons.pause_circle_outline,
        RecurringTemplateStatus.archived ||
        RecurringTemplateStatus.deleted =>
          Icons.archive_outlined,
      };

  String _epochDaysLabel(int days) => DateFormat.yMMMd().format(
        DateTime.fromMillisecondsSinceEpoch(days * 86400 * 1000, isUtc: true),
      );

  String _epochSecsLabel(int secs) => DateFormat.yMMMd().format(
        DateTime.fromMillisecondsSinceEpoch(secs * 1000, isUtc: true),
      );
}

// ---------------------------------------------------------------------------
// Immutable fields card (§9.14.2)
// ---------------------------------------------------------------------------

/// Read-only card showing immutable template metadata with tooltips.
class _ImmutableFieldsCard extends StatelessWidget {
  const _ImmutableFieldsCard({required this.template});

  final RecurringTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Read-only fields',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReadOnlyChip(
                  label: _typeLabel(template.transactionType),
                  tooltip:
                      'Transaction type cannot be changed. Create a new template to change the type.',
                  icon: Icons.swap_horiz_outlined,
                ),
                _ReadOnlyChip(
                  label:
                      'Every ${template.recurrenceN} ${template.recurrenceUnit.name}',
                  tooltip:
                      'Recurrence schedule cannot be changed. Archive this template and create a new one.',
                  icon: Icons.repeat_outlined,
                ),
                _ReadOnlyChip(
                  label: 'From ${_epochDays(template.startDate)}',
                  tooltip: 'Start date cannot be changed.',
                  icon: Icons.calendar_today_outlined,
                ),
                if (template.endDate != null)
                  _ReadOnlyChip(
                    label: 'Until ${_epochDays(template.endDate!)}',
                    tooltip: 'End date cannot be changed.',
                    icon: Icons.event_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'income' => 'Income',
        'transfer' => 'Transfer',
        _ => 'Expense',
      };

  String _epochDays(int days) => DateFormat.yMMMd().format(
        DateTime.fromMillisecondsSinceEpoch(days * 86400 * 1000, isUtc: true),
      );
}

/// A read-only chip with an explanatory Tooltip.
class _ReadOnlyChip extends StatelessWidget {
  const _ReadOnlyChip({
    required this.label,
    required this.tooltip,
    required this.icon,
  });

  final String label;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Chip(
        avatar: Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        label: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editable account pickers
// ---------------------------------------------------------------------------

/// Source / destination account pickers for the editable template form.
class _EditableAccountPickers extends ConsumerWidget {
  const _EditableAccountPickers({
    required this.transactionType,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  final String transactionType;
  final Account? sourceAccount;
  final Account? destinationAccount;
  final ValueChanged<Account?> onSourceChanged;
  final ValueChanged<Account?> onDestinationChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(activeAccountsProvider).value ?? const [];

    return Column(
      children: [
        if (transactionType == 'expense' || transactionType == 'transfer')
          _AccountDropdown(
            label: 'From account',
            selected: sourceAccount,
            accounts: accounts,
            onChanged: onSourceChanged,
          ),
        if (transactionType == 'transfer') const SizedBox(height: 12),
        if (transactionType == 'income' || transactionType == 'transfer')
          _AccountDropdown(
            label: 'To account',
            selected: destinationAccount,
            accounts: accounts,
            onChanged: onDestinationChanged,
          ),
      ],
    );
  }
}

/// Simple account dropdown field.
class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.label,
    required this.selected,
    required this.accounts,
    required this.onChanged,
  });

  final String label;
  final Account? selected;
  final List<Account> accounts;
  final ValueChanged<Account?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Account>(
      key: ValueKey(selected?.id),
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: accounts
          .map(
            (a) => DropdownMenuItem(value: a, child: Text(a.name)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Editable category picker
// ---------------------------------------------------------------------------

/// Category dropdown for editable mode.
class _EditableCategoryPicker extends ConsumerWidget {
  const _EditableCategoryPicker({
    required this.selected,
    required this.transactionType,
    required this.onChanged,
  });

  final Category? selected;
  final String transactionType;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final treeType = transactionType == 'income'
        ? CategoryTreeType.income
        : CategoryTreeType.expense;
    final relevant = categories
        .where((c) => c.treeType == treeType && !c.isProtected && !c.isDeleted)
        .toList();

    return DropdownButtonFormField<Category>(
      key: ValueKey(selected?.id),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Category (optional)',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<Category>(value: null, child: Text('None')),
        ...relevant.map(
          (c) => DropdownMenuItem(value: c, child: Text(c.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Posting behaviour selector
// ---------------------------------------------------------------------------

/// Radio selector for Auto-post vs Remind and confirm.
class _PostingBehaviourSelector extends StatelessWidget {
  const _PostingBehaviourSelector({
    required this.selected,
    required this.onChanged,
  });

  final PostingBehaviour selected;
  final ValueChanged<PostingBehaviour> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posting behaviour', style: theme.textTheme.titleSmall),
        RadioGroup<PostingBehaviour>(
          groupValue: selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: const Column(
            children: [
              RadioListTile<PostingBehaviour>(
                title: Text('Auto-post'),
                subtitle: Text('Transaction posted automatically'),
                value: PostingBehaviour.autoPost,
              ),
              RadioListTile<PostingBehaviour>(
                title: Text('Remind and confirm'),
                subtitle: Text('You confirm each occurrence manually'),
                value: PostingBehaviour.remindAndConfirm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Transfer fee panel
// ---------------------------------------------------------------------------

/// Expandable transfer fee panel.
class _FeePanelToggle extends StatelessWidget {
  const _FeePanelToggle({
    required this.enabled,
    required this.onToggle,
    required this.feeMode,
    required this.feeAmountController,
    required this.onFeeModeChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final FeeMode feeMode;
  final TextEditingController feeAmountController;
  final ValueChanged<FeeMode> onFeeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Transfer fee'),
          subtitle: const Text('Include a transfer service fee'),
          value: enabled,
          onChanged: onToggle,
        ),
        if (enabled) ...[
          SegmentedButton<FeeMode>(
            segments: const [
              ButtonSegment(value: FeeMode.flat, label: Text('Flat')),
              ButtonSegment(
                value: FeeMode.percentage,
                label: Text('Percentage'),
              ),
            ],
            selected: {feeMode},
            onSelectionChanged: (s) => onFeeModeChanged(s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: feeAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText:
                  feeMode == FeeMode.flat ? 'Fee amount' : 'Fee percentage',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Save button
// ---------------------------------------------------------------------------

/// Save action button shown in the AppBar.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: const Text('Save'),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer loading skeleton
// ---------------------------------------------------------------------------

/// Loading skeleton shown while the template stream resolves.
class _ShimmerForm extends StatelessWidget {
  const _ShimmerForm();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 32,
          width: 160,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 96,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 56, color: color),
        const SizedBox(height: 16),
        Container(height: 56, color: color),
        const SizedBox(height: 16),
        Container(height: 56, color: color),
      ],
    );
  }
}
