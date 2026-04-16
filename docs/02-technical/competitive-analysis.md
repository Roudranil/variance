---
name: Lead Engineer — Competitive Intelligence Consolidation
status: complete
owner: le
created: 2026-04-15
last_updated: 2026-04-15
depends_on: [enemy-recon/01-architecture-data-model.md, enemy-recon/02-ui-ux-animation.md, enemy-recon/03-state-management-performance.md, enemy-recon/04-feature-engineering.md, enemy-recon/05-security-infrastructure.md, enemy-recon/06-pm-consolidation.md, enemy-recon/08-emoji-icons-and-exchange-rates.md, enemy-recon/09-notification-parsing.md, enemy-recon/10-forked-packages.md]
outputs_to: [02-technical/sds.md]
---

- [Engineering Intelligence Report — Competitive Analysis Consolidation](#engineering-intelligence-report--competitive-analysis-consolidation)
- [Architecture Comparison: Cashew vs Variance](#architecture-comparison-cashew-vs-variance)
  - [1. Data Model: Single-Entry vs Double-Entry Bookkeeping](#1-data-model-single-entry-vs-double-entry-bookkeeping)
    - [What Cashew Does](#what-cashew-does)
    - [What Variance Should Do](#what-variance-should-do)
    - [Why Ours Is Better](#why-ours-is-better)
    - [Risks to Watch](#risks-to-watch)
  - [2. State Management: Global Mutable Map vs Structured Reactive Architecture](#2-state-management-global-mutable-map-vs-structured-reactive-architecture)
    - [What Cashew Does](#what-cashew-does-1)
    - [What Variance Should Do](#what-variance-should-do-1)
    - [Why Ours Is Better](#why-ours-is-better-1)
    - [Risks to Watch](#risks-to-watch-1)
  - [3. Database Layer: Drift Patterns and Migration Strategy](#3-database-layer-drift-patterns-and-migration-strategy)
    - [What Cashew Does](#what-cashew-does-2)
    - [What Variance Should Do](#what-variance-should-do-2)
    - [Why Ours Is Better](#why-ours-is-better-2)
    - [Risks to Watch](#risks-to-watch-2)
  - [4. Navigation: FadeIndexedStack vs GoRouter](#4-navigation-fadeindexedstack-vs-gorouter)
    - [What Cashew Does](#what-cashew-does-3)
    - [What Variance Should Do](#what-variance-should-do-3)
    - [Why Ours Is Better](#why-ours-is-better-3)
    - [Risks to Watch](#risks-to-watch-3)
  - [5. Theming: Material 3 Approach](#5-theming-material-3-approach)
    - [What Cashew Does](#what-cashew-does-4)
    - [What Variance Should Do](#what-variance-should-do-4)
    - [Why Ours Is Better](#why-ours-is-better-4)
    - [Risks to Watch](#risks-to-watch-4)
  - [6. Animation System: Curves, Patterns, and Philosophy](#6-animation-system-curves-patterns-and-philosophy)
    - [What Cashew Does](#what-cashew-does-5)
    - [What Variance Should Do](#what-variance-should-do-5)
    - [Why Ours Is Better](#why-ours-is-better-5)
    - [Risks to Watch](#risks-to-watch-5)
- [Section 2: Engineering Problems Cashew Solved (That We Must Solve Too)](#section-2-engineering-problems-cashew-solved-that-we-must-solve-too)
  - [1. Schema Migration Strategy](#1-schema-migration-strategy)
    - [The Problem](#the-problem)
    - [Cashew's Solution](#cashews-solution)
    - [Assessment: Adequate](#assessment-adequate)
    - [Our Recommended Approach](#our-recommended-approach)
  - [2. Multi-Currency Aggregation](#2-multi-currency-aggregation)
    - [The Problem](#the-problem-1)
    - [Cashew's Solution](#cashews-solution-1)
    - [Assessment: Poor](#assessment-poor)
    - [Our Recommended Approach](#our-recommended-approach-1)
  - [3. Recurring Transaction Materialization](#3-recurring-transaction-materialization)
    - [The Problem](#the-problem-2)
    - [Cashew's Solution](#cashews-solution-2)
    - [Assessment: Adequate](#assessment-adequate-1)
    - [Our Recommended Approach](#our-recommended-approach-2)
  - [4. Date and Period Calculations](#4-date-and-period-calculations)
    - [The Problem](#the-problem-3)
    - [Cashew's Solution](#cashews-solution-3)
    - [Assessment: Poor](#assessment-poor-1)
    - [Our Recommended Approach](#our-recommended-approach-3)
  - [5. Infinite Scroll and Large List Rendering](#5-infinite-scroll-and-large-list-rendering)
    - [The Problem](#the-problem-4)
    - [Cashew's Solution](#cashews-solution-4)
    - [Assessment: Poor](#assessment-poor-2)
    - [Our Recommended Approach](#our-recommended-approach-4)
  - [6. Search Implementation](#6-search-implementation)
    - [The Problem](#the-problem-5)
    - [Cashew's Solution](#cashews-solution-5)
    - [Assessment: Good (filter system), Adequate (search itself)](#assessment-good-filter-system-adequate-search-itself)
    - [Our Recommended Approach](#our-recommended-approach-5)
  - [7. CSV Import/Export](#7-csv-importexport)
    - [The Problem](#the-problem-6)
    - [Cashew's Solution](#cashews-solution-6)
    - [Assessment: Good](#assessment-good)
    - [Our Recommended Approach](#our-recommended-approach-6)
  - [8. Chart Rendering](#8-chart-rendering)
    - [The Problem](#the-problem-7)
    - [Cashew's Solution](#cashews-solution-7)
    - [Assessment: Good](#assessment-good-1)
    - [Our Recommended Approach](#our-recommended-approach-7)
  - [9. Platform Abstractions (Android / iOS / Web)](#9-platform-abstractions-android--ios--web)
    - [The Problem](#the-problem-8)
    - [Cashew's Solution](#cashews-solution-8)
    - [Assessment: Adequate](#assessment-adequate-2)
    - [Our Recommended Approach](#our-recommended-approach-8)
  - [Summary Table](#summary-table)
- [Section 3 -- Engineering Anti-Patterns to Avoid](#section-3----engineering-anti-patterns-to-avoid)
  - [AP-1: Global Mutable `Map<String, dynamic>` for Settings (170+ String Keys)](#ap-1-global-mutable-mapstring-dynamic-for-settings-170-string-keys)
  - [AP-2: 7,667-Line God File (`tables.dart`)](#ap-2-7667-line-god-file-tablesdart)
  - [AP-3: Zero Test Coverage](#ap-3-zero-test-coverage)
  - [AP-4: No Database Encryption (Plain SQLite File)](#ap-4-no-database-encryption-plain-sqlite-file)
  - [AP-5: Imperative GlobalKey-Based State Refresh (15+ GlobalKeys)](#ap-5-imperative-globalkey-based-state-refresh-15-globalkeys)
  - [AP-6: Module-Level Global Singletons (`late` Variables)](#ap-6-module-level-global-singletons-late-variables)
  - [AP-7: Silent Error Swallowing (Zone Error Handler)](#ap-7-silent-error-swallowing-zone-error-handler)
  - [AP-8: JSON-in-Columns Pattern (Serialized JSON in Database Columns)](#ap-8-json-in-columns-pattern-serialized-json-in-database-columns)
  - [AP-9: O(n) Period Iteration for Budget Date Calculation](#ap-9-on-period-iteration-for-budget-date-calculation)
  - [AP-10: Full-Database Sync Upload (Entire SQLite to Google Drive)](#ap-10-full-database-sync-upload-entire-sqlite-to-google-drive)
  - [Summary Table](#summary-table-1)
- [Section 4: Patterns Worth Stealing (With Modifications)](#section-4-patterns-worth-stealing-with-modifications)
  - [Pattern 1: Drift Reactive Streams (`.watch()` for Real-Time UI Updates)](#pattern-1-drift-reactive-streams-watch-for-real-time-ui-updates)
    - [What Cashew Does](#what-cashew-does-6)
    - [What Is Good About It](#what-is-good-about-it)
    - [What to Keep](#what-to-keep)
    - [What to Change](#what-to-change)
  - [Pattern 2: ListenableSelector (Targeted Widget Rebuilds)](#pattern-2-listenableselector-targeted-widget-rebuilds)
    - [What Cashew Does](#what-cashew-does-7)
    - [What Is Good About It](#what-is-good-about-it-1)
    - [What to Keep](#what-to-keep-1)
    - [What to Change](#what-to-change-1)
  - [Pattern 3: Currency Conversion via Base Currency Intermediary (USD Pivot)](#pattern-3-currency-conversion-via-base-currency-intermediary-usd-pivot)
    - [What Cashew Does](#what-cashew-does-8)
    - [What Is Good About It](#what-is-good-about-it-2)
    - [What to Keep](#what-to-keep-2)
    - [What to Change](#what-to-change-2)
  - [Pattern 4: Deterministic Key Generation for Sync Dedup](#pattern-4-deterministic-key-generation-for-sync-dedup)
    - [What Cashew Does](#what-cashew-does-9)
    - [What Is Good About It](#what-is-good-about-it-3)
    - [What to Keep](#what-to-keep-3)
    - [What to Change](#what-to-change-3)
  - [Pattern 5: Animation Curves -- easeInOutCubicEmphasized Everywhere](#pattern-5-animation-curves----easeinoutcubicemphasized-everywhere)
    - [What Cashew Does](#what-cashew-does-10)
    - [What Is Good About It](#what-is-good-about-it-4)
    - [What to Keep](#what-to-keep-4)
    - [What to Change](#what-to-change-4)
  - [Pattern 6: PageFramework / PopupFramework Scaffolding](#pattern-6-pageframework--popupframework-scaffolding)
    - [What Cashew Does](#what-cashew-does-11)
    - [What Is Good About It](#what-is-good-about-it-5)
    - [What to Keep](#what-to-keep-5)
    - [What to Change](#what-to-change-5)
  - [Pattern 7: Composable Filter Expressions](#pattern-7-composable-filter-expressions)
    - [What Cashew Does](#what-cashew-does-12)
    - [What Is Good About It](#what-is-good-about-it-6)
    - [What to Keep](#what-to-keep-6)
    - [What to Change](#what-to-change-6)
  - [Pattern 8: Three-Tier Animation Opt-Out System](#pattern-8-three-tier-animation-opt-out-system)
    - [What Cashew Does](#what-cashew-does-13)
    - [What Is Good About It](#what-is-good-about-it-7)
    - [What to Keep](#what-to-keep-7)
    - [What to Change](#what-to-change-7)
  - [Bonus Finding 1: Exchange Rate API (fawazahmed0 via jsDelivr)](#bonus-finding-1-exchange-rate-api-fawazahmed0-via-jsdelivr)
  - [Bonus Finding 2: Category Icon Library (277 Curated PNGs with Search Tags)](#bonus-finding-2-category-icon-library-277-curated-pngs-with-search-tags)
- [Engineering Intelligence Report -- Part B (Sections 5-8)](#engineering-intelligence-report----part-b-sections-5-8)
  - [6. Security \& Data Integrity Plan](#6-security--data-integrity-plan)
    - [6.1 Threat Model Context](#61-threat-model-context)
    - [6.2 MUST Have at v1 Launch](#62-must-have-at-v1-launch)
      - [6.2.1 Database Encryption (SQLCipher)](#621-database-encryption-sqlcipher)
      - [6.2.2 Secure Storage for Sensitive Settings](#622-secure-storage-for-sensitive-settings)
      - [6.2.3 Biometric / PIN Authentication](#623-biometric--pin-authentication)
      - [6.2.4 Input Validation at Every Boundary](#624-input-validation-at-every-boundary)
      - [6.2.5 Foreign Key Enforcement](#625-foreign-key-enforcement)
    - [6.3 Can Wait for v2](#63-can-wait-for-v2)
      - [6.3.1 Backup Encryption](#631-backup-encryption)
      - [6.3.2 Deep Link Safety](#632-deep-link-safety)
      - [6.3.3 Exchange Rate API Key Security](#633-exchange-rate-api-key-security)
    - [6.4 Security Checklist Summary](#64-security-checklist-summary)
  - [7. Technical Debt Lessons](#7-technical-debt-lessons)
    - [7.1 File Organization: The God File Problem](#71-file-organization-the-god-file-problem)
    - [7.2 Schema Migration Strategy: 46 Versions, Two Styles](#72-schema-migration-strategy-46-versions-two-styles)
    - [7.3 Testing Discipline: Zero Tests](#73-testing-discipline-zero-tests)
    - [7.4 State Management Evolution: Global Mutable Map](#74-state-management-evolution-global-mutable-map)
    - [7.5 Forked Packages: Three Abandoned Dependencies](#75-forked-packages-three-abandoned-dependencies)
    - [7.6 Technical Debt Summary](#76-technical-debt-summary)
  - [8. Estimated Complexity Assessment](#8-estimated-complexity-assessment)
    - [8.1 Complexity Ranking](#81-complexity-ranking)
    - [8.2 Critical Path Analysis](#82-critical-path-analysis)
    - [8.3 Risk Assessment](#83-risk-assessment)
    - [8.4 Effort Summary](#84-effort-summary)


# Engineering Intelligence Report — Competitive Analysis Consolidation

> **Author:** Lead Engineer Agent
> **Date:** 2026-04-15
> **Sources:** 10 reconnaissance reports from deep analysis of a production open-source Flutter/Dart finance tracker (120K lines, 245 files, 46 schema versions)
> **Purpose:** Inform Variance SDS, architecture, and implementation decisions

---


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

---

# Section 2: Engineering Problems Cashew Solved (That We Must Solve Too)

**Date:** 2026-04-15
**Author:** Lead Engineer
**Sources:** Reports 01 (Architecture & Data Model), 03 (State Management & Performance), 04 (Feature Engineering)
**Audience:** Founder + Engineering Team


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

---


# Section 3 -- Engineering Anti-Patterns to Avoid

**Date:** 2026-04-15
**Author:** Lead Engineer
**Sources:** Reports 01 (Architecture & Data Model), 03 (State Management & Performance), 05 (Security & Infrastructure)
**Audience:** Founder + TPM + Developer subagents

---

This section catalogs 10 concrete anti-patterns found in the Cashew codebase. Each entry describes what Cashew does, why it is a problem, and what Variance does instead. These are not theoretical concerns -- every one of them is observable in Cashew's source code and directly impacts maintainability, testability, security, or performance.

---

## AP-1: Global Mutable `Map<String, dynamic>` for Settings (170+ String Keys)

**What Cashew does:** All user preferences, cached data, and runtime configuration live in a single global mutable map called `appStateSettings` (Report 03, Section 2.1). This map holds over 170 key-value pairs -- theme colors, notification schedules, cached exchange rates, selected wallet PK, onboarding flags -- all keyed by stringly-typed `String` identifiers and typed as `dynamic`. The map is loaded from `SharedPreferences` on boot, mutated in place throughout the app via `appStateSettings[setting] = value`, and re-serialized to JSON on every change. There is no schema, no type checking, and no validation. Any widget can read any key directly in its `build()` method.

**Why it is a problem:**

- **No type safety.** A typo in a key string (`"batterysSaver"` vs `"batterySaver"`) silently returns `null` instead of failing at compile time. The `dynamic` value type means every read site must cast or hope.
- **No discoverability.** There is no single source of truth for what settings exist, what types they expect, or what their defaults are. The `defaultPreferences.dart` file lists 170+ defaults, but nothing enforces that the runtime map matches.
- **Untestable.** Because widgets read the global map directly, testing any widget requires priming a global mutable variable. There is no way to inject a test-specific settings object.
- **No migration safety.** Adding, renaming, or removing a setting key requires a manual scan of the entire codebase for string matches. There is no compiler-assisted refactoring.
- **Concurrent mutation risk.** Multiple call sites can write to the same map simultaneously with no synchronization.

**What Variance does instead:** Typed, immutable settings classes using `freezed` code generation (per `rules/dart/coding-style.md` -- prefer `final` for local variables, `const` for compile-time constants, `copyWith()` for state mutations). Settings are modeled as domain entities with explicit fields, validated at load time, and exposed through the state management layer (BLoC/Cubit or Riverpod, per `rules/dart/patterns.md`). Changes produce new immutable instances via `copyWith()`. No global mutable maps. No stringly-typed keys. Settings are injected through the dependency graph, making them testable and discoverable.

---

## AP-2: 7,667-Line God File (`tables.dart`)

**What Cashew does:** The entire data layer -- all 9 table definitions, all enums, all type converters, all CRUD methods, all query builders, all filter expression composers, all aggregation methods, all migration logic (46 versions), and all sync processing -- lives in a single file: `lib/database/tables.dart` at 7,667 lines (Report 01, Section 5.2). This file is the database class definition annotated with `@DriftDatabase`. Every query method, from `createOrUpdateTransaction()` to `watchTotalOfBudget()` to `fixWanderingTransactions()`, is a method on this one class in this one file.

**Why it is a problem:**

- **Cognitive overload.** No developer can hold 7,667 lines of context in their head. Finding where a query is defined requires full-text search, not structural navigation.
- **Merge conflict magnet.** Any two changes to the data layer -- a new query, a schema migration, a filter fix -- will conflict because they touch the same file.
- **No separation of concerns.** Table definitions (schema) are interleaved with query logic (reads), mutation logic (writes), migration logic (DDL), and sync logic (cloud). A change to sync code can accidentally break a query method, and the blast radius of any bug is the entire data layer.
- **Generated file bloat.** The corresponding `tables.g.dart` is 6,649 lines. Together, these two files account for over 14,000 lines that must be parsed, compiled, and analyzed as a single unit.
- **Violates file size rule.** Our coding standards cap files at 800 lines (per `rules/common/coding-style.md` -- 200-400 lines typical, 800 max).

**What Variance does instead:** Domain-organized data layer following clean architecture boundaries (per `rules/dart/patterns.md` -- Clean Architecture Layer Boundaries). Each domain concept (accounts, entries, categories, budgets, objectives) gets its own table definition file, its own DAO (Data Access Object) class, and its own repository implementation. Drift supports `@DriftAccessor` annotations for splitting queries across multiple DAO files while sharing a single database connection. Migration logic lives in a dedicated `migrations/` directory with one file per version. Filter expressions are extracted into composable utility classes. The database class itself is a thin shell that registers tables and DAOs -- under 100 lines.

---

## AP-3: Zero Test Coverage

**What Cashew does:** The only test file in the repository is `test/widget_test.dart`, which is the default Flutter scaffold placeholder generated by `flutter create` (Report 05, Section 10.4). It tests a counter increment on a widget that does not exist in the app. It references `Icons.add` and the text `'0'` / `'1'` -- none of which relate to Cashew's actual UI. It would not even compile if run against the app. The two other test files in the repo belong to vendored third-party packages, not to Cashew itself. There are no unit tests for financial calculations, no integration tests for database queries, no widget tests for any screen, and no CI pipeline.

**Why it is a problem:**

- **No regression safety net.** Any change to the codebase -- a query optimization, a migration step, a filter expression refactor -- could silently break existing behavior with no automated detection.
- **No verification of financial correctness.** The balance computation, currency conversion, budget period calculation, and recurring transaction spawning are all untested. Off-by-one errors, sign errors, and rounding errors are discoverable only by manual user testing.
- **Blocks refactoring.** The god file (AP-2) cannot be safely decomposed without tests that verify current behavior. Without tests, every refactoring is a leap of faith.
- **No confidence in migrations.** The 46-version migration chain has zero automated verification. Drift provides a migration testing framework (`SchemaVerifier`) that Cashew does not use.

**What Variance does instead:** TDD is mandatory (per `rules/common/testing.md` -- write test first RED, implement GREEN, refactor IMPROVE). The test pyramid targets 80%+ line coverage with specific layer targets: domain logic >90%, data layer >80%, application layer >80% (per `rules/dart/testing.md`). Property-based tests verify the DEB balance equation invariant (`sum(debits) == sum(credits)`) across all operations. Migration tests use Drift's `SchemaVerifier` to validate every schema version transition. Fakes are preferred over mocks for repository testing (per `rules/dart/testing.md` -- Fakes Over Mocks). Coverage failures block CI.

---

## AP-4: No Database Encryption (Plain SQLite File)

**What Cashew does:** The SQLite database is stored as a plain, unencrypted `.sqlite` file in the application documents directory (Report 05, Section 3.1). A grep for `encrypt`, `cipher`, `sqlcipher`, and `encryption` across Cashew's entire `lib/` directory returns zero relevant results. On native platforms (Android/iOS), the file sits at `getApplicationDocumentsDirectory()/db.sqlite`. On web, data is stored in IndexedDB or `window.localStorage` with a `bin2str` codec that is encoding, not encryption. All financial data -- transaction amounts, account names, category names, budget targets, notes -- is readable in the clear by any process with filesystem access.

**Why it is a problem:**

- **Device compromise exposes everything.** A rooted Android device, a jailbroken iPhone, a stolen laptop, or a forensic extraction tool can read the entire financial history in seconds. For a personal finance app, this is the most sensitive data a user owns.
- **Backups are also unencrypted.** Cashew uploads the raw `.sqlite` file to Google Drive (Report 05, Section 4.1). Anyone with access to the user's Google Drive -- a compromised Google account, a shared computer, a legal discovery request -- gets the full database in the clear.
- **No `flutter_secure_storage` anywhere.** Report 05 confirms zero usage across the entire codebase. Auth tokens, user emails, and sync timestamps are all stored in plaintext `SharedPreferences`.
- **Platform sandboxing is not sufficient.** App sandboxing protects against other apps on a non-rooted device, but it does not protect against physical access, device backup extraction, or cloud storage compromise.

**What Variance does instead:** SQLCipher for database encryption at rest, with the encryption key stored in platform-secure storage -- Keychain on iOS, EncryptedSharedPreferences on Android (per `rules/dart/security.md` -- store runtime secrets in `flutter_secure_storage`). Sensitive settings that cannot live in the encrypted database (such as the database key itself) use `flutter_secure_storage`, never `SharedPreferences`. Backups are encrypted before upload. The threat model (STRIDE) in the SDS explicitly covers information disclosure from device compromise and cloud storage access.

---

## AP-5: Imperative GlobalKey-Based State Refresh (15+ GlobalKeys)

**What Cashew does:** The primary mechanism for triggering UI updates is imperative calls through `GlobalKey` references to page state objects (Report 03, Section 2.6). Cashew declares over 15 `GlobalKey` references -- `homePageStateKey`, `transactionsListPageStateKey`, `budgetsListPageStateKey`, `settingsPageStateKey`, plus keys for the sidebar, loading indicator, snackbar, and more. When a setting changes or data updates, the code calls `somePageStateKey.currentState?.refreshState()` to force a rebuild. The `updateSettings()` function accepts a `pagesNeedingRefresh` parameter -- a list of integer page indices -- and the caller must manually specify which pages need refreshing. Even the midnight day-change detector (a 1-second polling loop) refreshes the entire app by calling `refreshState()` on every page key.

**Why it is a problem:**

- **Tight coupling.** Every piece of code that triggers a state change must know about the existence and identity of specific page keys. The settings module knows about the home page. The day-change detector knows about every page. Adding a new page requires updating every call site that might affect it.
- **Fragile.** If a `GlobalKey` is attached to a widget that has been disposed (e.g., the user navigated away), `currentState` is `null` and the refresh silently fails. There is no guarantee that a state change propagates to all affected UI.
- **Untestable.** `GlobalKey`-based refresh depends on a live widget tree. You cannot unit test state propagation without mounting the full page hierarchy. This makes it impossible to verify that a settings change correctly updates the budget page without an integration test.
- **Not reactive.** This is push-based imperative mutation, not pull-based reactive subscription. The UI does not automatically respond to state changes -- it must be told to refresh by something that knows it exists.
- **Violates Flutter's declarative model.** Flutter is designed around declarative state management: state changes flow through the widget tree via providers, streams, or notifiers, and widgets rebuild automatically. GlobalKey imperative refresh bypasses this entirely.

**What Variance does instead:** Reactive state management via BLoC/Cubit or Riverpod (per `rules/dart/patterns.md` -- State Management: BLoC/Cubit, State Management: Riverpod). State changes emit new immutable state objects. Widgets subscribe to the state streams they care about and rebuild automatically when relevant state changes. No `GlobalKey` references for state propagation. No manual page refresh lists. The state management layer is fully testable without a widget tree -- BLoC tests verify state transitions with `blocTest`, Riverpod tests use `ProviderContainer` (per `rules/dart/testing.md`).

---

## AP-6: Module-Level Global Singletons (`late` Variables)

**What Cashew does:** All core infrastructure objects are declared as module-level `late` global variables in `lib/struct/databaseGlobal.dart` (Report 03, Section 1.2):

```
late FinanceDatabase database;
late SharedPreferences sharedPreferences;
final uuid = Uuid();
```

Plus additional globals scattered across the codebase: `googleUser` (auth state), `appLifecycleState` (lifecycle), `flutterLocalNotificationsPlugin` (notifications), `notificationPayload`, `canSyncData`, and `isDatabaseCorrupted`. These are assigned once during the boot sequence and accessed directly by any file that imports them. There is no dependency injection, no service locator, no provider. The database object is referenced by name (`database.someQuery()`) in widgets, utilities, and state management code alike.

**Why it is a problem:**

- **Untestable.** Every class that references `database` directly is impossible to unit test with a fake or mock database. You cannot swap the global for a test double without mutation of shared global state, which breaks test isolation.
- **Hidden dependencies.** A function's signature does not reveal that it depends on the database, SharedPreferences, or auth state. You must read the function body to discover its dependencies. This makes reasoning about behavior, side effects, and error paths much harder.
- **Initialization order fragility.** `late` variables crash at runtime if accessed before initialization. The boot sequence must initialize them in exactly the right order, and that order is documented nowhere except the `main()` function. Adding a new global requires manually ensuring it is initialized before any consumer runs.
- **No lifecycle management.** Global singletons have no dispose mechanism. The database connection, for example, is never explicitly closed. For a mobile app that may be backgrounded and killed, this is a resource leak risk.
- **Violates `late` avoidance rule.** Our Dart coding standards say: avoid `late` unless initialization is guaranteed before first use; prefer nullable or constructor init (per `rules/dart/coding-style.md`).

**What Variance does instead:** Constructor-based dependency injection at the composition root (per `rules/dart/patterns.md` -- Dependency Injection). The database, secure storage, and other infrastructure are instantiated in a setup function and injected into repositories, use cases, and state managers via constructor parameters. `get_it` or Riverpod providers manage the object graph. Every dependency is explicit in the constructor signature, swappable in tests via fakes, and disposable via the DI container's lifecycle management. Zero module-level `late` variables for infrastructure.

---

## AP-7: Silent Error Swallowing (Zone Error Handler)

**What Cashew does:** The entire app runs inside a `runZonedGuarded` call whose error handler is an empty callback (Report 03, Section 6.1):

```
runZonedGuarded(() async { await body(); }, (error, stackTrace) {});
```

The empty `(error, stackTrace) {}` means every unhandled exception that propagates to the zone boundary is silently discarded. No logging. No crash reporting. No user notification. The error and its stack trace vanish. Additionally, in release mode, Flutter's error widget (the red/yellow striped box that signals rendering errors) is replaced with a transparent container:

```
ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
  return Container(color: Colors.transparent);
};
```

This means rendering errors are also invisible to the user. Between these two mechanisms, Cashew suppresses both Dart runtime exceptions and Flutter framework rendering errors in production.

**Why it is a problem:**

- **Lost diagnostics.** When a user reports "the app is broken," there is no crash log, no stack trace, no error context to diagnose the issue. The developer must reproduce the problem locally with debug logging enabled.
- **Silent data corruption.** If a database write partially fails, or a migration step throws, or a sync operation errors out mid-transaction, the error is swallowed. The app continues running with potentially corrupt state, and the user has no indication that anything went wrong.
- **Impossible debugging.** Errors that happen in production builds are unrecoverable. There is no Sentry, no Crashlytics, no structured error tracking. The zone capture system does log `print()` output to an in-memory ring buffer, but the zone error handler never calls `print()` -- it calls nothing.
- **Violates error handling rules.** Our coding standards say: handle errors explicitly at every level, never silently swallow errors (per `rules/common/coding-style.md` -- Error Handling). Dart-specific rules say: specify exception types in `on` clauses, never use bare `catch (e)` (per `rules/dart/coding-style.md` -- Error Handling).

**What Variance does instead:** Structured error handling at every layer. The zone error handler logs the error with full context (timestamp, user action, app version) to a structured logging service and, where privacy constraints allow, to a crash reporting backend. `Result`-style sealed types or typed exceptions propagate errors from the data layer through the application layer to the UI, where they are displayed as user-friendly messages. No bare `catch (e)`. No empty error callbacks. Every error path is explicitly handled or explicitly escalated.

---

## AP-8: JSON-in-Columns Pattern (Serialized JSON in Database Columns)

**What Cashew does:** Several columns across multiple tables store JSON-encoded lists or maps as text strings (Report 01, Sections 1.2, 5.2). Specific examples:

- `Budgets.categoryFks` -- a JSON-encoded list of category primary keys to include in the budget (e.g., `'["1","3","5"]'`).
- `Budgets.categoryFksExclude` -- a JSON-encoded list of category PKs to exclude.
- `Budgets.walletFks` -- a JSON-encoded list of wallet PKs.
- `Budgets.budgetTransactionFilters` -- a JSON-encoded list of enum flags controlling which transaction types count.
- `Transactions.budgetFksExclude` -- a JSON-encoded list of budget PKs this transaction is excluded from.
- `Wallets.homePageWidgetDisplay` -- a JSON-encoded list of enum indices for home page widget visibility.

These are implemented via Drift `TypeConverter` classes that serialize Dart `List<String>` to JSON strings and back.

**Why it is a problem:**

- **No SQL-level querying.** You cannot write `WHERE categoryFk IN budget.categoryFks` because `categoryFks` is a text blob, not a relational column. Instead, the filter expressions use string `LIKE '%"categoryPk"%'` checks or deserialize the JSON in Dart and filter in application memory. This defeats the purpose of using a relational database.
- **No referential integrity.** The PKs stored in these JSON blobs are not foreign keys. If a category is deleted, the stale PK remains in every budget's `categoryFks` JSON. The `fixWandering*` cleanup methods (Report 01, Section 1.3) exist precisely because these JSON blobs accumulate orphaned references.
- **No indexing.** SQLite cannot index into a JSON text column. Every query that filters by category inclusion must scan all budgets and deserialize their JSON to check membership.
- **Schema opacity.** The database schema does not reveal that `categoryFks` contains a list of foreign keys. Only reading the application code reveals the semantic meaning and structure of these columns.

**What Variance does instead:** Proper junction tables for many-to-many relationships (per the Data Model Design Principles in the engineering-lead skill -- apply 3NF for transactional data). A `budget_categories` junction table with explicit `budget_fk` and `category_fk` columns, each with proper foreign key constraints, replaces the JSON blob. Queries use standard SQL `JOIN` or `IN (SELECT ...)` subqueries. Cascade rules enforce referential integrity when categories are deleted. Composite indexes on the junction table support efficient membership queries. The schema is self-documenting.

---

## AP-9: O(n) Period Iteration for Budget Date Calculation

**What Cashew does:** The `getBudgetDate()` function in `lib/functions.dart` finds the current budget period by iterating forward from the budget start date, one period at a time, up to 10,000 iterations (Report 03, Section 3.9):

```
for (int i = 0; i < 10000; i++) {
  if (currentDate falls within currentDateLoopStart..currentDateLoopEnd) {
    return DateTimeRange(start: currentDateLoopStart, end: ...);
  }
  // Advance the loop window by one period
}
```

For a daily budget created two years ago, this iterates approximately 730 times. For a budget created five years ago with a daily period, it approaches the 10,000 ceiling. If the budget is older than ~27 years (daily) or the period calculation somehow overshoots, the function silently returns nothing.

**Why it is a problem:**

- **O(n) where O(1) is trivial.** The current period number for a recurring budget with a fixed-length period is a simple arithmetic operation: `periodIndex = (today - startDate).inDays ~/ periodLengthInDays`. From the index, you can compute the exact start and end dates of the current period with two additions. This is O(1) with zero iteration.
- **Runs on the main thread.** This computation is synchronous and executes during widget builds. With multiple budgets, each triggering this loop, the cost multiplies. For a home screen that displays 5 budgets, each 2 years old with daily periods, that is 3,650 iterations on the UI thread per rebuild.
- **Hard-coded iteration ceiling.** The 10,000 cap is a magic number with no documentation explaining why it was chosen or what happens when it is exceeded.
- **Month/year boundary handling obscures the fix.** The iteration exists partly because months and years have variable lengths, making direct arithmetic non-trivial for those period types. But even for monthly periods, the calculation is `monthDiff = (today.year - start.year) * 12 + (today.month - start.month)`, which is still O(1).

**What Variance does instead:** Direct date arithmetic for budget period calculation. The period index is computed from the date difference and period length using integer division. For variable-length periods (monthly, yearly), we use `DateTime` constructor arithmetic (`DateTime(year, month + offset, day)`) which Dart handles natively, including rollover. No iteration loops. O(1) for all period types. The computation is a pure function in the domain layer, unit-tested with edge cases for month boundaries, leap years, and DST transitions.

---

## AP-10: Full-Database Sync Upload (Entire SQLite to Google Drive)

**What Cashew does:** The sync protocol uploads the entire SQLite database file to Google Drive on every sync operation (Report 05, Section 5.1). The file is named `sync-{clientID}.sqlite` and is stored in the Drive `appDataFolder`. During the download phase, the device downloads every other device's full database file, opens each one as a temporary `FinanceDatabase`, queries for records modified since the last sync timestamp, creates `SyncLog` entries, and applies them. Conflict resolution is last-write-wins based on `dateTimeModified` timestamps. There are no vector clocks, no CRDTs, no merge strategies, and no conflict detection UI.

**Why it is a problem:**

- **Does not scale with data volume.** A user with 3 years of daily transactions -- say 5,000+ records across 9 tables -- uploads and downloads the full database on every sync. As the database grows, sync becomes slower and consumes more bandwidth. There is no differential transfer.
- **Bandwidth waste.** If a user changes one transaction on their phone, the next sync uploads the entire database (all 5,000+ transactions, all categories, all budgets, all settings) to update that one record. The ratio of useful data to transferred data approaches zero over time.
- **Unencrypted in transit and at rest on Drive.** The raw `.sqlite` file is uploaded without encryption (Report 05, Section 12, finding C4). Anyone with access to the user's Google Drive can download and read the complete financial history.
- **No integrity validation.** Downloaded sync files are not validated for SQLite structural integrity, schema version compatibility, or data consistency before being merged into the local database (Report 05, Section 5.6). A corrupt or malicious sync file could break the local database.
- **Last-write-wins data loss.** If two devices edit the same transaction between syncs, the last upload wins. There is no detection, no user prompt, and no merge. The losing device's change is silently overwritten.
- **No partial failure recovery.** If sync is interrupted mid-merge (app killed, network drop), there is no transactional guarantee. The local database may be left in a partially merged state.

**What Variance does instead:** Differential sync protocol designed into the data model from day one. The DEB architecture's immutable, append-only ledger entries are naturally suited to sync -- new entries are appended, never mutated, eliminating write conflicts by design. Sync transfers only records created or modified since the last successful sync, not the full database. All data is encrypted before leaving the device (per `rules/dart/security.md` -- encryption at rest for sensitive data). Schema version and data integrity checks are performed on received data before any merge. The sync strategy (whether CRDTs, event sourcing, or operational transforms) will be specified in the SDS with explicit conflict resolution semantics documented in the ADRs.

---

## Summary Table

| # | Anti-Pattern | Cashew Location | Core Violation | Variance Mitigation |
|---|---|---|---|---|
| AP-1 | Global mutable `Map<String, dynamic>` | `settings.dart` | Type safety, testability | Typed immutable `freezed` classes via DI |
| AP-2 | 7,667-line god file | `tables.dart` | File size, separation of concerns | Domain-organized DAOs, 800-line cap |
| AP-3 | Zero test coverage | `widget_test.dart` (placeholder) | Quality, regression safety | TDD mandatory, 80%+ coverage, CI gates |
| AP-4 | No database encryption | `platform/native.dart` | Data protection | SQLCipher + `flutter_secure_storage` |
| AP-5 | GlobalKey imperative refresh | 15+ GlobalKeys in nav framework | Declarative UI, testability | BLoC/Cubit or Riverpod reactive state |
| AP-6 | Module-level `late` singletons | `databaseGlobal.dart` | Dependency injection, testability | Constructor injection via `get_it`/Riverpod |
| AP-7 | Silent error swallowing | Zone error handler `(e, s) {}` | Error handling, diagnostics | Structured error handling, crash reporting |
| AP-8 | JSON-in-columns | Budget/wallet JSON text columns | Relational integrity, queryability | Junction tables with FK constraints |
| AP-9 | O(n) period iteration | `getBudgetDate()` loop to 10,000 | Algorithmic efficiency | O(1) date arithmetic, pure functions |
| AP-10 | Full-DB sync upload | `syncClient.dart` | Scalability, security, bandwidth | Differential encrypted sync, integrity checks |

---


# Section 4: Patterns Worth Stealing (With Modifications)

Eight patterns from Cashew that solve real problems and are worth adopting in Variance -- each with explicit modifications to fit our architecture. Two bonus findings (exchange rate API and icon library) are noted at the end.

Sources: Reports 01, 02, 03, 04, and 08.

---

## Pattern 1: Drift Reactive Streams (`.watch()` for Real-Time UI Updates)

### What Cashew Does

Every data query in Cashew returns a `Stream<T>` via Drift's `.watch()` method. When a row in SQLite changes, Drift automatically re-emits the query result. Widgets consume these streams via `StreamBuilder`, so the UI always reflects the current database state without manual refresh calls.

Cashew also returns both a stream and a future from some methods:

```dart
(Stream<List<Transaction>>, Future<List<Transaction>>) getAllSubscriptions() {
  final query = select(transactions)...;
  return (query.watch(), query.get());
}
```

This gives callers the choice between reactive and one-shot access.

### What Is Good About It

- Zero manual synchronization between DB writes and UI reads. Write to the DB; every widget watching that table updates automatically.
- Drift handles the invalidation logic internally -- it knows which tables a query touches and re-fires when those tables change.
- Eliminates an entire class of stale-data bugs.
- The stream-first approach composes well with Flutter's `StreamBuilder` and with state management layers.

### What to Keep

- **Drift as our SQLite ORM.** This is already aligned with our tech stack decisions. Drift's reactive query system is its killer feature for local-first apps.
- **Stream-first query API.** Every repository method that the UI consumes should return `Stream<T>`. One-shot `Future<T>` methods are for background tasks, migrations, and bulk operations only.
- **Database as the single source of truth.** UI state derives from DB state, not the other way around.

### What to Change

- **No global `late` database variable.** Cashew stores the Drift database as a module-level `late FinanceDatabase database`. We use dependency injection. The database instance is provided through the DI container (likely `get_it` or Riverpod's provider tree) and injected into repositories. This makes testing trivial -- swap in an in-memory Drift database for tests.
- **Repositories consume Drift streams, UI consumes BLoC/Cubit state.** Cashew pipes `StreamBuilder` directly into widgets. We insert a state management layer between the database and the UI. Repositories expose `Stream<T>`, Cubits/BLoCs subscribe to those streams and emit typed state objects (sealed classes: Loading, Success, Failure). Widgets consume Cubit state via `BlocBuilder`, never raw database streams.
- **No `StreamZip` for multi-wallet aggregation.** Cashew merges N per-wallet streams with `StreamZip` to compute multi-currency totals. Our DEB model with per-currency EQ entries means we can compute multi-currency balances with a single query that joins entries with their exchange rates. One stream, not N.

---

## Pattern 2: ListenableSelector (Targeted Widget Rebuilds)

### What Cashew Does

Cashew has a custom `ListenableSelector` extension that converts a `Listenable` into a `ValueListenable<Value>` with a selector function and an optional equality filter:

```dart
extension ListenableSelectorExtension<Controller extends Listenable> on Controller {
  ValueListenable<Value> select<Value>(
    ListenableSelector<Controller, Value> selector, [
    ListenableFilter<Value>? test,
  ]) => _ValueListenableView<Controller, Value>(this, selector, test);
}
```

The internal `_ValueListenableView` lazily subscribes to the source, compares previous and next selected values using `identical()` and the optional filter, and only notifies downstream listeners when the selected value actually changed.

### What Is Good About It

- Prevents cascading rebuilds. If a parent `Listenable` has 10 properties, a widget that only cares about property 3 does not rebuild when properties 1-2 or 4-10 change.
- The lazy subscription model means no overhead until a widget actually mounts.
- It is a general-purpose optimization that works with any `Listenable`, not tied to a specific state management framework.

### What to Keep

- **The concept of selective listening.** Widgets should only rebuild when the specific slice of state they depend on changes. This is a non-negotiable performance principle for Variance.

### What to Change

- **Use Riverpod's `select()` or BLoC's `buildWhen`/`listenWhen` instead of a custom implementation.** The concept is sound, but we do not need to hand-roll it. Both Riverpod and BLoC have built-in selector mechanisms that achieve the same result with framework integration:
  - **BLoC route:** `BlocBuilder<MyCubit, MyState>(buildWhen: (prev, curr) => prev.amount != curr.amount, builder: ...)`
  - **Riverpod route:** `ref.watch(myProvider.select((s) => s.amount))`
- **Immutable state classes make selectors reliable.** Cashew's `ListenableSelector` uses `identical()` comparison, which only works with immutable objects. Our sealed state classes (via `freezed` or manual sealed hierarchies) guarantee this. Cashew's mutable `Map<String, dynamic>` for settings would break the selector -- a mutation does not change identity. We avoid this problem by design.
- **No `GlobalKey`-based refresh.** Cashew uses `ListenableSelector` in a few places but falls back to `GlobalKey.currentState?.refreshState()` for most UI updates. We eliminate imperative refresh entirely. Every UI update flows through the state management layer.

---

## Pattern 3: Currency Conversion via Base Currency Intermediary (USD Pivot)

### What Cashew Does

All exchange rates are fetched relative to USD from the fawazahmed0 API. Rates are cached as a flat map: `{"eur": 0.912, "inr": 83.12, ...}`. To convert from currency A to currency B, Cashew goes through USD as the intermediary:

```
rate = (USD_to_B) * (1 / USD_to_A)
```

For multi-currency totals, the system iterates over every wallet, sums transactions per wallet in native currency, then multiplies each sum by the conversion ratio to the primary (display) currency. These per-wallet results are merged via `StreamZip`.

Custom/manual exchange rates are supported per currency, always stored as USD-relative to avoid chain-dependency issues when API rates update.

### What Is Good About It

- The USD intermediary means you only need N rates (one per currency relative to USD) rather than N^2 rates (every pair). With 537 currencies in the dataset, that is 537 values instead of ~288,000.
- The math is correct and simple. Two multiplications per conversion.
- Custom rates being USD-relative is a smart design decision -- it prevents custom overrides from drifting when the API rate for the primary currency changes.
- Fallback to cached rates on network failure provides offline resilience.

### What to Keep

- **The intermediary currency concept.** One base currency, N rates, two multiplications. This is the standard approach and it works.
- **The fawazahmed0 API itself** is worth evaluating seriously (see Bonus Finding 1 below). Free, no API key, CDN-served.
- **Custom rate overrides.** Users with exotic currencies or crypto need to manually set rates.
- **Offline-first caching.** Rates must survive app restarts and network outages.

### What to Change

- **Home currency as the base, not USD.** Cashew stores all rates as USD-relative because it was simpler for the developer. We store rates as home-currency-relative. The user's home currency (set during onboarding, INR fallback per PRD) is the base. This eliminates one multiplication for the most common conversion (foreign -> home). It also makes the rate column on transactions (`exchange_rate_to_home`) directly usable without an additional USD lookup.
- **Per-transaction rate capture, not per-display-moment.** Cashew converts at display time using the latest cached rate. We lock the exchange rate at transaction creation time (per PRD decision: `exchange_rate_to_home` stored on each transaction). Historical totals use historical rates. Net worth uses current rates (explicitly documented).
- **No per-wallet loop.** Cashew runs N queries (one per wallet) and merges streams. Our DEB ledger entries each carry the transaction's exchange rate. Category and account balances can be computed in a single query: `SUM(entry_amount * exchange_rate_to_home)` for cross-currency aggregation. This is both simpler and more performant.
- **Structured rate storage, not SharedPreferences.** Cashew dumps the entire rate map into `appStateSettings` (a `Map<String, dynamic>` in SharedPreferences). We store exchange rates in a dedicated Drift table with columns for currency code, rate, fetched_at timestamp, and source (api/manual). This supports TTL checks, staleness warnings, and audit of when rates were last refreshed.
- **Rounding discipline.** Cashew does two floating-point multiplications per conversion with no rounding strategy. We define a rounding policy: rates stored to 6 decimal places, converted amounts rounded to the target currency's decimal precision (2 for most fiat, up to 8 for crypto).

---

## Pattern 4: Deterministic Key Generation for Sync Dedup

### What Cashew Does

When a recurring transaction is paid and the next instance is spawned, Cashew generates the new transaction's primary key deterministically from the original key:

```dart
String updatePredictableKey(String originalKey) {
  // "abc" -> "abc::predict::1" -> "abc::predict::2" -> ...
}
```

If the original key is `"tx-uuid-123"`, the first spawned instance gets `"tx-uuid-123::predict::1"`, the second gets `"tx-uuid-123::predict::2"`, and so on. This means that if two devices both auto-pay the same subscription offline, they generate the same key for the next instance. When the devices sync, the duplicate is detected by primary key collision and resolved via last-writer-wins -- instead of creating two separate next-instances.

### What Is Good About It

- Solves a genuinely hard problem. Concurrent materialization of recurring transactions across devices is a classic sync conflict scenario. Deterministic keys turn a conflict-resolution problem into an idempotency problem.
- The implementation is trivial -- string concatenation with a counter suffix.
- It composes cleanly with last-writer-wins sync: same key means same logical entity, so the merge is automatic.

### What to Keep

- **The principle of deterministic key generation for system-generated entities.** Any time the system creates an entity automatically (recurring transaction instances, balance adjustment entries, EQ entries), the key should be derivable from the inputs, not randomly generated.

### What to Change

- **UUIDs stay random for user-created entities.** Only system-generated entities (recurring instances, reversal entries, correction entries) use deterministic keys. User-created transactions use UUID v4.
- **Use a proper deterministic function, not string concatenation.** The `::predict::N` suffix is fragile -- it encodes ordering assumptions and does not handle branching (what if a device skips an instance?). We use UUID v5 (namespace + name-based): `uuidV5(recurringTemplateId, instanceDateISO)`. The template ID is the namespace, the occurrence date is the name. This is deterministic, collision-resistant, and does not encode a sequential counter.
- **Broader application to DEB correction pairs.** When the system creates a reversal+correction pair for an edit, the reversal entry's key should be deterministic from the original transaction ID. This prevents duplicate reversals if the edit is retried.
- **Compound group IDs.** For compound transactions (transfer-with-fee), the `compound_group_id` should also be deterministic from its constituent transaction IDs, not a fresh UUID. This supports idempotent creation of compound groups.

---

## Pattern 5: Animation Curves -- easeInOutCubicEmphasized Everywhere

### What Cashew Does

Cashew uses a deliberate animation curve hierarchy across the entire app:

1. **`Curves.easeInOutCubicEmphasized`** is the dominant curve. It is used for sidebar expand/collapse (1500ms), tab indicators, FAB show/hide (500ms), `AnimatedSize` (800ms), and scroll-to-top (1200ms). This is the Material 3 recommended motion curve -- slow start, aggressive acceleration, satisfying deceleration.

2. **`ElasticOutCurve(0.5-0.6)`** is used for delight moments: pie chart segment animations (1300ms), scale-in pop effects (1500ms), category badge pop-ins. The elastic overshoot-and-settle gives interactive elements a physical, springy feel.

3. **Short durations for interactions, long durations for reveals.** Tap feedback is 150-230ms (via `FadedButton`). Content reveals are 500-1500ms. The app responds instantly to touch but takes its time for visual storytelling.

### What Is Good About It

- Consistent motion language. Every transition in the app feels like it belongs. The same curve family is used everywhere, creating a cohesive personality.
- The three-tier timing (instant touch feedback / medium interaction / slow reveal) is perceptually correct. Users experience responsiveness (no lag on tap) and polish (smooth content transitions) simultaneously.
- `easeInOutCubicEmphasized` genuinely looks better than generic `easeInOut` -- the aggressive mid-section and gentle settle give transitions a sense of momentum.

### What to Keep

- **`easeInOutCubicEmphasized` as our default motion curve.** This is the Material 3 standard and it works. No reason to deviate.
- **The timing hierarchy.** Touch feedback: 100-200ms. Interactive state changes (toggle, expand, tab switch): 300-500ms. Content reveals and page transitions: 500-1000ms. No animation over 1500ms.
- **Elastic curves for delight-only moments.** Reserve `ElasticOutCurve` for non-critical celebratory animations -- goal reached, balance milestone, onboarding illustrations. Never use elastic on functional interactions (it delays the settled state).

### What to Change

- **Codify the motion constants.** Cashew hard-codes duration and curve values at every call site. We define a `VarianceMotion` constants class:
  - `VarianceMotion.defaultCurve` = `easeInOutCubicEmphasized`
  - `VarianceMotion.tapDuration` = 150ms
  - `VarianceMotion.interactionDuration` = 400ms
  - `VarianceMotion.revealDuration` = 700ms
  - `VarianceMotion.delightCurve` = `ElasticOutCurve(0.5)`
  - `VarianceMotion.delightDuration` = 1200ms
- **No animations over 1000ms in functional UI.** Cashew's 1500ms sidebar animation and 2500ms circular progress animation are too slow for daily-use interactions. Cap functional animations at 1000ms; only decorative/celebratory animations may exceed.
- **Android only simplifies platform branching.** Cashew has separate animation paths for iOS (opacity-based tap) and Android (ripple/InkSplash). We target Android only (per PRD), so we standardize on Material ripple everywhere.

---

## Pattern 6: PageFramework / PopupFramework Scaffolding

### What Cashew Does

Cashew has two universal layout widgets that enforce consistent page structure:

**PageFramework** (1,336 lines) wraps every page. It provides:
- A `CustomScrollView` with a `SliverAppBar` that collapses as the user scrolls.
- A large title that scales by up to 1.15x when the header is expanded, settling to normal size on scroll.
- A back button that fades from ghosted (50% opacity) to full opacity as the header collapses.
- Drag-to-dismiss gesture support (vertical threshold: 125px, horizontal swipe from left edge: 90px).
- Adaptive header height based on screen size (110-200px on Android, scaled linearly between 700-855px screen heights).
- Content injection via `slivers` (raw slivers) or `listWidgets` (auto-wrapped in `SliverList`).

**PopupFramework** wraps every bottom sheet. It provides:
- A title (left-aligned on Android), optional subtitle, optional icon.
- 18px horizontal padding, safe area bottom padding.
- A close button on full-screen layouts.

### What Is Good About It

- Every page and popup in the app looks and feels consistent without developers thinking about it. The framework handles scroll behavior, header collapse, safe areas, padding, and gesture dismissal.
- New pages are trivially created: pass a title, pass content widgets, done. The structural boilerplate is zero.
- Adaptive header sizing means the design works across phone sizes without manual breakpoints per page.

### What to Keep

- **A single base page scaffold for all pages.** Every Variance page should extend (or compose) a common page widget that handles: app bar behavior, scroll view setup, safe area padding, content width constraints, and consistent spacing.
- **A single base popup scaffold for all bottom sheets.** Title, padding, close affordance, max width -- standardized.
- **Adaptive sizing based on screen dimensions.** Dynamic header heights, constrained content widths on larger screens.

### What to Change

- **Decompose the monolith.** Cashew's `PageFramework` is 1,336 lines because it handles too many concerns: scroll tracking, animation controllers, drag-to-dismiss, header rendering, fab positioning, responsive layout. We separate these into composable pieces:
  - `VarianceScaffold` -- handles safe areas, app bar slot, content slot, optional FAB slot.
  - `CollapsibleHeader` -- the scroll-aware animated header, usable within the scaffold.
  - `DismissiblePage` -- optional mixin or wrapper for drag-to-dismiss behavior.
  - `VarianceBottomSheet` -- the popup scaffold, kept deliberately small.
- **No platform branching in the scaffold.** Cashew's `PageFramework` checks `PlatformOS.isIOS` in 10+ places for header height, title alignment, and gesture behavior. We target Android only. One code path.
- **Width constraints from a theme/responsive utility.** Cashew computes constrained widths via `getHorizontalPaddingConstrained()` -- a function with complex branching. We define responsive breakpoints in a centralized utility and reference them from the scaffold, not inline.
- **Content injection via slots, not parameter overloading.** Cashew's `PageFramework` has dozens of optional parameters for every customization. We use a slot-based API (named child parameters) that is explicit about what goes where.

---

## Pattern 7: Composable Filter Expressions

### What Cashew Does

Cashew's most well-designed subsystem is its composable filter expression architecture (lines 5773-6456 of `tables.dart`). Every list and aggregation query accepts filter parameters and composes them into a single Drift `Expression<bool>`:

| Function | Purpose |
|---|---|
| `onlyShowIfFollowsSearchFilters()` | Master filter accepting a `SearchFilters` object (income/expense, paid/unpaid, date range, amount range, title/note search, transaction types, wallet/category/budget/objective PKs) |
| `onlyShowTransactionBasedOnSearchQuery()` | Full-text-like search across transaction name, note, category name, subcategory name, amount, and parsed date text |
| `onlyShowIfFollowsFilters()` | Budget-specific filters (shared, added, income, debt/credit, objectives, balance corrections) |
| `onlyShowBasedOnTimeRange()` | Date range filtering with special handling for custom budget periods |
| `isInCategory()` | Category include/exclude list filtering |
| `onlyShowBasedOnWalletFks()` | Wallet-level filtering |

These are pure expression builders. Each returns an `Expression<bool>` that composes with others via `&` (AND) and `|` (OR). Any query can apply any combination of filters by chaining these builders.

### What Is Good About It

- Clean separation of filter logic from query logic. The filters do not know what query they are part of.
- High reusability. The same `onlyShowIfFollowsSearchFilters()` is used by the transactions list, budget calculations, category totals, and export.
- Type-safe at the Drift level -- `Expression<bool>` compiles to valid SQL WHERE clauses.
- Incrementally composable. Adding a new filter dimension requires writing one new builder function, not modifying every existing query.

### What to Keep

- **Pure expression builders as the filter pattern.** Every filter dimension is an independent function that returns `Expression<bool>`. Queries compose them freely.
- **A `SearchFilters` data class as the transport object.** A single typed class carries all active filters, serializable for persistence.
- **Reuse across all query contexts.** Transaction lists, category totals, budget progress, net worth -- all share the same filter infrastructure.

### What to Change

- **Extract filters out of the database class.** Cashew defines all filter functions inside the 7,667-line `FinanceDatabase` class. We define filter builders in a separate `filters/` directory, organized by domain:
  - `filters/transaction_filters.dart` -- date range, amount range, search query, status, purpose
  - `filters/account_filters.dart` -- account PKs, account type
  - `filters/category_filters.dart` -- category PKs, include/exclude
  - `filters/entry_filters.dart` -- debit/credit side, currency
- **DEB-aware filters.** Cashew filters on transactions only. Our filter expressions operate on both transactions and ledger entries. For example, "show all expenses over 5000" filters on transactions, but "show all debits to account X" filters on entries. The expression builders must work with both Drift table types.
- **No JSON-in-columns.** Cashew stores category PK lists and budget filter flags as JSON strings in text columns, then uses `String.contains()` checks in Dart (not SQL) to apply them. We use proper junction tables for many-to-many relationships (e.g., budget-to-category inclusions). This keeps filtering entirely in SQL.
- **Immutable filter state.** Cashew mutates filter parameters in place. Our `SearchFilters` class is immutable (via `freezed` or manual `copyWith`). Filter changes produce new instances; the Cubit compares old and new and re-queries only if filters actually changed.
- **FTS for search.** Cashew uses `LIKE '%query%'` for text search -- no indexes, no stemming, case-insensitive via collation. If search performance matters at scale (10k+ transactions), we evaluate SQLite FTS5 as a dedicated search index. For v1, `LIKE` is acceptable with proper column indexes.

---

## Pattern 8: Three-Tier Animation Opt-Out System

### What Cashew Does

Cashew implements three levels of animation fidelity that users can choose between:

1. **Full animations** (default). All transitions, elastic curves, pie chart reveals, breathing widgets, and shadows are active.

2. **Reduced animations.** Controlled by `appStateSettings["appAnimations"]` (an `AppAnimations` enum). When not set to `all`, animation durations become `Duration.zero` and some widgets skip their animation entirely. The layout and content remain identical; only motion is removed.

3. **Battery saver mode.** `appStateSettings["batterySaver"]` disables box shadows (via `boxShadowCheck()` returning `null`) and all decorative animations. Animation widgets check this flag and return their child directly without wrapping in animation controllers.

Every animation widget in the app has a bailout path:

```dart
// Typical pattern in animation widgets:
if (appStateSettings["batterySaver"]) return child; // skip animation entirely
```

### What Is Good About It

- Accessibility-conscious. Users with motion sensitivity can reduce or eliminate animations without losing functionality.
- Battery-aware. Shadow rendering and continuous animations (breathing, rotation) are the most GPU-intensive elements and are the first to go.
- Graceful degradation. The app works identically at all three tiers -- only the visual polish changes.
- Every animation widget is independently responsible for its bailout check, so the system works without a central coordinator.

### What to Keep

- **The three-tier concept.** Full / reduced / minimal is the right granularity. Material 3 respects `MediaQuery.disableAnimations`, and Android exposes "Remove animations" in developer options. We should honor both system settings and an in-app override.
- **Per-widget bailout checks.** Each animation widget decides its own degradation behavior. A `CountNumber` widget can fall back to showing the final value instantly. An `AnimatedExpanded` can snap to its final size.
- **Shadow removal in battery saver.** Box shadows are expensive and purely cosmetic.

### What to Change

- **System integration, not just a settings flag.** Cashew only checks its own `appStateSettings["batterySaver"]` flag. We integrate with Android's `MediaQuery.platformBrightness`, `MediaQuery.disableAnimations`, and battery-saver API (`Battery` package or platform channel). When the OS is in battery saver mode, we automatically switch to reduced animations. Users can override in either direction.
- **A centralized `MotionConfig` via InheritedWidget or Riverpod provider.** Cashew checks `appStateSettings` (a global mutable map) in every animation widget. We provide the animation tier via `MotionConfig.of(context)` or a Riverpod provider, making it testable and mockable. Widget tests can set `MotionConfig.tier = AnimationTier.none` to skip all animation logic during test runs.
- **Respect `AccessibilityFeatures.reduceMotion`.** Flutter provides `MediaQueryData.accessibleNavigation` and `MediaQueryData.disableAnimations`. We check these in addition to our custom setting. If the OS says reduce motion, we reduce motion -- even if the user has not toggled our in-app setting.
- **No global mutable state.** Cashew reads `appStateSettings["batterySaver"]` directly in widget `build()` methods. We read from the DI-provided config. State changes propagate reactively through the widget tree, not via imperative refresh.

---

## Bonus Finding 1: Exchange Rate API (fawazahmed0 via jsDelivr)

Cashew uses the [fawazahmed0/exchange-api](https://github.com/fawazahmed0/exchange-api), served via jsDelivr CDN:

```
https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json
```

Key characteristics:
- **Free, no API key required.** No registration, no rate limits documented.
- **CDN-served** via jsDelivr (global edge caching, high availability).
- **537 currencies** including fiat and crypto (BTC, ETH, ADA, DOGE, etc.).
- **Updated daily.** Only latest rates; no historical endpoint used by Cashew.
- **Response format:** `{"date": "2024-01-15", "usd": {"eur": 0.912, "inr": 83.12, ...}}`

**Evaluation for Variance:**
- **Pros:** Zero cost, zero auth complexity, supports crypto, CDN reliability.
- **Cons:** No SLA, no guaranteed uptime, no historical rates API, no rate-limit documentation, single maintainer open-source project.
- **Recommendation:** Use as the primary source for v1. Cache aggressively in a Drift table. If the API goes down or is deprecated, the cached rates continue to work, and we can swap to another provider (exchangerate.host, Open Exchange Rates) by changing one URL. The abstraction cost of a pluggable rate provider is near zero.

---

## Bonus Finding 2: Category Icon Library (277 Curated PNGs with Search Tags)

Cashew does NOT convert emojis to icons. It provides two completely independent paths:

1. **277 curated PNG illustrations** (`assets/categories/`), each with ~10 search tags and a suggested category name. The icons are flat-design, colored PNGs (Flaticon/Freepik style). Users search by tag in a grid picker. Selecting an icon auto-suggests a category name (e.g., `apple.png` suggests "Food").

2. **Raw emoji input.** Users type an emoji from their keyboard. The emoji is stored as a Unicode string and rendered as text using the device's native emoji font. No conversion, no custom rendering.

These two paths are mutually exclusive on a category: setting one clears the other.

**Evaluation for Variance:**
- **We chose `material_symbols_icons` package** (per PRD decision: curated subset bundled). This gives us vector SVG icons that scale cleanly, support tinting/theming, and do not require 277 PNG assets in the bundle.
- **The tag-based search UX is worth stealing.** Cashew's icon picker is effective because each icon has ~10 semantic tags. We should build a similar search-tagged metadata structure for our Material Symbols subset.
- **Emoji as a secondary path is low-cost UX value.** Even though we use Material Symbols as the primary icon set, allowing emoji input as an alternative costs almost nothing to implement (one text field, one regex filter, store as a string). Consider as a v1 or v2 addition.
- **The auto-name suggestion pattern** (selecting an icon pre-fills the category name) is a nice UX touch that reduces friction during category creation.

---

# Engineering Intelligence Report -- Part B (Sections 5-8)

**Date:** 2026-04-15
**Author:** Lead Engineer
**Sources:** Reports 01, 03, 04, 05, 06, 08, 09, 10
**Audience:** Founder + TPM (for SDS planning input)


## 6. Security & Data Integrity Plan

Cashew's security report (Report 05) identified 4 CRITICAL, 5 HIGH, and 6 MEDIUM vulnerabilities. This section splits them into what we must solve at v1 launch versus what can wait for v2, based on our threat model: a local-first, zero-network, single-user app on Android.

### 6.1 Threat Model Context

Variance's attack surface is fundamentally smaller than Cashew's because we have no network calls, no Firebase, no Google Sign-In, no cloud sync, and no shared budgets. Our threat model is:

- **Physical device access** (stolen phone, shared device)
- **Malicious apps on the same device** (reading our database file, or our SharedPreferences)
- **Deep link injection** (v2/v3 if we add deep links)
- **Backup file theft** (v2 when we add backup/restore)
- **Supply chain** (compromised dependencies)

### 6.2 MUST Have at v1 Launch

#### 6.2.1 Database Encryption (SQLCipher)

Cashew stores all financial data as plaintext SQLite (Report 05, C1). This is the single most exploitable vulnerability -- any app with storage permissions, or anyone with physical access to a rooted/unlocked device, can read the entire financial history.

**Variance v1 plan:**
- Use `sqlcipher_flutter_libs` + Drift's encrypted database support.
- Encryption key derived from a user-provided PIN or biometric-backed keystore key.
- Key stored in Android Keystore (hardware-backed where available), accessed via `flutter_secure_storage`.
- On first launch, the database is created encrypted. No migration from unencrypted to encrypted -- we start encrypted.
- Performance impact: SQLCipher adds ~5-15% overhead on read/write operations. For a local-first app this is acceptable.

#### 6.2.2 Secure Storage for Sensitive Settings

Cashew stores everything -- including user email, auth tokens, and all 170+ settings -- in plaintext SharedPreferences (Report 05, C2). SharedPreferences on Android is an XML file readable by any app with root access.

**Variance v1 plan:**
- Use `flutter_secure_storage` (backed by Android EncryptedSharedPreferences) for any sensitive value: encryption key material, biometric config, future API keys.
- Non-sensitive settings (theme, locale, display preferences) can stay in SharedPreferences -- there is no security risk in an attacker knowing your preferred date format.
- Clear separation: `SecureSettingsRepository` for secrets, `SettingsRepository` for preferences. Different storage backends, same interface pattern.

#### 6.2.3 Biometric / PIN Authentication

Cashew's biometric implementation has a bypass vulnerability: importing a database file auto-authenticates and disables `requireAuth` (Report 05, M1). The `requireAuth` flag itself is in plaintext SharedPreferences.

**Variance v1 plan:**
- Use `local_auth` for biometric authentication gating the app.
- The auth-required flag must be stored in `flutter_secure_storage`, not SharedPreferences.
- No bypass on any code path. If biometrics fail, the user retries or enters their PIN. Period.
- The biometric gate protects the app launch. The SQLCipher key protects the data at rest. These are two separate security layers.

#### 6.2.4 Input Validation at Every Boundary

Cashew has no systematic input validation (Report 05, Section 3.3). Drift's parameterized queries protect against SQL injection at the local level, but there is no schema-level validation of amounts, dates, or string lengths.

**Variance v1 plan:**
- Validate all user input in the application layer before it reaches the repository.
- Amount validation: must be positive, must not exceed a configurable maximum (default: 999,999,999.99), must have at most N decimal places (based on currency).
- String validation: max length enforced at schema level (Drift column constraints) AND at form level (Flutter `TextInputFormatter`).
- Date validation: transaction date must not be in the future beyond a configurable tolerance (default: 1 day for timezone edge cases).
- Category/account FK validation: referenced entities must exist and not be soft-deleted.

#### 6.2.5 Foreign Key Enforcement

Cashew never sets `PRAGMA foreign_keys = ON` (Report 01, Section 1.3). Their `fixWandering*` cleanup methods confirm that orphaned records occur in production.

**Variance v1 plan:**
- Enable `PRAGMA foreign_keys = ON` in the Drift database setup callback. This is a single line of configuration that prevents an entire class of data integrity bugs.
- Define explicit `ON DELETE` actions for every FK: `RESTRICT` for entries referencing accounts (prevent deleting accounts with entries), `CASCADE` for entries referencing transactions (delete entries when transaction is deleted).
- Soft-delete means we rarely hit FK constraints on delete, but the safety net must be there.

### 6.3 Can Wait for v2

#### 6.3.1 Backup Encryption

Cashew uploads raw SQLite files to Google Drive (Report 05, C4). We do not have backup/restore in v1, so this is deferred. When we add it in v2:

- Backup files must be encrypted with a user-provided passphrase (separate from the SQLCipher key).
- Use AES-256-GCM for the backup encryption layer.
- Include a checksum (SHA-256) in the backup metadata for integrity verification on restore.
- Validate the imported database structure (schema version, table existence, FK integrity) before overwriting the active database.

#### 6.3.2 Deep Link Safety

Cashew's deep link handler creates transactions without user confirmation (Report 05, H3). We do not have deep links in v1. When we add them:

- Validate scheme, host, and path against an explicit allowlist.
- Never auto-create entities from deep link parameters. Always route to a pre-filled form for user confirmation.
- Rate-limit deep link processing (one per second max).

#### 6.3.3 Exchange Rate API Key Security

When we add exchange rate fetching in v3:

- API keys (if any) must be stored via `flutter_secure_storage`, never hardcoded.
- Use `--dart-define-from-file` for build-time configuration.
- Rate-limit API calls and implement exponential backoff on failure.

### 6.4 Security Checklist Summary

| Control | Cashew Status | Variance v1 | Variance v2 |
|---------|---------------|-------------|-------------|
| Database encryption at rest | None (C1) | SQLCipher | -- |
| Secure storage for secrets | None (C2) | flutter_secure_storage | -- |
| Biometric auth | Bypassed on import (M1) | No bypass, auth flag in secure storage | -- |
| FK enforcement | OFF (orphans occur) | ON from day one | -- |
| Input validation | None systematic | Schema + form + application layer | -- |
| Backup encryption | N/A (unencrypted raw files) | N/A (no backup in v1) | AES-256-GCM |
| Deep link validation | None (H3) | N/A (no deep links in v1) | Allowlist + confirmation |
| API key storage | Hardcoded (C3) | N/A (no APIs in v1) | flutter_secure_storage |
| Firestore rules | Missing (H1) | N/A (no cloud) | N/A (never) |
| Test coverage | Zero (L2) | 80% minimum | 80% minimum |

---

## 7. Technical Debt Lessons

Cashew's codebase is a case study in how organic growth without architectural discipline creates compounding debt. Every anti-pattern below is something we can avoid by making the right decision once, early.

### 7.1 File Organization: The God File Problem

**What happened:** `tables.dart` is 7,667 lines (Report 01, Section 5.2). It contains ALL table definitions, ALL enums, ALL type converters, ALL queries, ALL CRUD methods, ALL filter expressions, ALL migration logic, and ALL sync processing. The second-largest file is `addTransactionPage.dart` at 5,207 lines (Report 04, Section 1.4), which contains the entire transaction entry flow -- UI, validation, business logic, and state management in a single widget.

**Why it happened:** Drift encourages putting table definitions and the database class in the same file (the generated `.g.dart` file depends on it). Once the database class was there, queries naturally followed. Once queries were there, CRUD methods followed. Once CRUD methods were there, filter expressions followed. The file grew by accretion, never by design.

**How we avoid it:**
- Drift supports partial files and included `.drift` files. Table definitions go in separate `.drift` schema files, organized by domain (accounts, entries, transactions, categories, templates).
- The database class itself is thin -- it only declares the tables. Query classes (DAOs in Drift terminology) are separate files, one per domain.
- Repository implementations wrap DAOs and add business logic. They are separate files.
- File size guardrail: our coding standard (200-400 lines typical, 800 max) is enforced from commit one. The TPM must reject any PR that introduces a file over 800 lines.

### 7.2 Schema Migration Strategy: 46 Versions, Two Styles

**What happened:** Cashew has 46 schema versions with two incompatible migration styles (Report 01, Section 2.2):
- Versions 9-32: manual `addColumn`/`alterTable` calls wrapped in `if (from <= N)` guards
- Versions 33-46: Drift's `migrationSteps()` API with typed step callbacks

The transition point (v33) means any user upgrading from pre-v33 runs through both systems sequentially. The v36-37 migration was a massive PK type change (integers to UUIDs) that touched every table. Every migration step is wrapped in try-catch that swallows errors and continues -- a defensive pattern that masks corruption.

**How we avoid it:**
- Use Drift's `migrationSteps()` from version 1. One style, forever.
- Use Drift's schema verification tests: generate schema snapshots for each version and write tests that verify upgrade paths. Drift provides tooling for this (`drift_dev` schema generation).
- Never swallow migration errors. If a migration fails, surface it to the user and offer to export a backup before retrying. Silent continuation after a failed migration is how data gets corrupted.
- Design schemas with UUID primary keys from day one (Cashew's v36 int-to-UUID migration was a massive, risky change that we will never need).
- Maintain a migration test matrix: test upgrades from every released version to the current version. This is cheap to automate and prevents the "works on clean install, breaks on upgrade" class of bugs.

### 7.3 Testing Discipline: Zero Tests

**What happened:** Cashew has exactly one test file, which is the default Flutter scaffold placeholder. It does not import or reference any actual app code (Report 05, Section 10.4). There are no unit tests, no integration tests, no widget tests, and no CI pipeline. In 120K lines of Dart across 245 files, zero lines are tested.

**Why it matters beyond code quality:** The absence of tests is why Cashew cannot refactor. The God file cannot be split because there are no tests to verify that the split preserves behavior. The inverted `paid` semantics for credit/debt cannot be fixed because there are no tests to verify the fix does not break filtering. Every technical debt item compounds because refactoring without tests is gambling.

**How we avoid it:**
- TDD is mandatory per our development workflow. Tests are written before implementation.
- 80% coverage minimum, enforced by CI.
- Domain layer (DEB engine, balance calculation, correction chain logic) targets 95%+ coverage with property-based tests (the `sum(debit) == sum(credit)` invariant is a natural property to test).
- Repository layer targets 80%+ with integration tests against an in-memory SQLite database.
- Widget layer: smoke tests for critical flows (transaction entry, account creation), not exhaustive widget tests.
- The DEB engine is the single most important piece of code in the app. It must have exhaustive test coverage before any UI is built on top of it.

### 7.4 State Management Evolution: Global Mutable Map

**What happened:** Cashew's entire settings and state system is a global `Map<String, dynamic>` with 170+ keys, mutated in place, accessed directly from widget `build()` methods, and refreshed via `GlobalKey`-based imperative calls to `refreshState()` on 15+ page-level widgets (Report 03, Sections 2.1-2.6). There is no type safety on keys or values. The `updateSettings()` function requires the caller to specify which pages need refreshing by index number.

**Why it happened:** It started as a simple key-value store for a few preferences. Each new setting added a key. Each new page added a GlobalKey. The pattern scaled from 10 settings to 170 without anyone stopping to redesign it.

**How we avoid it:**
- Typed, immutable settings classes from day one. Each settings domain (appearance, locale, security, transaction defaults) is a separate `@freezed` class with compile-time type safety.
- State management via Riverpod or BLoC -- reactive, testable, no GlobalKeys.
- Settings persistence via a structured repository (not a flat JSON blob). Each settings domain can have its own storage strategy (SharedPreferences for non-sensitive, flutter_secure_storage for sensitive).
- No global `late` variables for infrastructure. Database, settings, and platform services are provided via dependency injection (Riverpod providers or a service locator like `get_it`).

### 7.5 Forked Packages: Three Abandoned Dependencies

**What happened (Report 10):** Cashew forks and vendors three UI packages:
1. `sliding_sheet` v0.5.2 (abandoned since 2021) -- 6 modifications for Impeller rendering, keyboard dismiss, Flutter 3.x APIs
2. `implicitly_animated_reorderable_list` v0.4.2 (abandoned since 2021) -- 2 modifications for null safety and Dart 3 compatibility
3. Flutter's own `SliverReorderableList` (copied from SDK source) -- modified for async reorder callback

These forks require permanent maintenance by the app developer. When Flutter ships a new rendering engine change or API deprecation, every forked package must be manually updated.

**How we avoid it:**
- **Bottom sheets:** Evaluate `wolt_modal_sheet` or build a custom solution. Never depend on a package last published in 2021 for core UI. Keyboard interaction must be first-class from day one (four of six `sliding_sheet` mods are keyboard-related).
- **Animated lists:** Evaluate whether Flutter's stock `SliverAnimatedList` (significantly improved since 2021) plus `diffutil_dart` can replace the vendored animated list package.
- **Reorderable lists:** If we need async reorder (likely for account/category reordering in v2), wrap Flutter's built-in widget with an async bridge rather than copying 1,446 lines of framework code. The modification surface is small.
- **Dependency policy:** Prefer packages published within 12 months, with Dart 3 SDK constraints, and active issue triage. If we must vendor, isolate the customization layer so that upgrading the base package does not require re-applying every modification.
- **Test on Impeller from day one.** Cashew's Impeller rendering bug in `sliding_sheet` affected every bottom sheet in the app. We must run `flutter run --enable-impeller` as part of our development loop.

### 7.6 Technical Debt Summary

| Debt Category | Cashew Reality | Variance Prevention |
|---------------|---------------|---------------------|
| God files | 7,667-line tables.dart, 5,207-line addTransactionPage.dart | 800-line max, enforced by code review |
| Migration sprawl | 46 versions, 2 styles, silent error swallowing | Single style (migrationSteps), migration tests, fail loudly |
| Zero tests | Placeholder test file only | TDD mandatory, 80% coverage, CI-enforced |
| Global mutable state | 170-key untyped Map, 15+ GlobalKeys | Freezed settings, Riverpod/BLoC, DI |
| Forked packages | 3 abandoned forks requiring manual maintenance | Actively maintained deps, wrap instead of fork |
| No FK enforcement | PRAGMA foreign_keys never enabled, orphans in production | ON from day one, explicit ON DELETE rules |
| Magic values | PK "0" = primary wallet, PK "0" = balance correction category, amount -1 = difference-only loan | Named constants, enum types, no sentinel values |
| JSON-in-columns | Category PKs, budget filters stored as JSON strings in text columns | Junction tables, proper relational modeling |

---

## 8. Estimated Complexity Assessment

This section ranks Variance v1 features by implementation difficulty, informed by what Cashew's equivalent required. The purpose is to give the TPM a realistic picture of where engineering time will concentrate.

### 8.1 Complexity Ranking

| Rank | Feature | Complexity | Estimated Effort | Rationale |
|------|---------|-----------|-----------------|-----------|
| 1 | DEB Engine | XL | 3-4 weeks | Novel. No reference implementation in Flutter. The balance equation invariant, entry generation rules, correction chain, and void logic must be correct from day one. This is the foundation everything else depends on. |
| 2 | Transaction Entry Form | XL | 3-4 weeks | Cashew's equivalent is 5,207 lines (Report 04, Section 1.4). Ours is more complex: DEB requires source + destination accounts, compound groups for transfers with fees, correction vs void choice on edit. Must be split into small composable widgets from the start. |
| 3 | Multi-Currency with Exchange Rate Capture | L | 2-3 weeks | Cashew only stores current rates and converts at display time (Report 08). We capture the rate at transaction time and store it with entries. This means the entry form needs inline rate display and override UI, the DEB engine must accept rates per entry, and the balance query must handle mixed-rate entries correctly. |
| 4 | Recurring Template Materialization | L | 2 weeks | Cashew's lazy materialization (one-at-a-time on pay, Report 04, Section 3.2) is simpler than our design. We materialize ALL occurrences at template creation, which means: generating N transactions at once, each with correct DEB entries, handling the 4-state lifecycle (active/paused/archived/deleted), and updating future occurrences when the template is modified. The upfront materialization is more work than lazy generation. |
| 5 | Installment Tracking | L | 1.5-2 weeks | Not present in Cashew at all (Report 06 confirms this is a gap feature). We need: materialization of all installment occurrences at creation, 4-way running total (total, paid, remaining, overdue), compound group linking, and the installment detail view. Depends on both the DEB engine and the recurring template system. |
| 6 | Correction / Void Chain | M | 1-1.5 weeks | Cashew has no equivalent -- they edit in place (Report 04, Section 1.5). We need: reversal entry generation (negating every entry of the original transaction), correction entry generation (new entries reflecting the updated values), chain traversal (corrects_transaction_id), and UI to show the final corrected state while hiding the chain. The DEB engine handles the math; the complexity is in the UI presentation and the decision flow (when to offer correction vs void). |
| 7 | Navigation Framework | M | 1 week | Bottom nav bar with 3 tabs (Home, Accounts, Settings). Cashew uses `LazyIndexedStack` with `KeepAliveClientMixin` on every page (Report 06, Section 1.2). We use GoRouter with `ShellRoute`. The complexity is not in the navigation itself but in the tab state preservation, FAB behavior (context-dependent), and the search overlay (global across all transactions). |
| 8 | Search (FTS5 + Fuzzy) | M | 1-1.5 weeks | Cashew uses SQL LIKE (Report 04, Section 5.1). We are implementing FTS5 with fuzzy re-ranking. FTS5 setup and sync triggers are ~2 days. The fuzzy scoring algorithm (fzf-style) is ~2-3 days. The search UI (overlay, result list, filter chips) is ~2-3 days. The technical risk is low; the work is just non-trivial. |
| 9 | Account System | M | 1 week | Cashew's wallet model is simple (one type, one currency, Report 01, Section 1.2). Ours has 8 account categories with per-type fields (credit card limits, loan terms, etc.), per-currency EQ accounts (lazy-created), and the balance reconciliation flow. The schema is straightforward; the complexity is in the per-category field validation and the EQ account lifecycle. |
| 10 | Home Screen Dashboard | M | 1 week | Greeting, net worth (single SQL query), monthly summary (income/expense totals), transaction list (paginated), alerts (overdue recurring, payment reminders). Each component is independently simple. The complexity is in composing them with correct reactive data flows and ensuring performance on first load. |
| 11 | Transaction Categories | S | 3-4 days | Two-level hierarchy (category -> subcategory), separate for income and expense. Cashew's model is similar (Report 01, Section 1.2, self-referential FK). The main work is the category picker UI (icon grid, search, emoji support) and default category seeding. |
| 12 | Settings System | S | 3-4 days | Typed, immutable settings classes with Freezed. Per-domain persistence. The work is scaffolding, not complexity. But it must be done before anything else uses settings. |
| 13 | Onboarding | S | 2-3 days | 5-step wizard: welcome, home currency, first account creation, default categories confirmation, completion. Minimal business logic; primarily UI. |

### 8.2 Critical Path Analysis

The dependency chain determines the build order:

```
Settings System (foundation)
    |
    v
DEB Engine (core domain logic)
    |
    +---> Account System (depends on DEB for balance queries)
    |         |
    |         v
    |     Transaction Entry Form (depends on accounts + DEB)
    |         |
    |         +---> Multi-Currency (extends entry form + DEB)
    |         +---> Correction/Void Chain (extends entry form + DEB)
    |         +---> Photo Attachments (extends entry form)
    |
    +---> Transaction Categories (parallel with accounts)
    |
    +---> Search (depends on transactions existing)
    |
    v
Recurring Template Materialization (depends on DEB + entry form)
    |
    v
Installment Tracking (depends on recurring templates + DEB)
    |
    v
Navigation Framework (depends on all screens existing)
    |
    v
Home Screen Dashboard (depends on all data being queryable)
    |
    v
Onboarding (last -- needs all entity creation flows working)
```

### 8.3 Risk Assessment

| Feature | Technical Risk | Why |
|---------|---------------|-----|
| DEB Engine | HIGH | No Flutter reference implementation. Correctness is existential -- a bug here corrupts every balance in the app. Must be proven correct through exhaustive property-based tests before any UI is built. |
| Transaction Entry Form | MEDIUM | The UI complexity is high (Cashew's 5,207 lines prove this), but the patterns are known. Risk is in scope creep -- the form must do a lot, and resisting the urge to build it monolithically requires discipline. |
| Multi-Currency | MEDIUM | The exchange rate capture and storage is straightforward. The risk is in cross-currency balance aggregation queries getting subtly wrong, especially when the same account has entries in different currencies (which should not happen in our model, but edge cases around corrections/voids need careful thought). |
| Recurring Materialization | MEDIUM | Upfront materialization of all occurrences is our chosen design. The risk is in modification propagation: when a user edits a template, how do we update the N unmaterialized future transactions? This needs clear rules before implementation. |
| Installments | LOW | Conceptually straightforward once DEB and recurring templates work. The tracking view is novel but not technically risky. |
| FTS5 Search | LOW | Well-documented SQLite feature. Drift supports raw SQL for FTS5 queries. The fuzzy scoring is a known algorithm. |

### 8.4 Effort Summary

| Complexity | Features | Combined Effort |
|-----------|---------|----------------|
| XL (3-4 weeks each) | DEB Engine, Transaction Entry Form | 6-8 weeks |
| L (1.5-3 weeks each) | Multi-Currency, Recurring Templates, Installments | 5.5-7.5 weeks |
| M (1-1.5 weeks each) | Correction/Void, Navigation, Search, Accounts, Home Screen | 5-6.5 weeks |
| S (2-4 days each) | Categories, Settings, Onboarding | 1.5-2 weeks |
| **Total estimate** | | **18-24 weeks (4.5-6 months)** |

This estimate assumes one developer working full-time. Parallelization is possible for some M and S items once the DEB engine is stable (Categories, Settings, and Onboarding can be built in parallel with the Transaction Entry Form). The critical path runs through DEB Engine -> Account System -> Transaction Entry Form -> Multi-Currency -> Recurring Templates -> Installments, which is approximately 14-18 weeks sequentially.

The DEB engine is the single highest-risk, highest-effort item. If it takes longer than 4 weeks, the entire timeline shifts. I recommend a 2-week spike on the DEB engine before committing to a full timeline -- build the core `createTransaction` function with entry generation, the balance query, and the correction chain, prove them with 50+ property-based tests, and use that experience to refine the estimate.
