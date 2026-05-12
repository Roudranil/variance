// lib/data/database/tables/recurring_templates_table.dart
//
// Drift table definition for `recurring_templates`.
//
// Template definition for both recurring and installment transaction series.
// The [isInstallment] flag distinguishes the two sub-types. Installment
// metadata lives in `installment_plans` (1:1 relation).

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/currencies_table.dart';
import 'package:variance/data/database/tables/payees_table.dart';

/// Drift table for recurring/installment transaction template definitions.
///
/// Immutability note: [transactionType], [recurrenceN], [recurrenceUnit],
/// [recurrenceConstraints], [startDate], and [endDate] (for recurring) must
/// not be updated after the first write. This invariant is enforced at the
/// domain layer, not the database schema.
class RecurringTemplates extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Transaction type: `income`, `expense`, or `transfer`. Immutable.
  TextColumn get transactionType => text()();

  /// Lifecycle state. Valid values: `active`, `paused`, `archived`, `deleted`.
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Per-occurrence amount in minor units. Editable in-place.
  IntColumn get amountMinor => integer()();

  /// Currency derived from source account.
  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// Source account for expense/transfer; NULL for income.
  TextColumn get accountSourceId =>
      text().nullable().references(Accounts, #id)();

  /// Destination account for income/transfer; NULL for expense.
  TextColumn get accountDestinationId =>
      text().nullable().references(Accounts, #id)();

  /// Top-level category. NULL for transfers. Editable.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// Optional subcategory. Editable.
  TextColumn get subcategoryId =>
      text().nullable().references(Categories, #id)();

  /// Optional payee. Editable.
  TextColumn get payeeId => text().nullable().references(Payees, #id)();

  /// Optional user label. Editable.
  TextColumn get title => text().nullable()();

  /// Optional description. Editable.
  TextColumn get description => text().nullable()();

  /// N in "every N <unit>". Immutable.
  IntColumn get recurrenceN => integer()();

  /// Time unit for recurrence. Valid values: `day`, `week`, `month`, `year`.
  /// Immutable.
  TextColumn get recurrenceUnit => text()();

  /// JSON array of recurrence constraint enums. Immutable.
  TextColumn get recurrenceConstraints => text().nullable()();

  /// First occurrence date as Unix epoch. Immutable.
  IntColumn get startDate => integer()();

  /// Last valid occurrence date. Immutable for recurring; computed for
  /// installments.
  IntColumn get endDate => integer().nullable()();

  /// Posting behaviour: `auto_post` or `remind_and_confirm`. Editable.
  TextColumn get postingBehaviour =>
      text().withDefault(const Constant('auto_post'))();

  /// Transfer fee mode: `flat`, `percentage`, or NULL (no fee).
  TextColumn get feeMode => text().nullable()();

  /// Flat fee amount in minor units.
  IntColumn get feeAmountMinor => integer().nullable()();

  /// Fee as percentage × 1,000,000.
  IntColumn get feePercentageMicro => integer().nullable()();

  /// Fee expense category.
  TextColumn get feeCategoryId =>
      text().nullable().references(Categories, #id)();

  /// Unix epoch; resume from pause after this time.
  IntColumn get pauseUntil => integer().nullable()();

  /// Unix epoch when this template was archived.
  IntColumn get archivedAt => integer().nullable()();

  /// Reason for archival.
  TextColumn get archivedReason => text().nullable()();

  /// Discriminator: 0 = recurring, 1 = installment.
  BoolColumn get isInstallment =>
      boolean().withDefault(const Constant(false))();

  /// Soft-delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Unix epoch seconds set on soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  /// JSON escape hatch for future extensibility.
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
