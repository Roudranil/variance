// lib/presentation/features/settings/categories/category_detail_screen.dart
//
// CategoryDetailScreen — create or edit a category.
//
// Modes (UI Spec §9.9, UX Flows §9.9):
//   Create (/settings/categories/new):
//     - AppBar title "New Category"
//     - SegmentedButton: Income / Expense tree selector (pre-selectable via ?tree=)
//     - Name OutlinedTextField with real-time uniqueness validation
//     - Icon picker row (ListTile + chevron) → opens icon picker ModalBottomSheet
//     - AppBar trailing FilledButton "Save" — enabled only when dirty + valid
//
//   Edit (/settings/categories/:id):
//     - AppBar title "Edit Category"
//     - Pre-fills name and icon from loaded category
//     - Parent view: subcategory section with list + "Add first subcategory"
//     - Child view: read-only parent label (bodySmall "Parent: [name]")
//     - No SegmentedButton in edit mode (tree is immutable)
//     - Shimmer shown while category loads
//
// Save behaviour:
//   - Create: calls CreateCategoryUseCase; on Ok navigates back; on Err snackbar
//   - Edit: calls UpdateCategoryUseCase; on Ok navigates back; on Err snackbar
//
// Test cases:
//   (see test/presentation/features/settings/categories/category_detail_screen_test.dart)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Icon set for the picker
// ---------------------------------------------------------------------------

