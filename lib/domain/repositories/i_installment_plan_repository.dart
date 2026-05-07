// lib/domain/repositories/i_installment_plan_repository.dart
//
// Abstract repository interface for the InstallmentPlan aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';

/// Contract for all InstallmentPlan data-access operations.
abstract interface class IInstallmentPlanRepository {
  /// Watches all installment plans (non-deleted templates with isInstallment).
  Stream<List<InstallmentPlan>> watchAll();

  /// Watches a single installment plan by its template UUID.
  Stream<InstallmentPlan?> watchById(String id);

  /// Creates a new installment plan (together with its template).
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan);

  /// Updates mutable plan fields (e.g. numberOfInstallments for future items).
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan);

  /// Closes an installment plan early; cancels all pending occurrences.
  Future<Result<void>> closeEarly(String id);
}
