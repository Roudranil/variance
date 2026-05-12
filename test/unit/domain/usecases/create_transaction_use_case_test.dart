// test/unit/domain/usecases/create_transaction_use_case_test.dart
//
// Unit tests for CreateTransactionUseCase (T-49, T-50).
// Uses fake repository and fake LedgerEngine to avoid database I/O.
//
// Test cases:
//   T-49.1. valid expense → Ok(Transaction); entries created (2 rows)
//   T-49.2. valid income → Ok(Transaction); entries created (2 rows)
//   T-49.3. amount = 0 → Err(ValidationFailure)
//   T-49.4. expense missing category_id → Err(ValidationFailure)
//   T-49.5. income missing account_destination_id → Err(ValidationFailure)
//   T-49.6. expense missing account_source_id → Err(ValidationFailure)
//   T-49.7. date_time = 0 → Err(ValidationFailure)
//   T-50.1. same-currency transfer → Ok(Transaction)
//   T-50.2. cross-currency transfer with exchange_rate_micro → Ok(Transaction)
//   T-50.3. cross-currency transfer without exchange_rate_micro → Err(ValidationFailure)
//   T-50.4. transfer-with-fee → Ok(Transaction); compound_group_id set
//   T-50.5. transfer missing account_source_id → Err(ValidationFailure)
//   T-50.6. transfer missing account_destination_id → Err(ValidationFailure)
//   T-50.7. transfer-with-fee with fee amount = 0 → Err(ValidationFailure)

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/transaction/create_transaction_use_case.dart';

// ---------------------------------------------------------------------------
// Fake LedgerRepository
// ---------------------------------------------------------------------------

/// Fake [LedgerRepository] that records insertEntries calls and always succeeds.
class FakeLedgerRepository implements LedgerRepository {
  final _insertedEntries = <List<Entry>>[];
  bool eqExists = false;
  bool failInsert = false;

  /// Returns all entry lists recorded during the test.
  List<List<Entry>> get insertedEntries => List.unmodifiable(_insertedEntries);

  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async {
    if (failInsert) {
      return const Err(DatabaseFailure('Simulated insert failure'));
    }
    _insertedEntries.add(entries);
    return const Ok(null);
  }

  @override
  Future<bool> eqAccountExists(String currencyCode) async => eqExists;

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async {
    eqExists = true;
    return Ok('__EQ_$currencyCode');
  }
}

// ---------------------------------------------------------------------------
// Fake TransactionRepository
// ---------------------------------------------------------------------------

/// Thin fake that records persisted transactions and entries.
///
/// Implements [ITransactionRepository] directly (no DAO dependency) so that
/// domain-layer unit tests are fully isolated from the database layer.
class FakeTransactionRepository implements ITransactionRepository {
  final _saved = <String, Transaction>{};
  final _savedEntries = <String, List<Entry>>{};
  bool failSave = false;

  /// Returns the persisted transaction for [id], or null.
  Transaction? getSaved(String id) => _saved[id];

  /// Returns the persisted entries for [transactionId].
  List<Entry> getEntries(String transactionId) =>
      _savedEntries[transactionId] ?? [];

  /// Mirrors [TransactionRepositoryImpl.createWithEntries].
  Future<Result<Transaction>> createWithEntries(
    Transaction draft,
    List<Entry> entries,
  ) async {
    if (failSave) {
      return const Err(DatabaseFailure('Simulated save failure'));
    }
    _saved[draft.id] = draft;
    _savedEntries[draft.id] = entries;
    return Ok(draft);
  }

  @override
  Future<Result<Transaction>> create(Transaction draft) async {
    if (failSave) return const Err(DatabaseFailure('Simulated save failure'));
    _saved[draft.id] = draft;
    return Ok(draft);
  }

