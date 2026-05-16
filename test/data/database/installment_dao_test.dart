// test/data/database/installment_dao_test.dart
//
// Unit tests for InstallmentPlanDao and InstallmentOccurrenceDao.
//
// All tests use an in-memory AppDatabase — no disk I/O, no encryption.
// FK constraints ARE enforced (PRAGMA foreign_keys = ON via beforeOpen).
// All tests insert a parent recurring_templates row before touching the
// installment_plans or installment_occurrences tables.
//
// Test cases:
//   InstallmentPlanDao:
//     1. watchAll() emits all plans after insert
//     2. watchById() emits null when not found; emits plan after insert
//     3. insertPlan() persists and returns plan
//     4. updatePlan() persists changed fields
//     5. deletePlan() removes the row
//   InstallmentOccurrenceDao:
//     6. watchByPlan() emits occurrences ordered by sequence_number
//     7. insertOccurrences() bulk-inserts correctly
//     8. updateOccurrence() persists changed fields
//     9. deleteOccurrence() removes the row
//    10. markPosted() sets status=posted (child_transaction_id bypasses FK)
//    11. cancelPendingOccurrences() cancels only pending for a template
//   T-125 migration:
//    12. installment_occurrences index DDL is structurally valid SQL

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/domain/entities/installment_occurrence.dart' as domain;
import 'package:variance/domain/entities/installment_plan.dart' as domain;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inserts a minimal `recurring_templates` row for [id].
///
/// The `installment_plans` and `installment_occurrences` tables both have
/// FK → `recurring_templates(id)`, so a parent row must exist before any
/// installment data can be inserted.
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

/// Builds a minimal [domain.InstallmentPlan] for tests.
domain.InstallmentPlan _makePlan({
  String templateId = 'plan-1',
  int totalMinor = 300000,
  int count = 3,
}) =>
    domain.InstallmentPlan(
      templateId: templateId,
      totalConfiguredMinor: totalMinor,
      numberOfInstallments: count,
      createdAt: 1700000000,
    );

