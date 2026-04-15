# Section 2: Engineering Problems Cashew Solved (That We Must Solve Too)

**Date:** 2026-04-15
**Author:** Lead Engineer
**Sources:** Reports 01 (Architecture & Data Model), 03 (State Management & Performance), 04 (Feature Engineering)
**Audience:** Founder + Engineering Team

---

## Purpose

Cashew is a production-tested Flutter expense tracker with 46 schema versions and real users. Regardless of its architectural shortcomings, it has solved nine engineering problems that Variance must also solve. This section examines each problem, evaluates Cashew's solution, and defines our recommended approach based on Variance's locked decisions (two-field transaction model, 5 entity schemas, EQ per-currency, 4-state template lifecycle, materialized installments, global search, `exchange_rate_to_home`).

For each problem: the problem statement, Cashew's solution, an honest assessment, and our recommended approach.

---

## 1. Schema Migration Strategy

### The Problem

A personal finance app accumulates irreplaceable user data from day one. Schema changes are inevitable as features evolve -- Cashew went through 46 versions. Every migration must succeed on every user's device, across every possible upgrade path, without data loss. A failed migration on a user's phone means destroyed financial records with no recovery path.

### Cashew's Solution

Two distinct phases of migration coexist in the same codebase.

**Phase 1 (v9-v32):** Manual `addColumn`/`alterTable` calls wrapped in `if (from <= N)` guards with try-catch around every step:

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

**Phase 2 (v33-v46):** Drift's structured `migrationSteps()` API with generated schema snapshots stored in `drift_schemas/` (5,077 lines of generated code in `schema_versions.dart`).

The try-catch-and-continue pattern is critical. When a user imports a backup from a newer schema version, the migration encounters columns that already exist. Instead of crashing, it logs the error and moves on. This is defensive to the point of being sloppy, but it works in production.

They also run data fixups in `beforeOpen` callbacks -- for example, setting default `homePageWidgetDisplay` on all wallets after v42.

### Assessment: Adequate

The defensive try-catch pattern is battle-tested and pragmatic. The dual migration approach (manual + structured) is messy but functional. The absence of migration tests is a real gap -- they rely on the try-catch safety net instead of verifying correctness upfront. The integer-to-UUID PK migration (v36-v37) is a cautionary tale: they had to cast every PK and FK column in every table, touching the entire schema in a single migration step.

### Our Recommended Approach

- Use Drift's `migrationSteps()` API from day one. No manual migration phase.
- Generate schema snapshots for every version and store them in version control.
- Write migration unit tests using Drift's `SchemaVerifier` -- test every version-to-version upgrade path before release.
- Separate schema migrations from data migrations. Schema changes (add column, create table) run first; data backfills (set defaults, transform values) run in `beforeOpen`.
- Design primary keys as UUIDs from the start. Cashew's v36-v37 integer-to-UUID migration was a painful lesson we do not need to repeat.
- Enable `PRAGMA foreign_keys = ON` from v1. Cashew never did this, leading to orphaned records and runtime fixup methods (`fixWandering*`). We enforce referential integrity at the database level.

---

## 2. Multi-Currency Aggregation

### The Problem

A user has accounts in USD, EUR, and INR. The home screen must show a single net worth figure in their home currency. Every summary screen -- budget progress, spending totals, goal tracking -- faces the same challenge: aggregating amounts denominated in different currencies into a single number. The conversion must be correct, reasonably current, and fast enough to render in real-time as streams update.

### Cashew's Solution

Currency is stored at the wallet level. Each wallet has a `currency` string (e.g., `"usd"`, `"eur"`). Exchange rates are fetched from a free CDN (`@fawazahmed0/currency-api`), always relative to USD, and cached in `appStateSettings["cachedCurrencyExchange"]`.

Aggregation uses a **per-wallet loop with USD as pivot**:

```dart
double amountRatioToPrimaryCurrency(AllWallets allWallets, String? walletCurrency) {
  double exchangeRateFromUSDToTarget = getCurrencyExchangeRate(primaryCurrency);
  double exchangeRateFromCurrentToUSD = 1 / getCurrencyExchangeRate(walletCurrency);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}
```

For every total computation:
1. Loop through all wallets
2. Run a separate `SUM(amount)` query per wallet, filtered by `walletFk`
3. Multiply each sum by the exchange rate ratio to the primary currency
4. Merge all per-wallet streams with `StreamZip` and reduce to a single total

