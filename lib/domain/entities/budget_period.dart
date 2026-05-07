// lib/domain/entities/budget_period.dart
//
// BudgetPeriod domain entity.
//
// Materialized period instance for a Budget. Computed values (spent,
// remaining) are derived at query time from entries; carriedOverMinor is the
// only stored rolled-over value.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_period.freezed.dart';

/// Immutable domain entity for a materialized budget period.
@freezed
abstract class BudgetPeriod with _$BudgetPeriod {
  const factory BudgetPeriod({
    /// UUID v4 stable identifier.
    required String id,

    /// Parent budget UUID.
    required String budgetId,

    /// Period start epoch (inclusive, Unix seconds).
    required int periodStart,

    /// Period end epoch (exclusive, Unix seconds).
    required int periodEnd,

    /// Effective ceiling including carryover (minor units).
    required int budgetedMinor,

    /// Rolled-over amount from the previous period (minor units).
    @Default(0) int carriedOverMinor,

    /// Creation epoch (Unix seconds).
    required int createdAt,
  }) = _BudgetPeriod;
}
