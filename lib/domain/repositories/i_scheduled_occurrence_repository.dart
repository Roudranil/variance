// lib/domain/repositories/i_scheduled_occurrence_repository.dart
//
// Abstract repository interface for the ScheduledOccurrence aggregate.

import 'package:variance/domain/core/result.dart';

/// Contract for ScheduledOccurrence status-update operations.
abstract interface class IScheduledOccurrenceRepository {
  /// Marks a pending occurrence as posted and records the resulting
  /// [transactionId].
  Future<Result<void>> markPosted(String id, String transactionId);

  /// Marks a pending occurrence as skipped (manually handled or pause-skipped).
  Future<Result<void>> markSkipped(String id);
}
