// lib/domain/usecases/category/create_category_use_case.dart
//
// Use case: create a new category.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';

/// Creates a new category and persists it.
class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);

  // ignore: unused_field
  final ICategoryRepository _repository;

  /// Executes the use case.
  Future<Result<Category>> call(Category category) {
    throw UnimplementedError('CreateCategoryUseCase.call is not implemented');
  }
}
