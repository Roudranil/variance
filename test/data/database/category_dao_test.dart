// test/data/database/category_dao_test.dart
//
// Unit tests for CategoryDao using an in-memory Drift database.
//
// Test cases:
//   1. watchAllCategories — emits inserted non-deleted categories
//   2. watchAllCategories — excludes soft-deleted categories
//   3. watchByTreeType — emits only income or expense categories
//   4. insertCategory — row queryable via findById
//   5. updateCategory — updated fields reflected in watchAllCategories stream
//   6. updateCategory — returns false for non-existent id
//   7. softDeleteCategory — category disappears from watchAllCategories
//   8. countChildren — returns 0 for leaf category
//   9. countChildren — returns N for parent with N non-deleted children
//  10. existsNameInScope — true for active root category (same tree, null parent)
//  11. existsNameInScope — true for soft-deleted row (uniqueness includes deleted)
//  12. existsNameInScope — false for same name in different tree
//  13. existsNameInScope — excludeId skips the specified row
//  14. existsNameInScope — case-insensitive comparison
//  15. findById — returns matching row
//  16. findById — returns null for missing id

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/category_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CategoryDao dao;

  const kNow = 1735689600;

  // Helper: create a minimal CategoriesCompanion.
  CategoriesCompanion makeCompanion({
    required String id,
    String? parentId,
    String treeType = 'expense',
    required String name,
    String iconRef = 'category',
    bool isDeleted = false,
    bool isProtected = false,
  }) {
    return CategoriesCompanion(
      id: Value(id),
      parentId: Value(parentId),
      treeType: Value(treeType),
      name: Value(name),
      iconRef: Value(iconRef),
      isDeleted: Value(isDeleted),
      deletedAt: const Value(null),
      isProtected: Value(isProtected),
      sortOrder: const Value(null),
      createdAt: const Value(kNow),
      updatedAt: const Value(kNow),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.categoryDao;
  });

  tearDown(() => db.close());

  // -----------------------------------------------------------------------
  // watchAllCategories
  // -----------------------------------------------------------------------

  group('watchAllCategories', () {
    test('1. emits inserted non-deleted categories', () async {
      await dao.insertCategory(
        makeCompanion(id: 'c1', name: 'Food'),
      );
      final categories = await dao.watchAllCategories().first;
      expect(categories.map((c) => c.id), contains('c1'));
    });

    test('2. excludes soft-deleted categories', () async {
      await dao.insertCategory(
        makeCompanion(id: 'c1', name: 'Food'),
      );
      await dao.softDeleteCategory('c1', kNow + 1);
      final categories = await dao.watchAllCategories().first;
      expect(categories.map((c) => c.id), isNot(contains('c1')));
    });
  });

  // -----------------------------------------------------------------------
  // watchByTreeType
  // -----------------------------------------------------------------------

  group('watchByTreeType', () {
    test('3. emits only categories for the given tree type', () async {
      // Use names not in the seed data, and unique ids.
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c-inc',
          treeType: 'income',
          name: 'TestIncomeCat',
        ),
      );
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c-exp',
          treeType: 'expense',
          name: 'TestExpenseCat',
        ),
      );
      // watchByTreeType('income') will include seeded income categories +
      // our one new income category. Verify our specific row is there and
      // no expense rows are included.
      final incomeList = await dao.watchByTreeType('income').first;
      expect(incomeList.map((c) => c.id), contains('test-c-inc'));
      expect(incomeList.map((c) => c.id), isNot(contains('test-c-exp')));
      expect(incomeList.every((c) => c.treeType == 'income'), isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // insertCategory / findById
  // -----------------------------------------------------------------------

  group('insertCategory / findById', () {
    test('4. inserted row is queryable via findById', () async {
      await dao.insertCategory(
        makeCompanion(id: 'c1', name: 'Food'),
      );
      final row = await dao.findById('c1');
      expect(row, isNotNull);
      expect(row!.name, equals('Food'));
    });

    test('16. findById returns null for missing id', () async {
      final row = await dao.findById('does-not-exist');
      expect(row, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // updateCategory
  // -----------------------------------------------------------------------

  group('updateCategory', () {
    test('5. updated name reflected in stream', () async {
      await dao.insertCategory(
        makeCompanion(id: 'c1', name: 'Food'),
      );
      await dao.updateCategory(
        CategoriesCompanion(
          id: const Value('c1'),
          parentId: const Value(null),
          treeType: const Value('expense'),
          name: const Value('Groceries'),
          iconRef: const Value('category'),
          isDeleted: const Value(false),
          deletedAt: const Value(null),
          isProtected: const Value(false),
          sortOrder: const Value(null),
          createdAt: const Value(kNow),
          updatedAt: const Value(kNow),
        ),
      );
      final categories = await dao.watchAllCategories().first;
      final updated = categories.firstWhere((c) => c.id == 'c1');
      expect(updated.name, equals('Groceries'));
    });

    test('6. updateCategory returns false for non-existent id', () async {
      final result = await dao.updateCategory(
        CategoriesCompanion(
          id: const Value('non-existent'),
          parentId: const Value(null),
          treeType: const Value('expense'),
          name: const Value('X'),
          iconRef: const Value('category'),
          isDeleted: const Value(false),
          deletedAt: const Value(null),
          isProtected: const Value(false),
          sortOrder: const Value(null),
          createdAt: const Value(kNow),
          updatedAt: const Value(kNow),
        ),
      );
      expect(result, isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // softDeleteCategory
  // -----------------------------------------------------------------------

  group('softDeleteCategory', () {
    test('7. soft-deleted category disappears from watchAllCategories',
        () async {
      await dao.insertCategory(makeCompanion(id: 'c1', name: 'Food'));
      await dao.softDeleteCategory('c1', kNow + 10);
      final list = await dao.watchAllCategories().first;
      expect(list.map((c) => c.id), isNot(contains('c1')));
    });
  });

  // -----------------------------------------------------------------------
  // countChildren
  // -----------------------------------------------------------------------

  group('countChildren', () {
    test('8. returns 0 for leaf category with no children', () async {
      await dao.insertCategory(makeCompanion(id: 'parent', name: 'Food'));
      final count = await dao.countChildren('parent');
      expect(count, equals(0));
    });

    test('9. returns N for parent with N non-deleted children', () async {
      await dao.insertCategory(
        makeCompanion(id: 'parent', name: 'Food'),
      );
      await dao.insertCategory(
        makeCompanion(
          id: 'child-1',
          parentId: 'parent',
          name: 'Lunch',
        ),
      );
      await dao.insertCategory(
        makeCompanion(
          id: 'child-2',
          parentId: 'parent',
          name: 'Dinner',
        ),
      );
      // Soft-delete one child — should not be counted.
      await dao.softDeleteCategory('child-2', kNow + 1);

      final count = await dao.countChildren('parent');
      expect(count, equals(1));
    });
  });

  // -----------------------------------------------------------------------
  // existsNameInScope
  // -----------------------------------------------------------------------

  group('existsNameInScope', () {
    // Use unique names not in the seed data to avoid false positives.
    const kTestName = 'TestUniqueCategoryXYZ';

    test('10. true for active root category in same tree', () async {
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c1',
          treeType: 'expense',
          name: kTestName,
        ),
      );
      final exists = await dao.existsNameInScope(kTestName, 'expense', null);
      expect(exists, isTrue);
    });

    test('11. true for soft-deleted row (uniqueness includes deleted)',
        () async {
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c1',
          treeType: 'expense',
          name: kTestName,
        ),
      );
      await dao.softDeleteCategory('test-c1', kNow + 1);
      // Even after soft-delete, the name should still be "taken".
      final exists = await dao.existsNameInScope(kTestName, 'expense', null);
      expect(exists, isTrue);
    });

    test('12. false for same name in different tree', () async {
      // Insert only in income tree.
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c1',
          treeType: 'income',
          name: kTestName,
        ),
      );
      // Query expense tree — should not find the income row.
      final exists = await dao.existsNameInScope(kTestName, 'expense', null);
      expect(exists, isFalse);
    });

    test('13. excludeId skips the specified row', () async {
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c1',
          treeType: 'expense',
          name: kTestName,
        ),
      );
      final existsWithExclude = await dao.existsNameInScope(
        kTestName,
        'expense',
        null,
        excludeId: 'test-c1',
      );
      expect(existsWithExclude, isFalse);
    });

    test('14. case-insensitive name comparison', () async {
      await dao.insertCategory(
        makeCompanion(
          id: 'test-c1',
          treeType: 'expense',
          name: kTestName,
        ),
      );
      final existsUpper = await dao.existsNameInScope(
        kTestName.toUpperCase(),
        'expense',
        null,
      );
      final existsMixed = await dao.existsNameInScope(
        kTestName.toLowerCase(),
        'expense',
        null,
      );
      expect(existsUpper, isTrue);
      expect(existsMixed, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // findById
  // -----------------------------------------------------------------------

  group('findById', () {
    test('15. returns matching row', () async {
      await dao.insertCategory(
        makeCompanion(id: 'c1', name: 'Food'),
      );
      final row = await dao.findById('c1');
      expect(row, isNotNull);
      expect(row!.id, equals('c1'));
    });
  });
}
