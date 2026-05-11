// test/data/models/category_dto_test.dart
//
// Unit tests for CategoryDto mapping between Drift row and domain entity.
//
// Test cases:
//   1. fromRow + toEntity round-trips all fields without data loss
//   2. tree_type 'income' maps to CategoryTreeType.income
//   3. tree_type 'expense' maps to CategoryTreeType.expense
//   4. unknown tree_type falls back to CategoryTreeType.expense
//   5. treeTypeToString(income) returns 'income'
//   6. treeTypeToString(expense) returns 'expense'

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/data/database/app_database.dart' show Category;
import 'package:variance/data/models/category_dto.dart';
import 'package:variance/domain/entities/category.dart' as domain;

void main() {
  const kNow = 1735689600;

  // Helper to build a minimal Drift Category row for testing.
  Category makeRow({
    String id = 'cat-1',
    String? parentId,
    String treeType = 'expense',
    String name = 'Food',
    String iconRef = 'restaurant',
    bool isDeleted = false,
    int? deletedAt,
    bool isProtected = false,
    int? sortOrder,
    int createdAt = kNow,
    int updatedAt = kNow,
  }) {
    return Category(
      id: id,
      parentId: parentId,
      treeType: treeType,
      name: name,
      iconRef: iconRef,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      isProtected: isProtected,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  group('CategoryDto', () {
    test('1. fromRow + toEntity round-trips all fields', () {
      final row = makeRow(
        id: 'cat-abc',
        parentId: 'cat-parent',
        treeType: 'income',
        name: 'Salary',
        iconRef: 'money',
        isDeleted: false,
        deletedAt: null,
        isProtected: true,
        sortOrder: 3,
        createdAt: kNow,
        updatedAt: kNow + 60,
      );

      final entity = CategoryDto.fromRow(row).toEntity();

      expect(entity.id, equals('cat-abc'));
      expect(entity.parentId, equals('cat-parent'));
      expect(entity.treeType, equals(domain.CategoryTreeType.income));
      expect(entity.name, equals('Salary'));
      expect(entity.iconRef, equals('money'));
      expect(entity.isDeleted, isFalse);
      expect(entity.deletedAt, isNull);
      expect(entity.isProtected, isTrue);
      expect(entity.sortOrder, equals(3));
      expect(entity.createdAt, equals(kNow));
      expect(entity.updatedAt, equals(kNow + 60));
    });

    test('2. tree_type "income" maps to CategoryTreeType.income', () {
      final row = makeRow(treeType: 'income');
      final entity = CategoryDto.fromRow(row).toEntity();
      expect(entity.treeType, equals(domain.CategoryTreeType.income));
    });

    test('3. tree_type "expense" maps to CategoryTreeType.expense', () {
      final row = makeRow(treeType: 'expense');
      final entity = CategoryDto.fromRow(row).toEntity();
      expect(entity.treeType, equals(domain.CategoryTreeType.expense));
    });

    test('4. unknown tree_type falls back to CategoryTreeType.expense', () {
      final row = makeRow(treeType: 'unknown_value');
      final entity = CategoryDto.fromRow(row).toEntity();
      expect(entity.treeType, equals(domain.CategoryTreeType.expense));
    });

    test('5. treeTypeToString(income) returns "income"', () {
      expect(
        CategoryDto.treeTypeToString(domain.CategoryTreeType.income),
        equals('income'),
      );
    });

    test('6. treeTypeToString(expense) returns "expense"', () {
      expect(
        CategoryDto.treeTypeToString(domain.CategoryTreeType.expense),
        equals('expense'),
      );
    });
  });
}
