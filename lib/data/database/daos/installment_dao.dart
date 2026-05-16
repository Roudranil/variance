// lib/data/database/daos/installment_dao.dart
//
// DAOs for the `installment_plans` and `installment_occurrences` tables.
//
// InstallmentPlanDao   — CRUD on installment_plans rows.
// InstallmentOccurrenceDao — CRUD on installment_occurrences rows.
//
// Indexes used (data model §8.2.1):
//   idx_inst_occ_template_seq  — UNIQUE on (template_id, sequence_number)
//   idx_inst_occ_status_date   — on (status, scheduled_date)
//
// Spec: T-126, API Contracts §2.7.1, §2.7.2
//
// Test cases (see test/data/database/installment_dao_test.dart):
//   InstallmentPlanDao:
//     1. watchAll() emits all plans after insert
//     2. watchById() emits single plan by templateId
//     3. insertPlan() persists and returns plan
//     4. updatePlan() persists changed fields
//     5. deletePlan() removes the row
//   InstallmentOccurrenceDao:
//     6. watchByPlan() emits occurrences ordered by sequence_number
//     7. insertOccurrences() bulk-inserts correctly
//     8. updateOccurrence() persists changed fields
//     9. deleteOccurrence() removes the row
//    10. markPosted() sets status='posted' and childTransactionId
//    11. cancelPendingOccurrences() cancels all pending for a template

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/installment_plans_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/domain/entities/installment_occurrence.dart'
    as domain;
import 'package:variance/domain/entities/installment_plan.dart' as domain;

part 'installment_dao.g.dart';

// ---------------------------------------------------------------------------
// InstallmentPlanDao
// ---------------------------------------------------------------------------

/// DAO for CRUD on `installment_plans`.
///
/// Each row is 1:1 with a `recurring_templates` row where `is_installment = 1`.
/// [templateId] is the PK and FK to `recurring_templates`.
///
/// Row-to-domain mapping is handled by [_mapPlanRow]. Callers should work
/// with [domain.InstallmentPlan] entities, not raw Drift data classes.
@DriftAccessor(tables: [InstallmentPlans])
class InstallmentPlanDao extends DatabaseAccessor<AppDatabase>
    with _$InstallmentPlanDaoMixin {
  /// Creates a [InstallmentPlanDao] bound to [db].
  InstallmentPlanDao(super.db);

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  /// Watches all installment plan rows.
  ///
  /// Emits on any change to the `installment_plans` table.
  Stream<List<domain.InstallmentPlan>> watchAll() {
    return select(installmentPlans).map(_mapPlanRow).watch();
  }

  /// Watches a single installment plan by [templateId].
  ///
  /// Emits [null] when no row exists for [templateId].
  ///
  /// Parameters:
  /// - [templateId]: UUID of the parent recurring template.
  Stream<domain.InstallmentPlan?> watchById(String templateId) {
    return (select(installmentPlans)
          ..where((p) => p.templateId.equals(templateId)))
        .map(_mapPlanRow)
        .watchSingleOrNull();
  }

  // -------------------------------------------------------------------------
  // Mutations
  // -------------------------------------------------------------------------

  /// Inserts a new installment plan row.
  ///
  /// Returns the inserted [domain.InstallmentPlan] on success. Throws on
  /// constraint violations (duplicate templateId, negative amounts, etc.).
  ///
  /// Parameters:
  /// - [plan]: Domain entity whose fields map to the DB row.
  Future<domain.InstallmentPlan> insertPlan(domain.InstallmentPlan plan) async {
    await into(installmentPlans).insert(
      InstallmentPlansCompanion.insert(
        templateId: plan.templateId,
        totalConfiguredMinor: plan.totalConfiguredMinor,
        numberOfInstallments: plan.numberOfInstallments,
        createdAt: plan.createdAt,
      ),
    );
    return plan;
  }

  /// Updates an existing installment plan row.
  ///
  /// Updates [totalConfiguredMinor] and [numberOfInstallments] from [plan].
  ///
  /// Parameters:
  /// - [plan]: Domain entity with the new field values.
  Future<void> updatePlan(domain.InstallmentPlan plan) async {
    await (update(installmentPlans)
          ..where((p) => p.templateId.equals(plan.templateId)))
        .write(
      InstallmentPlansCompanion(
        totalConfiguredMinor: Value(plan.totalConfiguredMinor),
        numberOfInstallments: Value(plan.numberOfInstallments),
      ),
    );
  }

  /// Deletes an installment plan row by [templateId].
  ///
  /// Cascades to `installment_occurrences` via ON DELETE CASCADE on the FK.
  ///
  /// Parameters:
  /// - [id]: UUID of the parent recurring template.
  Future<void> deletePlan(String id) async {
    await (delete(installmentPlans)
          ..where((p) => p.templateId.equals(id)))
        .go();
  }

  // -------------------------------------------------------------------------
  // Mapping
  // -------------------------------------------------------------------------

  /// Maps a Drift [InstallmentPlan] data row to the domain entity.
  domain.InstallmentPlan _mapPlanRow(InstallmentPlan row) {
    return domain.InstallmentPlan(
      templateId: row.templateId,
      totalConfiguredMinor: row.totalConfiguredMinor,
      numberOfInstallments: row.numberOfInstallments,
      createdAt: row.createdAt,
    );
  }
}

// ---------------------------------------------------------------------------
// InstallmentOccurrenceDao
// ---------------------------------------------------------------------------

