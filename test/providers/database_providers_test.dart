// test/providers/database_providers_test.dart
//
// Integration test for the Riverpod provider graph starting at AppDatabase.
//
// Test cases:
//   - appDatabaseProvider resolves when overridden with in-memory AppDatabase
//   - transactionDaoProvider resolves to a TransactionDao instance
//   - accountDaoProvider resolves to an AccountDao instance
//   - categoryDaoProvider resolves to a CategoryDao instance
//   - templateDaoProvider resolves to a TemplateDao instance
//   - exchangeRateDaoProvider resolves to an ExchangeRateDao instance
//   - currencyDaoProvider resolves to a CurrencyDao instance
//   - transactionRepositoryProvider resolves to an ITransactionRepository instance
//   - accountRepositoryProvider resolves to an IAccountRepository instance
//   - categoryRepositoryProvider resolves to an ICategoryRepository instance
//
// All tests use ProviderContainer with an in-memory AppDatabase override to
// avoid touching the file system or FlutterSecureStorage.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/data/database/daos/template_dao.dart';
import 'package:variance/data/database/daos/transaction_dao.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/presentation/providers/database_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

/// Helper that creates a [ProviderContainer] with [appDatabaseProvider]
/// overridden to an in-memory [AppDatabase].
///
/// The container is closed after each test via [addTearDown].
ProviderContainer _makeContainer() {
  final inMemoryDb = AppDatabase.forTesting();

  final container = ProviderContainer(
    overrides: [
      // Override appDatabaseProvider so no file system or secure storage is touched.
      appDatabaseProvider.overrideWith((_) async => inMemoryDb),
    ],
  );

  addTearDown(() async {
    container.dispose();
    await inMemoryDb.close();
  });

  return container;
}

void main() {
  // Initialise the Flutter test binding so rootBundle is available for the
  // currency seeding step executed inside AppDatabase.onCreate (T-22).
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase provider', () {
    test('appDatabaseProvider resolves to AppDatabase', () async {
      final container = _makeContainer();

      final db = await container.read(appDatabaseProvider.future);
      expect(db, isA<AppDatabase>());
    });
  });

  group('DAO providers', () {
    test('transactionDaoProvider resolves to TransactionDao', () async {
      final container = _makeContainer();

      final dao = await container.read(transactionDaoProvider.future);
      expect(dao, isA<TransactionDao>());
    });

    test('accountDaoProvider resolves to AccountDao', () async {
      final container = _makeContainer();

      final dao = await container.read(accountDaoProvider.future);
      expect(dao, isA<AccountDao>());
    });

    test('categoryDaoProvider resolves to CategoryDao', () async {
      final container = _makeContainer();

      final dao = await container.read(categoryDaoProvider.future);
      expect(dao, isA<CategoryDao>());
    });

    test('templateDaoProvider resolves to TemplateDao', () async {
      final container = _makeContainer();

      final dao = await container.read(templateDaoProvider.future);
      expect(dao, isA<TemplateDao>());
    });

    test('exchangeRateDaoProvider resolves to ExchangeRateDao', () async {
      final container = _makeContainer();

      final dao = await container.read(exchangeRateDaoProvider.future);
      expect(dao, isA<ExchangeRateDao>());
    });

    test('currencyDaoProvider resolves to CurrencyDao', () async {
      final container = _makeContainer();

      final dao = await container.read(currencyDaoProvider.future);
      expect(dao, isA<CurrencyDao>());
    });
  });

  group('Repository providers', () {
    test('transactionRepositoryProvider resolves to ITransactionRepository',
        () async {
      final container = _makeContainer();

      final repo = await container.read(transactionRepositoryProvider.future);
      expect(repo, isA<ITransactionRepository>());
    });

    test('accountRepositoryProvider resolves to IAccountRepository', () async {
      final container = _makeContainer();

      final repo = await container.read(accountRepositoryProvider.future);
      expect(repo, isA<IAccountRepository>());
    });

    test('categoryRepositoryProvider resolves to ICategoryRepository',
        () async {
      final container = _makeContainer();

      final repo = await container.read(categoryRepositoryProvider.future);
      expect(repo, isA<ICategoryRepository>());
    });
  });
}
