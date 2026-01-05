# integrity

## Overview for `GlobalEquationResult`

### Description

Result of the global accounting equation check.

 Contains the computed totals for each account nature and whether the
 equation holds.

### Members

- **assets**: `double`
  Total of all asset account balances.

- **liabilities**: `double`
  Total of all liability account balances.

- **equity**: `double`
  Total of all equity account balances.

- **income**: `double`
  Total of all income account balances.

- **expenses**: `double`
  Total of all expense account balances.

- **isBalanced**: `bool`
  Whether the accounting equation holds.

 True if Assets = Liabilities + Equity + (Income - Expenses).

### Constructors

#### Unnamed Constructor
Creates a new instance of [GlobalEquationResult].



---

## Overview for `IntegrityService`

### Description

Provides integrity verification functions for double-entry bookkeeping.

 This service validates that the database maintains DEB invariants:
 - Every transaction has balanced ledger entries (sum debits = sum credits)
 - Account balances are correctly computed from ledger entries
 - The global accounting equation holds (Assets = Liabilities + Equity + Net
   Income)

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor
Creates a new instance of [IntegrityService].

 Parameters:
 - [db]: The database instance to use.



---

## Method: `netIncome`

### Description

The net income (Income - Expenses).

### Return Type
`double`



---

## Method: `rhs`

### Description

The right-hand side of the equation (Liabilities + Equity + Net Income).

### Return Type
`double`



---

## Method: `toString`

### Description



### Return Type
`String`



---

## Method: `lhs`

### Description

The left-hand side of the equation (Assets).

### Return Type
`double`



---

## Method: `computeAccountBalance`

### Description

Computes the balance of an account from ledger entries.

 Balance calculation depends on [AccountNature]:
 - ASSET, EXPENSE: balance = sum(debits) - sum(credits)
 - LIABILITY, EQUITY, INCOME: balance = sum(credits) - sum(debits)

 Only non-void transactions are included.

 Returns the computed balance.

 Parameters:
 - [accountId]: The unique identifier of the account.

### Return Type
`Future<double>`

### Parameters

- `accountId`: `int`


---

## Method: `checkAllTransactionsBalance`

### Description

Checks if all non-void transactions are balanced.

 Returns a list of transaction IDs that are NOT balanced. Empty list means
 all transactions are valid.

### Return Type
`Future<List<int>>`



---

## Method: `checkTransactionBalance`

### Description

Checks if a specific transaction is balanced.

 A transaction is balanced when sum(debits) = sum(credits) for all its
 ledger entries.

 Returns true if the transaction is balanced.

 Parameters:
 - [transactionId]: The unique identifier of the transaction.

### Return Type
`Future<bool>`

### Parameters

- `transactionId`: `int`


---

## Method: `computeAllBalances`

### Description

Computes balances for all accounts.

 Returns a map of account ID to computed balance.

### Return Type
`Future<Map<int, double>>`



---

## Method: `canSoftDeleteAccount`

### Description

Checks if an account can be soft-deleted.

 An account can only be deleted if its balance is zero.

 Returns true if the account balance is zero (within tolerance).

 Parameters:
 - [accountId]: The unique identifier of the account.

### Return Type
`Future<bool>`

### Parameters

- `accountId`: `int`


---

## Method: `checkGlobalEquation`

### Description

Checks the global accounting equation.

 The equation: Assets = Liabilities + Equity + (Income - Expenses)

 Returns a [GlobalEquationResult] with the computed values and whether the
 equation holds.

### Return Type
`Future<GlobalEquationResult>`



---