This pattern repeats in `watchTotalOfBudget()`, `watchTotalSpentInTimeRangeFromCategories()`, `watchTotalTowardsObjective()`, and virtually every other aggregation method.

Users can override any exchange rate via `appStateSettings["customCurrencyAmounts"]`, and can add custom currencies (crypto) with manually set rates.

### Assessment: Poor

Functionally correct but architecturally expensive. Every summary screen fires N database queries for N wallets. There are no indexes on `walletFk`, so each query does a full table scan. The double floating-point multiplication through a USD pivot compounds rounding errors -- converting CAD to INR goes through two multiplications instead of one. The exchange rates are cached in a `Map<String, dynamic>` inside SharedPreferences with no versioning, no staleness tracking, and no fallback beyond "use whatever was last cached." If the free CDN goes down, rates freeze at whatever was last fetched with no user-visible indication.

### Our Recommended Approach

- Store `exchange_rate_to_home` on every transaction entry at creation time. This is a locked decision. It means aggregation never requires runtime currency conversion -- just `SUM(amount * exchange_rate_to_home)` in a single query across all entries regardless of source currency.
- EQ (equity) entries are per-currency by design. When we need a breakdown by currency before converting to home, the data is already partitioned.
- Maintain a `currency_rates` table with `(from_currency, to_currency, rate, fetched_at)` rows. Track staleness explicitly. Show a visual indicator when rates are older than a configurable threshold (e.g., 24 hours).
- Support user-defined rate overrides at the currency pair level, stored in the database (not SharedPreferences).
- Use direct cross-rates where available; fall back to triangulation through a base currency only when necessary. This reduces compounding rounding errors.
- Index on `walletFk` and any currency-related columns from day one. Cashew's absence of explicit indexes is a performance gap we will not repeat.

---

## 3. Recurring Transaction Materialization

### The Problem

Users have recurring expenses (rent, Netflix, salary) that repeat on a schedule. The app must: (a) show upcoming instances, (b) let users mark them paid/skipped, (c) prevent duplicate instances when the app is opened on multiple devices, and (d) stop generating instances after an end date. The core design question is when and how future instances become real transactions.

### Cashew's Solution

Recurring transactions are **not templates** -- they are real transaction records in the `Transactions` table with `paid: false` and a `type` of `subscription` or `repetitive`. Materialization is lazy (generate-next-on-pay):

1. A recurring transaction starts as `paid: false` with a future `dateCreated`.
2. When the user marks it paid, `createNewSubscriptionTransaction()` generates the **next single future instance** by advancing `dateCreated` by the recurrence interval.
3. The `createdAnotherFutureTransaction` flag prevents duplicate generation.
4. Deterministic key generation via `updatePredictableKey()` prevents sync conflicts:

```dart
String updatePredictableKey(String originalKey) {
  // "abc" -> "abc::predict::1" -> "abc::predict::2" -> ...
}
```

On app launch, `markSubscriptionsAsPaid()` iterates through overdue subscriptions and auto-pays them in a loop (up to 50 iterations), because paying one instance may create the next, which is also overdue.

### Assessment: Adequate

The lazy materialization approach is simple and avoids the complexity of pre-generating hundreds of future instances. The deterministic key generation for sync is clever -- it solves a real problem elegantly. But the model has real downsides: recurring transactions pollute the main `Transactions` table with `paid: false` records that must be filtered out of every aggregation query. The up-to-50-iterations loop for catching up on overdue subscriptions is a blunt instrument. And the lack of a separate template entity means editing the recurrence schedule requires mutating the current unpaid instance, with no history of the original schedule.

### Our Recommended Approach

- Use the locked 4-state template lifecycle: `active`, `paused`, `completed`, `cancelled`. Templates live in their own table, separate from materialized transactions.
- Installments are materialized at creation (locked decision). When a user creates a 12-month installment plan, all 12 instances are generated immediately as pending transactions. This gives the user a complete view of their future obligations.
- For open-ended recurring transactions (no end date), use lazy materialization: generate the next N instances (e.g., 3 months ahead) and generate more as the window advances. This balances visibility with avoiding infinite instance generation.
- Adopt Cashew's deterministic key pattern for sync safety. The `::predict::N` suffix approach is worth borrowing directly.
- Keep templates and instances in separate tables. Templates define the schedule; instances are the materialized transactions. Editing a template's schedule affects only future unmaterialized instances -- already-materialized instances are immutable.

