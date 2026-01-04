import 'package:drift/drift.dart' hide isNotNull;

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// **Category Repository**
///
/// Manages classification entities ([Categories]).
///
/// **Responsibilities:**
/// *   CRUD for Categories.
/// *   Managing Hierarchy (Parents/Children).
class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  /// Watches all categories.
  /// Excluding deleted.
  Stream<List<Category>> watchAllCategories() {
    return (_db.select(
      _db.categories,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  /// Watches categories by type (Expense/Income).
  /// Excluding deleted.
  Stream<List<Category>> watchCategoriesByKind(CategoryKind kind) {
    return (_db.select(_db.categories)..where(
          (tbl) => tbl.kind.equals(kind.name) & tbl.isDeleted.equals(false),
        ))
        .watch();
  }

  /// Creates a new category.
  Future<int> createCategory(CategoriesCompanion category) {
    return _db.into(_db.categories).insert(category);
  }

  /// Soft deletes a category.
  Future<void> deleteCategory(int id) {
    return (_db.update(_db.categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(isDeleted: const Value(true)));
  }
}
