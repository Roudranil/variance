// test/unit/domain/usecases/create_installment_plan_use_case_test.dart
//
// Unit tests for CreateInstallmentPlanUseCase (T-130, T-131, T-143).
//
// Uses a fake IInstallmentPlanRepository to avoid database I/O.
//
// Test cases (T-143):
//   T-143.1  income type — correct number of occurrences materialised,
//            end date correct, per-installment amounts sum to total.
//   T-143.2  expense type — same structural guarantees as income.
//   T-143.3  transfer type — accountSourceId and accountDestinationId populated.
//   T-143.4  transfer-with-fee — fee columns populated on template row.
//   T-143.5  totalConfigured = 0 → Err(ValidationFailure).
//   T-143.6  numberOfInstallments = 0 → Err(ValidationFailure).
//   T-143.7  manual per-installment overrides sum ≠ totalConfigured —
//            creation succeeds (mismatch is non-blocking).
//   T-143.8  DB failure during createAtomic → Err(DatabaseFailure) returned,
//            no partial rows (full rollback is the repository's responsibility).
//   T-131.1  transfer source == destination → Err(ValidationFailure).
//   T-131.2  transfer missing source → Err(ValidationFailure).
//   T-131.3  transfer missing destination → Err(ValidationFailure).

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/services/period_calculator.dart';
import 'package:variance/domain/usecases/installment/create_installment_plan_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

/// Captures the most recent [createAtomic] call for test assertions.
class _FakeInstallmentPlanRepository implements IInstallmentPlanRepository {
  RecurringTemplate? capturedTemplate;
  InstallmentPlan? capturedPlan;
  List<InstallmentOccurrence>? capturedOccurrences;

  /// When true, [createAtomic] returns [Err(DatabaseFailure)].
  bool failAtomic = false;

  @override
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<InstallmentOccurrence> occurrences,
  }) async {
    if (failAtomic) {
      return const Err(DatabaseFailure('Simulated DB failure'));
    }
    capturedTemplate = template;
    capturedPlan = plan;
    capturedOccurrences = occurrences;
    return Ok(plan);
  }

  @override
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan) async =>
      Ok(plan);

  @override
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan) async =>
      Ok(plan);

  @override
  Future<Result<void>> closeEarly(String id) async => const Ok(null);

  @override
  Stream<List<InstallmentPlan>> watchAll() => const Stream.empty();

  @override
  Stream<InstallmentPlan?> watchById(String id) => const Stream.empty();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Base valid income input for tests that only need to vary one field.
CreateInstallmentPlanInput _incomeInput({
  int totalConfiguredMinor = 12000,
  int numberOfInstallments = 12,
  String transactionType = 'income',
  String? accountSourceId,
  String? accountDestinationId = 'acc-dest-1',
  List<int>? perInstallmentAmountsMinor,
  FeeMode? feeMode,
  int? feeAmountMinor,
  int? feePercentageMicro,
  String? feeCategoryId,
}) {
  return CreateInstallmentPlanInput(
    transactionType: transactionType,
    totalConfiguredMinor: totalConfiguredMinor,
    numberOfInstallments: numberOfInstallments,
    startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
    recurrenceN: 1,
    recurrenceUnit: RecurrenceUnit.month,
    currencyCode: 'INR',
    accountSourceId: accountSourceId,
    accountDestinationId: accountDestinationId,
    perInstallmentAmountsMinor: perInstallmentAmountsMinor,
    feeMode: feeMode,
    feeAmountMinor: feeAmountMinor,
    feePercentageMicro: feePercentageMicro,
    feeCategoryId: feeCategoryId,
  );
}

