# Stories

## S-1 — Encrypted SQLite Database + Drift Schema

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer, I want an encrypted, versioned SQLite database with all 18 tables and the FTS5 virtual table provisioned via Drift, so that every data-layer feature has a stable, schema-correct persistence foundation to build on.

### Objectives

- Integrate Drift with SQLCipher (AES-256, WAL mode) and store the encryption key via `flutter_secure_storage` backed by Android Keystore
- Define all 18 tables and the `transactions_fts` FTS5 virtual table matching the data model
- Apply required PRAGMAs on every open: `journal_mode=WAL`, `foreign_keys=ON`, `synchronous=NORMAL`, `busy_timeout=5000`, `cache_size=-20000`
- Implement a versioned migration scaffold; raise `SchemaMismatchException` when on-disk version exceeds compiled version
- Implement one `DatabaseAccessor` DAO per aggregate: `TransactionDao`, `AccountDao`, `CategoryDao`, `TemplateDao`, `ExchangeRateDao`, `CurrencyDao`
- Write a `SchemaVerifier` test that validates the v1 schema on a fresh in-memory database

### Definition of Done

- `flutter test` passes `SchemaVerifier` for v1 schema without error
- `AppDatabase` opens on a fresh emulator without throwing an exception
- All DAOs have generated `.g.dart` files committed to source control
- Migration from v1 → v1 (fresh install) completes without error
- SQLCipher encryption is active; unencrypted reads on the raw file fail

### References

- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)
- `2.3 Database and Persistence` (`docs/02-technical/sds.md`)
- `3. Core Tables` (`docs/02-technical/data-model.md`)
- `2. Schema Migration Policy` (`docs/02-technical/data-model.md`)

---

## S-2 — Domain Entities + Use Case Scaffolding

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer, I want all Freezed domain entities, abstract repository interfaces, and the `Result<T>` / `Failure` sealed hierarchy available as a pure-Dart package, so that use case and repository implementations have a typed, Flutter-free domain foundation.

### Objectives

- Define all 16 `@freezed` domain entities in `lib/domain/entities/` (zero setters; `copyWith` only; no `json_serializable`)
- Define one abstract repository interface per aggregate in `lib/domain/repositories/` with method signatures matching the API contracts
- Implement `Result<T>` sealed type at `lib/domain/core/result.dart`
- Implement the `Failure` sealed hierarchy at `lib/domain/core/failure.dart` with `DatabaseFailure`, `ValidationFailure`, `NetworkFailure`, `NotFoundFailure`, `BusinessRuleFailure`
- Scaffold all use case shells in `lib/domain/usecases/` with correct `call()` signatures and no logic
- Verify the domain package compiles with a pubspec that excludes `flutter` as a direct dependency

### Definition of Done

- `dart analyze lib/domain/` returns zero errors
- Domain package builds without `flutter` as a direct dependency; CI enforces this
- All 16 entities have `@freezed` code-gen output committed
- All `Failure` subtypes are present and correctly sealed
- Use case shells exist with correct input/output types

### References

- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)
- `1.5.1 Folder Structure` (`docs/02-technical/sds.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `2. Domain Contracts` (`docs/02-technical/api-contracts.md`)

---

## S-3 — Riverpod Provider Graph (DI Wiring)

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer, I want the full Riverpod provider graph wired from `AppDatabase` through DAOs, repositories, and use cases, so that every screen and use case can resolve its dependencies through a single, code-generated composition root.

### Objectives

- Define `AppDatabaseProvider` with `keepAlive: true` as the root of the provider tree
- Define DAO providers (`keepAlive: true`) hanging off `AppDatabaseProvider`
- Define repository implementation providers (`keepAlive: true`) hanging off the DAO providers
- Define use case providers hanging off repository providers
- Enforce scoping rules: database/repositories at global scope; form notifiers scoped via `ProviderScope` override; ephemeral local state via `ValueNotifier`
- Generate all providers with `riverpod_generator` (no raw `Provider(...)` constructor syntax)

### Definition of Done

- `main.dart` starts without a runtime `ProviderException`
- A provider test instantiates `AppDatabaseProvider` against an in-memory Drift database and resolves at least one repository provider without error
- All provider output files follow the `.g.dart` convention and are committed
- No raw `Provider(...)` constructor syntax exists in the codebase

### References

- `INFRA-3 — Riverpod DI Wiring` (`docs/02-technical/feature-dag.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)
- `1.3.4 Infrastructure Cross-Cut` (`docs/02-technical/sds.md`)

---

## S-4 — GoRouter Navigation Shell

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a user, I want a 3-tab navigation shell with all app routes pre-defined and an onboarding guard, so that the app navigates consistently between every screen and redirects new users to onboarding automatically.

### Objectives

- Implement `StatefulShellRoute.indexedStack` with three independent `StatefulNavigationShell` branches: Tab 0 `/` → HomeScreen, Tab 1 `/accounts` → AccountListScreen, Tab 2 `/settings` → SettingsScreen
- Define the complete route tree in `lib/presentation/navigation/app_router.dart` with all named paths before any screen implementation
- Implement the onboarding redirect guard: if `onboardingComplete == false` in `app_settings`, all routes redirect to `/onboarding`
- Define modal routes outside the shell: `/onboarding`, `/filter`, `/exchange-rate-detail`
- Enforce navigation rules: `context.go(...)` for tab-root transitions; `context.push(...)` for within-tab stack pushes
- Validate all route path parameters at the builder; navigate to an error screen on invalid parameters

