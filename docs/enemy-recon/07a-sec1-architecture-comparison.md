---
title: "Architecture Comparison: Cashew vs Variance"
status: draft
owner: lead-engineer
date: 2026-04-15
depends_on:
  - docs/enemy-recon/01-architecture-data-model.md
  - docs/enemy-recon/02-ui-ux-animation.md
  - docs/enemy-recon/03-state-management-performance.md
---

# Architecture Comparison: Cashew vs Variance

This document is a side-by-side architectural comparison between Cashew (the open-source Flutter expense tracker we studied) and Variance (our planned system). For each area, the structure is: what Cashew does, what Variance should do, why ours is better, and risks to watch.

Sources: Report 01 (Architecture & Data Model), Report 02 (UI/UX & Animation), Report 03 (State Management & Performance). Variance decisions reference the locked PRD v0.3.0 and all resolved technical clarifications.

---

## 1. Data Model: Single-Entry vs Double-Entry Bookkeeping

### What Cashew Does

Cashew uses **single-entry bookkeeping**. Every financial event is one row in the `Transactions` table with a signed `amount` column: negative for expenses, positive for income. The table has 27 columns and serves as the single source of truth for all financial state. Key structural facts:

- **No ledger entries.** There is no concept of debit/credit sides. A transaction is an atomic signed amount assigned to one wallet and one category.
- **No transfer primitive until v46.** Transfers between wallets were bolted on via `pairedTransactionFk` -- two separate transactions linked by a foreign key. Each side is an independent record that can be edited, deleted, or corrupted independently.
- **Balance is always recomputed.** There is no stored balance on wallets. Every balance read requires summing all transactions for that wallet, filtered by `paid == true`, across the entire table.
- **Magic values replace proper types.** Category PK `"0"` is the balance correction category. Wallet PK `"0"` is the primary wallet. Transaction second `30` means negative correction, `31` means positive. Objective amount `-1` means "difference only loan." These are scattered throughout query and display logic.
- **Redundant income flag.** The `income` boolean is semantically redundant with the sign of `amount`, but it cannot be removed because it is baked into the filtering layer. The code even forces them into alignment for credit/debt types.
- **JSON-in-columns for lists.** Category include/exclude lists, budget transaction filters, and wallet lists are stored as JSON-encoded strings in text columns, preventing SQL-level querying and forcing application-side string `contains()` checks.
- **No referential integrity at DB level.** Drift `references()` annotations generate schema but SQLite `PRAGMA foreign_keys = ON` is never set. Orphaned records occur in production; the app includes `fixWandering*` methods to clean them up at runtime.

The model has 9 active tables. For the full schema, see Report 01 Section 1.

### What Variance Should Do

Variance uses **double-entry bookkeeping (DEB)** with 5 core entity schemas:

| Entity | Role |
|--------|------|
| **Transaction** | The financial event envelope. Two-field classification: `status` (pending/posted/voided) x `purpose` (user/reversal/correction/system). |
| **Entry** | The ledger line. Every transaction produces at least two entries (debit side, credit side). Entries are immutable once posted. |
| **Account** | Typed accounts: Asset, Liability, Equity, Income, Expense. Each account has a currency. |
| **Category** | Categorization metadata on transactions, independent of the accounting model. |
| **Template** | Recurrence templates with a 4-state lifecycle machine, separate from transaction instances. |

Core invariants enforced at the data layer:

- **`sum(debits) == sum(credits)`** for every posted transaction, always. This is the fundamental consistency check that Cashew lacks entirely.
- **EQ per currency.** Equity tracking is per-currency, so multi-currency portfolios do not require runtime exchange rate lookups for balance verification.
- **Correction chains.** Errors are corrected by posting reversal + correction entries, not by mutating the original. The original entry is never changed.
- **Compound groups.** Complex operations (e.g., a multi-leg transfer with fees) are modeled as a single transaction with multiple entry pairs, not as separate paired transactions.
- **Installment materialization at creation.** When a user creates a recurring installment, all future instances are materialized as pending transactions immediately, giving a complete forward-looking ledger view.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **Consistency check** | None. A corrupted amount or wrong wallet FK is silently accepted. | `sum(debits) == sum(credits)` is a hard invariant. Violations are detectable and reportable. | Structural integrity vs hope |
| **Transfers** | Two independent rows linked by FK. Either side can be orphaned, double-edited, or deleted without the other. | One transaction, two (or more) entries. Atomicity is guaranteed at the transaction level. | First-class vs bolt-on |
| **Audit trail** | Mutable records, hard delete, no history. | Immutable entries, correction chains, voided status. Every change is traceable. | Full audit vs none |
| **Account types** | Single "wallet" type. Debt/credit are modeled as special transaction types with confusing semantics (`income` boolean overloaded for "lent to" vs "borrowed from"). | Five account types (A/L/Eq/I/E). Debts are Liability accounts. Income is an Income account. The accounting model matches the domain. | Domain-correct vs hacks |
| **Multi-currency** | Per-wallet currency, totals computed by looping all wallets and converting through USD at display time. | Per-entry currency, EQ per-currency. Balance verification does not require exchange rates. Display-time conversion is still needed for reporting, but the ledger itself is currency-consistent. | O(1) verification vs O(wallets) |
| **Balance reads** | Full table scan (sum of all transactions for a wallet). No indexes on `walletFk` or `paid`. | Balance derivable from entry sums per account. With proper indexes on `account_id` and `status`, this is efficient. Optionally, materialized balance can be maintained. | Indexable vs scan |