  @override
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Transaction>> updateNonFinancial(
    String id,
    TransactionNonFinancialPatch patch,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> void$(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> bulkVoid(List<String> ids) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Transaction>>> search(
    String query, {
    TransactionFilters? filters,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Transaction>> watchByMonth(
    int year,
    int month, {
    TransactionFilters? filters,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Transaction?> watchById(String id) {
    throw UnimplementedError();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// ignore: prefer_const_constructors
final _uuid = Uuid();

const _now = 1715000000; // fixed epoch for tests
const _accountId = 'acc-1';
const _destAccountId = 'acc-2';
const _categoryId = 'cat-1';
const _currencyCode = 'INR';

Transaction _baseExpense({
  String? id,
  int amountMinor = 5000,
  String? accountSourceId = _accountId,
  String? categoryId = _categoryId,
  int dateTime = _now,
}) {
  return Transaction(
    id: id ?? _uuid.v4(),
    type: TransactionType.expense,
    status: TransactionStatus.posted,
    dateTime: dateTime,
    amountMinor: amountMinor,
    currencyCode: _currencyCode,
    accountSourceId: accountSourceId,
    categoryId: categoryId,
    createdAt: _now,
    updatedAt: _now,
  );
}

Transaction _baseIncome({
  String? id,
  int amountMinor = 5000,
  String? accountDestinationId = _accountId,
  String? categoryId = _categoryId,
  int dateTime = _now,
}) {
  return Transaction(
    id: id ?? _uuid.v4(),
    type: TransactionType.income,
    status: TransactionStatus.posted,
    dateTime: dateTime,
    amountMinor: amountMinor,
    currencyCode: _currencyCode,
    accountDestinationId: accountDestinationId,
    categoryId: categoryId,
    createdAt: _now,
    updatedAt: _now,
  );
}

Transaction _baseTransfer({
  String? id,
  int amountMinor = 5000,
  String? accountSourceId = _accountId,
  String? accountDestinationId = _destAccountId,
  String? currencyCode = _currencyCode,
  int? exchangeRateMicro,
  String? homeCurrencyAtCapture,
  int dateTime = _now,
}) {
  return Transaction(
    id: id ?? _uuid.v4(),
    type: TransactionType.transfer,
    status: TransactionStatus.posted,
    dateTime: dateTime,
    amountMinor: amountMinor,
    currencyCode: currencyCode ?? _currencyCode,
    accountSourceId: accountSourceId,
    accountDestinationId: accountDestinationId,
    exchangeRateMicro: exchangeRateMicro,
    homeCurrencyAtCapture: homeCurrencyAtCapture,
    createdAt: _now,
    updatedAt: _now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeLedgerRepository fakeRepo;
  late LedgerEngine ledgerEngine;
  late FakeTransactionRepository fakeTxnRepo;
  late CreateTransactionUseCase useCase;

  setUp(() {
    fakeRepo = FakeLedgerRepository();
    // LedgerEngine uses FakeLedgerRepository for EQ account resolution only
    // (buildOnly does not call insertEntries).
    ledgerEngine = LedgerEngine(fakeRepo);
    fakeTxnRepo = FakeTransactionRepository();
    useCase = CreateTransactionUseCase(fakeTxnRepo, ledgerEngine);
  });

  // -----------------------------------------------------------------------
  // T-49 — Expense and Income
  // -----------------------------------------------------------------------

  group('T-49 — Expense and Income', () {
    test('T-49.1. valid expense → Ok(Transaction); 2 entries', () async {
      final draft = _baseExpense();
      final result = await useCase.call(draft);

      expect(result, isA<Ok<Transaction>>());
      final tx = (result as Ok<Transaction>).value;
      expect(tx.type, equals(TransactionType.expense));
      // 2 entries (Dr EC, Cr A) passed to createWithEntries
      expect(fakeTxnRepo.getEntries(draft.id), hasLength(2));
    });

    test('T-49.2. valid income → Ok(Transaction); 2 entries', () async {
      final draft = _baseIncome();
      final result = await useCase.call(draft);

      expect(result, isA<Ok<Transaction>>());
      // 2 entries (Dr A, Cr IC) passed to createWithEntries
      expect(fakeTxnRepo.getEntries(draft.id), hasLength(2));
    });

    test('T-49.3. amount = 0 → Err(ValidationFailure)', () async {
      final draft = _baseExpense(amountMinor: 0);
      final result = await useCase.call(draft);
      expect(result, isA<Err<Transaction>>());
      expect((result as Err<Transaction>).failure, isA<ValidationFailure>());
    });

    test('T-49.4. expense missing category_id → Err(ValidationFailure)',
        () async {
      final draft = _baseExpense(categoryId: null);
      final result = await useCase.call(draft);
      expect(result, isA<Err<Transaction>>());
      expect((result as Err<Transaction>).failure, isA<ValidationFailure>());
    });

    test(
      'T-49.5. income missing account_destination_id → Err(ValidationFailure)',
      () async {
        final draft = _baseIncome(accountDestinationId: null);
        final result = await useCase.call(draft);
        expect(result, isA<Err<Transaction>>());
        expect((result as Err<Transaction>).failure, isA<ValidationFailure>());
      },
    );

    test(
      'T-49.6. expense missing account_source_id → Err(ValidationFailure)',
      () async {
        final draft = _baseExpense(accountSourceId: null);
        final result = await useCase.call(draft);
        expect(result, isA<Err<Transaction>>());
        expect((result as Err<Transaction>).failure, isA<ValidationFailure>());
      },
    );

    test('T-49.7. date_time = 0 → Err(ValidationFailure)', () async {
      final draft = _baseExpense(dateTime: 0);
      final result = await useCase.call(draft);
      expect(result, isA<Err<Transaction>>());
      expect((result as Err<Transaction>).failure, isA<ValidationFailure>());
    });
  });

  // -----------------------------------------------------------------------
  // T-50 — Transfer variants
  // -----------------------------------------------------------------------

  group('T-50 — Transfer variants', () {
    test('T-50.1. same-currency transfer → Ok(Transaction)', () async {
      final draft = _baseTransfer();
      final result = await useCase.call(draft);
      expect(result, isA<Ok<Transaction>>());
      // 2 entries: Dr A₂, Cr A₁
      expect(fakeTxnRepo.getEntries(draft.id), hasLength(2));
    });

    test(
      'T-50.2. cross-currency transfer with exchange_rate_micro → Ok(Transaction)',
      () async {
        final draft = _baseTransfer(
          currencyCode: 'USD',
          exchangeRateMicro: 83000000,
          homeCurrencyAtCapture: 'INR',
        );
        final result = await useCase.call(draft);
        expect(result, isA<Ok<Transaction>>());
      },
    );

    test(
      'T-50.3. cross-currency transfer without exchange_rate_micro → Err(ValidationFailure)',
      () async {
        final draft = _baseTransfer(
          currencyCode: 'USD',
          // exchangeRateMicro is null (not supplied)
          homeCurrencyAtCapture: 'INR', // signals cross-currency
        );
        final result = await useCase.call(draft);
        expect(result, isA<Err<Transaction>>());
        expect(
          (result as Err<Transaction>).failure,
          isA<ValidationFailure>(),
        );
      },
    );

    test(
      'T-50.4. transfer-with-fee → Ok(Transaction); compound_group_id set',
      () async {
        final draft = _baseTransfer();
        final result = await useCase.call(
          draft,
          feeCategoryId: 'fee-cat-1',
          feeAmountMinor: 200,
        );
        expect(result, isA<Ok<Transaction>>());
        final tx = (result as Ok<Transaction>).value;
        expect(tx.compoundGroupId, isNotNull);
        expect(tx.compoundRole, equals('primary'));
        // 4 entries: transfer pair (Dr A₂, Cr A₁) + fee pair (Dr FC, Cr A₁)
        expect(fakeTxnRepo.getEntries(tx.id), hasLength(4));
      },
    );

    test(
      'T-50.5. transfer missing account_source_id → Err(ValidationFailure)',
      () async {
        final draft = _baseTransfer(accountSourceId: null);
        final result = await useCase.call(draft);
        expect(result, isA<Err<Transaction>>());
        expect(
          (result as Err<Transaction>).failure,
          isA<ValidationFailure>(),
        );
      },
    );

    test(
      'T-50.6. transfer missing account_destination_id → Err(ValidationFailure)',
      () async {
        final draft = _baseTransfer(accountDestinationId: null);
        final result = await useCase.call(draft);
        expect(result, isA<Err<Transaction>>());
        expect(
          (result as Err<Transaction>).failure,
          isA<ValidationFailure>(),
        );
      },
    );

    test(
      'T-50.7. transfer-with-fee with feeAmountMinor = 0 → Err(ValidationFailure)',
      () async {
        final draft = _baseTransfer();
        final result = await useCase.call(
          draft,
          feeCategoryId: 'fee-cat-1',
          feeAmountMinor: 0,
        );
        expect(result, isA<Err<Transaction>>());
        expect(
          (result as Err<Transaction>).failure,
          isA<ValidationFailure>(),
        );
      },
    );
  });
}
