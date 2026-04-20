---
name: Ideation Diff
status: current
owner: architect
created: 2026-04-20
last_updated: 2026-04-20
depends_on: []
outputs_to: []
---

# Ideation Diff — Session 2026-04-20 (Part 2: Tech Stack)

> This file records the exact changes made in this ideation session. It is overwritten each session and used as the basis for commit messages.

---

## 1. Files Modified

### `docs/06-helpers/ideation-tracker.md`

- Deliverable Checklist row 2 (SDS) status updated to reflect Section 2 complete and all 4 SDS-owned TC items resolved (TC-006, TC-009, TC-033, TC-041).
- Key Decisions Log: new row added (2026-04-20) capturing all tech stack decisions and TC resolutions from this session.

### `docs/06-helpers/ideation-diff.md`

- Overwritten with current session changes (standard per-session procedure).

### `docs/02-technical/sds.md`

**Section 2 (Tech Stack) appended after Section 1 (Architecture Overview).** No existing content was modified.

#### 2.1 Core Runtime

- Flutter SDK channel: `stable`. Version pinned via FVM (`.fvmrc`). Rationale for explicit pin documented.
- Dart SDK constraint: `>=3.4.0 <4.0.0`. Sound null safety enforced.
- Android targets: `minSdkVersion 31`, `targetSdkVersion 35`, `compileSdkVersion 35`. ABI targets listed. Dynamic color always active (no API-level conditional needed at API 31 minimum).

#### 2.2 State Management and Reactivity

- `flutter_riverpod ^2.6.1`, `riverpod_annotation ^2.3.5`, `riverpod_generator ^2.4.3` (dev), `riverpod_lint ^2.3.13` (dev).
- All five provider patterns documented with usage rules: `AsyncNotifier`, `Notifier`, `StreamProvider`, functional providers, `keepAlive` singletons.
- DI strategy: Riverpod provider graph is the composition root. No `get_it`. `keepAlive` for DB, repositories, infrastructure. Route-scoped for form notifiers. `ValueNotifier` for ephemeral widget-local state.
- Provider scoping rules defined: global, route, widget.

#### 2.3 Database and Persistence

- `drift ^2.21.0`, `drift_dev ^2.21.0` (dev), `sqlite3_flutter_libs ^0.5.0`.
- WAL mode + 5 PRAGMA settings documented with rationale (`journal_mode WAL`, `foreign_keys ON`, `synchronous NORMAL`, `busy_timeout 5000`, `cache_size -20000`).
- Migration strategy: versioned hand-written migrations only. Drift `SchemaVerifier` for dev-time drift detection. Schema JSON dumps committed per version. No destructive fallback in prod. Downgrade protection via `SchemaMismatchException`.
- DAO structure: 6 DAOs defined (TransactionDao, AccountDao, CategoryDao, TemplateDao, ExchangeRateDao, CurrencyDao).

#### 2.4 Navigation

- `go_router ^14.6.2`. `StatefulShellRoute.indexedStack` for 3-tab bottom nav.
- Full route table documented: home tab (`/`, `/transaction/new`, `/transaction/:id`, `/transaction/:id/edit`), accounts tab (`/accounts`, `/accounts/:id`, `/accounts/new`), settings tab with 5 sub-routes. Four modal routes.
- Navigation rules: `context.go` vs `context.push` distinction, onboarding redirect guard, typed route parameter validation.

#### 2.5 Data Modeling and Serialization

- `freezed_annotation ^2.4.4`, `freezed ^2.5.7` (dev) — domain layer only. No JSON annotations on domain entities.
- `json_annotation ^4.9.0`, `json_serializable ^6.8.0` (dev) — data layer DTOs, exchange rate API response parsing, backup/restore file format.
- Serialization field naming: `fieldRename: FieldRename.snake` on all `@JsonSerializable` classes.
- Separation rule: Freezed for domain, json_serializable for DTOs. Domain entities have zero serialization knowledge.

#### 2.6 Scheduling — TC-041 RESOLVED

**Decision: Hybrid WorkManager + Exact Alarm.**

