// lib/domain/usecases/recurring/post_due_occurrences_use_case.dart
//
// Use case: post all due recurring occurrences on app launch.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Posts all auto_post occurrences whose scheduled_date ≤ now.
///
/// Returns the count of occurrences that were successfully posted.
/// Called on every app launch (AppInitializer) and by the background worker.
class PostDueOccurrencesUseCase {
  const PostDueOccurrencesUseCase(
    this._templateRepository,
    this._occurrenceRepository,
    this._transactionRepository,
  );

  // ignore: unused_field
  final IRecurringTemplateRepository _templateRepository;
  // ignore: unused_field
  final IScheduledOccurrenceRepository _occurrenceRepository;
  // ignore: unused_field
  final ITransactionRepository _transactionRepository;

  /// Executes the use case.
  ///
  /// Returns [Ok(n)] where n is the number of occurrences posted.
  Future<Result<int>> call() {
    throw UnimplementedError(
      'PostDueOccurrencesUseCase.call is not implemented',
    );
  }
}
