// lib/data/database/tables/entries_table.dart
//
// Drift table definition for `entries`.
//
// Individual DEB ledger lines. Each transaction has ≥ 2 entries and
// Σ debit = Σ credit must hold. Exactly one of account_id / category_id is
// non-null per row; this exclusivity is enforced at the domain layer.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/transactions_table.dart';
import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/currencies_table.dart';

/// Drift table for individual double-entry bookkeeping ledger lines.
///
/// Balance formula for accounts:
/// `balance = Σ(amount WHERE side='debit') − Σ(amount WHERE side='credit')`
///
/// The exclusivity constraint (exactly one of [accountId] or [categoryId]
/// must be non-null) is enforced at the domain layer via
/// `Transaction.validate()`.
class Entries extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// FK → transactions(id) ON DELETE RESTRICT. Cascade delete is blocked
  /// intentionally — void/reversal must go through the domain layer.
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.restrict)();

  /// Account leg; mutually exclusive with [categoryId].
  TextColumn get accountId => text().nullable().references(Accounts, #id)();

  /// Category leg; mutually exclusive with [accountId].
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// Double-entry side: `debit` or `credit`.
  TextColumn get side => text()();

  /// Amount in minor units of [currencyCode]. Must be > 0.
  IntColumn get amountMinor => integer()();

  /// Currency of this entry (derived from account currency).
  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// Rate to home currency × 1,000,000. NULL if same as home currency.
  IntColumn get exchangeRateMicro => integer().nullable()();

  /// Unix epoch seconds when this row was written (TC-025).
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
