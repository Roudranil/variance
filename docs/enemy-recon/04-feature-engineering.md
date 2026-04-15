# Cashew Feature Engineering Report

**Subject:** Cashew (open-source Flutter/Dart personal expense tracker)
**Codebase:** ~120K lines of Dart across 245 files
**ORM:** Drift (SQLite), schema version 46
**Date:** 2026-04-15

---

## 1. Transaction System

### 1.1 Data Model

The `Transaction` entity is the central table. Key fields:

| Field | Type | Purpose |
|---|---|---|
| `transactionPk` | `String` (UUID) | Primary key |
| `pairedTransactionFk` | `String?` | FK to paired transfer transaction |
| `name` | `String` (max 250) | Title/description |
| `amount` | `double` | Signed amount (negative = expense, positive = income) |
| `note` | `String` (max 500) | Optional notes |
| `categoryFk` | `String` | FK to category; **"0" = balance correction / transfer** |
| `subCategoryFk` | `String?` | FK to subcategory |
| `walletFk` | `String` | FK to wallet/account (default "0") |
| `dateCreated` | `DateTime` | Transaction date |
| `dateTimeModified` | `DateTime?` | Last modification timestamp (for sync) |
| `originalDateDue` | `DateTime?` | Original due date before marking paid |
| `income` | `bool` | `true` = income, `false` = expense |
| `periodLength` | `int?` | Recurrence period (for subscriptions) |
| `reoccurrence` | `BudgetReoccurence?` | daily/weekly/monthly/yearly |
| `endDate` | `DateTime?` | End date for recurring transactions |
| `type` | `TransactionSpecialType?` | upcoming/subscription/repetitive/credit/debt |
| `paid` | `bool` | Whether the transaction has been "realized" |
| `skipPaid` | `bool` | Whether it was skipped |
| `createdAnotherFutureTransaction` | `bool?` | Prevents duplicate future instance creation |
| `methodAdded` | `MethodAdded?` | email/shared/csv/preview/appLink |
| `objectiveFk` | `String?` | FK to goal/objective |
| `objectiveLoanFk` | `String?` | FK to loan objective |
| `budgetFksExclude` | `List<String>?` | Budgets this transaction is excluded from |
| `sharedKey` | `String?` | Firebase shared key |
| `transactionOwnerEmail` | `String?` | Email of owner (shared budgets) |

### 1.2 Income vs Expense

Cashew uses a **single `income` boolean** on the transaction:
- `income: true` --> the amount is stored as positive
- `income: false` --> the amount is stored as negative (multiplied by -1 at creation)

From `addTransactionPage.dart`:
```dart
amount: (selectedIncome || selectedAmount == 0
    ? (selectedAmount ?? 0).abs()
    : (selectedAmount ?? 0).abs() * -1),
```

The category also has an `income` boolean. When the user selects a category, the transaction's income flag is automatically set to match the category, unless the user is dealing with credit/debt types.

### 1.3 Transfers (Balance Corrections)

There is **no first-class "transfer" transaction type**. Instead, transfers are implemented as a pair of "balance correction" transactions sharing `categoryFk == "0"`:

1. A negative (outflow) transaction on the source wallet
2. A positive (inflow) transaction on the destination wallet
3. Both share the same `dateCreated` (within 1 second) and are linked via `pairedTransactionFk`

The system uses `getCloselyRelatedBalanceCorrectionTransaction()` to find the pair. It first checks `pairedTransactionFk` (explicit link), then falls back to a heuristic: same timestamp within 1 second, `categoryFk == "0"`, opposite `income` flag, same `type`.

Currency conversion for cross-wallet transfers is handled by `getAmountRatioWalletTransferTo()` and `getAmountRatioWalletTransferFrom()`.

**Key insight:** When editing a transfer, the app prompts "Update both transfers?" to keep the pair synchronized. When deleting, it prompts "Delete both transfers?" This is a UI-level concern -- there is no database-level cascade.

### 1.4 Transaction Entry Flow

The `AddTransactionPage` (5,207 lines, the largest file) handles both creation and editing. The flow:

