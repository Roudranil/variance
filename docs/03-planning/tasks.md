# Tasks

## T-1 — Add SQLCipher + Drift dependencies and configure flutter_secure_storage

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Add `drift`, `drift_flutter`, `sqlcipher_flutter_libs`, `flutter_secure_storage` to `pubspec.yaml`
- [ ] Add `drift_dev`, `build_runner` as dev dependencies
- [ ] Configure `flutter_secure_storage` Android options to use Android Keystore backend
- [ ] Verify `flutter pub get` completes without conflicts
- [ ] Confirm SQLCipher native libs are linked in the Android build

### Notes

- SQLCipher must be AES-256, WAL mode; unencrypted reads on the raw `.db` file must fail

### References

- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `2.3.2 WAL Mode and PRAGMA Configuration` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)
- `2.14.1 Production Dependencies` (`docs/02-technical/sds.md`)

---

## T-2 — Implement AppDatabase with encryption key management and PRAGMAs

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Create `lib/data/database/app_database.dart` with `@DriftDatabase` annotation
- [ ] On `onCreate`, generate or retrieve a 32-byte AES key via `flutter_secure_storage`
- [ ] Pass the encryption key to SQLCipher via `MoorIsolate` / `NativeDatabase.createInBackground`
- [ ] Apply all required PRAGMAs on every open: `journal_mode=WAL`, `foreign_keys=ON`, `synchronous=NORMAL`, `busy_timeout=5000`, `cache_size=-20000`
- [ ] Store database file at `getApplicationDocumentsDirectory()/variance.db`

### References

