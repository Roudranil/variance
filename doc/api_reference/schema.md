# schema

## Overview for `Categories`

### Description

Classifies the nature of a transaction (Flow).

 Technically acts as Nominal Accounts in a strict ledger, but here treated as tagging.
 Supports infinite hierarchy via [parentId].

### Dependencies

- Table



---

## Overview for `Accounts`

### Description

Represents the physical or digital storage of money.

 This is the core entity for the Double Entry system.

 Constraints:
 - [type] must be one of [AccountType] values.
 - [currencyCode] defaults to 'INR'.

### Dependencies

- Table



---

## Overview for `Transactions`

### Description

Represents the central ledger of the application.

 Records money moving between accounts (Transfer) or in/out of an account (Income/Expense).

### Dependencies

- Table



---

## Overview for `Tags`

### Description

Defines cross-cutting labels for grouping transactions across categories.

 Example: "Trip 2025" tag on Food, Flight, and Hotel transactions.

### Dependencies

- Table



---

## Overview for `RecurringPatterns`

### Description

Represents definitions for transactions that repeat over time.

 Used by the generator engine to create actual [Transactions] entries.

### Dependencies

- Table



---

## Overview for `TransactionTags`

### Description

Defines the Many-to-Many relationship between [Transactions] and [Tags].

### Dependencies

- Table



---

## Method: `statementDay`

### Description

The day of the month (1-31) when the statement is generated.

 Nullable: Only relevant for [type] == 'creditCard'.

### Return Type
`IntColumn`



---

## Method: `transactionDate`

### Description

The actual date and time the transaction occurred.

### Return Type
`DateTimeColumn`



---

## Method: `description`

### Description

The optional user-defined note.

### Return Type
`TextColumn`



---

## Method: `sourceAccountId`

### Description

The account money is coming FROM.

 Required for: 'expense', 'transfer'.
 Null for: 'income'.

### Return Type
`IntColumn`



---

## Method: `categoryId`

### Description

The classification category.

 Required for: 'expense', 'income'.
 Optional/Null for: 'transfer' (Transfers usually don't need categories).

### Return Type
`IntColumn`



---

## Method: `interestRate`

### Description

The annual Interest Rate (percentage).

 Nullable: Only relevant for loans or savings accounts.

### Return Type
`RealColumn`



---

## Method: `id`

### Description

The primary Key. Auto-incrementing integer.

### Return Type
`IntColumn`



---

## Method: `currencyCode`

### Description

The ISO 4217 Currency Code (e.g., 'INR', 'USD').

 Defaults to 'INR'.

### Return Type
`TextColumn`



---

## Method: `initialBalance`

### Description

The opening balance when the account was created/imported.

### Return Type
`RealColumn`



---

## Method: `type`

### Description

The nature. of the account.

 Used for UI grouping and reporting logic (Net Worth calculation).

### Return Type
`TextColumn`



---

## Method: `id`

### Description



### Return Type
`IntColumn`



---

## Method: `isDeleted`

### Description

The soft Delete flag.

 If true, the account is hidden from the UI but kept for history.

### Return Type
`BoolColumn`



---

## Method: `paymentDueDay`

### Description

The day of the month (1-31) when the payment is due.

 Nullable: Only relevant for [type] == 'creditCard'.

### Return Type
`IntColumn`



---

## Method: `currentBalance`

### Description

The current calculated balance.

 NOTE: This can be derived from [initialBalance] + Sum(Transactions).
 Optimization: We might cache this value here.

### Return Type
`RealColumn`



---

## Method: `includeInTotals`

### Description

Determines if the balances in this account should be included in
 the overall net worth calculation.

### Return Type
`BoolColumn`



---

## Method: `name`

### Description

The user-defined name for the account (e.g., "HDFC Bank", "Wallet").

### Return Type
`TextColumn`



---

## Method: `destinationAccountId`

### Description

The account money is going TO.

 Required for: 'income', 'transfer'.
 Null for: 'expense'.

### Return Type
`IntColumn`



---

## Method: `id`

### Description



### Return Type
`IntColumn`



---

## Method: `isDeleted`

### Description

Soft Delete flag.

### Return Type
`BoolColumn`



---

## Method: `color`

### Description



### Return Type
`IntColumn`



---

## Method: `name`

### Description



### Return Type
`TextColumn`



---

## Method: `createdAt`

### Description

The audit timestamp.

### Return Type
`DateTimeColumn`



---

## Method: `id`

### Description



### Return Type
`IntColumn`



---

## Method: `templateData`

### Description

The template data (amount, accounts, category) to copy when generating the real transaction.

 Stored as a JSON blob.

### Return Type
`TextColumn`



---

## Method: `startDate`

### Description

The date when this pattern starts active.

### Return Type
`DateTimeColumn`



---

## Method: `type`

### Description

The automation type.

### Return Type
`TextColumn`



---

## Method: `name`

### Description

The display name (e.g., "Food", "Salary").

### Return Type
`TextColumn`



---

## Method: `isDeleted`

### Description

Soft Delete flag.

### Return Type
`BoolColumn`



---

## Method: `endDate`

### Description

The date when this pattern stops.

 If null, it repeats forever.

### Return Type
`DateTimeColumn`



---

## Method: `interval`

### Description

The multiplier for the frequency.

 Example: frequency='weekly', interval=2 implies "Every 2 weeks".

### Return Type
`IntColumn`



---

## Method: `frequency`

### Description

The base frequency unit.

### Return Type
`TextColumn`



---

## Method: `type`

### Description

The nature of the transaction.

### Return Type
`TextColumn`



---

## Method: `transactionId`

### Description



### Return Type
`IntColumn`



---

## Method: `tagId`

### Description



### Return Type
`IntColumn`



---

## Method: `primaryKey`

### Description



### Return Type
`Set<Column>`



---

## Method: `amount`

### Description

The absolute magnitude of the money flow.

 NOTE: Always stored as a positive number. Direction is determined by [type] and Accounts.

### Return Type
`RealColumn`



---

## Method: `kind`

### Description

The direction of flow this category represents.

### Return Type
`TextColumn`



---

## Method: `id`

### Description

The primary Key.

### Return Type
`IntColumn`



---

## Method: `iconData`

### Description

The icon identifier (stored as string codePoint or asset path).

### Return Type
`TextColumn`



---

## Method: `isDeleted`

### Description

Soft Delete flag.

### Return Type
`BoolColumn`



---

## Method: `color`

### Description

The UI Color (stored as ARGB integer).

### Return Type
`IntColumn`



---

## Method: `parentId`

### Description

The self-referencing Foreign Key to support sub-categories.

 If null, this is a Top-Level Category.

### Return Type
`IntColumn`



---

## Method: `nextRunDate`

### Description

The pre-calculated date of the next occurrence.

 Optimization field: The engine queries this to find what's due today.

### Return Type
`DateTimeColumn`



---

