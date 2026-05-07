// lib/domain/usecases/home/get_catch_up_banner_use_case.dart
//
// Use case: retrieve overdue recurring templates for the catch-up banner.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Returns all recurring templates with overdue (past-due) pending occurrences.
///
/// The count of returned templates drives the "Catch up" alert strip on the
/// home screen.
class GetCatchUpBannerUseCase {
  const GetCatchUpBannerUseCase(this._repository);

  // ignore: unused_field
  final IRecurringTemplateRepository _repository;

  /// Executes the use case.
  Future<Result<List<RecurringTemplate>>> call() {
    throw UnimplementedError(
      'GetCatchUpBannerUseCase.call is not implemented',
    );
  }
}