### Risks to Watch

1. **Complexity tax.** DEB is inherently more complex than single-entry. Every financial operation requires thinking in debit/credit pairs. The transaction creation UX must hide this complexity completely -- the user should never see the word "debit." If we fail at UX abstraction, we lose the simplicity advantage that made Cashew usable.
2. **Entry volume.** DEB produces at least 2x the row count of single-entry for the same number of user actions. With correction chains and compound groups, the multiplier can be higher. Index strategy and query optimization must be designed from day one, not bolted on.
3. **Migration complexity.** Cashew's 46-version migration chain is a cautionary tale. DEB schemas are more complex, so migration errors are more consequential. We need Drift's migration testing from the start, not as an afterthought.
4. **Over-engineering risk.** Cashew shipped and has real users. Our architectural purity means nothing if we do not ship. The DEB model is the right choice, but we must resist the temptation to build a general-purpose accounting engine when we need a personal expense tracker.

---

## 2. State Management: Global Mutable Map vs Structured Reactive Architecture

### What Cashew Does

Cashew's state management is built on three pillars, none of which are what the Flutter community would consider modern:

**Pillar 1: `appStateSettings` -- a global `Map<String, dynamic>`.**
This is a single mutable map with 170+ key-value pairs covering everything from theme preferences to cached exchange rates. It is loaded from `SharedPreferences` on boot, mutated in-place via `updateSettings()`, and read directly in widget `build()` methods. There is no type safety, no change notification, no reactive subscription. When a setting changes, the caller must explicitly specify which pages need refreshing by passing page index numbers.

**Pillar 2: GlobalKey-based imperative refresh.**
Over 15 `GlobalKey` references point to specific page states (`homePageStateKey`, `transactionsListPageStateKey`, `budgetsListPageStateKey`, etc.). UI updates are triggered by calling `currentState?.refreshState()` on these keys. This is the dominant state management pattern -- not Provider, not streams, but imperative method calls through global references. The day-change detector, for example, calls `refreshState()` on all four main pages every time midnight crosses, detected by a 1-second polling loop.

**Pillar 3: Two `StreamProvider`s and raw `StreamBuilder`s.**
Cashew uses Provider in exactly two places: `StreamProvider<AllWallets>` and `StreamProvider<SelectedWalletPk>`. Everything else uses Drift's reactive streams consumed directly via `StreamBuilder` in widget `build()` methods. There is no ViewModel, no Cubit, no intermediate state layer between the database and the UI.

**The consequences:**
- Business logic is mixed into widgets. The `AddTransactionPage` is 5,207 lines of interleaved UI, validation, state management, and database calls.
- Testing is effectively impossible. You cannot unit-test state transitions without instantiating the entire widget tree, because state lives in widget classes and is accessed through global keys.
- The caller of `updateSettings()` must know the internal page structure to trigger the right refreshes. Change a setting that affects the home page but forget to pass `pagesNeedingRefresh: [0]`? The UI is stale until the user navigates away and back.

### What Variance Should Do

Variance should use a **layered reactive architecture** with clear boundaries:

| Layer | Responsibility | Technology |
|-------|---------------|------------|
| **Presentation** | Widgets observe state, dispatch user actions. No business logic, no direct DB access. | Flutter widgets, `BlocBuilder`/`context.watch` |
| **Application (BLoC/Cubit)** | Manages screen-level state, orchestrates use cases, emits immutable state objects. | `flutter_bloc` with sealed state classes and Freezed |
| **Domain (Use Cases)** | Encapsulates business rules. Enforces DEB invariants (debit == credit), validates transactions, computes balances. | Pure Dart, no Flutter imports |
| **Data (Repositories)** | Abstracts Drift database behind interfaces. Maps DTOs to domain entities at the boundary. | Drift, repository pattern |

**Settings should be a typed, immutable state class** -- not a `Map<String, dynamic>`. Each setting gets a named field with a concrete type. Changes produce a new settings object. A dedicated `SettingsCubit` emits the new state, and all widgets that depend on settings rebuild automatically via `BlocBuilder`. No manual page refresh lists.

