// test/data/database/category_seed_test.dart
//
// Integration tests for the default category seeding migration (T-77).
//
// Test cases:
//   1. Income parent categories are present after onCreate
//   2. Expense parent categories are present after onCreate
//   3. Income subcategories are present
//   4. Expense subcategories (sample) are present
//   5. Protected rows have is_protected = true
//   6. Non-protected rows have is_protected = false
//   7. Running seed twice produces no duplicate rows (idempotency)
//   8. Income Balance Adjustment parent has icon_ref = 'balance'
//   9. Expense Balance Adjustment parent has icon_ref = 'balance'
//  10. BAI child has is_protected = true
//  11. BAE child has is_protected = true
//  12. Fees & Charges child has is_protected = true

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/migrations/seed_default_categories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    // forTesting() triggers onCreate → currencies + categories are seeded.
    db = AppDatabase.forTesting();
  });

  tearDown(() => db.close());

  // Helper: fetch all categories as a flat list.
  Future<List<Map<String, dynamic>>> allRows() async {
    final result = await db
        .customSelect(
          'SELECT id, tree_type, name, icon_ref, is_protected, parent_id '
          'FROM categories',
        )
        .get();
    return result
        .map(
          (row) => {
            'id': row.read<String>('id'),
            'tree_type': row.read<String>('tree_type'),
            'name': row.read<String>('name'),
            'icon_ref': row.read<String>('icon_ref'),
            'is_protected': row.read<int>('is_protected'),
            'parent_id': row.readNullable<String>('parent_id'),
          },
        )
        .toList();
  }

  group('Default category seeding', () {
    test('1. Income parent categories are present after onCreate', () async {
      final rows = await allRows();
      final incomeParents = rows
          .where((r) => r['tree_type'] == 'income' && r['parent_id'] == null)
          .map((r) => r['name'] as String)
          .toSet();

      expect(incomeParents,
          containsAll(['Standard', 'Gift', 'Repayment', 'Other']));
      expect(incomeParents, contains('Balance Adjustment'));
    });

    test('2. Expense parent categories are present after onCreate', () async {
      final rows = await allRows();
      final expenseParents = rows
          .where((r) => r['tree_type'] == 'expense' && r['parent_id'] == null)
          .map((r) => r['name'] as String)
          .toSet();

      expect(
        expenseParents,
        containsAll([
          'Food',
          'Transportation',
          'Household',
          'Travels',
          'Apparel',
          'Health',
          'Self',
          'Social',
          'Stationery',
          'Culture',
          'Financial',
          'Education',
          'Loan',
          'Friends & Family',
          'Other',
          'Balance Adjustment',
        ]),
      );
    });

    test('3. Income subcategories are present', () async {
      final rows = await allRows();
      final incomeChildren = rows
          .where((r) => r['tree_type'] == 'income' && r['parent_id'] != null)
          .map((r) => r['name'] as String)
          .toSet();

      expect(
        incomeChildren,
        containsAll([
          'Salary',
          'Bonus',
          'Allowance',
          'Reimbursement',
          'Scholarship',
          'EPF',
          'Pension',
          'Loans',
          'Splitwise',
          'Refund',
          'BAI',
        ]),
      );
    });

    test('4. Expense subcategories (sample) are present', () async {
      final rows = await allRows();
      final expenseChildren = rows
          .where((r) => r['tree_type'] == 'expense' && r['parent_id'] != null)
          .map((r) => r['name'] as String)
          .toSet();

      // Sample from several expense groups to verify (no income-only names).
      expect(
        expenseChildren,
        containsAll([
          'Lunch',
          'Groceries',
          'Fuel',
          'Rent',
          'Gym',
          'Textbooks',
          'BAE',
          'Fees & Charges',
        ]),
      );
    });

    test('5. Protected rows have is_protected = 1', () async {
      final rows = await allRows();
      final protected = rows.where((r) => r['is_protected'] == 1).toList();
      // BAI parent, BAI child, BAE parent, BAE child, Fees & Charges
      expect(protected.length, greaterThanOrEqualTo(5));
      final names = protected.map((r) => r['name'] as String).toSet();
      expect(
        names,
        containsAll(['Balance Adjustment', 'BAI', 'BAE', 'Fees & Charges']),
      );
    });

    test('6. Non-protected rows have is_protected = 0', () async {
      final rows = await allRows();
      // "Food" should never be protected.
      final foodRow = rows.firstWhere((r) => r['name'] == 'Food');
      expect(foodRow['is_protected'], equals(0));
    });

    test('7. Running seed twice produces no duplicate rows (idempotency)',
        () async {
      // Seed a second time.
      await seedDefaultCategories(db);
      final rows = await allRows();
      // No duplicate names at the same (tree_type, parent_id) scope.
      // A naive check: total row count should not change.
      await seedDefaultCategories(db);
      final rowsAfterThird = await allRows();
      expect(rowsAfterThird.length, equals(rows.length));
    });

    test('8. Income Balance Adjustment parent has icon_ref = "balance"',
        () async {
      final rows = await allRows();
      final incBa = rows.firstWhere(
        (r) =>
            r['name'] == 'Balance Adjustment' &&
            r['tree_type'] == 'income' &&
            r['parent_id'] == null,
      );
      expect(incBa['icon_ref'], equals('balance'));
    });

    test('9. Expense Balance Adjustment parent has icon_ref = "balance"',
        () async {
      final rows = await allRows();
      final expBa = rows.firstWhere(
        (r) =>
            r['name'] == 'Balance Adjustment' &&
            r['tree_type'] == 'expense' &&
            r['parent_id'] == null,
      );
      expect(expBa['icon_ref'], equals('balance'));
    });

    test('10. BAI child has is_protected = 1', () async {
      final rows = await allRows();
      final bai = rows.firstWhere(
        (r) => r['name'] == 'BAI' && r['tree_type'] == 'income',
      );
      expect(bai['is_protected'], equals(1));
    });

    test('11. BAE child has is_protected = 1', () async {
      final rows = await allRows();
      final bae = rows.firstWhere(
        (r) => r['name'] == 'BAE' && r['tree_type'] == 'expense',
      );
      expect(bae['is_protected'], equals(1));
    });

    test('12. Fees & Charges child has is_protected = 1', () async {
      final rows = await allRows();
      final feesCharges = rows.firstWhere(
        (r) => r['name'] == 'Fees & Charges',
      );
      expect(feesCharges['is_protected'], equals(1));
    });
  });
}
