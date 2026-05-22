// lib/domain/usecases/installment/create_installment_plan_use_case.dart
//
// CreateInstallmentPlanUseCase — create a new installment plan.
//
// Responsibilities:
//   - Validate all inputs (T-130, T-131)
//   - Insert recurring_templates row (is_installment = 1)
//   - Insert installment_plans row
//   - Bulk-insert all installment_occurrences eagerly
//   - Compute end_date = start_date + (N × recurrence_period) via PeriodCalculator
//   - Compute per-installment amounts; assign remainder to last occurrence
//   - Support income, expense, transfer (with fee) transaction types (T-131)
//
// Constraints (SDS §1.6.2, §1.6.10):
//   - All three inserts in a single DB transaction (ACID).
//   - End date computed O(1) via PeriodCalculator — no iteration loops.
//   - Transfer: account_source_id and account_destination_id required, non-equal.
//   - Mismatch between sum of per-installment amounts and total_configured is
//     non-blocking (allowed by spec); the caller must surface a warning at UI.
//
// Spec: T-130, T-131, T-143
//
// Test cases (see test/unit/domain/usecases/create_installment_plan_use_case_test.dart):
//   T-143.1. income type — correct occurrences materialised, end date correct
//   T-143.2. expense type — same as above
//   T-143.3. transfer type — source and destination populated
//   T-143.4. transfer-with-fee — fee columns populated on template row
//   T-143.5. total_configured = 0 → Err(ValidationFailure)
//   T-143.6. number_of_installments = 0 → Err(ValidationFailure)
//   T-143.7. manual per-installment overrides that sum ≠ total_configured — succeeds
//   T-143.8. DB failure during bulk occurrence insert → propagates Err(DatabaseFailure)

import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/services/period_calculator.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// Input model for [CreateInstallmentPlanUseCase].
///
/// Carries all fields needed to create an installment plan template and its
/// eagerly materialised occurrence records.
class CreateInstallmentPlanInput {
  /// Creates a [CreateInstallmentPlanInput].
  ///
  /// Parameters:
  /// - [transactionType]: One of 'income', 'expense', 'transfer'.
  /// - [totalConfiguredMinor]: Target total in minor units. Must be > 0.
  /// - [numberOfInstallments]: Number of occurrences to materialise. Must be > 0.
  /// - [startDate]: First occurrence date as Unix epoch days.
  /// - [recurrenceN]: Cadence multiplier (e.g. 1 for monthly).
  /// - [recurrenceUnit]: Time unit for each period.
  /// - [currencyCode]: ISO 4217 currency code.
  /// - [accountSourceId]: Required for expense/transfer.
  /// - [accountDestinationId]: Required for income/transfer.
  /// - [categoryId]: Required for income/expense; null for transfer.
  /// - [subcategoryId]: Optional subcategory.
  /// - [payeeId]: Optional payee UUID.
  /// - [title]: Optional template label.
  /// - [description]: Optional long-form note.
  /// - [postingBehaviour]: Auto-post or remind-and-confirm.
  /// - [feeMode]: Transfer fee mode; null = no fee.
  /// - [feeAmountMinor]: Flat fee in minor units.
  /// - [feePercentageMicro]: Percentage fee × 1,000,000.
  /// - [feeCategoryId]: Fee expense category UUID.
  /// - [perInstallmentAmountsMinor]: Optional manual overrides for each
  ///   occurrence amount. When provided, must have length [numberOfInstallments].
  ///   If null, amounts are auto-calculated as total ÷ count with the remainder
  ///   assigned to the last occurrence.
  const CreateInstallmentPlanInput({
    required this.transactionType,
    required this.totalConfiguredMinor,
    required this.numberOfInstallments,
    required this.startDate,
    required this.recurrenceN,
    required this.recurrenceUnit,
    required this.currencyCode,
    this.accountSourceId,
    this.accountDestinationId,
    this.categoryId,
    this.subcategoryId,
    this.payeeId,
    this.title,
    this.description,
    this.postingBehaviour = PostingBehaviour.autoPost,
    this.feeMode,
    this.feeAmountMinor,
    this.feePercentageMicro,
    this.feeCategoryId,
    this.perInstallmentAmountsMinor,
  });