**Database reactivity flows through BLoCs, not raw StreamBuilders.** A `TransactionListBloc` subscribes to a Drift stream, transforms the data (filtering, sorting, currency conversion), and emits a `TransactionListState` (loading/loaded/error). The widget only sees the final state object.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **Testability** | Untestable. State lives in widgets, accessed via GlobalKeys. | BLoCs are pure Dart classes with `Stream`-based output. Unit-testable without any UI. | Testable vs untestable |
| **Type safety** | `appStateSettings["someKey"]` returns `dynamic`. Typos compile but crash at runtime. | `settings.state.themeMode` is a typed field. Typos do not compile. | Compile-time vs runtime |
| **Reactivity** | Manual. Caller must know which pages to refresh. Miss one and the UI is stale. | Automatic. BLoC emits new state, all subscribers rebuild. No manual refresh lists. | Reactive vs imperative |
| **Separation of concerns** | None. A single 5,207-line widget file contains UI, business logic, and data access. | Enforced by layer. Presentation cannot import data layer. Domain cannot import Flutter. | Layered vs monolithic |
| **Debugging** | `print()` statements and hope. No state history, no time-travel debugging. | BLoC observer logs every state transition. Replay, inspect, and diagnose. | Observable vs opaque |
| **Scalability** | Adding a new setting requires updating a flat map, remembering to pass page indices, and hoping nothing breaks. | Adding a new setting is adding a field to a Freezed class. The compiler catches all missing cases. | Structured vs fragile |

### Risks to Watch

1. **BLoC boilerplate.** BLoC/Cubit with Freezed state classes produces more files and more ceremony than a global map. The tradeoff is worth it for testability and safety, but we must establish code generation templates (Freezed + BLoC) early so the boilerplate is automated, not hand-written.
2. **Over-abstraction.** Cashew's approach, for all its flaws, is simple to understand. A junior developer can read `appStateSettings["theme"]` and know exactly what is happening. Our layered architecture introduces indirection. We must ensure that the layer boundaries are genuinely useful, not just architectural theatre. If a BLoC just passes data through without transformation, it should be eliminated.
3. **Stream management.** Drift streams + BLoC streams + UI subscriptions create a stream pipeline that must be carefully managed to avoid memory leaks and redundant rebuilds. We need explicit subscription lifecycle management in every BLoC, and we need to test for leaks.
4. **Migration from prototype.** If we start with a simpler state management approach during early prototyping and plan to "upgrade" to BLoC later, the migration will be painful. Better to start with the target architecture from day one, even if it feels heavy for the initial feature set.

---

## 3. Database Layer: Drift Patterns and Migration Strategy

### What Cashew Does

Cashew uses Drift (formerly Moor) as its ORM over SQLite. The implementation is functional but carries 46 schema versions of accumulated debt.

**Single-file monolith.** The entire data layer -- table definitions, enums, type converters, the `FinanceDatabase` class with all queries, all CRUD methods, all filter expressions, all migration logic, and all sync processing -- lives in `tables.dart` at 7,667 lines. The generated code (`tables.g.dart`) adds another 6,649 lines.

**Global singleton, no DI.** The database instance is a module-level `late` global variable: `late FinanceDatabase database;`. It is accessed directly throughout the codebase. There is no repository interface, no dependency injection, no way to swap the database for a test double.

**No explicit indexes.** Despite running complex multi-join aggregate queries on every home screen refresh, there are no manual indexes on `dateCreated`, `categoryFk`, `walletFk`, or `paid` -- the most heavily queried columns. Drift auto-creates PK indexes but nothing else. Commented-out code for testing with 35,000+ transactions suggests they hit performance walls.

**No FK enforcement.** `PRAGMA foreign_keys = ON` is never set. Drift's `references()` annotations define the schema but do not enforce it at runtime. Orphaned records are a known production issue, handled by `fixWandering*` cleanup methods that scan and remove orphans.

**Migration strategy -- two eras:**
- **v9-v32:** Manual `addColumn`/`alterTable` wrapped in `if (from <= N)` guards and try-catch blocks. Defensive: errors are caught and logged but execution continues, allowing users to import backups from newer schema versions without crashing.
- **v33-v46:** Drift's structured `migrationSteps()` API with named step callbacks and type-safe schema objects. The v36-v37 migration was a massive PK type change from integers to text (UUIDs) across every table.

**Query patterns:**
- Drift typed query builders for nearly all queries. Only 2 raw SQL queries in the entire codebase.
- Composable `Expression<bool>` filter system (the strongest part of their data layer). Pure expression builders that combine with `&` and `|` operators, allowing any query to accept any combination of filters.
- Per-wallet aggregation loops: for every total computation, the code loops through all wallets, runs a separate sum query per wallet, multiplies by exchange rate, and merges streams with `StreamZip`. Functionally correct, computationally expensive.
- Reactive streams (`.watch()`) for nearly all reads. Many methods return both `Stream<T>` and `Future<T>` as a tuple.
- Effectively no pagination: `DEFAULT_LIMIT = 100000`.

