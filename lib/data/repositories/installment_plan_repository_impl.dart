// lib/data/repositories/installment_plan_repository_impl.dart
//
// Concrete implementation of IInstallmentPlanRepository backed by Drift DAOs.
//
// Pattern: delegate to DAO; wrap DAO exceptions in Err(DatabaseFailure(...)).
// All methods return Result<T> — callers never see raw DB exceptions.
//
// createAtomic: Executes all three inserts (recurring_templates,
//   installment_plans, installment_occurrences) within a single Drift DB
//   transaction for ACID atomicity (SDS §1.6.2).
//
// Import aliasing convention (Drift name-collision pattern):
//   Domain entities share names with Drift-generated row types.
//   Import all three domain entities under the `domain` prefix to
//   disambiguate from the Drift-generated data classes exposed by
//   AppDatabase (e.g. `domain.InstallmentPlan` vs `InstallmentPlan`).
//
// Spec: T-129, T-130, T-131, API Contracts §2.7.1, SDS §2.9.3
//
// Test cases (see test/data/repositories/installment_plan_repository_test.dart):
//   1. create() inserts and returns Ok(plan)
//   2. update() persists changed fields and returns Ok(plan)
//   3. closeEarly() cancels pending occurrences and returns Ok(null)
//   4. watchAll() emits list after insert
//   5. watchById() emits null when not found; emits plan after insert
//   6. DAO exception wrapped in Err(DatabaseFailure)
//   7. createAtomic() inserts template + plan + occurrences atomically
//   8. createAtomic() rolls back all on DAO failure

import 'dart:developer' as dev;

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/installment_dao.dart';
import 'package:variance/data/database/daos/template_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
// Domain entities are aliased as `domain` to avoid collision with Drift-generated
// row types (e.g. `InstallmentPlan` exists in both namespaces).
import 'package:variance/domain/entities/installment_occurrence.dart'
    as domain_occ;
import 'package:variance/domain/entities/installment_plan.dart' as domain_plan;
import 'package:variance/domain/entities/recurring_template.dart'
    as domain_templ;
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';

/// Drift-backed implementation of [IInstallmentPlanRepository].
///
/// Delegates all data access to [InstallmentPlanDao], [InstallmentOccurrenceDao],
/// and [TemplateDao]. All DAO exceptions are caught and wrapped in
/// [Err(DatabaseFailure(...))] — no raw exceptions propagate to callers.
///
/// [createAtomic] wraps the three-table insert in a single Drift database
/// transaction for ACID atomicity (SDS §1.6.2).
class InstallmentPlanRepositoryImpl implements IInstallmentPlanRepository {
  /// Creates an [InstallmentPlanRepositoryImpl].
  ///
  /// Parameters:
  /// - [planDao]: DAO for installment plan table operations.
  /// - [occurrenceDao]: DAO for installment occurrence operations.
  /// - [templateDao]: DAO for recurring template table operations.
  /// - [database]: The Drift database; used to open a single transaction.
  const InstallmentPlanRepositoryImpl(
    this._planDao,
    this._occurrenceDao,
    this._templateDao,
    this._database,
  );

  final InstallmentPlanDao _planDao;
  final InstallmentOccurrenceDao _occurrenceDao;
  final TemplateDao _templateDao;
  final AppDatabase _database;

  @override
  Stream<List<domain_plan.InstallmentPlan>> watchAll() {
    return _planDao.watchAll();
  }

  @override
  Stream<domain_plan.InstallmentPlan?> watchById(String id) {
    return _planDao.watchById(id);
  }

  @override
  Future<Result<domain_plan.InstallmentPlan>> createAtomic({
    required domain_templ.RecurringTemplate template,
    required domain_plan.InstallmentPlan plan,
    required List<domain_occ.InstallmentOccurrence> occurrences,
  }) async {
    try {
      // All three inserts must succeed together — any exception rolls back the
      // entire DB transaction (SDS §1.6.2 ACID constraint).
      await _database.transaction(() async {
        // 1. Insert recurring_templates row (is_installment = true).
        await _templateDao.insertFromEntity(template);

        // 2. Insert installment_plans row.
        await _planDao.insertPlan(plan);

        // 3. Bulk-insert all installment_occurrences rows.
        await _occurrenceDao.insertOccurrences(occurrences);
      });
      return Ok(plan);
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanRepositoryImpl.createAtomic: $e',
        name: 'InstallmentPlanRepositoryImpl',
      );
      return Err(
        DatabaseFailure('Failed to create installment plan atomically: $e'),
      );
    }
  }

  @override
  Future<Result<domain_plan.InstallmentPlan>> create(
    domain_plan.InstallmentPlan plan,
  ) async {
    try {
      final created = await _planDao.insertPlan(plan);
      return Ok(created);
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanRepositoryImpl.create: $e',
        name: 'InstallmentPlanRepositoryImpl',
      );
      return Err(DatabaseFailure('Failed to create installment plan: $e'));
    }
  }

  @override
  Future<Result<domain_plan.InstallmentPlan>> update(
    domain_plan.InstallmentPlan plan,
  ) async {
    try {
      await _planDao.updatePlan(plan);
      return Ok(plan);
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanRepositoryImpl.update: $e',
        name: 'InstallmentPlanRepositoryImpl',
      );
      return Err(DatabaseFailure('Failed to update installment plan: $e'));
    }
  }

  @override
  Future<Result<void>> closeEarly(String id) async {
    try {
      // Cancel all pending occurrences before archiving the template.
      // The template status update happens in the use case (domain layer).
      await _occurrenceDao.cancelPendingOccurrences(id);
      return const Ok(null);
    } on Object catch (e) {
      dev.log(
        'InstallmentPlanRepositoryImpl.closeEarly: $e',
        name: 'InstallmentPlanRepositoryImpl',
      );
      return Err(
        DatabaseFailure('Failed to close installment plan early: $e'),
      );
    }
  }
}
