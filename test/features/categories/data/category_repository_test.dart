import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/categories/data/category_repository.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepository CRUD', () {
    test('createCategory creates category with linked account', () async {
      final id = await repository.createCategory(
        name: 'Food',
        kind: CategoryKind.expense,
      );

      final category = await repository.getCategory(id);
      expect(category, isNotNull);
      expect(category!.name, 'Food');
      expect(category.kind, CategoryKind.expense);

      // verify linked account was created
      final linkedAccount = await (db.select(
        db.accounts,
      )..where((a) => a.id.equals(category.linkedAccountId))).getSingleOrNull();

      expect(linkedAccount, isNotNull);
      expect(linkedAccount!.nature, AccountNature.expense);
      expect(linkedAccount.isUserVisible, false);
    });

    test('createCategory creates income account for income category', () async {
      final id = await repository.createCategory(
        name: 'Salary',
        kind: CategoryKind.income,
      );

      final category = await repository.getCategory(id);
      final linkedAccount = await (db.select(
        db.accounts,
      )..where((a) => a.id.equals(category!.linkedAccountId))).getSingle();

      expect(linkedAccount.nature, AccountNature.income);
    });

    test('watchAllCategories excludes deleted categories', () async {
      final id = await repository.createCategory(
        name: 'To Delete',
        kind: CategoryKind.expense,
      );

      // verify category appears
      var categories = await repository.watchAllCategories().first;
      expect(categories.any((c) => c.id == id), true);

      // soft delete
      await repository.softDeleteCategory(id);

      // verify category is hidden
      categories = await repository.watchAllCategories().first;
      expect(categories.any((c) => c.id == id), false);
    });

    test('watchCategoriesByKind filters by kind', () async {
      await repository.createCategory(name: 'Food', kind: CategoryKind.expense);

      await repository.createCategory(
        name: 'Salary',
        kind: CategoryKind.income,
      );

      final expenses = await repository
          .watchCategoriesByKind(CategoryKind.expense)
          .first;
      final incomes = await repository
          .watchCategoriesByKind(CategoryKind.income)
          .first;

      expect(expenses.length, 1);
      expect(expenses.first.name, 'Food');
      expect(incomes.length, 1);
      expect(incomes.first.name, 'Salary');
    });
  });

  group('CategoryRepository Hierarchy', () {
    test('createCategory supports parent-child relationship', () async {
      final parentId = await repository.createCategory(
        name: 'Food',
        kind: CategoryKind.expense,
      );

      final childId = await repository.createCategory(
        name: 'Groceries',
        kind: CategoryKind.expense,
        parentId: parentId,
      );

      final child = await repository.getCategory(childId);
      expect(child!.parentId, parentId);
    });
  });

  group('CategoryRepository Update', () {
    test('updateCategory updates name and linked account name', () async {
      final id = await repository.createCategory(
        name: 'Original',
        kind: CategoryKind.expense,
      );

      await repository.updateCategory(id: id, name: 'Updated');

      final category = await repository.getCategory(id);
      expect(category!.name, 'Updated');

      // check linked account name was also updated
      final linkedAccount = await (db.select(
        db.accounts,
      )..where((a) => a.id.equals(category.linkedAccountId))).getSingle();

      expect(linkedAccount.name, 'Updated (expense)');
    });

    test('updateCategory updates icon and color', () async {
      final id = await repository.createCategory(
        name: 'Test',
        kind: CategoryKind.expense,
      );

      await repository.updateCategory(
        id: id,
        iconData: '0xE5D2',
        color: 0xFFFF5722,
      );

      final category = await repository.getCategory(id);
      expect(category!.iconData, '0xE5D2');
      expect(category.color, 0xFFFF5722);
    });
  });

  group('CategoryRepository Soft Delete', () {
    test('softDeleteCategory also soft deletes linked account', () async {
      final id = await repository.createCategory(
        name: 'To Delete',
        kind: CategoryKind.expense,
      );

      final category = await repository.getCategory(id);
      final linkedAccountId = category!.linkedAccountId;

      await repository.softDeleteCategory(id);

      // verify category is deleted
      final deletedCategory = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(id))).getSingle();
      expect(deletedCategory.isDeleted, true);

      // verify linked account is also deleted
      final deletedAccount = await (db.select(
        db.accounts,
      )..where((a) => a.id.equals(linkedAccountId))).getSingle();
      expect(deletedAccount.isDeleted, true);
    });
  });
}
