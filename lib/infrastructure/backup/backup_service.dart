// lib/infrastructure/backup/backup_service.dart
//
// BackupService — export all non-deleted app data to a versioned ZIP archive.
//
// ZIP structure (SDS §2.17, TC-054):
//   variance_backup_YYYYMMDD_HHmmss.zip
//     ├── manifest.json        — format version, app version, timestamp, schema
//     ├── variance_export.json — all non-deleted entities (JSON array per table)
//     └── attachments/         — referenced photo files (missing files skipped)
//
// This service is designed to be called from the UI layer via
// [BackupNotifier]; it runs the DB snapshot inside a Drift transaction to
// guarantee a consistent read (SDS §2.17.1 mid-write consistency constraint).
//
// After a successful export, the caller is responsible for writing
// `last_backup_at` to app_settings via [AppSettingsNotifier.save].
//
// Test cases (see test/infrastructure/backup/backup_service_test.dart):
//   T-188.1 manifest JSON contains correct fields and values
//   T-188.2 soft-deleted entities are absent from variance_export.json
//   T-188.3 missing photo file is skipped without exception
//   T-188.4 last_backup_at is written on successful export (integration)

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:variance/data/database/app_database.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// Result of a backup export attempt.
sealed class BackupResult {}

/// Backup completed successfully.
///
/// [filePath] is the absolute path to the written ZIP archive.
final class BackupSuccess extends BackupResult {
  /// Creates a [BackupSuccess] with the written [filePath].
  BackupSuccess(this.filePath);

  /// Absolute path to the written ZIP archive.
  final String filePath;
}

/// Backup failed.
///
/// [message] describes the error for display or logging.
final class BackupFailure extends BackupResult {
  /// Creates a [BackupFailure] with an error [message].
  BackupFailure(this.message);

  /// Human-readable failure description.
  final String message;
}

// ---------------------------------------------------------------------------
// BackupService
// ---------------------------------------------------------------------------

/// Exports all non-deleted app data to a versioned ZIP archive.
///
/// Reads all data inside a Drift read-only transaction for snapshot consistency
/// (SDS §2.17.1). The ZIP is written to [destinationDir] if provided, or falls
/// back to the platform Downloads directory.
///
/// The caller must write `last_backup_at` to [AppSettingsNotifier] after a
/// [BackupSuccess] result is received — this service does not write settings.
class BackupService {
  /// Creates a [BackupService] backed by [database].
  ///
  /// Parameters:
  /// - [database]: The Drift database; used for all read queries.
  /// - [appVersionResolver]: Optional async function that returns the app
  ///   version string. Defaults to reading from [PackageInfo]. Override in
  ///   tests to avoid platform-plugin dependencies.
  const BackupService(
    this._database, {
    Future<String> Function()? appVersionResolver,
  }) : _appVersionResolver = appVersionResolver;

  final AppDatabase _database;

