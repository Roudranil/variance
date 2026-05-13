// lib/domain/usecases/recurring/skip_occurrence_use_case.dart
//
// Use case: manually skip a pending scheduled occurrence.
//
// The occurrence is marked status = 'skipped' via IScheduledOccurrenceRepository.
// The parent recurring_templates row is NOT modified — only the occurrence row
// is updated (RECUR-02).
//
// This use case is also called internally by:
//   - EditTransactionUseCase     (child edit   → mark occurrence skipped)
//   - SoftDeleteTransactionUseCase (child delete → mark occurrence skipped)
//   - PauseRecurringTemplateUseCase (batch skip within pause window)
//
// Spec: T-112, RECUR-02, API Contracts §2.6.3
//
// Test cases (see test/unit/domain/usecases/skip_occurrence_use_case_test.dart):
//   1. Valid skip → Ok(void); markSkipped called with correct id.
//   2. Repository failure → Err propagated.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';

/// Marks the scheduled occurrence with [id] as skipped.
///
/// The occurrence status is set to 'skipped' via
/// [IScheduledOccurrenceRepository.markSkipped]. The parent template is not
/// touched; future occurrences continue normally (RECUR-02).
class SkipOccurrenceUseCase {
  /// Creates a [SkipOccurrenceUseCase].
  ///
  /// Parameters:
  /// - [repository]: Repository for scheduled occurrence status mutations.
  const SkipOccurrenceUseCase(this._repository);

  final IScheduledOccurrenceRepository _repository;

  /// Marks the occurrence identified by [id] as skipped.
  ///
  /// Returns [Ok(null)] when the skip succeeds. Returns [Err] when the
  /// repository operation fails (e.g. database error or record not found).
  ///
  /// Parameters:
  /// - [id]: UUID of the scheduled occurrence to mark as skipped.
  Future<Result<void>> call(String id) => _repository.markSkipped(id);
}