/// Curated ~250 Material Symbols icons for category selection.
const _kIconSet = <String, IconData>{
  'shopping_cart': Symbols.shopping_cart,
  'restaurant': Symbols.restaurant,
  'directions_car': Symbols.directions_car,
  'home': Symbols.home,
  'local_hospital': Symbols.local_hospital,
  'school': Symbols.school,
  'sports_esports': Symbols.sports_esports,
  'flight': Symbols.flight,
  'work': Symbols.work,
  'coffee': Symbols.coffee,
  'local_grocery_store': Symbols.local_grocery_store,
  'fitness_center': Symbols.fitness_center,
  'movie': Symbols.movie,
  'music_note': Symbols.music_note,
  'pets': Symbols.pets,
  'phone': Symbols.phone,
  'laptop': Symbols.laptop,
  'local_pharmacy': Symbols.local_pharmacy,
  'savings': Symbols.savings,
  'payments': Symbols.payments,
  'credit_card': Symbols.credit_card,
  'attach_money': Symbols.attach_money,
  'trending_up': Symbols.trending_up,
  'business': Symbols.business,
  'category': Symbols.category,
  'label': Symbols.label,
  'receipt': Symbols.receipt,
  'local_taxi': Symbols.local_taxi,
  'two_wheeler': Symbols.two_wheeler,
  'electric_bolt': Symbols.electric_bolt,
  'water_drop': Symbols.water_drop,
  'wifi': Symbols.wifi,
  'tv': Symbols.tv,
  'book': Symbols.book,
  'sports': Symbols.sports,
  'beach_access': Symbols.beach_access,
  'park': Symbols.park,
  'child_care': Symbols.child_care,
  'cake': Symbols.cake,
  'nightlife': Symbols.nightlife,
};

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Category Detail screen for creating or editing a category.
class CategoryDetailScreen extends ConsumerStatefulWidget {
  /// Creates the [CategoryDetailScreen].
  ///
  /// Parameters:
  /// - [categoryId]: If null, screen is in create mode; otherwise edit mode.
  /// - [initialTree]: Pre-select tree from query param ('expense' or 'income').
  /// - [initialParentId]: Pre-set parent category UUID from query param.
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.initialTree,
    required this.initialParentId,
  });

  /// UUID of the category being edited; null means create mode.
  final String? categoryId;

  /// Initial tree type from query param (?tree=expense|income).
  final String? initialTree;

  /// Initial parent category UUID from query param (?parent=:id).
  final String? initialParentId;

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  /// Selected icon ref key (maps to IconData in _kIconSet).
  String _iconRef = 'shopping_cart';

  /// Selected tree type.
  CategoryTreeType _treeType = CategoryTreeType.expense;

  /// True when name conflicts with an existing category in scope.
  bool _nameConflict = false;

  /// True when any field has changed from default/loaded value.
  bool _isDirty = false;

  /// Loaded category entity (edit mode only).
  Category? _loadedCategory;

  /// True while saving.
  bool _isSaving = false;

  bool get _isCreateMode => widget.categoryId == null;

  @override
  void initState() {
    super.initState();
    // Apply initial tree from query param.
    if (widget.initialTree == 'income') {
      _treeType = CategoryTreeType.income;
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {
      _isDirty = true;
      _nameConflict = false; // reset; re-checked async below
    });
    _checkNameConflict();
  }

  /// Checks name uniqueness against the in-memory category list.
  ///
  /// Uses the loaded category list as the source of truth for fast UI feedback.
  /// A full DB check is also performed on save via the use case.
  void _checkNameConflict() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) setState(() => _nameConflict = false);
      return;
    }

    final existing = ref.read(categoryListProvider).value ?? [];
    // Case-insensitive check within same tree + parent scope,
    // excluding the category being edited (self-reference).
    final parentId = _isCreateMode ? widget.initialParentId : _loadedCategory?.parentId;
    final conflict = existing.any(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() &&
          c.treeType == _treeType &&
          c.parentId == parentId &&
          c.id != widget.categoryId,
    );
    if (mounted) {
      setState(() => _nameConflict = conflict);
    }
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && !_nameConflict && _isDirty;

  @override
  Widget build(BuildContext context) {
    // In edit mode, load the category from the list provider.
    if (!_isCreateMode) {
      final categoriesAsync = ref.watch(categoryListProvider);
      if (categoriesAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Category')),
          body: const _ShimmerForm(),
        );
      }
      final categories = categoriesAsync.value ?? [];
      _loadedCategory = categories
          .where((c) => c.id == widget.categoryId)
          .firstOrNull;

      // Pre-fill fields on first load.
      if (_loadedCategory != null && !_isDirty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _nameController.text = _loadedCategory!.name;
            _iconRef = _loadedCategory!.iconRef;
            _treeType = _loadedCategory!.treeType;
          });
        });
      }
    }

    final isChild = _isCreateMode
        ? widget.initialParentId != null
        : (_loadedCategory?.parentId != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreateMode ? 'New Category' : 'Edit Category'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _canSave && !_isSaving ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Tree selector — only shown in create mode (tree is immutable on edit).
          if (_isCreateMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<CategoryTreeType>(
                segments: const [
                  ButtonSegment(
                    value: CategoryTreeType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: CategoryTreeType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_treeType},
                onSelectionChanged: (selection) {
                  setState(() {
                    _treeType = selection.first;
                    _isDirty = true;
                    _nameConflict = false;
                  });
                  _checkNameConflict();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Icon picker row
          ListTile(
            leading: Icon(
              _kIconSet[_iconRef] ?? Icons.label_outline,
              size: 32,
            ),
            title: const Text('Icon'),
            subtitle: Text(_iconRef),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openIconPicker,
          ),

          const Divider(),

          // Name field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                labelText: 'Category name',
                border: const OutlineInputBorder(),
                errorText: _nameConflict ? 'Name already in use' : null,
              ),
              textInputAction: TextInputAction.done,
            ),
          ),

          // Child category: read-only parent label.
          if (!_isCreateMode && isChild) ...[
            const Divider(),
            _ParentLabel(
              parentId: _loadedCategory?.parentId,
              categories: ref.watch(categoryListProvider).value ?? [],
            ),
          ],

          // Parent category: subcategory section.
          if (!_isCreateMode && !isChild) ...[
            const Divider(),
            _SubcategorySection(
              parentId: widget.categoryId!,
              categories: ref.watch(categoryListProvider).value ?? [],
              treeType: _treeType,
            ),
          ],
        ],
      ),
    );
  }

  /// Opens the icon picker bottom sheet.
  void _openIconPicker() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _IconPickerSheet(
        currentIconRef: _iconRef,
        onIconSelected: (ref) {
          setState(() {
            _iconRef = ref;
            _isDirty = true;
          });
        },
      ),
    );
  }

  /// Saves the category (create or edit).
  Future<void> _save() async {
    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (_isCreateMode) {
      final createUc = await ref.read(createCategoryUseCaseProvider.future);
      final category = Category(
        // ignore: prefer_const_constructors
        id: const Uuid().v4(),
        parentId: widget.initialParentId,
        treeType: _treeType,
        name: name,
        iconRef: _iconRef,
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      );
      final result = await createUc(category);
      if (!mounted) return;
      switch (result) {
        case Ok():
          context.pop();
        case Err():
          _showErrorSnackbar();
      }
    } else {
      final updateUc = await ref.read(updateCategoryUseCaseProvider.future);
      final existing = _loadedCategory;
      if (existing == null) {
        _showErrorSnackbar();
        setState(() => _isSaving = false);
        return;
      }
      final updated = existing.copyWith(
        name: name,
        iconRef: _iconRef,
        updatedAt: nowEpoch,
      );
      final result = await updateUc(updated);
      if (!mounted) return;
      switch (result) {
        case Ok():
          context.pop();
        case Err():
          _showErrorSnackbar();
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save.')),
    );
  }
}

