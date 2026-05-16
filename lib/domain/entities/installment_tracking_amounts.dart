// lib/domain/entities/installment_tracking_amounts.dart
//
// InstallmentTrackingAmounts — computed tracking amounts for an installment plan.
//
// All four amounts are derived from installment_occurrences at query time;
// none are stored columns (TC-026, Data Model §8.1).
//
// Formulas:
//   runningTotalMinor     = SUM(amount_minor) WHERE status='posted' AND child not voided
//   totalRemainingMinor   = SUM(amount_minor) WHERE status='pending'
//   projectedFinalTotal   = runningTotalMinor + totalRemainingMinor
//   hasMismatch           = projectedFinalTotal ≠ totalConfiguredMinor
//
// Spec: T-132, INST-02

import 'package:freezed_annotation/freezed_annotation.dart';

part 'installment_tracking_amounts.freezed.dart';

/// Computed tracking amounts for an installment series.
///
/// These values are never stored; they are derived from [installment_occurrences]
/// at query time (TC-026).
@freezed
abstract class InstallmentTrackingAmounts with _$InstallmentTrackingAmounts {
  const factory InstallmentTrackingAmounts({
    /// The target total as stored in `installment_plans.total_configured_minor`.
    required int totalConfiguredMinor,

    /// Sum of [amountMinor] for all occurrences where `status = 'posted'`
    /// and the child transaction is not voided.
    required int runningTotalMinor,

    /// Sum of [amountMinor] for all occurrences where `status = 'pending'`.
    required int totalRemainingMinor,

    /// True when [projectedFinalTotalMinor] ≠ [totalConfiguredMinor].
    ///
    /// Non-blocking at save time (PRD §5.2.8.1).
    required bool hasMismatch,
  }) = _InstallmentTrackingAmounts;

  const InstallmentTrackingAmounts._();

  /// `runningTotalMinor + totalRemainingMinor`.
  int get projectedFinalTotalMinor => runningTotalMinor + totalRemainingMinor;
}
