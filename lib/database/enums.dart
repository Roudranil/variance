/// **Enums for Type Safety**

/// Represents the nature of an account.
enum AccountType {
  cash,
  savings,
  bankAccount,
  creditCard,
  loan,
  investment,
  insurance,
}

/// Represents the direction flow for a category.
enum CategoryKind { expense, income }

/// Represents the type of a transaction.
enum TransactionType { expense, income, transfer, adjustment }

/// Represents the frequency for recurring patterns.
enum RecurringFrequency { daily, weekly, monthly, yearly }

/// Represents the automation type for recurring patterns.
enum RecurringType { automatic, manualReminder }
