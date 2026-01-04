# transaction_repository

## Overview for `TransactionRepository`

### Description

**Transaction Repository**

 Handles all business logic related to the central ledger ([Transactions]).

 **Key Responsibilities:**
 *   CRUD operations for transactions.
 *   **Enforcing Double-Entry Integrity**: Ensures that creating a transaction
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

## Method: `createTransaction`

### Description

**Core Double-Entry Operation**

 Creates a new transaction record AND updates the affected Account balances
 in a single atomic database transaction.

 **Logic:**
 *   **Expense**: [sourceAccountId] is required. Reduces Source Balance by [amount].
 *   **Income**: [destinationAccountId] is required. Increases Dest Balance by [amount].
 *   **Transfer**: Both Accounts required. Reduces Source, Increases Dest.

 Throws an error if required accounts are missing for the given [type].

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

