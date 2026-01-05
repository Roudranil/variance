/// The fundamental accounting nature of an account.
///
/// Determines whether debits increase or decrease the account balance according
/// to double-entry bookkeeping rules.
enum AccountNature {
  /// Debit-increase accounts (cash, savings, wallet).
  ///
  /// Balance = sum(debits) - sum(credits).
  asset,

  /// Credit-increase accounts (credit cards, loans).
  ///
  /// Balance = sum(credits) - sum(debits).
  liability,

  /// Credit-increase accounts (opening balances, retained earnings).
  ///
  /// Balance = sum(credits) - sum(debits).
  equity,

  /// Credit-increase accounts (salary, rent income).
  ///
  /// Balance = sum(credits) - sum(debits).
  income,

  /// Debit-increase accounts (food, transport categories).
  ///
  /// Balance = sum(debits) - sum(credits).
  expense,
}

/// The user-facing type of an account for UI display and grouping.
///
/// This is separate from [AccountNature] which determines accounting behavior.
/// An account's [AccountType] determines which UI group it appears in and what
/// metadata fields are relevant.
enum AccountType {
  /// Physical cash in hand or wallet.
  cash,

  /// Savings account in a bank.
  savings,

  /// Standard bank account (checking/current).
  bankAccount,

  /// Credit card account.
  creditCard,

  /// Loan or debt account.
  loan,

  /// Investment account (e.g., stocks, mutual funds).
  investment,

  /// Insurance policy account.
  insurance,

  /// Digital wallet (e.g., Paytm, GPay).
  wallet,
}

/// The side of a ledger entry in double-entry bookkeeping.
///
/// Every transaction creates at least two ledger entries, and the sum of all
/// debit amounts must equal the sum of all credit amounts.
enum LedgerSide {
  /// Left side of the accounting equation.
  ///
  /// Increases asset and expense accounts; decreases liability, equity, and
  /// income accounts.
  debit,

  /// Right side of the accounting equation.
  ///
  /// Increases liability, equity, and income accounts; decreases asset and
  /// expense accounts.
  credit,
}

/// The direction of money flow for a category.
///
/// Used to filter categories in the UI based on transaction type.
enum CategoryKind {
  /// Represents an expense category (money leaving).
  expense,

  /// Represents an income category (money entering).
  income,
}

/// The type of a financial transaction.
///
/// Determines the structure of ledger entries created for the transaction.
enum TransactionType {
  /// Money leaving an account to an expense category.
  ///
  /// Creates: Debit expense account, Credit source account.
  expense,

  /// Money entering an account from an income category.
  ///
  /// Creates: Debit destination account, Credit income account.
  income,

  /// Money moving between two user-visible accounts.
  ///
  /// Creates: Debit destination account, Credit source account.
  transfer,

  /// Correction of an account balance.
  ///
  /// Creates entries against the Opening Balances equity account.
  adjustment,
}

/// The frequency for recurring transaction patterns.
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

/// The automation type for recurring transaction patterns.
enum RecurringType {
  /// Automatically generates the transaction on the scheduled date.
  automatic,

  /// Sends a reminder to the user to manually create the transaction.
  manualReminder,
}
