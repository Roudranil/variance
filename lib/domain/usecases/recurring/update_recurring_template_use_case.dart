// lib/domain/usecases/recurring/update_recurring_template_use_case.dart
//
// Use case: update editable fields of a recurring template.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Updates mutable fields of an existing recurring template.
///
/// Immutable fields (transaction type, recurrence spec, start/end date) are
/// ignored by the repository implementation.
class UpdateRecurringTemplateUseCase {
  const UpdateRecurringTemplateUseCase(this._repository);

  // ignore: unused_field
  final IRecurringTemplateRepository _repository;

  /// Executes the use case.
  Future<Result<RecurringTemplate>> call(RecurringTemplate template) {
    throw UnimplementedError(
      'UpdateRecurringTemplateUseCase.call is not implemented',
    );
  }
}
