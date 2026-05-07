// lib/data/database/tables/scheduled_occurrences_table.dart
//
// Drift table definition for `scheduled_occurrences`.
//
// Materialized occurrence records for recurring (non-installment) templates.
// Created lazily, up to 90 days ahead.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/recurring_templates_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';

/// Drift table for materialized recurring occurrence records.
///
/// One row per expected occurrence. Provides the exception list for the
/// scheduler (TC-003) and enables per-occurrence status tracking without
/// a separate exception table.
class ScheduledOccurrences extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → recurring_templates(id) ON DELETE CASCADE.
  TextColumn get templateId => text().references(
        RecurringTemplates,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// When this occurrence should fire (Unix epoch date).
  IntColumn get scheduledDate => integer()();

  /// Status: `pending`, `posted`, `skipped`, or `cancelled`.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// FK to the transaction created when this occurrence is posted.
  TextColumn get childTransactionId =>
      text().nullable().references(Transactions, #id)();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