/// Builds a minimal [domain.InstallmentOccurrence] for tests.
domain.InstallmentOccurrence _makeOcc({
  required String id,
  required String templateId,
  required int seq,
  int amountMinor = 100000,
  int scheduledDate = 20000,
  domain.InstallmentOccurrenceStatus status =
      domain.InstallmentOccurrenceStatus.pending,
}) =>
    domain.InstallmentOccurrence(
      id: id,
      templateId: templateId,
      sequenceNumber: seq,
      scheduledDate: scheduledDate + seq,
      amountMinor: amountMinor,
      status: status,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // =========================================================================
  // InstallmentPlanDao (tests 1–5)
  // =========================================================================

  group('InstallmentPlanDao', () {
    // Each test inserts its own parent recurring_template row with a unique id
    // to avoid PK collisions across tests that share the same in-memory DB.

    test('1. watchAll() emits all plans after insert', () async {
      await _insertParentTemplate(db, 'plan-all');
      final plan = _makePlan(templateId: 'plan-all');
      await db.installmentPlanDao.insertPlan(plan);

      final plans = await db.installmentPlanDao.watchAll().first;
      expect(plans.length, 1);
      expect(plans.first.templateId, 'plan-all');
    });

    test('2. watchById() emits null before insert; emits plan after', () async {
      // Before insert: should emit null.
      final before = await db.installmentPlanDao.watchById('plan-watch').first;
      expect(before, isNull);

      await _insertParentTemplate(db, 'plan-watch');
      final plan = _makePlan(templateId: 'plan-watch');
      await db.installmentPlanDao.insertPlan(plan);

      final after = await db.installmentPlanDao.watchById('plan-watch').first;
      expect(after, isNotNull);
      expect(after!.templateId, 'plan-watch');
    });

    test('3. insertPlan() persists and returns plan', () async {
      await _insertParentTemplate(db, 'plan-insert');
      final plan = _makePlan(
        templateId: 'plan-insert',
        totalMinor: 500000,
        count: 5,
      );
      final returned = await db.installmentPlanDao.insertPlan(plan);
      expect(returned.templateId, 'plan-insert');
      expect(returned.totalConfiguredMinor, 500000);
      expect(returned.numberOfInstallments, 5);

      final fromDb = await db.installmentPlanDao.watchById('plan-insert').first;
      expect(fromDb, isNotNull);
      expect(fromDb!.totalConfiguredMinor, 500000);
    });

    test('4. updatePlan() persists changed fields', () async {
      await _insertParentTemplate(db, 'plan-update');
      final plan = _makePlan(templateId: 'plan-update', count: 3);
      await db.installmentPlanDao.insertPlan(plan);

      final updated = plan.copyWith(numberOfInstallments: 6);
      await db.installmentPlanDao.updatePlan(updated);

      final fromDb = await db.installmentPlanDao.watchById('plan-update').first;
      expect(fromDb!.numberOfInstallments, 6);
    });

    test('5. deletePlan() removes the row', () async {
      await _insertParentTemplate(db, 'plan-delete');
      final plan = _makePlan(templateId: 'plan-delete');
      await db.installmentPlanDao.insertPlan(plan);

      await db.installmentPlanDao.deletePlan('plan-delete');

      final fromDb = await db.installmentPlanDao.watchById('plan-delete').first;
      expect(fromDb, isNull);
    });
  });

  // =========================================================================
  // InstallmentOccurrenceDao (tests 6–11)
  // =========================================================================

  group('InstallmentOccurrenceDao', () {
    const templateId = 'occ-template';

    setUp(() async {
      // Insert the parent recurring_template once per test via shared setUp.
      await _insertParentTemplate(db, templateId);
    });

    test('6. watchByPlan() emits occurrences ordered by sequence_number',
        () async {
      // Insert out-of-order to verify ORDER BY is applied.
      final occs = [
        _makeOcc(id: 'occ-3', templateId: templateId, seq: 3),
        _makeOcc(id: 'occ-1', templateId: templateId, seq: 1),
        _makeOcc(id: 'occ-2', templateId: templateId, seq: 2),
      ];
      await db.installmentOccurrenceDao.insertOccurrences(occs);

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(result.length, 3);
      expect(result[0].sequenceNumber, 1);
      expect(result[1].sequenceNumber, 2);
      expect(result[2].sequenceNumber, 3);
    });

    test('7. insertOccurrences() bulk-inserts correctly', () async {
      final occs = List.generate(
        5,
        (i) =>
            _makeOcc(id: 'bulk-${i + 1}', templateId: templateId, seq: i + 1),
      );
      await db.installmentOccurrenceDao.insertOccurrences(occs);

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(result.length, 5);
    });

    test('8. updateOccurrence() persists changed fields', () async {
      final occ = _makeOcc(id: 'upd-occ', templateId: templateId, seq: 1);
      await db.installmentOccurrenceDao.insertOccurrences([occ]);

      final updated = occ.copyWith(amountMinor: 200000);
      await db.installmentOccurrenceDao.updateOccurrence(updated);

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(result.first.amountMinor, 200000);
    });

    test('9. deleteOccurrence() removes the row', () async {
      final occ = _makeOcc(id: 'del-occ', templateId: templateId, seq: 1);
      await db.installmentOccurrenceDao.insertOccurrences([occ]);

      await db.installmentOccurrenceDao.deleteOccurrence('del-occ');

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(result, isEmpty);
    });

    test('10. markPosted() sets status=posted and childTransactionId',
        () async {
      final occ = _makeOcc(id: 'post-occ', templateId: templateId, seq: 1);
      await db.installmentOccurrenceDao.insertOccurrences([occ]);

      // Disable FK temporarily for the child_transaction_id FK — in tests
      // we don't have a real transactions row. The FK on child_transaction_id
      // is nullable; when we set it via markPosted, it must reference an
      // existing transaction. We insert a minimal transactions row first.
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Temporarily disable FK enforcement so we can insert a transaction row
      // referencing a currency without inserting the currency first.
      // Re-enabled after the insert to maintain test isolation.
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await db.customStatement(
        '''
        INSERT INTO transactions (
          id, type, status, purpose,
          transaction_date, amount_minor, currency_code,
          created_at, updated_at
        ) VALUES (
          'tx-123', 'expense', 'posted', 'manual',
          ?, 100000, 'INR',
          ?, ?
        )
      ''',
        [nowEpoch, nowEpoch, nowEpoch],
      );
      await db.customStatement('PRAGMA foreign_keys = ON');

      await db.installmentOccurrenceDao.markPosted('post-occ', 'tx-123');

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(
        result.first.status,
        domain.InstallmentOccurrenceStatus.posted,
      );
      expect(result.first.childTransactionId, 'tx-123');
    });

    test('11. cancelPendingOccurrences() cancels only pending rows', () async {
      final occs = [
        _makeOcc(id: 'pend-1', templateId: templateId, seq: 1),
        _makeOcc(id: 'pend-2', templateId: templateId, seq: 2),
        _makeOcc(
          id: 'posted-1',
          templateId: templateId,
          seq: 3,
          status: domain.InstallmentOccurrenceStatus.posted,
        ),
      ];
      await db.installmentOccurrenceDao.insertOccurrences(occs);

      await db.installmentOccurrenceDao.cancelPendingOccurrences(templateId);

      final result =
          await db.installmentOccurrenceDao.watchByPlan(templateId).first;
      expect(
        result.where(
          (o) => o.status == domain.InstallmentOccurrenceStatus.cancelled,
        ),
        hasLength(2),
      );
      expect(
        result.where(
          (o) => o.status == domain.InstallmentOccurrenceStatus.posted,
        ),
        hasLength(1),
      );
    });
  });

  // =========================================================================
  // T-125 migration: installment_occurrences indexes (test 12)
  // =========================================================================

  group('T-125: installment_occurrences index DDL', () {
    test('12. CREATE UNIQUE INDEX IF NOT EXISTS runs without error', () async {
      // Verify the exact DDL used in the v3 migration runs correctly.
      await expectLater(
        db.customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS idx_inst_occ_template_seq_t
          ON installment_occurrences (template_id, sequence_number)
        '''),
        completes,
      );
      await expectLater(
        db.customStatement('''
          CREATE INDEX IF NOT EXISTS idx_inst_occ_status_date_t
          ON installment_occurrences (status, scheduled_date)
        '''),
        completes,
      );
    });
  });
}
