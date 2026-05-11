// lib/presentation/features/settings/categories/category_picker_sheet.dart
//
// CategoryPickerSheet — modal bottom sheet for selecting a category.
//
// Used from transaction entry forms (income/expense) and deletion wizard
// migration target selection.
//
// Layout (UI Spec §8.1, UX Flows §1.1):
//   - DraggableScrollableSheet: initialChildSize=0.6, maxChildSize=0.92
//   - Drag handle (centered 32×4dp)
//   - Sheet title "Select Category — [Income|Expense]"
//   - M3 SearchBar (docked, auto-focused)
//   - Recents chip strip (up to 5 SuggestionChips keyed by tree type)
//   - Two-level list: parent row with chevron (if has children); tap expands
//   - Inline create row (animates in at bottom; icon picker + name + confirm)
//   - Empty state: "No categories yet" + "Create category" TextButton
//   - No-results state: "No results for '[query]'" + "+ Create '[query]'" button
//
// Filtering rules (UI Spec §8.1.3):
//   - is_protected = true rows always hidden.
//   - Soft-deleted rows hidden except when [showDeletedCurrentId] is set.
//   - Inline create creates parent categories only.
//
// Test cases:
//   (see test/presentation/features/settings/categories/protected_category_guard_test.dart)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/features/settings/categories/category_icons.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Recents provider
// ---------------------------------------------------------------------------

/// In-memory recents registry keyed by [CategoryTreeType].
///
/// Persisted only for the app session; a persistent implementation can
/// be added later via SharedPreferences (CAT-02 scope).
final _categoryRecentsNotifier = _CategoryRecentsNotifier();

class _CategoryRecentsNotifier extends ChangeNotifier {
  final _recents = <CategoryTreeType, List<String>>{};

  /// Returns up to 5 most-recently used category IDs for [treeType].
  List<String> forTree(CategoryTreeType treeType) =>
      List.unmodifiable(_recents[treeType] ?? const []);

  /// Records [categoryId] as recently used for [treeType].
  void record(CategoryTreeType treeType, String categoryId) {
    final list = _recents.putIfAbsent(treeType, () => []);
    list
      ..remove(categoryId)
      ..insert(0, categoryId);
    if (list.length > 5) list.removeLast();
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

/// A draggable bottom sheet for selecting a [Category].
///
/// Opens with [showCategoryPickerSheet] or directly as a widget inside
/// [showModalBottomSheet].
class CategoryPickerSheet extends ConsumerStatefulWidget {
  /// Creates the [CategoryPickerSheet].
  ///
  /// Parameters:
  /// - [treeType]: Which tree (income or expense) to show.
  /// - [onSelected]: Called with the selected [Category] when user taps a row.
  /// - [showDeletedCurrentId]: If set, the soft-deleted category with this ID
  ///   is shown at top (for edit mode where transaction already uses it).
  const CategoryPickerSheet({
    super.key,
    required this.treeType,
    required this.onSelected,
    this.showDeletedCurrentId,
  });

  /// The category tree to display.
  final CategoryTreeType treeType;

  /// Callback invoked when a category is selected.
  final ValueChanged<Category> onSelected;

  /// Optional soft-deleted category ID shown in edit context.
  final String? showDeletedCurrentId;

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Expanded parent category IDs.
  final _expanded = <String>{};

  /// Whether the inline create row is visible.
  bool _inlineCreateOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final treeLabel =
        widget.treeType == CategoryTreeType.income ? 'Income' : 'Expense';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Select Category — $treeLabel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search categories...',
                leading: const Icon(Icons.search),
                onChanged: (_) {},
              ),
            ),

