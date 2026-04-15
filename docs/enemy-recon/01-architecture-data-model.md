# Cashew Architecture & Data Model Intelligence Report

**Date:** 2026-04-15
**Analyst:** Lead Engineering Agent
**Subject:** Cashew (aka "Budget") -- Open-source Flutter personal expense tracker
**Source:** `/Cashew/budget/lib/database/tables.dart` (7,667 lines) and surrounding files
**Audience:** Founder (non-engineer) + Variance Lead Engineer

---

## Executive Summary

Cashew is a mature, feature-rich personal expense tracker built with Flutter and Drift ORM. Its entire data model -- tables, queries, CRUD logic, filtering, sync, and migration -- lives in a single 7,667-line file (`tables.dart`). The app uses a **single-entry bookkeeping** model: every transaction is a signed amount (negative = expense, positive = income) assigned to one category and one wallet (account). There is no double-entry ledger. The codebase is pragmatic but carries significant technical debt from organic growth over 46 schema versions.

**Key takeaway for Variance:** Cashew solved many real-world UX problems (recurring transactions, multi-currency, shared budgets, category autocomplete, balance corrections) but its data model is fundamentally limited compared to our planned DEB architecture. Their weaknesses -- no true transfers, no audit trail, mutable state, monolithic file -- are exactly the problems our design avoids.

---

## 1. Data Model Design

### 1.1 Table Inventory

Cashew has **9 active tables** (plus 1 deleted table, `Labels`, which was removed in schema version 32):

| Table Name | Drift Class | Data Class | Purpose |
|---|---|---|---|
| `Wallets` | `$WalletsTable` | `TransactionWallet` | Accounts/wallets (e.g., "Bank", "Cash", "Bitcoin") |
| `Transactions` | `$TransactionsTable` | `Transaction` | All financial entries -- expenses, income, subscriptions, debts |
| `Categories` | `$CategoriesTable` | `TransactionCategory` | Spending categories with subcategory support |
| `CategoryBudgetLimits` | `$CategoryBudgetLimitsTable` | `CategoryBudgetLimit` | Per-category spending caps within a budget |
| `AssociatedTitles` | `$AssociatedTitlesTable` | `TransactionAssociatedTitle` | Smart auto-complete labels that map keywords to categories |
| `Budgets` | `$BudgetsTable` | `Budget` | Spending envelopes with time periods and filters |
| `Objectives` | `$ObjectivesTable` | `Objective` | Savings goals and loan tracking |
| `AppSettings` | `$AppSettingsTable` | `AppSetting` | Single-row settings store (JSON blob) |
| `ScannerTemplates` | `$ScannerTemplatesTable` | `ScannerTemplate` | Email/notification parsing templates for auto-import |
| `DeleteLogs` | `$DeleteLogsTable` | `DeleteLog` | Tombstone records for cross-device sync |

### 1.2 Table-by-Table Analysis

#### Wallets (Accounts)

**File:** `tables.dart`, lines 250-271

```dart
TextColumn get walletPk => text().clientDefault(() => uuid.v4())();
TextColumn get name => text().withLength(max: NAME_LIMIT)();
TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
TextColumn get iconName => text().nullable()();
DateTimeColumn get dateCreated => dateTime().clientDefault(() => new DateTime.now())();
DateTimeColumn get dateTimeModified => dateTime().withDefault(Constant(DateTime.now())).nullable()();
IntColumn get order => integer()();
TextColumn get currency => text().nullable()();
TextColumn get currencyFormat => text().nullable()();
IntColumn get decimals => integer().withDefault(Constant(2))();
TextColumn get homePageWidgetDisplay => text().nullable()...
```

**Key observations:**
- The "primary wallet" always has PK `"0"` -- hardcoded throughout the codebase.
- Currency is stored as a simple string (e.g., `"usd"`, `"eur"`, `"btc"`), nullable.
- Wallets have no `balance` field. Balance is always computed by summing transactions.
- The `decimals` field (default 2) allows Bitcoin's 7-decimal precision.
- `homePageWidgetDisplay` stores a JSON-encoded list of enum indices for which home page widgets show this wallet.

**Relevance to Variance:** Their wallet is our "Account" entity. We store balance explicitly via DEB ledger entries; they recompute it on every read. Their approach is simpler but slower at scale.