### Definition of Done

- All named routes compile without error
- Tapping each bottom-nav tab renders a placeholder screen
- The onboarding redirect fires correctly when `onboardingComplete` is false
- No `GoException` is thrown on any defined path parameter
- Modal routes are accessible and do not corrupt the shell stack

### References

- `INFRA-4 — GoRouter Navigation Shell` (`docs/02-technical/feature-dag.md`)
- `2.4 Navigation` (`docs/02-technical/sds.md`)
- `3. App Shell & Navigation` (`docs/02-technical/ux-flows.md`)
- `2. App Shell & Navigation` (`docs/02-technical/ui-spec.md`)

---

## S-5 — Theme + Token System

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer, I want a centralized `ThemeData` with `VarianceColors` semantic tokens and dynamic color support, so that every screen can use consistent, financially-meaningful colors in both light and dark mode without string-keyed color lookups.

### Objectives

- Define both light and dark `ThemeData` using `ColorScheme.fromSeed`
- Integrate `DynamicColorBuilder` from the `dynamic_color` package; fall back to `app_settings.color_seed` when OEM wallpaper extraction returns null
- Implement `ThemeExtension<VarianceColors>` with compile-time semantic tokens: `incomeAmount`, `expenseAmount`, `warningAmount`, `accentPastel`
- Ensure all tokens are theme-adaptive (correct values for both light and dark modes)
- Expose `app_settings.color_scheme_mode` preference to switch between `dynamic` and `custom` modes

### Definition of Done

- `ThemeData` and `VarianceColors` compile without error
- Widget test confirms `Theme.of(context).extension<VarianceColors>()!.incomeAmount` resolves to a non-null color in both light and dark mode
- `DynamicColorBuilder` null-fallback path is covered by a widget test with a mock returning null
- No string-keyed color lookups exist in the presentation layer

### References

- `INFRA-5 — Theme + Token System` (`docs/02-technical/feature-dag.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `1. Global Design Decisions` (`docs/02-technical/ui-spec.md`)

---

## S-6 — Currency Bundle + Seeding

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a user, I want all ~180 ISO 4217 currencies available offline from first launch, so that I can create accounts and record transactions in any world currency without a network request.

### Objectives

- Bundle `assets/data/currencies.json` with ~180 active ISO 4217 currencies (schema per entry: `code`, `name`, `symbol`, `minor_units`)
- Seed the `currencies` table on fresh install via the `onCreate` Drift migration by bulk-inserting from the bundled asset
- Expose a `keepAlive` Riverpod provider backed by `CurrencyRepository`; load the asset once on app startup with no runtime network fetch
- `CurrencyDao` is read-only; no user edits to the currencies table
- Enforce downstream `minor_units` contract: input fields restrict decimal places; amounts stored as integers; display formatted to `minor_units` places

### Definition of Done

- Asset is bundled, parseable, and contains ≥ 170 rows
- `currencies` table is populated on fresh install with ≥ 170 rows
- `CurrencyRepository.getAll()` returns correct entries for USD (2 decimals), JPY (0 decimals), and BHD (3 decimals)
- `CurrencyProvider` resolves without error on app startup

### References

- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)
- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)

---

## S-7 — Ledger Engine Domain Services

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer, I want four stateless domain services — `LedgerEngine`, `BalanceCalculator`, `PostingCaseSelector`, `PeriodCalculator` — that enforce all DEB invariants and posting cases, so that every financial write in the app passes through a single, tested correctness layer.

### Objectives

- Implement `LedgerEngine`: accepts `CreateTransactionInput`; calls `PostingCaseSelector`; builds a balanced `Entry` set; asserts `Σdebit = Σcredit` before returning; raises `BusinessRuleFailure` on any imbalance
- Implement `PostingCaseSelector`: maps (event_type, entity_state) → posting case enum covering all cases from `ledger-entry.md` (expense/income/transfer creation, balance edit, reversal, account-deletion transfer, recurring auto-post)
- Implement `BalanceCalculator`: computes `balance = Σdebit − Σcredit` from `entries` rows with home-currency conversion via `exchange_rate_to_home`; stores no result
- Implement `PeriodCalculator`: O(1) `DateRange` computation for recurring templates and budgets; handles month-boundary and leap-year edge cases
- Enforce ACID: every ledger write executes inside a single Drift `database.transaction()` call
- Enforce immutability: `LedgerEngine` never issues SQL `UPDATE` on `entries` rows; corrections produce reversal + correction entry sets
- Handle EQ account lazy creation: atomically create `__EQ_{code}` inside the same transaction when posting an opening balance entry

### Definition of Done

- Unit tests cover all posting cases from `ledger-entry.md`: Cases 1.1, 1.2, 1.3, 1.3a, 2.2a/b, 2.3a/b, 2.4a/b, 2.5a, 3.1
- A deliberately imbalanced input returns `BusinessRuleFailure` (unit test)
- `PeriodCalculator` is tested for Feb 28/29 boundary and month-end clamping
- All four services are stateless; no shared mutable state between calls
- All ledger writes use a single Drift transaction; partial-write path does not exist

### References

- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `1.6 Key Architectural Constraints` (`docs/02-technical/sds.md`)
- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
