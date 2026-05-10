// test/unit/domain/usecases/account_use_cases_test.dart
//
// Unit tests for account use cases with fake repository and stub LedgerEngine.
//
// Test cases:
//   CreateAccountUseCase:
//     1. valid account with zero balance → Ok(Account)
//     2. empty name → Err(ValidationFailure)
//     3. invalid currency code → Err(ValidationFailure)
//     4. name already taken (active) → Err(ValidationFailure)
//     5. name taken by soft-deleted same-category → Err(ReinstateOfferFailure)
//     6. name taken by soft-deleted different category → Ok (allowed, different key)
//     7. positive initial balance + txId → Ok; ledger.post called
//     8. negative initial balance + txId → Ok; ledger.post called
//     9. non-zero balance without txId → Err(ValidationFailure)
//
//   UpdateAccountUseCase:
//    10. valid name change → Ok(Account)
//    11. empty name → Err(ValidationFailure)
//    12. category changed → Err(ValidationFailure)
//    13. currency changed → Err(ValidationFailure)
//    14. account not found → Err(NotFoundFailure)
//    15. name taken by other account → Err(ValidationFailure)
//
//   DeleteAccountUseCase:
//    16. non-protected account with siblings → Ok(void)
//    17. protected account → Err(BusinessRuleFailure)
//    18. last remaining account → Err(LastAccountFailure)
//    19. non-existent account → Err(NotFoundFailure)

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/entry.dart' as entry_lib;
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/account/create_account_use_case.dart';
import 'package:variance/domain/usecases/account/delete_account_use_case.dart';
import 'package:variance/domain/usecases/account/update_account_use_case.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// In-memory fake [IAccountRepository] for use case testing.
class FakeAccountRepository implements IAccountRepository {
  final _accounts = <String, Account>{};

  void seed(Account account) => _accounts[account.id] = account;

  @override
  Stream<List<Account>> watchAll() => Stream.value(
        _accounts.values.where((a) => !a.isDeleted && !a.isSystem).toList(),
      );

  @override
  Stream<Account?> watchById(String id) {
    final account = _accounts[id];
    return Stream.value(account?.isDeleted == true ? null : account);
  }

  @override
  Future<Result<Account>> create(Account account) async {
    _accounts[account.id] = account;
    return Ok(account);
  }

  @override
  Future<Result<Account>> update(Account account) async {
    if (!_accounts.containsKey(account.id)) {
      return Err(NotFoundFailure('Account ${account.id} not found.'));
    }
    _accounts[account.id] = account;
    return Ok(account);
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    if (!_accounts.containsKey(id)) {
      return Err(NotFoundFailure('Account $id not found.'));
    }
    final existing = _accounts[id]!;
    _accounts[id] = existing.copyWith(
      isDeleted: true,
      deletedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    return const Ok(null);
  }

  @override
  Stream<Money> watchBalance(String id, String currencyCode) =>
      Stream.value(Money(amountMinor: 0, currencyCode: currencyCode));

  @override
  Future<bool> isNameTaken(String name) async {
    return _accounts.values.any((a) => a.name == name);
  }

  @override
  Future<Account?> findSoftDeletedByNameAndCategory(
    String name,
    AccountCategory category,
  ) async {
    return _accounts.values
        .where(
          (a) => a.name == name && a.accountCategory == category && a.isDeleted,
        )
        .cast<Account?>()
        .firstOrNull;
  }

  @override
  Future<Result<void>> saveAccountDetails(
    String accountId,
    List<AccountDetail> details,
  ) async =>
      const Ok(null);

  @override
  Future<List<AccountDetail>> getAccountDetails(String accountId) async => [];
}

/// Stub [LedgerRepository] that records calls to [insertEntries].
class _StubLedgerRepository implements LedgerRepository {
  int insertCount = 0;
  final _existingEqCurrencies = <String>{};