#### Transactions

**File:** `tables.dart`, lines 273-340

This is the **central table** with 27 columns. Here is the full schema:

| Column | Type | Purpose |
|---|---|---|
| `transactionPk` | text (UUID) | Primary key |
| `pairedTransactionFk` | text, nullable, FK to Transactions | Links two sides of a transfer (added in v46) |
| `name` | text(250) | Transaction title |
| `amount` | real | Signed amount. Negative = expense, positive = income |
| `note` | text(500) | Free-text notes |
| `categoryFk` | text, FK to Categories | Required. Category PK `"0"` is reserved for balance corrections |
| `subCategoryFk` | text, nullable, FK to Categories | Optional subcategory |
| `walletFk` | text, FK to Wallets, default `"0"` | Which account this belongs to |
| `dateCreated` | dateTime | When the transaction occurred |
| `dateTimeModified` | dateTime, nullable | Last modification timestamp (for sync) |
| `originalDateDue` | dateTime, nullable | Original due date before payment |
| `income` | bool, default false | Income flag |
| `periodLength` | int, nullable | Recurrence interval length |
| `reoccurrence` | intEnum(BudgetReoccurence), nullable | Recurrence type: daily/weekly/monthly/yearly |
| `endDate` | dateTime, nullable | When recurrence stops |
| `upcomingTransactionNotification` | bool, default true | Whether to notify |
| `type` | intEnum(TransactionSpecialType), nullable | upcoming/subscription/repetitive/credit/debt |
| `paid` | bool, default false | Whether the transaction is settled |
| `createdAnotherFutureTransaction` | bool, nullable | Prevents duplicate future transaction creation |
| `skipPaid` | bool, default false | Marks skipped recurring transactions |
| `methodAdded` | intEnum(MethodAdded), nullable | How it was created: email/shared/csv/preview/appLink |
| `transactionOwnerEmail` | text, nullable | For shared budgets |
| `transactionOriginalOwnerEmail` | text, nullable | For shared budgets |
| `sharedKey` | text, nullable | Firebase key for shared transactions |
| `sharedOldKey` | text, nullable | Previous shared key (when un-sharing) |
| `sharedStatus` | intEnum(SharedStatus), nullable | waiting/shared/error |
| `sharedDateUpdated` | dateTime, nullable | Last shared sync timestamp |
| `sharedReferenceBudgetPk` | text, nullable | Which budget this transaction was explicitly added to |
| `objectiveFk` | text, nullable, FK to Objectives | Savings goal this contributes to |
| `objectiveLoanFk` | text, nullable, FK to Objectives | Loan this contributes to |
| `budgetFksExclude` | text (JSON list), nullable | Budgets this transaction is explicitly excluded from |

**Critical design decisions:**
1. **Signed amount model:** Expenses are negative, income is positive. The `income` boolean is redundant with the sign but is used extensively in filtering. For credit/debt types, the code forces specific sign/income combinations (lines 3454-3459).
2. **No transfer primitive:** Transfers between wallets were not natively supported until v46, which added `pairedTransactionFk`. Even then, a transfer is modeled as two separate transactions linked by FK, not as a first-class transfer entity.
3. **Balance corrections** use the magic category PK `"0"` -- negative corrections get second=30, positive get second=31 to preserve ordering (lines 3465-3475).
4. **Recurring transactions** are templates that spawn copies. When a subscription becomes due, the system creates a new future transaction and marks the old one with `createdAnotherFutureTransaction = true`.

#### Categories

**File:** `tables.dart`, lines 342-373

- Self-referential hierarchy: `mainCategoryPk` is nullable FK to itself. If null, it is a main category; if set, it is a subcategory.
- The `income` flag indicates whether this is an income category (like "Salary").
- Category PK `"0"` is reserved for the **balance correction** virtual category.
- 11 default categories are seeded on first launch (Dining, Groceries, Shopping, Transit, Entertainment, Bills & Fees, Gifts, Beauty, Work, Travel, Income).

#### Budgets

**File:** `tables.dart`, lines 422-475

Budgets are spending envelopes with rich filtering capabilities:

