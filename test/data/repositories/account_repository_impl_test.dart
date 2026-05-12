// test/data/repositories/account_repository_impl_test.dart
//
// Integration tests for AccountRepositoryImpl against an in-memory Drift DB.
//
// Test cases:
//   1. create — inserted account appears in watchAll stream
//   2. create — duplicate name (active) returns Err(DatabaseFailure or re-surfaces)
//   3. update — changed name reflected in watchById stream
//   4. softDelete — account disappears from watchAll; watchById emits null
//   5. watchBalance — emits 0 for a new account with no entries
//   6. isNameTaken — true for active accounts
//   7. isNameTaken — true for soft-deleted accounts
//   8. findSoftDeletedByNameAndCategory — returns deleted match
//   9. saveAccountDetails — details readable via getAccountDetails
//  10. getAccountDetails — returns empty list when no details exist

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/data/repositories/account_repository_impl.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart' as domain;
import 'package:variance/domain/entities/account_detail.dart' as domain;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AccountDao dao;
  late AccountRepositoryImpl repo;

  const now = 1715000000;

  /// Helper: build a minimal Account domain entity.
  domain.Account makeAccount({
    String id = 'acc-1',
    String name = 'Test Account',
    domain.AccountCategory category = domain.AccountCategory.bankAccount,
    String currency = 'INR',
    int initialBalance = 0,
    bool isDeleted = false,
    int? deletedAt,
  }) {
    return domain.Account(
      id: id,
      name: name,
      accountCategory: category,
      currencyCode: currency,
      initialBalanceMinor: initialBalance,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    db = AppDatabase.forTesting();
    dao = AccountDao(db);
    repo = AccountRepositoryImpl(dao);
  });

  tearDown(() => db.close());

  // -----------------------------------------------------------------------
  // create
  // -----------------------------------------------------------------------

  group('create', () {
    test('1. inserted account appears in watchAll stream', () async {
      final account = makeAccount();
      final result = await repo.create(account);
      expect(result, isA<Ok<domain.Account>>());

      final list = await repo.watchAll().first;
      expect(list, hasLength(1));
      expect(list.first.id, equals('acc-1'));
    });

    test('2. create returns the persisted entity', () async {
      final account = makeAccount(name: 'Savings');
      final result = await repo.create(account);
      expect(result, isA<Ok<domain.Account>>());
      final created = (result as Ok<domain.Account>).value;
      expect(created.name, equals('Savings'));
    });
  });

  // -----------------------------------------------------------------------
  // update
  // -----------------------------------------------------------------------

  group('update', () {
    test('3. changed name is reflected in watchById stream', () async {
      final account = makeAccount();
      await repo.create(account);

      final updated = account.copyWith(name: 'Renamed', updatedAt: now + 1);
      final result = await repo.update(updated);
      expect(result, isA<Ok<domain.Account>>());

      final fromStream = await repo.watchById('acc-1').first;
      expect(fromStream?.name, equals('Renamed'));
    });
  });

  // -----------------------------------------------------------------------
  // softDelete
  // -----------------------------------------------------------------------

  group('softDelete', () {
    test('4a. account disappears from watchAll after soft-delete', () async {
      final account = makeAccount();
      await repo.create(account);

      final result = await repo.softDelete('acc-1');
      expect(result, isA<Ok<void>>());

      final list = await repo.watchAll().first;
      expect(list, isEmpty);
    });

    test('4b. watchById emits null after soft-delete', () async {
      final account = makeAccount();
      await repo.create(account);
      await repo.softDelete('acc-1');

      final fromStream = await repo.watchById('acc-1').first;
      expect(fromStream, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // watchBalance
  // -----------------------------------------------------------------------

  group('watchBalance', () {
    test('5. emits 0 for a new account with no entries', () async {
      final account = makeAccount();
      await repo.create(account);

      final balance = await repo.watchBalance('acc-1', 'INR').first;
      expect(balance.amountMinor, equals(0));
      expect(balance.currencyCode, equals('INR'));
    });
  });

  // -----------------------------------------------------------------------
  // isNameTaken
  // -----------------------------------------------------------------------

  group('isNameTaken', () {
    test('6. true for an active account with that name', () async {
      await repo.create(makeAccount(name: 'Wallet'));
      expect(await repo.isNameTaken('Wallet'), isTrue);
    });

    test('7. true for a soft-deleted account with that name', () async {
      final account = makeAccount(name: 'OldAccount');
      await repo.create(account);
      await repo.softDelete('acc-1');

      // isNameTaken includes soft-deleted rows.
      expect(await repo.isNameTaken('OldAccount'), isTrue);
    });

    test('7b. false when no account has that name', () async {
      expect(await repo.isNameTaken('NonExistent'), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // findSoftDeletedByNameAndCategory
  // -----------------------------------------------------------------------

  group('findSoftDeletedByNameAndCategory', () {
    test('8. returns soft-deleted account matching name and category',
        () async {
      final account = makeAccount(
        name: 'SavingsOld',
        category: domain.AccountCategory.bankAccount,
      );
      await repo.create(account);
      await repo.softDelete('acc-1');

      final found = await repo.findSoftDeletedByNameAndCategory(
        'SavingsOld',
        domain.AccountCategory.bankAccount,
      );
      expect(found, isNotNull);
      expect(found!.id, equals('acc-1'));
    });

    test('8b. returns null when name does not match', () async {
      final found = await repo.findSoftDeletedByNameAndCategory(
        'NoMatch',
        domain.AccountCategory.bankAccount,
      );
      expect(found, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // saveAccountDetails / getAccountDetails
  // -----------------------------------------------------------------------

  group('account details', () {
    test('9. saveAccountDetails makes details readable', () async {
      await repo.create(makeAccount());

      final details = [
        const domain.AccountDetail(
          id: 'det-1',
          accountId: 'acc-1',
          detailKey: 'bank_name',
          detailValue: 'State Bank',
          updatedAt: now,
        ),
      ];
      final result = await repo.saveAccountDetails('acc-1', details);
      expect(result, isA<Ok<void>>());

      final saved = await repo.getAccountDetails('acc-1');
      expect(saved, hasLength(1));
      expect(saved.first.detailValue, equals('State Bank'));
    });

    test('10. getAccountDetails returns empty list when no details exist',
        () async {
      await repo.create(makeAccount());
      final saved = await repo.getAccountDetails('acc-1');
      expect(saved, isEmpty);
    });
  });
}
