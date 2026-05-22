// test/unit/domain/usecases/close_installment_plan_use_case_test.dart
//
// Unit tests for CloseInstallmentPlanUseCase (T-144).
//
// Uses hand-written fake repositories — no database I/O.
//
// Test cases (T-144):
//   T-144.1  no-final-payment path: pending occurrences cancelled, template archived
//   T-144.2  updateTotalOnEarlyClose=true updates totalConfiguredMinor to newTotalMinor
//   T-144.3  already-archived template → Err(BusinessRuleFailure)
//   T-144.4  non-existent template → Err(NotFoundFailure)
//   T-144.5  closeEarly repository failure → Err(DatabaseFailure) propagated
//   T-144.6  archive template repository failure → Err propagated
//   T-144.7  updateTotalOnEarlyClose=false leaves totalConfiguredMinor unchanged

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/installment/close_installment_plan_use_case.dart';

// ---------------------------------------------------------------------------
// Fake IInstallmentPlanRepository
// ---------------------------------------------------------------------------

class _FakeInstallmentPlanRepository implements IInstallmentPlanRepository {
  _FakeInstallmentPlanRepository({
    required this.plan,
    this.failCloseEarly = false,
  });

  final InstallmentPlan? plan;
  final bool failCloseEarly;

  bool closeEarlyCalled = false;
  InstallmentPlan? updatedPlan;

  @override
  Stream<List<InstallmentPlan>> watchAll() => const Stream.empty();

  @override
  Stream<InstallmentPlan?> watchById(String id) =>
      Stream.value(plan?.templateId == id ? plan : null);

