// lib/domain/usecases/category/create_category_use_case.dart
//
// Use case: create a new category.
//
// Business rules enforced here:
//   1. Name must be non-empty after trimming.
//   2. Two-level depth limit: if parentId is non-null, the parent's own
//      parentId must be null (no grandchild nesting).
//   3. Name must be unique within scope (tree + parent), including
//      soft-deleted rows (case-insensitive).
//
// The caller (presentation layer) is responsible for generating UUID and
// epoch timestamps before calling this use case.
//
// Test cases (see test/unit/domain/usecases/category_use_cases_test.dart):
//   1. valid root category → Ok(Category)
//   2. valid child category → Ok(Category)
//   3. empty name → Err(ValidationFailure)
//   4. whitespace-only name → Err(ValidationFailure)
//   5. three-level depth (parent of a child) → Err(ValidationFailure)
//   6. duplicate name in scope (active) → Err(ValidationFailure)
//   7. duplicate name in scope (soft-deleted) → Err(ValidationFailure)
//   8. same name in different tree → Ok(Category)
//   9. same name in different parent → Ok(Category)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Creates a new category and persists it via [ICategoryRepository].
///
/// All validation is performed before any database write. The category id and
/// timestamps must be set by the caller prior to invoking [call].
class CreateCategoryUseCase {
  /// Creates a [CreateCategoryUseCase].
  ///
  /// Parameters:
  /// - [repository]: Category data access interface.
  const CreateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  /// Validates and persists a new [category].
  ///
  /// Returns [Ok] wrapping the persisted [Category] on success.
  /// Returns [Err] wrapping a typed [Failure] when validation fails or a
  /// database error occurs.
  ///
  /// Parameters:
  /// - [category]: The category to create (id and timestamps must be set).
  Future<Result<Category>> call(Category category) async {
    // --- Validation: name must not be empty ---
    if (category.name.trim().isEmpty) {
      return const Err(ValidationFailure('Name cannot be empty.'));
    }

    // --- Validation: two-level depth limit ---
    if (category.parentId != null) {
      final parent = await _repository.findById(category.parentId!);
      if (parent == null) {
        return Err(
          NotFoundFailure('Parent category ${category.parentId} not found.'),
        );
      }
      if (parent.parentId != null) {
        return const Err(
          ValidationFailure(
            'Categories cannot be nested more than two levels.',
          ),
        );
      }
    }

    // --- Validation: name uniqueness (including soft-deleted) ---
    final nameExists = await _repository.existsNameInScope(
      category.name,
      category.treeType,
      category.parentId,
    );
    if (nameExists) {
      return const Err(ValidationFailure('Name already in use.'));
    }

    return _repository.create(category);
  }
}