- `workmanager ^0.5.2` for silent background posting sweep.
- `flutter_local_notifications ^18.0.1` for exact-alarm "remind and confirm" notifications.
- Three-component model: (1) app-launch synchronous sweep in `AppInitializer`, (2) WorkManager `PostingSweeperWorker` with 6-hour period, (3) exact alarm via `ReminderAlarmScheduler` only for `REMIND_AND_CONFIRM` templates.
- Graceful degradation: if `SCHEDULE_EXACT_ALARM` denied, remind-and-confirm templates fall back to app-launch posting with settings-screen notice.
- Permissions: `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`.
- Four options evaluated with pros/cons table.

#### 2.7 Exchange Rate — TC-006 RESOLVED

**Decision: Frankfurter API (`api.frankfurter.app`).**

- No API key required. Open-source. ECB data. ~33 major currencies.
- Five API options evaluated with comparison table (auth, limits, coverage, self-hostable). Frankfurter selected; commercial alternatives rejected for key-management friction.
- Tradeoff accepted: 33 currencies vs 170+ on commercial APIs; exotic currency pairs show "Rate unavailable" inline.
- Fetch trigger: WorkManager one-time task on app launch if last fetch > 23 hours ago. Scope: only user's active account currencies.
- `exchange_rate_cache` table schema defined (id, from_currency, to_currency, rate, fetched_at, rate_date; UNIQUE constraint; index on pair).
- Staleness table: ≤14 days silent, >14 days disclaimer, no rate = omit field.
- Architectural isolation: entirely in `lib/infrastructure/exchange_rates/`; no core compile-time dependency.

#### 2.8 Search — TC-009 RESOLVED

**Decision: SQLite FTS5 virtual table + Dart-side scoring pass.**

- Three options evaluated: pure Dart O(N) scan (rejected — 10k performance risk), FTS5-only (rejected — no field-weight ranking), FTS5 + Dart scoring (chosen).
- FTS5 virtual table schema: `transactions_fts` with `unicode61 remove_diacritics 2` tokenizer. Content sync via AFTER INSERT/UPDATE/DELETE triggers on `transactions` table.
- Two-stage pipeline: Stage 1 = FTS5 prefix + exact query returning ≤500 candidates; Stage 2 = Dart `SearchRanker` applies field-weighted composite score.
- Scoring weight table: exact title match 1.00, prefix title 0.80, prefix account name 0.70, substring title 0.60, substring description 0.30, substring category 0.25, typo-tolerant title 0.40, typo-tolerant other 0.20.
- Tiebreaker: `transaction_date DESC`.
- Typo tolerance: Levenshtein distance-1 on Dart candidate set (bounded to ≤500 rows).
- Search scope: non-deleted transactions; month filter combined with FTS5 query (TC-050).

#### 2.9 Error Handling — TC-033 (deepened in Section 2)

**Decision: `Result<T>` sealed type pattern.**

- Two options evaluated: exception-based (rejected — invisible in type signatures), Result type (chosen — compile-time exhaustive handling via sealed + switch).
- `Result<T>` sealed class: `Ok<T>` and `Err<T>` with `Failure` sealed hierarchy (`DatabaseFailure`, `ValidationFailure`, `NetworkFailure`, `NotFoundFailure`, `BusinessRuleFailure`).
- Layer-boundary rules table: Data layer wraps `DriftDatabaseException`; domain use cases never throw; presentation maps `Err` to screen error state; infrastructure converts network exceptions before crossing.
- Ledger operation failure mode table: 5 failure modes with ACID guarantee and UX response per row.
- Form state preservation: `TransactionFormNotifier` holds field values; `FormState.saveError(message)` retains all fields; SnackBar surfaces message.

#### 2.10 Code Generation Pipeline

- `build_runner ^2.4.13` (dev). Single-shot for CI; watch mode for local dev.
- Generator execution order: `drift_dev` → `freezed` → `json_serializable` → `riverpod_generator`.
- Output conventions: all `*.g.dart` and `*.freezed.dart` in `.gitignore`. CI regenerates before compilation.
- CI build sequence: 6-step pipeline documented.

