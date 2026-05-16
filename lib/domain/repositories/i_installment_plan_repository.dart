// lib/domain/repositories/i_installment_plan_repository.dart
//
// Abstract repository interface for the InstallmentPlan aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';

/// Contract for all InstallmentPlan data-access operations.
abstract interface class IInstallmentPlanRepository {
  /// Watches all installment plans (non-deleted templates with isInstallment).
  Stream<List<InstallmentPlan>> watchAll();

  /// Watches a single installment plan by its template UUID.
  Stream<InstallmentPlan?> watchById(String id);

  /// Atomically creates a new installment plan, its template, and all
  /// eagerly materialised occurrences in a single DB transaction (SDS §1.6.2).
  ///
  /// Inserts [template], [plan], and [occurrences] as one atomic unit.
  /// Returns [Ok(plan)] on success; [Err(DatabaseFailure)] on any write error.
  ///
  /// Parameters:
  /// - [template]: The recurring template row (isInstallment = true).
  /// - [plan]: The installment plan metadata row.
  /// - [occurrences]: All eagerly materialised occurrence rows.
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<InstallmentOccurrence> occurrences,
  });

  /// Creates a new installment plan row only (without template or occurrences).
  ///
  /// Use [createAtomic] for full plan creation.
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan);

  /// Updates mutable plan fields (e.g. numberOfInstallments for future items).
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan);

  /// Closes an installment plan early; cancels all pending occurrences.
  Future<Result<void>> closeEarly(String id);
}
