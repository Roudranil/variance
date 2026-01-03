# API Overview

This document provides a high-level reference for the internal API, primarily the **Data Layer (Repositories)** which serves as the bridge between the Database and the UI.

## Core Repositories

### 1. AccountRepository
*See `lib/features/accounts/data/account_repository.dart`*

*   `watchAllAccounts()`: Returns a `Stream<List<Account>>` for real-time UI updates.
*   `createAccount(AccountsCompanion)`: Inserts a new account.
*   `updateAccount(Account)`: Updates properties (name, type).

### 2. TransactionRepository
*See `lib/features/transactions/data/transaction_repository.dart`*

This is the most critical component, enforcing the **Double Entry** rules.

*   `watchAllTransactions()`: Real-time list of all transactions, ordered by date.
*   `createTransaction(...)`: **Atomic Operation**.
    *   Inserts the transaction.
    *   Updates `sourceAccount.balance` (if expense/transfer).
    *   Updates `destinationAccount.balance` (if income/transfer).
    *   *Throws error* if logic is violated (e.g., Expense without Source).

### 3. CategoryRepository
*See `lib/features/categories/data/category_repository.dart`*

*   `watchAllCategories()`: Returns all categories.
*   `createCategory(CategoriesCompanion)`: Adds a new category.

## Database Entities (Drift Tables)
*See `lib/database/schema.dart`*

*   `Accounts`: Storage (Bank, Cash).
*   `Categories`: Classification.
*   `Transactions`: The Ledger.
*   `Tags`: Grouping labels.

## Usage Example (UI Layer)

```dart
// Reading a repository
final txRepo = context.read<TransactionRepository>();

// Creating a transaction
await txRepo.createTransaction(
  amount: 500.0,
  type: 'expense',
  date: DateTime.now(),
  sourceAccountId: 1, // Cash
  destinationAccountId: null,
  categoryId: 12, // Food
);
// The UI listening to watchAllAccounts() will automatically update
// to show the Cash balance reduced by 500.
```