- **Recurrence:** daily/weekly/monthly/yearly/custom period, with `startDate`, `endDate`, `periodLength`.
- **Category filtering:** `categoryFks` (include list), `categoryFksExclude` (exclude list) -- both stored as JSON string arrays.
- **Wallet filtering:** `walletFks` -- which wallets contribute to this budget.
- **Transaction filters:** `budgetTransactionFilters` -- a JSON-encoded list of enum flags controlling which types of transactions count (income, debt/credit, balance corrections, etc.).
- **Sharing:** Full Firebase-backed shared budget support with `sharedKey`, `sharedOwnerMember`, `sharedMembers`, `sharedAllMembersEver`.
- **Added-only mode:** `addedTransactionsOnly` -- when true, only transactions explicitly assigned to this budget count.
- **Absolute vs relative limits:** `isAbsoluteSpendingLimit` toggles between absolute amounts and percentage-based category limits.

#### CategoryBudgetLimits

**File:** `tables.dart`, lines 375-388

A junction table linking categories to budgets with a spending cap:

```dart
TextColumn get categoryLimitPk => text().clientDefault(() => uuid.v4())();
TextColumn get categoryFk => text().references(Categories, #categoryPk)();
TextColumn get budgetFk => text().references(Budgets, #budgetPk)();
RealColumn get amount => real()();
TextColumn get walletFk => text().references(Wallets, #walletPk).withDefault(const Constant("0"))();
```

The `walletFk` here determines which currency the limit amount is denominated in.

#### Objectives (Goals and Loans)

**File:** `tables.dart`, lines 513-539

```dart
IntColumn get type => intEnum<ObjectiveType>().withDefault(Constant(0))();
```

Two types via `ObjectiveType` enum:
- `goal` -- savings target (e.g., "Trip Savings Jar")
- `loan` -- borrowed/lent money tracking (e.g., "Car Payment Loan")

Transactions are linked to objectives via `objectiveFk` (for goals) or `objectiveLoanFk` (for loans). The `income` boolean on the objective determines direction: if `income == true` with type `loan`, it means "lent to someone"; if `income == false`, it means "borrowed from someone".

A special "difference only loan" is indicated by `amount == -1` -- these track the net difference rather than targeting a specific amount.

#### AssociatedTitles (Smart Autocomplete)

**File:** `tables.dart`, lines 394-408

Maps keyword strings to categories. When a user types "pineapple", the system checks if "apple" is in the title and auto-suggests the Food category. The `isExactMatch` flag controls whether substring or exact matching is used.

#### DeleteLogs (Tombstones)

**File:** `tables.dart`, lines 238-248

Soft-delete tracking for cross-device sync. When any entity is deleted, a `DeleteLog` entry is created with the deleted entity's PK and type. During sync, these tombstones tell other devices which records to remove.

**This is NOT soft-delete in the traditional sense.** Records are hard-deleted from their source tables. The `DeleteLog` table serves only as a sync mechanism -- it is the tombstone record that propagates deletions across devices.

#### AppSettings

**File:** `tables.dart`, lines 478-486

A single-row table (PK always `0`) storing all user preferences as a JSON blob in `settingsJSON`. This is also backed by `SharedPreferences` for faster access. The settings JSON contains everything from theme preferences to cached exchange rates.

#### ScannerTemplates

**File:** `tables.dart`, lines 488-511

Templates for parsing financial notifications/emails. Each template has `contains` (trigger text), `titleTransactionBefore/After` (delimiters for extracting the title), and `amountTransactionBefore/After` (delimiters for extracting amounts). Automatically creates transactions from notifications.

### 1.3 Relationship Model

Cashew uses **Drift foreign key references** (`text().references(Table, #column)`) but the relationships are enforced at the ORM level, not with SQLite `FOREIGN KEY` constraints. This means:

- **No cascading deletes.** The application manually handles cascading (e.g., `deleteCategory` at line 4963 explicitly deletes associated titles, transactions, and budget limits before deleting the category).
- **No referential integrity at the DB level.** Orphaned records are possible and the app includes multiple `fixWandering*` methods (lines 5458-5513) to clean up orphaned category budget limits.

**Relationship diagram:**

