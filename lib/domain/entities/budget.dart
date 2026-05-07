// lib/domain/entities/budget.dart
//
// Budget domain entity.
//
// Budget envelope definition — either a total budget (category_id = null)
// or a per-category budget for a recurring period.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

/// Recurrence horizon for a budget.
enum BudgetPeriodType {
  weekly,
  monthly,
  quarterly,
  annual,
}

/// Immutable domain entity for a budget definition.
@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    /// UUID v4 stable identifier.
    required String id,

    /// User label.
    required String name,

    /// Linked category UUID; null = total (all-categories) budget.
    String? categoryId,

    /// Budget ceiling in minor units.
    required int amountMinor,

    /// Home currency of this budget.
    required String currencyCode,

    /// Recurrence horizon.
    required BudgetPeriodType periodType,

    /// Number of period units (e.g. periodN=1, periodType=monthly = monthly).
    @Default(1) int periodN,

    /// Carry unused amount to the next period.
    @Default(false) bool rollover,

    /// Whether this budget is currently active.
    @Default(true) bool isActive,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _Budget;
}
