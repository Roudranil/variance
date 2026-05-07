// lib/domain/repositories/i_budget_repository.dart
//
// Abstract repository interface for the Budget aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/budget.dart';
import 'package:variance/domain/entities/budget_period.dart';

/// Contract for all Budget data-access operations.
abstract interface class IBudgetRepository {
  /// Watches all active budgets.
  Stream<List<Budget>> watchAll();

  /// Watches a single budget by UUID.
  Stream<Budget?> watchById(String id);

  /// Persists a new budget.
  Future<Result<Budget>> create(Budget budget);

  /// Updates a budget's mutable fields.
  Future<Result<Budget>> update(Budget budget);

  /// Deactivates a budget (sets isActive = false).
  Future<Result<void>> deactivate(String id);

  /// Watches all period records for a given budget.
  Stream<List<BudgetPeriod>> watchPeriodsForBudget(String budgetId);
}