  /// Injectable version resolver; null means use the real PackageInfo.
  final Future<String> Function()? _appVersionResolver;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Runs the full export and writes the ZIP archive.
  ///
  /// Parameters:
  /// - [destinationDir]: Directory in which to write the ZIP. Falls back to
  ///   [_resolveDownloadsDir] when null or when the path does not exist.
  ///
  /// Returns [BackupSuccess] with the file path on success, or [BackupFailure]
  /// on any error. Never throws.
  Future<BackupResult> export({String? destinationDir}) async {
    try {
      // 1. Resolve the output directory.
      final outDir = await _resolveOutputDir(destinationDir);
      final timestamp = _formatTimestamp(DateTime.now());
      final zipPath = p.join(outDir, 'variance_backup_$timestamp.zip');

      // 2. Collect all data inside a single DB transaction (snapshot read).
      late _ExportPayload payload;
      await _database.transaction(() async {
        payload = await _collectPayload();
      });

      // 3. Assemble and write the ZIP archive.
      final archive = _buildArchive(payload);
      final encoder = ZipEncoder();

      final outFile = File(zipPath);
      await outFile.parent.create(recursive: true);

      // Write the archive bytes to disk.
      final bytes = encoder.encode(archive);
      await outFile.writeAsBytes(bytes);

      dev.log(
        'Backup written to $zipPath (${bytes.length} bytes)',
        name: 'BackupService',
      );

      return BackupSuccess(zipPath);
    } on Object catch (e, st) {
      dev.log('BackupService.export failed: $e',
          name: 'BackupService', error: e, stackTrace: st);
      return BackupFailure('Export failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Collects all data needed for the ZIP from the database.
  ///
  /// Must be called inside a Drift [database.transaction] block to ensure a
  /// consistent snapshot across all table reads.
  Future<_ExportPayload> _collectPayload() async {
    // Resolve app version via the injected resolver (production: PackageInfo).
    final String appVersion;
    if (_appVersionResolver != null) {
      appVersion = await _appVersionResolver();
    } else {
      // Lazy import to avoid compile-time issues in test environments where
      // package_info_plus Windows FFI sources fail to compile.
      appVersion = await _resolveAppVersion();
    }

    // Read schema_backup_version from app_settings (default 1).
    final schemaVersionStr =
        await _database.appSettingsDao.getValue('schema_backup_version');
    final schemaVersion = int.tryParse(schemaVersionStr ?? '') ?? 1;

    // Read all non-deleted entities from each table.
    // Tables with is_deleted: accounts, categories, payees, recurring_templates.
    // Transactions use status='voided' instead of is_deleted (Data Model §11.2).
    final accounts = await _selectNonDeleted('accounts');
    final accountDetails = await _database.customSelect(
      'SELECT * FROM account_details',
      readsFrom: {},
    ).get();
    final categories = await _selectNonDeleted('categories');
    final tags = await _database.customSelect(
      'SELECT * FROM tags',
      readsFrom: {},
    ).get();
    final payees = await _selectNonDeleted('payees');

    // Transactions: exclude voided. Include posted, pending, draft.
    final transactions = await _database.customSelect(
      "SELECT * FROM transactions WHERE status != 'voided'",
      readsFrom: {},
    ).get();
    final entries = await _database.customSelect(
      'SELECT * FROM entries',
      readsFrom: {},
    ).get();
    final transactionTags = await _database.customSelect(
      'SELECT * FROM transaction_tags',
      readsFrom: {},
    ).get();

    final currencies = await _database.customSelect(
      'SELECT * FROM currencies',
      readsFrom: {},
    ).get();
    final exchangeRates = await _database.customSelect(
      'SELECT * FROM exchange_rates',
      readsFrom: {},
    ).get();

    // Attachments — we collect file_path for photo resolution.
    final attachments = await _database.customSelect(
      'SELECT * FROM attachments',
      readsFrom: {},
    ).get();

    final budgets = await _database.customSelect(
      'SELECT * FROM budgets',
      readsFrom: {},
    ).get();
    final budgetPeriods = await _database.customSelect(
      'SELECT * FROM budget_periods',
      readsFrom: {},
    ).get();

    final recurringTemplates = await _selectNonDeleted('recurring_templates');
    final scheduledOccurrences = await _database.customSelect(
      'SELECT * FROM scheduled_occurrences',
      readsFrom: {},
    ).get();
    final installmentPlans = await _database.customSelect(
      'SELECT * FROM installment_plans',
      readsFrom: {},
    ).get();
    final installmentOccurrences = await _database.customSelect(
      'SELECT * FROM installment_occurrences',
      readsFrom: {},
    ).get();

    // Resolve photo file paths (relative → absolute via app documents dir).
    final docsDir = (await getApplicationDocumentsDirectory()).path;
    final photoPaths = attachments
        .map((row) {
          final value = row.data['file_path'];
          return value is String ? value : null;
        })
        .whereType<String>()
        .map((rel) => p.join(docsDir, rel))
        .toList();

    return _ExportPayload(
      appVersion: appVersion,
      schemaVersion: schemaVersion,
      createdAt: DateTime.now().toUtc(),
      entityRows: {
        'accounts': _rowsToJson(accounts),
        'account_details': _rowsToJson(accountDetails),
        'categories': _rowsToJson(categories),
        'tags': _rowsToJson(tags),
        'payees': _rowsToJson(payees),
        'transactions': _rowsToJson(transactions),
        'entries': _rowsToJson(entries),
        'transaction_tags': _rowsToJson(transactionTags),
        'currencies': _rowsToJson(currencies),
        'exchange_rates': _rowsToJson(exchangeRates),
        'attachments': _rowsToJson(attachments),
        'budgets': _rowsToJson(budgets),
        'budget_periods': _rowsToJson(budgetPeriods),
        'recurring_templates': _rowsToJson(recurringTemplates),
        'scheduled_occurrences': _rowsToJson(scheduledOccurrences),
        'installment_plans': _rowsToJson(installmentPlans),
        'installment_occurrences': _rowsToJson(installmentOccurrences),
      },
      photoPaths: photoPaths,
    );
  }

  /// Queries [tableName] filtering out soft-deleted rows (`is_deleted = 1`).
  Future<List<QueryRow>> _selectNonDeleted(String tableName) {
    return _database.customSelect(
      'SELECT * FROM $tableName WHERE is_deleted = 0',
      readsFrom: {},
    ).get();
  }

  /// Converts a list of [QueryRow]s to a list of JSON-serialisable maps.
  List<Map<String, dynamic>> _rowsToJson(List<QueryRow> rows) {
    return rows.map((row) {
      // QueryRow.data is Map<String, dynamic> — values are SQLite primitives
      // (int, double, String, Uint8List, null). We convert Uint8List to a
      // base64-encoded string for JSON compatibility (e.g. encrypted fields).
      final Map<String, dynamic> result = {};
      for (final entry in row.data.entries) {
        final value = entry.value;
        if (value is List<int>) {
          result[entry.key] = base64Encode(value);
        } else {
          result[entry.key] = value;
        }
      }
      return result;
    }).toList();
  }

  /// Builds the in-memory [Archive] with manifest, export JSON, and photos.
  Archive _buildArchive(_ExportPayload payload) {
    final archive = Archive();

    // --- manifest.json (SDS §2.17.1) ---
    final manifest = {
      'backup_format_version': 1,
      'app_version': payload.appVersion,
      'created_at': payload.createdAt.toIso8601String(),
      'schema_version': payload.schemaVersion,
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    // --- variance_export.json ---
    final exportBytes = utf8.encode(
      jsonEncode({'export_version': 1, 'tables': payload.entityRows}),
    );
    archive.addFile(
      ArchiveFile('variance_export.json', exportBytes.length, exportBytes),
    );

    // --- Photos (skip missing files, log warning) ---
    for (final photoPath in payload.photoPaths) {
      final file = File(photoPath);
      if (!file.existsSync()) {
        dev.log(
          'BackupService: photo missing, skipping — $photoPath',
          name: 'BackupService',
        );
        continue;
      }
      final photoBytes = file.readAsBytesSync();
      final archiveName = p.join('attachments', p.basename(photoPath));
      archive.addFile(
        ArchiveFile(archiveName, photoBytes.length, photoBytes),
      );
    }

    return archive;
  }

  /// Resolves the output directory.
  ///
  /// Uses [dir] if provided and accessible. Falls back to the platform
  /// Downloads directory, then app external storage.
  Future<String> _resolveOutputDir(String? dir) async {
    if (dir != null && dir.isNotEmpty) {
      final d = Directory(dir);
      if (d.existsSync()) return dir;
    }
    // Fallback: external storage or app documents dir.
    final downloadsPath = await _resolveDownloadsDir();
    return downloadsPath;
  }

  /// Attempts to resolve a writable Downloads directory.
  ///
  /// Returns the app external storage path on Android if the standard
  /// Downloads directory is not accessible.
  Future<String> _resolveDownloadsDir() async {
    // Standard Android external storage (getExternalStorageDirectory covers
    // the app-private external directory; no WRITE_EXTERNAL_STORAGE needed).
    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      return externalDir.path;
    }
    // Last resort: app documents directory.
    final docsDir = await getApplicationDocumentsDirectory();
    return docsDir.path;
  }

  /// Reads the app version string from [PackageInfo.fromPlatform].
  ///
  /// Only called in production (non-test) paths. Tests inject a version
  /// resolver via the constructor to avoid platform-plugin dependencies.
  Future<String> _resolveAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Formats a [DateTime] as `YYYYMMDDHHmmss` for the file name.
  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$mo$d$h$mi$s';
  }
}

// ---------------------------------------------------------------------------
// Internal data holder
// ---------------------------------------------------------------------------

/// Internal payload assembled from a single DB snapshot transaction.
class _ExportPayload {
  const _ExportPayload({
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.entityRows,
    required this.photoPaths,
  });

  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;

  /// Map of table name → list of serialised row maps.
  final Map<String, List<Map<String, dynamic>>> entityRows;

  /// Absolute file paths to attached photos.
  final List<String> photoPaths;
}
