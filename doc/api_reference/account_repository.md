# account_repository

## Overview for `AccountRepository`

### Description

**Account Repository**

 Manages the lifecycle of [Accounts] entities.

 **Responsibilities:**
 *   Creating new accounts with initial balances.
 *   Updating account details (name, type, limits).
 *   Watching account balances for the UI.

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor




---

## Method: `deleteAccount`

### Description

Deletes an account.

 Note: This logic assumes no cascading delete constraints are blocking the deletion.
 If transactions exist, this might fail depending on FK settings.

### Return Type
`Future<int>`

### Parameters

- `id`: `int`


---

## Method: `updateAccount`

### Description

Updates an existing account.

### Return Type
`Future<bool>`

### Parameters

- `account`: `Account`


---

## Method: `createAccount`

### Description

Creates a new account.

### Return Type
`Future<int>`

### Parameters

- `account`: `AccountsCompanion`


---

## Method: `getAccount`

### Description

Gets a single account by ID.

### Return Type
`Future<Account?>`

### Parameters

- `id`: `int`


---

## Method: `watchAllAccounts`

### Description

Watches all accounts ordered by name.

### Return Type
`Stream<List<Account>>`



---