### What Variance Should Do

**File organization by domain, not by layer.** The data layer should be organized into focused modules:

| Module | Contents |
|--------|----------|
| `data/tables/transactions.dart` | Transaction and Entry table definitions |
| `data/tables/accounts.dart` | Account table definition |
| `data/tables/categories.dart` | Category table definition |
| `data/tables/templates.dart` | Template table definition |
| `data/dao/transaction_dao.dart` | Transaction queries, filters, aggregations |
| `data/dao/account_dao.dart` | Account queries, balance computations |
| `data/dao/category_dao.dart` | Category queries |
| `data/dao/template_dao.dart` | Template lifecycle queries |
| `data/migrations/` | One file per migration step |
| `data/database.dart` | Database class definition, DAO registration, migration orchestration |

No file should exceed 800 lines. The god-file pattern is explicitly prohibited.

**Repository interfaces in the domain layer.** The domain layer defines abstract repository interfaces (`TransactionRepository`, `AccountRepository`, etc.). The data layer implements them with Drift-backed concrete classes. The BLoC layer depends on the interfaces, not the implementations. This enables testing with fakes.

**Dependency injection via Riverpod or get_it.** The database instance is injected, not globally accessed. In tests, a fresh in-memory database is created per test case. No global mutable state.

**Explicit indexes from day one.** Every column that appears in a WHERE clause or JOIN condition gets an index. For our schema, at minimum:
- `entries.account_id` (every balance query)
- `entries.transaction_id` (every entry lookup)
- `transactions.status` (filtering posted/pending/voided)
- `transactions.created_at` (date range queries)
- `transactions.category_id` (category aggregations)
- Composite index on `(account_id, status)` for balance computations

**FK constraints enforced.** `PRAGMA foreign_keys = ON` must be set in the database configuration. Cascading deletes and restrict rules defined per relationship. No orphaned records, no runtime fixup methods.

**Migration strategy:**
- Use Drift's `migrationSteps()` API from v1. No manual `addColumn` calls.
- Schema snapshot files generated for every version via `drift_dev schema dump`.
- Migration tests using Drift's `SchemaVerifier` that test every possible upgrade path.
- Defensive try-catch wrapping (adopted from Cashew) for backup import resilience.
- Data migrations separated from schema migrations.

**Query patterns to adopt and improve:**
- Adopt the composable `Expression<bool>` filter pattern. It is genuinely well-designed.
- Replace per-wallet aggregation loops with single queries that join entries with accounts, grouped by currency. DEB's per-currency EQ means we can sum by account in one query without looping.
- Use cursor-based pagination for transaction lists, not `LIMIT 100000`.
- Use Drift's `.watch()` for reactive queries, consumed by DAOs and surfaced through repositories.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **File organization** | 7,667-line god file | Domain-organized modules, 800 lines max | Maintainable vs unmaintainable |
| **Testability** | Global singleton, no DI, no interfaces | Repository interfaces + DI + in-memory test DBs | Fully testable vs untestable |
| **Data integrity** | No FK enforcement, orphan cleanup at runtime | FK constraints enforced at DB level, cascading rules defined | Guaranteed vs best-effort |
| **Indexes** | None (auto PK only) | Explicit indexes on every queried column from day one | Performant by design vs hope |
| **Multi-currency aggregation** | O(wallets) per-wallet loop with separate queries | O(1) single query with GROUP BY currency/account | Efficient vs brute-force |
| **Migration safety** | Defensive try-catch (good) but no migration tests | Migration tests for every upgrade path + defensive try-catch | Verified vs defensive |
| **Pagination** | `LIMIT 100000` (effectively none) | Cursor-based pagination | Scalable vs bounded |

### Risks to Watch

1. **Drift learning curve.** Drift's type-safe query builder is powerful but has a steeper learning curve than raw SQL. Complex DEB queries (e.g., "sum all posted entries for accounts of type Expense, grouped by category and currency, for the current budget period") will push the limits of the query builder. We may need raw SQL for the most complex aggregations, and that is acceptable.
2. **Generated code volume.** Drift generates substantial code. With 5 entity tables, multiple DAOs, and migration schemas, the generated file volume will be significant. Build times must be monitored. `build_runner` should be configured for incremental builds.
3. **Index maintenance cost.** Every index speeds up reads but slows writes. For a personal expense tracker, reads vastly outnumber writes, so the tradeoff is correct. But we should benchmark write performance with all indexes active to ensure transaction creation stays under our latency budget.
4. **Composable filter complexity.** Cashew's filter system works because it evolved organically. Ours needs to be designed up front to handle DEB-specific filters (by entry side, by account type, by status, by purpose). The filter interface must be extensible without modification to existing filters.

---

## 4. Navigation: FadeIndexedStack vs GoRouter

### What Cashew Does

Cashew uses a **custom imperative navigation system** built on `IndexedStack`:

