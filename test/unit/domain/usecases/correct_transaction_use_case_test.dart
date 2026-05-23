// test/unit/domain/usecases/correct_transaction_use_case_test.dart
//
// Unit tests for CorrectTransactionUseCase (T-53).
// Uses hand-written fakes; no database I/O.
//
// Test cases:
//   T-53.1. financial edit → voided original + reversal + correction produced
//   T-53.2. in-place edit → direct UPDATE, no new transactions
//   T-53.3. soft-delete → void$() called, returns Ok(null)
//   T-53.4. correction-of-correction → chain links to immediate predecessor

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/transaction/correct_transaction_use_case.dart';

// ignore: prefer_const_constructors
final _uuid = Uuid();

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

// ---------------------------------------------------------------------------
// Fake LedgerRepository
// ---------------------------------------------------------------------------

class _FakeLedgerRepository implements LedgerRepository {
  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);

  @override
  Future<bool> eqAccountExists(String currencyCode) async => true;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      Ok('__EQ_$currencyCode');
}

// ---------------------------------------------------------------------------
// Fake TransactionRepository
// ---------------------------------------------------------------------------

class _FakeTransactionRepository implements ITransactionRepository {
  final _transactions = <String, Transaction>{};
  final _correctionChainCalls = <Map<String, dynamic>>[];
  final _nonFinancialPatches = <String, TransactionNonFinancialPatch>{};
  final _voidedIds = <String>[];

  void seed(Transaction tx) => _transactions[tx.id] = tx;

  List<Map<String, dynamic>> get correctionChainCalls =>
      List.unmodifiable(_correctionChainCalls);
  List<String> get voidedIds => List.unmodifiable(_voidedIds);
  Map<String, TransactionNonFinancialPatch> get patches =>
      Map.unmodifiable(_nonFinancialPatches);

  @override
  Stream<Transaction?> watchById(String id) => Stream.value(_transactions[id]);

  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) async {
    _correctionChainCalls.add({
      'originalId': originalId,
      'reversal': reversal,
      'correction': correction,
    });
    _transactions[correction.id] = correction;
    return Ok(correction);
  }

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) async {
    _nonFinancialPatches[id] = patch;
    final existing = _transactions[id];
    if (existing == null) {
      return const Err(NotFoundFailure('not found'));
    }
    final updated = existing.copyWith(
      title: patch.title ?? existing.title,
      description: patch.description ?? existing.description,
    );
    _transactions[id] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<void>> void$(String id) async {
    _voidedIds.add(id);
    final existing = _transactions[id];
    if (existing != null) {
      _transactions[id] = existing.copyWith(status: TransactionStatus.voided);
    }
    return const Ok(null);
  }

  // --- Unused stubs ---
  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> create(Transaction draft) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> bulkVoid(List<String> ids) => throw UnimplementedError();
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

  @override
  Future<int> countPosted() => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Transaction _makePostedExpense({
  String? id,
  int amountMinor = 10000,
  String? categoryId,
  String? accountSourceId,
}) {
  return Transaction(
    id: id ?? _uuid.v4(),
    type: TransactionType.expense,
    status: TransactionStatus.posted,
    dateTime: _now - 3600,
    amountMinor: amountMinor,
    currencyCode: 'INR',
    categoryId: categoryId ?? 'cat-1',
    accountSourceId: accountSourceId ?? 'acc-1',
    createdAt: _now - 3600,
    updatedAt: _now - 3600,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeTransactionRepository repo;
  late LedgerEngine engine;
  late CorrectTransactionUseCase useCase;

  setUp(() {
    repo = _FakeTransactionRepository();
    engine = LedgerEngine(_FakeLedgerRepository());
    useCase = CorrectTransactionUseCase(repo, engine);
  });

  // T-53.1. Financial edit — correction chain produced
  test('T-53.1 financial edit produces voided + reversal + correction',
      () async {
    final original = _makePostedExpense(amountMinor: 10000);
    repo.seed(original);

    // Change amount — financial field.
    final updated = original.copyWith(
      id: _uuid.v4(),
      amountMinor: 15000,
    );

    final result = await useCase.call(
      originalId: original.id,
      updated: updated,
    );

    expect(result, isA<Ok<Transaction?>>());
    final correction = (result as Ok<Transaction?>).value!;
    expect(correction.purpose, TransactionPurpose.correction);

    // correctFinancialChain was called once with the correct IDs.
    expect(repo.correctionChainCalls, hasLength(1));
    final call = repo.correctionChainCalls.first;
    expect(call['originalId'], original.id);
    expect(
      (call['correction'] as Transaction).correctsTransactionId,
      original.id,
    );
    expect(
      (call['reversal'] as Transaction).purpose,
      TransactionPurpose.reversal,
    );
  });

  // T-53.2. In-place edit — direct UPDATE, no correction chain
  test('T-53.2 in-place edit: updateNonFinancial called, no chain', () async {
    final original = _makePostedExpense();
    repo.seed(original);

    // Change only title — in-place field.
    final updated = original.copyWith(title: 'Updated title');

    final result = await useCase.call(
      originalId: original.id,
      updated: updated,
    );

    expect(result, isA<Ok<Transaction?>>());
    expect(repo.correctionChainCalls, isEmpty);
    expect(repo.patches.containsKey(original.id), isTrue);
    expect(repo.patches[original.id]!.title, 'Updated title');
  });

  // T-53.3. Soft-delete — void$() called, returns Ok(null)
  test('T-53.3 soft-delete: void\$ called, result is Ok(null)', () async {
    final original = _makePostedExpense();
    repo.seed(original);

    final result = await useCase.call(
      originalId: original.id,
      updated: null, // null = soft-delete
    );

    expect(result, isA<Ok<Transaction?>>());
    expect((result as Ok<Transaction?>).value, isNull);
    expect(repo.voidedIds, contains(original.id));
    expect(repo.correctionChainCalls, isEmpty);
  });

  // T-53.4. Correction-of-correction — chain points to previous correction
  test(
      'T-53.4 correction-of-correction: correctsTransactionId points to previous',
      () async {
    // The "original" here is itself a correction from a previous chain.
    final prevCorrection = _makePostedExpense().copyWith(
      purpose: TransactionPurpose.correction,
      amountMinor: 12000,
    );
    repo.seed(prevCorrection);

    // Correct the correction with a new amount.
    final updated = prevCorrection.copyWith(
      id: _uuid.v4(),
      amountMinor: 18000,
    );

    await useCase.call(
      originalId: prevCorrection.id,
      updated: updated,
    );

    expect(repo.correctionChainCalls, hasLength(1));
    final call = repo.correctionChainCalls.first;
    // corrects_transaction_id must point to the immediate predecessor
    // (prevCorrection), not an earlier ancestor.
    expect(
      (call['correction'] as Transaction).correctsTransactionId,
      prevCorrection.id,
    );
  });
}
