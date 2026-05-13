// lib/data/database/app_database.dart
//
// Central Drift database class for Variance.
//
// Responsibilities:
//   - Encryption key generation and retrieval via flutter_secure_storage
//   - SQLCipher database open via sqlite3mc hook (AES-256, WAL mode)
//   - PRAGMA application on every connection (SDS §2.3.2)
//   - Version-guard: throws SchemaMismatchException if on-disk version >
//     compiled version
//   - Registers all 19 tables (18 regular + 1 FTS virtual)
//   - Exposes all 7 DAOs
//
// Database file: getApplicationDocumentsDirectory()/variance.db
// Encryption key: 32 random bytes stored in flutter_secure_storage under
//   the key 'db_encryption_key'. Retrieved on every open; generated on
//   first open.
//
// Test cases (see test/data/database/schema_verifier_test.dart):
//   - in-memory AppDatabase opens without error
//   - all 18 tables present in sqlite_master
//   - FTS5 virtual table present in sqlite_master
//   - foreign_keys PRAGMA is ON after open

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:variance/data/database/daos/account_dao.dart';
import 'package:variance/data/database/daos/app_settings_dao.dart';
import 'package:variance/data/database/daos/category_dao.dart';
import 'package:variance/data/database/daos/currency_dao.dart';
import 'package:variance/data/database/daos/exchange_rate_dao.dart';
import 'package:variance/data/database/daos/scheduled_occurrence_dao.dart';
import 'package:variance/data/database/daos/template_dao.dart';
import 'package:variance/data/database/daos/transaction_dao.dart';
import 'package:variance/data/database/migrations/migrations.dart';
import 'package:variance/data/database/tables/account_details_table.dart';
import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/app_settings_table.dart';
import 'package:variance/data/database/tables/attachments_table.dart';
import 'package:variance/data/database/tables/budgets_table.dart';
import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/currencies_table.dart';
import 'package:variance/data/database/tables/drafts_table.dart';
import 'package:variance/data/database/tables/entries_table.dart';
import 'package:variance/data/database/tables/exchange_rates_table.dart';
import 'package:variance/data/database/tables/installment_plans_table.dart';
import 'package:variance/data/database/tables/payees_table.dart';
import 'package:variance/data/database/tables/recurring_templates_table.dart';
import 'package:variance/data/database/tables/scheduled_occurrences_table.dart';
import 'package:variance/data/database/tables/tags_table.dart';
import 'package:variance/data/database/tables/transaction_tags_table.dart';
import 'package:variance/data/database/tables/transactions_table.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Encryption key storage key
// ---------------------------------------------------------------------------

/// flutter_secure_storage key under which the 32-byte AES-256 encryption key
/// is stored (base64-encoded).
const _kEncryptionKeyStorageKey = 'db_encryption_key';

/// Number of random bytes to generate for the SQLCipher encryption key.
///
/// 32 bytes = 256 bits, matching the AES-256 requirement from SDS §2.3.1.
const _kEncryptionKeyBytes = 32;

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

