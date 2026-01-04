# Unit Tests

This document details the comprehensive unit test suite implemented for the Variance application, covering both the Database Layer and the UI Foundation. All tests are run using `flutter test`.

## 1. UI Foundation Tests
**Location:** [`test/core/theme`](file:///home/rudy/code/variance/test/core/theme)

### Group: Extensions
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `TextSizesExtension` | Verifies the Tailwind-inspired scaling logic. | - `xs`...`xl9` match expected pixel values<br>- `scaleFactor` correctly multiplies base sizes<br>- `lerp` handles transition between factors |
| `SemanticColorsExtension` | Verifies financial color mapping. | - `income` maps to Green (Latte/Mocha dependent)<br>- `expense` maps to Red (Latte/Mocha dependent)<br>- `general` maps to correct accent color |

### Group: Logic (Providers)
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `AppTheme.define` | Verifies theme generation. | - Correct `Brightness`<br>- Extensions are registered<br>- `seedColor` is respected |
| `ThemeProvider` | Verifies state management unit logic. | - `toggleThemeMode` switches System/Light/Dark<br>- `setAccentColor` disables dynamic color<br>- `toggleDynamicColor` updates state |

---

## 2. AccountRepository Tests
**Location:** [`test/features/accounts/data/account_repository_test.dart`](file:///home/rudy/code/variance/test/features/accounts/data/account_repository_test.dart)

### Group: CRUD
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `createAccount adds a new account with correct defaults` | Verifies the creation of an `Accounts` entity. | - ID is returned (not null)<br>- Name, Balance, Type match input<br>- Default `includeInTotals` is `true`<br>- Default `currencyCode` is `'INR'`<br>- Default `isDeleted` is `false` |
| `deleteAccount sets isDeleted to true` | Verifies soft-delete functionality. | - `deleteAccount` sets `isDeleted = true`<br>- `getAccount` still returns the record (for history)<br>- `watchAllAccounts` stream **excludes** the record |
| `watchAllAccounts returns ordered active accounts` | Verifies retrieving the list of accounts. | - Returns list of accounts<br>- Sorted alphabetically by `name` |

### Group: Logic (Auto-Adjustment)
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `Updating name does NOT create an adjustment transaction` | Verifies that purely metadata updates don't trigger financial logic. | - Account name is updated<br>- `Transactions` table remains empty |
| `Increasing balance creates an "Income-like" adjustment` | Verifies logic when user manually increases balance (e.g., finding $10). | - Account balance updated to new value<br>- New `Transaction` created<br>- Type: `adjustment`<br>- `destinationAccountId`: [Account ID]<br>- `sourceAccountId`: `null` |
| `Decreasing balance creates an "Expense-like" adjustment` | Verifies logic when user manually decreases balance (e.g., losing $10). | - Account balance updated to new value<br>- New `Transaction` created<br>- Type: `adjustment`<br>- `destinationAccountId`: `null`<br>- `sourceAccountId`: [Account ID] |

---

## 3. TransactionRepository Tests
**Location:** [`test/features/transactions/data/transaction_repository_test.dart`](file:///home/rudy/code/variance/test/features/transactions/data/transaction_repository_test.dart)

### Group: Double-Entry Validation
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `createTransaction (Expense) reduces source balance` | Standard expense verification. | - Transaction created with amount<br>- Source Account balance: `Original - Amount` |
| `createTransaction (Income) increases destination balance` | Standard income verification. | - Transaction created with amount<br>- Destination Account balance: `Original + Amount` |
| `createTransaction (Transfer) moves money between accounts` | Standard transfer verification. | - Transaction created with amount<br>- Source Account balance: `Original - Amount`<br>- Destination Account balance: `Original + Amount` |

### Group: Cascade/Revert Logic
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `deleteTransaction reverts balance changes` | Verifies undoing a transaction restores balances. | - Transaction row deleted<br>- Affected Account balances revert to pre-transaction values |
| `updateTransaction (Amount Change) adjusts balances correctly` | Verifies modifying a transaction's amount. | - Old balance effect is reverted<br>- New balance effect is applied<br>- Example: Change 100 to 200 -> Balance drops by another 100 |
| `updateTransaction (Account Change) moves balance effect` | Verifies moving a transaction to a different account. | - Old Account balance reverts to original<br>- New Account balance reflects the transaction |

---

## 4. CategoryRepository Tests
**Location:** [`test/features/categories/data/category_repository_test.dart`](file:///home/rudy/code/variance/test/features/categories/data/category_repository_test.dart)

### Group: CRUD
| Test Case | Description | Expected Result |
| :--- | :--- | :--- |
| `createCategory adds category` | Standard creation. | - Category created with Name and Kind (Enum) |
| `watchCategoriesByKind filters correctly` | Verifies filtering by Expense/Income. | - Requesting `Expense` returns ONLY expense categories<br>- Requesting `Income` returns ONLY income categories<br>- **Note:** This test verified the fix for a critical Enum-String cast bug. |
| `deleteCategory soft deletes` | Verifies soft deletion. | - `deleteCategory` sets `isDeleted = true`<br>- Category disappears from `watchAllCategories` |
