# Engineering Intelligence Report -- Part B (Sections 5-8)

**Date:** 2026-04-15
**Author:** Lead Engineer
**Sources:** Reports 01, 03, 04, 05, 06, 08, 09, 10
**Audience:** Founder + TPM (for SDS planning input)

---

## 5. Performance & Scalability Recommendations

Cashew's performance architecture is characterized by deferred optimization: it works fine with small datasets and falls apart predictably as data grows. Every performance problem below was discoverable from the source code without load testing. We know exactly where the walls are.

### 5.1 Balance Calculation: The Per-Wallet Loop

**Cashew's approach:** Every total computation -- net worth, budget progress, spending summary -- follows the same pattern (Report 01, Section 3.3; Report 03, Section 3.5):

1. Loop through all wallets in `AllWallets.list`
2. For each wallet, issue a separate `SELECT SUM(amount)` query filtered by `walletFk`
3. Multiply each result by `amountRatioToPrimaryCurrency()`
4. Merge all per-wallet streams with `StreamZip` and reduce to a single total

This is O(W) database queries per aggregation, where W is the number of wallets. For a user with 5 wallets, every home screen refresh fires 5 separate SQL queries just for net worth, plus 5 more for each budget, plus 5 more for spending summary. With reactive streams, these all re-fire on every transaction change.

**Variance recommendation:** SQL-level aggregation from day one.

- Use a single SQL query with `GROUP BY wallet_fk` (or `GROUP BY currency`) and handle the exchange rate multiplication in Dart after the single round-trip. This reduces O(W) queries to O(1).
- For DEB specifically: our per-currency EQ entries mean balance queries can `SUM` entries grouped by currency in a single query. No wallet iteration needed.
- For home screen net worth: maintain a materialized view or cached aggregate that updates reactively via Drift stream watchers on the entries table. One stream, one query, one rebuild.

### 5.2 Period Aggregation: The O(n) Budget Loop

**Cashew's approach:** The `getBudgetDate()` function finds the current period of a recurring budget by iterating forward from the start date up to 10,000 times (Report 03, Section 3.9). For a daily budget created a year ago, that is 365 iterations. For one created 3 years ago, 1,095.

**Variance recommendation:** O(1) arithmetic.

- `periods_elapsed = floor((today - start_date) / period_length)`
- `current_period_start = start_date + (periods_elapsed * period_length)`

This is standard date arithmetic. When we build budgets in v2, this must be O(1). No iterative search.

### 5.3 List Rendering: KeepAlive Overuse

**Cashew's approach:** Every home screen section is wrapped in `KeepAliveClientMixin` (Report 03, Section 3.3; Report 06, Section 1.2). This preserves scroll position across tab switches but keeps all widget subtrees alive in memory permanently. With 13 configurable home screen sections, all containing reactive `StreamBuilder` widgets watching database queries, this means all 13 sections maintain active database subscriptions even when off-screen.

**Variance recommendation:** Selective keep-alive with lifecycle management.

- Use `AutomaticKeepAliveClientMixin` only for the active tab's primary list.
- For off-screen tabs, dispose stream subscriptions and rebuild on tab switch. The 100-200ms rebuild cost is acceptable versus the permanent memory and CPU cost of 13 concurrent database watchers.
- For transaction lists: implement cursor-based pagination. Cashew uses `DEFAULT_LIMIT = 100000` (Report 01, Section 3.5) -- effectively loading every transaction ever created into a single list. Our v1 should paginate at 50-100 items with infinite scroll.

### 5.4 Search Indexing: SQL LIKE Is Not Search

**Cashew's approach:** All search uses `LIKE '%query%'` with `Collate.noCase` across 6+ fields via OR expressions (Report 04, Section 5.1). This is a full table scan on every keystroke (debounced at 500ms). No index can accelerate a leading-wildcard LIKE query in SQLite.

**Variance recommendation:** FTS5 (Full-Text Search) from day one.

- SQLite's FTS5 extension provides tokenized, indexed full-text search with ranking.
- Create an FTS5 virtual table mirroring the searchable columns (transaction name, note, category name, account name).
- Keep the FTS table in sync via Drift triggers or application-level writes.
- FTS5 supports prefix queries, phrase matching, and BM25 ranking -- all superior to LIKE.
- For fuzzy search (our PRD specifies fzf-style), implement a Dart-side fuzzy scorer that re-ranks FTS5 results. FTS5 handles recall (finding candidates fast); the fuzzy scorer handles precision (ranking by edit distance).
- The 500ms debounce Cashew uses is fine for LIKE but unnecessary for FTS5. We can debounce at 150-200ms for a more responsive feel.

### 5.5 Isolate Usage: One in 120K Lines

**Cashew's approach:** There is exactly one `compute()` call in the entire codebase -- for line graph point calculation (Report 03, Section 3.6). All other financial computation (balance calculations, spending summaries, category totals, budget progress) runs on the main thread.

**Variance recommendation:** Isolates for heavy computation, main thread for UI.

- **Balance computation:** For users with 1,000+ transactions, the `SUM` query itself is fast (SQLite is optimized for this), but any Dart-side post-processing (exchange rate conversion, grouping, formatting) should be offloaded to an isolate if it exceeds ~5ms.
- **Search:** FTS5 queries are fast, but fuzzy re-ranking of 100+ results should use `Isolate.run()`.
- **Reporting/analytics (v2):** Any chart data preparation that processes more than ~500 data points should use an isolate.
- **Rule of thumb:** Profile first. If a computation takes >16ms (one frame), move it to an isolate. Use `Isolate.run()` (Dart 2.19+) for one-shot computations; use long-lived isolates only for recurring heavy work.

### 5.6 Pagination Strategy

Cashew has no real pagination. Their `DEFAULT_LIMIT = 100000` means the transaction list widget attempts to render the entire transaction history. For a user adding 5 transactions/day over 3 years, that is ~5,500 transactions loaded into a single `StreamBuilder`.

**Variance recommendation:** Keyset (cursor-based) pagination.

- Use `WHERE date_created < :last_seen_date ORDER BY date_created DESC LIMIT 50` for forward pagination.
- Keyset pagination is faster than OFFSET pagination for large datasets because it uses the index directly.
- Index on `(date_created DESC, transaction_pk)` for deterministic ordering.
- The home screen transaction list loads the first 50, with infinite scroll loading the next 50 on demand.
- For search results: same pattern, but ordered by FTS5 rank score.

### 5.7 Summary: Performance Budget

| Operation | Cashew | Variance Target | How |
|-----------|--------|----------------|-----|
| Net worth computation | O(W) queries, main thread | O(1) query, main thread | SQL GROUP BY currency |
| Budget period lookup | O(n) iteration | O(1) arithmetic | Date math |
| Transaction list load | 100K limit, no pagination | 50-item pages, cursor-based | Keyset pagination |
| Search | Full table scan (LIKE) | FTS5 indexed | FTS5 virtual table |
| Spending summary | Main thread, no caching | Main thread with cached aggregates | Drift stream + cache |
| Exchange rate conversion | Per-wallet loop | Single query, Dart-side multiply | GROUP BY currency |

---

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