- The root shell widget (`PageNavigationFramework`) holds all pages in a single `FadeIndexedStack` -- a `LazyIndexedStack` wrapped in a `FadeTransition`.
- 4 primary pages (Home, Transactions, Budgets, More) plus 14 extended pages (Subscriptions, Notifications, All Spending, Accounts, Edit pages, Goals, etc.) are all mounted into this single indexed stack. That is 18 pages alive simultaneously.
- Tab switching changes the visible index. Pages are never destroyed or recreated. `LazyIndexedStack` (from `flutter_lazy_indexed_stack`) delays first build until a page is selected, but once built, the page stays in memory forever.
- Sub-navigation uses `pushRoute()` -- a custom helper that wraps `Navigator.push` with a slide+fade `PageRouteBuilder` (300ms in, 125ms out). There is no named routing, no deep linking, no URL-based navigation.
- Bottom sheet navigation (`openBottomSheet`) uses a forked `sliding_sheet` package. Snap points vary by device aspect ratio.
- The FAB uses `OpenContainerNavigation` (Flutter `animations` package) for a Material container transform: the FAB morphs into the Add Transaction page.

**Platform-adaptive bottom nav bar:**
- On iOS: custom `Row` of icon buttons with `ScaleIn` circular selection indicator. No text labels.
- On Android: forked Material 3 `NavigationBar` with `easeInOutCubicEmphasized` indicator animation. Always shows labels.
- All three primary icons are customizable via long-press -- the user can reassign them to different pages.

**Wide-screen sidebar:** When screen width exceeds 700px, the bottom nav disappears and a collapsible left sidebar appears (270px expanded, 70px collapsed). Collapse animation: 1500ms `easeInOutCubicEmphasized`.

**Key problems:**
- No deep linking. The app cannot be opened to a specific transaction, budget, or page via URL.
- No route-based state restoration. If the app is killed and restarted, navigation state is lost.
- 18 pages in an indexed stack means 18 pages in memory. `LazyIndexedStack` helps first-load but does not help memory after all pages have been visited.
- The forked `sliding_sheet` is vendor-locked. Any upstream bug fixes or Flutter version compatibility updates must be manually ported.

### What Variance Should Do

Variance should use **GoRouter** for declarative, URL-based navigation:

- **3 tabs** (locked decision): the specific tabs are defined in the PRD. Bottom nav bar with GoRouter's `StatefulShellRoute` for tab preservation.
- **Declarative route tree.** Every screen has a named route with a URL path. This enables deep linking from notifications, share intents, and (future) web support.
- **State restoration.** GoRouter integrates with Flutter's state restoration framework. If the app is killed and restarted, the user returns to the same screen.
- **Type-safe route parameters.** GoRouter with `go_router_builder` generates type-safe route classes. No string-based route names, no dynamic parameters without compile-time validation.
- **Bottom sheets as routes, not imperative calls.** Modal bottom sheets should be GoRouter routes (via `showModalBottomSheet` or a custom `Page` implementation), so they participate in the route stack and can be deep-linked to.
- **No forked packages.** Use standard `showModalBottomSheet` or a well-maintained package like `wolt_modal_sheet` instead of a forked `sliding_sheet`.

**Navigation shell architecture:**

```
StatefulShellRoute (preserves tab state)
  +-- Tab 1 route branch
  |     +-- Subroute 1a
  |     +-- Subroute 1b
  +-- Tab 2 route branch
  |     +-- Subroute 2a
  +-- Tab 3 route branch
        +-- Subroute 3a
```

Each tab branch has its own `Navigator`, so pushing a subroute within a tab does not affect the other tabs. Tab state is preserved across switches via `StatefulShellRoute`.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **Deep linking** | None. No named routes, no URL paths. | Every screen addressable by URL. Notifications, share intents, and web all work. | Linkable vs closed |
| **State restoration** | Lost on app kill. | Integrated with Flutter's restoration framework via GoRouter. | Resilient vs fragile |
| **Memory** | 18 pages alive in IndexedStack after all visited. | Only active tab branch + current route in memory. Other tabs preserved but not holding full widget trees. | Bounded vs unbounded |
| **Type safety** | String-based page indices (`changePage(3)`). | Generated route classes with typed parameters (`TransactionRoute(id: txId)`). | Compile-time vs runtime |
| **Bottom sheets** | Forked package, imperative `openBottomSheet()` calls. | Route-based or standard Flutter APIs. No forked dependencies. | Maintainable vs vendor-locked |
| **Wide-screen** | Custom sidebar with manual responsive breakpoints. | GoRouter + responsive shell. Sidebar/bottom-nav swap driven by the same route tree. | Unified vs duplicated |

### Risks to Watch

