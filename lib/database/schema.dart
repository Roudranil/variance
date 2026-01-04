import 'package:drift/drift.dart';

import 'package:variance/database/enums.dart';

/// **Accounts Table**
///
/// Represents the physical or digital storage of money.
/// This is the core entity for the Double Entry system.
///
/// **Constraints:**
/// *   [type] must be one of [AccountType] values.
/// *   [currencyCode] defaults to 'INR'.
class Accounts extends Table {
  /// Primary Key. Auto-incrementing integer.
  IntColumn get id => integer().autoIncrement()();

  /// User-defined name for the account (e.g., "HDFC Bank", "Wallet").
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// The category/nature of the account.
  /// Used for UI grouping and reporting logic (Net Worth calculation).
  TextColumn get type => textEnum<AccountType>()();

  /// The opening balance when the account was created/imported.
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();

  /// The current calculated balance.
  /// NOTE: This can be derived from [initialBalance] + Sum(Transactions).
  /// Optimization: We might cache this value here.
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();

  /// ISO 4217 Currency Code (e.g., 'INR', 'USD').
  /// Defaults to 'INR'.
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();

  /// Determines if the balances in this account should be included in
  /// the overall net worth calculation.
  BoolColumn get includeInTotals =>
      boolean().withDefault(const Constant(true))();

  /// Soft Delete flag. If true, the account is hidden from the UI but kept for history.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // --- Credit Card Specific Fields ---

  /// The day of the month (1-31) when the statement is generated.
  /// Nullable: Only relevant for [type] == 'creditCard'.
  IntColumn get statementDay => integer().nullable()();

  /// The day of the month (1-31) when the payment is due.
  /// Nullable: Only relevant for [type] == 'creditCard'.
  IntColumn get paymentDueDay => integer().nullable()();

  // --- Loan/Savings Specific Fields ---

  /// Annual Interest Rate (percentage).
  /// Nullable: Only relevant for loans or savings accounts.
  RealColumn get interestRate => real().nullable()();
}

/// **Categories Table**
///
/// Classifies the nature of a transaction (Flow).
/// Technically acts as Nominal Accounts in a strict ledger, but here treated as tagging.
/// Supports infinite hierarchy via [parentId].
class Categories extends Table {
  /// Primary Key.
  IntColumn get id => integer().autoIncrement()();

  /// Display name (e.g., "Food", "Salary").
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// The direction of flow this category represents.
  TextColumn get kind => textEnum<CategoryKind>()();

  /// Self-referencing Foreign Key to support sub-categories.
  /// If null, this is a Top-Level Category.
  IntColumn get parentId => integer().nullable().references(Categories, #id)();

  /// Icon identifier (stored as string codePoint or asset path).
  TextColumn get iconData => text().nullable()();

  /// UI Color (stored as ARGB integer).
  IntColumn get color => integer().nullable()();

  /// Soft Delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// **Tags Table**
///
/// Cross-cutting labels for grouping transactions across categories.
/// Example: "Trip 2025" tag on Food, Flight, and Hotel transactions.
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer().nullable()();

  /// Soft Delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// **Transactions Table**
///
/// The central ledger of the application.
/// Records money moving between accounts (Transfer) or in/out of an account (Income/Expense).
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The actual date and time the transaction occurred.
  DateTimeColumn get transactionDate => dateTime()();

  /// The absolute magnitude of the money flow.
  /// NOTE: Always stored as a positive number. Direction is determined by [type] and Accounts.
  RealColumn get amount => real()();

  /// The nature of the transaction.
  TextColumn get type => textEnum<TransactionType>()();

  /// Optional user note.
  TextColumn get description => text().nullable()();

  // --- Foreign Keys (Double Entry Enforcers) ---

  /// The account money is coming FROM.
  /// Required for: 'expense', 'transfer'.
  /// Null for: 'income'.
  IntColumn get sourceAccountId =>
      integer().nullable().references(Accounts, #id)();

  /// The account money is going TO.
  /// Required for: 'income', 'transfer'.
  /// Null for: 'expense'.
  IntColumn get destinationAccountId =>
      integer().nullable().references(Accounts, #id)();

  /// The classification category.
  /// Required for: 'expense', 'income'.
  /// Optional/Null for: 'transfer' (Transfers usually don't need categories).
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Audit timestamp.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// **TransactionTags Table**
///
/// Many-to-Many join table linking [Transactions] and [Tags].
class TransactionTags extends Table {
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}

/// **RecurringPatterns Table**
///
/// Definitions for transactions that repeat over time.
/// Used by the generator engine to create actual [Transactions] entries.
class RecurringPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Base frequency unit.
  TextColumn get frequency => textEnum<RecurringFrequency>()();

  /// Multiplier for the frequency.
  /// Example: frequency='weekly', interval=2 implies "Every 2 weeks".
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// When this pattern starts active.
  DateTimeColumn get startDate => dateTime()();

  /// When this pattern stops.
  /// If null, it repeats forever.
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Optimization field: The pre-calculated date of the next occurrence.
  /// The engine queries this to find what's due today.
  DateTimeColumn get nextRunDate => dateTime()();

  /// Automation type.
  TextColumn get type =>
      textEnum<RecurringType>().withDefault(const Constant('automatic'))();

  /// JSON blob containing the template data (amount, accounts, category)
  /// to copy when generating the real transaction.
  TextColumn get templateData => text()();

  /// Soft Delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