  /// Financial direction: 'income', 'expense', or 'transfer'.
  final String transactionType;

  /// Target total amount in minor units. Immutable after creation.
  final int totalConfiguredMinor;

  /// Number of installment occurrences to eagerly materialise.
  final int numberOfInstallments;

  /// First occurrence date as Unix epoch days (seconds ÷ 86400).
  final int startDate;

  /// Cadence multiplier (e.g. 1 for "every 1 month").
  final int recurrenceN;

  /// Time unit for the recurrence cadence.
  final RecurrenceUnit recurrenceUnit;

  /// ISO 4217 currency code; derived from source account.
  final String currencyCode;

  /// Source account UUID; required for expense/transfer.
  final String? accountSourceId;

  /// Destination account UUID; required for income/transfer.
  final String? accountDestinationId;

  /// Category UUID; required for income/expense; null for transfer.
  final String? categoryId;

  /// Optional subcategory UUID.
  final String? subcategoryId;

  /// Optional payee UUID.
  final String? payeeId;

  /// Optional template display label.
  final String? title;

  /// Optional long-form description.
  final String? description;

  /// Auto-posting behaviour.
  final PostingBehaviour postingBehaviour;

  /// Transfer fee mode; null = no fee.
  final FeeMode? feeMode;

  /// Flat fee in minor units. Used when [feeMode] = [FeeMode.flat].
  final int? feeAmountMinor;

  /// Percentage fee × 1,000,000. Used when [feeMode] = [FeeMode.percentage].
  final int? feePercentageMicro;

  /// Fee expense category UUID.
  final String? feeCategoryId;

  /// Optional manual per-installment amount overrides (minor units, 1-indexed).
  ///
  /// When null, amounts are auto-calculated as `totalConfiguredMinor ÷ numberOfInstallments`
  /// with the integer remainder assigned to the last occurrence.
  /// When provided, must have exactly [numberOfInstallments] elements.
  final List<int>? perInstallmentAmountsMinor;
}

/// Creates a new installment plan with eagerly materialised occurrence records.
///
/// Validates all inputs, then delegates to
/// [IInstallmentPlanRepository.createAtomic] which performs within a single
/// DB transaction:
///   1. Inserts the `recurring_templates` row (isInstallment = true).
///   2. Inserts the `installment_plans` row.
///   3. Bulk-inserts all [CreateInstallmentPlanInput.numberOfInstallments]
///      `installment_occurrences` rows.
///
/// End date is computed O(1) via [PeriodCalculator] — no iteration loops.
/// Per-installment amounts are auto-calculated if not manually overridden.
class CreateInstallmentPlanUseCase {
  /// Creates a [CreateInstallmentPlanUseCase].
  ///
  /// Parameters:
  /// - [planRepository]: Persists the template, plan, and occurrences atomically.
  /// - [periodCalculator]: Computes scheduled dates O(1).
  const CreateInstallmentPlanUseCase({
    required IInstallmentPlanRepository planRepository,
    required PeriodCalculator periodCalculator,
  })  : _planRepository = planRepository,
        _periodCalculator = periodCalculator;

  final IInstallmentPlanRepository _planRepository;
  final PeriodCalculator _periodCalculator;