```
Wallets 1---* Transactions
Categories 1---* Transactions (via categoryFk)
Categories 1---* Transactions (via subCategoryFk, nullable)
Categories 1---* Categories (self-ref via mainCategoryPk, nullable -- subcategories)
Categories 1---* AssociatedTitles
Categories 1---* CategoryBudgetLimits
Budgets 1---* CategoryBudgetLimits
Objectives 1---* Transactions (via objectiveFk)
Objectives 1---* Transactions (via objectiveLoanFk)
Transactions 1---1 Transactions (via pairedTransactionFk -- transfers)
```

### 1.4 Soft-Delete vs Hard-Delete

**Hard delete with tombstone logging.** When records are deleted:

1. A `DeleteLog` entry is created with the entry's PK and type (line 2671-2688).
2. The actual record is removed from its table via `delete(...).go()`.
3. During sync, the `DeleteLog` entries are compared with remote devices to propagate deletions.
4. Recently deleted transactions are also cached in-memory (via `addTransactionToRecentlyDeleted`) for undo functionality.

There is no `isDeleted` flag on any table. Deletion is permanent and immediate.

### 1.5 Recurring / Subscription Transactions

Cashew models recurring transactions through the `TransactionSpecialType` enum:

- **`subscription`** -- recurring bills (Netflix, rent). Unpaid subscriptions appear in the "upcoming" section.
- **`repetitive`** -- recurring expenses that repeat automatically.
- **`upcoming`** -- one-time future transactions (not recurring).

The recurrence engine works as follows (from `upcomingTransactionsFunctions.dart`):

1. A recurring transaction is created with `paid = false`, a `type` (subscription/repetitive), `periodLength`, and `reoccurrence` (daily/weekly/monthly/yearly).
2. When the user marks it as paid, the system creates a **new future transaction** with the next due date by adding the period offset.
3. The `createdAnotherFutureTransaction` flag prevents duplicate spawning.
4. The `endDate` field stops recurrence after a specified date.
5. The `skipPaid` flag allows users to skip a recurring instance without paying.

**Key insight:** Recurring transactions are not templates -- they are actual transaction records in the `Transactions` table with `paid = false`. This means they show up in queries and must be filtered out of totals using `transactions.paid.equals(true)`.

### 1.6 Multi-Currency Handling

Currency is handled at the **wallet level** -- each wallet has a `currency` string (e.g., `"usd"`, `"eur"`, `"btc"`).

**Exchange rate strategy (from `currencyFunctions.dart`):**
1. Rates are fetched from a free CDN API (`@fawazahmed0/currency-api`), always relative to USD.
2. Rates are cached in `appStateSettings["cachedCurrencyExchange"]`.
3. To convert between any two currencies, the code goes through USD as intermediary:
   - `fromCurrency -> USD -> toCurrency`
   - `ratio = (USD_to_target) * (1 / USD_to_source)`
4. The "primary wallet" (PK `"0"`) determines the display currency for totals.

**How multi-currency totals work:** For every aggregation query, the code **loops through all wallets**, runs a separate sum query per wallet (filtered by `walletFk`), and then multiplies each result by the exchange rate ratio. These per-wallet streams are merged with `StreamZip` (lines 5421-5425). This is visible in virtually every `watchTotal*` method.

**Relevance to Variance:** This per-wallet-loop approach is functionally correct but computationally expensive. Our DEB model with per-currency EQ entries will handle this more elegantly.

---

## 2. Database Architecture

### 2.1 Drift Configuration

**Platform abstraction:** `lib/database/platform/shared.dart` uses conditional exports:

```dart
export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';
```

**Native (mobile/desktop):** Uses `NativeDatabase` with a `MultiExecutor`:
- Foreground executor for reads
- Background executor for writes
- Database file stored in `getApplicationDocumentsDirectory()` as `db.sqlite`

**Web:** Uses `WebDatabase` with `DriftWebStorage.indexedDbIfSupported()`, falling back to `localStorage` with binary-to-string encoding.

**Database singleton:** `lib/struct/databaseGlobal.dart` -- the database instance is a **global `late` variable**:

```dart
late FinanceDatabase database;
late SharedPreferences sharedPreferences;
final uuid = Uuid();
```

No dependency injection. The database is accessed globally throughout the codebase.

### 2.2 Migration Strategy

**Current schema version:** 46

The migration history spans from at least version 9 to version 46, with two distinct migration styles:

