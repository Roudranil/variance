// lib/data/database/tables/installment_plans_table.dart
//
// Drift table definitions for `installment_plans` and
// `installment_occurrences`.
//
// Installment-specific metadata extends recurring_templates rows flagged
// with is_installment=1. Occurrences are created eagerly at template
// creation (all records at once).

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/recurring_templates_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';

/// Drift table for installment-specific template metadata.
///
/// One-to-one with [RecurringTemplates] where `is_installment = 1`.
/// [templateId] serves as both FK and primary key.
class InstallmentPlans extends Table {
  /// PK and FK → recurring_templates(id) ON DELETE CASCADE.
  TextColumn get templateId => text().references(
        RecurringTemplates,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Target total amount in minor units. Immutable except during early close.
  IntColumn get totalConfiguredMinor => integer()();

  /// Total planned installment count. Editable for future installments.
  IntColumn get numberOfInstallments => integer()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {templateId};
}

/// Drift table for individual materialized installment records.
///
/// Created eagerly at template creation — all [numberOfInstallments] rows
/// are inserted at once. Supports per-installment amount overrides.
class InstallmentOccurrences extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → recurring_templates(id) ON DELETE CASCADE.
  TextColumn get templateId => text().references(
        RecurringTemplates,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// 1-based position in the series. Unique per template.
  IntColumn get sequenceNumber => integer()();

  /// When this installment should be posted (Unix epoch date).
  IntColumn get scheduledDate => integer()();

  /// Per-installment amount in minor units. Adjustable for unposted rows.
  IntColumn get amountMinor => integer()();

  /// Status: `pending`, `posted`, or `cancelled`.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// FK to the transaction created when this installment is posted.
  TextColumn get childTransactionId =>
      text().nullable().references(Transactions, #id)();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
