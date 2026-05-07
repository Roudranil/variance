// lib/domain/usecases/category/delete_category_use_case.dart
//
// Use case: soft-delete a category.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Input for deleting a category.
class DeleteCategoryInput {
  const DeleteCategoryInput({required this.id, this.replacementId});

  /// UUID of the category to soft-delete.
  final String id;

  /// Optional UUID of the replacement category for existing transactions.
  final String? replacementId;
}

/// Soft-deletes a category and optionally re-assigns linked transactions.
///
/// Protected categories (BAI, BAE) return a [BusinessRuleFailure].
class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  // ignore: unused_field
  final ICategoryRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(DeleteCategoryInput input) {
    throw UnimplementedError('DeleteCategoryUseCase.call is not implemented');
  }
}
