// lib/presentation/providers/database_providers.dart
//
// Riverpod providers for the AppDatabase singleton and all DAO accessors.
//
// Provider tree (all keepAlive — constructed once, never disposed):
//   appDatabaseProvider
//     ├── transactionDaoProvider
//     ├── accountDaoProvider
//     ├── categoryDaoProvider
//     ├── templateDaoProvider
//     ├── installmentPlanDaoProvider
//     ├── installmentOccurrenceDaoProvider
//     ├── scheduledOccurrenceDaoProvider
//     ├── exchangeRateDaoProvider
//     ├── currencyDaoProvider
//     ├── appSettingsDaoProvider
//     └── searchDaoProvider
//
// Production: appDatabaseProvider calls AppDatabase.open() and stores the
// encryption key in FlutterSecureStorage (Android Keystore backed).
// Tests: override appDatabaseProvider with AppDatabase.forTesting().
//
// Rules (SDS §2.2.1, §2.2.4):
//   - All providers use @riverpod annotation; raw Provider(...) is forbidden.
//   - keepAlive: true — database and DAOs must never be auto-disposed.
//
// Test cases (see test/providers/database_providers_test.dart):
//   - Override appDatabaseProvider with in-memory DB and resolve each DAO
//     provider without error.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/data/database/daos/app_settings_dao.dart';
import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/data/database/daos/installment_dao.dart';
import 'package:variance/data/database/daos/scheduled_occurrence_dao.dart';
import 'package:variance/data/database/daos/search_dao.dart';
import 'package:variance/data/database/daos/template_dao.dart';
import 'package:variance/data/database/daos/transaction_dao.dart';

part 'database_providers.g.dart';

// ---------------------------------------------------------------------------
// Database singleton
// ---------------------------------------------------------------------------

/// The production [AppDatabase] singleton.
///
/// Opens the encrypted SQLite database on first access and keeps it alive for
/// the lifetime of the app (keepAlive: true).
///
/// Override in tests with [AppDatabase.forTesting]:
/// ```dart
/// ProviderScope(
///   overrides: [appDatabaseProvider.overrideWith((_) => AppDatabase.forTesting())],
///   ...
/// )
/// ```
@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  const storage = FlutterSecureStorage();
  return AppDatabase.open(storage);
}

// ---------------------------------------------------------------------------
// DAO providers — each reads from appDatabaseProvider
// ---------------------------------------------------------------------------

/// Provides the [TransactionDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<TransactionDao> transactionDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.transactionDao;
}

/// Provides the [AccountDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<AccountDao> accountDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.accountDao;
}

/// Provides the [CategoryDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<CategoryDao> categoryDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.categoryDao;
}

/// Provides the [TemplateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<TemplateDao> templateDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.templateDao;
}

/// Provides the [ExchangeRateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<ExchangeRateDao> exchangeRateDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.exchangeRateDao;
}

/// Provides the [CurrencyDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<CurrencyDao> currencyDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.currencyDao;
}

/// Provides the [AppSettingsDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<AppSettingsDao> appSettingsDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.appSettingsDao;
}

/// Provides the [InstallmentPlanDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<InstallmentPlanDao> installmentPlanDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.installmentPlanDao;
}

/// Provides the [InstallmentOccurrenceDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<InstallmentOccurrenceDao> installmentOccurrenceDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.installmentOccurrenceDao;
}

/// Provides the [ScheduledOccurrenceDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<ScheduledOccurrenceDao> scheduledOccurrenceDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scheduledOccurrenceDao;
}

/// Provides the [SearchDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<SearchDao> searchDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.searchDao;
}
