import 'package:drift/drift.dart' hide isNotNull;

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Manages classification entities [Categories].
///
/// Responsibilities:
/// - CRUD for Categories.
/// - Managing Hierarchy (Parents/Children).
class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  /// Watches all categories.
  ///
  /// Excludes deleted categories.
  Stream<List<Category>> watchAllCategories() {
    return (_db.select(
      _db.categories,
    )..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  /// Watches categories by type (Expense/Income).
  ///
  /// Excludes deleted categories.
  ///
  /// Parameters:
  /// - [kind]: The category kind to filter by.
  Stream<List<Category>> watchCategoriesByKind(CategoryKind kind) {
    return (_db.select(_db.categories)..where(
          (tbl) => tbl.kind.equals(kind.name) & tbl.isDeleted.equals(false),
        ))
        .watch();
  }

  /// Creates a new category and persists it to the database.
  ///
  /// Categories can optionally be hierarchical by specifying a [parentId].
  ///
  /// Returns the unique identifier of the newly created category.
  ///
  /// Parameters:
  /// - [name]: The display name of the category.
  /// - [kind]: The category kind (expense/income).
  /// - [parentId]: Optional parent category ID for nesting.
  /// - [iconData]: Optional icon identifier.
  /// - [color]: Optional ARGB color value.
  Future<int> createCategory({
    /// The display name of the category.
    required String name,

    /// The category kind, indicating whether it represents an expense or income.
    required CategoryKind kind,

    /// The identifier of the parent category.
    ///
    /// When provided, the category is treated as a sub-category.
    int? parentId,

    /// The icon associated with the category.
    ///
    /// This may be an asset path or an icon code point, depending on UI
    /// implementation.
    String? iconData,

    /// The ARGB color value used for UI styling of the category.
    int? color,
  }) {
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            kind: kind,
            parentId: Value(parentId),
            iconData: Value(iconData),
            color: Value(color),
          ),
        );
  }

  /// Soft deletes a category.
  ///
  /// Parameters:
  /// - [id]: The ID of the category to delete.
  Future<void> deleteCategory(int id) {
    return (_db.update(_db.categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(isDeleted: const Value(true)));
  }
}
