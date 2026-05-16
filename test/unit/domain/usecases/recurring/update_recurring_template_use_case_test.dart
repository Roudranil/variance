// test/unit/domain/usecases/recurring/update_recurring_template_use_case_test.dart
//
// Unit tests for UpdateRecurringTemplateUseCase (T-110).
//
// Test cases:
//   1. Valid edit of amount → Ok(template) with updated amount.
//   2. Attempt to change transactionType → Err(BusinessRuleFailure).
//   3. Attempt to change recurrenceN → Err(BusinessRuleFailure).
//   4. Attempt to change recurrenceUnit → Err(BusinessRuleFailure).
//   5. Attempt to change recurrenceConstraints → Err(BusinessRuleFailure).
//   6. Attempt to change startDate → Err(BusinessRuleFailure).
//   7. Attempt to change endDate → Err(BusinessRuleFailure).
//   8. Template not found → Err(NotFoundFailure).

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/recurring/update_recurring_template_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({this.stored, this.updateError});

  final RecurringTemplate? stored;
  final Failure? updateError;

  RecurringTemplate? lastUpdated;

  @override
  Stream<RecurringTemplate?> watchById(String id) {
    if (stored == null || stored!.id != id) return Stream.value(null);
    return Stream.value(stored);
  }

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) async {
    lastUpdated = template;
    if (updateError != null) return Err(updateError!);
    return Ok(template);
  }

  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value([]);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) async =>
      Ok(template);

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async => const Ok(null);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _baseTemplate = RecurringTemplate(
  id: 'tpl-001',
  transactionType: 'expense',
  amountMinor: 10000,
  currencyCode: 'INR',
  accountSourceId: 'acc-001',
  recurrenceN: 1,
  recurrenceUnit: RecurrenceUnit.month,
  recurrenceConstraints: null,
  startDate: 20000,
  endDate: null,
  createdAt: 1000000,
  updatedAt: 1000000,
);

void main() {
  group('UpdateRecurringTemplateUseCase', () {
    // -------------------------------------------------------------------------
    // 1. Valid edit of amount
    // -------------------------------------------------------------------------
    test('valid edit of amount returns Ok with updated template', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(amountMinor: 20000);
      final result = await useCase(updated);

      expect(result, isA<Ok<RecurringTemplate>>());
      final ok = result as Ok<RecurringTemplate>;
      expect(ok.value.amountMinor, 20000);
      expect(repo.lastUpdated?.amountMinor, 20000);
    });

    // -------------------------------------------------------------------------
    // 2. Attempt to change transactionType
    // -------------------------------------------------------------------------
    test('changing transactionType returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(transactionType: 'income');
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      final err = result as Err<RecurringTemplate>;
      expect(err.failure, isA<BusinessRuleFailure>());
      expect(err.failure.message, contains('immutable_field'));
    });

    // -------------------------------------------------------------------------
    // 3. Attempt to change recurrenceN
    // -------------------------------------------------------------------------
    test('changing recurrenceN returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(recurrenceN: 3);
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      expect((result as Err<RecurringTemplate>).failure, isA<BusinessRuleFailure>());
    });

    // -------------------------------------------------------------------------
    // 4. Attempt to change recurrenceUnit
    // -------------------------------------------------------------------------
    test('changing recurrenceUnit returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(recurrenceUnit: RecurrenceUnit.week);
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      expect(
        (result as Err<RecurringTemplate>).failure,
        isA<BusinessRuleFailure>(),
      );
    });

    // -------------------------------------------------------------------------
    // 5. Attempt to change recurrenceConstraints
    // -------------------------------------------------------------------------
    test('changing recurrenceConstraints returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(
        recurrenceConstraints: [RecurrenceConstraint.weekdaysOnly],
      );
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      expect(
        (result as Err<RecurringTemplate>).failure,
        isA<BusinessRuleFailure>(),
      );
    });

    // -------------------------------------------------------------------------
    // 6. Attempt to change startDate
    // -------------------------------------------------------------------------
    test('changing startDate returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(startDate: 99999);
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      expect(
        (result as Err<RecurringTemplate>).failure,
        isA<BusinessRuleFailure>(),
      );
    });

    // -------------------------------------------------------------------------
    // 7. Attempt to change endDate
    // -------------------------------------------------------------------------
    test('changing endDate returns BusinessRuleFailure', () async {
      final repo = _FakeTemplateRepository(stored: _baseTemplate);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final updated = _baseTemplate.copyWith(endDate: 30000);
      final result = await useCase(updated);

      expect(result, isA<Err<RecurringTemplate>>());
      expect(
        (result as Err<RecurringTemplate>).failure,
        isA<BusinessRuleFailure>(),
      );
    });

    // -------------------------------------------------------------------------
    // 8. Template not found
    // -------------------------------------------------------------------------
    test('template not found returns NotFoundFailure', () async {
      final repo = _FakeTemplateRepository(stored: null);
      final useCase = UpdateRecurringTemplateUseCase(repo);

      final result = await useCase(_baseTemplate);

      expect(result, isA<Err<RecurringTemplate>>());
      expect(
        (result as Err<RecurringTemplate>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });
}