            // Content (scrollable)
            Expanded(
              child: categoriesAsync.when(
                loading: () => const _ShimmerPickerSkeleton(),
                error: (_, __) => const Center(
                  child: Text('Failed to load categories.'),
                ),
                data: (allCategories) => _buildContent(
                  context,
                  allCategories,
                  scrollController,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Category> allCategories,
    ScrollController scrollController,
  ) {
    // Filter: hide protected; hide soft-deleted unless it's the current edited one.
    final visible = allCategories.where((c) {
      if (c.isProtected) return false;
      if (c.treeType != widget.treeType) return false;
      if (c.isDeleted && c.id != widget.showDeletedCurrentId) return false;
      return true;
    }).toList();

    // Separate into roots and children.
    final roots = visible
        .where((c) => c.parentId == null)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final children = visible.where((c) => c.parentId != null).toList();

    // Apply search filter.
    final filteredRoots = _query.isEmpty
        ? roots
        : roots.where((c) => c.name.toLowerCase().contains(_query)).toList();
    final filteredChildren = _query.isEmpty
        ? children
        : children
            .where((c) => c.name.toLowerCase().contains(_query))
            .toList();

    // Recents
    final recentIds =
        _categoryRecentsNotifier.forTree(widget.treeType);
    final recentCats = recentIds
        .map(
          (id) => allCategories.where((c) => c.id == id).firstOrNull,
        )
        .whereType<Category>()
        .toList();

    // Empty state
    if (visible.isEmpty) {
      return _EmptyState(
        onCreateTapped: () => setState(() => _inlineCreateOpen = true),
      );
    }

    // No results state
    if (_query.isNotEmpty && filteredRoots.isEmpty && filteredChildren.isEmpty) {
      return _NoResultsState(
        query: _query,
        onCreateTapped: () => setState(() {
          _inlineCreateOpen = true;
        }),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Recents chip strip
        if (recentCats.isNotEmpty && _query.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Recent'),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentCats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = recentCats[index];
                return ActionChip(
                  avatar: Icon(
                    kCategoryIcons[cat.iconRef] ?? Icons.label_outline,
                    size: 16,
                  ),
                  label: Text(cat.name),
                  onPressed: () => _select(cat),
                );
              },
            ),
          ),
        ],

        // Category list
        if (_query.isEmpty) ...[
          for (final root in roots) ...[
            _buildRootRow(context, root, children),
            if (_expanded.contains(root.id))
              ...children
                  .where((c) => c.parentId == root.id)
                  .map((child) => _buildChildRow(context, child)),
          ],
        ] else ...[
          // Search results: show parents then children flat
          for (final root in filteredRoots)
            _buildRootRow(context, root, children),
          for (final child in filteredChildren)
            _buildChildRow(context, child),
        ],

        // Inline create row
        if (_inlineCreateOpen)
          _InlineCreateRow(
            treeType: widget.treeType,
            prefillName: _query,
            onCreated: (cat) {
              _categoryRecentsNotifier.record(widget.treeType, cat.id);
              widget.onSelected(cat);
            },
            onClose: () => setState(() => _inlineCreateOpen = false),
          ),

        // "+ New category" button
        if (!_inlineCreateOpen)
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New category'),
            onTap: () => setState(() => _inlineCreateOpen = true),
          ),
      ],
    );
  }

  Widget _buildRootRow(
    BuildContext context,
    Category root,
    List<Category> allChildren,
  ) {
    final childCount = allChildren.where((c) => c.parentId == root.id).length;
    final isExpanded = _expanded.contains(root.id);

    return ListTile(
      leading: Icon(
        kCategoryIcons[root.iconRef] ?? Icons.label_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(root.name),
      trailing: childCount > 0
          ? Icon(
              isExpanded ? Icons.expand_less : Icons.chevron_right,
              size: 20,
            )
          : null,
      onTap: () {
        if (childCount > 0) {
          setState(() {
            if (isExpanded) {
              _expanded.remove(root.id);
            } else {
              _expanded.add(root.id);
            }
          });
        } else {
          _select(root);
        }
      },
    );
  }

  Widget _buildChildRow(BuildContext context, Category child) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        leading: Icon(
          kCategoryIcons[child.iconRef] ?? Icons.label_outline,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(child.name),
        onTap: () => _select(child),
      ),
    );
  }

  void _select(Category category) {
    _categoryRecentsNotifier.record(widget.treeType, category.id);
    widget.onSelected(category);
    Navigator.of(context).pop();
  }
}

// ---------------------------------------------------------------------------
// Convenience function
// ---------------------------------------------------------------------------

