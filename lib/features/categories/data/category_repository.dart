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
  /// TODO: Add sorting or tree-traversal logic for UI display.
  Stream<List<Category>> watchAllCategories() {
    return _db.select(_db.categories).watch();
  }

  /// Watches categories by type (Expense/Income).
  Stream<List<Category>> watchCategoriesByKind(CategoryKind kind) {
    return (_db.select(
      _db.categories,
    )..where((tbl) => tbl.kind.equals(kind as String))).watch();
  }

  /// Creates a new category.
  Future<int> createCategory(CategoriesCompanion category) {
    return _db.into(_db.categories).insert(category);
  }

  /// Deletes a category.
  /// TODO: Add logic to prevent deleting if it has children or transactions.
  Future<int> deleteCategory(int id) {
    return (_db.delete(_db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
