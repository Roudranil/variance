// lib/domain/repositories/i_category_repository.dart
//
// Abstract repository interface for the Category aggregate.
//
// Rules (SDS §1.6.3):
//   - Zero Flutter imports in this file.
//   - Use cases depend on this interface, never on concrete implementations.

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
  /// Returns [BusinessRuleFailure] if the category still has children.
  Future<Result<void>> softDelete(String id, {String? replacementId});

  /// Returns whether a category name already exists within a given scope.
  ///
  /// The check is case-insensitive and includes soft-deleted rows so that
  /// names remain globally unique even after soft-deletion.
  ///
  /// Parameters:
  /// - [name]: Display name to check.
  /// - [treeType]: The category tree type value.
  /// - [parentId]: Parent UUID for child categories; null for root categories.
  /// - [excludeId]: UUID to skip (used when renaming the category itself).
  Future<bool> existsNameInScope(
    String name,
    CategoryTreeType treeType,
    String? parentId, {
    String? excludeId,
  });

  /// Returns the category entity for [id], or null if not found.
  ///
  /// Includes soft-deleted rows so use cases can inspect protected state.
  ///
  /// Parameters:
  /// - [id]: UUID of the category to look up.
  Future<Category?> findById(String id);
}
