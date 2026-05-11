// test/unit/domain/usecases/category_use_cases_test.dart
//
// Unit tests for category use cases with a fake repository.
//
// Test cases:
//   CreateCategoryUseCase:
//     1. valid root category → Ok(Category)
//     2. valid child category → Ok(Category)
//     3. empty name → Err(ValidationFailure)
//     4. whitespace-only name → Err(ValidationFailure)
//     5. three-level depth (child of a child) → Err(ValidationFailure)
//     6. parent not found → Err(NotFoundFailure)
//     7. duplicate name in scope (active) → Err(ValidationFailure)
//     8. duplicate name in scope (soft-deleted) → Err(ValidationFailure)
//     9. same name in different tree → Ok(Category)
//
//   UpdateCategoryUseCase:
//    10. valid rename → Ok(Category)
//    11. empty name → Err(ValidationFailure)
//    12. protected category → Err(BusinessRuleFailure)
//    13. rename to conflicting name → Err(ValidationFailure)
//    14. rename to own current name → Ok(Category) (self-exclude works)
//    15. category not found → Err(NotFoundFailure)
//
//   DeleteCategoryUseCase:
//    16. leaf category deleted successfully → Ok(void)
//    17. protected category → Err(BusinessRuleFailure)
//    18. parent with children (propagated from repo) → Err(BusinessRuleFailure)
//    19. non-existent category → Err(NotFoundFailure)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/usecases/category/create_category_use_case.dart';
import 'package:variance/domain/usecases/category/delete_category_use_case.dart';
import 'package:variance/domain/usecases/category/update_category_use_case.dart';

// ---------------------------------------------------------------------------
// FakeCategoryRepository
// ---------------------------------------------------------------------------

/// In-memory fake [ICategoryRepository] for use-case testing.
class FakeCategoryRepository implements ICategoryRepository {
  final _categories = <String, Category>{};

  // Simulate child count per parent (set in tests).
  final _childCounts = <String, int>{};

  void seed(Category category) => _categories[category.id] = category;
  void setChildCount(String parentId, int count) =>
      _childCounts[parentId] = count;

  @override
  Stream<List<Category>> watchAll() => Stream.value(
        _categories.values.where((c) => !c.isDeleted).toList(),
      );

  @override
  Future<Result<Category>> create(Category category) async {
    _categories[category.id] = category;
    return Ok(category);
  }

  @override
  Future<Result<Category>> update(Category category) async {
    if (!_categories.containsKey(category.id)) {
      return Err(NotFoundFailure('Category ${category.id} not found.'));
    }
    _categories[category.id] = category;
    return Ok(category);
  }

  @override
  Future<Result<void>> softDelete(String id, {String? replacementId}) async {
    final existing = _categories[id];
    if (existing == null) {
      return Err(NotFoundFailure('Category $id not found.'));
    }
    final childCount = _childCounts[id] ?? 0;
    if (childCount > 0) {
      return const Err(
        BusinessRuleFailure('Cannot delete a category with subcategories.'),
      );
    }
    _categories[id] = existing.copyWith(isDeleted: true);
    return const Ok(null);
  }

  @override
  Future<bool> existsNameInScope(
    String name,
    CategoryTreeType treeType,
    String? parentId, {
    String? excludeId,
  }) async {
    return _categories.values.any(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() &&
          c.treeType == treeType &&
          c.parentId == parentId &&
          c.id != excludeId,
    );
  }

