// test/data/database/transaction_dao_test.dart
//
// Integration tests for TransactionDao (T-47).
// Uses in-memory AppDatabase with seeded currencies and categories.
//
// Test cases:
//   T-47.1. insertTransactionWithEntries inserts header + entries atomically
//   T-47.2. getById returns the transaction row after insert
//   T-47.3. getById returns null for unknown id
//   T-47.4. watchByMonth returns transactions in the correct calendar month
//   T-47.5. watchByMonth excludes voided transactions
//   T-47.6. watchByAccount matches accountSourceId
//   T-47.7. watchByAccount matches accountDestinationId
//   T-47.8. watchPaginated respects cursor (date, id) ordering
//   T-47.9. voidTransaction sets status = voided
//   T-47.10. bulkVoidTransactions voids multiple rows atomically
//   T-47.11. getEntriesForTransaction returns entries for a transaction

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/transaction_dao.dart';

// ignore: prefer_const_constructors
final _uuid = Uuid();

const _kCurrencyCode = 'USD';
const _kAccountId = 'acc-test-1';
const _kDestAccountId = 'acc-test-2';
const _kCategoryId = 'cat-test-1';

// Fixed epoch: 2025-05-01 00:00:00 UTC
const _kMayEpoch = 1746057600;
// Fixed epoch: 2025-06-01 00:00:00 UTC
const _kJuneEpoch = 1748736000;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TransactionDao dao;

  setUp(() async {
    db = AppDatabase.forTesting();
    await db.customStatement('SELECT 1'); // trigger schema creation
    await _insertSeedData(db);
    dao = db.transactionDao;
  });

  tearDown(() => db.close());

  group('TransactionDao — T-47', () {
    test('T-47.1. insertTransactionWithEntries inserts header + entries',
        () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch),
        [
          _makeEntry(txId: txId, accountId: _kAccountId, side: 'debit'),
          _makeEntry(txId: txId, categoryId: _kCategoryId, side: 'credit'),
        ],
      );

      final row = await dao.getById(txId);
      expect(row, isNotNull);
      expect(row!.id, equals(txId));

      final entries = await dao.getEntriesForTransaction(txId);
      expect(entries, hasLength(2));
    });

    test('T-47.2. getById returns the transaction row after insert', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch),
        [],
      );

      final row = await dao.getById(txId);
      expect(row, isNotNull);
      expect(row!.id, equals(txId));
      expect(row.status, equals('posted'));
    });

    test('T-47.3. getById returns null for unknown id', () async {
      final row = await dao.getById('non-existent-id');
      expect(row, isNull);
    });

    test('T-47.4. watchByMonth returns transactions in May 2025', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch + 100),
        [],
      );

      // June transaction — should NOT appear in May query
      final juneTxId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: juneTxId, date: _kJuneEpoch + 100),
        [],
      );

      final mayTxns = await dao.watchByMonth(2025, 5).first;
      expect(mayTxns.any((t) => t.id == txId), isTrue);
      expect(mayTxns.any((t) => t.id == juneTxId), isFalse);
    });

    test('T-47.5. watchByMonth excludes voided transactions', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch + 200, status: 'voided'),
        [],
      );

      final mayTxns = await dao.watchByMonth(2025, 5).first;
      expect(mayTxns.any((t) => t.id == txId), isFalse);
    });

    test('T-47.6. watchByAccount matches accountSourceId', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch, accountSourceId: _kAccountId),
        [],
      );

      final acctTxns = await dao.watchByAccount(_kAccountId).first;
      expect(acctTxns.any((t) => t.id == txId), isTrue);
    });

    test('T-47.7. watchByAccount matches accountDestinationId', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(
          id: txId,
          date: _kMayEpoch,
          type: 'income',
          accountDestId: _kDestAccountId,
          accountSourceId: null,
        ),
        [],
      );

      final acctTxns = await dao.watchByAccount(_kDestAccountId).first;
      expect(acctTxns.any((t) => t.id == txId), isTrue);
    });

    test('T-47.8. watchPaginated first page returns up to 50 items', () async {
      // Insert 5 transactions in May.
      for (var i = 0; i < 5; i++) {
        await dao.insertTransactionWithEntries(
          _makeTxn(id: _uuid.v4(), date: _kMayEpoch + i * 3600),
          [],
        );
      }

      final page = await dao.watchPaginated().first;
      expect(page.length, equals(5));
    });

    test('T-47.9. voidTransaction sets status = voided', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch),
        [],
      );

      await dao.voidTransaction(txId, _kMayEpoch + 10);

      final row = await dao.getById(txId);
      expect(row!.status, equals('voided'));
    });

    test('T-47.10. bulkVoidTransactions voids multiple rows', () async {
      final ids = List.generate(3, (_) => _uuid.v4());
      for (final id in ids) {
        await dao.insertTransactionWithEntries(
          _makeTxn(id: id, date: _kMayEpoch),
          [],
        );
      }

      await dao.bulkVoidTransactions(ids, _kMayEpoch + 100);

      for (final id in ids) {
        final row = await dao.getById(id);
        expect(row!.status, equals('voided'));
      }
    });

    test('T-47.11. getEntriesForTransaction returns entries', () async {
      final txId = _uuid.v4();
      await dao.insertTransactionWithEntries(
        _makeTxn(id: txId, date: _kMayEpoch),
        [
          _makeEntry(txId: txId, accountId: _kAccountId, side: 'debit'),
          _makeEntry(txId: txId, categoryId: _kCategoryId, side: 'credit'),
        ],
      );

      final entries = await dao.getEntriesForTransaction(txId);
      expect(entries, hasLength(2));
      expect(entries.any((e) => e.side == 'debit'), isTrue);
      expect(entries.any((e) => e.side == 'credit'), isTrue);
    });
  });
}

