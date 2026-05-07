// lib/data/database/daos/category_dao.dart
//
// DAO for the `categories` aggregate.
//
// Responsibilities:
//   - CRUD on the categories table
//   - Tree-structured queries (parent/child lookups)
//   - Guard against deletion of protected system categories

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/categories_table.dart';

part 'category_dao.g.dart';

/// DAO for CRUD and tree-structure queries on `categories`.
///
/// The two-level hierarchy is enforced by the [Category.parentId] FK.
/// Deletion of rows where [Category.isProtected] = true is blocked at the
/// domain layer before this DAO is called.
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  /// Creates a new [CategoryDao] bound to [db].
  CategoryDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns a reactive stream of all non-deleted root categories for the
  /// given [treeType] (`income` or `expense`).
  ///
  /// Parameters:
  /// - [treeType]: Which category tree to query.
  Stream<List<Category>> watchRootCategories(String treeType) {
    return (select(categories)
          ..where(
            (c) =>
                c.treeType.equals(treeType) &
                c.parentId.isNull() &
                c.isDeleted.equals(false),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns all non-deleted child categories for the given [parentId].
  ///
  /// Parameters:
  /// - [parentId]: UUID of the parent category.
  Future<List<Category>> getChildren(String parentId) {
    return (select(categories)
          ..where(
            (c) => c.parentId.equals(parentId) & c.isDeleted.equals(false),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Inserts a new category row.
  ///
  /// Parameters:
  /// - [category]: The companion carrying the column values to insert.
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }
}