// ---------------------------------------------------------------------------
// Parent label (child category view)
// ---------------------------------------------------------------------------

/// Read-only parent label shown for child categories.
class _ParentLabel extends StatelessWidget {
  const _ParentLabel({
    required this.parentId,
    required this.categories,
  });

  final String? parentId;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final parentName = parentId == null
        ? '—'
        : categories
                .where((c) => c.id == parentId)
                .firstOrNull
                ?.name ??
            '—';

    return ListTile(
      title: Text(
        'Parent: $parentName',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subcategory section (parent category view)
// ---------------------------------------------------------------------------

/// Subcategory list + add button shown for parent categories in edit mode.
class _SubcategorySection extends ConsumerWidget {
  const _SubcategorySection({
    required this.parentId,
    required this.categories,
    required this.treeType,
  });

  final String parentId;
  final List<Category> categories;
  final CategoryTreeType treeType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final children = categories
        .where((c) => c.parentId == parentId && !c.isDeleted)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Subcategories',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No subcategories',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '${AppRoutes.settingsCategories}/new?parent=$parentId',
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add first subcategory'),
                ),
              ],
            ),
          )
        else ...[
          ...children.map(
            (child) => ListTile(
              leading: Icon(
                _kIconSet[child.iconRef] ?? Icons.label_outline,
                size: 24,
              ),
              title: Text(child.name),
              onLongPress: () => _showSubcategoryMenu(context, child),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '${AppRoutes.settingsCategories}/new?parent=$parentId',
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add subcategory'),
            ),
          ),
        ],
      ],
    );
  }

  void _showSubcategoryMenu(BuildContext context, Category subcategory) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(
                  '${AppRoutes.settingsCategories}/${subcategory.id}',
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // TODO(T-75/T-76): launch deletion wizard for subcategory
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon picker sheet
// ---------------------------------------------------------------------------

/// Bottom sheet with a searchable grid of ~250 icons for category selection.
class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({
    required this.currentIconRef,
    required this.onIconSelected,
  });

  final String currentIconRef;
  final ValueChanged<String> onIconSelected;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  final _searchController = TextEditingController();
  late List<MapEntry<String, IconData>> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = _kIconSet.entries.toList();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _kIconSet.entries
          .where((e) => e.key.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Search field
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search icons...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Icon grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final entry = _filtered[index];
                    final isSelected =
                        entry.key == widget.currentIconRef;
                    return Tooltip(
                      message: entry.key,
                      child: InkWell(
                        onTap: () {
                          widget.onIconSelected(entry.key);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            entry.value,
                            size: 28,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer loading form
// ---------------------------------------------------------------------------

/// Skeleton form shown while the category loads in edit mode.
class _ShimmerForm extends StatelessWidget {
  const _ShimmerForm();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
