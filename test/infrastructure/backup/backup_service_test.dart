// test/infrastructure/backup/backup_service_test.dart
//
// Unit tests for BackupService (T-188).
//
// Uses an in-memory AppDatabase — no disk I/O beyond the temp ZIP file,
// which is written to a system temp directory and cleaned up after each test.
//
// BackupService is constructed with an injected [appVersionResolver] to avoid
// package_info_plus platform-plugin dependencies in tests.
//
// Test cases:
//   T-188.1 manifest JSON contains correct fields and structure
//   T-188.2 soft-deleted accounts absent from variance_export.json
//   T-188.3 missing photo file is skipped without exception
//   T-188.4 variance_export.json contains non-deleted accounts
//   T-188.5 ZIP contains both manifest.json and variance_export.json
//   T-188.6 backup file name matches variance_backup_YYYYMMDD_ pattern

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:variance/data/database/app_database.dart';
import 'package:variance/infrastructure/backup/backup_service.dart';

// ---------------------------------------------------------------------------
// path_provider mock
// ---------------------------------------------------------------------------

/// Minimal [PathProviderPlatform] fake that returns a temp directory for all
/// path queries used by [BackupService].
class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.tempDir);

  final String tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir;

  @override
  Future<String?> getExternalStoragePath() async => tempDir;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      null;

  @override
  Future<String?> getApplicationCachePath() async => tempDir;

  @override
  Future<String?> getApplicationSupportPath() async => tempDir;

  @override
  Future<String?> getDownloadsPath() async => tempDir;

  @override
  Future<String?> getTemporaryPath() async => tempDir;

  @override
  Future<String?> getLibraryPath() async => null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a [BackupService] backed by [db] with a stub version resolver.
BackupService _makeService(AppDatabase db) {
  return BackupService(
    db,
    appVersionResolver: () async => '1.0.0-test',
  );
}

/// Inserts a minimal accounts row.
///
/// Uses [account_category] (Drift column for account type) and
/// [initial_balance_minor] as per the actual schema.
Future<void> _insertAccount(
  AppDatabase db,
  String id,
  String name, {
  int isDeleted = 0,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.customStatement(
    '''
    INSERT INTO accounts (id, name, account_category, currency_code,
      initial_balance_minor, is_deleted, created_at, updated_at)
    VALUES (?, ?, 'savings', 'INR', 0, ?, ?, ?)
    ''',
    [id, name, isDeleted, now, now],
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('backup_test_');
    db = AppDatabase(NativeDatabase.memory());

    // Register fake path provider so BackupService resolves paths correctly.
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);

    // Seed schema_backup_version in app_settings.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.customStatement(
      "INSERT OR REPLACE INTO app_settings (key, value, updated_at)"
      " VALUES ('schema_backup_version', '1', 1700000000)",
    );
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // ---- T-188.1 Manifest structure ------------------------------------------

  test('T-188.1 manifest JSON contains required fields', () async {
    final service = _makeService(db);
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final zipPath = (result as BackupSuccess).filePath;
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    final manifestFile = archive.files.firstWhere(
      (f) => f.name == 'manifest.json',
    );
    final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>))
        as Map<String, dynamic>;

    expect(manifest['backup_format_version'], 1);
    expect(manifest['app_version'], '1.0.0-test');
    expect(manifest['created_at'], isA<String>());
    expect(manifest['schema_version'], 1);

    // created_at must be valid ISO 8601 UTC.
    final createdAt = DateTime.tryParse(manifest['created_at'] as String);
    expect(createdAt, isNotNull);
  });

  // ---- T-188.2 Soft-deleted entities excluded --------------------------------

  test('T-188.2 soft-deleted accounts absent from variance_export.json',
      () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertAccount(db, 'acc-active', 'Active Account', isDeleted: 0);
    await _insertAccount(db, 'acc-deleted', 'Deleted Account', isDeleted: 1);
    await db.customStatement('PRAGMA foreign_keys = ON');

    final service = _makeService(db);
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final zipPath = (result as BackupSuccess).filePath;
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    final exportFile = archive.files.firstWhere(
      (f) => f.name == 'variance_export.json',
    );
    final export = jsonDecode(utf8.decode(exportFile.content as List<int>))
        as Map<String, dynamic>;

    final accounts =
        (export['tables'] as Map<String, dynamic>)['accounts'] as List<dynamic>;
    final ids = accounts.map((a) => (a as Map)['id']).toList();

    expect(ids, contains('acc-active'));
    expect(ids, isNot(contains('acc-deleted')));
  });

  // ---- T-188.3 Missing photo skipped ----------------------------------------

  test('T-188.3 missing photo file skipped without exception', () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.customStatement(
      "INSERT INTO attachments (id, transaction_id, file_path,"
      " file_size_bytes, mime_type, created_at)"
      " VALUES ('att-1', 'tx-ghost', 'attachments/ghost.jpg', 0,"
      " 'image/jpeg', 1700000000)",
    );
    await db.customStatement('PRAGMA foreign_keys = ON');

    final service = _makeService(db);
    // Should complete without throwing.
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final zipPath = (result as BackupSuccess).filePath;
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    // Ghost photo must NOT appear in the archive.
    final names = archive.files.map((f) => f.name).toList();
    expect(names, isNot(contains('attachments/ghost.jpg')));
  });

  // ---- T-188.4 Non-deleted entities included ---------------------------------

  test('T-188.4 non-deleted accounts present in variance_export.json',
      () async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await _insertAccount(db, 'acc-ok', 'My Account', isDeleted: 0);
    await db.customStatement('PRAGMA foreign_keys = ON');

    final service = _makeService(db);
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final zipPath = (result as BackupSuccess).filePath;
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    final exportFile = archive.files.firstWhere(
      (f) => f.name == 'variance_export.json',
    );
    final export = jsonDecode(utf8.decode(exportFile.content as List<int>))
        as Map<String, dynamic>;

    final accounts =
        (export['tables'] as Map<String, dynamic>)['accounts'] as List<dynamic>;
    final ids = accounts.map((a) => (a as Map)['id']).toList();
    expect(ids, contains('acc-ok'));
  });

  // ---- T-188.5 ZIP structure ------------------------------------------------

  test('T-188.5 ZIP contains manifest.json and variance_export.json', () async {
    final service = _makeService(db);
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final zipPath = (result as BackupSuccess).filePath;
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    final names = archive.files.map((f) => f.name).toList();
    expect(names, contains('manifest.json'));
    expect(names, contains('variance_export.json'));
  });

  // ---- T-188.6 File name pattern -------------------------------------------

  test('T-188.6 backup file name matches variance_backup_YYYYMMDD_ pattern',
      () async {
    final service = _makeService(db);
    final result = await service.export(destinationDir: tempDir.path);
    expect(result, isA<BackupSuccess>());

    final fileName = p.basename((result as BackupSuccess).filePath);
    expect(fileName, matches(RegExp(r'^variance_backup_\d{14}\.zip$')));
  });
}
