// lib/domain/usecases/recurring/skip_occurrence_use_case.dart
//
// Use case: manually skip a pending scheduled occurrence.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';

/// Marks the scheduled occurrence with [id] as skipped.
class SkipOccurrenceUseCase {
  const SkipOccurrenceUseCase(this._repository);

  // ignore: unused_field
  final IScheduledOccurrenceRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(String id) {
    throw UnimplementedError('SkipOccurrenceUseCase.call is not implemented');
  }
}
