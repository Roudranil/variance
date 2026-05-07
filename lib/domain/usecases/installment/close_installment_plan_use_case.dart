// lib/domain/usecases/installment/close_installment_plan_use_case.dart
//
// Use case: close an installment plan early.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';

/// Closes the installment plan identified by [id] early.
///
/// Cancels all pending installment occurrences and archives the template.
class CloseInstallmentPlanUseCase {
  const CloseInstallmentPlanUseCase(this._repository);

  // ignore: unused_field
  final IInstallmentPlanRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(String id) {
    throw UnimplementedError(
      'CloseInstallmentPlanUseCase.call is not implemented',
    );
  }
}
