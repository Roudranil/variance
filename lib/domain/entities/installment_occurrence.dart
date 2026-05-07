// lib/domain/entities/installment_occurrence.dart
//
// InstallmentOccurrence domain entity.
//
// Individual materialized installment record. Created eagerly at template
// creation (all occurrences). Supports per-installment amount overrides
// and status tracking.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'installment_occurrence.freezed.dart';

/// Lifecycle state of an installment occurrence.
enum InstallmentOccurrenceStatus {
  pending,
  posted,
  cancelled,
}

/// Immutable domain entity for a single installment occurrence.
@freezed
abstract class InstallmentOccurrence with _$InstallmentOccurrence {
  const factory InstallmentOccurrence({
    /// UUID v4 stable identifier.
    required String id,

    /// Parent installment template UUID.
    required String templateId,

    /// 1-based position in the installment series; unique per template.
    required int sequenceNumber,

    /// Unix epoch date when this installment should be posted.
    required int scheduledDate,

    /// Per-installment amount in minor units; user-adjustable for future
    /// unposted installments.
    required int amountMinor,

    /// Lifecycle status.
    @Default(InstallmentOccurrenceStatus.pending)
    InstallmentOccurrenceStatus status,

    /// Transaction UUID once the installment is posted.
    String? childTransactionId,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _InstallmentOccurrence;
}
