// test/data/database/installment_tracking_amounts_test.dart
//
// Unit tests for InstallmentOccurrenceDao.watchTrackingAmounts (T-132).
//
// All tests use an in-memory AppDatabase — no disk I/O, no encryption.
// FK constraints are selectively disabled for transaction inserts that
// would require a full currency/account setup.
//
// Test cases (T-132):
//   T-132.1 zero-posted state: runningTotal = 0, totalRemaining = totalConfigured
//   T-132.2 partial-posted: runningTotal reflects posted amounts only
//   T-132.3 all-posted: runningTotal = totalConfigured, totalRemaining = 0
//   T-132.4 voided child excluded from runningTotal
//   T-132.5 hasMismatch = true when projectedFinalTotal ≠ totalConfiguredMinor
//   T-132.6 hasMismatch = false when projectedFinalTotal = totalConfiguredMinor

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/domain/entities/installment_occurrence.dart' as domain;
import 'package:variance/domain/entities/installment_plan.dart' as domain;

// ---------------------------------------------------------------------------
// Helpers (mirrors installment_dao_test.dart)
// ---------------------------------------------------------------------------

/// Inserts a minimal `recurring_templates` row for [id].
Future<void> _insertParentTemplate(AppDatabase db, String id) async {
  final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.customStatement(
    '''
    INSERT INTO recurring_templates (
      id, transaction_type, status,
      amount_minor, currency_code,
      recurrence_n, recurrence_unit,
      start_date, posting_behaviour,
      is_installment, is_deleted,
      created_at, updated_at
    ) VALUES (
      ?, 'expense', 'active',
      100000, 'INR',
      1, 'month',
      20000, 'auto_post',
      1, 0,
      ?, ?
    )
  ''',
    [id, nowEpoch, nowEpoch],
  );
}

/// Inserts a minimal `installment_plans` row for [templateId].
Future<void> _insertPlan(
  AppDatabase db,
  String templateId, {
  int totalConfiguredMinor = 300000,
}) async {
  final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final plan = domain.InstallmentPlan(
    templateId: templateId,
    totalConfiguredMinor: totalConfiguredMinor,
    numberOfInstallments: 3,
    createdAt: nowEpoch,
  );
  await db.installmentPlanDao.insertPlan(plan);
}

