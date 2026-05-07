// lib/data/database/tables/attachments_table.dart
//
// Drift table definition for `attachments`.
//
// Photo attachments to transactions. Max 2 per transaction enforced at app
// layer. Photos are stored as files in app-private storage; this table holds
// metadata and the path only.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/transactions_table.dart';

/// Drift table for transaction photo attachment metadata.
///
/// The actual photo files live in app-private storage. On soft-delete of
/// the parent transaction, the files must be deleted from disk by the
/// domain service.
class Attachments extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → transactions(id) ON DELETE RESTRICT. Physical deletion is managed
  /// by the domain service, not the cascade.
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.restrict)();

  /// Relative path within app-private storage. Unique across all attachments.
  TextColumn get filePath => text().unique()();

  /// Compressed file size in bytes.
  IntColumn get fileSizeBytes => integer()();

  /// MIME type. Always `image/jpeg` after TC-007 compression.
  TextColumn get mimeType => text().withDefault(const Constant('image/jpeg'))();

  /// Compressed width in pixels. NULL if unavailable.
  IntColumn get widthPx => integer().nullable()();

  /// Compressed height in pixels. NULL if unavailable.
  IntColumn get heightPx => integer().nullable()();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
