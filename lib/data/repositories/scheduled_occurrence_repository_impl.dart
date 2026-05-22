// lib/data/repositories/scheduled_occurrence_repository_impl.dart
//
// Concrete Drift-backed implementation of IScheduledOccurrenceRepository.
//
// All data access delegates to ScheduledOccurrenceDao. Business logic
// (lookahead computation, pause-resume logic) lives in use cases.
//
// Epoch-day convention:
//   The `scheduled_date` column stores dates as Unix epoch days
//   (millisecondsSinceEpoch / 86400000). DateTime parameters from the
//   domain layer are converted to epoch days at this boundary.
//
// Test cases (see test/data/repositories/scheduled_occurrence_repository_impl_test.dart):
//   1. getPendingDue — returns occurrences with scheduled_date <= asOf epoch day
//   2. markPosted    — status becomes 'posted'; childTransactionId set
//   3. markSkipped   — status becomes 'skipped'
//   4. markCancelled — status becomes 'cancelled'
//   5. generateLookahead — inserts rows; existing dates skipped

import 'package:variance/data/database/daos/scheduled_occurrence_dao.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';

/// Drift-backed implementation of [IScheduledOccurrenceRepository].
///
/// Converts between epoch-day integers (stored in DB) and [DateTime] values
/// (used by the domain layer). All DB operations are delegated to
/// [ScheduledOccurrenceDao].
class ScheduledOccurrenceRepositoryImpl
    implements IScheduledOccurrenceRepository {
  /// Creates a [ScheduledOccurrenceRepositoryImpl] backed by [dao].
  const ScheduledOccurrenceRepositoryImpl(this._dao);

  final ScheduledOccurrenceDao _dao;

  /// Converts a [DateTime] to a Unix epoch day integer.
  ///
  /// Parameters:
  /// - [dt]: The date to convert. Time-of-day component is ignored.
  static int _toEpochDay(DateTime dt) => dt.millisecondsSinceEpoch ~/ 86400000;

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) {
    return _dao.pendingDueOn(_toEpochDay(asOf));
  }

  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) {
    // 24h grace period: occurrences scheduled more than 24h ago.
    final cutoff = asOf.subtract(const Duration(hours: 24));
    return _dao.pendingStackedBefore(_toEpochDay(cutoff));
  }

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async {
    try {
      await _dao.updateStatus(
        id,
        'posted',
        childTransactionId: transactionId,
      );
      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure('markPosted failed: $e'));
    }
  }

  @override
  Future<Result<void>> markSkipped(String id) async {
    try {
      await _dao.updateStatus(id, 'skipped');
      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure('markSkipped failed: $e'));
    }
  }

  @override
  Future<Result<void>> markCancelled(String id) async {
    try {
      await _dao.updateStatus(id, 'cancelled');
      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure('markCancelled failed: $e'));
    }
  }

  @override
  Future<Result<void>> generateLookahead({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<ScheduledOccurrence> occurrences,
  }) async {
    try {
      final existing = await _dao.existingScheduledDates(templateId);
      final scheduledDates = occurrences.map((o) => o.scheduledDate).toList();
      await _dao.insertBatch(
        templateId: templateId,
        scheduledDates: scheduledDates,
        existingDates: existing,
      );
      return const Ok(null);
    } on Exception catch (e) {
      return Err(DatabaseFailure('generateLookahead failed: $e'));
    }
  }
}
