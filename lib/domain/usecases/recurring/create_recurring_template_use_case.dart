// lib/domain/usecases/recurring/create_recurring_template_use_case.dart
//
// Use case: create a new recurring template.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Creates a new recurring template and materializes its initial occurrences.
class CreateRecurringTemplateUseCase {
  const CreateRecurringTemplateUseCase(this._repository);

  // ignore: unused_field
  final IRecurringTemplateRepository _repository;

  /// Executes the use case.
  Future<Result<RecurringTemplate>> call(RecurringTemplate template) {
    throw UnimplementedError(
      'CreateRecurringTemplateUseCase.call is not implemented',
    );
  }
}
