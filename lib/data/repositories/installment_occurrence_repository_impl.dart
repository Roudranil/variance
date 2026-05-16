// lib/data/repositories/installment_occurrence_repository_impl.dart
//
// Concrete implementation of IInstallmentOccurrenceRepository backed by
// InstallmentOccurrenceDao (T-129).
//
// Pattern: delegate to DAO; wrap DAO exceptions in Err(DatabaseFailure(...)).
// All methods return Result<T> — callers never see raw DB exceptions.
//
// Spec: API Contracts §2.7.2, SDS §2.9.3
//
// Test cases (see test/data/repositories/installment_occurrence_repository_test.dart):
//   1. watchByPlan() emits occurrences ordered by sequence_number
//   2. markPosted() sets status='posted' and returns Ok(null)
//   3. DAO exception wrapped in Err(DatabaseFailure)

import 'dart:developer' as dev;

import 'package:variance/data/database/daos/installment_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/repositories/i_installment_occurrence_repository.dart';

/// Drift-backed implementation of [IInstallmentOccurrenceRepository].
///
/// Delegates all data access to [InstallmentOccurrenceDao]. All DAO
/// exceptions are caught and wrapped in [Err(DatabaseFailure(...))] — no raw
/// exceptions propagate to callers.
class InstallmentOccurrenceRepositoryImpl
    implements IInstallmentOccurrenceRepository {
  /// Creates an [InstallmentOccurrenceRepositoryImpl].
  ///
  /// Parameters:
  /// - [dao]: DAO for installment occurrence table operations.
  const InstallmentOccurrenceRepositoryImpl(this._dao);

  final InstallmentOccurrenceDao _dao;

  @override
  Stream<List<InstallmentOccurrence>> watchByPlan(String planId) {
    return _dao.watchByPlan(planId);
  }

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    try {
      await _dao.markPosted(id, transactionId);
      return const Ok(null);
    } on Object catch (e) {
      dev.log(
        'InstallmentOccurrenceRepositoryImpl.markPosted: $e',
        name: 'InstallmentOccurrenceRepositoryImpl',
      );
      return Err(
        DatabaseFailure('Failed to mark installment occurrence as posted: $e'),
      );
    }
  }
}