/// Shows the [CategoryPickerSheet] as a modal bottom sheet.
///
/// Returns the selected [Category] or null if dismissed.
Future<Category?> showCategoryPickerSheet(
  BuildContext context, {
  required CategoryTreeType treeType,
  String? showDeletedCurrentId,
}) {
  final completer = Completer<Category?>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CategoryPickerSheet(
      treeType: treeType,
      showDeletedCurrentId: showDeletedCurrentId,
      onSelected: (cat) {
        if (!completer.isCompleted) completer.complete(cat);
      },
    ),
  ).then((_) {
    if (!completer.isCompleted) completer.complete(null);
  });

  return completer.future;
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTapped});
  final VoidCallback onCreateTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No categories yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateTapped,
            child: const Text('Create category'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No-results state
// ---------------------------------------------------------------------------

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query, required this.onCreateTapped});
  final String query;
  final VoidCallback onCreateTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No results for '$query'",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateTapped,
            child: Text('+ Create "$query"'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton
// ---------------------------------------------------------------------------

class _ShimmerPickerSkeleton extends StatelessWidget {
  const _ShimmerPickerSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline create row
// ---------------------------------------------------------------------------

/// Animated row for inline category creation within the picker.
///
/// Creates parent categories only (per UI Spec §8.1.3).
class _InlineCreateRow extends ConsumerStatefulWidget {
  const _InlineCreateRow({
    required this.treeType,
    required this.prefillName,
    required this.onCreated,
    required this.onClose,
  });

  final CategoryTreeType treeType;
  final String prefillName;
  final ValueChanged<Category> onCreated;
  final VoidCallback onClose;

  @override
  ConsumerState<_InlineCreateRow> createState() => _InlineCreateRowState();
}

class _InlineCreateRowState extends ConsumerState<_InlineCreateRow> {
  late final TextEditingController _nameController;
  String _selectedIconRef = 'shopping_cart';
  bool _hasConflict = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
    _nameController.addListener(_checkConflict);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkConflict);
    _nameController.dispose();
    super.dispose();
  }

  void _checkConflict() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _hasConflict = false);
      return;
    }
    final existing = ref.read(categoryListProvider).value ?? [];
    final conflict = existing.any(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() &&
          c.treeType == widget.treeType &&
          c.parentId == null,
    );
    if (mounted) setState(() => _hasConflict = conflict);
  }

  bool get _canConfirm =>
      _nameController.text.trim().isNotEmpty && !_hasConflict;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final createUc = await ref.read(createCategoryUseCaseProvider.future);

    // ignore: prefer_const_constructors
    final category = Category(
      id: const Uuid().v4(),
      treeType: widget.treeType,
      name: name,
      iconRef: _selectedIconRef,
      createdAt: nowEpoch,
      updatedAt: nowEpoch,
    );

    final result = await createUc(category);
    if (!mounted) return;

    switch (result) {
      case Ok():
        widget.onCreated(result.value);
      case Err():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create category.')),
        );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Icon picker button
          InkWell(
            onTap: _openIconPicker,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                kCategoryIcons[_selectedIconRef] ?? Icons.label_outline,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Name field
          Expanded(
            child: TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Category name',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                errorText: _hasConflict ? 'Name already exists' : null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Confirm button
          FilledButton.tonal(
            onPressed: _canConfirm && !_isSaving ? _confirm : null,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, size: 18),
          ),

          // Close button
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _openIconPicker() {
    showModalBottomSheet<String>(
      context: context,
      builder: (_) => _IconSubSheet(
        currentIconRef: _selectedIconRef,
        onSelected: (ref) {
          setState(() => _selectedIconRef = ref);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon sub-sheet (for inline create)
// ---------------------------------------------------------------------------

class _IconSubSheet extends StatefulWidget {
  const _IconSubSheet({
    required this.currentIconRef,
    required this.onSelected,
  });

  final String currentIconRef;
  final ValueChanged<String> onSelected;

  @override
  State<_IconSubSheet> createState() => _IconSubSheetState();
}

class _IconSubSheetState extends State<_IconSubSheet> {
  final _searchController = TextEditingController();
  late List<MapEntry<String, IconData>> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = kCategoryIcons.entries.toList();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = kCategoryIcons.entries.where((e) => e.key.contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search icons...',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final entry = _filtered[index];
                return InkWell(
                  onTap: () {
                    widget.onSelected(entry.key);
                    Navigator.of(context).pop();
                  },
                  child: Icon(entry.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
