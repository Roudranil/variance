# account_repository

## Overview for `AccountRepository`

### Description

Manages [Accounts] entities.

 Responsibilities:
 - Creating new accounts with initial balances.
 - Updating account details (name, type, limits).
 - Watching account balances for the UI.

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor




---

## Method: `deleteAccount`

### Description

Soft deletes an account.

 Parameters:
 - [id]: The ID of the account to delete.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

## Method: `updateAccount`

### Description

Updates an existing account.

 If [currentBalance] is changed, creates an 'adjustment' Transaction.

 Parameters:
 - [account]: The account object with updated values.

### Return Type
`Future<void>`

### Parameters

- `account`: `Account`


---

## Method: `createAccount`

### Description

Creates a new account and persists it to the database.

 The account is initialized with [initialBalance], which is also used as the
 initial value for the current balance.

 Returns the unique identifier of the newly created account.

 Parameters:
 - [name]: The display name of the account.
 - [type]: The type of account.
 - [initialBalance]: The starting balance.
 - [currencyCode]: ISO 4217 currency code. Defaults to `'INR'`.
 - [includeInTotals]: Whether the account is included in net worth totals.
 - [statementDay]: Credit card statement day (1–31).
 - [paymentDueDay]: Credit card payment due day (1–31).
 - [interestRate]: Annual interest rate, if applicable.

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

## Method: `getAccount`

### Description

Gets a single account by ID.

 Parameters:
 - [id]: The ID of the account to fetch.

### Return Type
`Future<Account?>`

### Parameters

- `id`: `int`


---

## Method: `watchAllAccounts`

### Description

Watches all accounts ordered by name.

 Excludes deleted accounts.

### Return Type
`Stream<List<Account>>`



---

