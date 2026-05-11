// lib/domain/usecases/category/update_category_use_case.dart
//
// Use case: update an existing category's mutable fields (name, iconRef).
//
// Business rules enforced here:
//   1. Name must be non-empty after trimming.
//   2. Protected categories (is_protected = true) cannot be modified.
//   3. Name must be unique within scope, excluding the category's own id.
//
// The caller must set updatedAt before calling this use case, or this use
// case will stamp it with the current epoch. Per task spec, this use case
// sets updatedAt = DateTime.now().
//
// Test cases (see test/unit/domain/usecases/category_use_cases_test.dart):
//   10. valid rename → Ok(Category)
//   11. empty name → Err(ValidationFailure)
//   12. protected category → Err(BusinessRuleFailure)
//   13. rename to existing name (same scope) → Err(ValidationFailure)
//   14. rename to own current name → Ok(Category) (self-exclude works)
//   15. category not found → Err(NotFoundFailure)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Updates a category's mutable fields (name, iconRef).
///
/// Protected categories are blocked from mutation. The [updatedAt] field
/// is stamped with the current UTC epoch before persisting.
class UpdateCategoryUseCase {
  /// Creates an [UpdateCategoryUseCase].
  ///
  /// Parameters:
  /// - [repository]: Category data access interface.
  const UpdateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  /// Validates and persists updates to [category].
  ///
  /// Returns [Ok] wrapping the updated [Category] on success.
  /// Returns [Err] wrapping a typed [Failure] on validation or DB error.
  ///
  /// Parameters:
  /// - [category]: The category with updated fields; [id] must match an
  ///   existing row.
  Future<Result<Category>> call(Category category) async {
    // --- Validation: name must not be empty ---
    if (category.name.trim().isEmpty) {
      return const Err(ValidationFailure('Name cannot be empty.'));
    }

    // --- Fetch existing to check protected status ---
    final existing = await _repository.findById(category.id);
    if (existing == null) {
      return Err(
        NotFoundFailure('Category ${category.id} not found.'),
      );
    }

    // --- Guard: protected categories cannot be modified ---
    if (existing.isProtected) {
      return const Err(
        BusinessRuleFailure('System categories cannot be modified.'),
      );
    }

    // --- Validation: name uniqueness excluding own id ---
    final nameExists = await _repository.existsNameInScope(
      category.name,
      category.treeType,
      category.parentId,
      excludeId: category.id,
    );
    if (nameExists) {
      return const Err(ValidationFailure('Name already in use.'));
    }

    // --- Stamp updatedAt and persist ---
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final updated = category.copyWith(updatedAt: nowEpoch);
    return _repository.update(updated);
  }
}
