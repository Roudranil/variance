---
name: Engineering Anti-Patterns to Avoid
status: approved
owner: reviewer
created: 2026-04-15
last_updated: 2026-04-15
depends_on: [enemy-recon/01-architecture-data-model.md, enemy-recon/03-state-management-performance.md, enemy-recon/05-security-infrastructure.md]
outputs_to: [02-technical/sds.md]
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