1. **Amount entry** -- a calculator-style input
2. **Income/expense toggle** -- tab selector at the top, with a third "Transfer" tab (optional, togglable in settings)
3. **Category selection** -- grid of category icons, with subcategory drill-down
4. **Title** -- text input with "associated titles" autocomplete (smart labels that auto-assign categories)
5. **Date/time picker**
6. **Additional options** (expandable):
   - Transaction type (Default/Upcoming/Subscription/Repetitive/Borrowed/Lent)
   - Recurrence settings (period + frequency)
   - End date
   - Wallet selection
   - Budget assignment
   - Objective/goal assignment
   - Notes
   - Budget exclusion
   - Payer (for shared budgets)

### 1.5 Corrections/Edits

Editing is done by re-opening `AddTransactionPage` with the existing `Transaction` passed as a parameter. The same `createOrUpdateTransaction` database method is called with `insert: false`. There is no audit trail or history of changes -- the `dateTimeModified` field is updated for sync purposes.

---

## 2. Multi-Currency and Exchange Rates

### 2.1 Architecture

Each **wallet (account)** has its own `currency` field (ISO code string like "usd", "cad"). There is a **primary wallet** tracked in `appStateSettings["selectedWalletPk"]` whose currency serves as the display/home currency.

### 2.2 Exchange Rate Fetching

From `currencyFunctions.dart`:

```dart
Uri url = Uri.parse(
    "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json");
```

- Fetches all exchange rates **relative to USD** from the free fawazahmed0 API
- Stores the entire map in `appStateSettings["cachedCurrencyExchange"]` (a simple key-value map in shared preferences)
- No historical rates -- only latest rates are cached

### 2.3 Conversion Logic

All conversions go through **USD as a pivot currency**:

```dart
double amountRatioToPrimaryCurrency(AllWallets allWallets, String? walletCurrency) {
  double exchangeRateFromUSDToTarget = getCurrencyExchangeRate(primaryCurrency);
  double exchangeRateFromCurrentToUSD = 1 / getCurrencyExchangeRate(walletCurrency);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}
```

So to convert CAD to INR: `CAD --> USD --> INR`. The conversion ratio is applied at query time in the database layer. When aggregating totals across wallets, the system iterates over all wallets, sums each wallet's transactions in its native currency, then multiplies by the conversion ratio to the primary currency.

### 2.4 Custom Exchange Rates

Users can override any exchange rate via `appStateSettings["customCurrencyAmounts"]`. Custom rates take priority over the cached API rates in `getCurrencyExchangeRate()`. Users can also add completely custom currencies (e.g., crypto) with manually set rates. Custom rates are always expressed as "1 USD = X custom-currency" to avoid ambiguity when the primary currency changes.

### 2.5 Multi-Currency Wallets

Wallets do NOT support multiple currencies internally. Each wallet has exactly one currency. Multi-currency is handled by having multiple wallets, each with its own currency. The home page and summaries convert all wallet totals to the primary currency for display.

---

## 3. Recurring Transactions and Subscriptions

### 3.1 Data Model

Recurring transactions are **regular transactions** with special `type` and recurrence fields:

| Type | Meaning |
|---|---|
| `TransactionSpecialType.subscription` | Recurring (auto-pay semantics) |
| `TransactionSpecialType.repetitive` | Recurring (manual-pay semantics) |
| `TransactionSpecialType.upcoming` | One-time future transaction |

Recurrence is configured by:
- `reoccurrence`: daily/weekly/monthly/yearly
- `periodLength`: multiplier (e.g., 2 + monthly = every 2 months)
- `endDate`: optional termination date

### 3.2 Materialization of Future Transactions

This is the most interesting design choice. Future instances are **NOT pre-generated**. Instead:

1. A recurring transaction starts as `paid: false`
2. When its `dateCreated` passes (it becomes overdue), the system can auto-pay it or prompt the user
3. When paid, `createNewSubscriptionTransaction()` generates the **next single future instance** with a new `dateCreated` advanced by the recurrence interval
4. The new instance starts as `paid: false`, and the cycle continues

The next instance's primary key is generated **deterministically** via `updatePredictableKey()`:
```dart
String updatePredictableKey(String originalKey) {
  // "abc" -> "abc::predict::1" -> "abc::predict::2" -> ...
}
```
This prevents duplicates during sync -- if two devices both auto-pay the same subscription, they generate the same next-instance key rather than creating duplicates.

### 3.3 Auto-Pay Logic

On app launch, `markSubscriptionsAsPaid()` iterates through overdue subscriptions and marks them paid if the setting is enabled. It loops recursively (up to 50 iterations) because paying one instance creates the next, which might also be overdue.

