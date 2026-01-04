import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/categories/data/category_repository.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepository CRUD', () {
    test('createCategory adds category', () async {
      final companion = CategoriesCompanion.insert(
        name: 'Food',
        kind: CategoryKind.expense,
        iconData: const Value('fastfood'),
        color: const Value(0xFF123456),
      );

      final id = await repository.createCategory(companion);
      expect(id, isNotNull);

      final categories = await repository.watchAllCategories().first;
      expect(categories.length, 1);
      expect(categories.first.name, 'Food');
      expect(categories.first.kind, CategoryKind.expense);
    });

    test('watchCategoriesByKind filters correctly', () async {
      // Create Expense
      await repository.createCategory(
        CategoriesCompanion.insert(name: 'Food', kind: CategoryKind.expense),
      );
      // Create Income
      await repository.createCategory(
        CategoriesCompanion.insert(name: 'Salary', kind: CategoryKind.income),
      );

      // Watch Expense
      try {
        final expenses = await repository
            .watchCategoriesByKind(CategoryKind.expense)
            .first;
        expect(expenses.length, 1);
        expect(expenses.first.name, 'Food');
      } catch (e) {
        fail('Should not throw exception: $e');
      }

      // Watch Income
      final incomes = await repository
          .watchCategoriesByKind(CategoryKind.income)
          .first;
      expect(incomes.length, 1);
      expect(incomes.first.name, 'Salary');
    });

    test('deleteCategory soft deletes', () async {
      final id = await repository.createCategory(
        CategoriesCompanion.insert(
          name: 'To Delete',
          kind: CategoryKind.expense,
        ),
      );

      await repository.deleteCategory(id);

      final active = await repository.watchAllCategories().first;
      expect(active.isEmpty, true);

      // Verify it still exists in DB? We don't have getCategory exposed in Repo yet,
      // but we can query DB directly or trust watchAllCategories filters it.
      final allRows = await db.select(db.categories).get();
      expect(allRows.length, 1);
      expect(allRows.first.isDeleted, true);
    });
  });
}
