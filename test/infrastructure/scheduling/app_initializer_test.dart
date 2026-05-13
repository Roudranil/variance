// test/infrastructure/scheduling/app_initializer_test.dart
//
// Unit tests for AppInitializer (T-103).
//
// Test cases:
//   1. both use cases called in order
//   2. lastAutoPostedCount set to count returned by PostDueOccurrencesUseCase
//   3. failure in PostDueOccurrencesUseCase is logged, lastAutoPostedCount = 0
//   4. failure in GenerateLookaheadUseCase is logged, does not affect count

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/recurring/generate_lookahead_use_case.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';

// ---------------------------------------------------------------------------
// Controllable fakes
// ---------------------------------------------------------------------------

class _FakeOccurrenceRepository implements IScheduledOccurrenceRepository {
  int? pendingCount;

  @override
  Future<List<ScheduledOccurrence>> getPendingDue(DateTime asOf) async {
    // Return the right number of pending occurrences based on pendingCount.
    if (pendingCount == null) return [];
    return List.generate(
      pendingCount!,
      (i) => ScheduledOccurrence(
        id: 'occ-$i',
        templateId: 'tmpl-1',
        scheduledDate: 0,
        createdAt: 0,
        updatedAt: 0,
      ),
    );
  }

  @override
  Future<Result<void>> markPosted(String id, String transactionId) async =>
      const Ok(null);

  @override
  Future<Result<void>> markSkipped(String id) async => const Ok(null);

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

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value([]);

  @override
  Stream<RecurringTemplate?> watchById(String id) => Stream.value(null);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) =>
      throw UnimplementedError();

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> pause(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> resume(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> softDelete(String id) => throw UnimplementedError();

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

class _FakeTransactionRepository implements ITransactionRepository {
  @override
  Future<Result<Transaction>> createWithEntries(transaction, entries) async =>
      Ok(transaction);

  @override
  Future<Result<Transaction>> create(Transaction draft) =>
      throw UnimplementedError();

  @override
  Stream<List<Transaction>> watchByMonth(int year, int month,
          {TransactionFilters? filters,}) =>
      throw UnimplementedError();

  @override
  Stream<Transaction?> watchById(String id) => throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancial(
    String id,
    Transaction draft,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> void$(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> bulkVoid(List<String> ids) =>
      throw UnimplementedError();

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) =>
      throw UnimplementedError();
}

class _NoOpLedgerRepository implements LedgerRepository {
  const _NoOpLedgerRepository();

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);

  @override
  Future<bool> eqAccountExists(String currencyCode) async => true;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      Ok('__EQ_$currencyCode');
}

/// Configurable fake PostDueOccurrencesUseCase that returns a preset count or
/// error without doing any real DB work.
class _FakePostDueOccurrencesUseCase extends PostDueOccurrencesUseCase {
  _FakePostDueOccurrencesUseCase({
    this.returnCount = 0,
    this.shouldFail = false,
  }) : super(
          _FakeTemplateRepository(),
          _FakeOccurrenceRepository(),
          _FakeTransactionRepository(),
          const LedgerEngine(_NoOpLedgerRepository()),
        );

  final int returnCount;
  final bool shouldFail;

  bool called = false;

  @override
  Future<Result<int>> call({DateTime? asOf}) async {
    called = true;
    if (shouldFail) return const Err(DatabaseFailure('Simulated failure'));
    return Ok(returnCount);
  }
}

/// Configurable fake GenerateLookaheadUseCase.
class _FakeGenerateLookaheadUseCase extends GenerateLookaheadUseCase {
  _FakeGenerateLookaheadUseCase({this.shouldFail = false})
      : super(
          _FakeTemplateRepository(),
          _FakeOccurrenceRepository(),
        );

  final bool shouldFail;
  bool called = false;

  @override
  Future<Result<int>> call({DateTime? today}) async {
    called = true;
    if (shouldFail) return const Err(DatabaseFailure('Simulated failure'));
    return const Ok(3);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Reset AppInitializer state before each test.
    AppInitializer.lastAutoPostedCount = 0;
  });

  group('AppInitializer', () {
    test('1. both use cases called in order', () async {
      final postUseCase = _FakePostDueOccurrencesUseCase(returnCount: 2);
      final lookaheadUseCase = _FakeGenerateLookaheadUseCase();

      await AppInitializer.run(
        postDueOccurrences: postUseCase,
        generateLookahead: lookaheadUseCase,
      );

      expect(postUseCase.called, isTrue);
      expect(lookaheadUseCase.called, isTrue);
    });

    test('2. lastAutoPostedCount set to count from PostDueOccurrencesUseCase',
        () async {
      final postUseCase = _FakePostDueOccurrencesUseCase(returnCount: 5);
      final lookaheadUseCase = _FakeGenerateLookaheadUseCase();

      await AppInitializer.run(
        postDueOccurrences: postUseCase,
        generateLookahead: lookaheadUseCase,
      );

      expect(AppInitializer.lastAutoPostedCount, 5);
    });

    test(
      '3. PostDueOccurrencesUseCase failure → lastAutoPostedCount = 0',
      () async {
        final postUseCase =
            _FakePostDueOccurrencesUseCase(shouldFail: true);
        final lookaheadUseCase = _FakeGenerateLookaheadUseCase();

        await AppInitializer.run(
          postDueOccurrences: postUseCase,
          generateLookahead: lookaheadUseCase,
        );

        expect(AppInitializer.lastAutoPostedCount, 0);
        // GenerateLookahead still runs even after PostDue failure.
        expect(lookaheadUseCase.called, isTrue);
      },
    );

    test(
      '4. GenerateLookaheadUseCase failure does not affect count',
      () async {
        final postUseCase = _FakePostDueOccurrencesUseCase(returnCount: 3);
        final lookaheadUseCase =
            _FakeGenerateLookaheadUseCase(shouldFail: true);

        await AppInitializer.run(
          postDueOccurrences: postUseCase,
          generateLookahead: lookaheadUseCase,
        );

        // Count from PostDue is preserved even if GenerateLookahead fails.
        expect(AppInitializer.lastAutoPostedCount, 3);
      },
    );
  });
}
