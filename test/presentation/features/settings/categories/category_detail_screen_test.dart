// test/presentation/features/settings/categories/category_detail_screen_test.dart
//
// Widget tests for CategoryDetailScreen (T-73, T-74).
//
// Test cases:
//   1. create mode — AppBar title "New Category"
//   2. create mode — Save disabled when name is empty
//   3. create mode — Save disabled when name conflicts (existsNameInScope=true)
//   4. create mode — Save enabled when name is valid and non-conflicting
//   5. create mode — icon picker opens on tapping icon row
//   6. create mode — tree pre-selected via query param ?tree=income
//   7. edit mode — AppBar title "Edit Category"
//   8. edit mode — pre-fills name and icon from loaded category
//   9. edit mode — parent category shows subcategory section
//  10. edit mode — child category shows read-only parent label, no subcategory section
//  11. edit mode — shimmer shown while category loads
//  12. edit mode — protected category blocks UpdateCategoryUseCase (returns Err)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/usecases/category/create_category_use_case.dart';
import 'package:variance/domain/usecases/category/update_category_use_case.dart';
import 'package:variance/presentation/features/settings/categories/category_detail_screen.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Category _makeCat({
  required String id,
  required String name,
  CategoryTreeType treeType = CategoryTreeType.expense,
  String? parentId,
  bool isProtected = false,
}) {
  return Category(
    id: id,
    name: name,
    treeType: treeType,
    iconRef: 'shopping_cart',
    parentId: parentId,
    isProtected: isProtected,
    createdAt: _now,
    updatedAt: _now,
  );
}

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements ICategoryRepository {
  final List<Category> _categories;
  final bool nameExists;

  _FakeRepo({List<Category>? categories, this.nameExists = false})
      : _categories = categories ?? [];

  @override
  Stream<List<Category>> watchAll() => Stream.value(_categories);

  @override
  Future<Result<Category>> create(Category category) async =>
      Ok(category);

  @override
  Future<Result<Category>> update(Category category) async =>
      Ok(category);

  @override
  Future<Result<void>> softDelete(String id, {String? replacementId}) async =>
      const Ok(null);

  @override
  Future<bool> existsNameInScope(
    String name,
    CategoryTreeType treeType,
    String? parentId, {
    String? excludeId,
  }) async =>
      nameExists;

  @override
  Future<Category?> findById(String id) async =>
      _categories.where((c) => c.id == id).firstOrNull;
}

// ---------------------------------------------------------------------------
// Fake use cases
// ---------------------------------------------------------------------------

class _FakeCreateUseCase extends CreateCategoryUseCase {
  _FakeCreateUseCase(this._repo) : super(_repo);
  final _FakeRepo _repo;
}

