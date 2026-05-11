// lib/domain/usecases/category/delete_category_use_case.dart
//
// Use case: soft-delete a category.
//
// Business rules enforced here:
//   1. Category must exist → NotFoundFailure if absent.
//   2. Protected categories cannot be deleted → BusinessRuleFailure.
//   3. Parent with non-deleted children cannot be deleted → BusinessRuleFailure
//      (propagated from CategoryRepositoryImpl via softDelete).
//
// Test cases (see test/unit/domain/usecases/category_use_cases_test.dart):
//   16. leaf category deleted successfully → Ok(void)
//   17. protected category → Err(BusinessRuleFailure)
//   18. parent with children → Err(BusinessRuleFailure)
//   19. non-existent category → Err(NotFoundFailure)

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Soft-deletes a category after validating protected-category and child
/// constraints.
///
/// [replacementId] is forwarded to the repository for optional transaction
/// re-assignment (migration) after the soft-delete.
class DeleteCategoryUseCase {
  /// Creates a [DeleteCategoryUseCase].
  ///
  /// Parameters:
  /// - [repository]: Category data access interface.
  const DeleteCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  /// Soft-deletes the category with [id].
  ///
  /// Returns [Ok] on success.
  /// Returns [Err] wrapping [NotFoundFailure] if the category does not exist.
  /// Returns [Err] wrapping [BusinessRuleFailure] if the category is
  /// protected or still has non-deleted children.
  ///
  /// Parameters:
  /// - [id]: UUID of the category to soft-delete.
  /// - [replacementId]: Optional UUID of a replacement category for
  ///   transaction migration; forwarded to the repository.
  Future<Result<void>> call(String id, {String? replacementId}) async {
    // --- Fetch existing ---
    final existing = await _repository.findById(id);
    if (existing == null) {
      return Err(NotFoundFailure('Category $id not found.'));
    }

    // --- Guard: protected categories cannot be deleted ---
    if (existing.isProtected) {
      return const Err(
        BusinessRuleFailure('System categories cannot be deleted.'),
      );
    }

    // Delegate to repository; the "children" guard is enforced there.
    return _repository.softDelete(id, replacementId: replacementId);
  }
}
