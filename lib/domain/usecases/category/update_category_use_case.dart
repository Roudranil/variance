// lib/domain/usecases/category/update_category_use_case.dart
//
// Use case: update an existing category.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Updates a category's mutable fields.
class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);

  // ignore: unused_field
  final ICategoryRepository _repository;

  /// Executes the use case.
  Future<Result<Category>> call(Category category) {
    throw UnimplementedError('UpdateCategoryUseCase.call is not implemented');
  }
}