1. **GoRouter complexity.** GoRouter's declarative API has a learning curve, especially for nested `StatefulShellRoute` with typed parameters. The route tree must be designed carefully up front; restructuring routes later affects deep links and state restoration.
2. **Bottom sheet routing.** Making bottom sheets participate in the GoRouter route stack is not trivial. If the complexity is too high, it is acceptable to use imperative bottom sheets for non-linkable interactions (e.g., quick filters, date pickers) while keeping full-page flows as routes.
3. **Tab count rigidity.** With 3 tabs locked, adding a 4th tab later requires modifying the `StatefulShellRoute` and bottom nav bar. This is a product decision, not a technical limitation, but the architecture should not make it painful.
4. **FAB container transform.** Cashew's `OpenContainer` FAB-to-page morph is a proven delight pattern. GoRouter's `CustomTransitionPage` can replicate this, but it requires custom transition code. We should prototype this early to ensure it works with GoRouter's navigation model.

---

## 5. Theming: Material 3 Approach

### What Cashew Does

Cashew uses Material 3 (`useMaterial3: true`) with `ColorScheme.fromSeed()` as the base, then layers a substantial custom color system on top.

**Theme generation pipeline:**
1. An accent color is stored in `appStateSettings` (user-selectable or system-derived via `system_theme` package on Android 12+).
2. `getColorScheme(brightness)` generates a Material 3 `ColorScheme` from the seed color.
3. `getAppColors()` generates a custom `AppColors` `ThemeExtension` with 14 semantic color tokens.
4. Both are assembled in `generateThemeDataWithExtension()`.

**Custom `AppColors` extension (14 tokens):**
Includes inverted semantic names (`white` returns white in light mode and black in dark mode), income/expense-specific colors (green/red pairs that shift between light and dark), warning orange, star yellow, and a `lightDarkAccent` that lightens or darkens the accent color based on brightness.

**`dynamicPastel()` -- the workhorse function:**
Nearly every colored surface passes through `dynamicPastel()`, which lightens colors in light mode and darkens them in dark mode using `Color.alphaBlend` with white/black overlays. This ensures category colors, chart segments, and accent surfaces all adapt to the current theme without manual per-color tuning.

**Material You support:**
When enabled, background surfaces become tinted with the accent color (91% lightened in light mode, 92% darkened in dark mode). `secondaryContainer` gets further blending for popups and bottom sheets. When disabled, plain whites/blacks.

**Grayscale workaround:**
If the user picks a grayscale accent (R/G/B channels within 15 of each other), the app bypasses `fromSeed()` entirely (which produces ugly results with gray inputs) and uses a hand-crafted `blueGrey` color scheme.

**String-based color lookup:**
Colors are accessed via `getColor(context, "lightDarkAccent")` -- a string-keyed lookup function. No compile-time safety; a typo in the string key fails silently or throws at runtime.

**Fonts:**
User-selectable from 6 options (Avenir, Inter, DMSans, Metropolis, RobotoCondensed, Inconsolata). Inter is the default and fallback.

### What Variance Should Do

**Start with Material 3 `ColorScheme.fromSeed()` -- same as Cashew -- but with a type-safe extension layer:**

- Use `ThemeExtension<VarianceColors>` with an **enum-based or class-based API**, not string keys. Every semantic token is a named getter on the extension class, so `Theme.of(context).extension<VarianceColors>()!.incomeAmount` is compile-time checked.
- Adopt the `dynamicPastel()` concept but implement it as a method on the extension or as a standalone utility with the same signature. This is a genuinely good pattern for making arbitrary colors work across brightness modes.
- Support Material You (dynamic color) via `dynamic_color` package, which is the official Google approach and more robust than Cashew's `system_theme` + manual blending.
- Handle the grayscale edge case: either detect and substitute (like Cashew) or constrain the accent color picker to exclude near-grayscale values.

**Semantic token design:**

| Token | Purpose | Light | Dark |
|-------|---------|-------|------|
| `surface` | Page backgrounds | M3 `surface` | M3 `surface` |
| `surfaceContainer` | Cards, sheets | M3 `surfaceContainer` | M3 `surfaceContainer` |
| `incomeAmount` | Positive financial amounts | Green shade | Green shade (brighter) |
| `expenseAmount` | Negative financial amounts | Red shade | Red shade (brighter) |
| `warningAmount` | Budget approaching limit | Orange shade | Orange shade (brighter) |
| `textPrimary` | Primary body text | M3 `onSurface` | M3 `onSurface` |
| `textSecondary` | Secondary/muted text | M3 `onSurfaceVariant` | M3 `onSurfaceVariant` |
| `accentPastel` | Lightened/darkened accent for surfaces | `dynamicPastel` of primary | `dynamicPastel` of primary |

This is a smaller, more focused set than Cashew's 14 tokens. We add tokens only when Material 3's built-in `ColorScheme` roles are insufficient.

