// lib/domain/entities/installment_plan.dart
//
// InstallmentPlan domain entity.
//
// Installment-specific metadata for a RecurringTemplate flagged
// isInstallment = true. One-to-one with the parent recurring_templates row.
//
// Computed fields (never stored, always derived from installment_occurrences):
//   runningTotal       = SUM(amountMinor) WHERE status='posted'
//   totalRemaining     = SUM(amountMinor) WHERE status='pending'
//   projectedFinalTotal = runningTotal + totalRemaining

import 'package:freezed_annotation/freezed_annotation.dart';

part 'installment_plan.freezed.dart';

/// Immutable domain entity for installment-specific plan metadata.
@freezed
abstract class InstallmentPlan with _$InstallmentPlan {
  const factory InstallmentPlan({
    /// UUID v4; also the FK to recurring_templates (same value as templateId).
    required String templateId,

    /// Target total amount in minor units; immutable except on early close.
    required int totalConfiguredMinor,

    /// Total number of planned installments; editable for future installments.
    required int numberOfInstallments,

    /// Creation epoch (Unix seconds).
    required int createdAt,
  }) = _InstallmentPlan;
}
