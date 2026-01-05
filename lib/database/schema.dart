import 'package:drift/drift.dart';

import 'package:variance/database/enums.dart';

///
/// This includes user-visible accounts (cash, bank, credit cards) and hidden
/// system accounts (category-linked nominal accounts, equity accounts).
///
/// Constraints:
/// - [nature] determines debit/credit behavior per accounting rules.
/// - [type] is nullable for system accounts (categories, equity).
/// - [isUserVisible] controls whether the account appears in the user-facing
///   account list.
class Accounts extends Table {
  /// Primary key. Auto-incrementing integer.
  IntColumn get id => integer().autoIncrement()();

  /// The user-defined name for the account.
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// The user-facing type for UI grouping.
  ///
  /// Nullable for system accounts (category-linked accounts, equity accounts).
  TextColumn get type => textEnum<AccountType>().nullable()();

  /// The fundamental accounting nature.
  ///
  /// Determines whether debits increase or decrease the balance.
  TextColumn get nature => textEnum<AccountNature>()();

  /// Whether this account is visible in the user-facing account list.
  ///
  /// False for category-linked accounts and system equity accounts.
  BoolColumn get isUserVisible => boolean().withDefault(const Constant(true))();

  /// ISO 4217 currency code.
  ///
  /// Defaults to 'INR'.
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();

  /// Whether to include this account in net worth calculations.
  ///
  /// Defaults to true.
  BoolColumn get includeInTotals =>
      boolean().withDefault(const Constant(true))();

  /// Soft delete flag.
  ///
  /// If true, the account is hidden from the UI but kept for historical
  /// integrity.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Audit timestamp for record creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Audit timestamp for last update.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // --- Credit Card Metadata (nullable) ---

  /// Statement generation day (1-31).
  ///
  /// Applicable only to credit card accounts.
  IntColumn get statementDay => integer().nullable()();

  /// Payment due day (1-31).
  ///
  /// Applicable only to credit card accounts.
  IntColumn get paymentDueDay => integer().nullable()();

  /// Credit limit amount.
  ///
  /// Applicable only to credit card accounts.
  RealColumn get creditLimit => real().nullable()();

  // --- Loan/Savings Metadata (nullable) ---

  /// Annual interest rate (as a percentage).
  ///
  /// Applicable to loans and savings accounts.
  RealColumn get interestRate => real().nullable()();

  /// Original principal amount.
  ///
  /// Applicable only to loan accounts.
  RealColumn get principal => real().nullable()();

  /// Monthly installment amount (EMI).
  ///
  /// Applicable only to loan accounts.
  RealColumn get installmentAmount => real().nullable()();

  /// Next payment due date.
  ///
  /// Applicable only to loan accounts.
  DateTimeColumn get nextDueDate => dateTime().nullable()();

  /// Maturity date.
  ///
  /// Applicable to fixed deposits and savings accounts.
  DateTimeColumn get maturityDate => dateTime().nullable()();
}

/// Classifies the nature of a transaction (expense or income).
///
/// In double-entry bookkeeping, each category is linked to a hidden nominal
/// account. When a user selects a category for a transaction, the system uses
/// the [linkedAccountId] to create the corresponding ledger entry.
///
/// Supports infinite hierarchy via [parentId].
class Categories extends Table {
  /// Primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Display name (e.g., "Food", "Salary").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// The direction of flow this category represents.
  TextColumn get kind => textEnum<CategoryKind>()();