**Phase 1 (v9-v32): Manual addColumn/alterTable**

```dart
if (from <= 10) {
  await migrator.alterTable(TableMigration(budgets));
  await migrator.alterTable(TableMigration(categories));
  await migrator.alterTable(TableMigration(wallets));
}
if (from <= 12) {
  await migrator.addColumn(transactions, transactions.createdAnotherFutureTransaction);
}
```

These are wrapped in `if (from <= N)` guards, allowing upgrades from any version to the latest. Each migration step is surrounded by try-catch blocks that print errors but continue execution -- a defensive pattern to handle cases where a user imports a backup from a newer schema version.

**Phase 2 (v33-v46): Drift's `migrationSteps` API**

From v33 onward, they use Drift's structured `migrationSteps()` function with named step callbacks (`from33To34`, `from34To35`, etc.). Each step uses the schema object for type safety.

**Notable migration v36-v37:** A massive PK type migration from integers to text (UUIDs). Every table had its primary key and foreign key columns cast from integer to string:

```dart
await m.alterTable(
  TableMigration(schema.transactions, columnTransformer: {
    schema.transactions.transactionPk: schema.transactions.transactionPk.cast<String>(),
    schema.transactions.categoryFk: schema.transactions.categoryFk.cast<String>(),
    // ...
  }),
);
```

This was likely done to support UUID-based sync across devices.

**Data migrations in `beforeOpen`:** Some migrations include data fixups that run after schema changes, such as:
- Setting default `homePageWidgetDisplay` on all wallets (post v42)
- Migrating `objectiveFk` and `walletFk` to the current selected wallet (post v45)

**Schema version tracking files:** The `drift_schemas/` directory contains JSON schema snapshots for versions 33-46, used by `schema_versions.dart` (5,077 lines of generated code) to support the `migrationSteps()` API.

### 2.3 Indexes

**There are no explicit index definitions** in the Drift table declarations. Drift automatically creates indexes for primary keys, but there are no manual indexes on:
- `transactions.dateCreated` (heavily queried for time ranges)
- `transactions.categoryFk` or `transactions.walletFk` (used in every join)
- `transactions.paid` (filtered in nearly every aggregation)

This is a significant performance gap for large datasets. The commented-out code for testing with 35,000+ transactions (lines 788-828 in `generatePreviewData.dart`) suggests they may have encountered performance issues.

---

## 3. Query Patterns

### 3.1 Query Style: Drift Query Builders (Primarily)

The vast majority of queries use Drift's typed query builder API. There is **one instance of raw SQL** (line 3294-3303) for finding duplicate associated titles:

```dart
await customSelect(
  'SELECT associated_titles.* FROM (SELECT title, category_fk FROM associated_titles GROUP BY title, category_fk HAVING COUNT(*) >= 2) T1 JOIN ...',
  readsFrom: {associatedTitles},
)
```

And one more raw SQL query for finding duplicate category budget limits (line 5496-5505).

### 3.2 The Filter Expression Architecture

The most sophisticated part of the codebase is the **composable filter expression system** (lines 5773-6456). Every list/total query accepts a broad set of filter parameters and composes them into a single `Expression<bool>`:

**Core filter functions:**

| Function | Purpose |
|---|---|
| `onlyShowIfFollowsSearchFilters()` | Master filter for SearchFilters objects (income/expense, paid/unpaid, date range, amount range, title/note search, method added, transaction types, category/wallet/budget/objective PKs) |
| `onlyShowTransactionBasedOnSearchQuery()` | Full-text search across transaction name, note, category name, subcategory name, budget name, objective name, and even date/amount parsing |
| `onlyShowIfFollowsFilters()` | Budget-specific filters (shared, added, income, debt/credit, objectives, balance corrections) |
| `onlyShowBasedOnTimeRange()` | Date range filtering with special handling for custom budgets |
| `onlyShowIfFollowCustomPeriodCycle()` | Handles the user's selected period cycle (all-time, budget cycle, past N days, date range) |
| `isInCategory()` | Category include/exclude list filtering |
| `onlyShowBasedOnWalletFks()` | Wallet-level filtering |
| `onlyShowIfMember()` | Shared budget member filtering |
| `onlyShowIfNotExcludedFromBudget()` | Budget exclusion list filtering |