---

## 4. Date and Period Calculations

### The Problem

Budgets, recurring transactions, and spending summaries all need to answer the same question: "What is the current period for this recurring entity?" A monthly budget that started on January 15 needs to know that on April 20, the current period is March 15 - April 14. This sounds trivial but becomes complex with: custom period lengths (every 2 weeks, every 3 months), budgets that started years ago, different recurrence types (daily/weekly/monthly/yearly), and edge cases around month boundaries (January 31 + 1 month = ?).

### Cashew's Solution

The `getBudgetDate()` function in `functions.dart` finds the current budget period by **iterating forward from the start date up to 10,000 times**:

```dart
for (int i = 0; i < 10000; i++) {
  if (currentDate falls within currentDateLoopStart..currentDateLoopEnd) {
    return DateTimeRange(start: currentDateLoopStart, end: ...);
  }
  // Advance the loop window by one period
}
```

For a daily budget that started 3 years ago, this iterates ~1,095 times. For a weekly budget started 5 years ago, ~260 times. The function runs on the main thread, called every time a budget's current period needs to be determined.

Date formatting uses a 50+ entry static list of format strings (`commonDateFormats.dart`) for brute-force parsing during CSV import.

### Assessment: Poor

An O(n) loop where O(1) arithmetic exists is an engineering miss. For monthly recurrence: `periods_elapsed = ((current_year - start_year) * 12 + (current_month - start_month)) / period_length`. For daily: `periods_elapsed = (current_date - start_date).inDays / period_length`. The iterative approach works -- it is not wrong -- but it does unnecessary work on every call with no caching. The 10,000 iteration cap is an arbitrary guard that would fail for a daily budget older than ~27 years, which is unlikely but indicates the author knew the approach was bounded.

### Our Recommended Approach

- Implement period calculation as pure O(1) arithmetic for each recurrence type:
  - **Daily/weekly:** `floor((currentDate - startDate).inDays / periodLengthInDays)`
  - **Monthly:** `floor(monthsBetween(startDate, currentDate) / periodLength)`
  - **Yearly:** `floor(yearsBetween(startDate, currentDate) / periodLength)`
- Handle month-boundary edge cases explicitly (e.g., budget starts Jan 31, next period starts Feb 28/29, then Mar 31). Use `DateTime` month arithmetic with clamping to last day of month.
- Cache the current period result per entity and invalidate on date change (once per midnight, not on every widget build). Cashew recalculates on every render.
- For CSV date parsing, use a ranked list of common formats with early exit on first successful parse, rather than trying all 50+ formats sequentially. Better yet, let the user select the format once and apply it to all rows.

---

## 5. Infinite Scroll and Large List Rendering

### The Problem

A user with 3 years of daily expenses has ~3,000+ transactions. Loading all of them into a `ListView` at once kills both memory and frame rate. The transaction list must support smooth scrolling through thousands of items, grouped by date, with real-time reactive updates as new transactions are added or existing ones are modified.

### Cashew's Solution

Cashew's approach to list rendering is surprisingly naive. Most queries use `DEFAULT_LIMIT = 100000` -- effectively no limit. The main transaction list uses Drift's reactive streams via `StreamBuilder`, which loads the entire result set into memory and rebuilds the widget on every database change.

Only `getTransactionCategoryWithDay()` accepts a genuine `limit` parameter for pagination. There is no cursor-based pagination anywhere in the codebase.

For horizontal date/month selectors, they built `MultiDirectionalInfiniteScroll` -- a bidirectional lazy-loading scroll using two `SliverList`s in a `CustomScrollView` (one growing upward, one growing downward from a center key):

```dart
CustomScrollView(
  center: ValueKey('second-sliver-list'),
  slivers: <Widget>[
    SliverList(/* top items, growing upward */),
    SliverList(/* bottom items, growing downward */),
  ],
)
```

Items load lazily when the user scrolls within 50px of either edge. But this widget is used for date selectors, not for the main transaction list.

