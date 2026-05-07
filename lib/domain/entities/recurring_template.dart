// lib/domain/entities/recurring_template.dart
//
// RecurringTemplate domain entity.
//
// Template definition for recurring and installment transaction series.
// The isInstallment flag distinguishes the two sub-types; installment-specific
// metadata lives in InstallmentPlan (1:1 relation).
//
// Lifecycle states (TC-043):
//   active → paused → active (resumable)
//   active/paused → archived (terminal)
//   active/paused → deleted (soft-delete, terminal)
//
// Immutable after creation: transactionType, recurrenceN, recurrenceUnit,
// recurrenceConstraints, startDate, endDate (for recurring).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_template.freezed.dart';

/// Lifecycle state of a recurring template (TC-043).
enum RecurringTemplateStatus {
  active,
  paused,
  archived,
  deleted,
}

/// Time unit for recurrence cadence.
enum RecurrenceUnit {
  day,
  week,
  month,
  year,
}

/// Optional scheduling constraint applied to an occurrence date.
enum RecurrenceConstraint {
  weekdaysOnly,
  weekendsOnly,
  startOfMonth,
  endOfMonth,
  startOfYear,
  endOfYear,
}

/// Fee mode for transfer templates that carry a service fee.
enum FeeMode {
  flat,
  percentage,
}

/// Auto-posting behaviour.
enum PostingBehaviour {
  autoPost,
  remindAndConfirm,
}

/// Archival trigger reason.
enum ArchivedReason {
  endDateReached,
  installmentsExhausted,
  earlyClose,
  userStopped,
}

/// Immutable domain entity for a recurring or installment template.
@freezed
abstract class RecurringTemplate with _$RecurringTemplate {
  const factory RecurringTemplate({
    /// UUID v4 stable identifier.
    required String id,

    /// Financial direction; immutable after creation.
    required String transactionType,

    /// Lifecycle state.
    @Default(RecurringTemplateStatus.active) RecurringTemplateStatus status,

    /// Per-occurrence amount in minor units; in-place editable.
    required int amountMinor,

    /// ISO 4217 code; derived from source account.
    required String currencyCode,

    /// Source account UUID; null for income.
    String? accountSourceId,

    /// Destination account UUID; null for expense.
    String? accountDestinationId,

    /// Category UUID; null for transfer; editable.
    String? categoryId,

    /// Subcategory UUID; editable.
    String? subcategoryId,

    /// Payee UUID; optional.
    String? payeeId,

    /// Template title; editable.
    String? title,

    /// Description; editable.
    String? description,

    /// Cadence multiplier (e.g. 2 in "every 2 weeks"); immutable.
    required int recurrenceN,

    /// Cadence time unit; immutable.
    required RecurrenceUnit recurrenceUnit,

    /// Optional scheduling constraints (JSON array of [RecurrenceConstraint]);
    /// immutable.
    List<RecurrenceConstraint>? recurrenceConstraints,

    /// First occurrence date (Unix epoch days); immutable.
    required int startDate,

    /// Last valid occurrence date; immutable for recurring; computed for
    /// installments.
    int? endDate,

    /// Auto-posting behaviour; editable.
    @Default(PostingBehaviour.autoPost) PostingBehaviour postingBehaviour,

    /// Transfer fee mode; null = no fee.
    FeeMode? feeMode,

    /// Flat fee in minor units.
    int? feeAmountMinor,

    /// Percentage fee × 1,000,000.
    int? feePercentageMicro,

    /// Fee expense category UUID.
    String? feeCategoryId,

    /// Resume-after epoch; null = not paused.
    int? pauseUntil,

    /// Archival epoch; null = not archived.
    int? archivedAt,

    /// Archival trigger; null = not archived.
    ArchivedReason? archivedReason,

    /// Discriminator: false = recurring, true = installment.
    @Default(false) bool isInstallment,

    /// Soft-delete flag.
    @Default(false) bool isDeleted,

    /// Soft-delete epoch.
    int? deletedAt,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,

    /// JSON escape hatch.
    String? metadata,
  }) = _RecurringTemplate;
}
