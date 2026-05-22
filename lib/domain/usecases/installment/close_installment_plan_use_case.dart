// lib/domain/usecases/installment/close_installment_plan_use_case.dart
//
// Use case: close an installment plan early (INST-03, T-135).
//
// Flow (PRD §5.2.8.3):
//   1. Load the template by [id] — reject if already archived.
//   2. Cancel all pending occurrences via [IInstallmentPlanRepository.closeEarly].
//   3. Archive the template (status → archived, archivedReason → earlyClose)
//      via [IRecurringTemplateRepository.update].
//   4. Optionally update [totalConfiguredMinor] = [newTotalMinor] when the
//      caller chooses "Update target" after mismatch check (TC-021).
//
// Mismatch handling (PRD §5.2.8.3 step 4):
//   - The mismatch check and UI prompt happen in the presentation layer.
//   - This use case receives [updateTotalOnEarlyClose]: when true, it updates
//     the plan's [totalConfiguredMinor] to [newTotalMinor].
//
// Returns:
//   - [Ok(null)]                    on success.
//   - [Err(BusinessRuleFailure)]    when the template is already archived.
//   - [Err(NotFoundFailure)]        when no template row exists for [id].
//   - [Err(DatabaseFailure)]        when a repository write fails.
//
// Test cases (see test/unit/domain/usecases/close_installment_plan_use_case_test.dart):
//   T-144.1  no-final-payment path: pending occurrences cancelled, template archived
//   T-144.2  updateTotalOnEarlyClose=true updates totalConfiguredMinor
//   T-144.3  already-archived template → Err(BusinessRuleFailure)
//   T-144.4  non-existent template → Err(NotFoundFailure)
//   T-144.5  closeEarly repository failure → Err(DatabaseFailure) propagated

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Input parameters for [CloseInstallmentPlanUseCase].
class CloseInstallmentPlanInput {
  /// Creates a [CloseInstallmentPlanInput].
  ///
  /// Parameters:
  /// - [id]: UUID of the installment template to close.
  /// - [updateTotalOnEarlyClose]: When true, updates [installment_plans.total_configured_minor]
  ///   to [newTotalMinor]. Used when the user chooses "Update target" after mismatch prompt.
  /// - [newTotalMinor]: The running total to store as the new target. Required when
  ///   [updateTotalOnEarlyClose] is true.
  const CloseInstallmentPlanInput({
    required this.id,
    this.updateTotalOnEarlyClose = false,
    this.newTotalMinor,
  });

  /// UUID of the installment template to close.
  final String id;

  /// When true, overwrites [total_configured_minor] with [newTotalMinor].
  final bool updateTotalOnEarlyClose;

  /// New total in minor units; used when [updateTotalOnEarlyClose] is true.
  final int? newTotalMinor;
}

/// Closes the installment plan identified by [id] early.
///
/// Cancels all pending installment occurrences and archives the template.
/// Optionally updates [totalConfiguredMinor] if the user chooses to align
/// the target to the actual running total (TC-021).
class CloseInstallmentPlanUseCase {
  /// Creates a [CloseInstallmentPlanUseCase].
  ///
  /// Parameters:
  /// - [planRepository]: Repository for installment plan operations.
  /// - [templateRepository]: Repository for recurring template operations.
  const CloseInstallmentPlanUseCase({
    required IInstallmentPlanRepository planRepository,
    required IRecurringTemplateRepository templateRepository,
  })  : _planRepository = planRepository,
        _templateRepository = templateRepository;

  final IInstallmentPlanRepository _planRepository;
  final IRecurringTemplateRepository _templateRepository;

  /// Executes the close use case.
  ///
  /// Returns [Ok(null)] on success. Returns [Err] on validation or DB failure.
  ///
  /// Parameters:
  /// - [input]: Close parameters including the template [id] and optional
  ///   total update.
  Future<Result<void>> call(CloseInstallmentPlanInput input) async {
    // 1. Load the current template to verify it is eligible to be closed.
    final template = await _templateRepository.watchById(input.id).first;

    if (template == null) {
      return const Err(NotFoundFailure('Installment template not found'));
    }

    // Guard: already-archived templates cannot be closed again.
    if (template.status == RecurringTemplateStatus.archived) {
      return const Err(
        BusinessRuleFailure(
          'Template is already archived and cannot be closed again',
        ),
      );
    }

    // 2. Cancel all pending occurrences.
    final closeResult = await _planRepository.closeEarly(input.id);
    if (closeResult case Err(:final failure)) {
      return Err(failure);
    }

    // 3. Archive the template.
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final archived = template.copyWith(
      status: RecurringTemplateStatus.archived,
      archivedAt: now,
      archivedReason: ArchivedReason.earlyClose,
    );
    final archiveResult = await _templateRepository.update(archived);
    if (archiveResult case Err(:final failure)) {
      return Err(failure);
    }

    // 4. Optionally update totalConfiguredMinor to match running total (TC-021).
    if (input.updateTotalOnEarlyClose && input.newTotalMinor != null) {
      // Read the current plan to preserve fields other than totalConfiguredMinor.
      final plan = await _planRepository.watchById(input.id).first;
      if (plan != null) {
        final updatedPlan = InstallmentPlan(
          templateId: plan.templateId,
          totalConfiguredMinor: input.newTotalMinor!,
          numberOfInstallments: plan.numberOfInstallments,
          createdAt: plan.createdAt,
        );
        final updateResult = await _planRepository.update(updatedPlan);
        if (updateResult case Err(:final failure)) {
          return Err(failure);
        }
      }
    }

    return const Ok(null);
  }
}
