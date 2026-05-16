// lib/data/database/daos/template_dao.dart
//
// DAO for the `recurring_templates` and `installment_plans` aggregates.
//
// Responsibilities:
//   - CRUD on recurring_templates and installment_plans tables
//   - Scheduler sweep query (pending past-due active templates)

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/tables/installment_plans_table.dart';
import 'package:variance/data/database/tables/recurring_templates_table.dart';
import 'package:variance/domain/entities/recurring_template.dart' as domain;

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

  /// Inserts a recurring template row from a domain entity.
  ///
  /// Maps all [domain.RecurringTemplate] fields to the DB companion.
  ///
  /// Parameters:
  /// - [template]: Domain entity to persist.
  Future<void> insertFromEntity(
    domain.RecurringTemplate template,
  ) async {
    await into(recurringTemplates).insert(
      RecurringTemplatesCompanion.insert(
        id: template.id,
        transactionType: template.transactionType,
        status: Value(template.status.name),
        amountMinor: template.amountMinor,
        currencyCode: template.currencyCode,
        accountSourceId: Value(template.accountSourceId),
        accountDestinationId: Value(template.accountDestinationId),
        categoryId: Value(template.categoryId),
        subcategoryId: Value(template.subcategoryId),
        payeeId: Value(template.payeeId),
        title: Value(template.title),
        description: Value(template.description),
        recurrenceN: template.recurrenceN,
        recurrenceUnit: template.recurrenceUnit.name,
        recurrenceConstraints: Value(_encodeConstraints(template.recurrenceConstraints)),
        startDate: template.startDate,
        endDate: Value(template.endDate),
        postingBehaviour: Value(_encodePostingBehaviour(template.postingBehaviour)),
        feeMode: Value(template.feeMode?.name),
        feeAmountMinor: Value(template.feeAmountMinor),
        feePercentageMicro: Value(template.feePercentageMicro),
        feeCategoryId: Value(template.feeCategoryId),
        isInstallment: Value(template.isInstallment),
        isDeleted: Value(template.isDeleted),
        createdAt: template.createdAt,
        updatedAt: template.updatedAt,
        metadata: Value(template.metadata),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Encoding helpers
  // ---------------------------------------------------------------------------

  String? _encodeConstraints(List<domain.RecurrenceConstraint>? constraints) {
    if (constraints == null || constraints.isEmpty) return null;
    return '[${constraints.map((c) => '"${c.name}"').join(',')}]';
  }

  String _encodePostingBehaviour(domain.PostingBehaviour behaviour) {
    return switch (behaviour) {
      domain.PostingBehaviour.autoPost => 'auto_post',
      domain.PostingBehaviour.remindAndConfirm => 'remind_and_confirm',
    };
  }
}
