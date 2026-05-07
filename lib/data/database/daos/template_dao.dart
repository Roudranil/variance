// lib/data/database/daos/template_dao.dart
//
// DAO for the `recurring_templates` and `installment_plans` aggregates.
//
// Responsibilities:
//   - CRUD on recurring_templates and installment_plans tables
//   - Scheduler sweep query (pending past-due active templates)

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/recurring_templates_table.dart';
import 'package:variance/data/database/tables/installment_plans_table.dart';

part 'template_dao.g.dart';

/// DAO for CRUD on `recurring_templates` and `installment_plans`.
///
/// Template immutability rules ([RecurringTemplate.transactionType],
/// [RecurringTemplate.recurrenceN], etc.) are enforced at the domain layer
/// before this DAO is called.
@DriftAccessor(tables: [RecurringTemplates, InstallmentPlans])
class TemplateDao extends DatabaseAccessor<AppDatabase>
    with _$TemplateDaoMixin {
  /// Creates a new [TemplateDao] bound to [db].
  TemplateDao(super.db);

  // -----------------------------------------------------------------------
  // Queries
  // -----------------------------------------------------------------------

  /// Returns a stream of all active (non-deleted, non-archived) recurring
  /// templates (excludes installments).
  Stream<List<RecurringTemplate>> watchActiveRecurringTemplates() {
    return (select(recurringTemplates)
          ..where(
            (t) =>
                t.status.isIn(['active', 'paused']) &
                t.isInstallment.equals(false) &
                t.isDeleted.equals(false),
          ))
        .watch();
  }

  /// Returns the [InstallmentPlan] row for the given [templateId], or null
  /// if not found.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the parent recurring template.
  Future<InstallmentPlan?> getInstallmentPlan(String templateId) {
    return (select(installmentPlans)
          ..where((p) => p.templateId.equals(templateId)))
        .getSingleOrNull();
  }

  /// Inserts a recurring template row.
  ///
  /// Parameters:
  /// - [template]: The companion carrying the column values to insert.
  Future<int> insertTemplate(RecurringTemplatesCompanion template) {
    return into(recurringTemplates).insert(template);
  }
}