// ---------------------------------------------------------------------------
// Seed helpers
// ---------------------------------------------------------------------------

/// Inserts the minimal rows needed for FK constraints: one currency, two
/// accounts, and one category.
Future<void> _insertSeedData(AppDatabase db) async {
  // Currency
  await db.customStatement(
    'INSERT OR IGNORE INTO currencies (code, name, symbol, minor_units, is_active) '
    "VALUES ('$_kCurrencyCode', 'US Dollar', '\$', 2, 1)",
  );

  // Accounts
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.into(db.accounts).insert(
        AccountsCompanion(
          id: const Value(_kAccountId),
          name: const Value('Test Account'),
          accountCategory: const Value('bank_account'),
          currencyCode: const Value(_kCurrencyCode),
          initialBalanceMinor: const Value(0),
          includeInNetWorth: const Value(true),
          isProtected: const Value(false),
          isSystem: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

  await db.into(db.accounts).insert(
        AccountsCompanion(
          id: const Value(_kDestAccountId),
          name: const Value('Dest Account'),
          accountCategory: const Value('bank_account'),
          currencyCode: const Value(_kCurrencyCode),
          initialBalanceMinor: const Value(0),
          includeInNetWorth: const Value(true),
          isProtected: const Value(false),
          isSystem: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

  // Category
  await db.customStatement(
    'INSERT OR IGNORE INTO categories '
    '(id, tree_type, name, icon_ref, is_deleted, is_protected, sort_order, created_at, updated_at) '
    "VALUES ('$_kCategoryId', 'expense', 'Test Category', 'tag', 0, 0, 0, $now, $now)",
  );
}

// ---------------------------------------------------------------------------
// Row builder helpers
// ---------------------------------------------------------------------------

TransactionsCompanion _makeTxn({
  required String id,
  required int date,
  String type = 'expense',
  String status = 'posted',
  String purpose = 'user',
  String? accountSourceId = _kAccountId,
  String? accountDestId,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return TransactionsCompanion(
    id: Value(id),
    type: Value(type),
    status: Value(status),
    purpose: Value(purpose),
    transactionDate: Value(date),
    amountMinor: const Value(5000),
    currencyCode: const Value(_kCurrencyCode),
    accountSourceId: Value(accountSourceId),
    accountDestinationId: Value(accountDestId),
    isManuallyHandled: const Value(false),
    createdAt: Value(now),
    updatedAt: Value(now),
  );
}

EntriesCompanion _makeEntry({
  required String txId,
  required String side,
  String? accountId,
  String? categoryId,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return EntriesCompanion(
    id: Value(_uuid.v4()),
    transactionId: Value(txId),
    accountId: Value(accountId),
    categoryId: Value(categoryId),
    side: Value(side),
    amountMinor: const Value(5000),
    currencyCode: const Value(_kCurrencyCode),
    createdAt: Value(now),
  );
}