- `2.3.2 WAL Mode and PRAGMA Configuration` (`docs/02-technical/sds.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-3 — Define all 18 Drift table classes and FTS5 virtual table

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Create one Drift `Table` subclass for each of the 18 tables: `accounts`, `account_details`, `transactions`, `entries`, `categories`, `tags`, `transaction_tags`, `payees`, `currencies`, `exchange_rates`, `attachments`, `budgets`, `budget_periods`, `recurring_templates`, `scheduled_occurrences`, `installment_plans`, `installment_occurrences`, `app_settings`, `drafts`
- [ ] Define columns, types, nullability, and foreign key constraints matching the data model schema
- [ ] Define the `transactions_fts` FTS5 virtual table for full-text search
- [ ] Register all tables in `@DriftDatabase(tables: [...])`
- [ ] Run `dart run build_runner build` and confirm all `.g.dart` files are generated

### References

- `3. Core Tables` (`docs/02-technical/data-model.md`)
- `10. Search` (`docs/02-technical/data-model.md`)
- `1. Overview` (`docs/02-technical/data-model.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-4 — Implement versioned migration scaffold and SchemaMismatchException

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Implement `MigrationStrategy` with `onCreate` (v1 baseline) and `onUpgrade` stubs
- [ ] Implement `SchemaMismatchException` thrown when on-disk `user_version` > compiled schema version
- [ ] Add version check logic in `AppDatabase` open callback
- [ ] Confirm migration from v1 → v1 (fresh install) completes without error
- [ ] Document the migration pattern in a code comment within the migration file

### References

- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `2. Schema Migration Policy` (`docs/02-technical/data-model.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-5 — Implement one DatabaseAccessor DAO per aggregate

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Create `TransactionDao` in `lib/data/database/daos/transaction_dao.dart`
- [ ] Create `AccountDao` in `lib/data/database/daos/account_dao.dart`
- [ ] Create `CategoryDao` in `lib/data/database/daos/category_dao.dart`
- [ ] Create `TemplateDao` in `lib/data/database/daos/template_dao.dart`
- [ ] Create `ExchangeRateDao` in `lib/data/database/daos/exchange_rate_dao.dart`
- [ ] Create `CurrencyDao` in `lib/data/database/daos/currency_dao.dart`
- [ ] Each DAO extends `DatabaseAccessor`; stub at least one query method per DAO
- [ ] Register all DAOs in `@DriftDatabase(daos: [...])`

### References

- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `3. Core Tables` (`docs/02-technical/data-model.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-6 — Write SchemaVerifier test for v1 schema

**Parent Epic:** E-1
**Parent Story:** S-1

### Todo

- [ ] Create `test/data/database/schema_verifier_test.dart`
- [ ] Open an in-memory `AppDatabase` instance in the test
- [ ] Assert all 18 tables and the FTS5 virtual table exist by querying `sqlite_master`
- [ ] Assert foreign key pragma is active
- [ ] Run `flutter test` and confirm zero failures

### References

- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `3. Core Tables` (`docs/02-technical/data-model.md`)
- `10. Search` (`docs/02-technical/data-model.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-7 — Define all 16 Freezed domain entities

**Parent Epic:** E-1
**Parent Story:** S-2

### Todo

- [ ] Create `lib/domain/entities/` directory
- [ ] Define `@freezed` class for each of the 16 entities: `Transaction`, `Entry`, `Account`, `Category`, `RecurringTemplate`, `ScheduledOccurrence`, `InstallmentPlan`, `InstallmentOccurrence`, `Budget`, `BudgetPeriod`, `Payee`, `Tag`, `Currency`, `ExchangeRate`, `AppSettings`, `Draft`
- [ ] Ensure zero setters; `copyWith` only; no `json_serializable` annotation on any entity
- [ ] Add `freezed`, `freezed_annotation` to `pubspec.yaml`; add `freezed` to dev dependencies
- [ ] Run `dart run build_runner build` and confirm all `.freezed.dart` files are generated

### References

- `2.5.1 Freezed — Domain Entities` (`docs/02-technical/sds.md`)
- `2.5 Data Modeling and Serialization` (`docs/02-technical/sds.md`)
- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)

---

## T-8 — Define abstract repository interfaces for all aggregates

**Parent Epic:** E-1
**Parent Story:** S-2

### Todo

- [ ] Create `lib/domain/repositories/` directory
- [ ] Define one abstract class per aggregate with method signatures matching the API contracts doc
- [ ] Repository interfaces must return `Future<Result<T>>` using the `Result<T>` type
- [ ] Confirm no concrete implementations exist in this task — interfaces only
- [ ] Run `dart analyze lib/domain/repositories/` and resolve all errors

### References

- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `2. Domain Contracts` (`docs/02-technical/api-contracts.md`)
- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)

---

## T-9 — Implement Result sealed type and Failure sealed hierarchy

**Parent Epic:** E-1
**Parent Story:** S-2

### Todo

- [ ] Create `lib/domain/core/result.dart` with `Result<T>` as a sealed class with `Success<T>` and `Failure` variants
- [ ] Create `lib/domain/core/failure.dart` with `Failure` sealed hierarchy: `DatabaseFailure`, `ValidationFailure`, `NetworkFailure`, `NotFoundFailure`, `BusinessRuleFailure`
- [ ] Each `Failure` subtype carries a human-readable `message` field
- [ ] Run `dart analyze lib/domain/core/` and confirm zero errors

### References

- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)

---

## T-10 — Scaffold all use case shells with correct signatures

**Parent Epic:** E-1
**Parent Story:** S-2

### Todo

- [ ] Create `lib/domain/usecases/` directory
- [ ] Add a use case shell file per aggregate domain (transactions, accounts, categories, templates, budgets, exchange rates, currencies, settings)
- [ ] Each use case class exposes a `call()` method with the correct input type and `Future<Result<T>>` return type
- [ ] All `call()` method bodies throw `UnimplementedError` — no logic yet
- [ ] Run `dart analyze lib/domain/usecases/` and confirm zero errors

### References

- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)
- `2. Domain Contracts` (`docs/02-technical/api-contracts.md`)
- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)

---

## T-11 — Verify domain package compiles without Flutter dependency

**Parent Epic:** E-1
**Parent Story:** S-2

### Todo

- [ ] Confirm no `flutter` direct dependency in `pubspec.yaml` for the domain package
- [ ] Run `dart pub get` and `dart analyze lib/domain/` and confirm zero errors
- [ ] Confirm no implicit Flutter imports exist in any file under `lib/domain/`
- [ ] Add a CI step or Makefile target that enforces this constraint on every build

### References

- `1.5.1 Folder Structure` (`docs/02-technical/sds.md`)
- `1.6.3 Domain Layer Must Have Zero Flutter Dependency` (`docs/02-technical/sds.md`)
- `INFRA-2 — Domain Entities + Use Case Scaffolding` (`docs/02-technical/feature-dag.md`)

---

## T-12 — Define AppDatabaseProvider and DAO providers

**Parent Epic:** E-1
**Parent Story:** S-3

### Todo

- [ ] Create `lib/presentation/providers/database_providers.dart`
- [ ] Define `@Riverpod(keepAlive: true) AppDatabase appDatabase(...)` using `riverpod_generator`
- [ ] Define one `@Riverpod(keepAlive: true)` provider per DAO (`transactionDao`, `accountDao`, `categoryDao`, `templateDao`, `exchangeRateDao`, `currencyDao`), each reading from `appDatabaseProvider`
- [ ] Run `dart run build_runner build` and confirm all provider `.g.dart` files are generated
- [ ] Confirm no raw `Provider(...)` constructor syntax is used

### References

- `2.2.1 Riverpod` (`docs/02-technical/sds.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)
- `INFRA-3 — Riverpod DI Wiring` (`docs/02-technical/feature-dag.md`)

---

## T-13 — Define repository implementation providers and use case providers

**Parent Epic:** E-1
**Parent Story:** S-3

### Todo

- [ ] Create concrete repository implementations in `lib/data/repositories/` (one per aggregate)
- [ ] Define `@Riverpod(keepAlive: true)` provider for each repository implementation, injecting the appropriate DAO provider
- [ ] Define use case providers (auto-dispose unless long-lived) injecting repository providers
- [ ] Run `dart run build_runner build` and confirm generated files are present
- [ ] Confirm all providers follow `@riverpod` annotation convention — no raw `Provider(...)` constructors

### References

- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `2.2.4 Provider Scoping Rules` (`docs/02-technical/sds.md`)
- `INFRA-3 — Riverpod DI Wiring` (`docs/02-technical/feature-dag.md`)

---

## T-14 — Wire ProviderScope in main.dart and write provider integration test

**Parent Epic:** E-1
**Parent Story:** S-3

### Todo

- [ ] Wrap the root widget with `ProviderScope` in `lib/main.dart`
- [ ] Confirm `main.dart` starts without a runtime `ProviderException`
- [ ] Write a provider test in `test/providers/` that opens an in-memory `AppDatabase`, overrides `appDatabaseProvider`, and resolves at least one repository provider without error
- [ ] Run `flutter test` on the provider test and confirm it passes

### References

- `2.2.4 Provider Scoping Rules` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `INFRA-3 — Riverpod DI Wiring` (`docs/02-technical/feature-dag.md`)

---

## T-15 — Define complete GoRouter route tree with all named paths

**Parent Epic:** E-1
**Parent Story:** S-4

### Todo

- [ ] Create `lib/presentation/navigation/app_router.dart`
- [ ] Define `StatefulShellRoute.indexedStack` with three branches: `/` → HomeScreen, `/accounts` → AccountListScreen, `/settings` → SettingsScreen
- [ ] Define all named paths for every screen in the app before any screen implementation
- [ ] Define modal routes outside the shell: `/onboarding`, `/filter`, `/exchange-rate-detail`
- [ ] Confirm the file compiles with zero errors

### References

- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `2.4.1 GoRouter` (`docs/02-technical/sds.md`)
- `3.1 Route Map` (`docs/02-technical/ux-flows.md`)
- `2.3 Route Map` (`docs/02-technical/ui-spec.md`)
- `INFRA-4 — GoRouter Navigation Shell` (`docs/02-technical/feature-dag.md`)

---

## T-16 — Implement onboarding redirect guard

**Parent Epic:** E-1
**Parent Story:** S-4

### Todo

- [ ] Read `onboardingComplete` flag from `app_settings` inside a GoRouter `redirect` callback
- [ ] Redirect all routes to `/onboarding` when `onboardingComplete == false`
- [ ] Allow `/onboarding` route to bypass the guard (no redirect loop)
- [ ] Write a widget test asserting the redirect fires on a fresh install state (`onboardingComplete = false`)
- [ ] Write a widget test asserting no redirect when `onboardingComplete = true`

### References

- `2.4.3 Navigation Rules` (`docs/02-technical/sds.md`)
- `3.4 Back-Stack Rules` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `INFRA-4 — GoRouter Navigation Shell` (`docs/02-technical/feature-dag.md`)

---

## T-17 — Add placeholder screens for all 3 tabs and validate route parameters

**Parent Epic:** E-1
**Parent Story:** S-4

### Todo

- [ ] Create minimal `HomeScreen`, `AccountListScreen`, `SettingsScreen` placeholder widgets (scaffold only)
- [ ] Tapping each bottom-nav tab navigates to the correct placeholder screen
- [ ] Validate all route path parameters at the builder; navigate to an error screen on invalid parameters
- [ ] Enforce navigation rules: `context.go(...)` for tab-root transitions; `context.push(...)` for within-tab stack pushes — add lint comment to document this rule
- [ ] Confirm no `GoException` is thrown on any defined path parameter

### References

- `2.4.1 GoRouter` (`docs/02-technical/sds.md`)
- `3.2 Shell States` (`docs/02-technical/ux-flows.md`)
- `2.1 Shell Scaffold` (`docs/02-technical/ui-spec.md`)
- `2.2 NavigationBar Item Spec` (`docs/02-technical/ui-spec.md`)
- `INFRA-4 — GoRouter Navigation Shell` (`docs/02-technical/feature-dag.md`)

---

## T-18 — Define light and dark ThemeData with ColorScheme.fromSeed

**Parent Epic:** E-1
**Parent Story:** S-5

### Todo

- [ ] Create `lib/presentation/theme/app_theme.dart`
- [ ] Define `lightTheme` and `darkTheme` using `ColorScheme.fromSeed` with `useMaterial3: true`
- [ ] Add `dynamic_color` package to `pubspec.yaml`
- [ ] Wire `DynamicColorBuilder` at the root widget; fall back to `app_settings.color_seed` when OEM wallpaper extraction returns null
- [ ] Expose `app_settings.color_scheme_mode` preference to toggle between `dynamic` and `custom` modes

### References

- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `1. Global Design Decisions` (`docs/02-technical/ui-spec.md`)
- `INFRA-5 — Theme + Token System` (`docs/02-technical/feature-dag.md`)

---

## T-19 — Implement VarianceColors ThemeExtension with semantic tokens

**Parent Epic:** E-1
**Parent Story:** S-5

### Todo

- [ ] Create `lib/presentation/theme/variance_colors.dart` with `ThemeExtension<VarianceColors>`
- [ ] Define compile-time semantic tokens: `incomeAmount`, `expenseAmount`, `warningAmount`, `accentPastel`
- [ ] Provide theme-adaptive values for both light and dark modes
- [ ] Register `VarianceColors` extension in both `lightTheme` and `darkTheme` `extensions` list
- [ ] Confirm no string-keyed color lookups exist anywhere in the presentation layer

### References

- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `1. Global Design Decisions` (`docs/02-technical/ui-spec.md`)
- `INFRA-5 — Theme + Token System` (`docs/02-technical/feature-dag.md`)

---

## T-20 — Write widget tests for VarianceColors and DynamicColorBuilder fallback

**Parent Epic:** E-1
**Parent Story:** S-5

### Todo

- [ ] Write a widget test confirming `Theme.of(context).extension<VarianceColors>()!.incomeAmount` resolves to a non-null color in light mode
- [ ] Write a widget test confirming the same token resolves to a non-null color in dark mode
- [ ] Write a widget test for the `DynamicColorBuilder` null-fallback path using a mock that returns null
- [ ] Run `flutter test` on all three tests and confirm zero failures

### References

- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `1. Global Design Decisions` (`docs/02-technical/ui-spec.md`)
- `INFRA-5 — Theme + Token System` (`docs/02-technical/feature-dag.md`)

---

## T-21 — Create and bundle currencies.json asset

**Parent Epic:** E-1
**Parent Story:** S-6

### Todo

- [ ] Create `assets/data/currencies.json` with ~180 active ISO 4217 currencies
- [ ] Each entry must conform to schema: `{ "code", "name", "symbol", "minor_units" }`
- [ ] Exclude obsolete/suspended currencies; include ≥ 170 active entries
- [ ] Register `assets/data/` in `pubspec.yaml` under `flutter.assets`
- [ ] Verify the asset is parseable via `rootBundle.loadString` in a unit test

### References

- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `4. Currency & Rates` (`docs/02-technical/data-model.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)

---

## T-22 — Seed currencies table via onCreate Drift migration

**Parent Epic:** E-1
**Parent Story:** S-6

### Todo

- [ ] In the `AppDatabase` `onCreate` migration callback, load `assets/data/currencies.json` via `rootBundle`
- [ ] Bulk-insert all currency entries into the `currencies` table
- [ ] Confirm ≥ 170 rows are present after `onCreate` on a fresh in-memory database (unit test)
- [ ] Confirm `CurrencyDao` exposes only read operations — no insert/update/delete methods

### References

- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)

---

## T-23 — Implement CurrencyRepository and keepAlive CurrencyProvider

**Parent Epic:** E-1
**Parent Story:** S-6

### Todo

- [ ] Implement `CurrencyRepositoryImpl` with `getAll()` and `getByCode(String code)` backed by `CurrencyDao`
- [ ] Define `@Riverpod(keepAlive: true) Future<List<Currency>> currencies(...)` provider
- [ ] Confirm the provider loads the asset once on startup with no runtime network fetch
- [ ] Write a unit test asserting `getByCode('USD')` returns `minor_units = 2`, `getByCode('JPY')` returns `minor_units = 0`, and `getByCode('BHD')` returns `minor_units = 3`

### References

- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.5.1 ICurrencyRepository` (`docs/02-technical/api-contracts.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)

---

## T-24 — Implement PostingCaseSelector

**Parent Epic:** E-1
**Parent Story:** S-7

### Todo

- [ ] Create `lib/domain/services/posting_case_selector.dart`
- [ ] Define a `PostingCase` enum covering all cases from `ledger-entry.md`: expense/income/transfer creation, balance edit, reversal, account-deletion transfer, recurring auto-post
- [ ] Implement `PostingCaseSelector.select(eventType, entityState)` → `PostingCase` mapping
- [ ] Confirm the class is stateless (no instance fields mutated between calls)
- [ ] Write unit tests covering every enum case value

### References

- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)
- `Group 1 — Transaction Lifecycle` (`docs/01-product/ledger-entry.md`)
- `Group 2 — Account Lifecycle` (`docs/01-product/ledger-entry.md`)
- `Group 3 — Additional Cases (Beyond User's Initial List)` (`docs/01-product/ledger-entry.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)

---

## T-25 — Implement LedgerEngine with balanced entry assertion

**Parent Epic:** E-1
**Parent Story:** S-7

### Todo

- [ ] Create `lib/domain/services/ledger_engine.dart`
- [ ] `LedgerEngine.post(CreateTransactionInput)` calls `PostingCaseSelector`, builds a balanced `Entry` set, and asserts `Σdebit == Σcredit` before returning
- [ ] Raise `BusinessRuleFailure` on any imbalance; do not silently swallow the error
- [ ] Handle EQ account lazy creation: atomically create `__EQ_{code}` inside the same Drift transaction when posting an opening balance entry
- [ ] Wrap every ledger write in a single `database.transaction()` call

### Notes

- `LedgerEngine` never issues SQL `UPDATE` on `entries` rows; corrections produce reversal + correction entry sets

### References

- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `1.6.7 Transaction Immutability and Correction Model` (`docs/02-technical/sds.md`)
- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.3.1 IEntryRepository` (`docs/02-technical/api-contracts.md`)
- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)

---

## T-26 — Implement BalanceCalculator

**Parent Epic:** E-1
**Parent Story:** S-7

### Todo

- [ ] Create `lib/domain/services/balance_calculator.dart`
- [ ] Implement `BalanceCalculator.compute(List<Entry> entries, String homeCurrency)` → `Decimal`
- [ ] Formula: `balance = Σdebit − Σcredit` with home-currency conversion via `exchange_rate_to_home`
- [ ] Confirm no result is stored — the method is pure and stateless
- [ ] Write unit tests for multi-currency balance aggregation correctness

### References

- `1.6 Key Architectural Constraints` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)

---

## T-27 — Implement PeriodCalculator with edge case handling

**Parent Epic:** E-1
**Parent Story:** S-7

### Todo

- [ ] Create `lib/domain/services/period_calculator.dart`
- [ ] Implement O(1) `DateRange` computation for recurring templates and budgets
- [ ] Handle month-boundary edge cases: month-end clamping (e.g., Jan 31 + 1 month = Feb 28/29)
- [ ] Handle leap-year February 29 boundary correctly
- [ ] Write unit tests for: Feb 28/29 boundary, month-end clamping, year boundary, and standard monthly/weekly intervals

### References

- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations` (`docs/02-technical/sds.md`)
- `4.5 Recurring & Scheduling Domain` (`docs/02-technical/feature-dag.md`)
- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)

---

## T-28 — Write unit tests for all posting cases and LedgerEngine invariants

**Parent Epic:** E-1
**Parent Story:** S-7

### Todo

- [ ] Write unit tests covering all posting cases from `ledger-entry.md`: Cases 1.1, 1.2, 1.3, 1.3a, 2.2a/b, 2.3a/b, 2.4a/b, 2.5a, 3.1
- [ ] Write a unit test asserting a deliberately imbalanced input returns `BusinessRuleFailure`
- [ ] Confirm all four services (`LedgerEngine`, `BalanceCalculator`, `PostingCaseSelector`, `PeriodCalculator`) have no shared mutable state between calls
- [ ] Run `flutter test` and confirm all ledger engine tests pass

### References

- `1.6 Key Architectural Constraints` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)
- `INFRA-7 — Ledger Engine` (`docs/02-technical/feature-dag.md`)

---
