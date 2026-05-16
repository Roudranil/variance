// lib/data/database/daos/scheduled_occurrence_dao.dart
//
// DAO for the `scheduled_occurrences` table (T-99).
//
// Indexes referenced (data model §7.2.1):
//   idx_sched_occ_template  — on template_id
//   idx_sched_occ_status_date — on (status, scheduled_date)
//
// Drift note: Drift creates indexes from @TableIndex annotations on the
// table class. The table already declares the FK to recurring_templates.
// Indexes are added via customStatement in migrations.
//
// Name collision note:
//   The Drift-generated row class for ScheduledOccurrences is also named
//   'ScheduledOccurrence'. The domain entity is imported as 'domain'.
//   All Drift row references use the bare 'ScheduledOccurrence' name
//   (from the generated .g.dart), and domain references use 'domain.' prefix.

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/scheduled_occurrences_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart' as domain;

part 'scheduled_occurrence_dao.g.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// DAO for CRUD on `scheduled_occurrences`.
///
/// All status transitions (pending → posted/skipped/cancelled) are performed
/// here. Bulk lookahead insertion uses a [batch] to stay within a single
/// SQLite write.
@DriftAccessor(tables: [ScheduledOccurrences, Transactions])
class ScheduledOccurrenceDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduledOccurrenceDaoMixin {
  /// Creates a [ScheduledOccurrenceDao] bound to [db].
  ScheduledOccurrenceDao(super.db);

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  /// Returns all occurrences with `status = 'pending'` whose
  /// `scheduled_date ≤ [asOfDays]`.
  ///
  /// Parameters:
  /// - [asOfDays]: Upper bound as Unix epoch days (days since epoch).
  Future<List<domain.ScheduledOccurrence>> pendingDueOn(int asOfDays) {
    return (select(scheduledOccurrences)
          ..where(
            (t) =>
                t.status.equals('pending') &
                t.scheduledDate.isSmallerOrEqualValue(asOfDays),
          ))
        .map(_mapRow)
        .get();
  }

  /// Returns all occurrence scheduled dates (epoch-day integers) for
  /// [templateId] that are not cancelled.
  ///
  /// Used by [insertBatch] to skip already-materialized dates.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the parent recurring template.
  Future<List<int>> existingScheduledDates(String templateId) async {
    final rows = await (select(scheduledOccurrences)
          ..where(
            (t) =>
                t.templateId.equals(templateId) &
                t.status.isNotIn(['cancelled']),
          ))
        .map((r) => r.scheduledDate)
        .get();
    return rows;
  }

  // -------------------------------------------------------------------------
  // Mutations
  // -------------------------------------------------------------------------

  /// Updates the status of occurrence [id] to [newStatus].
  ///
  /// Parameters:
  /// - [id]: UUID of the occurrence.
  /// - [newStatus]: Target status string ('posted', 'skipped', 'cancelled').
  /// - [childTransactionId]: Set when transitioning to 'posted'.
  Future<void> updateStatus(
    String id,
    String newStatus, {
    String? childTransactionId,
  }) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(scheduledOccurrences)..where((t) => t.id.equals(id))).write(
      ScheduledOccurrencesCompanion(
        status: Value(newStatus),
        childTransactionId: childTransactionId != null
            ? Value(childTransactionId)
            : const Value.absent(),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Inserts a batch of new occurrence rows, skipping dates that already
  /// have a non-cancelled row for the same [templateId].
  ///
  /// Parameters:
  /// - [templateId]: Parent template UUID.
  /// - [scheduledDates]: Epoch-day dates to materialize.
  /// - [existingDates]: Already-materialized dates for this template
  ///   (non-cancelled). Dates in this set are skipped.
  Future<void> insertBatch({
    required String templateId,
    required List<int> scheduledDates,
    required List<int> existingDates,
  }) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final skipSet = existingDates.toSet();

    await batch((b) {
      for (final date in scheduledDates) {
        if (skipSet.contains(date)) continue;
        b.insert(
          scheduledOccurrences,
          ScheduledOccurrencesCompanion.insert(
            id: _uuid.v4(),
            templateId: templateId,
            scheduledDate: date,
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Mapping
  // -------------------------------------------------------------------------

  /// Maps a Drift [ScheduledOccurrence] row to the domain entity.
  domain.ScheduledOccurrence _mapRow(ScheduledOccurrence row) {
    return domain.ScheduledOccurrence(
      id: row.id,
      templateId: row.templateId,
      scheduledDate: row.scheduledDate,
      status: _mapStatus(row.status),
      childTransactionId: row.childTransactionId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  domain.ScheduledOccurrenceStatus _mapStatus(String raw) => switch (raw) {
        'posted' => domain.ScheduledOccurrenceStatus.posted,
        'skipped' => domain.ScheduledOccurrenceStatus.skipped,
        'cancelled' => domain.ScheduledOccurrenceStatus.cancelled,
        _ => domain.ScheduledOccurrenceStatus.pending,
      };
}
