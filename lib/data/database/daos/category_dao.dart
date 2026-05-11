// lib/data/database/daos/category_dao.dart
//
// DAO for the `categories` aggregate.
//
// Responsibilities:
//   - CRUD on the categories table
//   - Tree-structured queries (parent/child lookups)
//   - Soft-delete support (is_deleted flag, deleted_at epoch)
//   - Name uniqueness guard (case-insensitive, including soft-deleted rows)
//   - Child count for deletion safety check
//
// Test cases (see test/data/database/category_dao_test.dart):
//   1. watchAllCategories — emits non-deleted categories ordered by name
//   2. watchByTreeType — emits only income or expense categories
//   3. insertCategory — row appears in watchAllCategories stream
//   4. updateCategory — stream reflects updated fields
//   5. softDeleteCategory — row disappears from watchAllCategories
//   6. countChildren — returns 0 for leaf, N for parent with children
//   7. existsNameInScope — true for active rows; true for soft-deleted rows
//   8. existsNameInScope — excludeId skips the matched row
//   9. existsNameInScope — case-insensitive match
//  10. findById — returns matching row or null

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
  // Streams
  // -----------------------------------------------------------------------

  /// Returns a reactive stream of all non-deleted categories (both trees),
  /// ordered alphabetically by name.
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns a reactive stream of all non-deleted categories for [treeType].
  ///
  /// Parameters:
  /// - [treeType]: `'income'` or `'expense'`.
  Stream<List<Category>> watchByTreeType(String treeType) {
    return (select(categories)
          ..where(
            (c) => c.treeType.equals(treeType) & c.isDeleted.equals(false),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns all non-deleted root categories for the given [treeType],
  /// ordered alphabetically by name.
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

  // -----------------------------------------------------------------------
  // Single-row lookups
  // -----------------------------------------------------------------------

  /// Returns the category row for [id], or null if not found.
  ///
  /// Includes soft-deleted rows so use cases can guard on `isProtected`
  /// before committing a mutation.
  ///
  /// Parameters:
  /// - [id]: UUID of the category.
  Future<Category?> findById(String id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns all non-deleted child categories for the given [parentId],
  /// ordered alphabetically by name.
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

  // -----------------------------------------------------------------------
  // Writes
  // -----------------------------------------------------------------------

  /// Inserts a new category row.
  ///
  /// Returns the rowid of the inserted row.
  ///
  /// Parameters:
  /// - [category]: The companion carrying the column values to insert.
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  /// Updates an existing category row identified by the companion's [id].
  ///
  /// Returns `true` if exactly one row was updated; `false` if no matching
  /// row was found.
  ///
  /// Parameters:
  /// - [category]: The companion with the fields to update (must include [id]).
  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(categories).replace(category);
  }

  /// Soft-deletes the category with [id] by setting `is_deleted = true`
  /// and `deleted_at = [deletedAtEpoch]`.
  ///
  /// Parameters:
  /// - [id]: UUID of the category to soft-delete.
  /// - [deletedAtEpoch]: Unix epoch seconds to record as the deletion time.
  Future<int> softDeleteCategory(String id, int deletedAtEpoch) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAtEpoch),
        updatedAt: Value(deletedAtEpoch),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Aggregation helpers
  // -----------------------------------------------------------------------

  /// Returns the number of non-deleted child categories for [parentId].
  ///
  /// Used by the repository to guard against deleting a parent that still
  /// has children.
  ///
  /// Parameters:
  /// - [parentId]: UUID of the parent category.
  Future<int> countChildren(String parentId) async {
    final countExpr = categories.id.count();
    final query = selectOnly(categories)
      ..addColumns([countExpr])
      ..where(
        categories.parentId.equals(parentId) &
            categories.isDeleted.equals(false),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Returns true if a category with [name] exists within the given scope,
  /// optionally restricted to [parentId].
  ///
  /// The check is case-insensitive and includes soft-deleted rows, so names
  /// remain globally unique even after soft-deletion.
  ///
  /// Parameters:
  /// - [name]: Display name to check (compared case-insensitively).
  /// - [treeType]: `'income'` or `'expense'` tree.
  /// - [parentId]: Parent UUID for child categories; null for root categories.
  /// - [excludeId]: UUID to exclude from the check (used during update to
  ///   skip the row being edited).
  Future<bool> existsNameInScope(
    String name,
    String treeType,
    String? parentId, {
    String? excludeId,
  }) async {
    // Use LOWER() for case-insensitive comparison.
    // customSelect is needed because Drift's Expression API does not expose
    // LOWER() directly. The query is safe from injection via parameterised
    // variables.
    final buffer = StringBuffer(
      'SELECT COUNT(*) AS cnt FROM categories '
      'WHERE LOWER(name) = LOWER(?) AND tree_type = ? ',
    );
    final vars = <Variable<Object>>[
      Variable.withString(name),
      Variable.withString(treeType),
    ];

    if (parentId == null) {
      buffer.write('AND parent_id IS NULL ');
    } else {
      buffer.write('AND parent_id = ? ');
      vars.add(Variable.withString(parentId));
    }

    if (excludeId != null) {
      buffer.write('AND id != ? ');
      vars.add(Variable.withString(excludeId));
    }

    final result = await customSelect(
      buffer.toString(),
      variables: vars,
      readsFrom: {categories},
    ).getSingle();

    return result.read<int>('cnt') > 0;
  }
}