These functions are **pure expression builders** -- they return `Expression<bool>` values that get combined with `&` (AND) and `|` (OR) operators. This is a well-designed pattern that allows any query to apply any combination of filters.

### 3.3 Aggregation Patterns

**Total computation follows a consistent multi-wallet pattern:**

1. Loop through all wallets in `AllWallets.list`
2. For each wallet, create a `selectOnly` query with `amount.sum(filter: paid.equals(true))`
3. Filter by `walletFk.equals(wallet.walletPk)` plus all other filters
4. Map the result through `amountRatioToPrimaryCurrency()` to convert to primary currency
5. Collect all per-wallet streams into `mergedStreams`
6. Combine with `StreamZip` and reduce via `totalDoubleStream()`

This pattern appears in:
- `watchTotalOfBudget()` (line 6465)
- `watchTotalSpentInTimeRangeFromCategories()` (line 5724)
- `watchTotalSpentInEachCategoryInTimeRangeFromCategories()` (line 6549)
- `watchTotalTowardsObjective()` (line 5650)
- `watchTotalAmountObjectiveLoan()` (line 5627)
- And many more

**Category totals** use a similar pattern but group by `categoryFk` or `subCategoryFk`, returning `List<CategoryWithTotal>` objects.

### 3.4 Streaming vs One-Shot

Cashew uses Drift's **reactive streams** extensively. Most query methods return `Stream<T>` (via `.watch()`) rather than `Future<T>` (via `.get()`). Many methods return **both**:

```dart
(Stream<List<Transaction>>, Future<List<Transaction>>) getAllSubscriptions() {
  final query = select(transactions)...;
  return (query.watch(), query.get());
}
```

This tuple pattern gives callers the choice between reactive updates and one-shot reads.

### 3.5 Pagination

Pagination is minimal. Most queries use a `DEFAULT_LIMIT = 100000` (line 39), which is effectively no limit. Only the `getTransactionCategoryWithDay()` method accepts a `limit` parameter that is genuinely used for pagination. There is no cursor-based pagination.

### 3.6 Batch Operations

Drift's `batch()` API is used extensively for bulk updates, particularly:
- Reordering entities (budgets, categories, wallets, objectives)
- Syncing data from remote devices
- Moving transactions between wallets/categories/objectives

---

## 4. Data Initialization

### 4.1 Default Database Setup

**File:** `lib/database/initializeDefaultDatabase.dart`

On first launch:
1. If no categories exist (and this is not a backup restore), create 11 default categories via `createDefaultCategories()`.
2. If no wallets exist, create a default wallet with PK `"0"`, named via localization key `"default-account-name"`, using the device's default currency.

The default wallet is special -- PK `"0"` is hardcoded throughout the app as the primary wallet. When a user deletes wallet `"0"`, the app promotes another wallet to PK `"0"` via `convertToPrimaryWallet()` (line 5087).

### 4.2 Default Categories

**File:** `lib/struct/defaultCategories.dart`

11 categories with hardcoded PKs `"1"` through `"11"`:

| PK | Name Key | Icon | Income? |
|---|---|---|---|
| 1 | Dining | cutlery.png | No |
| 2 | Groceries | groceries.png | No |
| 3 | Shopping | shopping.png | No |
| 4 | Transit | tram.png | No |
| 5 | Entertainment | popcorn.png | No |
| 6 | Bills & Fees | bills.png | No |
| 7 | Gifts | gift.png | No |
| 8 | Beauty | flower.png | No |
| 9 | Work | briefcase.png | No |
| 10 | Travel | plane.png | No |
| 11 | Income | coin.png | Yes |

Note: PK `"0"` is reserved for the balance correction virtual category (never shown to users as a selectable category).

### 4.3 Preview Data Generation

**File:** `lib/database/generatePreviewData.dart`

A demo mode that creates:
- 3 wallets (Bank/USD, Euros/EUR, Bitcoin/BTC)
- 2 budgets (Vacation, Monthly Spending)
- 2 objectives (Trip Savings Jar, Car Payment Loan)
- ~350 randomized transactions spanning 300 days
- 4 category budget limits
- Named transactions for specific demo scenarios (payroll, subscriptions, etc.)

