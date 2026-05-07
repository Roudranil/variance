// lib/data/database/tables/transaction_tags_table.dart
//
// Drift table definition for `transaction_tags`.
//
// Many-to-many join between transactions and tags. Both FK columns
// participate in the composite primary key.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/data/database/tables/tags_table.dart';

/// Drift table for the many-to-many join between transactions and tags.
///
/// The composite primary key is (transactionId, tagId). Both columns
/// cascade-delete when the parent row is removed.
class TransactionTags extends Table {
  /// FK → transactions(id) ON DELETE CASCADE.
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();

  /// FK → tags(id) ON DELETE CASCADE.
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {transactionId, tagId};
}