  /// Executes the installment plan creation.
  ///
  /// Validates [input], then atomically inserts the template, plan, and all
  /// occurrence rows.
  ///
  /// Returns [Ok] carrying the created [InstallmentPlan] on success.
  /// Returns [Err(ValidationFailure)] for invalid inputs.
  /// Returns [Err(DatabaseFailure)] when a DB write fails.
  ///
  /// Parameters:
  /// - [input]: All field values for the new installment plan.
  Future<Result<InstallmentPlan>> call(CreateInstallmentPlanInput input) async {
    // -----------------------------------------------------------------------
    // Step 1: Validate inputs.
    // -----------------------------------------------------------------------
    final validationError = _validate(input);
    if (validationError != null) {
      return Err(ValidationFailure(validationError));
    }

    // -----------------------------------------------------------------------
    // Step 2: Build domain entities.
    // -----------------------------------------------------------------------
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final templateId = _uuid.v4();

    // Compute end date: start + (N × recurrence_period), O(1).
    // startDate is epoch days; convert to epoch seconds for PeriodCalculator.
    final startEpochSeconds = input.startDate * 86400;
    // Compute the epoch seconds for the period starting N installments after start.
    final endEpochSeconds = _computeEndEpochSeconds(
      startEpochSeconds: startEpochSeconds,
      recurrenceN: input.recurrenceN,
      recurrenceUnit: input.recurrenceUnit,
      numberOfInstallments: input.numberOfInstallments,
    );
    // Convert back to epoch days for the template entity.
    final endDateEpochDays = endEpochSeconds ~/ 86400;

    final template = RecurringTemplate(
      id: templateId,
      transactionType: input.transactionType,
      status: RecurringTemplateStatus.active,
      amountMinor: _baseAmountMinor(input),
      currencyCode: input.currencyCode,
      accountSourceId: input.accountSourceId,
      accountDestinationId: input.accountDestinationId,
      categoryId: input.categoryId,
      subcategoryId: input.subcategoryId,
      payeeId: input.payeeId,
      title: input.title,
      description: input.description,
      recurrenceN: input.recurrenceN,
      recurrenceUnit: input.recurrenceUnit,
      startDate: input.startDate,
      endDate: endDateEpochDays,
      postingBehaviour: input.postingBehaviour,
      feeMode: input.feeMode,
      feeAmountMinor: input.feeAmountMinor,
      feePercentageMicro: input.feePercentageMicro,
      feeCategoryId: input.feeCategoryId,
      isInstallment: true,
      createdAt: nowEpoch,
      updatedAt: nowEpoch,
    );

    final plan = InstallmentPlan(
      templateId: templateId,
      totalConfiguredMinor: input.totalConfiguredMinor,
      numberOfInstallments: input.numberOfInstallments,
      createdAt: nowEpoch,
    );

    final occurrences = _buildOccurrences(
      templateId: templateId,
      input: input,
      startEpochSeconds: startEpochSeconds,
      nowEpoch: nowEpoch,
    );

    // -----------------------------------------------------------------------
    // Step 3: Persist atomically.
    // All three inserts (recurring_templates, installment_plans,
    // installment_occurrences) are executed in a single Drift DB transaction
    // via createAtomic(). Any failure rolls back all prior writes.
    // -----------------------------------------------------------------------
    return _planRepository.createAtomic(
      template: template,
      plan: plan,
      occurrences: occurrences,
    );
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Returns an error message string if validation fails, null otherwise.
  String? _validate(CreateInstallmentPlanInput input) {
    if (input.totalConfiguredMinor <= 0) {
      return 'Total configured amount must be greater than 0';
    }
    if (input.numberOfInstallments <= 0) {
      return 'Number of installments must be greater than 0';
    }
    if (input.recurrenceN <= 0) {
      return 'Recurrence N must be greater than 0';
    }
    if (!const ['income', 'expense', 'transfer']
        .contains(input.transactionType)) {
      return 'Transaction type must be one of: income, expense, transfer';
    }
    // Transfer-specific validation (T-131).
    if (input.transactionType == 'transfer') {
      if (input.accountSourceId == null) {
        return 'Transfer requires a source account';
      }
      if (input.accountDestinationId == null) {
        return 'Transfer requires a destination account';
      }
      if (input.accountSourceId == input.accountDestinationId) {
        return 'Transfer source and destination accounts must be different';
      }
    }
    // Per-installment overrides length check.
    final overrides = input.perInstallmentAmountsMinor;
    if (overrides != null && overrides.length != input.numberOfInstallments) {
      return 'perInstallmentAmountsMinor length must equal numberOfInstallments';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // End date computation — O(1) via PeriodCalculator
  // ---------------------------------------------------------------------------

  /// Computes the end date as the start of the period immediately after the
  /// last installment period.
  ///
  /// Uses [PeriodCalculator._addPeriods] logic by calling [PeriodCalculator.compute]
  /// with a reference date that is exactly one period past the last installment
  /// start, then taking the end of that range.
  ///
  /// This is O(1) — no iteration loops.
  int _computeEndEpochSeconds({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int numberOfInstallments,
  }) {
    // The end date is the start of the (numberOfInstallments + 1)th period,
    // which equals the end of the last (numberOfInstallments)th period.
    // We compute this by asking PeriodCalculator for a reference date that
    // falls just inside the last period, then returning that period's end.
    //
    // For the last occurrence date: compute the DateRange of the period starting
    // at index = (numberOfInstallments - 1). Use the start of that range, then
    // return the end of that range as the end date.
    //
    // Strategy: get the start of period index = numberOfInstallments (the first
    // period AFTER all installments). That is the end date we need.
    //
    // We exploit PeriodCalculator.compute() — pass a reference date that is
    // known to be inside the (numberOfInstallments - 1)th period, then take
    // the period end.
    //
    // Simpler: for fixed-length units, period end = start + N*period_length.
    // For variable-length units (month/year), use _addPeriods logic indirectly
    // by computing start of period (numberOfInstallments), which equals:
    //   startEpoch + numberOfInstallments × recurrenceN × unit_length
    return switch (recurrenceUnit) {
      RecurrenceUnit.day =>
        startEpochSeconds + (numberOfInstallments * recurrenceN * 86400),
      RecurrenceUnit.week =>
        startEpochSeconds + (numberOfInstallments * recurrenceN * 7 * 86400),
      // For month/year, use PeriodCalculator.compute to find the period
      // containing a reference point exactly (numberOfInstallments * period)
      // after start, then return that period's end. We do this by computing
      // the nth period's end via a reference-period lookup trick.
      RecurrenceUnit.month || RecurrenceUnit.year => _computeVariableEndDate(
          startEpochSeconds: startEpochSeconds,
          recurrenceN: recurrenceN,
          recurrenceUnit: recurrenceUnit,
          numberOfInstallments: numberOfInstallments,
        ),
    };
  }

  /// Computes end date for variable-length (month/year) periods via
  /// [PeriodCalculator.compute].
  ///
  /// For N installments, end date = start of period N (0-indexed).
  /// PeriodCalculator returns the period containing a reference date, so we
  /// use a reference that is slightly after the start of the last period.
  int _computeVariableEndDate({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int numberOfInstallments,
  }) {
    // Compute the period that contains a reference date midway through the
    // last installment period (index = numberOfInstallments - 1).
    // Use half a week past the start of that period as reference.
    // The period's end IS the next period start = our desired end date.
    //
    // Average seconds per period for the approximate offset:
    final avgSecondsPerPeriod = switch (recurrenceUnit) {
      RecurrenceUnit.month => recurrenceN * 30 * 86400,
      RecurrenceUnit.year => recurrenceN * 365 * 86400,
      _ => throw StateError('Only month/year handled here'),
    };
    // Reference = start + (numberOfInstallments - 1) periods + half a period.
    final referenceEpoch = startEpochSeconds +
        ((numberOfInstallments - 1) * avgSecondsPerPeriod) +
        (avgSecondsPerPeriod ~/ 2);

    final range = _periodCalculator.compute(
      startEpochSeconds: startEpochSeconds,
      recurrenceN: recurrenceN,
      recurrenceUnit: recurrenceUnit,
      referenceEpochSeconds: referenceEpoch,
    );
    // The end of this period = start of the next period = desired end date.
    return range.endEpochSeconds;
  }

  // ---------------------------------------------------------------------------
  // Occurrence scheduling
  // ---------------------------------------------------------------------------

  /// Builds all [InstallmentOccurrence] domain entities for the plan.
  ///
  /// Schedules each occurrence at the start of its period using
  /// [PeriodCalculator.compute]. Per-installment amounts are auto-calculated
  /// (total ÷ count) unless [CreateInstallmentPlanInput.perInstallmentAmountsMinor]
  /// is provided.
  ///
  /// The integer division remainder is added to the last occurrence.
  List<InstallmentOccurrence> _buildOccurrences({
    required String templateId,
    required CreateInstallmentPlanInput input,
    required int startEpochSeconds,
    required int nowEpoch,
  }) {
    final amounts = _computeAmounts(input);
    final occurrences = <InstallmentOccurrence>[];

    for (var i = 0; i < input.numberOfInstallments; i++) {
      // Scheduled date: start of the ith period from the template start date.
      final scheduledEpochSeconds = _scheduledDateForIndex(
        startEpochSeconds: startEpochSeconds,
        recurrenceN: input.recurrenceN,
        recurrenceUnit: input.recurrenceUnit,
        index: i,
      );
      // Convert epoch seconds to epoch days.
      final scheduledEpochDays = scheduledEpochSeconds ~/ 86400;

      occurrences.add(
        InstallmentOccurrence(
          id: _uuid.v4(),
          templateId: templateId,
          sequenceNumber: i + 1,
          scheduledDate: scheduledEpochDays,
          amountMinor: amounts[i],
          status: InstallmentOccurrenceStatus.pending,
          createdAt: nowEpoch,
          updatedAt: nowEpoch,
        ),
      );
    }
    return occurrences;
  }

  /// Computes the per-installment amounts list.
  ///
  /// If manual overrides are provided, uses them directly.
  /// Otherwise: auto = totalConfiguredMinor ÷ numberOfInstallments with
  /// the integer remainder assigned to the last occurrence.
  List<int> _computeAmounts(CreateInstallmentPlanInput input) {
    if (input.perInstallmentAmountsMinor != null) {
      return input.perInstallmentAmountsMinor!;
    }
    final n = input.numberOfInstallments;
    final base = input.totalConfiguredMinor ~/ n;
    final remainder = input.totalConfiguredMinor - (base * n);
    return [
      for (var i = 0; i < n; i++) i < n - 1 ? base : base + remainder,
    ];
  }

  /// Computes the scheduled epoch seconds for occurrence at [index] (0-based).
  ///
  /// Uses [PeriodCalculator.compute] for O(1) arithmetic.
  int _scheduledDateForIndex({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int index,
  }) {
    return switch (recurrenceUnit) {
      RecurrenceUnit.day => startEpochSeconds + (index * recurrenceN * 86400),
      RecurrenceUnit.week =>
        startEpochSeconds + (index * recurrenceN * 7 * 86400),
      RecurrenceUnit.month || RecurrenceUnit.year => _scheduledVariableDate(
          startEpochSeconds: startEpochSeconds,
          recurrenceN: recurrenceN,
          recurrenceUnit: recurrenceUnit,
          index: index,
        ),
    };
  }

  /// Computes the scheduled epoch seconds for variable-length periods.
  ///
  /// Uses [PeriodCalculator.compute] with a reference midway inside period
  /// [index] to retrieve the period start.
  int _scheduledVariableDate({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int index,
  }) {
    if (index == 0) return startEpochSeconds;

    final avgSecondsPerPeriod = switch (recurrenceUnit) {
      RecurrenceUnit.month => recurrenceN * 30 * 86400,
      RecurrenceUnit.year => recurrenceN * 365 * 86400,
      _ => throw StateError('Only month/year handled here'),
    };
    final referenceEpoch = startEpochSeconds +
        (index * avgSecondsPerPeriod) +
        (avgSecondsPerPeriod ~/ 2);

    final range = _periodCalculator.compute(
      startEpochSeconds: startEpochSeconds,
      recurrenceN: recurrenceN,
      recurrenceUnit: recurrenceUnit,
      referenceEpochSeconds: referenceEpoch,
    );
    return range.startEpochSeconds;
  }

  /// Returns the per-installment base amount for the recurring template row.
  ///
  /// This is the auto-calculated amount (total ÷ count, ignoring remainder).
  int _baseAmountMinor(CreateInstallmentPlanInput input) {
    return input.totalConfiguredMinor ~/ input.numberOfInstallments;
  }
}