Transfer-type recurring transactions (paired balance corrections) are handled by finding matching pairs and keeping them synchronized during auto-pay.

### 3.4 Overdue Handling

Overdue transactions = `paid: false` AND `dateCreated` is before now. The UI shows these in the upcoming/overdue transactions page. Users can:
- **Pay** -- marks paid, creates next instance, records `originalDateDue`
- **Skip** -- marks `skipPaid: true`, creates next instance
- **Un-pay** -- deletes the future instance, resets to unpaid

### 3.5 Occurrence Counting

`countTransactionOccurrences()` counts how many future instances remain until the end date. This is purely a display calculation for showing "x3 remain until Dec 2026".

---

## 4. Budget System

### 4.1 Data Model

The `Budget` table:

| Field | Purpose |
|---|---|
| `budgetPk` | UUID primary key |
| `name` | Budget name |
| `amount` | Budget limit amount |
| `startDate` / `endDate` | Custom range (for custom recurrence) |
| `periodLength` + `reoccurrence` | Recurring period (e.g., 1 month) |
| `categoryFks` | Include-list of categories (null = all) |
| `categoryFksExclude` | Exclude-list of categories |
| `walletFks` | Which wallets contribute (null = all) |
| `income` | `true` = income budget (saving target) |
| `addedTransactionsOnly` | Only count manually-added transactions |
| `budgetTransactionFilters` | Bitmask of filters (include income, debt/credit, balance corrections, etc.) |
| `isAbsoluteSpendingLimit` | Whether it is an absolute spending limit |
| `pinned` | Show on home page |
| `archived` | Hidden but retained |

### 4.2 Budget Categories

Budgets filter transactions by:
1. **Included categories** (`categoryFks`): if set, only these categories count
2. **Excluded categories** (`categoryFksExclude`): if set, all except these count
3. **Budget transaction filters**: a list of `BudgetTransactionFilters` that control:
   - Include income (off by default)
   - Include debt/credit (off by default)
   - Include balance corrections (off by default)
   - Include transactions shared/added to other budgets
   - Include transactions added to objectives

### 4.3 Per-Category Spending Limits

The `CategoryBudgetLimit` table allows setting per-category spending limits within a budget. This is visualized as a spending goal per category within the budget's pie chart view.

### 4.4 Budget Progress Calculation

Progress is calculated by:
1. `watchTotalSpentInEachCategoryInTimeRangeFromCategories()` streams category totals within the budget's date range
2. Category totals are summed and multiplied by `determineBudgetPolarity()` (-1 for expense budgets, 1 for income)
3. The total is compared against the budget amount (converted to primary currency via `budgetAmountToPrimaryCurrency()`)

The budget page shows: a spending graph over time, a pie chart of category breakdown, per-category entries with amounts, and all transactions in the period.

### 4.5 Past Budgets / Budget History

Budgets are **period-based** (recurring). Users can navigate to past periods using `changeSelectedDateRange()` which adjusts the `dateForRangeIndex`. The function `getDatePastToDetermineBudgetDate()` calculates the date range for any past period. Past budget viewing is a **premium feature** (behind a paywall check).

### 4.6 Shared Budgets

Budgets can be shared via Firebase (see Section 7). Shared budget members' transactions are synced to all participants. Members can be filtered by `memberTransactionFilters`.

---

## 5. Search and Filtering

### 5.1 Search Implementation

Search is **SQL LIKE-based** (not full-text search). The `onlyShowTransactionBasedOnSearchQuery()` function builds an OR expression across multiple fields:

```dart
// Searches across:
// - Transaction name (title)
// - Transaction note
// - Category name
// - Subcategory name
// - Budget name (if joined)
// - Objective name (if joined)
// - Parsed date text in search query
// - Parsed amount text in search query
```

All string matching uses `LIKE '%query%'` with `Collate.noCase` for case-insensitive matching. There is no stemming, fuzzy matching, or full-text indexing.

**Smart search features:**
- **Amount search**: If the query looks like a number (e.g., "50" or "50-100"), it also matches transactions by amount range
- **Date search**: If the query contains date-like text, it matches transactions by date
- **Debounced**: Search input uses a 500ms debouncer to avoid excessive queries

### 5.2 Filter System

The `SearchFilters` class provides comprehensive filtering:

