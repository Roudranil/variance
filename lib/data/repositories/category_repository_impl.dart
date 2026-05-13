// lib/data/repositories/category_repository_impl.dart
//
// Concrete implementation of ICategoryRepository backed by Drift via CategoryDao.
//
// Business rules enforced here:
//   - softDelete: blocked when the category still has non-deleted children
//     (returns BusinessRuleFailure). Use cases may also add further guards.
//   - update: returns NotFoundFailure if the DAO reports 0 rows updated.
//   - create/update/softDelete: all Drift exceptions are wrapped in
//     DatabaseFailure before crossing the layer boundary.
//
// Naming note: The Drift-generated row class for `categories` is also named
// `Category`. Domain entity is imported with the `domain` alias; the Drift
// row is imported via `show`.
//
// Test cases (see test/data/repositories/category_repository_impl_test.dart):
//   1. watchAll — emits non-deleted categories after insert
//   2. create — inserted category appears in watchAll stream
//   3. update — changed name reflected in watchAll stream
//   4. update — missing row returns Err(NotFoundFailure)
//   5. softDelete — category disappears from watchAll stream
//   6. softDelete leaf — returns Ok(null)
//   7. softDelete parent with children — returns Err(BusinessRuleFailure)

import 'dart:developer' as dev;

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart'
    show Category, CategoriesCompanion;
import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/data/models/category_dto.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart' as domain;
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Drift-backed implementation of [ICategoryRepository].
///
/// Delegates all data access to [CategoryDao]. Business rules live in use
/// cases; only the "cannot delete a parent with children" invariant is
/// enforced here since it requires a DAO call that the repository is
/// responsible for.
class CategoryRepositoryImpl implements ICategoryRepository {
  /// Creates a [CategoryRepositoryImpl] backed by [dao].
  ///
  /// Parameters:
  /// - [dao]: The [CategoryDao] used for all category data access.
  const CategoryRepositoryImpl(this._dao);

  final CategoryDao _dao;

  // -----------------------------------------------------------------------
  // ICategoryRepository — streams
  // -----------------------------------------------------------------------

  @override
  Stream<List<domain.Category>> watchAll() {
    return _dao.watchAllCategories().map(
          (rows) => rows.map(_rowToEntity).toList(),
        );
  }

  // -----------------------------------------------------------------------
  // ICategoryRepository — writes
  // -----------------------------------------------------------------------

  @override
  Future<Result<domain.Category>> create(domain.Category category) async {
    try {
      await _dao.insertCategory(_entityToCompanion(category));
      final row = await _dao.findById(category.id);
      if (row == null) {
        return const Err(
          DatabaseFailure('Category insert succeeded but row not found'),
        );
      }
      return Ok(_rowToEntity(row));
    } on Object catch (e, st) {
      dev.log(
        'CategoryRepositoryImpl.create error: $e',
        name: 'CategoryRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to create category: $e'));
    }
  }

  @override
  Future<Result<domain.Category>> update(domain.Category category) async {
    try {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final companion = _entityToCompanion(category).copyWith(
        updatedAt: Value(nowEpoch),
      );
      final updated = await _dao.updateCategory(companion);
      if (!updated) {
        return Err(
          NotFoundFailure('Category ${category.id} not found for update'),
        );
      }
      final row = await _dao.findById(category.id);
      if (row == null) {
        return const Err(
          DatabaseFailure('Category row missing after update'),
        );
      }
      return Ok(_rowToEntity(row));
    } on Object catch (e, st) {
      dev.log(
        'CategoryRepositoryImpl.update error: $e',
        name: 'CategoryRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Result<void>> softDelete(String id, {String? replacementId}) async {
    try {
      // Guard: cannot delete a parent that still has children.
      final childCount = await _dao.countChildren(id);
      if (childCount > 0) {
        return const Err(
          BusinessRuleFailure(
            'Cannot delete a category with subcategories.',
          ),
        );
      }

      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final affected = await _dao.softDeleteCategory(id, nowEpoch);
      if (affected == 0) {
        return Err(NotFoundFailure('Category $id not found for soft-delete'));
      }
      return const Ok(null);
    } on Object catch (e, st) {
      dev.log(
        'CategoryRepositoryImpl.softDelete error: $e',
        name: 'CategoryRepo',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Failed to soft-delete category: $e'));
    }
  }

  // -----------------------------------------------------------------------
  // Additional query helpers (used by use cases via the interface)
  // -----------------------------------------------------------------------

  // -----------------------------------------------------------------------
  // ICategoryRepository — additional query helpers
  // -----------------------------------------------------------------------

  @override
  Future<bool> existsNameInScope(
    String name,
    domain.CategoryTreeType treeType,
    String? parentId, {
    String? excludeId,
  }) {
    return _dao.existsNameInScope(
      name,
      CategoryDto.treeTypeToString(treeType),
      parentId,
      excludeId: excludeId,
    );
  }

  @override
  Future<domain.Category?> findById(String id) async {
    final row = await _dao.findById(id);
    return row == null ? null : _rowToEntity(row);
  }

  // -----------------------------------------------------------------------
  // Private mapping helpers
  // -----------------------------------------------------------------------

  /// Maps a Drift-generated [Category] row to the domain entity.
  domain.Category _rowToEntity(Category row) {
    return CategoryDto.fromRow(row).toEntity();
  }

  /// Maps a domain [domain.Category] entity to a Drift [CategoriesCompanion].
  CategoriesCompanion _entityToCompanion(domain.Category entity) {
    return CategoriesCompanion(
      id: Value(entity.id),
      parentId: Value(entity.parentId),
      treeType: Value(CategoryDto.treeTypeToString(entity.treeType)),
      name: Value(entity.name),
      iconRef: Value(entity.iconRef),
      isDeleted: Value(entity.isDeleted),
      deletedAt: Value(entity.deletedAt),
      isProtected: Value(entity.isProtected),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      largeTxnThresholdMinor: Value(entity.largeTxnThresholdMinor),
    );
  }
}