  @override
  Future<Category?> findById(String id) async => _categories[id];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const kNow = 1735689600;

Category makeCategory({
  String id = 'cat-1',
  String? parentId,
  CategoryTreeType treeType = CategoryTreeType.expense,
  String name = 'Food',
  String iconRef = 'category',
  bool isDeleted = false,
  bool isProtected = false,
}) {
  return Category(
    id: id,
    parentId: parentId,
    treeType: treeType,
    name: name,
    iconRef: iconRef,
    isDeleted: isDeleted,
    isProtected: isProtected,
    createdAt: kNow,
    updatedAt: kNow,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeCategoryRepository fakeRepo;
  late CreateCategoryUseCase createUseCase;
  late UpdateCategoryUseCase updateUseCase;
  late DeleteCategoryUseCase deleteUseCase;

  setUp(() {
    fakeRepo = FakeCategoryRepository();
    createUseCase = CreateCategoryUseCase(fakeRepo);
    updateUseCase = UpdateCategoryUseCase(fakeRepo);
    deleteUseCase = DeleteCategoryUseCase(fakeRepo);
  });

  // -----------------------------------------------------------------------
  // CreateCategoryUseCase
  // -----------------------------------------------------------------------

  group('CreateCategoryUseCase', () {
    test('1. valid root category returns Ok(Category)', () async {
      final result = await createUseCase(makeCategory(id: 'c1', name: 'Food'));
      expect(result, isA<Ok<Category>>());
    });

    test('2. valid child category returns Ok(Category)', () async {
      // Seed the parent (root) category.
      fakeRepo.seed(makeCategory(id: 'parent', name: 'Food'));
      final child = makeCategory(
        id: 'child',
        parentId: 'parent',
        name: 'Lunch',
      );
      final result = await createUseCase(child);
      expect(result, isA<Ok<Category>>());
    });

    test('3. empty name returns Err(ValidationFailure)', () async {
      final result = await createUseCase(makeCategory(name: ''));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('4. whitespace-only name returns Err(ValidationFailure)', () async {
      final result = await createUseCase(makeCategory(name: '   '));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test(
        '5. child of a child (three-level depth) returns Err(ValidationFailure)',
        () async {
      // grandparent → child with parentId set.
      final grandParent = makeCategory(id: 'gp', name: 'Root');
      final parent = makeCategory(
        id: 'parent',
        parentId: 'gp', // parent already has a parent → depth = 2
        name: 'SubRoot',
      );
      fakeRepo.seed(grandParent);
      fakeRepo.seed(parent);
      // Trying to add child of `parent` which is itself a child.
      final grandChild = makeCategory(
        id: 'gc',
        parentId: 'parent',
        name: 'Leaf',
      );
      final result = await createUseCase(grandChild);
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('6. parent not found returns Err(NotFoundFailure)', () async {
      final child = makeCategory(
        id: 'c1',
        parentId: 'non-existent-parent',
        name: 'Lunch',
      );
      final result = await createUseCase(child);
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });

    test('7. duplicate active name returns Err(ValidationFailure)', () async {
      fakeRepo.seed(makeCategory(id: 'existing', name: 'Food'));
      final result = await createUseCase(makeCategory(id: 'new', name: 'Food'));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('8. duplicate soft-deleted name returns Err(ValidationFailure)',
        () async {
      fakeRepo.seed(makeCategory(id: 'deleted', name: 'Food', isDeleted: true));
      // FakeCategoryRepository includes soft-deleted in existsNameInScope.
      final result = await createUseCase(makeCategory(id: 'new', name: 'Food'));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('9. same name in different tree returns Ok(Category)', () async {
      fakeRepo.seed(
        makeCategory(
          id: 'income-cat',
          treeType: CategoryTreeType.income,
          name: 'Other',
        ),
      );
      // Same name but expense tree → should succeed.
      final result = await createUseCase(
        makeCategory(
          id: 'expense-cat',
          treeType: CategoryTreeType.expense,
          name: 'Other',
        ),
      );
      expect(result, isA<Ok<Category>>());
    });
  });

  // -----------------------------------------------------------------------
  // UpdateCategoryUseCase
  // -----------------------------------------------------------------------

  group('UpdateCategoryUseCase', () {
    test('10. valid rename returns Ok(Category)', () async {
      fakeRepo.seed(makeCategory(id: 'c1', name: 'Food'));
      final result =
          await updateUseCase(makeCategory(id: 'c1', name: 'Groceries'));
      expect(result, isA<Ok<Category>>());
      expect((result as Ok<Category>).value.name, equals('Groceries'));
    });

    test('11. empty name returns Err(ValidationFailure)', () async {
      fakeRepo.seed(makeCategory(id: 'c1', name: 'Food'));
      final result = await updateUseCase(makeCategory(id: 'c1', name: ''));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('12. protected category returns Err(BusinessRuleFailure)', () async {
      fakeRepo.seed(
        makeCategory(id: 'c1', name: 'Balance Adjustment', isProtected: true),
      );
      final result = await updateUseCase(
        makeCategory(id: 'c1', name: 'New Name', isProtected: true),
      );
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<BusinessRuleFailure>());
    });

    test('13. rename to conflicting name returns Err(ValidationFailure)',
        () async {
      fakeRepo.seed(makeCategory(id: 'c1', name: 'Food'));
      fakeRepo.seed(makeCategory(id: 'c2', name: 'Transport'));
      // Try to rename c1 to 'Transport' which is taken by c2.
      final result =
          await updateUseCase(makeCategory(id: 'c1', name: 'Transport'));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('14. rename to own current name succeeds (self-exclude)', () async {
      fakeRepo.seed(makeCategory(id: 'c1', name: 'Food'));
      // Same name, same id → excludeId should prevent self-collision.
      final result = await updateUseCase(makeCategory(id: 'c1', name: 'Food'));
      expect(result, isA<Ok<Category>>());
    });

    test('15. category not found returns Err(NotFoundFailure)', () async {
      final result = await updateUseCase(makeCategory(id: 'missing'));
      expect(result, isA<Err<Category>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });
  });

  // -----------------------------------------------------------------------
  // DeleteCategoryUseCase
  // -----------------------------------------------------------------------

  group('DeleteCategoryUseCase', () {
    test('16. leaf category deleted successfully', () async {
      fakeRepo.seed(makeCategory(id: 'c1', name: 'Food'));
      final result = await deleteUseCase('c1');
      expect(result, isA<Ok<void>>());
    });

    test('17. protected category returns Err(BusinessRuleFailure)', () async {
      fakeRepo.seed(
        makeCategory(
          id: 'c1',
          name: 'Balance Adjustment',
          isProtected: true,
        ),
      );
      final result = await deleteUseCase('c1');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<BusinessRuleFailure>());
    });

    test('18. parent with children returns Err(BusinessRuleFailure)', () async {
      fakeRepo.seed(makeCategory(id: 'parent', name: 'Food'));
      fakeRepo.setChildCount('parent', 2);
      final result = await deleteUseCase('parent');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<BusinessRuleFailure>());
    });

    test('19. non-existent category returns Err(NotFoundFailure)', () async {
      final result = await deleteUseCase('does-not-exist');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });
  });
}
