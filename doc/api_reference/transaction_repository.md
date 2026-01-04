# transaction_repository

## Overview for `TransactionRepository`

### Description

Handles all business logic related to the central ledger [Transactions].

 Responsibilities:
 - CRUD operations for transactions.
 - Enforcing Double-Entry Integrity: Ensures that creating a transaction
   automatically updates the [currentBalance] of related Accounts.

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor




---

## Method: `watchAllTransactions`

### Description

Watches all transactions from the database.

 Ordering: Descending by [transactionDate] (Newest first).

### Return Type
`Stream<List<Transaction>>`



---

## Method: `deleteTransaction`

### Description

Deletes a transaction and reverts its effect on account balances.

 Parameters:
 - [id]: The ID of the transaction to delete.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

## Method: `createTransaction`

### Description

Creates a new transaction record and updates the affected Account balances.

 This is the core Double-Entry operation. It executes in a single atomic database transaction.

 Logic:
 - Expense: [sourceAccountId] is required. Reduces Source Balance by [amount].
 - Income: [destinationAccountId] is required. Increases Dest Balance by [amount].
 - Transfer: Both Accounts required. Reduces Source, Increases Dest.

 Throws an error if required accounts are missing for the given [type].

 Parameters:
 - [amount]: The transaction amount.
 - [type]: The transaction type (expense, income, transfer).
 - [date]: The date of transaction.
 - [sourceAccountId]: ID of source account (required for expense/transfer).
 - [destinationAccountId]: ID of destination account (required for income/transfer).
 - [categoryId]: ID of the category.
 - [description]: Optional description.

### Return Type
`Future<void>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `updateTransaction`

### Description

Updates a transaction.

 Conceptually: Reverts the OLD transaction, then Applies the NEW transaction.

 Parameters:
 - [updatedTransaction]: The transaction object with updated values.

### Return Type
`Future<void>`

### Parameters

- `updatedTransaction`: `Transaction`


---

