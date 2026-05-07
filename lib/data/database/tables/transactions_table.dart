// lib/data/database/tables/transactions_table.dart
//
// Drift table definition for `transactions`.
//
// Stores atomic financial event headers. Each transaction has two or more
// corresponding rows in `entries`. Financial fields are immutable once
// status='posted'; non-financial fields are updatable in-place.

import 'package:drift/drift.dart';

import 'package:variance/data/database/tables/currencies_table.dart';
import 'package:variance/data/database/tables/accounts_table.dart';
import 'package:variance/data/database/tables/categories_table.dart';
import 'package:variance/data/database/tables/payees_table.dart';
import 'package:variance/data/database/tables/recurring_templates_table.dart';

/// Drift table for transaction headers.
///
/// The [type] column distinguishes income/expense/transfer. The [status] and
/// [purpose] columns together implement the correction-chain model (TC-001).
/// Balance computation is deferred to `entries`.
class Transactions extends Table {
  /// Stable UUID v4 identifier.
  TextColumn get id => text()();

  /// Transaction type: `income`, `expense`, or `transfer`.
  TextColumn get type => text()();

  /// Ledger participation state. Defaults to `pending`.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Role in the correction/reversal chain. Defaults to `user`.
  TextColumn get purpose => text().withDefault(const Constant('user'))();

  /// User-specified business date as Unix epoch seconds.
  /// Named [transactionDate] to avoid collision with Drift's built-in
  /// `dateTime()` method on Table.
  IntColumn get transactionDate => integer()();

  /// Transaction amount in minor units of [currencyCode]. Must be > 0.
  IntColumn get amountMinor => integer()();

  /// Currency derived from source account. Immutable after creation.
  TextColumn get currencyCode => text().references(Currencies, #code)();

  /// Rate × 1,000,000 from account currency to [homeCurrencyAtCapture].
  /// NULL when transaction currency equals home currency.
  IntColumn get exchangeRateMicro => integer().nullable()();

  /// Home currency code captured at rate-fetch time.
  /// NULL when transaction currency equals home currency.
  TextColumn get homeCurrencyAtCapture =>
      text().nullable().references(Currencies, #code)();

  /// Source account for expense/transfer. NULL for income.
  TextColumn get accountSourceId =>
      text().nullable().references(Accounts, #id)();

  /// Destination account for income/transfer. NULL for expense.
  TextColumn get accountDestinationId =>
      text().nullable().references(Accounts, #id)();

  /// Top-level category. NULL for transfers.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// Optional subcategory. NULL for transfers.
  TextColumn get subcategoryId =>
      text().nullable().references(Categories, #id)();

  /// Optional payee/merchant reference.
  TextColumn get payeeId => text().nullable().references(Payees, #id)();

  /// User-defined label. Updatable in-place.
  TextColumn get title => text().nullable()();

  /// Long-form note. Updatable in-place.
  TextColumn get description => text().nullable()();

  /// UUID shared by compound group members (e.g. transfer + fee).
  TextColumn get compoundGroupId => text().nullable()();

  /// Role within a compound group: `primary`, `secondary`, or NULL.
  TextColumn get compoundRole => text().nullable()();

  /// FK to the generating recurring template.
  TextColumn get parentTemplateId =>
      text().nullable().references(RecurringTemplates, #id)();

  /// For purpose=correction/reversal: ID of the transaction being corrected.
  TextColumn get correctsTransactionId =>
      text().nullable().references(Transactions, #id)();

  /// True when a child was edited/deleted outside normal scheduling.
  BoolColumn get isManuallyHandled =>
      boolean().withDefault(const Constant(false))();

  /// Unix epoch seconds when this row was created.
  IntColumn get createdAt => integer()();

  /// Unix epoch seconds when this row was last modified.
  IntColumn get updatedAt => integer()();

  /// JSON escape hatch for future extensibility.
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