All preview data uses `methodAdded: MethodAdded.preview` for easy identification and cleanup.

---

## 5. Key Engineering Observations

### 5.1 Strengths

1. **Rich filtering system.** The composable `Expression<bool>` filter architecture is genuinely well-designed. Every query can accept any combination of category, wallet, budget, date range, income/expense, paid status, and search text filters. This is a pattern worth studying.

2. **Practical recurring transaction model.** Their approach of creating actual transaction records for future occurrences (rather than a separate template + instance model) is simple and works well for user-facing features like "upcoming transactions" views.

3. **Multi-currency support.** Though the per-wallet-loop approach is expensive, it correctly handles conversions through a USD intermediary and gracefully handles missing exchange rates.

4. **Sync architecture.** The `DeleteLog` tombstone pattern + `dateTimeModified` timestamps on every table enables last-write-wins cross-device sync via Google Drive SQLite file exchange. This is pragmatic and functional.

5. **Data integrity fixup methods.** The `fixWandering*` and `fixOrder*` methods show realistic battle scars from production -- orphaned records happen, and having cleanup code is necessary.

6. **Defensive migration strategy.** Wrapping every migration step in try-catch and continuing on error means users can import backups from newer versions without crashing. Smart for a solo-developer app.

### 5.2 Weaknesses and Anti-Patterns

1. **God file.** `tables.dart` is 7,667 lines containing table definitions, enums, type converters, helper classes, the database class with ALL queries, ALL CRUD methods, ALL filter expressions, ALL migration logic, and ALL sync processing. This is the single largest anti-pattern in the codebase.

2. **No double-entry bookkeeping.** Transfers between wallets were not supported until v46, and even then they are modeled as paired single-entry transactions. There is no concept of debit/credit sides, no ledger, no audit trail. Balance is always recomputed from transaction sums.

3. **Magic values everywhere.**
   - Wallet PK `"0"` = primary wallet
   - Category PK `"0"` = balance correction
   - Transaction PK `"-1"` = auto-generate (insert mode)
   - Objective amount `-1` = "difference only loan"
   - Transaction second `30` = negative balance correction, `31` = positive

4. **No indexes.** For an app that runs complex multi-join aggregate queries on every home screen refresh, the absence of explicit indexes on `dateCreated`, `categoryFk`, `walletFk`, and `paid` is a significant oversight.

5. **Global mutable state.** The database, SharedPreferences, UUID generator, and all app settings are global `late` variables. This makes testing difficult and creates hidden coupling.

6. **Redundant income flag.** The `income` boolean on transactions is redundant with the sign of `amount`. The code even forces them into alignment for credit/debt types (lines 3454-3459). But they cannot remove it now because it is deeply embedded in filtering logic.

7. **JSON-in-columns pattern.** Lists of category PKs, budget transaction filters, and wallet PKs are stored as JSON-encoded strings in text columns (via `TypeConverter`). This prevents SQL-level querying of these lists -- the app must use string `contains()` checks instead of proper joins.

8. **No foreign key constraints at DB level.** While Drift `references()` generates the right schema, SQLite foreign key enforcement requires `PRAGMA foreign_keys = ON`, which does not appear to be set. The numerous `fixWandering*` cleanup methods confirm that referential integrity violations occur in production.

9. **N+1 query patterns in delete operations.** Deleting a category (line 4963) requires: fetching associated titles, deleting them, fetching category transactions, deleting them, fetching subcategory transactions, un-assigning them, fetching budget limits, deleting them -- all as separate queries.

10. **Exchange rate fetch on startup.** Currency conversion relies on a free CDN that could go offline. The `cachedCurrencyExchange` is the only fallback, stored in app settings.

### 5.3 Problems They Solved That We Must Also Solve