/// DAO for CRUD on `installment_occurrences`.
///
/// Occurrences are created eagerly at template creation; all rows for a
/// plan are inserted at once via [insertOccurrences]. Status transitions
/// follow: `pending` → `posted` (via [markPosted]) or `cancelled` (via
/// [cancelPendingOccurrences] or [deleteOccurrence]).
///
/// Row-to-domain mapping is handled by [_mapOccurrenceRow].
@DriftAccessor(tables: [InstallmentOccurrences, Transactions])
class InstallmentOccurrenceDao extends DatabaseAccessor<AppDatabase>
    with _$InstallmentOccurrenceDaoMixin {
  /// Creates an [InstallmentOccurrenceDao] bound to [db].
  InstallmentOccurrenceDao(super.db);

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  /// Watches all occurrences for [planId], ordered by [sequence_number] ASC.
  ///
  /// Uses `idx_inst_occ_template_seq` for the ordered scan.
  ///
  /// Parameters:
  /// - [planId]: UUID of the parent recurring template (installment plan FK).
  Stream<List<domain.InstallmentOccurrence>> watchByPlan(String planId) {
    return (select(installmentOccurrences)
          ..where((o) => o.templateId.equals(planId))
          ..orderBy([(o) => OrderingTerm.asc(o.sequenceNumber)]))
        .map(_mapOccurrenceRow)
        .watch();
  }

  // -------------------------------------------------------------------------
  // Mutations
  // -------------------------------------------------------------------------

  /// Bulk-inserts all occurrence rows for an installment plan.
  ///
  /// Each row in [occurrences] maps to a single `installment_occurrences`
  /// DB row. Uses a [batch] for efficiency — single SQLite write.
  ///
  /// Parameters:
  /// - [occurrences]: List of domain occurrences to insert.
  Future<void> insertOccurrences(
    List<domain.InstallmentOccurrence> occurrences,
  ) async {
    await batch((b) {
      for (final occ in occurrences) {
        b.insert(
          installmentOccurrences,
          InstallmentOccurrencesCompanion.insert(
            id: occ.id,
            templateId: occ.templateId,
            sequenceNumber: occ.sequenceNumber,
            scheduledDate: occ.scheduledDate,
            amountMinor: occ.amountMinor,
            status: Value(occ.status.name),
            childTransactionId: Value(occ.childTransactionId),
            createdAt: occ.createdAt,
            updatedAt: occ.updatedAt,
          ),
        );
      }
    });
  }

  /// Updates all mutable fields of an occurrence row.
  ///
  /// Updates: [scheduledDate], [amountMinor], [status], [childTransactionId],
  /// and [updatedAt].
  ///
  /// Parameters:
  /// - [occ]: Domain occurrence with new field values; [occ.id] is the PK.
  Future<void> updateOccurrence(domain.InstallmentOccurrence occ) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(installmentOccurrences)
          ..where((o) => o.id.equals(occ.id)))
        .write(
      InstallmentOccurrencesCompanion(
        scheduledDate: Value(occ.scheduledDate),
        amountMinor: Value(occ.amountMinor),
        status: Value(occ.status.name),
        childTransactionId: Value(occ.childTransactionId),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Deletes a single occurrence row by [id].
  ///
  /// Parameters:
  /// - [id]: UUID of the installment occurrence to delete.
  Future<void> deleteOccurrence(String id) async {
    await (delete(installmentOccurrences)
          ..where((o) => o.id.equals(id)))
        .go();
  }

  /// Transitions a pending occurrence to `posted` and records [transactionId].
  ///
  /// Sets `status = 'posted'`, `child_transaction_id = [transactionId]`,
  /// and `updated_at = now()`.
  ///
  /// Parameters:
  /// - [id]: UUID of the installment occurrence.
  /// - [transactionId]: UUID of the posted transaction child.
  Future<void> markPosted(String id, String transactionId) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(installmentOccurrences)
          ..where((o) => o.id.equals(id)))
        .write(
      InstallmentOccurrencesCompanion(
        status: const Value('posted'),
        childTransactionId: Value(transactionId),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Cancels all `pending` occurrences for [templateId].
  ///
  /// Used during early close of an installment plan ([CloseInstallmentPlanUseCase]).
  /// Only rows in `pending` status are updated; `posted` rows are untouched.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the parent recurring template.
  Future<void> cancelPendingOccurrences(String templateId) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(installmentOccurrences)
          ..where(
            (o) =>
                o.templateId.equals(templateId) &
                o.status.equals('pending'),
          ))
        .write(
      InstallmentOccurrencesCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Mapping
  // -------------------------------------------------------------------------

  /// Maps a Drift [InstallmentOccurrence] row to the domain entity.
  domain.InstallmentOccurrence _mapOccurrenceRow(InstallmentOccurrence row) {
    return domain.InstallmentOccurrence(
      id: row.id,
      templateId: row.templateId,
      sequenceNumber: row.sequenceNumber,
      scheduledDate: row.scheduledDate,
      amountMinor: row.amountMinor,
      status: _mapStatus(row.status),
      childTransactionId: row.childTransactionId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Maps a raw DB status string to [domain.InstallmentOccurrenceStatus].
  domain.InstallmentOccurrenceStatus _mapStatus(String raw) => switch (raw) {
        'posted' => domain.InstallmentOccurrenceStatus.posted,
        'cancelled' => domain.InstallmentOccurrenceStatus.cancelled,
        _ => domain.InstallmentOccurrenceStatus.pending,
      };
}