  /// Self-referencing foreign key for sub-categories.
  ///
  /// If null, this is a top-level category.
  IntColumn get parentId => integer().nullable().references(Categories, #id)();

  /// Foreign key to the hidden nominal account for DEB.
  ///
  /// This account is created automatically when the category is created.
  IntColumn get linkedAccountId => integer().references(Accounts, #id)();

  /// Icon identifier (codePoint or asset path).
  TextColumn get iconData => text().nullable()();

  /// UI color (ARGB integer).
  IntColumn get color => integer().nullable()();

  /// Soft delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Audit timestamp for record creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Audit timestamp for last update.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cross-cutting labels for grouping transactions.
///
/// Example: Tag multiple transactions with "Hawaii Trip" to see the total trip
/// cost, regardless of whether they are Food, Travel, or Lodging expenses.
class Tags extends Table {
  /// Primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Display name.
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// UI color (ARGB integer).
  IntColumn get color => integer().nullable()();

  /// Soft delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Represents the header of a financial event (immutable).
///
/// The actual money movement is recorded in [LedgerEntries]. A transaction is
/// never deleted; instead, it is marked as void via [isVoid].
class Transactions extends Table {
  /// Primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The date and time the transaction occurred.
  DateTimeColumn get transactionDate => dateTime()();

  /// The type of transaction.
  TextColumn get type => textEnum<TransactionType>()();

  /// Optional user-defined note.
  TextColumn get userNote => text().nullable()();

  /// External reference (e.g., SMS ID, bank reference number).
  TextColumn get externalReference => text().nullable()();

  /// Soft-delete flag for immutable ledger.
  ///
  /// True = voided transaction (hidden from UI, excluded from balance
  /// calculations).
  BoolColumn get isVoid => boolean().withDefault(const Constant(false))();

  /// Audit timestamp for record creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Audit timestamp for last update.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Immutable journal line items for double-entry bookkeeping.
///
/// Each transaction creates 2 or more ledger entries such that:
/// - sum(debits) = sum(credits) for the transaction.
///
/// Entries are never modified or deleted. To "undo" a transaction, the parent
/// [Transactions] record is marked as void.
class LedgerEntries extends Table {
  /// Primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to the parent transaction.
  IntColumn get transactionId => integer().references(Transactions, #id)();

  /// Foreign key to the account affected.
  IntColumn get accountId => integer().references(Accounts, #id)();

  /// The amount (always stored as a positive number).
  RealColumn get amount => real()();

  /// The side of the entry (DEBIT or CREDIT).
  TextColumn get side => textEnum<LedgerSide>()();

  /// Audit timestamp for record creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Many-to-many join between [Transactions] and [Tags].
class TransactionTags extends Table {
  /// Foreign key to the transaction.
  IntColumn get transactionId => integer().references(Transactions, #id)();

  /// Foreign key to the tag.
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}

/// Definitions for transactions that repeat over time.
///
/// The system checks [nextRunDate] and creates actual [Transactions] entries
/// based on the template fields when due.
class RecurringPatterns extends Table {
  /// Primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Base frequency unit.
  TextColumn get frequency => textEnum<RecurringFrequency>()();

  /// Multiplier for the frequency.
  ///
  /// Example: frequency = weekly, interval = 2 means "every 2 weeks".
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// When this pattern starts.
  DateTimeColumn get startDate => dateTime()();

  /// When this pattern ends.
  ///
  /// If null, repeats forever.
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Pre-calculated next occurrence date.
  ///
  /// Optimization field for efficient querying.
  DateTimeColumn get nextRunDate => dateTime()();

  /// Automation type.
  ///
  /// Defaults to 'automatic'.
  TextColumn get automationType =>
      textEnum<RecurringType>().withDefault(const Constant('automatic'))();

  // --- Template Fields (DEB-compatible) ---

  /// Transaction type for the generated transaction.
  TextColumn get templateTransactionType => textEnum<TransactionType>()();

  /// Amount to use when creating the transaction.
  RealColumn get templateAmount => real()();

  /// Primary account for the transaction.
  ///
  /// For expense: the source account (money leaves).
  /// For income: the destination account (money enters).
  /// For transfer: the source account.
  @ReferenceName('recurringPatternsPrimaryAccount')
  IntColumn get templateAccountId => integer().references(Accounts, #id)();

  /// Category for the transaction.
  ///
  /// Required for expense/income. Null for transfers.
  IntColumn get templateCategoryId =>
      integer().nullable().references(Categories, #id)();

  /// Secondary account for transfers.
  ///
  /// The destination account for transfer transactions. Null for
  /// expense/income.
  @ReferenceName('recurringPatternsSecondaryAccount')
  IntColumn get templateSecondaryAccountId =>
      integer().nullable().references(Accounts, #id)();

  /// Optional note for the generated transaction.
  TextColumn get templateNote => text().nullable()();

  /// Soft delete flag.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