| Problem | Cashew's Solution | Variance Consideration |
|---|---|---|
| Multi-currency totals | Per-wallet query loop with exchange rate multiplication | DEB per-currency EQ entries |
| Recurring transactions | Template-in-place with `paid/createdAnotherFutureTransaction` flags | Need a recurrence engine; consider separate template table |
| Balance corrections | Magic category PK `"0"` with forced timestamp seconds | DEB: explicit balance adjustment entry type |
| Cross-device sync | Delete tombstones + dateTimeModified + Google Drive file sync | Need to design offline-first sync strategy |
| Category autocomplete | AssociatedTitles table with substring matching | Similar approach, possibly with ML enhancement |
| Budget period calculation | Runtime computation of current budget period from start date + recurrence | Same need; our budget model should handle this |
| Transfer between accounts | Paired transactions (v46) | DEB handles this natively as a single double-entry |
| Wandering/orphaned records | Runtime fixup methods that scan and clean | Proper FK constraints + cascading deletes |
| Schema evolution | 46-version migration chain with defensive try-catch | Design for migration from day 1; use Drift's migration testing |

### 5.4 Comparison with Variance DEB Model

| Aspect | Cashew | Variance (Planned) |
|---|---|---|
| **Bookkeeping** | Single-entry (signed amounts) | Double-entry (debit/credit legs) |
| **Balance** | Computed on read (sum of transactions) | Maintained via ledger entries; EQ per currency |
| **Transfers** | Bolt-on via `pairedTransactionFk` | First-class: one transaction, two entries |
| **Currency** | Per-wallet, converted at display time | Per-entry currency; EQ tracks per-currency balances |
| **Audit trail** | None (mutable records, hard delete) | Immutable entries; every change creates new entries |
| **Account types** | Single type ("wallet") | Asset, Liability, Equity, Income, Expense |
| **Categories** | Separate table, FK from transactions | Likely modeled as categorization metadata on entries |
| **Debt/Credit** | Special transaction types with confusing semantics | Modeled naturally as Liability accounts |

**Most significant gap in Cashew:** The single-entry model means there is no mathematical invariant that can be verified. In DEB, `sum(debits) == sum(credits)` always holds, providing a built-in consistency check. Cashew has no equivalent -- a transaction can be silently corrupted (wrong sign, wrong wallet FK) with no detection mechanism.

---

## 6. File Reference Index

| File | Lines | Purpose |
|---|---|---|
| `lib/database/tables.dart` | 7,667 | Entire data model, queries, CRUD, filters, migrations |
| `lib/database/tables.g.dart` | 6,649 | Generated Drift code |
| `lib/database/schema_versions.dart` | 5,077 | Generated schema version definitions (v34-v46) |
| `lib/database/platform/native.dart` | 46 | Native SQLite configuration |
| `lib/database/platform/web.dart` | 162 | Web SQLite/IndexedDB configuration |
| `lib/database/platform/shared.dart` | 14 | Platform conditional export |
| `lib/database/initializeDefaultDatabase.dart` | 52 | Default data seeding |
| `lib/database/generatePreviewData.dart` | 928 | Demo data generation |
| `lib/struct/databaseGlobal.dart` | 8 | Database singleton globals |
| `lib/struct/settings.dart` | ~200+ | Settings initialization and management |
| `lib/struct/defaultCategories.dart` | 141 | Default category definitions |
| `lib/struct/currencyFunctions.dart` | 100+ | Currency conversion logic |
| `lib/struct/syncClient.dart` | 100+ | Google Drive sync client |
| `lib/struct/spendingSummaryHelper.dart` | 80+ | Category total computation helpers |
| `lib/struct/upcomingTransactionsFunctions.dart` | 80+ | Recurring transaction spawning logic |

---

## 7. Conclusions

Cashew is a capable, production-tested expense tracker that has organically grown over 46 schema versions. Its core data model is simple (single-entry bookkeeping with signed amounts) and its query layer is sophisticated (composable filter expressions, reactive streams, multi-currency aggregation).

**For Variance, the key lessons are:**

1. **The filter expression pattern is excellent** -- adopt a similar composable approach for our query layer.
2. **Recurring transactions need a dedicated engine** -- their approach works but creates coupling between the template and the instance.
3. **Multi-currency aggregation is a real performance concern** -- our DEB model's per-currency EQ entries will handle this more efficiently than their per-wallet-loop approach.
4. **Schema migration must be designed for resilience** -- their defensive try-catch pattern is battle-tested and worth emulating.
5. **Avoid the God file pattern** -- our data layer should be organized by domain (accounts, entries, categories, budgets) from day one.
6. **DEB gives us a structural advantage** -- transfers, balance verification, audit trails, and multi-currency are all handled more cleanly by double-entry bookkeeping. This is our core technical moat.
