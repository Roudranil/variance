// lib/presentation/features/settings/categories/category_management_screen.dart
//
// CategoryManagementScreen — Settings > Categories.
//
// Layout (UI Spec §9.8, UX Flows §9.8):
//   - SmallTopAppBar "Categories"
//   - TabBar: "Expense" / "Income"
//   - TabBarView: per-tree category list
//   - FAB: Add Category → /settings/categories/new?tree=<active tab>
//
// States (UI Spec §9.8.2):
//   loading  → shimmer skeleton × 6 rows
//   error    → M3-styled error banner + "Retry" TextButton
//   empty    → abstract icon + "No categories yet" + FilledButton "Add Category"
//   populated → ListView of ListTile rows (icon + name + child count)
//
// Filtering rules:
//   - is_protected = true rows are always hidden from this screen.
//   - Each tab shows only its tree's categories.
//
// Long-press contextual menu (UI Spec §9.8.1):
//   - Edit → /settings/categories/:id
//   - Delete → disabled (tooltip) when category has children; else launches wizard
//   - Add Child Category → /settings/categories/new?parent=:id
//
// Test cases:
//   (see test/presentation/features/settings/categories/category_management_screen_test.dart)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/category_providers.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Category Management screen (Settings > Categories).
///
/// Shows expense and income category trees in separate tabs.
/// Protected (system) categories are excluded.
class CategoryManagementScreen extends ConsumerStatefulWidget {
  /// Creates the [CategoryManagementScreen].
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
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

  /// Returns the currently active [CategoryTreeType] based on the tab index.
  CategoryTreeType get _activeTree => _tabController.index == 0
      ? CategoryTreeType.expense
      : CategoryTreeType.income;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      // FAB always visible; navigates to new category form with active tree.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final tree = _activeTree.name; // 'expense' or 'income'
          context.push('${AppRoutes.settingsCategories}/new?tree=$tree');
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const _ShimmerListSkeleton(),
        error: (error, _) => _ErrorBanner(
          onRetry: () => ref.invalidate(categoryListProvider),
        ),
        data: (categories) {
          // Filter out system-protected categories globally.
          final visible = categories.where((c) => !c.isProtected).toList();

          if (visible.isEmpty) {
            return const _EmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryTabView(
                allCategories: visible,
                tree: CategoryTreeType.expense,
              ),
              _CategoryTabView(
                allCategories: visible,
                tree: CategoryTreeType.income,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab content
// ---------------------------------------------------------------------------

/// Renders the category list for a single [CategoryTreeType] tab.
class _CategoryTabView extends StatelessWidget {
  const _CategoryTabView({
    required this.allCategories,
    required this.tree,
  });

  final List<Category> allCategories;
  final CategoryTreeType tree;

  @override
  Widget build(BuildContext context) {
    // Only root (parent) categories are shown in the list.
    final roots = allCategories
        .where(
          (c) => c.treeType == tree && c.parentId == null && !c.isDeleted,
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (roots.isEmpty) {
      return const _EmptyState();
    }

    final children = allCategories
        .where(
          (c) => c.treeType == tree && c.parentId != null && !c.isDeleted,
        )
        .toList();

    return ListView.builder(
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final parent = roots[index];
        final childCount =
            children.where((c) => c.parentId == parent.id).length;
        return _CategoryRow(
          category: parent,
          childCount: childCount,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category row
// ---------------------------------------------------------------------------

/// A single category row with long-press contextual menu.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.childCount,
  });

  final Category category;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.label_outline,
        color: colorScheme.primary,
      ),
      title: Text(
        category.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: childCount > 0
          ? Text(
              '$childCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      onLongPress: () => _showContextMenu(context),
    );
  }

  /// Shows the contextual action bottom sheet for this category row.
  void _showContextMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _CategoryContextMenu(
        category: category,
        childCount: childCount,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Context menu
// ---------------------------------------------------------------------------

/// Bottom sheet showing Edit / Delete / Add Child Category actions.
///
/// Delete is disabled (with tooltip) when [childCount] > 0.
class _CategoryContextMenu extends StatelessWidget {
  const _CategoryContextMenu({
    required this.category,
    required this.childCount,
  });

  final Category category;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    final canDelete = childCount == 0;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit action
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.of(context).pop();
              context.push(
                '${AppRoutes.settingsCategories}/${category.id}',
              );
            },
          ),

          // Delete action — disabled with tooltip when children exist
          Tooltip(
            message: canDelete ? '' : 'Remove all subcategories first.',
            child: ListTile(
              enabled: canDelete,
              leading: Icon(
                Icons.delete_outline,
                color: canDelete
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface.withAlpha(80),
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: canDelete
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface.withAlpha(80),
                ),
              ),
              onTap: canDelete
                  ? () {
                      Navigator.of(context).pop();
                      // TODO(T-75/T-76): launch deletion wizard
                    }
                  : null,
            ),
          ),

          // Add Child Category action
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Child Category'),
            onTap: () {
              Navigator.of(context).pop();
              context.push(
                '${AppRoutes.settingsCategories}/new?parent=${category.id}',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

/// Shown when no user categories exist in the active tab.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Abstract geometric icon as illustration
            Icon(
              Icons.category_outlined,
              size: 80,
              color: colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No categories yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first category to start organising transactions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  context.push('${AppRoutes.settingsCategories}/new'),
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton
// ---------------------------------------------------------------------------

/// 6-row skeleton shown while categories are loading.
class _ShimmerListSkeleton extends StatelessWidget {
  const _ShimmerListSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        ...List.generate(
          6,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

/// M3-styled error banner with a Retry action button.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: MaterialBanner(
        backgroundColor: colorScheme.errorContainer,
        content: Text(
          'Could not load categories.',
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        leading: Icon(
          Icons.error_outline,
          color: colorScheme.onErrorContainer,
        ),
        actions: [
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