| Filter | Type | Description |
|---|---|---|
| `walletPks` | `List<String>` | Filter by wallets |
| `categoryPks` | `List<String>` | Filter by categories |
| `subcategoryPks` | `List<String>?` | Filter by subcategories (null = no subcategory) |
| `budgetPks` | `List<String?>` | Filter by budgets |
| `excludedBudgetPks` | `List<String>` | Exclude specific budgets |
| `objectivePks` | `List<String?>` | Filter by objectives |
| `objectiveLoanPks` | `List<String?>` | Filter by loan objectives |
| `expenseIncome` | `List<ExpenseIncome>` | Income/expense filter |
| `positiveCashFlow` | `bool?` | Positive/negative cash flow |
| `paidStatus` | `List<PaidStatus>` | Paid/not-paid/skipped |
| `transactionTypes` | `List<TransactionSpecialType?>` | Transaction type filter |
| `methodAdded` | `List<MethodAdded?>` | Method of creation |
| `amountRange` | `RangeValues?` | Amount range slider |
| `dateTimeRange` | `DateTimeRange?` | Date range |
| `searchQuery` | `String?` | Free text search |
| `titleContains` | `String?` | Title-specific search |
| `noteContains` | `String?` | Note-specific search |

### 5.3 Filter Persistence

Filters are serialized to a custom string format using `getFilterString()` and deserialized via `loadFilterString()`. The format is `key:-:value:-:key:-:value...`. This string is persisted in `appStateSettings["searchTransactionsSetFiltersString"]` so filters survive across sessions.

### 5.4 Applied Filter Chips

Active filters are displayed as chips below the search bar. Users can tap any chip to open the filter selection popup and clear filters individually or all at once.

---

## 6. Import/Export

### 6.1 CSV Import

The CSV import flow (`importCSV.dart`, 1,318 lines) is a multi-step wizard:

1. **File selection**: User picks a CSV file (with charset auto-detection via `flutter_charset_detector`)
2. **Column assignment**: The system auto-detects columns by matching header names:
   - `date` / `FormattedDate` / `dateCreated`
   - `amount`
   - `category` / `category name` / `categoryName`
   - `title` / `name`
   - `note`
   - `wallet` / `account` / `accountName`
3. **Date format selection**: User selects or provides a custom date format string
4. **Preview and import**: Shows a preview table of mapped data before importing

The import creates new categories/wallets if they do not already exist. It uses associated titles to auto-categorize when possible.

**Google Sheets integration**: There is a separate flow for importing from Google Sheets via a template URL. If the Google Sheets template is used, column assignment is skipped.

### 6.2 CSV Export

The CSV export (`exportCSV.dart`) is simpler:

1. User optionally selects a date range and wallet(s)
2. All matching transactions are fetched with their category, wallet, budget, and objective data
3. Output columns: account, amount, currency, title, note, date, income, type, category name, subcategory name, color, icon, emoji, budget, objective
4. Saved as a `.csv` file with timestamp in the filename

### 6.3 Database Backup (Export)

`exportDB.dart` exports the entire SQLite database file:
1. Calls `backupSettings()` to save current app settings into the DB
2. Streams the raw database file bytes
3. Saves as a `.sql` file

### 6.4 Database Restore (Import)

`importDB.dart` restores from a backup:
1. Shows an overwrite warning popup
2. User picks a `.sql` or `.sqlite` file
3. Cancels any active sync operation
4. Overwrites the default database with the imported file bytes
5. Resets language settings and requires app restart

---

## 7. Cloud Sync

### 7.1 Architecture

Sync uses **Google Drive's appDataFolder** (hidden app-specific storage). Each device uploads its entire database as a sync backup file named `sync-{clientID}.sqlite`.

### 7.2 Sync Process

1. **Upload current state**: `createSyncBackup()` uploads this device's database to Google Drive, replacing any existing file for this client
2. **Download other devices**: `syncData()` finds all `sync-*.sqlite` files from other clients
3. **Diff-based merge**: For each remote database:
   - Opens it as a secondary Drift database
   - Queries all entities modified since the last sync timestamp (`dateTimeModified > lastSynced`)
   - Creates `SyncLog` entries for both updates and deletes
4. **Apply changes**: `database.processSyncLogs()` applies all changes from all remote databases, sorted by timestamp
5. **Update last-synced timestamp** per client

### 7.3 Conflict Resolution

The strategy is **last-writer-wins** based on `dateTimeModified`. When multiple devices modify the same entity, the one with the later `dateTimeModified` overwrites the other. Delete logs are tracked in a separate `DeleteLogs` table with their own timestamps.