**Font strategy:**
Ship with one font (likely Inter or the system default). User-selectable fonts are a nice-to-have but not a v1 priority. Consistency over customization for the first release.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **Type safety** | `getColor(context, "lightDarkAccent")` -- string keys, runtime errors | `context.varianceColors.accentPastel` -- named getters, compile-time errors | Safe vs fragile |
| **Dynamic color** | `system_theme` package + manual blending + Samsung bug workaround | `dynamic_color` (official Google package) with built-in fallback | Standard vs patched |
| **Token count** | 14 custom tokens, some with confusing inverted semantics (`white` = black in dark mode) | Minimal extension set, leveraging M3's built-in 29 `ColorScheme` roles first | Lean vs bloated |
| **Pastel system** | `dynamicPastel()` is good but accessed inconsistently | Same concept, applied consistently through the extension layer | Systematic vs ad-hoc |

### Risks to Watch

1. **Material 3 color scheme limitations.** `ColorScheme.fromSeed()` sometimes produces colors that do not work well for financial data (e.g., the generated `error` color may not contrast well with custom income/expense colors). We need to test the generated scheme with real financial screens and override specific roles if needed.
2. **Income/expense color accessibility.** Red/green for expense/income is problematic for colorblind users (~8% of males). We should support alternative color pairs (e.g., red/blue) or shape-based indicators alongside color. This is a v2 concern but the token system should be designed to support swappable palettes.
3. **Theme switching performance.** Changing the accent color regenerates the entire `ThemeData`. If the user has a color picker that changes on drag, this can cause jank. Debounce the theme regeneration or use a preview mechanism that does not rebuild the full theme until the user commits.

---

## 6. Animation System: Curves, Patterns, and Philosophy

### What Cashew Does

Cashew has a surprisingly sophisticated, three-tier animation system that is one of the strongest parts of the codebase.

**Three-tier opt-out:**
1. **Full animations** (default): rich experience with elastic curves, container transforms, and staggered reveals.
2. **Reduced animations** (`appStateSettings["appAnimations"] != AppAnimations.all`): durations become `Duration.zero`, some animations skip entirely.
3. **Battery saver** (`appStateSettings["batterySaver"]`): all decorative animations and box shadows are disabled. Every animation widget checks this flag and returns the child directly.

This is considerate engineering. Every animation widget has a bailout path.

**Core animation widgets (10+):**

| Widget | Behavior | Curve | Duration |
|--------|----------|-------|----------|
| `FadeIn` | Opacity 0 to 1 | default | 500ms |
| `ScaleIn` | Scale 0 to 1 with overshoot | `ElasticOutCurve(0.5)` | 1500ms |
| `AnimatedExpanded` | Fade + size transition for show/hide | `fastOutSlowIn` | 425ms |
| `AnimatedSizeSwitcher` | Size + content cross-fade | `easeInOutCubicEmphasized` / 250ms | 800ms / 250ms |
| `CountNumber` | Numeric value tween | `easeOutQuint` | 1000ms |
| `BreathingWidget` | Looping scale pulse (1.0 to 1.3) | `Curves.ease` | 3000ms |
| `PinWheelReveal` | Clockwise sweep clip reveal | `easeInOutCubic` | 850ms |
| `ShakeAnimation` | Elastic horizontal shake | `ElasticInOutCurve(0.19)` | variable |
| `BouncingWidget` | Vertical elastic bounce | `ElasticOutCurve(0.6)` / `bounceIn` | variable |
| `AnimatedCircularProgress` | Custom-painted progress ring | `easeInOutCubicEmphasized` | 2500ms |

**The "snappy" feel comes from three deliberate choices:**
1. **`easeInOutCubicEmphasized`** as the dominant curve. This is the Material 3 recommended motion curve. It starts slow, accelerates aggressively, then settles with satisfying deceleration. Used for sidebar, tabs, FAB, size transitions, and scroll-to-top.
2. **Elastic curves for delight.** `ElasticOutCurve(0.5-0.6)` for pie chart segments, scale-in animations, and badge pop-ins. Gives objects a satisfying overshoot-and-settle.
3. **Short durations for interactions, long durations for reveals.** Tap feedback: 150-230ms. Content reveals: 500-1500ms. The app responds instantly to touch but takes its time for visual storytelling.

**Platform-adaptive touch feedback (`Tappable`):**
- Android: `InkWell` with `InkSparkle.constantTurbulenceSeedSplashFactory` ripple.
- iOS: custom `FadedButton` -- opacity fades to 50% on press (150ms ease-in), recovers on release (230ms `easeOutCubic`). No ripple.
This is one of the biggest contributors to the app feeling native on each platform.

**Implicit vs explicit split:**
Simple state-driven visibility uses implicit animations (`AnimatedContainer`, `AnimatedSwitcher`, `TweenAnimationBuilder`). Complex multi-part sequences use explicit `AnimationController`s (page headers, breathing widgets, custom painters).

### What Variance Should Do

