// lib/domain/repositories/i_scheduled_occurrence_repository.dart
//
// Abstract repository interface for the ScheduledOccurrence aggregate (T-99).
//
// Extended in T-99 to add:
//   - getPendingDue(asOf)     — query all pending occurrences due on or before asOf
//   - markCancelled(id)       — cancel an occurrence (e.g. template soft-deleted)
//   - generateLookahead(...)  — bulk insert pre-materialized future occurrences

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';

/// Contract for ScheduledOccurrence CRUD and status-update operations.
abstract interface class IScheduledOccurrenceRepository {
  /// Returns all occurrences with status = pending whose scheduled_date ≤
  /// [asOf] (Unix epoch days).
  ///
  /// Used by [PostDueOccurrencesUseCase] and [AppInitializer] on each launch.
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf);

  /// Marks a pending occurrence as posted and records the resulting
  /// [transactionId].
  Future<Result<void>> markPosted(String id, String transactionId);

  /// Marks a pending occurrence as skipped (manually handled or pause-skipped).
  Future<Result<void>> markSkipped(String id);

  /// Marks a pending occurrence as cancelled.
  ///
  /// Typically called when the parent template is soft-deleted or archived.
  Future<Result<void>> markCancelled(String id);

  /// Inserts pre-computed future occurrences for [templateId] in the date
  /// range [[fromDate], [toDate]].
  ///
  /// Skips insertion for dates that already have a non-cancelled row for the
  /// template. Idempotent — safe to call repeatedly.
  Future<Result<void>> generateLookahead({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<ScheduledOccurrence> occurrences,
  });
}