#### 2.11 Testing Stack

- Test pyramid with 5 tiers and coverage targets: domain/use cases 90%, repositories/DAOs 85%, widgets all non-trivial, goldens all screens/states, integration 5 critical flows.
- `mocktail ^1.0.4` for mocking. Fakes preferred over mocks for repository boundaries.
- `alchemist ^0.8.0` for golden tests. CI `--ci` mode enforced. Fixed emulator baseline (API 34, Pixel 6).
- 5 integration test scenarios listed.

#### 2.12 Build and Release Tooling

- `flutter_launcher_icons ^0.14.3` (dev) — adaptive icon with foreground/background layers.
- `flutter_native_splash ^2.4.3` (dev) — Android 12 splash + dark mode variant.
- ProGuard/R8: keep rules for Drift, json_serializable, workmanager, flutter_local_notifications.
- Build flavors: `dev`, `staging`, `prod` with application ID suffixes. Flavor config via `dart-define-from-file`.
- Version management: founder-controlled `version` file; CI sync check with `pubspec.yaml`.

#### 2.13 Linting and Static Analysis

- `flutter_lints ^5.0.0` (dev).
- `analysis_options.yaml`: 11 additional lint rules, 3 analyzer error escalations, generated file exclusions.
- `dart format` enforced in CI (`--set-exit-if-changed`). `dart fix` run locally pre-commit.
- Pre-commit hook defined.

#### 2.14 Complete Dependency Table

- 21 production dependencies.
- 11 dev dependencies.
- 3 dependency notes: `decimal` over `double` for monetary arithmetic, `http` over `dio`, `sqlite3_flutter_libs` version sync note.

---

## 2. TC Items Resolved in This Session

| TC ID | Decision |
|-------|---------|
| **TC-006** | Exchange rate API: **Frankfurter** (`api.frankfurter.app`). No API key. ECB data. WorkManager daily fetch. `exchange_rate_cache` SQLite table. 14-day staleness. Silent failure. |
| **TC-009** | Search: **FTS5 + Dart scoring**. FTS5 virtual table with `unicode61` tokenizer. Dart `SearchRanker` applies field-weighted composite score on ≤500 FTS5 candidates. Levenshtein-1 typo tolerance. |
| **TC-033** | Error handling: **`Result<T>` sealed type**. `Ok<T>` / `Err<T>` with `Failure` hierarchy. Layer-boundary rules enforce no raw exception propagation across layers. Form state preserved on failure. |
| **TC-041** | Scheduling: **Hybrid WorkManager + Exact Alarm**. WorkManager `PostingSweeperWorker` for silent background posting. `flutter_local_notifications` exact alarms for `REMIND_AND_CONFIRM` notifications only. App-launch synchronous sweep as primary catch-up. |

---

## 3. Architectural Decisions Made This Session

| Decision | Rationale |
|----------|-----------|
| FVM for Flutter SDK pinning | Prevents silent toolchain divergence between machines and CI |
| `Decimal` type for monetary amounts | `double` forbidden for financial arithmetic; stored as INTEGER (smallest unit) in SQLite |
| `http` over `dio` | Single exchange rate endpoint; no interceptors, auth, or retry chain needed |
| Frankfurter API (no-auth) | Eliminates API key management on a local-only app; open-source, ECB data, sufficient currency coverage |
| FTS5 + Dart two-stage search | Bounds O(N) Dart work to FTS5 candidate set (≤500 rows) regardless of total transaction count; satisfies 500ms NF-3 target |
| `Result<T>` sealed type at layer boundaries | Compile-time exhaustive error handling; invisible exceptions forbidden across layer crossings |
| Versioned hand-written migrations | No auto-migration in prod; schema JSON dumps committed per version; downgrade protection enforced |
| `alchemist` for golden tests | CI-enforcement support; founder as visual reviewer |

---

## 4. Files Unchanged This Session

- All `docs/01-product/` files (product docs locked).
