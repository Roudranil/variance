/// **Enums for Type Safety**
library;

/// Represents the nature of an account.
enum AccountType {
  /// Represents physical cash in hand or wallet.
  cash,

  /// Represents a savings account in a bank.
  savings,

  /// Represents a standard bank account (checking/current).
  bankAccount,

  /// Represents a credit card account.
  creditCard,

  /// Represents a loan or debt account.
  loan,

  /// Represents an investment account (e.g., stocks, mutual funds).
  investment,

  /// Represents an insurance policy account.
  insurance,
}

/// Represents the direction flow for a category.
enum CategoryKind {
  /// Represents an expense category.
  expense,

  /// Represents an income category.
  income,
}

/// Represents the type of a transaction.
enum TransactionType {
  /// Money leaving an account.
  expense,

  /// Money entering an account.
  income,

  /// Money moving between two accounts.
  transfer,

  /// Correction of account balance.
  adjustment,
}

/// Represents the frequency for recurring patterns.
enum RecurringFrequency {
  /// Repeats every day.
  daily,

  /// Repeats every week.
  weekly,

  /// Repeats every month.
  monthly,

  /// Repeats every year.
  yearly,
}

/// Represents the automation type for recurring patterns.
enum RecurringType {
  /// Automatically generates the transaction.
  automatic,

  /// Reminds the user to create the transaction.
  manualReminder,
}
