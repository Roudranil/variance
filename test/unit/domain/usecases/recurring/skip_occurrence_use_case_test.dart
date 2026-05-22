// test/unit/domain/usecases/recurring/skip_occurrence_use_case_test.dart
//
// Unit tests for SkipOccurrenceUseCase (T-112).
//
// Test cases:
//   1. Valid skip → Ok(void); markSkipped called with correct id.
//   2. Repository failure → Err propagated.

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/usecases/recurring/skip_occurrence_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeOccurrenceRepository implements IScheduledOccurrenceRepository {
  _FakeOccurrenceRepository({this.skipError});

  final Failure? skipError;

  final List<String> skippedIds = [];

  @override
  Future<Result<void>> markSkipped(String id) async {
    if (skipError != null) return Err(skipError!);
    skippedIds.add(id);
    return const Ok(null);
  }

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async => [];

  @override
  Future<List<ScheduledOccurrence>> getStackedRemindAndConfirm(
    DateTime asOf,
  ) async =>
      [];

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async =>
      const Ok(null);

  @override
  Future<Result<void>> markCancelled(String id) async => const Ok(null);

  @override
  Future<Result<void>> generateLookahead({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<ScheduledOccurrence> occurrences,
  }) async =>
      const Ok(null);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SkipOccurrenceUseCase', () {
    // -------------------------------------------------------------------------
    // 1. Valid skip
    // -------------------------------------------------------------------------
    test('valid skip returns Ok and calls markSkipped with correct id',
        () async {
      final repo = _FakeOccurrenceRepository();
      final useCase = SkipOccurrenceUseCase(repo);

      const occurrenceId = 'occ-001';
      final result = await useCase(occurrenceId);

      expect(result, isA<Ok<void>>());
      expect(repo.skippedIds, contains(occurrenceId));
    });

    // -------------------------------------------------------------------------
    // 2. Repository failure is propagated
    // -------------------------------------------------------------------------
    test('repository failure is propagated as Err', () async {
      const failure = DatabaseFailure('DB write failed');
      final repo = _FakeOccurrenceRepository(skipError: failure);
      final useCase = SkipOccurrenceUseCase(repo);

      final result = await useCase('occ-999');

      expect(result, isA<Err<void>>());
      final err = result as Err<void>;
      expect(err.failure, isA<DatabaseFailure>());
      expect(err.failure.message, 'DB write failed');
    });
  });
}
