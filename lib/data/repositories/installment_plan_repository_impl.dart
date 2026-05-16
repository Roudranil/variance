// lib/data/repositories/installment_plan_repository_impl.dart
//
// Concrete implementation of IInstallmentPlanRepository backed by
// InstallmentPlanDao (T-129).
//
// Pattern: delegate to DAO; wrap DAO exceptions in Err(DatabaseFailure(...)).
// All methods return Result<T> — callers never see raw DB exceptions.
//
// Spec: API Contracts §2.7.1, SDS §2.9.3
//
// Test cases (see test/data/repositories/installment_plan_repository_test.dart):
//   1. create() inserts and returns Ok(plan)
//   2. update() persists changed fields and returns Ok(plan)
//   3. closeEarly() cancels pending occurrences and returns Ok(null)
//   4. watchAll() emits list after insert
//   5. watchById() emits null when not found; emits plan after insert
//   6. DAO exception wrapped in Err(DatabaseFailure)

import 'dart:developer' as dev;

import 'package:variance/data/database/daos/installment_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';

/// Drift-backed implementation of [IInstallmentPlanRepository].
///
/// Delegates all data access to [InstallmentPlanDao] and
/// [InstallmentOccurrenceDao]. All DAO exceptions are caught and wrapped in
/// [Err(DatabaseFailure(...))] — no raw exceptions propagate to callers.
class InstallmentPlanRepositoryImpl implements IInstallmentPlanRepository {
  /// Creates an [InstallmentPlanRepositoryImpl].
  ///
  /// Parameters:
  /// - [planDao]: DAO for installment plan table operations.
  /// - [occurrenceDao]: DAO for installment occurrence cancellation on early close.
  const InstallmentPlanRepositoryImpl(this._planDao, this._occurrenceDao);

  final InstallmentPlanDao _planDao;
  final InstallmentOccurrenceDao _occurrenceDao;

  @override
  Stream<List<InstallmentPlan>> watchAll() {
    return _planDao.watchAll();
  }

  @override
  Stream<InstallmentPlan?> watchById(String id) {
    return _planDao.watchById(id);
  }

  @override
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan) async {
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
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan) async {
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
