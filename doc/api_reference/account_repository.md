# account_repository

## Overview for `AccountRepository`

### Description

Manages [Accounts] entities and computes balances from ledger entries.

 In the DEB system, account balances are computed from [LedgerEntries] rather
 than being stored as cached values. This repository provides methods to
 create accounts, compute their balances, and manage the Opening Balances
 equity account.

### Members

- **_db**: `AppDatabase`
- **openingBalancesAccountName**: `String`
  The name of the system equity account used for opening balances.

### Constructors

#### Unnamed Constructor
Creates a new instance of [AccountRepository].

 Parameters:
 - [db]: The database instance to use.



---

## Method: `_createOpeningBalanceTransaction`

### Description

Creates an opening balance transaction.

 This creates a transaction and ledger entries to establish the initial
 balance of an account using the Opening Balances equity account.

### Return Type
`Future<void>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `getAccountBalance`

### Description

Computes the current balance of an account from ledger entries.

 Balance calculation depends on [AccountNature]:
 - ASSET, EXPENSE: balance = sum(debits) - sum(credits)
 - LIABILITY, EQUITY, INCOME: balance = sum(credits) - sum(debits)

 Only non-void transactions are included in the calculation.

 Returns the computed balance as a [double].

 Parameters:
 - [accountId]: The unique identifier of the account.

### Return Type
`Future<double>`

### Parameters

- `accountId`: `int`


---

## Method: `updateAccount`

### Description

Updates an existing account's metadata.

 This method does NOT allow balance changes. To adjust a balance, use
 [TransactionRepository.createAdjustment].

 Parameters:
 - [account]: The account object with updated values.

### Return Type
`Future<void>`

### Parameters

- `account`: `Account`


---

## Method: `softDeleteAccount`

### Description

Soft deletes an account.

 The account is hidden from the UI but kept for historical integrity.
 This method does NOT check if the balance is zero; call [canSoftDelete]
 first if needed.

 Parameters:
 - [id]: The unique identifier of the account.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

## Method: `createAccount`

### Description

Creates a new user-visible account with an opening balance.

 This method performs the following in a single transaction:
 1. Creates the account record.
 2. If [initialBalance] is non-zero, creates an opening balance transaction
    against the Opening Balances equity account.

 Returns the unique identifier of the newly created account.

 Parameters:
 - [name]: The display name of the account.
 - [type]: The user-facing account type for UI grouping.
 - [nature]: The accounting nature (determines debit/credit behavior).
 - [initialBalance]: The starting balance. Defaults to `0.0`.
 - [currencyCode]: ISO 4217 currency code. Defaults to `'INR'`.
 - [includeInTotals]: Whether to include in net worth. Defaults to `true`.
 - [statementDay]: Credit card statement day (1-31).
 - [paymentDueDay]: Credit card payment due day (1-31).
 - [creditLimit]: Credit card limit.
 - [interestRate]: Annual interest rate.
 - [principal]: Loan principal amount.
 - [installmentAmount]: Loan EMI amount.
 - [nextDueDate]: Loan next payment date.
 - [maturityDate]: Savings/FD maturity date.

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
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `canSoftDelete`

### Description

Checks if an account can be soft-deleted.

 An account can only be deleted if its computed balance is zero.

 Returns true if the account balance is zero (within tolerance).

 Parameters:
 - [accountId]: The unique identifier of the account.

### Return Type
`Future<bool>`

### Parameters

- `accountId`: `int`


---

## Method: `getAccount`

### Description

Gets a single account by ID.

 Returns null if the account does not exist.

 Parameters:
 - [id]: The unique identifier of the account.

### Return Type
`Future<Account?>`

### Parameters

- `id`: `int`


---

## Method: `getOrCreateOpeningBalancesAccount`

### Description

Gets or creates the Opening Balances equity account.

 This is a system account used to balance opening balance transactions.
 It is not visible to users.

 Returns the account ID.

### Return Type
`Future<int>`



---

## Method: `watchAllAccounts`

### Description

Watches all user-visible accounts ordered by name.

 Excludes deleted accounts and system accounts (categories, equity).

 Returns a [Stream] of [Account] lists that updates when data changes.

### Return Type
`Stream<List<Account>>`



---

