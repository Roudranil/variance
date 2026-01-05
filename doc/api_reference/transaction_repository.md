# transaction_repository

## Overview for `TransactionRepository`

### Description

Manages [Transactions] and [LedgerEntries] for double-entry bookkeeping.

 This repository enforces the fundamental DEB invariant: for every
 transaction, sum(debits) = sum(credits). Transactions are immutable once
 created; to "edit" a transaction, the original is voided and a new one is
 created.

### Members

- **_db**: `AppDatabase`
- **_accountRepository**: `AccountRepository`
### Constructors

#### Unnamed Constructor
Creates a new instance of [TransactionRepository].

 Parameters:
 - [db]: The database instance to use.
 - [accountRepository]: The account repository for accessing Opening
   Balances account.



---

## Method: `createExpense`

### Description

Creates an expense transaction.

 An expense represents money leaving a user account to an expense category.

 Ledger entries created:
 - DEBIT: Category's linked account (expense increases)
 - CREDIT: Source account (asset decreases)

 Returns the unique identifier of the created transaction.

 Parameters:
 - [accountId]: The source account (money leaves this account).
 - [categoryId]: The expense category.
 - [amount]: The transaction amount (must be positive).
 - [date]: The date of the transaction.
 - [note]: Optional user note.
 - [externalReference]: Optional external reference (e.g., SMS ID).

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `getLedgerEntries`

### Description

Gets all ledger entries for a transaction.

 Returns a list of [LedgerEntry] objects for the given transaction.

 Parameters:
 - [transactionId]: The unique identifier of the transaction.

### Return Type
`Future<List<LedgerEntry>>`

### Parameters

- `transactionId`: `int`


---

## Method: `createTransfer`

### Description

Creates a transfer transaction between two user accounts.

 A transfer represents money moving from one account to another.

 Ledger entries created:
 - DEBIT: Destination account (receives money)
 - CREDIT: Source account (sends money)

 Returns the unique identifier of the created transaction.

 Parameters:
 - [fromAccountId]: The source account (money leaves).
 - [toAccountId]: The destination account (money enters).
 - [amount]: The transaction amount (must be positive).
 - [date]: The date of the transaction.
 - [note]: Optional user note.
 - [externalReference]: Optional external reference.

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `createAdjustment`

### Description

Creates an adjustment transaction to correct an account balance.

 This creates a transaction against the Opening Balances equity account
 to adjust the balance to the specified target value.

 Returns the unique identifier of the created transaction.

 Parameters:
 - [accountId]: The account to adjust.
 - [newBalance]: The target balance after adjustment.

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`


---

## Method: `voidTransaction`

### Description

Voids a transaction.

 The transaction and its ledger entries remain in the database but are
 excluded from balance calculations and hidden from the UI.

 Parameters:
 - [id]: The unique identifier of the transaction to void.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

## Method: `watchAllTransactions`

### Description

Watches all non-void transactions ordered by date (newest first).

 Returns a [Stream] of [Transaction] lists that updates when data changes.

### Return Type
`Stream<List<Transaction>>`



---

## Method: `getTransaction`

### Description

Gets a single transaction by ID.

 Returns null if the transaction does not exist.

 Parameters:
 - [id]: The unique identifier of the transaction.

### Return Type
`Future<Transaction?>`

### Parameters

- `id`: `int`


---

## Method: `editTransaction`

### Description

Edits a transaction by voiding the original and creating a new one.

 This method implements the void + recreate pattern for immutable ledger
 integrity.

 Returns the unique identifier of the new transaction.

 Parameters:
 - [originalTransactionId]: The transaction to void.
 - [type]: The type of the new transaction.
 - [accountId]: The primary account for the new transaction.
 - [categoryId]: The category (required for expense/income).
 - [secondaryAccountId]: The secondary account (required for transfers).
 - [amount]: The new amount.
 - [date]: The new date.
 - [note]: The new note.

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `createIncome`

### Description

Creates an income transaction.

 An income represents money entering a user account from an income
 category.

 Ledger entries created:
 - DEBIT: Destination account (asset increases)
 - CREDIT: Category's linked account (income increases)

 Returns the unique identifier of the created transaction.

 Parameters:
 - [accountId]: The destination account (money enters this account).
 - [categoryId]: The income category.
 - [amount]: The transaction amount (must be positive).
 - [date]: The date of the transaction.
 - [note]: Optional user note.
 - [externalReference]: Optional external reference (e.g., SMS ID).

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