domain.InstallmentOccurrence _makeOcc({
  required String id,
  required String templateId,
  required int seq,
  int amountMinor = 100000,
  domain.InstallmentOccurrenceStatus status =
      domain.InstallmentOccurrenceStatus.pending,
  String? childTransactionId,
}) =>
    domain.InstallmentOccurrence(
      id: id,
      templateId: templateId,
      sequenceNumber: seq,
      scheduledDate: 20000 + seq,
      amountMinor: amountMinor,
      status: status,
      childTransactionId: childTransactionId,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

/// Inserts a minimal transactions row, optionally voided.
///
/// Note: `status` field is used to mark voided transactions ('voided').
/// The transactions table uses `transaction_date` (not `date_time`).
Future<void> _insertTransaction(
  AppDatabase db,
  String txId, {
  String status = 'posted',
}) async {
  final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.customStatement(
    '''
    INSERT INTO transactions (
      id, type, status, purpose,
      transaction_date, amount_minor, currency_code,
      created_at, updated_at
    ) VALUES (
      ?, 'expense', ?, 'manual',
      ?, 100000, 'INR',
      ?, ?
    )
  ''',
    [txId, status, nowEpoch, nowEpoch, nowEpoch],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  const templateId = 'tmpl-track';
  const totalConfigured = 300000;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Disable FK enforcement during setup to avoid needing full dependency chain.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertParentTemplate(db, templateId);
    await _insertPlan(db, templateId, totalConfiguredMinor: totalConfigured);
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  // T-132.1 Zero-posted state
  test('T-132.1 zero-posted: runningTotal=0, totalRemaining=totalConfigured', () async {
    // Three pending occurrences, no postings yet.
    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(id: 'occ-1', templateId: templateId, seq: 1, amountMinor: 100000),
      _makeOcc(id: 'occ-2', templateId: templateId, seq: 2, amountMinor: 100000),
      _makeOcc(id: 'occ-3', templateId: templateId, seq: 3, amountMinor: 100000),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    expect(amounts.runningTotalMinor, 0);
    expect(amounts.totalRemainingMinor, 300000);
    expect(amounts.projectedFinalTotalMinor, 300000);
    expect(amounts.hasMismatch, isFalse);
  });

  // T-132.2 Partial-posted state
  test('T-132.2 partial-posted: runningTotal reflects posted amounts', () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertTransaction(db, 'tx-1');
    await db.customStatement('PRAGMA foreign_keys = ON');

    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(
        id: 'occ-a',
        templateId: templateId,
        seq: 1,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-1',
      ),
      _makeOcc(id: 'occ-b', templateId: templateId, seq: 2, amountMinor: 100000),
      _makeOcc(id: 'occ-c', templateId: templateId, seq: 3, amountMinor: 100000),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    expect(amounts.runningTotalMinor, 100000);
    expect(amounts.totalRemainingMinor, 200000);
    expect(amounts.projectedFinalTotalMinor, 300000);
    expect(amounts.hasMismatch, isFalse);
  });

  // T-132.3 All-posted state
  test('T-132.3 all-posted: runningTotal = totalConfigured, remaining = 0', () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertTransaction(db, 'tx-p1');
    await _insertTransaction(db, 'tx-p2');
    await _insertTransaction(db, 'tx-p3');
    await db.customStatement('PRAGMA foreign_keys = ON');

    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(
        id: 'occ-p1',
        templateId: templateId,
        seq: 1,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-p1',
      ),
      _makeOcc(
        id: 'occ-p2',
        templateId: templateId,
        seq: 2,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-p2',
      ),
      _makeOcc(
        id: 'occ-p3',
        templateId: templateId,
        seq: 3,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-p3',
      ),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    expect(amounts.runningTotalMinor, 300000);
    expect(amounts.totalRemainingMinor, 0);
    expect(amounts.projectedFinalTotalMinor, 300000);
    expect(amounts.hasMismatch, isFalse);
  });

  // T-132.4 Voided child excluded from runningTotal
  test('T-132.4 voided child transaction excluded from runningTotal', () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    // tx-voided is a voided transaction — should be excluded from running total.
    await _insertTransaction(db, 'tx-voided', status: 'voided');

    await db.customStatement('PRAGMA foreign_keys = ON');

    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(
        id: 'occ-v',
        templateId: templateId,
        seq: 1,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-voided',
      ),
      _makeOcc(id: 'occ-pend', templateId: templateId, seq: 2, amountMinor: 100000),
      _makeOcc(id: 'occ-pend2', templateId: templateId, seq: 3, amountMinor: 100000),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    // Voided child excluded → runningTotal = 0 not 100000.
    expect(amounts.runningTotalMinor, 0);
    expect(amounts.totalRemainingMinor, 200000);
    expect(amounts.projectedFinalTotalMinor, 200000);
    // 200000 ≠ 300000 → mismatch.
    expect(amounts.hasMismatch, isTrue);
  });

  // T-132.5 hasMismatch = true
  test('T-132.5 hasMismatch true when projected ≠ configured', () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertTransaction(db, 'tx-m1');
    await db.customStatement('PRAGMA foreign_keys = ON');

    // One posted (100000), one pending with overridden amount (50000 ≠ 100000).
    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(
        id: 'occ-m1',
        templateId: templateId,
        seq: 1,
        amountMinor: 100000,
        status: domain.InstallmentOccurrenceStatus.posted,
        childTransactionId: 'tx-m1',
      ),
      _makeOcc(
        id: 'occ-m2',
        templateId: templateId,
        seq: 2,
        amountMinor: 50000, // overridden below auto-calc
      ),
      _makeOcc(
        id: 'occ-m3',
        templateId: templateId,
        seq: 3,
        amountMinor: 100000,
      ),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    // projected = 100000 + 50000 + 100000 = 250000 ≠ 300000.
    expect(amounts.projectedFinalTotalMinor, 250000);
    expect(amounts.hasMismatch, isTrue);
  });

  // T-132.6 hasMismatch = false when matching
  test('T-132.6 hasMismatch false when projected = configured', () async {
    await db.installmentOccurrenceDao.insertOccurrences([
      _makeOcc(id: 'occ-eq1', templateId: templateId, seq: 1, amountMinor: 100000),
      _makeOcc(id: 'occ-eq2', templateId: templateId, seq: 2, amountMinor: 100000),
      _makeOcc(id: 'occ-eq3', templateId: templateId, seq: 3, amountMinor: 100000),
    ]);

    final amounts = await db.installmentOccurrenceDao
        .watchTrackingAmounts(templateId, totalConfigured)
        .first;

    expect(amounts.projectedFinalTotalMinor, 300000);
    expect(amounts.hasMismatch, isFalse);
  });
}
