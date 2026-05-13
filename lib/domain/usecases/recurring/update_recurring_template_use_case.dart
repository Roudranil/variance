// lib/domain/usecases/recurring/update_recurring_template_use_case.dart
//
// Use case: update editable fields of a recurring template.
//
// Business rules enforced here (RECUR-02):
//   - Only these fields may be changed: amountMinor, accountSourceId,
//     accountDestinationId, categoryId, subcategoryId, title, description,
//     postingBehaviour, feeMode, feeAmountMinor, feePercentageMicro,
//     feeCategoryId.
//   - Immutable fields: transactionType, recurrenceN, recurrenceUnit,
//     recurrenceConstraints, startDate, endDate.
//   - If the caller supplies a value that differs from the persisted value
//     for any immutable field, the use case returns
//     Err(BusinessRuleFailure('immutable_field')).
//   - On valid input, delegates to IRecurringTemplateRepository.update which
//     sets updated_at = now().
//
// Spec: T-110, RECUR-02, API Contracts §2.6.3, Data Model §7.1
//
// Test cases (see test/unit/domain/usecases/update_recurring_template_use_case_test.dart):
//   1. Valid edit of amount → Ok(template) with updated amount.
//   2. Attempt to change transactionType → Err(BusinessRuleFailure).
//   3. Attempt to change recurrenceN → Err(BusinessRuleFailure).
//   4. Attempt to change recurrenceUnit → Err(BusinessRuleFailure).
//   5. Attempt to change recurrenceConstraints → Err(BusinessRuleFailure).
//   6. Attempt to change startDate → Err(BusinessRuleFailure).
//   7. Attempt to change endDate → Err(BusinessRuleFailure).
//   8. Template not found → Err(NotFoundFailure).

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';

/// Updates mutable fields of an existing recurring template.
///
/// Immutable fields (transactionType, recurrenceN, recurrenceUnit,
/// recurrenceConstraints, startDate, endDate) are validated against the
/// persisted values. Any attempt to change them returns a
/// [BusinessRuleFailure] with key 'immutable_field'.
///
/// Only editable fields are passed through to the repository: amountMinor,
/// accountSourceId, accountDestinationId, categoryId, subcategoryId, title,
/// description, postingBehaviour, and the fee-related fields.
class UpdateRecurringTemplateUseCase {
  /// Creates an [UpdateRecurringTemplateUseCase].
  ///
  /// Parameters:
  /// - [repository]: Repository for template data access.
  const UpdateRecurringTemplateUseCase(this._repository);

  final IRecurringTemplateRepository _repository;

  /// Validates [template] and persists only its editable fields.
  ///
  /// Loads the current persisted template to check immutable fields. Returns
  /// [Ok] wrapping the updated [RecurringTemplate] on success. Returns [Err]
  /// on validation or persistence failure.
  ///
  /// Parameters:
  /// - [template]: Template entity with desired new values. The [template.id]
  ///   must match an existing record.
  Future<Result<RecurringTemplate>> call(RecurringTemplate template) async {
    // Load current state to verify immutable fields.
    final current = await _repository.watchById(template.id).first;
    if (current == null) {
      return Err(
        NotFoundFailure('Recurring template ${template.id} not found.'),
      );
    }

    // Guard immutable fields.
    if (template.transactionType != current.transactionType) {
      return const Err(
        BusinessRuleFailure(
          'immutable_field: transactionType cannot be changed',
        ),
      );
    }
    if (template.recurrenceN != current.recurrenceN) {
      return const Err(
        BusinessRuleFailure('immutable_field: recurrenceN cannot be changed'),
      );
    }
    if (template.recurrenceUnit != current.recurrenceUnit) {
      return const Err(
        BusinessRuleFailure(
          'immutable_field: recurrenceUnit cannot be changed',
        ),
      );
    }
    if (!_constraintsEqual(
      template.recurrenceConstraints,
      current.recurrenceConstraints,
    )) {
      return const Err(
        BusinessRuleFailure(
          'immutable_field: recurrenceConstraints cannot be changed',
        ),
      );
    }
    if (template.startDate != current.startDate) {
      return const Err(
        BusinessRuleFailure('immutable_field: startDate cannot be changed'),
      );
    }
    if (template.endDate != current.endDate) {
      return const Err(
        BusinessRuleFailure('immutable_field: endDate cannot be changed'),
      );
    }

    return _repository.update(template);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns true when two [RecurrenceConstraint] lists are equal.
  ///
  /// Two null values are considered equal. A null and an empty list are
  /// considered equal (both mean "no constraints").
  bool _constraintsEqual(
    List<RecurrenceConstraint>? a,
    List<RecurrenceConstraint>? b,
  ) {
    final normalA = a ?? const [];
    final normalB = b ?? const [];
    if (normalA.length != normalB.length) return false;
    for (var i = 0; i < normalA.length; i++) {
      if (normalA[i] != normalB[i]) return false;
    }
    return true;
  }
}