### 7.4 Debounced Sync

When `syncEveryChange` is enabled, changes trigger a sync after a 5-second debounce period. There is also a 5-second cooldown timer to prevent rapid re-syncing.

### 7.5 Shared Budgets

Shared budgets use **Firebase Firestore** (separate from the Google Drive sync):
- Budget metadata is stored in a `budgets` Firestore collection
- Transactions are stored in a `transactions` subcollection under each budget
- Members are tracked as email addresses in the budget document
- The owner creates the budget on Firestore; members can be added/removed
- Each member's transactions for that budget are synced bidirectionally

---

## 8. Credit/Debt and Bill Splitting

### 8.1 Credit/Debt Data Model

Credit and debt transactions are regular transactions with `type` set to:
- `TransactionSpecialType.credit` -- money lent to someone (you are owed)
- `TransactionSpecialType.debt` -- money borrowed from someone (you owe)

The `paid` boolean is **inverted for credit/debt**:
- `paid: true` -- the debt/credit is **active** (counts toward totals)
- `paid: false` -- the debt/credit has been **settled** (net zero)

This inversion is intentional. From the code comments:
> "For credit and debts, paid will be true initially, then false when it is received/paid. This is the opposite of what is expected -- but that's because we only want it to count for the totals until it is received/paid off resulting in a net of 0."

### 8.2 One-Time vs Long-Term Loans

Cashew offers two loan models:
1. **One-time loan**: A single credit/debt transaction. Settling it flips `paid` to false.
2. **Long-term loan**: Uses the `Objective` table with `type: ObjectiveType.loan`. Multiple transactions can be linked to the loan via `objectiveLoanFk`. This supports partial payments.

When a user chooses to "partially settle" a one-time loan, it is automatically converted to a long-term loan by creating an `Objective` and migrating the transaction.

### 8.3 Bill Splitting

The bill splitter (`billSplitter.dart`) is a **standalone in-app calculator** that does NOT create database transactions directly:

- **People list**: Users add names (saved in shared preferences)
- **Bill items**: Each item has a name, cost, and list of participants
- **Split modes**: Even split or custom percentage per person
- **Multiplier**: A global multiplier for tips/taxes
- **Summary**: Shows each person's total owed

The data model:
```dart
class BillSplitterItem {
  String name;
  double cost;
  bool evenSplit;
  List<SplitPerson> userAmounts;
}

class SplitPerson {
  String name;
  double? percent;
}
```

All bill splitter data is persisted in shared preferences as JSON, not in the Drift database. The UI shows an error highlight when the total accounted for does not match the total cost.

---

## 9. Net Worth and Financial Summaries

### 9.1 Net Worth Calculation

`HomePageNetWorth` uses `database.watchTotalWithCountOfWallet()` with `isIncome: null` to get the total across all (or selected) wallets.

The calculation:
1. For each wallet, sums all `paid` transactions (using `amount.sum()`)
2. Multiplies each wallet's total by the exchange rate ratio to the primary currency
3. Merges all wallet streams using `StreamZip` and reduces to a single total

The result is a **reactive stream** -- it updates in real-time as transactions change.

By default, balance corrections (transfers) and loan transactions ARE included in net worth (they are only excluded from budgets). The `onlyShowIfOnlyExpenseAndIncome` filter is used by spending summaries but NOT by net worth.

### 9.2 Net Worth Period Filtering

Users can configure the period for net worth display via `PeriodCyclePicker`:
- All time
- Monthly/weekly/yearly cycles
- Custom date range

Settings are persisted with the `NetWorth` cycle extension.

### 9.3 Spending Summary

`HomePageAllSpendingSummary` shows two boxes side-by-side:
- **Expense total**: `isIncome: false` with `onlyIncomeAndExpense: true` (excludes loans and balance corrections)
- **Income total**: `isIncome: true` with `onlyIncomeAndExpense: true`

Both use the same `watchTotalWithCountOfWallet()` method but with the income filter set. Each box links to a filtered `TransactionsSearchPage`.

### 9.4 Multi-Wallet Aggregation Pattern

The aggregation pattern used throughout (net worth, budgets, spending summary) is:

```
for each wallet in allWallets:
    query = SUM(transactions.amount) WHERE wallet_fk = wallet.pk AND filters...
    stream = query.map(sum * exchangeRate(wallet.currency, primaryCurrency))
merge all streams with StreamZip
reduce to single total
```