All spending summary computation runs synchronously on the main thread. There is exactly one usage of `compute()` (isolate) in the entire codebase -- for line graph point calculation. Everything else (balance calculations, category totals, budget progress) runs inline during widget builds.

### Assessment: Poor

Loading 100,000 transactions into memory via a `StreamBuilder` is a time bomb. It works for users with hundreds of transactions but will degrade visibly at a few thousand. The commented-out code for testing with 35,000+ transactions in `generatePreviewData.dart` suggests they have already encountered this. The `MultiDirectionalInfiniteScroll` widget is well-built but applied to the wrong problem (date selectors instead of the transaction list). The complete absence of background isolates for financial computation means the main thread handles both rendering and number crunching.

### Our Recommended Approach

- Use cursor-based pagination for all transaction lists. Query `LIMIT N+1` with `WHERE dateCreated < :lastSeenDate ORDER BY dateCreated DESC`. The +1 tells us whether more pages exist.
- Use `SliverList` with a builder pattern (`SliverList.builder` or `SliverList.separated`) for all large lists. Never load the full dataset.
- Implement a paging controller that manages: current page, loading state, has-more flag, and error state. Trigger next-page loads when the user scrolls within a threshold of the bottom.
- Group transactions by date in the query layer, not in the widget layer. Return `List<TransactionGroup>` where each group has a date header and a list of transactions. This avoids re-sorting and re-grouping on every rebuild.
- Move financial aggregation to background isolates using `Isolate.run()` (Dart 2.19+) or `compute()`. Balance calculations, category totals, and budget progress should never run on the main thread for datasets above a configurable threshold (e.g., 500 transactions).
- Add database indexes on `(dateCreated)`, `(walletFk, dateCreated)`, and `(categoryFk, dateCreated)` from v1. These are the hot query paths that Cashew left unindexed.

---

## 6. Search Implementation

### The Problem

Users need to find transactions by keyword across all their data -- searching by title ("Starbucks"), note content, category name, amount, or date. Search must be global (locked decision: across all transactions), responsive (results appear as the user types), and handle the combinatorial explosion of filter dimensions (wallet, category, date range, income/expense, paid status, amount range, transaction type).

### Cashew's Solution

Search is SQL `LIKE`-based with no full-text search index. The `onlyShowTransactionBasedOnSearchQuery()` function builds an OR expression across multiple fields:

- Transaction name (title)
- Transaction note
- Category name (via join)
- Subcategory name (via join)
- Budget name (via join)
- Objective name (via join)
- Parsed date text in the search query
- Parsed amount text in the search query

All string matching uses `LIKE '%query%'` with `Collate.noCase`. There is no stemming, no fuzzy matching, no FTS index.

The broader filter system is genuinely well-designed. `SearchFilters` is a serializable class with 15+ filter dimensions, all composable into a single `Expression<bool>` via pure expression builder functions:

```dart
// Filter functions return Expression<bool> values combined with & and |
onlyShowIfFollowsSearchFilters()      // Master filter for SearchFilters objects
onlyShowBasedOnTimeRange()            // Date range filtering
isInCategory()                        // Category include/exclude
onlyShowBasedOnWalletFks()            // Wallet filtering
onlyShowIfNotExcludedFromBudget()     // Budget exclusion
```

Filters are persisted as a custom string format (`key:-:value:-:key:-:value...`) in SharedPreferences.

Search input is debounced at 500ms.

### Assessment: Good (filter system), Adequate (search itself)

The composable filter expression architecture is the best-engineered pattern in Cashew's entire codebase. Every query can accept any combination of filters through pure expression composition. This is a pattern worth adopting directly.

The search itself is adequate for small datasets. `LIKE '%query%'` cannot use indexes and performs a full table scan with string comparison on every row. At 10,000 transactions with joins to categories, subcategories, budgets, and objectives, this will be slow. But for the typical Cashew user (hundreds of transactions), it is fast enough. The 500ms debounce helps.

The custom string serialization format for filter persistence is fragile -- any change to the filter schema requires migration logic for the persisted string.

### Our Recommended Approach

