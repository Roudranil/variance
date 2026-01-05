import 'package:drift/drift.dart';

import 'package:variance/core/utils/logger.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Manages [Categories] entities and their linked nominal accounts.
///
/// In double-entry bookkeeping, each category is backed by a hidden nominal
/// account. When a category is created, this repository automatically creates
/// the corresponding account with the appropriate [AccountNature].
class CategoryRepository {
  final AppDatabase _db;

  /// Creates a new instance of [CategoryRepository].
  ///
  /// Parameters:
  /// - [db]: The database instance to use.
  CategoryRepository(this._db);

  /// Watches all categories ordered by name.
  ///
  /// Excludes deleted categories.
  ///
  /// Returns a [Stream] of [Category] lists that updates when data changes.
  Stream<List<Category>> watchAllCategories() {
    return (_db.select(_db.categories)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Watches categories filtered by kind (expense or income).
  ///
  /// Excludes deleted categories.
  ///
  /// Returns a [Stream] of [Category] lists that updates when data changes.
  ///
  /// Parameters:
  /// - [kind]: The category kind to filter by.
  Stream<List<Category>> watchCategoriesByKind(CategoryKind kind) {
    return (_db.select(_db.categories)
          ..where((tbl) => tbl.kind.equalsValue(kind))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Gets a single category by ID.
  ///
  /// Returns null if the category does not exist.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the category.
  Future<Category?> getCategory(int id) {
    return (_db.select(
      _db.categories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new category with its linked nominal account.
  ///
  /// This method performs the following in a single transaction:
  /// 1. Creates a hidden nominal account with [AccountNature.expense] or
  ///    [AccountNature.income] based on [kind].
  /// 2. Creates the category record linking to that account.
  ///
  /// Returns the unique identifier of the newly created category.
  ///
  /// Parameters:
  /// - [name]: The display name of the category.
  /// - [kind]: The category kind (expense or income).
  /// - [parentId]: Optional parent category ID for sub-categories.
  /// - [iconData]: Optional icon identifier (codePoint or asset path).
  /// - [color]: Optional ARGB color value for UI styling.
  Future<int> createCategory({
    required String name,
    required CategoryKind kind,
    int? parentId,
    String? iconData,
    int? color,
  }) async {
    return _db.transaction(() async {
      // determine the account nature based on category kind
      final accountNature = kind == CategoryKind.expense
          ? AccountNature.expense
          : AccountNature.income;

      // create the hidden nominal account
      final linkedAccountId = await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: '$name (${kind.name})',
              nature: accountNature,
              isUserVisible: const Value(false),
              includeInTotals: const Value(false),
            ),
          );

      // create the category linking to the account
      final categoryId = await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: name,
              kind: kind,
              linkedAccountId: linkedAccountId,
              parentId: Value(parentId),
              iconData: Value(iconData),
              color: Value(color),
            ),
          );

      VarianceLogger.info(
        'Created category "$name" (id=$categoryId, kind=$kind, linkedAccount=$linkedAccountId)',
      );
      return categoryId;
    });
  }

  /// Updates an existing category's metadata.
  ///
  /// Updates the category name, icon, color, and parent. Also updates the
  /// display name of the linked nominal account.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the category to update.
  /// - [name]: The new display name.
  /// - [parentId]: The new parent category ID (null for top-level).
  /// - [iconData]: The new icon identifier.
  /// - [color]: The new ARGB color value.
  Future<void> updateCategory({
    required int id,
    String? name,
    int? parentId,
    String? iconData,
    int? color,
  }) async {
    return _db.transaction(() async {
      final category = await getCategory(id);
      if (category == null) return;

      // update category
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          parentId: Value(parentId),
          iconData: Value(iconData),
          color: Value(color),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // update linked account name if category name changed
      if (name != null) {
        await (_db.update(
          _db.accounts,
        )..where((a) => a.id.equals(category.linkedAccountId))).write(
          AccountsCompanion(
            name: Value('$name (${category.kind.name})'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        VarianceLogger.debug('Updated linked account name for category $id');
      }

      VarianceLogger.info('Updated category $id');
    });
  }

  /// Soft deletes a category.
  ///
  /// The category and its linked account are hidden from the UI but kept for
  /// historical integrity.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the category to delete.
  Future<void> softDeleteCategory(int id) async {
    return _db.transaction(() async {
      final category = await getCategory(id);
      if (category == null) return;

      // soft delete the category
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // soft delete the linked account
      await (_db.update(
        _db.accounts,
      )..where((a) => a.id.equals(category.linkedAccountId))).write(
        AccountsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      VarianceLogger.info(
        'Soft deleted category $id and linked account ${category.linkedAccountId}',
      );
    });
  }
}
