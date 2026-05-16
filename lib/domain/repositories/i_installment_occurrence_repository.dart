// lib/domain/repositories/i_installment_occurrence_repository.dart
//
// Abstract repository interface for the InstallmentOccurrence aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_tracking_amounts.dart';

/// Contract for InstallmentOccurrence data-access operations.
abstract interface class IInstallmentOccurrenceRepository {
  /// Watches all occurrences for an installment plan, ordered by sequence.
  Stream<List<InstallmentOccurrence>> watchByPlan(String planId);

  /// Marks a pending occurrence as posted and records [transactionId].
  Future<Result<void>> markPosted(String id, String transactionId);

  /// Watches the computed tracking amounts for an installment plan.
  ///
  /// Emits whenever occurrence or transaction data changes.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the installment plan template.
  /// - [totalConfiguredMinor]: The target total from [installment_plans].
  Stream<InstallmentTrackingAmounts> watchTrackingAmounts(
    String templateId,
    int totalConfiguredMinor,
  );
}