- Adopt Cashew's composable filter expression pattern. Pure `Expression<bool>` builder functions that combine with `&`/`|` are clean, testable, and composable. This is one of the few things Cashew got genuinely right at an architectural level.
- For search: start with `LIKE '%query%'` (same as Cashew) but add SQLite FTS5 as a future optimization path. FTS5 supports prefix matching, ranking, and is dramatically faster for text search on large datasets. The migration from LIKE to FTS5 should be designed as a non-breaking addition (FTS5 virtual table alongside the main table, populated via triggers).
- Debounce search input at 300ms (slightly more aggressive than Cashew's 500ms -- our pagination means results are cheaper to render).
- Serialize filters as JSON, not custom string formats. JSON is self-describing, versionable, and parseable without custom logic.
- Support smart search features Cashew already has: amount range parsing ("50-100"), date parsing ("last week"), and category name matching. These are genuinely useful and differentiate search from a dumb text box.

---

## 7. CSV Import/Export

### The Problem

Users switching from another app or from a spreadsheet need to import their historical data. Users who want to analyze their finances in Excel or back up to a portable format need to export. CSV is the universal interchange format for personal finance data, but every bank, every app, and every spreadsheet uses different column names, date formats, currency conventions, and encoding schemes. Import must handle this variety gracefully.

### Cashew's Solution

**Import** (`importCSV.dart`, 1,318 lines) is a multi-step wizard:

1. File selection with charset auto-detection (`flutter_charset_detector`)
2. Column assignment via header name matching. Auto-detects common column names: `date`/`FormattedDate`/`dateCreated`, `amount`, `category`/`category name`, `title`/`name`, `note`, `wallet`/`account`/`accountName`
3. Date format selection from a list of 50+ format strings or user-provided custom format
4. Preview table showing mapped data before final import

The import creates new categories and wallets on-the-fly if they do not already exist. It uses associated titles (smart autocomplete labels) to auto-categorize when possible. There is also a Google Sheets template flow that skips column assignment.

**Export** (`exportCSV.dart`) is straightforward: user selects optional date range and wallet filters, all matching transactions are fetched with joined category/wallet/budget/objective data, and written as a CSV with 15 columns.

**Database backup/restore** is separate: raw SQLite file export/import with an app restart required after restore.

### Assessment: Good

The import wizard is well-designed UX. The multi-step flow with preview-before-commit protects the user from bad imports. Auto-detection of column names by matching against known aliases is pragmatic and handles the most common cases. Charset auto-detection is a detail most apps miss -- it matters for users with non-ASCII characters in their data.

The brute-force date format approach (50+ formats, try all) is inelegant but functional. The on-the-fly category/wallet creation during import is the right call -- forcing users to pre-create categories before importing would be hostile UX.

The export is adequate but limited: no support for DEB-specific data (entry sides, exchange rates), no metadata about the export format version, and no re-import capability (the export format does not contain enough information to reconstruct the full database state).

### Our Recommended Approach

- Implement a similar multi-step import wizard: file selection, column mapping, date format, preview, commit. This UX pattern is proven.
- Auto-detect column names using a configurable alias map (e.g., `{"date": ["date", "Date", "FormattedDate", "dateCreated", "transaction_date"]}`) stored as a constant, not hardcoded in the import logic.
- For date format detection: let the user pick from a ranked list of common formats, then validate by parsing the first 5 rows. Show parse failures inline so the user can adjust before committing.
- Charset detection is essential -- adopt `flutter_charset_detector` or equivalent.
- On import, create placeholder accounts/categories for unrecognized values (same as Cashew). Mark them with an `imported: true` flag so the user can review and merge them later.
- Design the export format to be round-trippable. Include a header row with a format version identifier. Include all DEB-relevant fields: entry side (debit/credit), exchange rate to home, account type, template reference. This means a Variance export can be re-imported into Variance without data loss.
- Keep database backup/restore as a separate feature (raw SQLite file). This is the nuclear option for full data portability.
- Process import in a background isolate. Cashew's import runs on the main thread; for large CSV files (10,000+ rows), this will freeze the UI.

---

## 8. Chart Rendering

### The Problem

Users need visual summaries of their spending: category breakdowns (pie chart), spending trends over time (line graph), and daily activity heatmaps. Charts must render smoothly, animate gracefully on data changes, handle theme switching (light/dark), and work with multi-currency aggregated data. The chart library must be flexible enough for custom interaction patterns (tap segment to drill down, touch tooltip on line graph) while remaining maintainable.

### Cashew's Solution

All charts are built on `fl_chart`, a popular Flutter charting library. Each chart type is heavily wrapped in custom UI code:

**Pie chart:** Three concentric layers in a `Stack` (chart, frosted glass overlay, solid center). Wrapped in `PinWheelReveal` for a clockwise sweep reveal over 850ms. Segment interaction: tap to expand (radius grows 6-10px). Category badges pop in with sequential 70ms stagger delays and `ElasticOutCurve(0.6)` over 1300ms. Adjacent same-color segments get automatic differentiation via `dynamicPastel` lightening/darkening.

**Line graph:** 2000ms `fastLinearToSlowEaseIn` animation for data transitions. Initial zoom-in effect from a compressed range. Touch tooltips for data point inspection. The point calculation is the only computation in the entire codebase that uses a background isolate:

```dart
// lib/pages/homePage/homePageLineGraph.dart
future: compute(
  calculatePoints,
  CalculatePointsParams(
    transactions: snapshot.data ?? [],
    // ...
  ),
),
```

**Heatmap (GitHub-style):** Fully custom implementation (no library). 18x18px cells with color intensity mapped to spending amount via a 4-bucket range index. Infinite horizontal scroll with month-by-month loading.

**Color handling:** The `dynamicPastel()` function adapts category colors to the current theme -- lightening in light mode, darkening in dark mode -- ensuring chart segments remain readable across themes.

### Assessment: Good

Cashew's chart implementation is one of its strongest features from a UX perspective. The reveal animations (PinWheelReveal, staggered badge pop-in) are delightful without being excessive. The `fl_chart` library choice is sound -- it is well-maintained, supports all three chart types, and offers sufficient customization for personal finance use cases.

The weakness is performance. Only the line graph calculation uses an isolate. Pie chart data preparation (category totals, percentage calculations) and heatmap data aggregation run on the main thread. For a user with thousands of transactions, the category total computation that feeds the pie chart involves the per-wallet-loop aggregation pattern described in Section 2, all running synchronously during a widget build.

The custom heatmap is well-executed but represents significant code to maintain. The 4-bucket color mapping is hardcoded rather than configurable.

### Our Recommended Approach

- Use `fl_chart` as the charting library. It is the de facto standard for Flutter and Cashew has proven it works for this exact use case.
- Charts are deferred to v2 (per PM consolidation report). But when we build them, the data preparation must run in isolates -- not just for line graphs but for all chart types.
- Adopt the animation patterns Cashew got right: staggered category badge reveals, elastic curves for delight moments, smooth data transition animations. These are proven to feel good.
- Adopt the `dynamicPastel()` pattern for theme-adaptive colors. Category colors appearing in charts, entry rows, and selection grids should all pass through a single theme-aware color transformation function.
- For the heatmap: evaluate whether `fl_chart`'s capabilities have expanded to support heatmaps before building a custom implementation. If custom is needed, design it as a standalone reusable widget with configurable bucket count and color scheme.
- Separate chart data preparation from chart rendering. The chart widget receives pre-computed data; the data preparation happens in a repository or use case layer, optionally in an isolate. This makes chart widgets testable with mock data and prevents the "compute on build" anti-pattern.

---

## 9. Platform Abstractions (Android / iOS / Web)

### The Problem

A Flutter finance app targeting Android, iOS, and Web must handle platform differences at multiple layers: database storage (native SQLite vs IndexedDB/localStorage), scroll physics (bouncing on iOS, clamped on Android), UI patterns (Cupertino vs Material navigation bars, tap feedback, header layout), notifications (platform-specific APIs), biometric authentication (Touch ID vs fingerprint vs none on Web), file system access, and in-app purchases (App Store vs Google Play). The abstraction must be clean enough that feature code never branches on platform directly, but flexible enough to preserve platform-native feel.

### Cashew's Solution

Platform abstraction happens at three distinct layers:

**1. Database layer** -- Dart conditional exports:

```dart
// shared.dart
export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';
```

Each platform implements `constructDb()`, `getCurrentDBFileInfo()`, and `overwriteDefaultDB()`. Native uses Drift's `NativeDatabase` with a `MultiExecutor` (foreground reads, background writes). Web uses `DriftWebStorage.indexedDbIfSupported()` with a localStorage fallback that encodes binary to string via a custom `Codec<Uint8List, String>`.

**2. UI layer** -- A `getPlatform()` utility returns `PlatformOS.isIOS`, `PlatformOS.isAndroid`, or web. This is called throughout the codebase to branch UI decisions:

- Page headers: centered/100px on iOS, left-aligned/110-200px on Android
- Bottom nav: `CupertinoTabBar` on iOS, custom `NavigationBar` on Android
- Tap feedback: opacity fade on iOS, Material ripple on Android
- Bottom sheet corners: 10px radius on iOS, 20px on Android
- Scroll physics: `BouncingScrollPhysics` on iOS, `ClampingScrollPhysics` on Android
- Scroll-to-top animation: standard on iOS, `elasticOut` bounce on Android

An `iOSEmulate` debug flag overrides `getPlatform()` for testing.

**3. Feature layer** -- Biometrics disabled on Web. Notification scanning Android-only. High refresh rate setting Android-only. System accent color reading Android 12+ only (with Samsung bug workaround). In-app purchase product IDs differ by platform.

### Assessment: Adequate

The conditional export pattern for the database layer is the canonical Dart approach and is correctly implemented. The UI platform branching via `getPlatform()` is pragmatic and creates a genuinely native feel on each platform -- this is one of Cashew's UX strengths.

The weakness is that platform checks are scattered throughout the codebase rather than centralized. Every widget that cares about platform differences calls `getPlatform()` directly and branches inline. This means platform behavior is not testable in isolation -- you cannot verify "all iOS-specific behaviors" without running the entire app on iOS. The `iOSEmulate` flag is a workaround for this, not a solution.

The Web database fallback (localStorage with binary-to-string encoding) is fragile. localStorage has a ~5MB limit in most browsers; a user with years of transaction data could hit it. The `bin2str` codec is encoding, not encryption -- financial data sits in plain text in the browser's localStorage.

### Our Recommended Approach

- Use Dart conditional exports for the database layer (same as Cashew). This is the right pattern.
- Centralize platform-specific UI decisions into a `PlatformConfig` or `AppTheme` abstraction. Instead of calling `getPlatform()` in 50 different widgets, define platform-specific values (header heights, corner radii, scroll physics, tap feedback widgets) in a single configuration object injected via the widget tree (e.g., through `InheritedWidget` or a provider). Widgets consume the config, not the platform check.
- For Web: use IndexedDB exclusively (no localStorage fallback). Modern browsers all support IndexedDB. If IndexedDB is unavailable, show a clear error rather than silently falling back to a storage mechanism with a 5MB ceiling.
- For biometrics: abstract behind an `AuthGate` interface with platform-specific implementations. The interface exposes `canAuthenticate()`, `authenticate()`, and `isEnabled()`. On Web, `canAuthenticate()` returns false. This avoids scattered `kIsWeb` checks.
- For notifications: abstract behind a `NotificationService` interface. Android implementation uses `flutter_local_notifications` + `notification_listener_service`. iOS uses `flutter_local_notifications` only. Web returns no-ops. Feature code calls the interface, never the platform-specific package.
- Test platform behaviors in isolation. The `PlatformConfig` abstraction means we can inject an iOS config in a test environment regardless of the host platform, verifying that iOS-specific corner radii, physics, and layouts render correctly.

---

## Summary Table

| # | Problem | Cashew Assessment | Our Key Differentiator |
|---|---------|-------------------|----------------------|
| 1 | Schema migration | Adequate | Drift `migrationSteps` from v1, migration tests, UUIDs from start |
| 2 | Multi-currency aggregation | Poor | `exchange_rate_to_home` on every entry; single-query aggregation |
| 3 | Recurring transaction materialization | Adequate | Separate template/instance tables, 4-state lifecycle, materialized installments |
| 4 | Date/period calculations | Poor | O(1) arithmetic, not O(n) iteration |
| 5 | Infinite scroll / large lists | Poor | Cursor-based pagination, isolates for aggregation, proper indexes |
| 6 | Search implementation | Good (filters) / Adequate (search) | Adopt composable filters; add FTS5 as scaling path |
| 7 | CSV import/export | Good | Round-trippable export format, background isolate import |
| 8 | Chart rendering | Good | `fl_chart`, isolate data prep, adopt animation patterns |
| 9 | Platform abstractions | Adequate | Centralized `PlatformConfig`, interface-based feature abstraction |
