// lib/presentation/features/settings/warnings/category_limits_screen.dart
//
// Per-Category Limits sub-screen (T-182).
//
// Spec references:
//   - UX Flows §9.5.3: Per-Category Limits Sub-screen
//   - UI Spec §9.5.3: Components and visual tokens
//   - TC-047: Category thresholds are denominated in home currency
//
// Renders all expense/income categories excluding BAI/BAE system categories.
// Labels show home currency symbol. On change, calls
// ICategoryRepository.update(category) writing largeTxnThresholdMinor.
//
// BAI/BAE exclusion: categories with isProtected=true AND parentId!=null are
// the BAI/BAE leaf categories that must be hidden from this list.
//
// Test cases (see test/presentation/features/settings/warnings/
//             category_limits_screen_test.dart):
//   1. Empty state shows "No expense categories" message when list is empty.
//   2. BAI and BAE protected leaf categories are excluded from the list.
//   3. Non-protected categories are listed.
//   4. Category row shows home currency symbol as label.
//   5. Entering a threshold and confirming calls repository update.
//   6. Clearing a threshold sets it to null.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

/// Per-Category Limits sub-screen.
///
/// Lists all non-deleted, non-BAI/BAE categories with an inline threshold field
/// per row. Threshold amounts are in the home currency.
class CategoryLimitsScreen extends ConsumerWidget {
  /// Creates the [CategoryLimitsScreen].
  const CategoryLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    final homeCurrency = settingsAsync.value?.homeCurrency ?? 'INR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Spending Limits'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load categories.'),
        ),
        data: (categories) {
          // Exclude BAI/BAE: protected leaf categories (isProtected=true and
          // parentId!=null). Root protected categories (Balance Adjustment
          // parents) are also excluded as they are structural only.
          final visible =
              categories.where((c) => !c.isDeleted && !c.isProtected).toList();

          if (visible.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              return _CategoryThresholdRow(
                category: visible[index],
                homeCurrency: homeCurrency,
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

/// Shown when there are no eligible categories.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No expense categories',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category threshold row
// ---------------------------------------------------------------------------

/// A [ListTile] for a single category with an inline threshold editor.
class _CategoryThresholdRow extends ConsumerStatefulWidget {
  const _CategoryThresholdRow({
    required this.category,
    required this.homeCurrency,
  });

  /// The category to display.
  final Category category;

  /// ISO 4217 home currency code shown as threshold label.
  final String homeCurrency;

  @override
  ConsumerState<_CategoryThresholdRow> createState() =>
      _CategoryThresholdRowState();
}

class _CategoryThresholdRowState extends ConsumerState<_CategoryThresholdRow> {
  /// Whether the inline edit field is currently expanded.
  bool _isEditing = false;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = widget.category.largeTxnThresholdMinor;
    _controller = TextEditingController(
      text: current != null ? (current / 100).toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMinor = widget.category.largeTxnThresholdMinor;
    final isParent = widget.category.parentId == null;

    if (_isEditing) {
      return _InlineEditRow(
        controller: _controller,
        currencyCode: widget.homeCurrency,
        onConfirm: _save,
        onClear: _clear,
        onCancel: _cancelEdit,
      );
    }

    final trailingText = currentMinor != null
        ? '${(currentMinor / 100).toStringAsFixed(2)} ${widget.homeCurrency}'
        : 'Not set';

    return ListTile(
      leading: Icon(
        Icons.category_outlined,
        color: isParent ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        widget.category.name,
        style: TextStyle(
          fontWeight: isParent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: isParent
          ? Text(
              widget.category.treeType.name,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: Text(
        trailingText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: currentMinor != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
      ),
      onTap: () => setState(() => _isEditing = true),
    );
  }

  /// Saves the entered threshold to the repository.
  Future<void> _save() async {
    final text = _controller.text.trim();
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) {
      _cancelEdit();
      return;
    }

    final minorUnits = (parsed * 100).round();
    final updated =
        widget.category.copyWith(largeTxnThresholdMinor: minorUnits);

    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.update(updated);

    if (mounted) setState(() => _isEditing = false);
  }

  /// Clears the threshold (sets to null).
  Future<void> _clear() async {
    final updated = widget.category.copyWith(largeTxnThresholdMinor: null);
    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.update(updated);

    _controller.clear();
    if (mounted) setState(() => _isEditing = false);
  }

  void _cancelEdit() => setState(() => _isEditing = false);
}

// ---------------------------------------------------------------------------
// Inline edit row
// ---------------------------------------------------------------------------

/// Inline threshold amount edit row.
class _InlineEditRow extends StatelessWidget {
  const _InlineEditRow({
    required this.controller,
    required this.currencyCode,
    required this.onConfirm,
    required this.onClear,
    required this.onCancel,
  });

  /// Controller for the threshold field.
  final TextEditingController controller;

  /// ISO 4217 home currency code used as field label.
  final String currencyCode;

  /// Called when the user confirms the new value.
  final VoidCallback onConfirm;

  /// Called when the user clears the threshold.
  final VoidCallback onClear;

  /// Called when the user cancels editing.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: currencyCode,
                border: const OutlineInputBorder(),
                suffixText: currencyCode,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Confirm',
            icon: const Icon(Icons.check),
            onPressed: onConfirm,
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