/// The central Drift database for Variance.
///
/// All 18 data tables plus the FTS5 virtual table are registered here.
/// The database file is AES-256 encrypted via the sqlite3mc hook
/// (pubspec `hooks.user_defines.sqlite3.source = sqlite3mc`). The
/// encryption key is generated on first open and stored in the Android
/// Keystore via [FlutterSecureStorage].
///
/// Use [AppDatabase.open] to create the production singleton.
/// Use [AppDatabase.forTesting] to create an in-memory instance in tests.
@DriftDatabase(
  tables: [
    // Core
    Accounts,
    AccountDetails,
    Transactions,
    Entries,
    Categories,
    Tags,
    TransactionTags,
    Payees,
    // Currency & rates
    Currencies,
    ExchangeRates,
    // Attachments
    Attachments,
    // Budgets
    Budgets,
    BudgetPeriods,
    // Recurring & scheduled
    RecurringTemplates,
    ScheduledOccurrences,
    // Installments
    InstallmentPlans,
    InstallmentOccurrences,
    // App config
    AppSettings,
    Drafts,
  ],
  daos: [
    TransactionDao,
    AccountDao,
    CategoryDao,
    TemplateDao,
    ExchangeRateDao,
    CurrencyDao,
    AppSettingsDao,
    ScheduledOccurrenceDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] with the given [QueryExecutor].
  ///
  /// Prefer [AppDatabase.open] for production use and
  /// [AppDatabase.forTesting] for unit/integration tests.
  AppDatabase(super.e);

  // -----------------------------------------------------------------------
  // Schema version
  // -----------------------------------------------------------------------

  /// Current compiled schema version.
  ///
  /// Increment this when the schema changes and add a corresponding
  /// migration step in [buildMigrationStrategy].
  ///
  /// v1 — initial schema.
  /// v2 — add large_txn_threshold_minor to accounts and categories tables
  ///       (T-181, T-182, TC-047).
  @override
  int get schemaVersion => 2;

  // -----------------------------------------------------------------------
  // Migration strategy
  // -----------------------------------------------------------------------

  @override
  MigrationStrategy get migration =>
      buildMigrationStrategy(this, schemaVersion);

  // -----------------------------------------------------------------------
  // Factory constructors
  // -----------------------------------------------------------------------

  /// Opens the production database at
  /// `getApplicationDocumentsDirectory()/variance.db` with AES-256
  /// encryption.
  ///
  /// The encryption key is retrieved from or stored to [FlutterSecureStorage]
  /// on each call. The key is generated once (32 random bytes) and persisted.
  ///
  /// Parameters:
  /// - [secureStorage]: The secure storage instance to use for key management.
  static Future<AppDatabase> open(FlutterSecureStorage secureStorage) async {
    final key = await _resolveEncryptionKey(secureStorage);
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docDir.path, 'variance.db');

    dev.log('AppDatabase.open: path=$dbPath', name: 'AppDatabase');

    final executor = NativeDatabase.createInBackground(
      File(dbPath),
      setup: (db) => _applyEncryption(db, key),
    );

    return AppDatabase(executor);
  }

  /// Creates an in-memory database suitable for unit and widget tests.
  ///
  /// No encryption is applied in this mode. PRAGMAs are still applied via
  /// the [MigrationStrategy.beforeOpen] callback.
  factory AppDatabase.forTesting() {
    return AppDatabase(NativeDatabase.memory());
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Retrieves the encryption key from [secureStorage], generating and
  /// storing a new 32-byte random key if none exists.
  ///
  /// Returns the raw key bytes.
  static Future<List<int>> _resolveEncryptionKey(
    FlutterSecureStorage secureStorage,
  ) async {
    final existing = await secureStorage.read(
      key: _kEncryptionKeyStorageKey,
      aOptions: _androidOptions,
    );

    if (existing != null) {
      return base64.decode(existing);
    }

    // Generate a new 32-byte random key.
    final random = Random.secure();
    final keyBytes = List<int>.generate(
      _kEncryptionKeyBytes,
      (_) => random.nextInt(256),
    );

    await secureStorage.write(
      key: _kEncryptionKeyStorageKey,
      value: base64.encode(keyBytes),
      aOptions: _androidOptions,
    );

    dev.log('AppDatabase: generated new encryption key', name: 'AppDatabase');
    return keyBytes;
  }

  /// Applies the SQLCipher/sqlite3mc encryption key to [db].
  ///
  /// Called once inside [NativeDatabase.createInBackground]'s setup callback.
  /// The `PRAGMA key` must be the first statement executed on the connection.
  static void _applyEncryption(Database db, List<int> keyBytes) {
    // SQLCipher/sqlite3mc expects the key as a hex string prefixed with 'x'.
    final hexKey =
        keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    db.execute("PRAGMA key = \"x'$hexKey'\"");
  }

  /// Android-specific secure storage options.
  ///
  /// Forces the Android Keystore backend (EncryptedSharedPreferences) so the
  /// key material is hardware-backed on supported devices.
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
}
