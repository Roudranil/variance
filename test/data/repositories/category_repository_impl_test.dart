// test/data/repositories/category_repository_impl_test.dart
//
// Integration tests for CategoryRepositoryImpl against an in-memory Drift DB.
//
// Test cases:
//   1. watchAll — emits non-deleted categories after insert
//   2. create — inserted category appears in watchAll stream
//   3. update — changed name reflected in watchAll stream
//   4. update — missing row returns Err(NotFoundFailure)
//   5. softDelete — category disappears from watchAll stream
//   6. softDelete leaf — returns Ok(null)
//   7. softDelete parent with children — returns Err(BusinessRuleFailure)
//   8. existsNameInScope — true for active root category
//   9. existsNameInScope — excludeId skips own row
//  10. findById — returns domain entity or null

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/data/repositories/category_repository_impl.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/category.dart' as domain;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CategoryDao dao;
  late CategoryRepositoryImpl repo;

  const kNow = 1735689600;

  domain.Category makeCategory({
    String id = 'cat-1',
    String? parentId,
    domain.CategoryTreeType treeType = domain.CategoryTreeType.expense,
    String name = 'Food',
    String iconRef = 'category',
    bool isDeleted = false,
    bool isProtected = false,
  }) {
    return domain.Category(
      id: id,
      parentId: parentId,
      treeType: treeType,
      name: name,
      iconRef: iconRef,
      isDeleted: isDeleted,
      isProtected: isProtected,
      createdAt: kNow,
      updatedAt: kNow,
    );
  }

  setUp(() {
    db = AppDatabase.forTesting();
    dao = db.categoryDao;
    repo = CategoryRepositoryImpl(dao);
  });

  tearDown(() => db.close());

  group('watchAll', () {
    test('1. emits non-deleted categories after insert', () async {
      await repo.create(makeCategory(id: 'cat-1', name: 'Food'));
      final list = await repo.watchAll().first;
      expect(list.map((c) => c.id), contains('cat-1'));
    });
  });

  group('create', () {
    test('2. inserted category appears in watchAll stream', () async {
      final result =
          await repo.create(makeCategory(id: 'cat-new', name: 'Transport'));
      expect(result, isA<Ok<domain.Category>>());
      final list = await repo.watchAll().first;
      expect(list.any((c) => c.id == 'cat-new'), isTrue);
    });
  });

  group('update', () {
    test('3. changed name reflected in watchAll stream', () async {
      await repo.create(makeCategory(id: 'cat-1', name: 'Food'));
      final updated = makeCategory(id: 'cat-1', name: 'Groceries');
      final result = await repo.update(updated);
      expect(result, isA<Ok<domain.Category>>());
      final list = await repo.watchAll().first;
      final row = list.firstWhere((c) => c.id == 'cat-1');
      expect(row.name, equals('Groceries'));
    });

    test('4. missing row returns Err(NotFoundFailure)', () async {
      final result = await repo.update(makeCategory(id: 'missing'));
      expect(result, isA<Err<domain.Category>>());
      final failure = (result as Err).failure;
      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('softDelete', () {
    test('5. deleted category disappears from watchAll stream', () async {
      await repo.create(makeCategory(id: 'cat-1', name: 'Food'));
      await repo.softDelete('cat-1');
      final list = await repo.watchAll().first;
      expect(list.map((c) => c.id), isNot(contains('cat-1')));
    });

    test('6. softDelete leaf returns Ok(null)', () async {
      await repo.create(makeCategory(id: 'cat-1', name: 'Food'));
      final result = await repo.softDelete('cat-1');
      expect(result, isA<Ok<void>>());
    });

    test('7. softDelete parent with children returns Err(BusinessRuleFailure)',
        () async {
      await repo.create(makeCategory(id: 'parent', name: 'Food'));
      await repo.create(
        makeCategory(id: 'child', parentId: 'parent', name: 'Lunch'),
      );
      final result = await repo.softDelete('parent');
      expect(result, isA<Err<void>>());
      final failure = (result as Err).failure;
      expect(failure, isA<BusinessRuleFailure>());
    });
  });

  group('existsNameInScope', () {
    // Use a name not present in the seed data to avoid false positives
    // from the default category taxonomy seeded on onCreate.
    const kUniqueName = 'TestUniqueCatRepoXYZ';

    test('8. true for active root category', () async {
      await repo.create(makeCategory(id: 'c1', name: kUniqueName));
      final exists = await repo.existsNameInScope(
        kUniqueName,
        domain.CategoryTreeType.expense,
        null,
      );
      expect(exists, isTrue);
    });

    test('9. excludeId skips own row', () async {
      await repo.create(makeCategory(id: 'c1', name: kUniqueName));
      final exists = await repo.existsNameInScope(
        kUniqueName,
        domain.CategoryTreeType.expense,
        null,
        excludeId: 'c1',
      );
      expect(exists, isFalse);
    });
  });

  group('findById', () {
    test('10. returns domain entity for existing id', () async {
      await repo.create(makeCategory(id: 'c1', name: 'Food'));
      final entity = await repo.findById('c1');
      expect(entity, isNotNull);
      expect(entity!.id, equals('c1'));
    });

    test('10b. returns null for non-existent id', () async {
      final entity = await repo.findById('missing');
      expect(entity, isNull);
    });
  });
}