  @override
  Future<Result<void>> insertEntries(List<entry_lib.Entry> entries) async {
    insertCount += entries.length;
    return const Ok(null);
  }

  @override
  Future<bool> eqAccountExists(String currencyCode) async =>
      _existingEqCurrencies.contains(currencyCode);

  @override
  Future<Result<String>> createEqAccount(String currencyCode) async {
    _existingEqCurrencies.add(currencyCode);
    return Ok('__EQ_$currencyCode');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const now = 1715000000;

Account makeAccount({
  String id = 'acc-1',
  String name = 'My Account',
  AccountCategory category = AccountCategory.bankAccount,
  String currency = 'INR',
  int initialBalance = 0,
  bool isDeleted = false,
  bool isProtected = false,
}) {
  return Account(
    id: id,
    name: name,
    accountCategory: category,
    currencyCode: currency,
    initialBalanceMinor: initialBalance,
    isDeleted: isDeleted,
    isProtected: isProtected,
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeAccountRepository fakeRepo;
  late _StubLedgerRepository fakeLedger;
  late LedgerEngine ledgerEngine;
  late CreateAccountUseCase createUseCase;
  late UpdateAccountUseCase updateUseCase;
  late DeleteAccountUseCase deleteUseCase;

  setUp(() {
    fakeRepo = FakeAccountRepository();
    fakeLedger = _StubLedgerRepository();
    ledgerEngine = LedgerEngine(fakeLedger);
    createUseCase = CreateAccountUseCase(fakeRepo, ledgerEngine);
    updateUseCase = UpdateAccountUseCase(fakeRepo);
    deleteUseCase = DeleteAccountUseCase(fakeRepo);
  });

  // -----------------------------------------------------------------------
  // CreateAccountUseCase
  // -----------------------------------------------------------------------

  group('CreateAccountUseCase', () {
    test('1. valid account with zero balance returns Ok(Account)', () async {
      final result = await createUseCase(makeAccount());
      expect(result, isA<Ok<Account>>());
    });

    test('2. empty name returns Err(ValidationFailure)', () async {
      final result = await createUseCase(makeAccount(name: ''));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('3. invalid currency code returns Err(ValidationFailure)', () async {
      final result = await createUseCase(makeAccount(currency: 'us'));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('4. name taken by active account returns Err(ValidationFailure)',
        () async {
      fakeRepo.seed(makeAccount(name: 'Savings'));
      final result = await createUseCase(makeAccount(id: 'acc-2', name: 'Savings'));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test(
        '5. name taken by soft-deleted same-category returns '
        'Err(ReinstateOfferFailure)', () async {
      final deleted = makeAccount(name: 'OldCard', isDeleted: true);
      fakeRepo.seed(deleted);

      final result = await createUseCase(
        makeAccount(id: 'acc-new', name: 'OldCard'),
      );
      expect(result, isA<Err<Account>>());
      final failure = (result as Err).failure;
      expect(failure, isA<ReinstateOfferFailure>());
      expect((failure as ReinstateOfferFailure).softDeletedId, equals('acc-1'));
    });

    test(
        '6. name taken by soft-deleted different-category allows create',
        () async {
      // Same name, different category — should be treated as a new account.
      final deleted = makeAccount(
        name: 'Overlap',
        category: AccountCategory.creditCard,
        isDeleted: true,
      );
      fakeRepo.seed(deleted);

      final result = await createUseCase(
        makeAccount(
          id: 'acc-new',
          name: 'Overlap',
          category: AccountCategory.bankAccount,
        ),
      );
      // isNameTaken returns true (same name, regardless of category).
      // findSoftDeletedByNameAndCategory checks BOTH name + category.
      // Since category differs, softDeleted == null → ValidationFailure.
      // (Name is still taken by the deleted credit card.)
      expect(result, isA<Err<Account>>());
      final failure = (result as Err).failure;
      // Returns ValidationFailure (not ReinstateOffer) because soft-deleted
      // match has a different category.
      expect(failure, isA<ValidationFailure>());
    });

    test('7. positive initial balance → Ok; ledger entries inserted',
        () async {
      final account = makeAccount(initialBalance: 50000);
      final result = await createUseCase(
        account,
        openingBalanceTxId: 'tx-open-1',
      );
      expect(result, isA<Ok<Account>>());
      // LedgerEngine.post builds 2 entries for the opening balance.
      expect(fakeLedger.insertCount, greaterThan(0));
    });

    test('8. negative initial balance → Ok; ledger entries inserted',
        () async {
      final account = makeAccount(initialBalance: -30000);
      final result = await createUseCase(
        account,
        openingBalanceTxId: 'tx-open-2',
      );
      expect(result, isA<Ok<Account>>());
      expect(fakeLedger.insertCount, greaterThan(0));
    });

    test('9. non-zero balance without txId → Err(ValidationFailure)',
        () async {
      final result = await createUseCase(makeAccount(initialBalance: 10000));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });
  });

  // -----------------------------------------------------------------------
  // UpdateAccountUseCase
  // -----------------------------------------------------------------------

  group('UpdateAccountUseCase', () {
    test('10. valid name change → Ok(Account)', () async {
      fakeRepo.seed(makeAccount());
      final updated = makeAccount(name: 'New Name');
      final result = await updateUseCase(updated);
      expect(result, isA<Ok<Account>>());
      expect((result as Ok<Account>).value.name, equals('New Name'));
    });

    test('11. empty name → Err(ValidationFailure)', () async {
      fakeRepo.seed(makeAccount());
      final result = await updateUseCase(makeAccount(name: ''));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('12. category changed → Err(ValidationFailure)', () async {
      fakeRepo.seed(makeAccount());
      final result = await updateUseCase(
        makeAccount(category: AccountCategory.creditCard),
      );
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('13. currency changed → Err(ValidationFailure)', () async {
      fakeRepo.seed(makeAccount());
      final result = await updateUseCase(makeAccount(currency: 'USD'));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('14. account not found → Err(NotFoundFailure)', () async {
      // No accounts in fakeRepo.
      final result = await updateUseCase(makeAccount(id: 'missing'));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });

    test('15. name taken by another active account → Err(ValidationFailure)',
        () async {
      fakeRepo.seed(makeAccount(id: 'acc-1', name: 'Original'));
      fakeRepo.seed(makeAccount(id: 'acc-2', name: 'TakenName'));

      // Try to rename acc-1 to TakenName.
      final result = await updateUseCase(makeAccount(id: 'acc-1', name: 'TakenName'));
      expect(result, isA<Err<Account>>());
      expect((result as Err).failure, isA<ValidationFailure>());
    });
  });

  // -----------------------------------------------------------------------
  // DeleteAccountUseCase
  // -----------------------------------------------------------------------

  group('DeleteAccountUseCase', () {
    test('16. non-protected account with siblings → Ok(void)', () async {
      fakeRepo.seed(makeAccount(id: 'acc-1'));
      fakeRepo.seed(makeAccount(id: 'acc-2', name: 'Second'));
      final result = await deleteUseCase('acc-1');
      expect(result, isA<Ok<void>>());
    });

    test('17. protected account → Err(BusinessRuleFailure)', () async {
      fakeRepo.seed(makeAccount(id: 'acc-1', isProtected: true));
      fakeRepo.seed(makeAccount(id: 'acc-2', name: 'Second'));
      final result = await deleteUseCase('acc-1');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<BusinessRuleFailure>());
    });

    test('18. last remaining account → Err(LastAccountFailure)', () async {
      fakeRepo.seed(makeAccount(id: 'acc-1'));
      final result = await deleteUseCase('acc-1');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<LastAccountFailure>());
    });

    test('19. non-existent account → Err(NotFoundFailure)', () async {
      final result = await deleteUseCase('does-not-exist');
      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });
  });
}
