// lib/data/database/tables/drafts_table.dart
//
// Drift table definition for `drafts`.
//
// Auto-saved transaction entry form state. Max 5 rows enforced at app layer
// using FIFO eviction. Not part of the ledger — purely UX convenience.

import 'package:drift/drift.dart';

/// Drift table for auto-saved transaction entry drafts.
///
/// At most 5 rows are kept; the oldest is evicted when the limit is
/// exceeded. Drafts are not part of the financial ledger and do not
/// affect account balances.
class Drafts extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Serialized form state as a JSON string.
  TextColumn get payloadJson => text()();

  /// Unix epoch seconds when this draft was first saved. Used for FIFO
  /// eviction ordering.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds of the most recent auto-save.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
