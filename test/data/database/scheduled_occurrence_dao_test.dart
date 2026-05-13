// test/data/database/scheduled_occurrence_dao_test.dart
//
// Unit tests for ScheduledOccurrenceDao (T-99).
// Uses in-memory AppDatabase.
//
// Test cases:
//   1. pendingDueOn returns occurrences with scheduled_date <= asOfDays
//   2. pendingDueOn excludes occurrences with scheduled_date > asOfDays
//   3. pendingDueOn excludes non-pending occurrences
//   4. updateStatus transitions to 'posted' with childTransactionId
//   5. updateStatus transitions to 'skipped'
//   6. updateStatus transitions to 'cancelled'
//   7. existingScheduledDates returns non-cancelled dates for templateId
//   8. insertBatch skips dates in existingDates
//   9. insertBatch inserts all dates when existingDates is empty

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/scheduled_occurrence_dao.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';

// ignore: prefer_const_constructors
final _uuid = Uuid();

/// Unix epoch for 2025-05-01 (as epoch days).
const _kMayFirstEpochDay = 20210; // 2025-05-01
const _kMaySecondEpochDay = 20211;
const _kMayThirdEpochDay = 20212;

/// Inserts a minimal transaction row to satisfy FK for child_transaction_id.
///
/// The INR currency row is guaranteed by the DB seed data. Returns the id.
Future<String> _insertMinimalTransaction(AppDatabase db) async {
  final id = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.customStatement(
    '''
    INSERT INTO transactions
      (id, type, status, transaction_date, amount_minor, currency_code,
       created_at, updated_at)
    VALUES (?, 'expense', 'posted', ?, 1000, 'INR', ?, ?)
    ''',
    [id, now, now, now],
  );
  return id;
}

/// Inserts a minimal recurring_templates row so FK constraints are satisfied.
Future<String> _insertTemplate(AppDatabase db) async {
  final id = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.customStatement(
    '''
    INSERT INTO recurring_templates
      (id, transaction_type, amount_minor, currency_code, recurrence_n,
       recurrence_unit, start_date, created_at, updated_at)
    VALUES (?, 'expense', 1000, 'INR', 1, 'month', ?, ?, ?)
    ''',
    [id, _kMayFirstEpochDay, now, now],
  );
  return id;
}

