// lib/data/repositories/category_repository_impl.dart
//
// Concrete implementation of ICategoryRepository backed by Drift via CategoryDao.
//
// This stub implementation wires the DI graph for INFRA-3.
// Full business logic is implemented in later feature tasks.

import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Drift-backed implementation of [ICategoryRepository].
///
/// Delegates all data access to [CategoryDao]. Business rules live in use cases.
class CategoryRepositoryImpl implements ICategoryRepository {
  /// Creates a [CategoryRepositoryImpl] backed by [dao].
  const CategoryRepositoryImpl(this._dao);

  // ignore: unused_field — used by full implementation in later feature tasks
  final CategoryDao _dao;

  @override
  Stream<List<Category>> watchAll() {
    // TODO(dev): Map Drift Category rows to domain Category entities.
    throw UnimplementedError('watchAll not yet implemented');
  }

  @override
  Future<Result<Category>> create(Category category) {
    // TODO(dev): Implement category creation with tree-type validation.
    throw UnimplementedError('create not yet implemented');
  }

  @override
  Future<Result<Category>> update(Category category) {
    // TODO(dev): Implement category update with protected-category guard.
    throw UnimplementedError('update not yet implemented');
  }

  @override
  Future<Result<void>> softDelete(String id, {String? replacementId}) {
    // TODO(dev): Implement soft-delete with optional transaction re-assignment.
    throw UnimplementedError('softDelete not yet implemented');
  }
}