CreateInstallmentPlanUseCase _makeUseCase(
  _FakeInstallmentPlanRepository repo,
) {
  return CreateInstallmentPlanUseCase(
    planRepository: repo,
    periodCalculator: const PeriodCalculator(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CreateInstallmentPlanUseCase', () {
    late _FakeInstallmentPlanRepository repo;
    late CreateInstallmentPlanUseCase useCase;

    setUp(() {
      repo = _FakeInstallmentPlanRepository();
      useCase = _makeUseCase(repo);
    });

    // ---- T-143.1 Income type ------------------------------------------------

    test('T-143.1 income type materialises correct occurrences and sums', () async {
      final result = await useCase(_incomeInput(
        transactionType: 'income',
        totalConfiguredMinor: 12000,
        numberOfInstallments: 12,
      ));

      expect(result, isA<Ok<InstallmentPlan>>());

      final occurrences = repo.capturedOccurrences!;
      expect(occurrences.length, 12);

      // All statuses pending.
      expect(occurrences.every((o) => o.status == InstallmentOccurrenceStatus.pending), isTrue);

      // Sequence numbers 1-based and sequential.
      final seqNumbers = occurrences.map((o) => o.sequenceNumber).toList();
      expect(seqNumbers, List.generate(12, (i) => i + 1));

      // Sum of per-installment amounts equals total.
      final sum = occurrences.fold(0, (acc, o) => acc + o.amountMinor);
      expect(sum, 12000);

      // End date is after start date.
      final plan = repo.capturedPlan!;
      final template = repo.capturedTemplate!;
      expect(template.endDate, isNotNull);
      expect(template.endDate! > template.startDate, isTrue);

      // Plan fields.
      expect(plan.totalConfiguredMinor, 12000);
      expect(plan.numberOfInstallments, 12);
      expect(plan.templateId, template.id);

      // Template is_installment.
      expect(template.isInstallment, isTrue);
      expect(template.transactionType, 'income');
    });

    // ---- T-143.2 Expense type -----------------------------------------------

    test('T-143.2 expense type — same structural guarantees', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'expense',
        totalConfiguredMinor: 6000,
        numberOfInstallments: 6,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'acc-src-1',
      );

      final result = await useCase(input);
      expect(result, isA<Ok<InstallmentPlan>>());

      final occurrences = repo.capturedOccurrences!;
      expect(occurrences.length, 6);

      final sum = occurrences.fold(0, (acc, o) => acc + o.amountMinor);
      expect(sum, 6000);

      expect(repo.capturedTemplate!.transactionType, 'expense');
    });

    // ---- T-143.3 Transfer type -----------------------------------------------

    test('T-143.3 transfer type — source and destination populated', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 24000,
        numberOfInstallments: 24,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'acc-src-1',
        accountDestinationId: 'acc-dst-1',
      );

      final result = await useCase(input);
      expect(result, isA<Ok<InstallmentPlan>>());

      final template = repo.capturedTemplate!;
      expect(template.accountSourceId, 'acc-src-1');
      expect(template.accountDestinationId, 'acc-dst-1');
      expect(template.transactionType, 'transfer');
    });

    // ---- T-143.4 Transfer with fee ------------------------------------------

    test('T-143.4 transfer-with-fee — fee columns on template row', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 10000,
        numberOfInstallments: 10,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'acc-src-1',
        accountDestinationId: 'acc-dst-1',
        feeMode: FeeMode.flat,
        feeAmountMinor: 100,
        feeCategoryId: 'cat-fee-1',
      );

      final result = await useCase(input);
      expect(result, isA<Ok<InstallmentPlan>>());

      final template = repo.capturedTemplate!;
      expect(template.feeMode, FeeMode.flat);
      expect(template.feeAmountMinor, 100);
      expect(template.feeCategoryId, 'cat-fee-1');
    });

    test('T-143.4b transfer-with-percentage-fee — fee columns on template row', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 10000,
        numberOfInstallments: 10,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'acc-src-1',
        accountDestinationId: 'acc-dst-1',
        feeMode: FeeMode.percentage,
        feePercentageMicro: 20000, // 2%
        feeCategoryId: 'cat-fee-1',
      );

      final result = await useCase(input);
      expect(result, isA<Ok<InstallmentPlan>>());

      final template = repo.capturedTemplate!;
      expect(template.feeMode, FeeMode.percentage);
      expect(template.feePercentageMicro, 20000);
    });

    // ---- T-143.5 Validation: totalConfigured = 0 ----------------------------

    test('T-143.5 totalConfiguredMinor = 0 → Err(ValidationFailure)', () async {
      final result = await useCase(_incomeInput(totalConfiguredMinor: 0));
      expect(result, isA<Err<InstallmentPlan>>());
      final err = (result as Err<InstallmentPlan>).failure;
      expect(err, isA<ValidationFailure>());
    });

    test('T-143.5b totalConfiguredMinor < 0 → Err(ValidationFailure)', () async {
      final result = await useCase(_incomeInput(totalConfiguredMinor: -100));
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    // ---- T-143.6 Validation: numberOfInstallments = 0 -----------------------

    test('T-143.6 numberOfInstallments = 0 → Err(ValidationFailure)', () async {
      final result = await useCase(_incomeInput(numberOfInstallments: 0));
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    test('T-143.6b numberOfInstallments < 0 → Err(ValidationFailure)', () async {
      final result = await useCase(_incomeInput(numberOfInstallments: -5));
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    // ---- T-143.7 Manual overrides that mismatch total — succeeds ------------

    test('T-143.7 manual per-installment overrides ≠ total — succeeds (non-blocking)', () async {
      // Overrides sum to 13000, not 12000. Should still create successfully.
      final result = await useCase(_incomeInput(
        totalConfiguredMinor: 12000,
        numberOfInstallments: 3,
        perInstallmentAmountsMinor: [5000, 4000, 4000], // sum = 13000 ≠ 12000
      ));

      expect(result, isA<Ok<InstallmentPlan>>());

      final occurrences = repo.capturedOccurrences!;
      expect(occurrences.length, 3);
      expect(occurrences.map((o) => o.amountMinor).toList(), [5000, 4000, 4000]);
      // Plan stores the configured total, not the overridden sum.
      expect(repo.capturedPlan!.totalConfiguredMinor, 12000);
    });

    // ---- T-143.8 DB failure → Err(DatabaseFailure) -------------------------

    test('T-143.8 DB failure → propagates Err(DatabaseFailure)', () async {
      repo.failAtomic = true;
      final result = await useCase(_incomeInput());
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<DatabaseFailure>());
    });

    // ---- T-131 Transfer validation ------------------------------------------

    test('T-131.1 transfer source == destination → Err(ValidationFailure)', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 10000,
        numberOfInstallments: 10,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'same-acc',
        accountDestinationId: 'same-acc', // same as source
      );

      final result = await useCase(input);
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    test('T-131.2 transfer missing source → Err(ValidationFailure)', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 10000,
        numberOfInstallments: 10,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountDestinationId: 'acc-dst-1',
        // accountSourceId intentionally omitted
      );

      final result = await useCase(input);
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    test('T-131.3 transfer missing destination → Err(ValidationFailure)', () async {
      final input = CreateInstallmentPlanInput(
        transactionType: 'transfer',
        totalConfiguredMinor: 10000,
        numberOfInstallments: 10,
        startDate: DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        currencyCode: 'INR',
        accountSourceId: 'acc-src-1',
        // accountDestinationId intentionally omitted
      );

      final result = await useCase(input);
      expect(result, isA<Err<InstallmentPlan>>());
      expect((result as Err<InstallmentPlan>).failure, isA<ValidationFailure>());
    });

    // ---- End-date correctness for fixed-length periods ----------------------

    test('end date for weekly recurrence is start + N*7 days', () async {
      final startEpochDays =
          DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000);
      final input = CreateInstallmentPlanInput(
        transactionType: 'income',
        totalConfiguredMinor: 400,
        numberOfInstallments: 4,
        startDate: startEpochDays,
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        currencyCode: 'INR',
        accountDestinationId: 'acc-dst-1',
      );

      final result = await useCase(input);
      expect(result, isA<Ok<InstallmentPlan>>());

      // End = start + 4 weeks = start + 28 days.
      final template = repo.capturedTemplate!;
      expect(template.endDate, startEpochDays + 28);
    });

    test('occurrences are scheduled at correct dates for weekly plan', () async {
      final startEpochDays =
          DateTime(2025).millisecondsSinceEpoch ~/ (86400 * 1000);
      final input = CreateInstallmentPlanInput(
        transactionType: 'income',
        totalConfiguredMinor: 400,
        numberOfInstallments: 4,
        startDate: startEpochDays,
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        currencyCode: 'INR',
        accountDestinationId: 'acc-dst-1',
      );

      await useCase(input);
      final occs = repo.capturedOccurrences!;

      expect(occs[0].scheduledDate, startEpochDays);
      expect(occs[1].scheduledDate, startEpochDays + 7);
      expect(occs[2].scheduledDate, startEpochDays + 14);
      expect(occs[3].scheduledDate, startEpochDays + 21);
    });

    // ---- Remainder assignment -----------------------------------------------

    test('integer division remainder assigned to last occurrence', () async {
      // 10000 ÷ 3 = 3333 r1; last gets 3334.
      final result = await useCase(_incomeInput(
        totalConfiguredMinor: 10000,
        numberOfInstallments: 3,
      ));

      expect(result, isA<Ok<InstallmentPlan>>());
      final occs = repo.capturedOccurrences!;
      expect(occs[0].amountMinor, 3333);
      expect(occs[1].amountMinor, 3333);
      expect(occs[2].amountMinor, 3334);
      expect(occs.fold(0, (s, o) => s + o.amountMinor), 10000);
    });
  });
}