**Adopt the three-tier opt-out pattern.** This is non-negotiable. Every animation widget must check:
1. A `reduceMotion` system accessibility setting (via `MediaQuery.disableAnimations`).
2. An app-level animation preference (full/reduced/off).
3. A battery saver mode that disables all decorative motion and shadows.

The implementation should be a single `AnimationConfig` that is provided via `InheritedWidget` or Riverpod, not a global map lookup.

**Adopt `easeInOutCubicEmphasized` as the default curve.** Cashew proves this works. Material 3 recommends it. We should define it as a constant and use it everywhere unless there is a specific reason for a different curve.

**Define a motion token system:**

| Token | Duration | Curve | Use Case |
|-------|----------|-------|----------|
| `tapFeedback` | 150ms | `easeIn` | Press feedback (opacity/scale) |
| `microInteraction` | 200-250ms | `easeInOutCubicEmphasized` | Toggle, switch, chip selection |
| `contentSwitch` | 300-400ms | `easeInOutCubicEmphasized` | Content cross-fade, tab switch |
| `expand` | 400-500ms | `easeInOutCubicEmphasized` | Section expand/collapse |
| `pageTransition` | 300ms | `easeInOutCubicEmphasized` | Route push/pop |
| `contentReveal` | 500-800ms | `easeInOutCubicEmphasized` | Chart reveal, list appear |
| `delight` | 800-1500ms | `ElasticOutCurve(0.5)` | Badge pop, achievement, first-time reveal |
| `numberCount` | 1000ms | `easeOutQuint` | Financial amount animation |

This token system gives every animation a home. Developers pick a token, not a raw duration and curve. Consistency is enforced by design.

**Adopt platform-adaptive touch feedback.** Cashew's `Tappable` pattern (ripple on Android, opacity fade on iOS) is correct. We should build an equivalent widget. The specific approach:
- Android: standard `InkWell` with Material 3 ripple. No need to fork.
- iOS: opacity-based feedback (Cashew's `FadedButton` pattern). Consider `CupertinoButton`-style scaling as an alternative.

**Build animation widgets as composable primitives, not monoliths.** Cashew's `AnimatedSizeSwitcher` (20 lines, used dozens of times) is the ideal: tiny, composable, reusable. Their `PageFramework` (1,336 lines with three animation controllers) is the anti-ideal. Our animation widgets should be:
- Small (under 100 lines each)
- Single-purpose
- Composable (wrap them around each other, not a mega-widget with 15 parameters)
- Token-driven (durations and curves come from the motion token system, not hardcoded)

**Charts:** Use `fl_chart` (same as Cashew) or evaluate alternatives. Cashew's pie chart reveal (`PinWheelReveal`) and staggered badge pop-in are delightful. We should replicate the staggered animation pattern (initial delay + per-item stagger) for any list of items that appears.

### Why Ours Is Better

| Dimension | Cashew | Variance | Delta |
|-----------|--------|----------|-------|
| **Accessibility** | App-level toggle only. Does not respect system `reduceMotion`. | Respects `MediaQuery.disableAnimations` + app preference + battery saver. Three-tier, system-aware. | Accessible vs partially |
| **Consistency** | Durations and curves are hardcoded per-widget. 500ms here, 800ms there, 1500ms elsewhere. | Motion token system ensures consistent timing across the app. Developers pick tokens, not magic numbers. | Systematic vs ad-hoc |
| **Configurability** | Animation settings are in the global mutable map, checked via string key lookup. | `AnimationConfig` provided via `InheritedWidget`. Type-safe, testable, mockable. | Structured vs stringly-typed |
| **Widget size** | `PageFramework` is 1,336 lines with 3 animation controllers. | Composable primitives under 100 lines each. Compose them, do not monolith them. | Composable vs monolithic |
| **Touch feedback** | Platform-adaptive (good) but uses a forked package for bottom sheets. | Platform-adaptive (same quality) with no forked dependencies. | Clean vs vendor-locked |

### Risks to Watch

1. **Animation over-engineering.** Cashew's animation system works because it evolved organically from real UX needs. We should not design a comprehensive animation framework up front. Start with the token system, build 3-4 core animation widgets (fade, expand, size-switch, count), and add more only when a real screen needs them.
2. **Performance on low-end devices.** Elastic curves and staggered animations are expensive on low-end Android devices. The three-tier opt-out handles this, but we must actually test on budget hardware. A beautiful animation that janks on a Moto G is worse than no animation.
3. **Chart animation parity.** `fl_chart`'s built-in animations may not match our motion tokens exactly. We may need to wrap chart widgets in our own animation controllers to get the right curves and timings. Evaluate this during chart prototyping.
4. **iOS feel.** Cashew's iOS adaptations (opacity feedback, centered titles, compact headers) are well-tuned. Our iOS feel depends on getting these details right. This is not a framework problem; it is a polish problem that requires iterative testing on real iOS devices.