  @override
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<InstallmentOccurrence> occurrences,
  }) async =>
      Ok(plan);

  @override
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan) async =>
      Ok(plan);

  @override
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan) async {
    updatedPlan = plan;
    return Ok(plan);
  }

  @override
  Future<Result<void>> closeEarly(String id) async {
    closeEarlyCalled = true;
    if (failCloseEarly) {
      return const Err(DatabaseFailure('Simulated close failure'));
    }
    return const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Fake IRecurringTemplateRepository
// ---------------------------------------------------------------------------

class _FakeRecurringTemplateRepository implements IRecurringTemplateRepository {
  _FakeRecurringTemplateRepository({this.template, this.failUpdate = false});

  final RecurringTemplate? template;
  final bool failUpdate;

  RecurringTemplate? updatedTemplate;

  @override
  Stream<List<RecurringTemplate>> watchAll() => const Stream.empty();

  @override
  Stream<RecurringTemplate?> watchById(String id) =>
      Stream.value(template?.id == id ? template : null);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async {
    if (failUpdate) {
      return const Err(DatabaseFailure('Simulated archive failure'));
    }
    updatedTemplate = t;
    return Ok(t);
  }

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async =>
      const Ok(null);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _baseTemplate = RecurringTemplate(
  id: 'tmpl-close-1',
  transactionType: 'expense',
  status: RecurringTemplateStatus.active,
  amountMinor: 10000,
  currencyCode: 'INR',
  recurrenceN: 1,
  recurrenceUnit: RecurrenceUnit.month,
  startDate: 20000,
  isInstallment: true,
  createdAt: 1700000000,
  updatedAt: 1700000000,
);

final _basePlan = InstallmentPlan(
  templateId: 'tmpl-close-1',
  totalConfiguredMinor: 120000,
  numberOfInstallments: 12,
  createdAt: 1700000000,
);

CloseInstallmentPlanUseCase _makeUseCase({
  InstallmentPlan? plan,
  RecurringTemplate? template,
  bool failCloseEarly = false,
  bool failUpdateTemplate = false,
}) {
  return CloseInstallmentPlanUseCase(
    planRepository: _FakeInstallmentPlanRepository(
      plan: plan ?? _basePlan,
      failCloseEarly: failCloseEarly,
    ),
    templateRepository: _FakeRecurringTemplateRepository(
      template: template ?? _baseTemplate,
      failUpdate: failUpdateTemplate,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CloseInstallmentPlanUseCase', () {
    // ---- T-144.1 No-final-payment path ---------------------------------------

    test('T-144.1 no-final-payment: closeEarly called, template archived',
        () async {
      final planRepo = _FakeInstallmentPlanRepository(plan: _basePlan);
      final templateRepo = _FakeRecurringTemplateRepository(
        template: _baseTemplate,
      );
      final useCase = CloseInstallmentPlanUseCase(
        planRepository: planRepo,
        templateRepository: templateRepo,
      );

      final result = await useCase(
        const CloseInstallmentPlanInput(id: 'tmpl-close-1'),
      );

      expect(result, isA<Ok<void>>());
      expect(planRepo.closeEarlyCalled, isTrue);
      expect(
        templateRepo.updatedTemplate?.status,
        RecurringTemplateStatus.archived,
      );
      expect(
        templateRepo.updatedTemplate?.archivedReason,
        ArchivedReason.earlyClose,
      );
    });

    // ---- T-144.2 updateTotalOnEarlyClose = true ------------------------------

    test('T-144.2 updateTotalOnEarlyClose=true sets totalConfiguredMinor',
        () async {
      final planRepo = _FakeInstallmentPlanRepository(plan: _basePlan);
      final templateRepo = _FakeRecurringTemplateRepository(
        template: _baseTemplate,
      );
      final useCase = CloseInstallmentPlanUseCase(
        planRepository: planRepo,
        templateRepository: templateRepo,
      );

      final result = await useCase(
        const CloseInstallmentPlanInput(
          id: 'tmpl-close-1',
          updateTotalOnEarlyClose: true,
          newTotalMinor: 75000,
        ),
      );

      expect(result, isA<Ok<void>>());
      // Plan's totalConfiguredMinor must be updated to 75000.
      expect(planRepo.updatedPlan?.totalConfiguredMinor, 75000);
    });

    // ---- T-144.3 Already archived → BusinessRuleFailure ----------------------

    test('T-144.3 already-archived template → Err(BusinessRuleFailure)',
        () async {
      final archivedTemplate = _baseTemplate.copyWith(
        status: RecurringTemplateStatus.archived,
        archivedAt: 1700000000,
        archivedReason: ArchivedReason.earlyClose,
      );
      final useCase = _makeUseCase(template: archivedTemplate);

      final result = await useCase(
        const CloseInstallmentPlanInput(id: 'tmpl-close-1'),
      );

      expect(result, isA<Err<void>>());
      final failure = (result as Err<void>).failure;
      expect(failure, isA<BusinessRuleFailure>());
    });

    // ---- T-144.4 Non-existent template → NotFoundFailure ---------------------

    test('T-144.4 non-existent template → Err(NotFoundFailure)', () async {
      // templateRepo returns null for 'tmpl-not-found'.
      final planRepo = _FakeInstallmentPlanRepository(plan: null);
      final templateRepo = _FakeRecurringTemplateRepository(template: null);
      final useCase = CloseInstallmentPlanUseCase(
        planRepository: planRepo,
        templateRepository: templateRepo,
      );

      final result = await useCase(
        const CloseInstallmentPlanInput(id: 'tmpl-not-found'),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<NotFoundFailure>());
    });

    // ---- T-144.5 closeEarly failure → DatabaseFailure propagated -------------

    test('T-144.5 closeEarly failure → Err(DatabaseFailure) propagated',
        () async {
      final useCase = _makeUseCase(failCloseEarly: true);

      final result = await useCase(
        const CloseInstallmentPlanInput(id: 'tmpl-close-1'),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<DatabaseFailure>());
    });

    // ---- T-144.6 Archive template failure propagated -------------------------

    test('T-144.6 archive template failure propagated', () async {
      final useCase = _makeUseCase(failUpdateTemplate: true);

      final result = await useCase(
        const CloseInstallmentPlanInput(id: 'tmpl-close-1'),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<DatabaseFailure>());
    });

    // ---- T-144.7 updateTotalOnEarlyClose=false leaves total unchanged --------

    test(
        'T-144.7 updateTotalOnEarlyClose=false leaves totalConfiguredMinor unchanged',
        () async {
      final planRepo = _FakeInstallmentPlanRepository(plan: _basePlan);
      final templateRepo = _FakeRecurringTemplateRepository(
        template: _baseTemplate,
      );
      final useCase = CloseInstallmentPlanUseCase(
        planRepository: planRepo,
        templateRepository: templateRepo,
      );

      final result = await useCase(
        const CloseInstallmentPlanInput(
          id: 'tmpl-close-1',
          updateTotalOnEarlyClose: false,
        ),
      );

      expect(result, isA<Ok<void>>());
      // Plan.update must NOT have been called.
      expect(planRepo.updatedPlan, isNull);
    });
  });
}