/// Inserts a [ScheduledOccurrencesCompanion] and returns the occurrence id.
Future<String> _insertOccurrence(
  ScheduledOccurrenceDao dao, {
  required String templateId,
  required int scheduledDate,
  String status = 'pending',
  String? childTransactionId,
}) async {
  final id = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await dao.db.into(dao.db.scheduledOccurrences).insert(
        ScheduledOccurrencesCompanion.insert(
          id: id,
          templateId: templateId,
          scheduledDate: scheduledDate,
          status: Value(status),
          childTransactionId: childTransactionId != null
              ? Value(childTransactionId)
              : const Value.absent(),
          createdAt: now,
          updatedAt: now,
        ),
      );
  return id;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ScheduledOccurrenceDao dao;
  late String templateId;

  setUp(() async {
    db = AppDatabase.forTesting();
    await db.customStatement('SELECT 1'); // trigger schema creation
    templateId = await _insertTemplate(db);
    dao = db.scheduledOccurrenceDao;
  });

  tearDown(() => db.close());

  // -------------------------------------------------------------------------
  // pendingDueOn
  // -------------------------------------------------------------------------

  group('pendingDueOn', () {
    test('1. returns occurrences with scheduled_date <= asOfDays', () async {
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayFirstEpochDay,);
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMaySecondEpochDay,);

      final result = await dao.pendingDueOn(_kMaySecondEpochDay);

      expect(result, hasLength(2));
      expect(result.map((r) => r.scheduledDate),
          containsAll([_kMayFirstEpochDay, _kMaySecondEpochDay]),);
    });

    test('2. excludes occurrences with scheduled_date > asOfDays', () async {
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayFirstEpochDay,);
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayThirdEpochDay,);

      final result = await dao.pendingDueOn(_kMaySecondEpochDay);

      expect(result, hasLength(1));
      expect(result.first.scheduledDate, _kMayFirstEpochDay);
    });

    test('3. excludes non-pending occurrences', () async {
      await _insertOccurrence(dao,
          templateId: templateId,
          scheduledDate: _kMayFirstEpochDay,
          status: 'posted',);
      await _insertOccurrence(dao,
          templateId: templateId,
          scheduledDate: _kMaySecondEpochDay,
          status: 'skipped',);
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayThirdEpochDay,);

      final result = await dao.pendingDueOn(_kMayThirdEpochDay);

      expect(result, hasLength(1));
      expect(result.first.scheduledDate, _kMayThirdEpochDay);
      expect(result.first.status, ScheduledOccurrenceStatus.pending);
    });
  });

  // -------------------------------------------------------------------------
  // updateStatus
  // -------------------------------------------------------------------------

  group('updateStatus', () {
    test('4. transitions to posted with childTransactionId', () async {
      final occId = await _insertOccurrence(
        dao,
        templateId: templateId,
        scheduledDate: _kMayFirstEpochDay,
      );
      // Insert a real transaction so FK constraint is satisfied.
      final txId = await _insertMinimalTransaction(db);

      await dao.updateStatus(occId, 'posted', childTransactionId: txId);

      final rows = await db.select(db.scheduledOccurrences).get();
      final updated = rows.firstWhere((r) => r.id == occId);
      expect(updated.status, 'posted');
      expect(updated.childTransactionId, txId);
    });

    test('5. transitions to skipped', () async {
      final occId = await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayFirstEpochDay,);

      await dao.updateStatus(occId, 'skipped');

      final rows = await db.select(db.scheduledOccurrences).get();
      final updated = rows.firstWhere((r) => r.id == occId);
      expect(updated.status, 'skipped');
    });

    test('6. transitions to cancelled', () async {
      final occId = await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayFirstEpochDay,);

      await dao.updateStatus(occId, 'cancelled');

      final rows = await db.select(db.scheduledOccurrences).get();
      final updated = rows.firstWhere((r) => r.id == occId);
      expect(updated.status, 'cancelled');
    });
  });

  // -------------------------------------------------------------------------
  // existingScheduledDates
  // -------------------------------------------------------------------------

  group('existingScheduledDates', () {
    test('7. returns non-cancelled dates for templateId', () async {
      await _insertOccurrence(dao,
          templateId: templateId, scheduledDate: _kMayFirstEpochDay,);
      await _insertOccurrence(dao,
          templateId: templateId,
          scheduledDate: _kMaySecondEpochDay,
          status: 'posted',);
      await _insertOccurrence(dao,
          templateId: templateId,
          scheduledDate: _kMayThirdEpochDay,
          status: 'cancelled',);

      final dates = await dao.existingScheduledDates(templateId);

      expect(dates, containsAll([_kMayFirstEpochDay, _kMaySecondEpochDay]));
      expect(dates, isNot(contains(_kMayThirdEpochDay)));
    });
  });

  // -------------------------------------------------------------------------
  // insertBatch
  // -------------------------------------------------------------------------

  group('insertBatch', () {
    test('8. skips dates present in existingDates', () async {
      await dao.insertBatch(
        templateId: templateId,
        scheduledDates: [_kMayFirstEpochDay, _kMaySecondEpochDay],
        existingDates: [_kMayFirstEpochDay],
      );

      final rows = await db.select(db.scheduledOccurrences).get();
      expect(rows, hasLength(1));
      expect(rows.first.scheduledDate, _kMaySecondEpochDay);
    });

    test('9. inserts all dates when existingDates is empty', () async {
      await dao.insertBatch(
        templateId: templateId,
        scheduledDates: [
          _kMayFirstEpochDay,
          _kMaySecondEpochDay,
          _kMayThirdEpochDay,
        ],
        existingDates: [],
      );

      final rows = await db.select(db.scheduledOccurrences).get();
      expect(rows, hasLength(3));
    });
  });
}
