# schema

## Overview for `Categories`

### Description

Classifies the nature of a transaction (expense or income).

 In double-entry bookkeeping, each category is linked to a hidden nominal
 account. When a user selects a category for a transaction, the system uses
 the [linkedAccountId] to create the corresponding ledger entry.

 Supports infinite hierarchy via [parentId].

### Dependencies

- Table



---

## Overview for `LedgerEntries`

### Description

Immutable journal line items for double-entry bookkeeping.

 Each transaction creates 2 or more ledger entries such that:
 - sum(debits) = sum(credits) for the transaction.

 Entries are never modified or deleted. To "undo" a transaction, the parent
 [Transactions] record is marked as void.

### Dependencies

- Table



---

## Overview for `Accounts`

### Description

This includes user-visible accounts (cash, bank, credit cards) and hidden
 system accounts (category-linked nominal accounts, equity accounts).

 Constraints:
 - [nature] determines debit/credit behavior per accounting rules.
 - [type] is nullable for system accounts (categories, equity).
 - [isUserVisible] controls whether the account appears in the user-facing
   account list.

### Dependencies

- Table



---

## Overview for `Transactions`

### Description

Represents the header of a financial event (immutable).

 The actual money movement is recorded in [LedgerEntries]. A transaction is
 never deleted; instead, it is marked as void via [isVoid].

### Dependencies

- Table



---

## Overview for `Tags`

### Description

Cross-cutting labels for grouping transactions.

 Example: Tag multiple transactions with "Hawaii Trip" to see the total trip
 cost, regardless of whether they are Food, Travel, or Lodging expenses.

### Dependencies

- Table



---

## Overview for `RecurringPatterns`

### Description

Definitions for transactions that repeat over time.

 The system checks [nextRunDate] and creates actual [Transactions] entries
 based on the template fields when due.

### Dependencies

- Table



---

## Overview for `TransactionTags`

### Description

Many-to-many join between [Transactions] and [Tags].

### Dependencies

- Table



---

## Method: `type`

### Description

The user-facing type for UI grouping.

 Nullable for system accounts (category-linked accounts, equity accounts).

### Return Type
`TextColumn`



---

## Method: `externalReference`

### Description

External reference (e.g., SMS ID, bank reference number).

### Return Type
`TextColumn`



---

## Method: `isVoid`

### Description

Soft-delete flag for immutable ledger.

 True = voided transaction (hidden from UI, excluded from balance
 calculations).

### Return Type
`BoolColumn`



---

## Method: `id`

### Description

Primary key.

### Return Type
`IntColumn`



---

## Method: `createdAt`

### Description

Audit timestamp for record creation.

### Return Type
`DateTimeColumn`



---

## Method: `side`

### Description

The side of the entry (DEBIT or CREDIT).

### Return Type
`TextColumn`



---

## Method: `amount`

### Description

The amount (always stored as a positive number).

### Return Type
`RealColumn`



---

## Method: `accountId`

### Description

Foreign key to the account affected.

### Return Type
`IntColumn`



---

## Method: `transactionId`

### Description

Foreign key to the parent transaction.

### Return Type
`IntColumn`



---

## Method: `id`

### Description

Primary key.

### Return Type
`IntColumn`



---

## Method: `interestRate`

### Description

Annual interest rate (as a percentage).

 Applicable to loans and savings accounts.

### Return Type
`RealColumn`



---

## Method: `id`

### Description

Primary key. Auto-incrementing integer.

### Return Type
`IntColumn`



---

## Method: `creditLimit`

### Description

Credit limit amount.

 Applicable only to credit card accounts.

### Return Type
`RealColumn`



---

## Method: `currencyCode`

### Description

ISO 4217 currency code.

 Defaults to 'INR'.

### Return Type
`TextColumn`



---

## Method: `createdAt`

### Description

Audit timestamp for record creation.

### Return Type
`DateTimeColumn`



---

## Method: `maturityDate`

### Description

Maturity date.

 Applicable to fixed deposits and savings accounts.

### Return Type
`DateTimeColumn`



---

## Method: `createdAt`

### Description

Audit timestamp for record creation.

### Return Type
`DateTimeColumn`



---

## Method: `principal`

### Description

Original principal amount.

 Applicable only to loan accounts.

### Return Type
`RealColumn`



---

## Method: `statementDay`

### Description

Statement generation day (1-31).

 Applicable only to credit card accounts.

### Return Type
`IntColumn`



---

## Method: `isDeleted`

### Description

Soft delete flag.

 If true, the account is hidden from the UI but kept for historical
 integrity.

### Return Type
`BoolColumn`



---

## Method: `paymentDueDay`

### Description

Payment due day (1-31).

 Applicable only to credit card accounts.

### Return Type
`IntColumn`



---

## Method: `updatedAt`

### Description

Audit timestamp for last update.

### Return Type
`DateTimeColumn`



---

## Method: `isUserVisible`

### Description

