// lib/data/database/tables/budgets_table.dart
//
// Drift table definitions for `budgets` and `budget_periods`.
//
// Budget tables are created in v1 to avoid a migration when the budgeting
// feature ships in v2. All rows will be empty at v1 launch.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/currencies_table.dart';

/// Drift table for budget envelope definitions.
///
/// A budget may cover all spending (NULL [categoryId]) or a single category.
/// Computed fields (spent, remaining) are derived at query time from
/// `entries`, never stored.
class Budgets extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// User-defined label.
  TextColumn get name => text()();

  /// NULL = total budget; non-null = per-category budget.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// Budget ceiling in minor units. Must be > 0.
  IntColumn get amountMinor => integer()();

  /// Home currency of this budget.
  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// Recurrence horizon: `weekly`, `monthly`, `quarterly`, or `annual`.
  TextColumn get periodType => text()();

  /// Number of periods (e.g. periodN=1 + periodType=monthly = monthly).
  IntColumn get periodN => integer().withDefault(const Constant(1))();

  /// Whether unused amount carries over to the next period.
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();

  /// Whether this budget is active.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Drift table for materialized budget period instances.
///
/// Each active budget generates a new period record on each period boundary.
/// [carriedOverMinor] is the only stored rolled-over value; spent and
/// remaining are computed from `entries` at query time.
class BudgetPeriods extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → budgets(id).
  TextColumn get budgetId => text().references(Budgets, #id)();

  /// Period start epoch (inclusive).
  IntColumn get periodStart => integer()();

  /// Period end epoch (exclusive).
  IntColumn get periodEnd => integer()();

  /// Effective ceiling including carryover.
  IntColumn get budgetedMinor => integer()();

  /// Rolled-over amount from the previous period.
  IntColumn get carriedOverMinor => integer().withDefault(const Constant(0))();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
