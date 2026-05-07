// lib/domain/repositories/i_category_repository.dart
//
// Abstract repository interface for the Category aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';

/// Contract for all Category data-access operations.
abstract interface class ICategoryRepository {
  /// Watches all non-deleted categories (both income and expense trees).
  Stream<List<Category>> watchAll();

  /// Persists a new category.
  Future<Result<Category>> create(Category category);

  /// Updates an existing category.
  Future<Result<Category>> update(Category category);

  /// Soft-deletes the category with [id].
  ///
  /// [replacementId] — if provided, existing transactions referencing [id]
  /// are re-assigned to [replacementId] before deletion.
  Future<Result<void>> softDelete(String id, {String? replacementId});
}