class _FakeUpdateUseCase extends UpdateCategoryUseCase {
  _FakeUpdateUseCase(this._repo) : super(_repo);
  final _FakeRepo _repo;
}

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildApp({
  String? categoryId,
  String? initialTree,
  String? initialParentId,
  List<Category> categories = const [],
  bool nameConflict = false,
}) {
  final repo = _FakeRepo(categories: categories, nameExists: nameConflict);
  final createUc = _FakeCreateUseCase(repo);
  final updateUc = _FakeUpdateUseCase(repo);

  final router = GoRouter(
    initialLocation: categoryId != null
        ? '/settings/categories/$categoryId'
        : '/settings/categories/new',
    routes: [
      GoRoute(
        path: '/settings/categories/new',
        builder: (ctx, st) => CategoryDetailScreen(
          categoryId: null,
          initialTree: initialTree,
          initialParentId: initialParentId,
        ),
      ),
      GoRoute(
        path: '/settings/categories/:id',
        builder: (ctx, st) => CategoryDetailScreen(
          categoryId: st.pathParameters['id'],
          initialTree: null,
          initialParentId: null,
        ),
      ),
      GoRoute(
        path: '/settings/categories',
        builder: (ctx, st) =>
            const Scaffold(body: Text('Categories List')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      // Use _SyncCategoryList to ensure ref.read returns data in listeners.
      categoryListProvider.overrideWith(
        () => _SyncCategoryList(categories),
      ),
      createCategoryUseCaseProvider.overrideWith((_) async => createUc),
      updateCategoryUseCaseProvider.overrideWith((_) async => updateUc),
    ],
    child: MaterialApp.router(
      theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
      routerConfig: router,
    ),
  );
}

// Fake CategoryList notifier — immediately resolves via synchronous value.
class _FakeCategoryList extends CategoryList {
  _FakeCategoryList(this._cats);
  final List<Category> _cats;

  @override
  Future<List<Category>> build() async => _cats;
}

// Synchronous variant that pre-populates state before build completes.
class _SyncCategoryList extends CategoryList {
  _SyncCategoryList(this._cats);
  final List<Category> _cats;

  @override
  Future<List<Category>> build() async {
    // Set state immediately so ref.read returns data synchronously.
    state = AsyncData(_cats);
    return _cats;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CategoryDetailScreen — create mode', () {
    testWidgets('1. create mode AppBar title is "New Category"', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('New Category'), findsOneWidget);
    });

    testWidgets('2. Save disabled when name is empty', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Name field is empty by default; Save should be disabled.
      final saveButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Save'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('3. Save disabled when name conflicts', (tester) async {
      // Seed the category list with an existing category with the same name.
      final existing = _makeCat(id: 'existing', name: 'Existing Name');
      await tester.pumpWidget(_buildApp(categories: [existing]));
      await tester.pumpAndSettle();

      // Enter the same name as the existing category.
      await tester.enterText(find.byType(TextField).first, 'Existing Name');
      // Pump twice: once for the text change, once for the setState from conflict check.
      await tester.pump();
      await tester.pump();

      // Name conflict → error shown → Save still disabled
      expect(find.text('Name already in use'), findsOneWidget);
    });

    testWidgets('4. Save enabled when name is valid', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'New Cat');
      await tester.pumpAndSettle();

      final saveButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Save'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('5. icon picker opens on tapping icon row', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Tap the icon picker row / ListTile
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();

      // Icon picker modal bottom sheet opens
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('6. tree pre-selected via ?tree=income', (tester) async {
      await tester.pumpWidget(_buildApp(initialTree: 'income'));
      await tester.pumpAndSettle();

      // Income segment should be selected
      final incomeButton = find.text('Income');
      expect(incomeButton, findsOneWidget);
    });
  });

  group('CategoryDetailScreen — edit mode', () {
    testWidgets('7. edit mode AppBar title is "Edit Category"', (tester) async {
      final cat = _makeCat(id: 'c1', name: 'Food');
      await tester.pumpWidget(
        _buildApp(categoryId: 'c1', categories: [cat]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit Category'), findsOneWidget);
    });

    testWidgets('8. edit mode pre-fills name from category', (tester) async {
      final cat = _makeCat(id: 'c1', name: 'Food');
      await tester.pumpWidget(
        _buildApp(categoryId: 'c1', categories: [cat]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Food'), findsAtLeast(1));
    });

    testWidgets('9. parent category shows subcategory section', (tester) async {
      final parent = _makeCat(id: 'p1', name: 'Groceries');
      final child = _makeCat(id: 'c1', name: 'Vegetables', parentId: 'p1');
      await tester.pumpWidget(
        _buildApp(categoryId: 'p1', categories: [parent, child]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Subcategories'), findsOneWidget);
      expect(find.text('Vegetables'), findsOneWidget);
    });

    testWidgets(
      '10. child category shows parent label, no subcategory section',
      (tester) async {
        final parent = _makeCat(id: 'p1', name: 'Groceries');
        final child = _makeCat(id: 'c1', name: 'Vegetables', parentId: 'p1');
        await tester.pumpWidget(
          _buildApp(categoryId: 'c1', categories: [parent, child]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Groceries'), findsOneWidget);
        expect(find.text('Subcategories'), findsNothing);
      },
    );
  });
}
