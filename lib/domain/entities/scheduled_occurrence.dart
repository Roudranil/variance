// lib/domain/entities/scheduled_occurrence.dart
//
// ScheduledOccurrence domain entity.
//
// Materialized occurrence record for a recurring (non-installment) template.
// One row per expected occurrence. Provides the exception list for the
// scheduler (TC-003) and enables per-occurrence status tracking.
//
// Lookahead window: occurrences are materialized up to 90 days ahead.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_occurrence.freezed.dart';

/// Lifecycle state of a scheduled occurrence.
enum ScheduledOccurrenceStatus {
  pending,
  posted,
  skipped,
  cancelled,
}

/// Immutable domain entity for a single materialized recurring occurrence.
@freezed
abstract class ScheduledOccurrence with _$ScheduledOccurrence {
  const factory ScheduledOccurrence({
    /// UUID v4 stable identifier.
    required String id,

    /// Parent template UUID.
    required String templateId,

    /// Unix epoch date when this occurrence should fire.
    required int scheduledDate,

    /// Lifecycle status.
    @Default(ScheduledOccurrenceStatus.pending)
    ScheduledOccurrenceStatus status,

    /// Transaction UUID once the occurrence is posted.
    String? childTransactionId,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _ScheduledOccurrence;
}