Whether this account is visible in the user-facing account list.

 False for category-linked accounts and system equity accounts.

### Return Type
`BoolColumn`



---

## Method: `includeInTotals`

### Description

Whether to include this account in net worth calculations.

 Defaults to true.

### Return Type
`BoolColumn`



---

## Method: `name`

### Description

The user-defined name for the account.

### Return Type
`TextColumn`



---

## Method: `installmentAmount`

### Description

Monthly installment amount (EMI).

 Applicable only to loan accounts.

### Return Type
`RealColumn`



---

## Method: `nature`

### Description

The fundamental accounting nature.

 Determines whether debits increase or decrease the balance.

### Return Type
`TextColumn`



---

## Method: `nextDueDate`

### Description

Next payment due date.

 Applicable only to loan accounts.

### Return Type
`DateTimeColumn`



---

## Method: `type`

### Description

The type of transaction.

### Return Type
`TextColumn`



---

## Method: `id`

### Description

Primary key.

### Return Type
`IntColumn`



---

## Method: `isDeleted`

### Description

Soft delete flag.

### Return Type
`BoolColumn`



---

## Method: `color`

### Description

UI color (ARGB integer).

### Return Type
`IntColumn`



---

## Method: `name`

### Description

Display name.

### Return Type
`TextColumn`



---

## Method: `userNote`

### Description

Optional user-defined note.

### Return Type
`TextColumn`



---

## Method: `templateAmount`

### Description

Amount to use when creating the transaction.

### Return Type
`RealColumn`



---

## Method: `id`

### Description

Primary key.

### Return Type
`IntColumn`



---

## Method: `automationType`

### Description

Automation type.

 Defaults to 'automatic'.

### Return Type
`TextColumn`



---

## Method: `startDate`

### Description

When this pattern starts.

### Return Type
`DateTimeColumn`



---

## Method: `linkedAccountId`

### Description

Foreign key to the hidden nominal account for DEB.

 This account is created automatically when the category is created.

### Return Type
`IntColumn`



---

## Method: `templateTransactionType`

### Description

Transaction type for the generated transaction.

### Return Type
`TextColumn`



---

## Method: `nextRunDate`

### Description

Pre-calculated next occurrence date.

 Optimization field for efficient querying.

### Return Type
`DateTimeColumn`



---

## Method: `templateCategoryId`

### Description

Category for the transaction.

 Required for expense/income. Null for transfers.

### Return Type
`IntColumn`



---

## Method: `isDeleted`

### Description

Soft delete flag.

### Return Type
`BoolColumn`



---

## Method: `templateSecondaryAccountId`

### Description

Secondary account for transfers.

 The destination account for transfer transactions. Null for
 expense/income.

### Return Type
`IntColumn`



---

## Method: `templateNote`

### Description

Optional note for the generated transaction.

### Return Type
`TextColumn`



---

## Method: `endDate`

### Description

When this pattern ends.

 If null, repeats forever.

### Return Type
`DateTimeColumn`



---

## Method: `interval`

### Description

Multiplier for the frequency.

 Example: frequency = weekly, interval = 2 means "every 2 weeks".

### Return Type
`IntColumn`



---

## Method: `frequency`

### Description

Base frequency unit.

### Return Type
`TextColumn`



---

## Method: `updatedAt`

### Description

Audit timestamp for last update.

### Return Type
`DateTimeColumn`



---

## Method: `transactionId`

### Description

Foreign key to the transaction.

### Return Type
`IntColumn`



---

## Method: `tagId`

### Description

Foreign key to the tag.

### Return Type
`IntColumn`



---

## Method: `primaryKey`

### Description



### Return Type
`Set<Column>`



---

## Method: `transactionDate`

### Description

The date and time the transaction occurred.

### Return Type
`DateTimeColumn`



---

## Method: `kind`

### Description

The direction of flow this category represents.

### Return Type
`TextColumn`



---

## Method: `id`

### Description

Primary key.

### Return Type
`IntColumn`



---

## Method: `createdAt`

### Description

Audit timestamp for record creation.

### Return Type
`DateTimeColumn`



---

## Method: `iconData`

### Description

Icon identifier (codePoint or asset path).

### Return Type
`TextColumn`



---

## Method: `isDeleted`

### Description

Soft delete flag.

### Return Type
`BoolColumn`



---

## Method: `updatedAt`

### Description

Audit timestamp for last update.

### Return Type
`DateTimeColumn`



---

## Method: `color`

### Description

UI color (ARGB integer).

### Return Type
`IntColumn`



---

## Method: `parentId`

### Description

Self-referencing foreign key for sub-categories.

 If null, this is a top-level category.

### Return Type
`IntColumn`



---

## Method: `name`

### Description

Display name (e.g., "Food", "Salary").

### Return Type
`TextColumn`



---

## Method: `templateAccountId`

### Description

Primary account for the transaction.

 For expense: the source account (money leaves).
 For income: the destination account (money enters).
 For transfer: the source account.

### Return Type
`IntColumn`



---

