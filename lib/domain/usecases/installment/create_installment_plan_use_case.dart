// lib/domain/usecases/installment/create_installment_plan_use_case.dart
//
// Use case: create a new installment plan.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';

/// Input pairing the installment template with its plan metadata.
class CreateInstallmentPlanInput {
  const CreateInstallmentPlanInput({
    required this.template,
    required this.plan,
  });

  /// The recurring template (isInstallment = true).
  final RecurringTemplate template;

  /// The plan metadata.
  final InstallmentPlan plan;
}

/// Creates a new installment plan together with its template and eagerly
/// materializes all installment occurrences.
class CreateInstallmentPlanUseCase {
  const CreateInstallmentPlanUseCase(this._repository);

  // ignore: unused_field
  final IInstallmentPlanRepository _repository;

  /// Executes the use case.
  Future<Result<InstallmentPlan>> call(CreateInstallmentPlanInput input) {
    throw UnimplementedError(
      'CreateInstallmentPlanUseCase.call is not implemented',
    );
  }
}