This per-wallet-then-merge approach ensures correct currency conversion. It produces N database queries for N wallets, all watched as reactive streams.

---

## 10. Auto-Transactions from Email / Notifications

### 10.1 Scanner Templates

The `ScannerTemplate` table defines parsing rules for extracting transaction data from text:

| Field | Purpose |
|---|---|
| `templateName` | Human label for the template |
| `contains` | String that must be present in the message for this template to match |
| `titleTransactionBefore` | Text before the title in the message |
| `titleTransactionAfter` | Text after the title |
| `amountTransactionBefore` | Text before the amount |
| `amountTransactionAfter` | Text after the amount |
| `defaultCategoryFk` | Fallback category if smart matching fails |
| `walletFk` | Target wallet for transactions |
| `ignore` | Skip this template |

### 10.2 Parsing Logic

The parsing is simple **string-boundary extraction**:

```dart
String? getTransactionTitleFromEmail(String messageString,
    String titleTransactionBefore, String titleTransactionAfter) {
  int startIndex = messageString.indexOf(titleTransactionBefore) +
      titleTransactionBefore.length;
  int endIndex = messageString.indexOf(titleTransactionAfter, startIndex);
  title = messageString.substring(startIndex, endIndex);
}
```

Amount parsing strips non-numeric characters: `amountString.replaceAll(RegExp('[^0-9.]'), '')`.

### 10.3 Two Sources

**1. Email scanning (Gmail API)**:
- Requires Google sign-in with Gmail permissions
- On app launch, scans the most recent N emails (configurable, default 10)
- Each email is checked against all scanner templates
- Already-parsed email IDs are tracked in `appStateSettings["EmailAutoTransactions-emailsParsed"]`
- Matched transactions are auto-created with `methodAdded: MethodAdded.email`
- Emails are marked as read after processing

**2. Notification scanning (Android only)**:
- Uses `notification_listener_service` to intercept system notifications
- When a notification is dismissed, its content is parsed against scanner templates
- If matched, opens `AddTransactionPage` pre-filled with parsed data (does NOT auto-create -- requires user confirmation)
- Recent captured notifications are kept in memory for debugging

### 10.4 Category Assignment

For both sources, the system attempts smart category assignment:
1. Uses `getSimilarAssociatedTitles()` to find a matching associated title -> category
2. Falls back to the scanner template's `defaultCategoryFk`
3. For email, if no category is found at all, the transaction is skipped

---

## Architectural Observations for Variance

### Patterns Worth Adopting

1. **Predictable key generation** for recurring transaction instances prevents sync duplicates
2. **Per-wallet stream aggregation** for multi-currency totals is clean and reactive
3. **SearchFilters as a serializable class** with a string persistence format enables filter persistence without schema changes
4. **Scanner templates** for notification/email parsing is a pragmatic approach to automation

### Patterns to Avoid

1. **5,207-line `addTransactionPage.dart`** is a monolithic God-widget. Transaction entry logic, UI, validation, and business rules are all intermingled
2. **No domain layer** -- business logic lives in widgets and the Drift database class directly
3. **Inverted `paid` semantics for credit/debt** is confusing and creates subtle bugs (the code comments acknowledge this)
4. **USD-pivot conversion** means two floating-point multiplications per conversion, compounding rounding errors
5. **No audit trail** for transaction edits -- `dateTimeModified` is for sync, not user-facing history
6. **SharedPreferences for complex state** (bill splitter data, filter strings, cached exchange rates) is fragile
7. **Transfer as paired balance corrections** is implicit -- there is no explicit transfer entity, making it easy for pairs to become orphaned
8. **Last-writer-wins sync** with no real conflict detection -- concurrent edits silently overwrite

### Key Metrics

| Metric | Value |
|---|---|
| Largest file | `addTransactionPage.dart` (5,207 lines) |
| Schema version | 46 (extensive migration history) |
| Tables | 9 (Wallets, Transactions, Categories, CategoryBudgetLimits, AssociatedTitles, Budgets, AppSettings, ScannerTemplates, DeleteLogs, Objectives) |
| Exchange rate source | fawazahmed0 free API (USD-based) |
| Sync mechanism | Google Drive appDataFolder (full DB upload) |
| Shared budgets | Firebase Firestore |
| Recurring strategy | Generate-next-on-pay (lazy materialization) |
| Search | SQL LIKE with no FTS index |
