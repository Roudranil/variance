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


## T-29 — Define Account and AccountDetail Freezed domain entities

**Parent Epic:** E-2
**Parent Story:** S-8

### Todo

- [ ] Create `lib/domain/entities/account.dart` with all fields from Data Model §3.1: `id`, `name`, `account_category`, `currency_code`, `include_in_net_worth`, `notes`, `is_deleted`, `deleted_at`, `is_protected`, `is_system`, `display_order`, `created_at`, `updated_at`
- [ ] Create `lib/domain/entities/account_detail.dart` with fields: `id`, `account_id`, `detail_key`, `detail_value`, `detail_value_encrypted`, `created_at`, `updated_at`
- [ ] Annotate both with `@freezed`; run `build_runner`
- [ ] Confirm no Flutter or Drift imports in entity files

### References

- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-30 — Define IAccountRepository interface

**Parent Epic:** E-2
**Parent Story:** S-8

### Todo

- [ ] Create `lib/domain/repositories/i_account_repository.dart`
- [ ] Declare: `create`, `getById`, `update`, `softDelete`, `watchAll`, `watchById`, `watchBalance`, `isNameTaken`, `findSoftDeletedByNameAndCategory`
- [ ] All return types use `Result<T, Failure>` or `Stream<T>`; no Drift or Flutter imports

### References

- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-31 — Implement AccountDao

**Parent Epic:** E-2
**Parent Story:** S-9

### Todo

- [ ] Create `lib/data/daos/account_dao.dart` extending `DatabaseAccessor`
- [ ] Implement: `insertAccount`, `updateAccount`, `softDeleteAccount`, `findById`, `watchAll`, `watchById`, `isNameTaken` (includes soft-deleted), `findSoftDeletedByNameAndCategory`
- [ ] Implement `watchBalance(accountId)` as a Drift query: `SELECT SUM(debit_minor) - SUM(credit_minor) FROM entries WHERE account_id = ? AND status != 'voided'`
- [ ] Add index on `entries(account_id)` if not already present (Data Model §13)
- [ ] Implement `AccountDetailDao` for `account_details` key-value operations

### References

- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-32 — Implement AccountRepositoryImpl and DTOs

**Parent Epic:** E-2
**Parent Story:** S-9

### Todo

- [ ] Create `lib/data/repositories/account_repository_impl.dart`
- [ ] Implement all `IAccountRepository` methods delegating to `AccountDao`
- [ ] Create `AccountDto` and `AccountDetailDto` to map Drift rows ↔ domain entities
- [ ] Register `accountRepositoryProvider` in Riverpod DI graph
- [ ] Integration tests: create/read/update/soft-delete against in-memory DB

### References

- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.2 Data Layer` (`docs/02-technical/sds.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)

---

## T-33 — Implement CreateAccountUseCase

**Parent Epic:** E-2
**Parent Story:** S-10

### Todo

- [ ] Create `lib/domain/usecases/accounts/create_account_use_case.dart`
- [ ] Validate: name non-empty, account_category valid enum, currency_code valid ISO 4217
- [ ] Call `isNameTaken`; if soft-deleted match found via `findSoftDeletedByNameAndCategory` return `ReinstateOfferFailure` with the soft-deleted account
- [ ] If `initial_balance ≠ 0`: call `LedgerEngine.post` with opening balance posting case (Cases 2.2a/2.2b from `ledger-entry.md`)
- [ ] Wrap account insert + entry post in single `database.transaction()`
- [ ] Return typed `Result<Account, Failure>`

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1 Account CRUD` (`docs/01-product/prd.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `TC-045: EQ (Opening Balance equity account) — balance and auditability` (`docs/01-product/technical-clarifications.md`)
- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)

---

## T-34 — Implement UpdateAccountUseCase and SoftDeleteAccountUseCase

**Parent Epic:** E-2
**Parent Story:** S-10

### Todo

- [ ] Create `lib/domain/usecases/accounts/update_account_use_case.dart`
  - [ ] Validate editable fields only (name, notes, include_in_net_worth, category-specific fields)
  - [ ] Enforce: account_category immutable; currency_code immutable
  - [ ] Run name uniqueness check if name changed
- [ ] Create `lib/domain/usecases/accounts/soft_delete_account_use_case.dart`
  - [ ] Count active accounts; return `LastAccountFailure` if count == 1
  - [ ] Set `is_deleted = true`, `deleted_at = now`
- [ ] Unit tests with mock repository for all guard-rail branches

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1.4 Edit` (`docs/01-product/prd.md`)
- `TC-035: Soft-deleted entity reinstatement` (`docs/01-product/technical-clarifications.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## T-35 — Implement WatchAccountsUseCase and Riverpod account providers

**Parent Epic:** E-2
**Parent Story:** S-10

### Todo

- [ ] Create `WatchAccountsUseCase` (returns `Stream<List<Account>>` excluding system accounts)
- [ ] Create `GetAccountUseCase` (returns `Result<Account, Failure>`)
- [ ] Define `accountsProvider` as `StreamProvider<List<Account>>`
- [ ] Define `accountBalanceProvider(accountId)` as `StreamProvider<int>` (minor units)
- [ ] Define `netWorthProvider` as `Provider` that sums `accountBalanceProvider` × exchange rates for `include_in_net_worth` accounts

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `2.3 Riverpod Provider Graph` (`docs/02-technical/sds.md`)

---

## T-36 — Implement account_details persistence + encryption

**Parent Epic:** E-2
**Parent Story:** S-11

### Todo

- [ ] Implement `saveAccountDetails(accountId, List<AccountDetail>)` in `AccountDetailDao`
- [ ] For `detail_key` in `{'card_number', 'account_number'}`: write to `detail_value_encrypted` using `flutter_secure_storage` AES; leave `detail_value` null
- [ ] Implement `revealEncryptedDetail(accountId, detailKey)` — triggers biometric/PIN auth before returning plaintext
- [ ] Ensure CVV field is never written to either column
- [ ] Unit tests: write encrypted field → read without auth returns masked value; read with auth returns plaintext

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2 Account Categories (Fixed Set — No Custom Categories)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `2.3.3 Encryption` (`docs/02-technical/sds.md`)

---

## T-37 — Implement loan installment suggestion

**Parent Epic:** E-2
**Parent Story:** S-11

### Todo

- [ ] After successful account create, if `initial_balance < 0` OR (`emi_amount_minor` present AND `emi_date` present): show `LoanInstallmentSuggestionSheet`
- [ ] Bottom sheet pre-fills recurring template form: destination = this loan account, amount = emi_amount, recurrence = monthly on emi_date, start = today
- [ ] "Set up installment" CTA navigates to recurring template create flow; "Not now" dismisses
- [ ] Widget test: negative-balance account create → suggestion sheet appears; positive-balance → no sheet

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2.1 Linked bank account — behaviour by account category` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)

---

## T-38 — Implement balance stream + net worth aggregation logic

**Parent Epic:** E-2
**Parent Story:** S-12

### Todo

- [ ] Verify `watchBalance` Drift query uses index on `entries(account_id, side)` — add if missing
- [ ] Implement `NetWorthCalculator` domain service: sums balances × `exchange_rate_to_home` for `include_in_net_worth = 1 AND is_deleted = 0` accounts
- [ ] Handle missing exchange rate: exclude from sum; return `hasStaleRates` flag
- [ ] Performance test: balance query < 500 ms with 10,000 entry rows on in-memory DB

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `5.1.4 Account Balance View` (`docs/01-product/prd.md`)
- `13. Index Definitions` (`docs/02-technical/data-model.md`)

---

## T-39 — Build AccountListScreen and net worth card

**Parent Epic:** E-2
**Parent Story:** S-13

### Todo

- [ ] Create `lib/presentation/accounts/account_list_screen.dart`
- [ ] Net worth summary card at top: total in home currency, staleness indicator if `hasStaleRates`
- [ ] Accounts grouped by account_category with section headers; each row: name, balance, currency symbol (disambiguated)
- [ ] Excluded accounts section below net worth: grayed-out, "excluded" chip
- [ ] FAB → `/accounts/new`; row tap → `/accounts/:id`
- [ ] Empty state CTA when no accounts
- [ ] Widget tests: grouped render, empty state, negative balance color

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5.1.4.1 Negative balance visual treatment` (`docs/01-product/prd.md`)

---

## T-40 — Build AccountFormScreen (create + edit modes)

**Parent Epic:** E-2
**Parent Story:** S-13

### Todo

- [ ] Create `lib/presentation/accounts/account_form_screen.dart`; accepts optional `Account` for edit mode
- [ ] Fields: name, account_category (dropdown, disabled in edit), currency (searchable, with immutability info tooltip in edit), initial_balance (hidden in edit), include_in_net_worth toggle, notes
- [ ] Render category-specific fields section below common fields based on selected `account_category`
- [ ] Inline validation for all required fields
- [ ] On submit: call `CreateAccountUseCase` or `UpdateAccountUseCase`; handle `ReinstateOfferFailure` → show reinstatement dialog
- [ ] Widget tests: edit mode disables category field; reinstatement dialog fires on name conflict

### References

- `5.1.1.1 Create Account — Fields` (`docs/01-product/prd.md`)
- `5.1.1.2 Currency Immutability` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)

---

## T-41 — Build AccountDetailScreen

**Parent Epic:** E-2
**Parent Story:** S-14

### Todo

- [ ] Create `lib/presentation/accounts/account_detail_screen.dart`
- [ ] Header: name, category badge, currency, current balance (warning color if negative)
- [ ] Category-specific fields section (encrypted fields show masked value with "Reveal" button)
- [ ] Per-account transaction list: cursor-paginated, 50 rows, all months, reverse chronological; stub with empty list until TXN epic lands
- [ ] Toolbar: Edit action → AccountFormScreen in edit mode
- [ ] Overflow menu: Soft-delete (with last-account guard tooltip), Reconcile
- [ ] Credit card variant: outstanding balance chip, statement balance chip, Pay FAB
- [ ] Widget tests: credit card variant shows Pay FAB; non-credit-card does not; empty list empty state

### References

- `ACC-04 — Account Detail Screen` (`docs/02-technical/feature-dag.md`)
- `5.1.3 Account Detail Screen` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)

---

## T-42 — Implement credit card payment flow

**Parent Epic:** E-2
**Parent Story:** S-15

### Todo

- [ ] Pay FAB on credit card detail screen: pre-fill transfer entry form with destination = this credit card, amount = outstanding balance, source = linked bank account (from `account_details`) or account picker if not set
- [ ] Navigate to transaction entry form pre-filled; user can adjust before submitting
- [ ] Widget test: Pay FAB appears on credit_card accounts only; tapping opens pre-filled transfer form

### References

- `ACC-05 — Credit Card Payment Flow` (`docs/02-technical/feature-dag.md`)
- `5.1.5 Credit Card Payment` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)

---

## T-43 — Implement balance reconciliation

**Parent Epic:** E-2
**Parent Story:** S-15

### Todo

- [ ] Reconcile action on account detail overflow menu → `ReconcileScreen`
- [ ] `ReconcileScreen`: show current computed balance; user enters actual balance; app computes delta
- [ ] If delta > 0: post Balance Adjustment income (BAI category, `is_protected = 1`); if delta < 0: post BAE expense
- [ ] Post via `LedgerEngine`; navigate back on success
- [ ] Widget test: positive delta posts BAI; negative delta posts BAE

### References

- `ACC-06 — Balance Reconciliation` (`docs/02-technical/feature-dag.md`)
- `5.1.6 Balance Reconciliation` (`docs/01-product/prd.md`)
- `TC-046: BAI and BAE (Balance Adjustment categories)` (`docs/01-product/technical-clarifications.md`)

---

## T-44 — Implement overdraft and credit limit warnings

**Parent Epic:** E-2
**Parent Story:** S-15

### Todo

- [ ] In transaction entry form ViewModel: after amount + account are filled, compute projected balance
- [ ] If asset account and projected balance < 0: show inline `OverdraftWarningBanner` (non-blocking — user can still submit)
- [ ] If credit card account and projected balance (outstanding) would exceed `credit_limit_minor`: show inline `CreditLimitWarningBanner` (non-blocking)
- [ ] Widget tests: overdraft banner appears on asset account with insufficient balance; credit limit banner appears on credit card over limit; both allow submission

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.4.2 Overdraft warning` (`docs/01-product/prd.md`)
- `5.1.4.3 Credit card limit warning (FG-C18)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)

## T-45 — Define Transaction, Entry, Tag Freezed domain entities

**Parent Epic:** E-3
**Parent Story:** S-16

### Todo

- [ ] Create `lib/domain/entities/transaction.dart` with all fields from Data Model §3.3: `id`, `type`, `amount_minor`, `currency_code`, `account_source_id`, `account_destination_id`, `category_id`, `subcategory_id`, `title`, `description`, `date_time`, `status`, `purpose`, `corrects_transaction_id`, `compound_group_id`, `compound_role`, `exchange_rate_micro`, `created_at`, `updated_at`
- [ ] Create `lib/domain/entities/entry.dart` with fields from Data Model §3.4
- [ ] Create `lib/domain/entities/tag.dart`
- [ ] Annotate all with `@freezed`; run `build_runner`
- [ ] Confirm `type` is a sealed enum (`income`, `expense`, `transfer`); no Flutter imports

### References

- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `TC-024: Transaction entity — complete field enumeration and data types` (`docs/01-product/technical-clarifications.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-46 — Define ITransactionRepository interface

**Parent Epic:** E-3
**Parent Story:** S-16

### Todo

- [ ] Create `lib/domain/repositories/i_transaction_repository.dart`
- [ ] Declare: `save`, `getById`, `softDelete`, `watchPaginated`, `watchByAccount`, `search`, `findDuplicates`, `saveDraft`, `getDrafts`, `deleteDraft`
- [ ] All return types use `Result<T, Failure>` or `Stream<T>`; no Drift imports

### References

- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## T-47 — Implement TransactionDao

**Parent Epic:** E-3
**Parent Story:** S-17

### Todo

- [ ] Create `lib/data/daos/transaction_dao.dart`
- [ ] Implement: `insertTransaction`, `softDeleteTransaction`, `watchPaginated(month, cursor)`, `watchByAccount(accountId, cursor)`, `getById`
- [ ] Cursor pagination: `WHERE (date_time, id) < (cursor_date, cursor_id) ORDER BY date_time DESC, id DESC LIMIT 50`
- [ ] Implement `EntryDao` for `entries` table inserts (entries are never updated)
- [ ] Confirm FTS5 insert trigger exists in schema; test that `transactions_fts` is updated on insert

### References

- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-48 — Implement TransactionRepositoryImpl and DTOs

**Parent Epic:** E-3
**Parent Story:** S-17

### Todo

- [ ] Create `lib/data/repositories/transaction_repository_impl.dart`
- [ ] Implement all `ITransactionRepository` methods delegating to `TransactionDao`
- [ ] `TransactionDto` maps Drift row ↔ `Transaction` entity; `EntryDto` maps row ↔ `Entry`
- [ ] Register `transactionRepositoryProvider` in Riverpod DI graph
- [ ] Integration tests: create income, expense, transfer on in-memory DB; verify `entries` rows created correctly

### References

- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.2 Data Layer` (`docs/02-technical/sds.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## T-49 — Implement CreateTransactionUseCase (income + expense)

**Parent Epic:** E-3
**Parent Story:** S-18

### Todo

- [ ] Create `lib/domain/usecases/transactions/create_transaction_use_case.dart`
- [ ] Validate: amount > 0, account exists, category exists (income/expense require category_id), `date_time` not null
- [ ] Call `LedgerEngine.post(CreateTransactionInput)` → get balanced entry set
- [ ] Call `TransactionRepository.save(transaction, entries)` in single `database.transaction()`
- [ ] Invalidate `transactionsProvider` and `accountBalanceProvider` after commit
- [ ] Return typed `Result<Transaction, Failure>`

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)

---

## T-50 — Implement CreateTransactionUseCase (transfer + cross-currency + fee leg)

**Parent Epic:** E-3
**Parent Story:** S-19

### Todo

- [ ] Extend `CreateTransactionUseCase` for transfer type: require `account_source_id`, `account_destination_id`; no `category_id`
- [ ] Cross-currency: require `exchange_rate_micro` when source and destination currencies differ; store on transaction row
- [ ] Transfer-with-fee: generate `compound_group_id` (UUID v4); create primary leg with `compound_role = 'primary'`; create fee leg with `compound_role = 'fee'` in same DB transaction
- [ ] Unit tests: same-currency transfer, cross-currency transfer, transfer with fee

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `TC-024: Transaction entity — complete field enumeration and data types` (`docs/01-product/technical-clarifications.md`)

---

## T-51 — Build transaction entry form (income/expense)

**Parent Epic:** E-3
**Parent Story:** S-18

### Todo

- [ ] Create `lib/presentation/transactions/transaction_form_screen.dart`
- [ ] Fields: type toggle, amount (minor units), account picker (grouped by category), category + subcategory picker (excludes protected categories), date/time picker, title, description (max length from settings), tags
- [ ] Inline validation for required fields; submit button disabled until valid
- [ ] On submit: call `CreateTransactionUseCase`; show `DuplicateWarningSheet` if duplicate detected (non-blocking); navigate back on success
- [ ] Widget tests: field validation, duplicate warning dismissal, successful submit state

### References

- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## T-52 — Build transaction entry form (transfer variant)

**Parent Epic:** E-3
**Parent Story:** S-19

### Todo

- [ ] Extend `TransactionFormScreen` for transfer type: show source + destination account pickers; hide category picker; show exchange rate field when currencies differ; show optional fee row
- [ ] Fee row: toggle to add fee; fee amount + account fields appear when enabled
- [ ] Widget tests: same-currency hides exchange rate; cross-currency shows rate field; fee toggle shows fee fields

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## T-53 — Implement CorrectTransactionUseCase

**Parent Epic:** E-3
**Parent Story:** S-20

### Todo

- [ ] Create `lib/domain/usecases/transactions/correct_transaction_use_case.dart`
- [ ] Determine if changed fields are financial (trigger correction) or in-place (direct update)
- [ ] Financial edit path: set original `status = 'voided'`; post reversal (same fields, entries flipped); post correction (new financial values); link via `corrects_transaction_id`
- [ ] In-place path: `UPDATE transactions SET title/description/date_time/... WHERE id = ?`; no new entries
- [ ] Soft-delete path: void + reversal; no correction row
- [ ] All paths wrapped in single `database.transaction()`
- [ ] Unit tests for all 3 paths; correction-of-correction chain test

### References

- `TXN-02 — Transaction Immutability + Correction Model` (`docs/02-technical/feature-dag.md`)
- `1.6.7 Transaction Immutability and Correction Model` (`docs/02-technical/sds.md`)
- `3.3.1 Correction Chain` (`docs/02-technical/data-model.md`)
- `11.3 Void/Reversal Chain Policy` (`docs/02-technical/data-model.md`)
- `TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md` (`docs/01-product/technical-clarifications.md`)

---

## T-54 — Build TransactionDetailScreen

**Parent Epic:** E-3
**Parent Story:** S-21

### Todo

- [ ] Create `lib/presentation/transactions/transaction_detail_screen.dart`
- [ ] Render all §5.2.1.6 fields: type, amount + currency, account(s), category, date/time, title, description, exchange rate (cross-currency only), fee breakdown (compound group), tags
- [ ] Photo carousel: `PageView` with max 2 photos; full-screen tap opens `PhotoViewScreen`; per-photo delete button (confirmation → deletes `attachments` row + physical file)
- [ ] Top-right overflow menu: Edit → `TransactionFormScreen` pre-filled; Soft-delete → confirmation dialog
- [ ] Pending transaction: all overflow menu fields available for in-place edit
- [ ] Widget tests: compound transfer detail, empty photo carousel, pending transaction edit mode

### References

- `TXN-03 — Transaction Detail View` (`docs/02-technical/feature-dag.md`)
- `5.2.1.6 v1 contents` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## T-55 — Implement photo attach, compress, and delete

**Parent Epic:** E-3
**Parent Story:** S-22

### Todo

- [ ] `PhotoService`: pick from camera or gallery via `image_picker`
- [ ] Compress pipeline: `flutter_image_compress` → JPEG quality 85; if > 500KB, reduce by 5 points per iteration; floor = 60; max dimension 1920px; no upscaling
- [ ] Save to `getApplicationDocumentsDirectory()/attachments/{txn_id}/{uuid}.jpg`
- [ ] Insert `attachments` row with relative path, `mime_type = 'image/jpeg'`, file size
- [ ] `deletePhoto(attachmentId)`: delete `attachments` row first; then delete file (missing file = no error)
- [ ] `deleteAllPhotosForTransaction(txnId)`: called on transaction void
- [ ] Unit tests: compression output ≤ 500KB; 3rd photo add blocked; missing file idempotent delete

### References

- `TXN-04 — Photo Attachments` (`docs/02-technical/feature-dag.md`)
- `2.15 Photo Compression` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `TC-007: Photo compression parameters` (`docs/01-product/technical-clarifications.md`)

---

## T-56 — Build TransactionListScreen (unified + per-account)

**Parent Epic:** E-3
**Parent Story:** S-23

### Todo

- [ ] Create `lib/presentation/transactions/transaction_list_screen.dart` (unified, month-filtered)
- [ ] `TransactionListNotifier`: cursor-paginated `StreamProvider`; loads next page on scroll-to-bottom; default filter excludes `status = 'voided'` and `purpose = 'reversal'`
- [ ] Row widget: type icon, title, category, amount (warning color for expense/debit), account name
- [ ] Date-group headers render inline; pending badge on `status = 'pending'` rows
- [ ] Swipe-to-delete: confirmation → `SoftDeleteTransactionUseCase`
- [ ] Long-press contextual menu: Edit, Delete, Duplicate
- [ ] Per-account variant: same widget with `accountId` filter; no month scope
- [ ] Widget tests: empty month, pagination trigger, voided exclusion, pending badge

### References

- `TXN-05 — Transaction List (Unified)` (`docs/02-technical/feature-dag.md`)
- `TXN-12 — Per-Account Transaction List` (`docs/02-technical/feature-dag.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## T-57 — Implement duplicate detection

**Parent Epic:** E-3
**Parent Story:** S-24

### Todo

- [ ] Add `findDuplicates(type, amountMinor, accountId, categoryId, date)` to `TransactionDao`
- [ ] Query: `SELECT * FROM transactions WHERE type = ? AND amount_minor = ? AND account_source_id = ? AND category_id = ? AND DATE(date_time) = DATE(?) AND status = 'posted' LIMIT 1`
- [ ] Transfer variant: match on `account_source_id` + `account_destination_id` instead of category
- [ ] In `CreateTransactionUseCase`: call before `LedgerEngine.post`; if match found, return `DuplicateWarningResult(matchedTransaction)` — caller decides to proceed or abort
- [ ] Build `DuplicateWarningSheet`: show matched transaction; "Save anyway" proceeds; "Cancel" returns to form
- [ ] Unit tests: all type variants; no false positive when fields differ

### References

- `TXN-06 — Duplicate Detection` (`docs/02-technical/feature-dag.md`)
- `5.2.1.8 Duplicate detection` (`docs/01-product/prd.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## T-58 — Implement FTS5 search

**Parent Epic:** E-3
**Parent Story:** S-25

### Todo

- [ ] Add `search(query, cursor)` to `TransactionDao`: `SELECT * FROM transactions JOIN transactions_fts ON transactions.id = transactions_fts.rowid WHERE transactions_fts MATCH ? ORDER BY rank LIMIT 50`
- [ ] Implement `SearchNotifier` in Riverpod: debounce 300 ms; on query change triggers FTS search; on clear reverts to month-filtered `transactionsProvider`
- [ ] Build search bar overlay in home screen using `SearchAnchor` M3 widget
- [ ] Performance test: FTS query < 500 ms for 10,000 rows on test device

### References

- `TXN-08 — Transaction Search` (`docs/02-technical/feature-dag.md`)
- `1.4.3 FTS5 Search` (`docs/02-technical/sds.md`)
- `5.2.5 Search` (`docs/01-product/prd.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## T-59 — Build transaction filter sheet

**Parent Epic:** E-3
**Parent Story:** S-26

### Todo

- [ ] Create `FilterState` Freezed class: `dateRange`, `accountIds`, `categoryIds`, `types`, `amountRange`
- [ ] Create `FilterNotifier` (Riverpod `StateNotifier`); clear on month change
- [ ] Build `FilterSheet` bottom sheet: date range picker, account multi-select, category multi-select, type chips, amount range slider
- [ ] Build `ActiveFilterChipStrip` widget below search bar; each chip has × dismiss
- [ ] Update `TransactionListNotifier` to apply `FilterState` to its query

### References

- `TXN-09 — Transaction Filter` (`docs/02-technical/feature-dag.md`)
- `5.2.6 Filter` (`docs/01-product/prd.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## T-60 — Implement future-dated + pending transaction flow

**Parent Epic:** E-3
**Parent Story:** S-27

### Todo

- [ ] In `CreateTransactionUseCase`: if `date_time > now`, save with `status = 'pending'`; entries NOT written at save time
- [ ] `watchBalance` Drift query must exclude `status = 'pending'` rows
- [ ] Future-month list shows pending transactions with "Pending" badge
- [ ] App-launch sweep integration (SCHED-01 dependency): `PostPendingTransactionsUseCase` posts entries for `status = 'pending' AND date_time <= now`; sets `status = 'posted'`
- [ ] Edit form for pending transaction: all fields unlocked; submit updates in-place (no correction model)

### References

- `TXN-10 — Future-Dated Transactions` (`docs/02-technical/feature-dag.md`)
- `TXN-11 — Pending Transaction Management` (`docs/02-technical/feature-dag.md`)
- `5.2.7 Pending Transactions` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## T-61 — Implement transaction drafts

**Parent Epic:** E-3
**Parent Story:** S-28

### Todo

- [ ] `DraftRepository`: serialise form state to JSON; store up to 5 slots in `app_settings.draft_slots` (FIFO — evict oldest on 6th)
- [ ] `TransactionFormScreen`: on `WillPopScope` / back button, if form has content and `back_button_behaviour = 'auto_save_draft'`, call `DraftRepository.save`
- [ ] FAB in home screen: if draft exists, show "Resume draft" option; tapping opens form pre-populated
- [ ] Explicit discard action in form toolbar clears draft slot
- [ ] Widget tests: FIFO eviction on 6th draft; resume pre-populates all fields; discard clears slot

### References

- `DRAFT-01 — Transaction Drafts` (`docs/02-technical/feature-dag.md`)
- `5.2.8 Drafts` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

## T-62 — Define `Category` Freezed Domain Entity

**Parent Epic:** E-4
**Parent Story:** S-29

### Todo

- [ ] Create `lib/domain/entities/category.dart`
- [ ] Add `@freezed` annotation; declare all fields: `id` (String), `parentId` (String?), `treeType` (enum `CategoryTreeType` with `income`/`expense`), `name` (String), `iconRef` (String), `isDeleted` (bool), `deletedAt` (DateTime?), `isProtected` (bool), `sortOrder` (int?), `createdAt` (DateTime), `updatedAt` (DateTime)
- [ ] Define `CategoryTreeType` sealed enum in same file or adjacent file
- [ ] Run `build_runner`; verify generated `category.freezed.dart` compiles with zero errors
- [ ] Write unit test: `Category.copyWith` preserves unchanged fields; two instances with identical field values are equal (`==`)

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.5.1 Freezed — Domain Entities` (`docs/02-technical/sds.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-63 — Define `ICategoryRepository` Interface

**Parent Epic:** E-4
**Parent Story:** S-29

### Todo

- [ ] Create `lib/domain/repositories/category_repository.dart`
- [ ] Declare abstract interface `ICategoryRepository` with four methods: `watchAll()` → `Stream<List<Category>>`, `create(Category)` → `Future<Result<Category>>`, `update(Category)` → `Future<Result<Category>>`, `softDelete(String id, {String? replacementId})` → `Future<Result<void>>`
- [ ] Import `Result` from `lib/domain/core/result.dart`; ensure zero Flutter imports in this file
- [ ] Write unit test: `FakeCategoryRepository implements ICategoryRepository` compiles and satisfies the interface contract

### References

- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `1.6.3 Domain Layer Must Have Zero Flutter Dependency` (`docs/02-technical/sds.md`)
- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)

---

## T-64 — Implement `CategoryDto` with Drift Row Mapper

**Parent Epic:** E-4
**Parent Story:** S-29

### Todo

- [ ] Create `lib/data/models/category_dto.dart`
- [ ] Declare `CategoryDto` with a `fromRow(CategoriesData row)` factory and a `toEntity()` method returning `Category`
- [ ] Map `tree_type` TEXT column to `CategoryTreeType` enum via custom converter
- [ ] Map `is_deleted` / `is_protected` INTEGER columns to `bool` via Drift `BoolConverter`
- [ ] Map `created_at` / `updated_at` / `deleted_at` INTEGER epoch columns to `DateTime` via `IntToDateTimeConverter`
- [ ] Write unit test: `CategoryDto.fromRow(mockRow).toEntity()` round-trips all fields without data loss

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `12.2 Custom Type Converters` (`docs/02-technical/data-model.md`)
- `2.5.2 json_serializable — Data Transfer Objects` (`docs/02-technical/sds.md`)

---

## T-65 — Implement `CategoryDao`

**Parent Epic:** E-4
**Parent Story:** S-29

### Todo

- [ ] Create `lib/data/datasources/category_dao.dart` as a Drift `DatabaseAccessor`
- [ ] Implement `watchAllCategories()` → `Stream<List<CategoriesData>>` filtering `is_deleted = 0`; ordered alphabetically by `name`
- [ ] Implement `watchByTreeType(String treeType)` → filtered stream for one tree
- [ ] Implement `insertCategory(CategoriesCompanion)` → `Future<void>`
- [ ] Implement `updateCategory(CategoriesCompanion)` → `Future<bool>`
- [ ] Implement `softDeleteCategory(String id, DateTime deletedAt)` → `Future<void>` (sets `is_deleted = 1`, `deleted_at`)
- [ ] Implement `countChildren(String parentId)` → `Future<int>` (counts non-deleted children)
- [ ] Implement `existsNameInScope(String name, String treeType, String? parentId, {String? excludeId})` → `Future<bool>` for uniqueness check (case-insensitive, including soft-deleted rows)
- [ ] Unit-test all methods using `NativeDatabase.memory()` in-memory Drift DB

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `3.5.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)

---

## T-66 — Implement `CategoryRepositoryImpl`

**Parent Epic:** E-4
**Parent Story:** S-29

### Todo

- [ ] Create `lib/data/repositories/category_repository_impl.dart` implementing `ICategoryRepository`
- [ ] `watchAll()`: delegates to `CategoryDao.watchAllCategories()`; maps rows via `CategoryDto.toEntity()`
- [ ] `create(category)`: delegates to `CategoryDao.insertCategory()`; wraps `DriftDatabaseException` in `Err(DatabaseFailure)`
- [ ] `update(category)`: delegates to `CategoryDao.updateCategory()`; returns `Err(NotFoundFailure)` if no row updated
- [ ] `softDelete(id, replacementId?)`: calls `countChildren(id)`; returns `Err(BusinessRuleFailure("Cannot delete a category with subcategories."))` if count > 0; otherwise calls `softDeleteCategory()`
- [ ] Unit-test: `softDelete` with children → `BusinessRuleFailure`; `softDelete` leaf → success; `update` missing row → `NotFoundFailure`

### References

- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Layer-Boundary Rules` (`docs/02-technical/sds.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)

---

## T-67 — Implement `CreateCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** S-30

### Todo

- [ ] Create `lib/domain/usecases/category/create_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Validate `name` is non-empty; return `Err(ValidationFailure("Name cannot be empty."))` if blank
- [ ] Validate two-level depth: if `parentId` is non-null, call `repository` to confirm parent's own `parentId` is null; return `Err(ValidationFailure("Categories cannot be nested more than two levels."))` if violated
- [ ] Call `CategoryDao.existsNameInScope(name, treeType, parentId)` via repository; return `Err(ValidationFailure("Name already in use."))` on conflict
- [ ] Assign `id = Uuid().v4()`, `createdAt = DateTime.now()`, `updatedAt = DateTime.now()`
- [ ] Delegate to `repository.create(category)`
- [ ] Unit-test: empty name, depth violation, duplicate name (including soft-deleted conflict), happy path

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## T-68 — Implement `UpdateCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** S-30

### Todo

- [ ] Create `lib/domain/usecases/category/update_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Validate `name` is non-empty
- [ ] Validate `isProtected == false` on the existing entity; return `Err(BusinessRuleFailure("System categories cannot be modified."))` if `isProtected` is true
- [ ] Call name uniqueness check excluding the category's own `id` from the conflict search
- [ ] Set `updatedAt = DateTime.now()` on the updated entity
- [ ] Delegate to `repository.update(category)`
- [ ] Unit-test: protected category update blocked; rename to own name succeeds; rename to conflicting name fails

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)

---

## T-69 — Implement `DeleteCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** S-30

### Todo

- [ ] Create `lib/domain/usecases/category/delete_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Fetch existing entity; return `Err(NotFoundFailure)` if absent
- [ ] Guard: `isProtected == true` → return `Err(BusinessRuleFailure("System categories cannot be deleted."))`
- [ ] Delegate to `repository.softDelete(id, replacementId: replacementId?)`; propagate `BusinessRuleFailure` from repo if child count > 0
- [ ] Unit-test: protected category delete blocked; parent with children blocked; leaf category deleted successfully

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)

---

## T-70 — Implement `CategoryListNotifier` and Riverpod DI Wiring

**Parent Epic:** E-4
**Parent Story:** S-30

### Todo

- [ ] Create `lib/presentation/providers/category_providers.dart`
- [ ] Define `categoryRepositoryProvider` as a Riverpod `Provider<ICategoryRepository>` returning `CategoryRepositoryImpl`
- [ ] Define `CategoryListNotifier extends AsyncNotifier<List<Category>>` that calls `ref.watch(categoryRepositoryProvider).watchAll()` and converts the stream to `AsyncValue` via `AsyncValue.guard`
- [ ] Annotate with `@riverpod`; run `build_runner`; verify generated provider file
- [ ] Widget-test `CategoryListNotifier`: override provider with fake repository; verify `AsyncValue.data` contains expected list on stream emission
- [ ] Widget-test error path: fake repository emits error → notifier exposes `AsyncValue.error`

### References

- `2.4.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)

---

## T-71 — Implement Category Management Screen Scaffold and Loading / Error States

**Parent Epic:** E-4
**Parent Story:** S-31

### Todo

- [ ] Create `lib/presentation/features/settings/categories/category_management_screen.dart`
- [ ] Scaffold: `SmallTopAppBar` "Categories", `TabBar` with "Expense" / "Income" tabs, `TabBarView`
- [ ] Register route `/settings/categories` in `app_router.dart`
- [ ] Loading state: render `ShimmerWidget` × 6 rows per tab
- [ ] Error state: M3 `Banner` with `errorContainer` fill + "Retry" `TextButton`; retry re-triggers provider
- [ ] Empty state (no user categories): abstract geometric illustration + "No categories yet" text + `FilledButton` "Add Category"
- [ ] Widget-test loading state, error state, and empty state independently via provider overrides

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `3.1 Route Map` (`docs/02-technical/ux-flows.md`)
- `2.4 Navigation` (`docs/02-technical/sds.md`)

---

## T-72 — Implement Category Management Screen Populated State and Row Actions

**Parent Epic:** E-4
**Parent Story:** S-31

### Todo

- [ ] Render populated tab: `ListView` of `ListTile` rows (leading: category `Icon`; title: category name; trailing: child count `Text`)
- [ ] Filter `is_protected = 1` rows out of the list at the notifier/screen level before rendering
- [ ] `FloatingActionButton` with `add` icon always visible; taps navigate to `/settings/categories/new?tree=<active-tab-tree>`
- [ ] Long-press on row: `ModalBottomSheet` with contextual menu items: Edit, Delete, Add Child Category
- [ ] Delete menu item: disabled with `Tooltip` "Remove all subcategories first." when `childCount > 0`
- [ ] Delete menu item enabled: navigates to deletion wizard (placeholder navigation to S-33 screen)
- [ ] Edit menu item: navigates to `/settings/categories/:id`
- [ ] Add Child Category: navigates to `/settings/categories/new?parent=:id`
- [ ] Widget-test: `is_protected` rows absent; Delete disabled when childCount > 0; correct navigation targets called

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.8.1 States` (`docs/02-technical/ux-flows.md`)
- `9.8.2 Category Row Actions (long-tap contextual menu)` (`docs/02-technical/ux-flows.md`)
- `9.8.3 "Balance Adjustment" Category` (`docs/02-technical/ux-flows.md`)

---

## T-73 — Implement Category Detail Screen — Create Mode

**Parent Epic:** E-4
**Parent Story:** S-32

### Todo

- [ ] Create `lib/presentation/features/settings/categories/category_detail_screen.dart`
- [ ] Register routes: `/settings/categories/new` (create) and `/settings/categories/:id` (edit) in `app_router.dart`
- [ ] Create mode: `AppBar` title "New Category"; tree selector (`SegmentedButton` Income/Expense) at top; pre-selectable via query param `?tree=income|expense`
- [ ] Name `OutlinedTextField` with label "Category name"; real-time uniqueness validation on change; error text "Name already in use"
- [ ] Icon picker row: `ListTile` with current icon preview (32 dp); tap opens icon picker `ModalBottomSheet`
- [ ] Icon picker sheet: `GridView` of ~250 `material_symbols_icons`; `TextField` search at top; 48 dp touch targets per icon
- [ ] AppBar trailing `FilledButton` "Save": enabled only when name non-empty, no conflict, form dirty
- [ ] On save: calls `CreateCategoryUseCase`; on `Ok` navigates back; on `Err` shows snackbar "Failed to save."
- [ ] Widget-test: Save disabled when name empty; Save disabled when name conflicts; icon picker opens and selection updates preview

### References

- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.9.1 States` (`docs/02-technical/ux-flows.md`)
- `9.22.1 From Settings` (`docs/02-technical/ux-flows.md`)

---

## T-74 — Implement Category Detail Screen — Edit Mode, Parent/Child Views, Subcategory Section

**Parent Epic:** E-4
**Parent Story:** S-32

### Todo

- [ ] Edit mode: load existing category; `AppBar` title "Edit Category"; pre-fill name and icon
- [ ] Parent category view: subcategory section below name/icon; `Text` section header; `ListTile` rows for each subcategory (icon + name); long-press → Edit / Delete contextual menu on subcategory row
- [ ] Subcategory section empty state: "No subcategories" `Text` + `OutlinedButton` "Add first subcategory"
- [ ] "Add subcategory" `OutlinedButton` navigates to `/settings/categories/new?parent=:id` (tree inherited from parent)
- [ ] Child category view: read-only parent label `ListTile` (`bodySmall` "Parent: [name]"); no subcategory section
- [ ] On save: calls `UpdateCategoryUseCase`; propagates errors via snackbar
- [ ] Shimmer loading state while category loads
- [ ] Widget-test: parent view renders subcategory section; child view does not; read-only parent label displays correct parent name

### References

- `9.9.2 Fields` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Subcategory Section (parent category view only)` (`docs/02-technical/ux-flows.md`)
- `9.9.1 Components` (`docs/02-technical/ui-spec.md`)

---

## T-75 — Implement Category Deletion Wizard — Steps 1 and 2 (Template Handling + Usage Count)

**Parent Epic:** E-4
**Parent Story:** S-33

### Todo

- [ ] Create a `DeleteCategoryWizardController` (Riverpod `Notifier`) that owns wizard state: current step, template count, transaction count, migration choice, destination category, selected transactions
- [ ] Step 1 check: query recurring/installment templates referencing the category; if count > 0 → show template handling `AlertDialog` with "Migrate" / "Archive" / "Cancel" actions
- [ ] Step 1a (Migrate templates): open category picker `ModalBottomSheet` filtered to same `tree_type`; on selection store `templateMigrationTarget`
- [ ] Step 2: after template handling resolves (or if no templates), count active transactions referencing category; if N > 0 show info `AlertDialog` "This category is used by [N] transaction(s)."
- [ ] "Cancel" at any dialog step aborts the entire wizard without any mutations
- [ ] Unit-test: wizard always executes step 1 before step 2; wizard skips step 1 if no templates; cancel at step 1 → no DB writes

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Deletion Flow Components` (`docs/02-technical/ui-spec.md`)

---

## T-76 — Implement Category Deletion Wizard — Steps 3 and 4 (Migration + Soft-Delete)

**Parent Epic:** E-4
**Parent Story:** S-33

### Todo

- [ ] Step 3: transaction migration `AlertDialog` with `RadioListTile` choices: "No migration" / "Migrate all" / "Choose specific"
- [ ] Step 3a ("Migrate all"): category picker `ModalBottomSheet` (same tree filter); selection stored as `transactionMigrationTarget`
- [ ] Step 3b ("Choose specific"): multi-select `BottomSheet` with `Checkbox` per transaction row; selected IDs stored
- [ ] Step 4: if `totalMigrationCount > 50`, show `AlertDialog` "Re-categorise [N] transactions?" with Confirm / Cancel; show progress `CircularProgressIndicator` dialog while migrating
- [ ] Batch migration: single Drift `database.transaction(() {...})` call; re-categorises all affected transactions via ledger correction writes; soft-deletes category at end of same transaction
- [ ] Performance: target ≤ 5 s for N = 500 transactions; do not block UI thread (use `Isolate.run` or background `compute` for batch)
- [ ] Unit-test: atomic rollback — if soft-delete write throws, all category re-categorisations rolled back; category `is_deleted` remains 0
- [ ] Widget-test: progress dialog renders for N > 10; extra confirmation renders for N > 50
- [ ] Verify: soft-deleted category `watchAll()` stream no longer emits the category; picker excludes it; filter dropdowns still include it

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `11.2 Soft Delete Policy` (`docs/02-technical/data-model.md`)
- `2.9.4 Ledger Operation Failure Modes` (`docs/02-technical/sds.md`)

---

## T-77 — Implement Default Category Seeding Migration

**Parent Epic:** E-4
**Parent Story:** S-34

### Todo

- [ ] Create `lib/data/database/migrations/seed_default_categories.dart` containing the seed data list (one `CategoriesCompanion` per default category row)
- [ ] Map PRD §5.6.1 default category tables into income-tree and expense-tree parent/child structures; assign UUID v4 for each row's `id`
- [ ] Seed `Balance Adjustment` income parent + BAI child with `is_protected = 1`, `icon_ref = 'balance'`
- [ ] Seed `Balance Adjustment` expense parent + BAE child with `is_protected = 1`, `icon_ref = 'balance'`
- [ ] Seed `Financial` expense parent (`is_protected = 0`) and `Fees & Charges` child (`is_protected = 1`)
- [ ] All other default categories: `is_protected = 0`; `sort_order = NULL`
- [ ] Wire seeding into `MigrationStrategy.onCreate` in `app_database.dart` using `INSERT OR IGNORE`
- [ ] Unit-test with in-memory Drift DB: verify all expected rows present after `onCreate`; verify idempotency (run twice → no duplicates)

### Notes

- Icon `icon_ref` values for non-protected categories are placeholders until the founder approves the TC-014 curated icon list; use `'category'` as the placeholder icon ref for all non-BAI/BAE rows until then

### References

- `CAT-02 — Default Category Seeding` (`docs/02-technical/feature-dag.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `11.1 schema_migrations` (`docs/02-technical/data-model.md`)

---

## T-78 — Protected Category Guard — Widget Tests for Picker and Management Screen

**Parent Epic:** E-4
**Parent Story:** S-35

### Todo

- [ ] Write widget test: `CategoryListNotifier` seeded with `is_protected = 1` and `is_protected = 0` rows; verify category management screen renders zero `is_protected = 1` rows
- [ ] Write widget test: category picker sheet seeded with `is_protected = 1` and `is_protected = 0` rows; verify `is_protected = 1` rows absent from picker list
- [ ] Write widget test: `UpdateCategoryUseCase` called with a `is_protected = 1` entity returns `Err(BusinessRuleFailure)` and picker/management screen shows no edit option for those rows
- [ ] Write widget test: `DeleteCategoryUseCase` called with a `is_protected = 1` entity returns `Err(BusinessRuleFailure)`
- [ ] Verify filter dropdown (transaction filter sheet): soft-deleted categories visible; `is_protected` categories also visible in filter context (they can appear on historical transactions)

### References

- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `8.1.3 Rules` (`docs/02-technical/ui-spec.md`)
- `9.8.3 "Balance Adjustment" Category` (`docs/02-technical/ux-flows.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-79 — Implement Category Picker Sheet

**Parent Epic:** E-4
**Parent Story:** S-35

### Todo

- [ ] Create `lib/presentation/widgets/category_picker_sheet.dart` as a `DraggableScrollableSheet` with `initialChildSize: 0.6`, `maxChildSize: 0.92`
- [ ] Sheet chrome: drag handle; title "Select Category — [Income|Expense]"
- [ ] M3 `SearchBar` (docked, auto-focused on open); on query change filter list to parents then children, fuzzy match
- [ ] Recents chip strip: horizontal scroll of up to 5 `SuggestionChip`s with category icon; recents sourced from a `RecentCategoriesNotifier` keyed by `tree_type`
- [ ] Two-level list: `ListTile` per parent; chevron if has children; tapping parent with children expands inline child rows (16 dp indent); tapping any row applies selection and dismisses sheet
- [ ] Empty state: "No categories yet" + `TextButton` "Create category" (invokes inline create)
- [ ] No-results state: "No results for '[query]'" + `TextButton` "+ Create '[query]'"
- [ ] Inline create row: animated expansion at list bottom; icon picker chip (opens icon sub-sheet) + name `OutlinedTextField` + `FilledTonalIconButton` confirm; confirm calls `CreateCategoryUseCase`; on success auto-selects new category and dismisses
- [ ] Filter `is_protected = 1` rows; show soft-deleted "current" entry only in edit mode when transaction already references it
- [ ] Widget-test all eight states listed in UI spec §8.1.2

### References

- `8.1 Category Picker Sheet` (`docs/02-technical/ui-spec.md`)
- `1.1 Category Picker (UX-11)` (`docs/02-technical/ux-flows.md`)
- `1.1.3 Rules` (`docs/02-technical/ux-flows.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)

---

## T-80 — Define `ExchangeRate` and `Currency` Domain Entities

**Parent Epic:** E-5
**Parent Story:** S-37

### Todo

- [ ] Define `Currency` Freezed value object: fields `code`, `name`, `symbol`, `minorUnits`; annotate with `@freezed`
- [ ] Define `ExchangeRate` Freezed value object: fields `fromCurrency`, `toCurrency`, `rateMicro`, `fetchedAt` (DateTime), `rateDate` (String)
- [ ] Add computed getter `rate` on `ExchangeRate` returning `rateMicro / 1_000_000` as `double`
- [ ] Add computed getter `isStale` on `ExchangeRate` returning true when `(DateTime.now().difference(fetchedAt)).inSeconds > 14 * 86400`
- [ ] Run `build_runner` to generate `*.freezed.dart` and `*.g.dart` files
- [ ] Write unit tests: `isStale` returns false within 14 days, true beyond 14 days; `rate` computation is correct

### References

- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.5.1 ICurrencyRepository` (`docs/02-technical/api-contracts.md`)
- `2.5.2 IExchangeRateRepository` (`docs/02-technical/api-contracts.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)
- `2.5 Data Modeling and Serialization` (`docs/02-technical/sds.md`)

---

## T-81 — Bundle `currencies.json` Asset and Register in `pubspec.yaml`

**Parent Epic:** E-5
**Parent Story:** S-37

### Todo

- [ ] Produce `assets/data/currencies.json` containing ~180 active ISO 4217 currencies; each entry: `{"code":"USD","name":"US Dollar","symbol":"$","minor_units":2}`
- [ ] Verify JPY has `minor_units: 0`; BHD has `minor_units: 3`; USD has `minor_units: 2`
- [ ] Register `assets/data/` in `pubspec.yaml` under `flutter.assets`
- [ ] Write a Dart test that loads the bundled JSON and asserts ≥ 170 rows are present and the three canonical entries are correct

### References

- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)

---

## T-82 — Implement `currencies` Drift Table and Seed Migration

**Parent Epic:** E-5
**Parent Story:** S-37

### Todo

- [ ] Define `CurrenciesTable` in Drift: columns `code` (PK TEXT), `name` (TEXT NOT NULL), `symbol` (TEXT NOT NULL), `minor_units` (INTEGER NOT NULL, CHECK IN (0,2,3)), `is_active` (INTEGER NOT NULL DEFAULT 1)
- [ ] Add `CurrencyDao` with read-only methods: `watchAll()` returning `Stream<List<CurrencyData>>`, `getByCode(String code)` returning `Future<CurrencyData?>`
- [ ] In `onCreate` migration callback: read `assets/data/currencies.json` via `rootBundle.loadString`, parse, and bulk-insert into `currencies` table using `CurrencyDao`
- [ ] Run `build_runner` to generate Drift table/DAO code
- [ ] Write integration test: fresh DB has ≥ 170 rows; USD, JPY, BHD entries are correct

### References

- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `2.3 Database and Persistence` (`docs/02-technical/sds.md`)
- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)

---

## T-83 — Implement `ICurrencyRepository` and `CurrencyRepositoryImpl`

**Parent Epic:** E-5
**Parent Story:** S-37

### Todo

- [ ] Define `ICurrencyRepository` abstract class in `lib/domain/currency/` with methods: `watchAll()`, `watchEnabled()`, `setHomeCurrency(String code)`, `enableCurrency(String code)`, `disableCurrency(String code)`
- [ ] Implement `CurrencyRepositoryImpl` in `lib/data/currency/` backed by `CurrencyDao`; `watchEnabled()` filters `is_active = 1`
- [ ] In `AppInitializer` (or equivalent startup hook), load bundled asset once and populate the `keepAlive` Riverpod provider (`currenciesProvider`)
- [ ] Wire `CurrencyRepositoryImpl` into the Riverpod DI graph; register as `ICurrencyRepository`
- [ ] Write unit tests for `watchEnabled()` filtering and `setHomeCurrency()` persistence

### References

- `2.5.1 ICurrencyRepository` (`docs/02-technical/api-contracts.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)
- `2.7.5 Architectural Isolation` (`docs/02-technical/sds.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-84 — Implement `exchange_rates` Drift Table and DAO

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] Define `ExchangeRatesTable` in Drift: columns `id` (PK AUTOINCREMENT), `from_currency` (TEXT NOT NULL FK → currencies), `to_currency` (TEXT NOT NULL FK → currencies), `rate_micro` (INTEGER NOT NULL > 0), `fetched_at` (INTEGER NOT NULL), `rate_date` (TEXT NOT NULL); unique constraint `(from_currency, to_currency)`
- [ ] Add index `idx_exchange_rate_pair` on `(from_currency, to_currency)`
- [ ] Implement `ExchangeRateDao` with: `upsertRate(ExchangeRateCompanion)`, `getRate(String from, String to)` returning `Future<ExchangeRateData?>`, `watchAllRates()` returning `Stream<List<ExchangeRateData>>`
- [ ] Use `INSERT OR REPLACE` (Drift `insertOnConflictUpdate`) for upsert
- [ ] Run `build_runner`; write unit test verifying upsert overwrites stale rate for the same pair

### References

- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `4.2.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `2.7.3 Cache Schema` (`docs/02-technical/sds.md`)
- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)

---

## T-85 — Implement `IExchangeRateRepository` and `ExchangeRateRepositoryImpl`

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] Define `IExchangeRateRepository` abstract class in `lib/domain/currency/` with methods: `getRate(String from, String to)`, `getCachedRate(String from, String to)`, `fetchAndCache()`
- [ ] Implement `ExchangeRateRepositoryImpl` in `lib/data/currency/` backed by `ExchangeRateDao`
- [ ] `getCachedRate()` is synchronous; returns `Err` if no row exists for the pair
- [ ] `getRate()` calls `getCachedRate()` and returns the cached value; does not trigger a network fetch
- [ ] Wire into Riverpod DI graph; confirm no domain-layer import of infrastructure code (SDS §2.7.5)
- [ ] Write unit tests for both sync and async paths; verify `Err` is returned when pair is absent

### References

- `2.5.2 IExchangeRateRepository` (`docs/02-technical/api-contracts.md`)
- `2.5.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.7.5 Architectural Isolation` (`docs/02-technical/sds.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.9.1 Decision — TC-033: Result Type Pattern` (`docs/02-technical/sds.md`)

---

## T-86 — Implement `ExchangeRateService` (HTTP Fetch + Parse)

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] Create `ExchangeRateService` in `lib/infrastructure/exchange_rates/`; store the API URL as a single named constant: `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{base}.min.json`
- [ ] Implement `fetchRatesForCurrencies(List<String> targetCurrencies, String baseCurrency)`: one GET request per base currency; 10-second timeout via `http` package; return `Result<Map<String, double>>`
- [ ] Parse `rate_date` from top-level `"date"` field in the API response
- [ ] On timeout or any HTTP error, return `Err`; do not rethrow
- [ ] Write unit tests with a mock HTTP client: success path (rates parsed correctly, `rate_date` captured), timeout path (returns `Err`), HTTP 500 path (returns `Err`)

### Notes

- Service lives entirely in `lib/infrastructure/exchange_rates/`; no domain imports beyond `ExchangeRate` value object

### References

- `2.7.1 Decision — TC-006: fawazahmed0 Exchange API` (`docs/02-technical/sds.md`)
- `2.7.2 Fetch Trigger and Schedule` (`docs/02-technical/sds.md`)
- `2.7.5 Architectural Isolation` (`docs/02-technical/sds.md`)
- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)

---

## T-87 — Implement `RefreshExchangeRatesUseCase`

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] Define `RefreshExchangeRatesUseCase` in `lib/domain/currency/use_cases/`
- [ ] Orchestrate: query `SELECT DISTINCT currency FROM accounts WHERE is_deleted = 0` via `IAccountRepository`; if only home currency present, return `Ok(void)` immediately without calling the service
- [ ] Call `ExchangeRateService.fetchRatesForCurrencies()` with the derived target currencies; on success, call `IExchangeRateRepository.fetchAndCache()` to upsert results
- [ ] On failure from service, return `Err` without upsetting the UI (caller — WorkManager worker — handles silently)
- [ ] Write unit tests: single-home-currency path (no fetch issued), multi-currency path (fetch and upsert called), service-failure path (returns `Err`)

### References

- `2.5.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.7.2 Fetch Trigger and Schedule` (`docs/02-technical/sds.md`)
- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-88 — Implement `ExchangeRateFetchWorker` (WorkManager Task)

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] Create `ExchangeRateFetchWorker` extending `workmanager` `Workmanager.executeTask` callback in `lib/infrastructure/exchange_rates/`
- [ ] On launch, retrieve `last_fetch_timestamp` from `app_settings`; if `(now - last_fetch_timestamp) < 23 * 3600`, return `Future.value(true)` immediately
- [ ] Otherwise, call `RefreshExchangeRatesUseCase.execute()`; on success, update `last_fetch_timestamp` in `app_settings`; on failure, return `Future.value(true)` (silent failure, no retry)
- [ ] Register the task on app startup with `Workmanager().registerOneOffTask(...)` and constraint `NetworkType.connected`
- [ ] Write unit tests for the 23-hour gate (fetch skipped), fetch-triggered path, and silent-failure path

### References

- `2.7.2 Fetch Trigger and Schedule` (`docs/02-technical/sds.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-89 — Net Worth Card: Staleness Disclaimer

**Parent Epic:** E-5
**Parent Story:** S-36

### Todo

- [ ] In the net worth card widget, watch `IExchangeRateRepository.watchAllRates()` for active-account foreign currencies
- [ ] Compute `isAnyRateStale`: true if any rate's `(now - fetched_at) > 14 * 86400`
- [ ] When `isAnyRateStale` is true, render "Exchange rate may be outdated" label beneath the net worth total
- [ ] When `isAnyRateStale` is false, no staleness label is shown
- [ ] Write widget tests: fresh rates (no label), stale rate present (label shown), no foreign currencies (no label)

### References

- `8.1.2 Net Worth Card` (`docs/02-technical/ux-flows.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)
- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)

---

## T-90 — Implement Symbol Disambiguation Helper

**Parent Epic:** E-5
**Parent Story:** S-38

### Todo

- [ ] Create `CurrencySymbolResolver` in `lib/domain/currency/`: takes `List<Currency>` (active-account currencies) and returns `Map<String, String>` mapping `currencyCode → displayLabel`
- [ ] Logic: group active currencies by `symbol`; if `group.length > 1`, label for each = `'${symbol}${code}'` (e.g. `'$USD'`); otherwise label = `symbol`
- [ ] Expose as a pure function or class with no Flutter dependency (domain layer)
- [ ] Write unit tests: single currency (label = symbol), two currencies sharing symbol (both get ISO suffix), three currencies where only two share symbol (only colliding pair augmented)

### References

- `CURR-02 — Currency Symbol Disambiguation` (`docs/02-technical/feature-dag.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `8.1.3 Account Row` (`docs/02-technical/ux-flows.md`)

---

## T-91 — Wire Symbol Disambiguation into Account List Row

**Parent Epic:** E-5
**Parent Story:** S-38

### Todo

- [ ] In the account list ViewModel/notifier, derive the `CurrencySymbolResolver` output from the active-account currencies stream
- [ ] Pass the resolved display label to each account row widget; render `displayLabel` (e.g. `$USD`) in place of bare `$` when disambiguation is active
- [ ] Single-currency scenario: row displays bare symbol unchanged
- [ ] Write widget test: two-currency scenario renders ISO-suffixed labels in account rows; single-currency renders plain symbol

### References

- `CURR-02 — Currency Symbol Disambiguation` (`docs/02-technical/feature-dag.md`)
- `8.1.3 Account Row` (`docs/02-technical/ux-flows.md`)
- `8.1 Screen: Account List` (`docs/02-technical/ux-flows.md`)
- `2.5.4 Notifiers` (`docs/02-technical/api-contracts.md`)

---

## T-92 — Wire Symbol Disambiguation into Net Worth Card + Transaction Views

**Parent Epic:** E-5
**Parent Story:** S-38

### Todo

- [ ] Apply `CurrencySymbolResolver` output to the net worth card currency display
- [ ] Apply `CurrencySymbolResolver` output to transaction list row currency label
- [ ] Apply `CurrencySymbolResolver` output to transaction detail view currency label
- [ ] Confirm no change in display when only one active currency exists
- [ ] Write widget tests for net worth card and transaction list row: collision and no-collision scenarios

### References

- `CURR-02 — Currency Symbol Disambiguation` (`docs/02-technical/feature-dag.md`)
- `8.1.2 Net Worth Card` (`docs/02-technical/ux-flows.md`)
- `7.1 Transaction Detail Screen` (`docs/02-technical/ux-flows.md`)
- `6.8.2 Row Layout (3-Column)` (`docs/02-technical/ux-flows.md`)

---

## T-93 — Implement `GetExchangeRateUseCase`

**Parent Epic:** E-5
**Parent Story:** S-39

### Todo

- [ ] Define `GetExchangeRateUseCase` in `lib/domain/currency/use_cases/`; accepts `from` and `to` currency codes
- [ ] Call `IExchangeRateRepository.getCachedRate(from, to)`; return `Ok(ExchangeRate)` on hit, `Err(RateUnavailableFailure)` on miss
- [ ] Include `isStale` flag derived from `ExchangeRate.isStale` in the returned domain object (already computed via getter — no extra logic needed)
- [ ] Write unit tests: rate present (fresh), rate present (stale), rate absent

### References

- `2.5.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.5.2 IExchangeRateRepository` (`docs/02-technical/api-contracts.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)

---

## T-94 — Implement Exchange Rate Estimate Widget

**Parent Epic:** E-5
**Parent Story:** S-39

### Todo

- [ ] Create `ExchangeRateEstimateWidget` (stateless): accepts `amount` (nullable double), `fromCurrency` String, `toCurrency` String, `exchangeRate` (`ExchangeRate?`)
- [ ] When `fromCurrency == toCurrency`: render nothing (empty `SizedBox`)
- [ ] When `exchangeRate == null`: render "Exchange rate unavailable." text note
- [ ] When `exchangeRate.isStale`: render `≈ [homeSymbol][estimatedAmount]` + `⚠ Rate may be outdated` inline warning
- [ ] When rate is fresh: render `≈ [homeSymbol][estimatedAmount]`
- [ ] Estimate = `amount * exchangeRate.rate` formatted to home currency `minor_units` decimal places
- [ ] Write widget tests for all four render states

### References

- `CURR-03 — Exchange Rate Estimate During Entry + Staleness Warning` (`docs/02-technical/feature-dag.md`)
- `7.2.6 Inline Warnings at Entry Time` (`docs/02-technical/ux-flows.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)

---

## T-95 — Wire Exchange Rate Estimate into Transaction Entry Form ViewModel

**Parent Epic:** E-5
**Parent Story:** S-39

### Todo

- [ ] In the transaction entry form ViewModel, watch selected account's currency via `IAccountRepository`
- [ ] When account currency differs from home currency, call `GetExchangeRateUseCase` and expose `AsyncValue<ExchangeRate?>` to the form view
- [ ] Pass `exchangeRate`, `amount`, `fromCurrency`, `toCurrency` down to `ExchangeRateEstimateWidget` in the form view
- [ ] Confirm the estimate value is read-only and does not affect the posted transaction amount
- [ ] Write unit tests for the ViewModel: account currency = home currency (no rate fetch triggered), account currency ≠ home currency (rate fetched and exposed)

### References

- `CURR-03 — Exchange Rate Estimate During Entry + Staleness Warning` (`docs/02-technical/feature-dag.md`)
- `7.2 Create Transaction Screen` (`docs/02-technical/ux-flows.md`)
- `7.2.6 Inline Warnings at Entry Time` (`docs/02-technical/ux-flows.md`)
- `2.5.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.5.4 Notifiers` (`docs/02-technical/api-contracts.md`)

---

## T-96 — Implement Currency Settings Screen + `CurrencySettingsNotifier`

**Parent Epic:** E-5
**Parent Story:** S-40

### Todo

- [ ] Implement `CurrencySettingsNotifier` as a Riverpod `AsyncNotifier<CurrencySettingsState>`; state includes: `homeCurrency`, `secondaryCurrencies` (list of `{currency, latestRate}`)
- [ ] `CurrencySettingsState.secondaryCurrencies` derived from active accounts' currencies (watch `IAccountRepository.watchAll()`) joined with `IExchangeRateRepository.watchAllRates()`
- [ ] Compute `isStale` per secondary currency using the 14-day threshold
- [ ] Implement `/settings/currency` screen: home currency row (code + name + warning banner) + secondary currency list (each row: code, name, last-fetched timestamp, "Outdated" label if stale)
- [ ] Tapping home currency row opens the `CurrencyPickerScreen` (`1.5 Currency Picker` flow)
- [ ] On picker confirmation, call `ICurrencyRepository.setHomeCurrency(code)`
- [ ] Write widget tests for: loaded state, stale secondary currency label, home currency change flow

### References

- `9.10 Screen: Currency Settings` (`docs/02-technical/ux-flows.md`)
- `9.10.2 Home Currency Row` (`docs/02-technical/ux-flows.md`)
- `9.10.3 Secondary Currencies` (`docs/02-technical/ux-flows.md`)
- `2.5.4 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.5.1 ICurrencyRepository` (`docs/02-technical/api-contracts.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)

---

## T-97 — Implement Currency Picker Screen

**Parent Epic:** E-5
**Parent Story:** S-40

### Todo

- [ ] Implement `CurrencyPickerScreen` as a full-screen modal route at a shared route path (used by account creation and currency settings)
- [ ] Load currency list from `ICurrencyRepository.watchAll()`; show shimmer while loading
- [ ] Render search field with fuzzy match on `code`, `name`, and `symbol`
- [ ] Pin popular currencies (INR, USD, EUR, GBP, JPY) at top of the list before the sorted remainder
- [ ] Highlight current selection with a checkmark
- [ ] On row tap, pop with selected currency code; on back, pop with no result
- [ ] Write widget tests: populated state, search filters list, popular currencies pinned at top, selection checkmark

### References

- `1.5 Currency Picker` (`docs/02-technical/ux-flows.md`)
- `1.5.1 Screen States` (`docs/02-technical/ux-flows.md`)
- `1.5.2 Interaction Flow` (`docs/02-technical/ux-flows.md`)
- `1.5.3 Rules` (`docs/02-technical/ux-flows.md`)
- `2.5.1 ICurrencyRepository` (`docs/02-technical/api-contracts.md`)

---

## T-98 — Implement Exchange Rate Detail Screen

**Parent Epic:** E-5
**Parent Story:** S-39

### Todo

- [ ] Implement `ExchangeRateDetailScreen` as a modal route at `/exchange-rate-detail`
- [ ] Accept parameters: `fromCurrency`, `toCurrency`, optional `transactionRate` (ExchangeRate for historical display)
- [ ] When `transactionRate` is provided: show "Rate at time of transaction" label; no staleness indicator
- [ ] When showing cached rate: display fresh / stale / no-rate states per `7.9 Exchange Rate Detail Screen` spec
- [ ] Content rows: currency pair, rate value, rate type label, last updated date, staleness warning (stale state only)
- [ ] Write widget tests for all four screen states: fresh, stale, no-rate, transaction-level rate

### References

- `7.9 Exchange Rate Detail Screen` (`docs/02-technical/ux-flows.md`)
- `7.9.1 Screen States` (`docs/02-technical/ux-flows.md`)
- `7.9.2 Content` (`docs/02-technical/ux-flows.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)

---

## T-99 — Define `IScheduledOccurrenceRepository` + Drift DAO for `scheduled_occurrences`

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Define abstract `IScheduledOccurrenceRepository` in `domain/repositories/` with methods: `getPendingDue(asOf)`, `markPosted(id, transactionId)`, `markSkipped(id)`, `markCancelled(id)`, `generateLookahead(templateId, fromDate, toDate)`
- [ ] Create Drift table class `ScheduledOccurrences` mapping all columns from the data model schema (id, template_id, scheduled_date, status, child_transaction_id, created_at, updated_at)
- [ ] Implement `ScheduledOccurrenceDao` with queries: `pendingDueOn(DateTime asOf)`, `updateStatus(String id, String status)`, `insertBatch(List<ScheduledOccurrence>)`
- [ ] Implement `ScheduledOccurrenceRepository` (Drift-backed) implementing `IScheduledOccurrenceRepository`
- [ ] Verify `idx_sched_occ_template` and `idx_sched_occ_status_date` indexes are declared in the Drift table definition
- [ ] Write unit tests using `NativeDatabase.memory()` for all DAO queries

### References

- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.2.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)

---

## T-100 — Define `IRecurringTemplateRepository` + Drift DAO for `recurring_templates`

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Define abstract `IRecurringTemplateRepository` in `domain/repositories/` with all methods from the API contracts: `watchAll()`, `watchById(id)`, `create(template)`, `update(template)`, `pause(id)`, `resume(id)`, `softDelete(id)`, `getDue(asOf)`
- [ ] Create Drift table class `RecurringTemplates` mapping all columns (including `pause_until`, `archived_at`, `archived_reason`, `is_installment`, `is_deleted`, `metadata` JSON)
- [ ] Implement `RecurringTemplateDao` with queries: `watchActive()`, `watchAll()`, `getById(id)`, `getDueForSweep(DateTime asOf)`, `updateStatus(id, status)`, `updatePauseUntil(id, epoch)`, `softDelete(id)`, `updateEditableFields(...)`
- [ ] Implement `RecurringTemplateRepository` (Drift-backed)
- [ ] Verify `idx_templates_status`, `idx_templates_installment`, and `idx_templates_next` indexes are declared
- [ ] Write unit tests for DAO with in-memory DB

### References

- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.1.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)

---

## T-101 — Implement `PostDueOccurrencesUseCase`

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Create `PostDueOccurrencesUseCase` in `domain/usecases/recurring/`
- [ ] Accept `asOf: DateTime` parameter; query `IScheduledOccurrenceRepository.getPendingDue(asOf)` for all pending occurrences with `scheduled_date <= asOf`
- [ ] For each pending occurrence: load parent template; invoke `LedgerEngine.buildEntries`; call `ITransactionRepository.save` in a single atomic DB transaction; call `markPosted(occurrenceId, transactionId)`
- [ ] Return `Result<int>` (count of occurrences posted)
- [ ] Implement auto-resume logic: before posting loop, query all `recurring_templates` with `status = 'paused'` and `pause_until <= asOf`; call `IRecurringTemplateRepository.resume(id)` for each
- [ ] Write unit tests with fake repositories covering: zero due, one due, multiple due, pause auto-resume

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1.4.3 Background Write — Recurring Auto-Post` (`docs/02-technical/sds.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## T-102 — Implement 90-day Lookahead Generation Logic

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Create `GenerateLookaheadUseCase` in `domain/usecases/recurring/`
- [ ] For each active template, compute the next scheduled occurrence dates from the last materialized occurrence up to `today + 90 days` using `PeriodCalculator` (O(1) per occurrence — no iteration loops)
- [ ] Apply end-of-month clamping for `recurrence_unit = 'month'` or `'year'`: if target day > last day of month, use last day of month
- [ ] Apply `recurrence_constraints` (weekdays_only, weekends_only, start_of_month, end_of_month, start_of_year, end_of_year) to shift occurrence dates as required
- [ ] Insert generated rows via `IScheduledOccurrenceRepository.generateLookahead`; skip dates that already have a non-cancelled row for the template
- [ ] Write unit tests covering: monthly on day 31, leap year Feb 29, weekdays_only constraint, end-of-month constraint

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations` (`docs/02-technical/sds.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## T-103 — Implement `AppInitializer` Synchronous Launch Sweep

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Create `AppInitializer` class in `infrastructure/` (or `app/`)
- [ ] In `main.dart`, call `AppInitializer.run()` before `runApp()`; it must complete before the first frame
- [ ] `AppInitializer.run()` calls `PostDueOccurrencesUseCase(asOf: DateTime.now())` synchronously
- [ ] `AppInitializer.run()` calls `GenerateLookaheadUseCase()` to refresh the 90-day window
- [ ] Store the count of auto-posted occurrences returned by `PostDueOccurrencesUseCase` for use by the Catch-Up Banner (S-47)
- [ ] Write unit test: mock use cases; verify both are called in order; verify result count is stored

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `1.4.3 Background Write — Recurring Auto-Post` (`docs/02-technical/sds.md`)

---

## T-104 — Register WorkManager `PostingSweeperWorker`

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Add `workmanager ^0.5.2` to `pubspec.yaml`
- [ ] Implement `PostingSweeperWorker` callback: calls `PostDueOccurrencesUseCase` + `GenerateLookaheadUseCase`; returns `Future.value(true)` on success, `false` on failure
- [ ] Register the worker once at install via `Workmanager().registerPeriodicTask(...)` with `frequency: Duration(hours: 6)`, `constraints: Constraints(networkType: NetworkType.not_required, requiresCharging: false, requiresDeviceIdle: false)`
- [ ] Use `ExistingWorkPolicy.keep` so registration is idempotent across app restarts
- [ ] Declare `RECEIVE_BOOT_COMPLETED` in `AndroidManifest.xml`
- [ ] Write integration test confirming worker is registered after app launch

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `2.6 Scheduling` (`docs/02-technical/sds.md`)
- `2.14.1 Production Dependencies` (`docs/02-technical/sds.md`)

---

## T-105 — Implement `RecurringTemplate` Domain Entity + `CreateRecurringTemplateUseCase`

**Parent Epic:** E-6
**Parent Story:** S-42

### Todo

- [ ] Define `RecurringTemplate` Freezed entity in `domain/entities/` with all fields from the data model (immutable fields marked as such in doc comments)
- [ ] Define `CreateRecurringTemplateInput` value object with all required and optional fields
- [ ] Implement `CreateRecurringTemplateUseCase`: validate inputs (N > 0, unit required, start_date required, end_date >= start_date if set); call `IRecurringTemplateRepository.create`; then call `GenerateLookaheadUseCase` to produce initial occurrence batch
- [ ] Return `Result<RecurringTemplate>` with `ValidationFailure` for field errors
- [ ] Write unit tests with fake repo: valid creation, missing required field, end_date < start_date

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `2.5.1 Freezed — Domain Entities` (`docs/02-technical/sds.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)

---

## T-106 — Build Create Recurring Template Screen (UI + Form)

**Parent Epic:** E-6
**Parent Story:** S-42

### Todo

- [ ] Create `CreateRecurringTemplateScreen` widget at route `/transaction/new` (recurring mode)
- [ ] Implement transaction type selector (Expense / Income / Transfer); show/hide account and category fields based on type
- [ ] Implement recurrence fields section: N (integer input), unit (dropdown: day/week/month/year), constraints (multi-select chips: weekdays_only, weekends_only, start_of_month, end_of_month, start_of_year, end_of_year)
- [ ] Implement start date / end date pickers; show live "First scheduled date" preview below recurrence fields
- [ ] Implement posting behaviour selector (Auto-post / Remind and confirm)
- [ ] Implement transfer fee panel (collapsed by default; show only for Transfer type)
- [ ] Wire Save button to `CreateRecurringTemplateUseCase`; show loading state during save; navigate back on success
- [ ] Write golden tests: empty state, filled state

### References

- `7.3 Create Recurring Transaction Screen` (`docs/02-technical/ux-flows.md`)
- `7.3.1 Screen States` (`docs/02-technical/ux-flows.md`)
- `7.3.2 Template Fields` (`docs/02-technical/ux-flows.md`)
- `7.16 Flow — Create Recurring Template` (`docs/02-technical/ux-flows.md`)
- `9.23 Flow: Recurring Template Creation` (`docs/02-technical/ux-flows.md`)

---

## T-107 — Implement Recurrence Rule Validation + First-Date Preview Logic

**Parent Epic:** E-6
**Parent Story:** S-42

### Todo

- [ ] Create `RecurrencePreviewService` (pure Dart, no Flutter) that takes recurrence_n, recurrence_unit, recurrence_constraints, start_date and returns the first scheduled date
- [ ] Apply end-of-month clamping: for unit = 'month' or 'year', if computed day > last day of target month, clamp to last day
- [ ] Apply constraint shifts: weekdays_only → advance to Monday if Saturday/Sunday; weekends_only → advance to Saturday; start_of_month → day 1; end_of_month → last day; start_of_year → Jan 1; end_of_year → Dec 31
- [ ] Validate in use case: N must be integer > 0; unit must be one of {day, week, month, year}; constraints must be from the allowed enum set
- [ ] Wire preview to form: update first-date display on every recurrence field change (debounced 300ms)
- [ ] Write unit tests covering all constraint types and end-of-month edge cases

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `1.3.2.1 Domain Services` (`docs/02-technical/sds.md`)
- `1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations` (`docs/02-technical/sds.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.3.2 Template Fields` (`docs/02-technical/ux-flows.md`)

---

## T-108 — Build Recurring Templates List Screen

**Parent Epic:** E-6
**Parent Story:** S-43

### Todo

- [ ] Create `RecurringTemplatesListScreen` at route `/settings/recurring`
- [ ] Implement two tabs: "Recurring" and "Installments"; scope this task to the Recurring tab only (Installments tab is in E-7)
- [ ] Within the Recurring tab: three groups — Active, Paused, Archived; use `RecurringTemplateListNotifier` (watches `IRecurringTemplateRepository.watchAll()`)
- [ ] Render each `RecurringTemplateRow`: title (or amount + category fallback), status badge (Active=green, Paused=amber, Archived=grey), recurrence summary string, next due date
- [ ] Implement long-tap contextual menu per state: Active → Edit, Delete, Pause, View child transactions; Paused → Edit, Delete, Unpause, View child transactions; Archived → View child transactions (read-only)
- [ ] Show loading shimmer, empty state illustration, and error state with Retry
- [ ] Write golden tests: empty state, populated state (Active + Paused + Archived groups), error state

### References

- `9.13 Screen: Recurring Templates List` (`docs/02-technical/ux-flows.md`)
- `9.13.1 States` (`docs/02-technical/ux-flows.md`)
- `9.13.2 Template Row (Recurring)` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)

---

## T-109 — Build Recurring Template Detail / Edit Screen

**Parent Epic:** E-6
**Parent Story:** S-43

### Todo

- [ ] Create `RecurringTemplateDetailScreen` at route `/settings/recurring/:id`
- [ ] Load template via `IRecurringTemplateRepository.watchById(id)`; show shimmer until loaded
- [ ] Render immutable fields as read-only chips/text with Material tooltip showing the copy from §9.14.2
- [ ] Render editable fields as active form inputs (amount, accounts, category, title, description, posting behaviour, transfer fee fields)
- [ ] Disable Save button until at least one editable field is dirty; enable on first change
- [ ] Display next-due-date / paused-until / archived label per §9.14.5 template state
- [ ] Wire Save to `UpdateRecurringTemplateUseCase`; show loading on Save; show Snackbar "Failed to save." on error
- [ ] Write golden tests: loaded state (active), loaded state (paused), dirty state

### References

- `9.14 Screen: Recurring Template Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `9.14.1 States` (`docs/02-technical/ux-flows.md`)
- `9.14.2 Immutable Fields` (`docs/02-technical/ux-flows.md`)
- `9.14.3 Editable Fields` (`docs/02-technical/ux-flows.md`)
- `9.14.5 Next Due Date Display` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)

---

## T-110 — Implement `UpdateRecurringTemplateUseCase` (Editable Fields Only)

**Parent Epic:** E-6
**Parent Story:** S-43

### Todo

- [ ] Create `UpdateRecurringTemplateUseCase` in `domain/usecases/recurring/`
- [ ] Accept `UpdateRecurringTemplateInput` with only the editable field set: amount_minor, account_source_id, account_destination_id, category_id, subcategory_id, title, description, posting_behaviour, fee fields
- [ ] Guard: if input contains any immutable field (transaction_type, recurrence_n, recurrence_unit, recurrence_constraints, start_date, end_date), return `Result.err(BusinessRuleFailure('immutable_field'))`
- [ ] On valid input: call `IRecurringTemplateRepository.update(template)` writing only the editable columns; set `updated_at = now()`
- [ ] Write unit tests: valid update succeeds, immutable field update returns BusinessRuleFailure

### References

- `RECUR-02 — Recurring Template Editing + Child Transaction Handling` (`docs/02-technical/feature-dag.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1. Cross-Cutting Types` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## T-111 — Implement Template Delete + Child Occurrence Cancellation

**Parent Epic:** E-6
**Parent Story:** S-43

### Todo

- [ ] In `IRecurringTemplateRepository.softDelete(id)`: set `is_deleted = 1`, `deleted_at = now()`, `status = 'deleted'` on the template row
- [ ] As part of the same atomic DB transaction: update all `scheduled_occurrences` rows for this template with `status = 'pending'` → `status = 'cancelled'`
- [ ] Template must be hidden from all list queries (filter `is_deleted = 0`)
- [ ] Already-posted child transactions (`child_transaction_id IS NOT NULL`) are retained and fully visible
- [ ] Add delete confirmation dialog in the list long-tap menu before calling soft-delete
- [ ] Write unit tests: soft-delete sets template deleted, all future occurrences cancelled, posted child transactions unaffected

### References

- `RECUR-02 — Recurring Template Editing + Child Transaction Handling` (`docs/02-technical/feature-dag.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `11.2 Soft Delete Policy` (`docs/02-technical/data-model.md`)

---

## T-112 — Implement `SkipOccurrenceUseCase` + Child Transaction "Manually Handled" Marking

**Parent Epic:** E-6
**Parent Story:** S-43

### Todo

- [ ] Create `SkipOccurrenceUseCase` in `domain/usecases/recurring/`
- [ ] Accepts `occurrenceId`; calls `IScheduledOccurrenceRepository.markSkipped(id)`; sets `status = 'skipped'`, `updated_at = now()`
- [ ] In `EditTransactionUseCase` and `SoftDeleteTransactionUseCase`: after the transaction operation succeeds, if the transaction has a parent `scheduled_occurrences` row, call `SkipOccurrenceUseCase` on that row
- [ ] Verify: parent template configuration is unchanged; only the occurrence row is marked skipped
- [ ] Write unit tests: skip occurrence sets status; child edit triggers skip; child soft-delete triggers skip

### References

- `RECUR-02 — Recurring Template Editing + Child Transaction Handling` (`docs/02-technical/feature-dag.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## T-113 — Implement Pause Dialog UI + `PauseRecurringTemplateUseCase`

**Parent Epic:** E-6
**Parent Story:** S-44

### Todo

- [ ] Build `PauseDurationDialog` widget: two modes — "N units" (integer input + read-only unit label derived from template's recurrence_unit) and "Custom date" (date picker); no indefinite pause option
- [ ] Validate: N > 0; custom date must be strictly in the future
- [ ] Create `PauseRecurringTemplateUseCase`: compute `pause_until` epoch from input; call `IRecurringTemplateRepository.pause(id)` which sets `status = 'paused'` + `pause_until`
- [ ] As part of pause: query `scheduled_occurrences` for this template where `status = 'pending'` and `scheduled_date <= pause_until`; call `markSkipped` on each in a single batch transaction
- [ ] Wire dialog to Pause long-tap menu item in list and detail screens
- [ ] Write unit tests: valid pause computes correct epoch, in-window occurrences are skipped

### References

- `RECUR-03 — Recurring Template Pause/Unpause` (`docs/02-technical/feature-dag.md`)
- `9.14.4 Pause Flow` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## T-114 — Implement Unpause + Sweep Auto-Resume Logic

**Parent Epic:** E-6
**Parent Story:** S-44

### Todo

- [ ] In `IRecurringTemplateRepository.resume(id)`: set `status = 'active'`, `pause_until = NULL`, `updated_at = now()`
- [ ] Wire manual Unpause long-tap menu item to `resume(id)` with a confirmation snackbar
- [ ] In `PostDueOccurrencesUseCase` (T-101): before the posting loop, query templates where `status = 'paused'` and `pause_until <= now`; call `resume(id)` for each; do NOT retroactively post their skipped occurrences
- [ ] After resume: ensure sweep only picks up occurrences with `status = 'pending'` and `scheduled_date <= now` (skipped ones are not re-queued)
- [ ] Write unit tests: manual unpause sets active; auto-resume on sweep when pause_until passed; skipped occurrences remain skipped after resume

### References

- `RECUR-03 — Recurring Template Pause/Unpause` (`docs/02-technical/feature-dag.md`)
- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## T-115 — Implement `ReminderAlarmScheduler` Service

**Parent Epic:** E-6
**Parent Story:** S-45

### Todo

- [ ] Add `flutter_local_notifications ^18.0.1` to `pubspec.yaml`
- [ ] Create `ReminderAlarmScheduler` in `infrastructure/scheduling/`
- [ ] `scheduleAlarm(occurrence, template)`: call `FlutterLocalNotificationsPlugin.zonedSchedule(...)` with `AndroidScheduleMode.exactAllowWhileIdle`; payload includes occurrence_id, template_id, amount, account, category
- [ ] `cancelAlarm(occurrenceId)`: cancel the exact alarm for this occurrence by its notification ID (derived from occurrence_id)
- [ ] Notification action buttons: Confirm (posts the occurrence), Edit (deep-links to transaction entry pre-filled), Dismiss (triggers skip flow)
- [ ] On `CreateRecurringTemplateUseCase` completion for `remind_and_confirm` templates: call `ReminderAlarmScheduler.scheduleAlarm` for the next pending occurrence
- [ ] Write unit tests with mocked `FlutterLocalNotificationsPlugin`: verify scheduleAlarm and cancelAlarm are called with correct parameters

### Notes

- One alarm per pending `remind_and_confirm` occurrence; do not batch or coalesce

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `2.6 Scheduling` (`docs/02-technical/sds.md`)
- `2.14.1 Production Dependencies` (`docs/02-technical/sds.md`)

---

## T-116 — Implement Notification Action Handlers (Confirm / Edit / Dismiss)

**Parent Epic:** E-6
**Parent Story:** S-45

### Todo

- [ ] Register `onDidReceiveNotificationResponse` callback in the notification plugin initialisation
- [ ] Confirm action: parse `occurrenceId` from payload; call `PostDueOccurrencesUseCase` for that specific occurrence; cancel the alarm
- [ ] Dismiss action: show in-app confirmation dialog "Skip this occurrence? It will not be posted."; on confirm → call `SkipOccurrenceUseCase(occurrenceId)`; cancel the alarm
- [ ] Edit action: navigate to transaction entry screen pre-filled with template defaults; on save the occurrence will be marked skipped via `SkipOccurrenceUseCase` (same as child transaction edit)
- [ ] Handle the case where action is triggered while the app is in background/killed: use `FlutterLocalNotificationsPlugin.getNotificationAppLaunchDetails()` to detect action on launch
- [ ] Write unit tests for each action handler: correct use case called, alarm cancelled

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.6 Scheduling` (`docs/02-technical/sds.md`)

---

## T-117 — Implement Alerts Strip Pending-Confirmation Card

**Parent Epic:** E-6
**Parent Story:** S-45

### Todo

- [ ] Add "Pending recurring confirmation" alert type to the `AlertsStrip` widget on the Home screen
- [ ] Query `IScheduledOccurrenceRepository` for all `remind_and_confirm` occurrences with `status = 'pending'`; watch reactively
- [ ] For each pending occurrence render a card: template name, date, amount, account, category; action buttons: Confirm / Edit before confirming / Dismiss
- [ ] Dismiss taps in the strip → confirmation dialog "Skip this occurrence? It will not be posted." → Confirm → `SkipOccurrenceUseCase`; Cancel → dialog closes, card remains
- [ ] Confirm taps in the strip → `PostDueOccurrencesUseCase` for that occurrence; card disappears on success
- [ ] Write golden tests: single pending card state, multiple pending cards state, empty (no alerts)

### References

- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)

---

## T-118 — Declare Android Manifest Permissions + Runtime Permission Request Flow

**Parent Epic:** E-6
**Parent Story:** S-46

### Todo

- [ ] Add `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />` to `AndroidManifest.xml`
- [ ] Add `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />` to `AndroidManifest.xml`
- [ ] Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` to `AndroidManifest.xml`
- [ ] Implement `PermissionGateService` in `infrastructure/`: method `requestSchedulingPermissions()` that requests `SCHEDULE_EXACT_ALARM` (API 31+) and `POST_NOTIFICATIONS` (API 33+) in sequence using `permission_handler` or platform channel
- [ ] Call `requestSchedulingPermissions()` when: (a) user creates a `remind_and_confirm` template, or (b) user switches posting_behaviour to `remind_and_confirm` in the edit screen
- [ ] Write unit tests: permission granted path, permission denied path for each permission

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `1.6.8 Scheduling Architecture` (`docs/02-technical/sds.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)

---

## T-119 — Implement Graceful Degradation on Permission Denial

**Parent Epic:** E-6
**Parent Story:** S-46

### Todo

- [ ] Persist `SCHEDULE_EXACT_ALARM` and `POST_NOTIFICATIONS` grant status in `app_settings` (or equivalent Riverpod state)
- [ ] On `SCHEDULE_EXACT_ALARM` denied: do NOT call `ReminderAlarmScheduler.scheduleAlarm`; the template remains `remind_and_confirm` in the DB but behaves as `auto_post` at sweep time
- [ ] In Settings screen (Transaction Entry Settings or relevant sub-screen): show a persistent info notice "Exact alarm permission denied — remind and confirm templates will auto-post at launch" when `SCHEDULE_EXACT_ALARM` is denied
- [ ] On `POST_NOTIFICATIONS` denied: skip notification delivery; occurrence still auto-posts via sweep after 24 hours; no crash
- [ ] Write unit tests: denied SCHEDULE_EXACT_ALARM → no alarm scheduled; denied POST_NOTIFICATIONS → auto-post proceeds

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `9.4 Screen: Transaction Entry Settings` (`docs/02-technical/ux-flows.md`)

---

## T-120 — Implement Stacked Missed Occurrences Auto-Approval in Sweep

**Parent Epic:** E-6
**Parent Story:** S-47

### Todo

- [ ] In `PostDueOccurrencesUseCase`: after processing `auto_post` pending occurrences, query `remind_and_confirm` occurrences with `status = 'pending'` and `scheduled_date < now - 24h`
- [ ] Sort these occurrences ascending by `scheduled_date`
- [ ] Post each in order: use the original `scheduled_date` as the transaction date; pass an `isAutoApproved: true` flag to suppress duplicate-detection and overdraft warnings
- [ ] After all auto-approved postings: return total count of auto-approved occurrences to caller (separate from `auto_post` count)
- [ ] Write unit tests: zero stacked occurrences, one stacked, multiple stacked in correct chronological order; verify original scheduled_date is used; verify warnings suppressed

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## T-121 — Implement Summary Notification + Recurring Catch-Up Banner

**Parent Epic:** E-6
**Parent Story:** S-47

### Todo

- [ ] After `AppInitializer.run()` completes: if auto-approved count ≥ 1, call `FlutterLocalNotificationsPlugin.show(...)` with message "[N] recurring transactions were auto-posted while you were away."
- [ ] In `AppInitializer`: expose auto-approved count via a `ValueNotifier<int>` (or Riverpod provider) consumed by the Home screen
- [ ] In `HomeScreen`: show `RecurringCatchUpBanner` widget at the top of the transaction list when count ≥ 1; banner text: "[N] recurring transactions were auto-posted while you were away."
- [ ] "View details" CTA on banner: apply a filter to the transaction list showing only the auto-posted transactions (filter by transaction IDs returned by the sweep)
- [ ] Banner disappears when user navigates away or dismisses it manually; does not reappear unless a new sweep posts more occurrences
- [ ] Write golden tests: banner shown (N=1, N=5), banner absent (N=0); widget test for "View details" filter navigation

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `6.6 Recurring Catch-Up Banner` (`docs/02-technical/ux-flows.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)

---

## T-122 — Integration Test: App-Launch Sweep End-to-End

**Parent Epic:** E-6
**Parent Story:** S-41

### Todo

- [ ] Write an integration test using `integration_test` package: create a recurring template with `posting_behaviour = 'auto_post'`; advance the system clock past the first scheduled date; restart the app; assert the occurrence is posted (transaction exists in DB) before the first frame
- [ ] Assert 90-day lookahead rows are generated after restart
- [ ] Write an integration test for pause auto-resume: pause a template with `pause_until = 1 hour from now`; advance clock past `pause_until`; restart app; assert template status is `active`
- [ ] Assert WorkManager task is registered (check `Workmanager().isScheduled(...)` or equivalent)

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## T-123 — Integration Test: Remind-and-Confirm Full Flow

**Parent Epic:** E-6
**Parent Story:** S-45

### Todo

- [ ] Write an integration test: create a `remind_and_confirm` template; advance clock to scheduled time; verify exact alarm is scheduled via `FlutterLocalNotificationsPlugin.pendingNotificationRequests()`
- [ ] Simulate Confirm action from notification: verify occurrence is posted, alarm cancelled, `child_transaction_id` set on occurrence row
- [ ] Simulate Dismiss action: verify confirmation dialog appears; confirm dismiss; verify occurrence is `skipped`, no transaction created
- [ ] Simulate 24-hour auto-post: advance clock 24h + launch sweep; verify occurrence is auto-posted with original scheduled_date

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)

---

## T-124 — Define Drift table classes for `installment_plans` and `installment_occurrences`

**Parent Epic:** E-7
**Parent Story:** S-48

### Todo

- [ ] Add `InstallmentPlansTable` Drift table class: columns `template_id` (PK, FK cascade), `total_configured_minor` (NOT NULL, > 0), `number_of_installments` (NOT NULL, > 0), `created_at`
- [ ] Add `InstallmentOccurrencesTable` Drift table class: columns `id` (UUID PK), `template_id` (FK cascade), `sequence_number`, `scheduled_date`, `amount_minor`, `status` (CHECK IN pending/posted/cancelled), `child_transaction_id` (nullable FK), `created_at`, `updated_at`
- [ ] Register both tables in `AppDatabase` class
- [ ] Add custom type converters for `status` enum if not already present in `12.2 Custom Type Converters`
- [ ] Run `dart run build_runner build` and verify generated code compiles

### References

- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `12.2 Custom Type Converters` (`docs/02-technical/data-model.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## T-125 — Write Drift schema migration for installment tables

**Parent Epic:** E-7
**Parent Story:** S-48

### Todo

- [ ] Increment `schemaVersion` in `AppDatabase`
- [ ] Write `onUpgrade` migration step: `CREATE TABLE installment_plans (...)` and `CREATE TABLE installment_occurrences (...)`
- [ ] Add indexes: `idx_inst_occ_template_seq` (UNIQUE on `template_id, sequence_number`) and `idx_inst_occ_status_date` (on `status, scheduled_date`)
- [ ] Generate and commit new schema JSON dump under `lib/data/database/schema/`
- [ ] Write migration unit test using `SchemaVerifier` against the committed schema dump

### References

- `8.2.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `13. Index Catalogue` (`docs/02-technical/data-model.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## T-126 — Implement `InstallmentPlanDao` and `InstallmentOccurrenceDao`

**Parent Epic:** E-7
**Parent Story:** S-48

### Todo

- [ ] Create `InstallmentPlanDao` (`DatabaseAccessor`) with methods: `watchAll()`, `watchById(id)`, `insertPlan(plan)`, `updatePlan(plan)`, `deletePlan(id)`
- [ ] Create `InstallmentOccurrenceDao` with methods: `watchByPlan(planId)` (ordered by `sequence_number`), `insertOccurrences(List<...>)` (bulk), `updateOccurrence(occ)`, `deleteOccurrence(id)`, `markPosted(id, transactionId)`
- [ ] Add `cancelPendingOccurrences(templateId)` batch update method to `InstallmentOccurrenceDao` for early close
- [ ] Write unit tests for each DAO method using `NativeDatabase.memory()`

### References

- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)
- `2.7.2 IInstallmentOccurrenceRepository` (`docs/02-technical/api-contracts.md`)

---

## T-127 — Define `InstallmentPlan` and `InstallmentOccurrence` domain entities

**Parent Epic:** E-7
**Parent Story:** S-49

### Todo

- [ ] Create `lib/domain/entities/installment_plan.dart` as a `@freezed` class with fields: `id`, `templateId`, `totalConfiguredMinor`, `numberOfInstallments`, `createdAt`
- [ ] Create `lib/domain/entities/installment_occurrence.dart` as a `@freezed` class with fields: `id`, `templateId`, `sequenceNumber`, `scheduledDate`, `amountMinor`, `status` (sealed enum: pending/posted/cancelled), `childTransactionId` (nullable), `createdAt`, `updatedAt`
- [ ] Define `InstallmentOccurrenceStatus` as a Dart enum or sealed class
- [ ] Run `build_runner` to generate Freezed code; verify zero Flutter imports in entity files

### References

- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `2.5.1 Freezed — Domain Entities` (`docs/02-technical/sds.md`)
- `1.5.3 Domain Boundary Rules` (`docs/02-technical/sds.md`)

---

## T-128 — Define `IInstallmentPlanRepository` and `IInstallmentOccurrenceRepository` interfaces

**Parent Epic:** E-7
**Parent Story:** S-49

### Todo

- [ ] Create `lib/domain/repositories/installment_plan_repository.dart` with abstract methods: `watchAll()`, `watchById(id)`, `create(plan)`, `update(plan)`, `closeEarly(id)` — all returning `Result<T>`-wrapped futures or streams
- [ ] Create `lib/domain/repositories/installment_occurrence_repository.dart` with abstract methods: `watchByPlan(planId)`, `markPosted(id, transactionId)` — returning `Result<T>` futures or streams
- [ ] Ensure no Drift or Flutter imports in interface files

### References

- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)
- `2.7.2 IInstallmentOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)
- `1.5.3 Domain Boundary Rules` (`docs/02-technical/sds.md`)

---

## T-129 — Implement repository classes and DTOs for installment entities

**Parent Epic:** E-7
**Parent Story:** S-49

### Todo

- [ ] Create `InstallmentPlanDto` with `fromRow(InstallmentPlansTableData)` and `toEntity()` conversion
- [ ] Create `InstallmentOccurrenceDto` with `fromRow(InstallmentOccurrencesTableData)` and `toEntity()` conversion
- [ ] Create `InstallmentPlanRepositoryImpl` implementing `IInstallmentPlanRepository`; delegate to `InstallmentPlanDao`; wrap DAO exceptions in `Err(DatabaseFailure(...))`
- [ ] Create `InstallmentOccurrenceRepositoryImpl` implementing `IInstallmentOccurrenceRepository`; delegate to `InstallmentOccurrenceDao`
- [ ] Register both repository impls in Riverpod DI (provider files under `presentation/providers/`)
- [ ] Write unit tests against in-memory DB for both repository impls

### References

- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)
- `2.7.2 IInstallmentOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.5.2 json_serializable — Data Transfer Objects` (`docs/02-technical/sds.md`)
- `2.9.3 Layer-Boundary Rules` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)

---

## T-130 — Implement `CreateInstallmentPlanUseCase` — core creation logic

**Parent Epic:** E-7
**Parent Story:** S-50

### Todo

- [ ] Create `lib/domain/usecases/installment/create_installment_plan_use_case.dart`
- [ ] Validate inputs: `total_configured > 0`, `number_of_installments > 0`, `start_date` non-null, transaction type one of income/expense/transfer
- [ ] Within a single DB transaction: insert `recurring_templates` row (`is_installment = 1`), insert `installment_plans` row, bulk-insert all `installment_occurrences` rows
- [ ] Compute `end_date = start_date + (number_of_installments × recurrence_period)` — use `PeriodCalculator` domain service; no iteration loops (SDS §1.6.10)
- [ ] Compute per-installment `amount_minor = total_configured_minor ÷ number_of_installments`; assign full remainder to last occurrence
- [ ] Return `Err(ValidationFailure(...))` for invalid inputs; `Err(DatabaseFailure(...))` for DB errors

### References

- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)
- `2.7.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations` (`docs/02-technical/sds.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)

---

## T-131 — Implement `CreateInstallmentPlanUseCase` — transfer type and fee support

**Parent Epic:** E-7
**Parent Story:** S-50

### Todo

- [ ] Extend use case input model to carry `accountSourceId`, `accountDestinationId`, `feeMode`, `feeAmountMinor`, `feeCategoryId` fields
- [ ] When `transaction_type = 'transfer'`, validate that `account_source_id` and `account_destination_id` are both provided and non-equal
- [ ] Write `recurring_templates.fee_mode`, `fee_amount_minor`, `fee_percentage_micro`, `fee_category_id` columns when fee is present
- [ ] Unit tests: transfer with no fee, transfer with flat fee, transfer with percentage fee, source == destination (validation failure)

### References

- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)
- `1.3 Transfer Fee Fields (§5.1.5b)` (`docs/01-product/input-fields.md`)

---

## T-132 — Implement tracking amount query service

**Parent Epic:** E-7
**Parent Story:** S-51

### Todo

- [ ] Create `InstallmentTrackingAmounts` value object (or extend `InstallmentPlan` entity) with fields: `totalConfiguredMinor`, `runningTotalMinor`, `totalRemainingMinor`, `projectedFinalTotalMinor`, `hasMismatch` (bool)
- [ ] Add `watchTrackingAmounts(templateId)` method to `InstallmentOccurrenceDao`: SQL query that JOINs `installment_occurrences` with `transactions` ON `child_transaction_id` WHERE `transactions.is_deleted = 0`
  - `running_total` = `SUM(amount_minor) WHERE status='posted'` (with void exclusion join)
  - `total_remaining` = `SUM(amount_minor) WHERE status='pending'`
- [ ] For corrected transactions: join via correction chain to use latest non-deleted transaction amount
- [ ] Expose as `Stream<InstallmentTrackingAmounts>` from repository impl
- [ ] Unit tests: zero-posted state, partial, all-posted, voided-child excluded, corrected-child uses corrected amount

### References

- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `11.3 Void/Reversal Chain Policy` (`docs/02-technical/data-model.md`)
- `2.7.4 Notifiers` (`docs/02-technical/api-contracts.md`)

---

## T-133 — Implement `InstallmentPlanDetailNotifier` Riverpod provider

**Parent Epic:** E-7
**Parent Story:** S-51

### Todo

- [ ] Create `InstallmentPlanDetailNotifier` as a Riverpod `AsyncNotifier<InstallmentPlanDetail>` (combines `InstallmentPlan` + `List<InstallmentOccurrence>` + `InstallmentTrackingAmounts`)
- [ ] Watch `IInstallmentPlanRepository.watchById(id)` and `InstallmentOccurrenceRepository.watchByPlan(id)` and `trackingAmounts` stream simultaneously
- [ ] Expose `hasMismatch` flag to the UI layer
- [ ] Create `InstallmentPlanListNotifier` as a Riverpod `AsyncNotifier<List<InstallmentPlan>>` watching `IInstallmentPlanRepository.watchAll()`

### References

- `2.7.4 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)
- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)

---

## T-134 — Build `CreateInstallmentScreen` scaffold and installment-specific fields

**Parent Epic:** E-7
**Parent Story:** S-52

### Todo

- [ ] Create `lib/presentation/features/installments/create_installment_screen.dart` as a full-screen modal (`modal-slide-up` transition)
- [ ] Add AppBar: `SmallTopAppBar`, title "New Installment Plan", close icon `Icons.close`
- [ ] Wrap body in `SingleChildScrollView`
- [ ] Add `Total amount` field: `OutlinedTextField` with `displayHeroAmount` token; required; show immutable badge label after initial entry
- [ ] Add `Number of installments` field: numeric `OutlinedTextField`; required
- [ ] Add `Per-installment amounts` section: auto-calculated `OutlinedTextField` with helper text "Auto: total ÷ count"; overridable
- [ ] Add `End date` read-only display: `Text` widget `bodyMedium`, `onSurfaceVariant`, "Ends: [computed date]"

### References

- `6.4 Create Installment Screen` (`docs/02-technical/ui-spec.md`)
- `6.4.1 Components — Additional (beyond §6.3.1)` (`docs/02-technical/ui-spec.md`)
- `7.4 Create Installment Transaction Screen` (`docs/02-technical/ux-flows.md`)
- `7.4.1 Additional Installment Fields` (`docs/02-technical/ux-flows.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)

---

## T-135 — Wire reactive end date, per-installment auto-calc, and mismatch warning on create screen

**Parent Epic:** E-7
**Parent Story:** S-52

### Todo

- [ ] Implement `InstallmentCreateFormNotifier` (Riverpod `Notifier`) holding: total amount, count, per-installment overrides list, start date, recurrence config
- [ ] Recompute `end_date` whenever `start_date`, count, or recurrence unit/period changes; update read-only display field
- [ ] Recompute `per_installment_amount` whenever total or count changes (only if user has not overridden that row)
- [ ] Compute `projected_final_total = SUM(per_installment_amounts)` reactively
- [ ] Show `Card` mismatch warning (`warningAmount` tint) when `projected_final_total ≠ total_configured`; Save button remains enabled
- [ ] Widget tests: end date updates on count change, warning appears on manual override causing mismatch, warning clears on correction

### References

- `6.4.1 Components — Additional (beyond §6.3.1)` (`docs/02-technical/ui-spec.md`)
- `6.4.2 States` (`docs/02-technical/ui-spec.md`)
- `7.17 Flow — Create Installment (additional steps after §7.16 steps 1–2)` (`docs/02-technical/ux-flows.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## T-136 — Connect create screen to use case and handle all transaction types

**Parent Epic:** E-7
**Parent Story:** S-52

### Todo

- [ ] Add transaction type selector (income / expense / transfer) to form; reuse shared type selector component
- [ ] Show account source + destination pickers when type = transfer (reuse `AccountPicker` sheet)
- [ ] Show fee panel (fee mode, amount/percentage, fee category) when type = transfer and fee enabled; reuse from recurring template form
- [ ] On tap Save: call `CreateInstallmentPlanUseCase` with form state; transition to loading state
- [ ] On success: dismiss modal, show `SnackBar` "Installment plan saved"
- [ ] On failure: show error snackbar; form state preserved
- [ ] Golden tests for: expense filled, transfer filled, transfer-with-fee, mismatch warning visible

### References

- `7.17 Flow — Create Installment (additional steps after §7.16 steps 1–2)` (`docs/02-technical/ux-flows.md`)
- `6.4.2 States` (`docs/02-technical/ui-spec.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)
- `2.9.5 Form State Preservation` (`docs/02-technical/sds.md`)

---

## T-137 — Build `InstallmentPlanDetailScreen` — summary card and static scaffold

**Parent Epic:** E-7
**Parent Story:** S-53

### Todo

- [ ] Create `lib/presentation/features/installments/installment_plan_detail_screen.dart` at route `/settings/installments/:id`
- [ ] Add `SmallTopAppBar` with back arrow, title "Installment Plan", trailing `FilledButton` "Save" (disabled initially)
- [ ] Build 2×2 `GridView` summary card (`Card`, `surfaceContainerLow`): cells for "Target total" / "Paid to date" / "Remaining" / "Projected total" each with `bodySmall` label + `bodyLarge` value
- [ ] Add mismatch `Banner` widget (`warningAmount` / `warningContainer`) shown when `hasMismatch = true`; inline, non-blocking
- [ ] Wire to `InstallmentPlanDetailNotifier`; show shimmer on loading state

### References

- `9.16 Installment Plan Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.16.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.16.2 Summary Card (4 Tracked Amounts)` (`docs/02-technical/ux-flows.md`)
- `9.16 Screen: Installment Plan Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)

---

## T-138 — Build per-installment list with inline editing and add/remove actions

**Parent Epic:** E-7
**Parent Story:** S-53

### Todo

- [ ] Render per-installment list below summary card: columns #, scheduled date, amount (editable if unposted), status badge (`Chip`)
- [ ] Status badge colors: Scheduled = default; Posted = `primaryContainer`; Cancelled = `onSurfaceVariant`
- [ ] Tap on amount for unposted row: show inline `TextField` edit; mark form dirty on change
- [ ] Swipe-left on unposted row: delete occurrence; update tracking amounts stream reactively
- [ ] `FloatingActionButton` "Add installment": append new `InstallmentOccurrence` with `scheduled_date = last_occurrence_date + recurrence_period` and auto-filled `amount_minor`
- [ ] Save button calls repository update for all modified occurrences atomically
- [ ] Widget tests: tap-to-edit appears only for unposted rows; swipe-delete removes row; FAB adds row

### References

- `9.16.3 Per-Installment List` (`docs/02-technical/ux-flows.md`)
- `9.16.4 Add / Remove Installments` (`docs/02-technical/ux-flows.md`)
- `9.16.1 Components` (`docs/02-technical/ui-spec.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## T-139 — Build `InstallmentPlansListScreen` — Installments tab with template rows

**Parent Epic:** E-7
**Parent Story:** S-54

### Todo

- [ ] Wire the Installments tab in `RecurringTemplatesListScreen` to consume `InstallmentPlanListNotifier`
- [ ] Render three `SliverList` groups: Active / Paused / Archived, each with a group header `Text` (`sectionHeading`, `onSurfaceVariant`)
- [ ] Build `InstallmentTemplateRow` widget: title `bodyLarge`, `LinearProgressIndicator` (value = posted_count / total_count), `bodySmall` label "₹X paid of ₹Y"
- [ ] Assign status badge `Chip`: Active = `accentPastel` green; Paused = `warningAmount` amber; Archived = `onSurfaceVariant`
- [ ] Implement loading shimmer, empty state (per tab), and error+retry states per `9.13.4` spec

### References

- `9.15 Screen: Installment Plans List` (`docs/02-technical/ux-flows.md`)
- `9.13.3 Template Row (Installment)` (`docs/02-technical/ux-flows.md`)
- `9.13.1 States` (`docs/02-technical/ux-flows.md`)
- `9.15 Installment Plans List` (`docs/02-technical/ui-spec.md`)
- `9.13.3 Installment Template Row` (`docs/02-technical/ui-spec.md`)
- `9.13.4 States` (`docs/02-technical/ui-spec.md`)

---

## T-140 — Implement long-press contextual menu on installment template row

**Parent Epic:** E-7
**Parent Story:** S-54

### Todo

- [ ] Add `GestureDetector` long-press handler on `InstallmentTemplateRow` that shows `ModalBottomSheet`
- [ ] Menu items per status: Active → Edit / Delete / Pause / View child transactions / View progress / Mark series as complete; Paused → same + Unpause; Archived → View child transactions / View progress (read-only)
- [ ] "Mark series as complete" item pushes into the early-close flow (T-141)
- [ ] "View progress" navigates to `/settings/installments/:id`
- [ ] "Edit" navigates to installment edit screen (pre-filled form)
- [ ] "Delete" shows confirmation dialog; on confirm calls repository soft-delete
- [ ] Widget tests for menu item visibility per status

### References

- `9.13.3 Template Row (Installment)` (`docs/02-technical/ux-flows.md`)
- `9.13.3 Installment Template Row` (`docs/02-technical/ui-spec.md`)
- `9.13 Screen: Recurring Templates List` (`docs/02-technical/ux-flows.md`)
- `INST-03 — Installment Early Close` (`docs/02-technical/feature-dag.md`)

---

## T-141 — Implement `CloseInstallmentPlanUseCase`

**Parent Epic:** E-7
**Parent Story:** S-55

### Todo

- [ ] Create `lib/domain/usecases/installment/close_installment_plan_use_case.dart`
- [ ] Input: `templateId`, optional `finalPaymentData` (amount, date, account fields, category, description)
- [ ] If `finalPaymentData` provided: create and post child transaction via existing `TxnRepository` / ledger engine; link via `parent_template_id`; include in `running_total` before mismatch check
- [ ] Within a single DB transaction: cancel all pending occurrences (`status = 'cancelled'`), set `recurring_templates.status = 'archived'`, `archived_reason = 'early_close'`
- [ ] Compute post-close `running_total`; if `running_total ≠ total_configured`, return `Result` indicating mismatch with amounts for UI decision dialog
- [ ] Implement `updateTotalOnEarlyClose(templateId, newTotal)` as a separate guarded method — this is the only write path for `total_configured_minor` post-creation
- [ ] Return `Err(BusinessRuleFailure)` if template is already archived

### Notes

- Final payment must be posted and committed before occurrences are cancelled, within the same transaction

### References

- `INST-03 — Installment Early Close` (`docs/02-technical/feature-dag.md`)
- `2.7.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `2.9.1 Decision — TC-033: Result Type Pattern` (`docs/02-technical/sds.md`)

---

## T-142 — Build early-close UI flow dialogs and transaction entry handoff

**Parent Epic:** E-7
**Parent Story:** S-55

### Todo

- [ ] "Mark series as complete" triggers `AlertDialog`: "Record a final payment before closing?" — Yes / No buttons
- [ ] "Yes" path: push transaction entry screen pre-filled with template's transaction type, accounts, category, title, description; `amount` field left for user input
- [ ] On transaction entry save: return to early-close flow with `finalPaymentData`; proceed to close use case call
- [ ] "No" path: call `CloseInstallmentPlanUseCase` with no final payment directly
- [ ] After use case returns: if mismatch, show second `AlertDialog`: "Update target to [running_total]?" — Yes (call `updateTotalOnEarlyClose`) / No (archive as-is)
- [ ] Both dialog paths end with: pop back to installment list; show `SnackBar` "Plan closed"
- [ ] Widget tests: yes-path with final payment, no-path, mismatch dialog yes, mismatch dialog no

### References

- `9.16.5 Early Close Flow` (`docs/02-technical/ux-flows.md`)
- `9.16.2 Early Close Flow Components` (`docs/02-technical/ui-spec.md`)
- `5.2 Installment Early Close (§5.2.8, FG-B7)` (`docs/01-product/input-fields.md`)
- `INST-03 — Installment Early Close` (`docs/02-technical/feature-dag.md`)

---

## T-143 — Unit tests for `CreateInstallmentPlanUseCase`

**Parent Epic:** E-7
**Parent Story:** S-50

### Todo

- [ ] Test: income type — correct number of occurrences materialised, end date correct, per-installment amounts sum to total
- [ ] Test: expense type — same as above
- [ ] Test: transfer type — `account_source_id` and `account_destination_id` populated
- [ ] Test: transfer-with-fee — fee columns populated on template row
- [ ] Test: `total_configured = 0` → returns `Err(ValidationFailure)`
- [ ] Test: `number_of_installments = 0` → returns `Err(ValidationFailure)`
- [ ] Test: manual per-installment overrides that sum to ≠ `total_configured` — creation succeeds (non-blocking mismatch)
- [ ] Test: DB failure during bulk occurrence insert → full rollback, no partial rows

### References

- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)
- `2.11.2 Unit Testing` (`docs/02-technical/sds.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)

---

## T-144 — Unit tests for tracking amount queries and `CloseInstallmentPlanUseCase`

**Parent Epic:** E-7
**Parent Story:** S-51

### Todo

- [ ] Test `watchTrackingAmounts`: zero-posted → `running_total = 0`
- [ ] Test: partial postings → `running_total` equals sum of posted `amount_minor` values
- [ ] Test: voided child transaction (`is_deleted = 1`) excluded from `running_total`
- [ ] Test: corrected child transaction — `running_total` uses corrected amount, not original
- [ ] Test: `projected_final_total = running_total + total_remaining` at all states
- [ ] Test `CloseInstallmentPlanUseCase`: no-final-payment path — all pending occurrences cancelled, template archived
- [ ] Test: final-payment path — final transaction posted and linked; included in `running_total`
- [ ] Test: mismatch path — use case returns mismatch flag with correct amounts
- [ ] Test: `updateTotalOnEarlyClose` updates `total_configured_minor` to `running_total`
- [ ] Test: calling close on already-archived template returns `Err(BusinessRuleFailure)`

### References

- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)
- `INST-03 — Installment Early Close` (`docs/02-technical/feature-dag.md`)
- `2.11.2 Unit Testing` (`docs/02-technical/sds.md`)
- `11.3 Void/Reversal Chain Policy` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)

---

## T-145 — Golden tests for installment screens

**Parent Epic:** E-7
**Parent Story:** S-52

### Todo

- [ ] Golden test `CreateInstallmentScreen`: empty state (Save disabled), filled-expense state, filled-transfer state, mismatch-warning state, saving state
- [ ] Golden test `InstallmentPlanDetailScreen`: loading (shimmer), loaded-no-mismatch, loaded-with-mismatch-banner, dirty state
- [ ] Golden test `InstallmentTemplateRow` within list: active with progress bar, paused, archived
- [ ] Capture all goldens on fixed Android emulator (API 34, Pixel 6); commit snapshots
- [ ] Verify `alchemist --ci` mode passes in CI pipeline

### References

- `2.11.4 Golden Tests` (`docs/02-technical/sds.md`)
- `6.4.2 States` (`docs/02-technical/ui-spec.md`)
- `9.16.3 States` (`docs/02-technical/ui-spec.md`)
- `9.13.4 States` (`docs/02-technical/ui-spec.md`)

---

## T-146 — Implement `HomeState` Domain Entity and `HomeNotifier`

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Define `HomeState` Freezed entity: fields `selectedMonth`, `greeting`, `netWorth`, `monthlySummary`, `alertsLoading`, `listLoading`
- [ ] Define `MonthlySummary` value object: `income`, `expenses`, `net`, `currency`, `hasStaleFx` flag
- [ ] Implement `HomeNotifier` as `@riverpod AsyncNotifier<HomeState>` in `lib/features/home/presentation/notifiers/home_notifier.dart`
- [ ] Wire `WatchNetWorthUseCase` and `WatchMonthlySummaryUseCase` streams inside `HomeNotifier.build()`
- [ ] Expose `changeMonth(int year, int month)` method that re-subscribes the summary stream with new params
- [ ] Write unit tests: month change re-queries correctly; loading/error states propagate

### References

- `2.10.2 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-147 — Implement `WatchNetWorthUseCase`

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `WatchNetWorthUseCase` in `lib/features/home/domain/use_cases/watch_net_worth_use_case.dart`
- [ ] Query all non-deleted accounts where `include_in_net_worth = true` and `category != 'equity'`
- [ ] For each account, sum entry amounts using DEB formula; convert to home currency via `exchange_rate_to_home`
- [ ] Emit `Money` with home currency code; exclude accounts with no cached FX rate and set `hasStaleFx = true` on `MonthlySummary`
- [ ] Return `Stream<Money>` via Drift `watchStatement()`
- [ ] Write unit tests: EQ excluded; stale FX flag set when rate missing; correct sum across currencies

### References

- `2.10.1 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-148 — Implement `WatchMonthlySummaryUseCase`

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `WatchMonthlySummaryUseCase` in `lib/features/home/domain/use_cases/watch_monthly_summary_use_case.dart`
- [ ] Accept `(int year, int month)` parameters; compute date range boundaries
- [ ] Query `entries` joined to `transactions` for income-type and expense-type transactions in the month range
- [ ] Aggregate income and expenses; compute net = income − expenses; convert to home currency
- [ ] Return `Stream<MonthlySummary>` that re-emits on every DB write to the `entries` table
- [ ] Write unit tests: correct aggregation per month; zero values for empty month; future month only counts pending transactions

### References

- `2.10.1 Use Cases` (`docs/02-technical/api-contracts.md`)
- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-149 — Implement Greeting Row Widget

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `GreetingRow` `StatelessWidget` in `lib/features/home/presentation/widgets/greeting_row.dart`
- [ ] Read `display_name` from `app_settings` via `AppSettingsNotifier`
- [ ] Render "Hi, [name]!" when name is set; "Hi!" otherwise
- [ ] Apply `bodyLarge`, `onSurface` token per `§5.1.1` spec
- [ ] Write widget test: both name-set and name-absent states render correct text

### References

- `6.2 Greeting` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-150 — Implement Financial Summary Card Grid

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `FinancialSummaryGrid` widget: 2×2 grid with 8 dp gaps, 4 `ElevatedCard` widgets
- [ ] Net Worth card: `surfaceContainerLow`, `numericLarge` amount, `onSurface` text
- [ ] Income card: `incomeAmount` token for amount
- [ ] Expenses card: `expenseAmount` token for amount
- [ ] Net card: conditional color — `incomeAmount` if positive, `expenseAmount` if negative, `onSurface` if zero
- [ ] All cards consume `AsyncValue<HomeState>` from `HomeNotifier`; show skeleton shimmer in loading state
- [ ] Write widget test: loading state shows placeholders; populated state shows correct values and colors

### References

- `6.3 Financial Summary` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-151 — Implement Month Selector Widget

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `MonthSelector` `StatelessWidget` in `lib/features/home/presentation/widgets/month_selector.dart`
- [ ] Render `IconButton(Icons.chevron_left)` + `Text` (month/year) + `IconButton(Icons.chevron_right)`
- [ ] Apply `bodyMedium` text, `onSurface`; icon buttons `onSurfaceVariant`
- [ ] Tap left: call `homeNotifier.changeMonth(prevMonth)` and re-query summary + list
- [ ] Tap right: call `homeNotifier.changeMonth(nextMonth)` — future months allowed
- [ ] Default selected month is current calendar month on first render
- [ ] Write widget test: tapping left/right emits correct year/month to the notifier

### References

- `6.4 Month Selector` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-152 — Implement Home Screen Skeleton, Error, and FX Banner States

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Implement loading skeleton: shimmer on greeting line (120 dp), 4 card placeholders (80 dp), 6 row placeholders
- [ ] Implement error state: `ErrorCard` (`errorContainer`) with retry `FilledButton` that calls `homeNotifier.reload()`
- [ ] Implement stale FX `MaterialBanner`: warning icon + "Exchange rate may be outdated" + Dismiss; dismissed once per session via local `ValueNotifier`
- [ ] Implement no-FX-rate state: net worth card shows "—" with `bodySmall` disclaimer footnote
- [ ] Implement future-month state: summary shows "Projected" label; list shows pending transactions with muted styling
- [ ] Write widget tests for all 5 states

### References

- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)
- `5.1.4 States` (`docs/02-technical/ui-spec.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)

---

## T-153 — Implement `HomeScreen` Scaffold (CustomScrollView + SliverList)

**Parent Epic:** E-8
**Parent Story:** S-56

### Todo

- [ ] Create `HomeScreen` widget in `lib/features/home/presentation/screens/home_screen.dart`
- [ ] Use `CustomScrollView` with: `SliverToBoxAdapter` for greeting + summary grid, `SliverPersistentHeader` (pinned) for month selector, `SliverToBoxAdapter` for alerts strip + catch-up banner, `SliverList.builder` for date-grouped transaction rows
- [ ] No `AppBar`; greeting and summary are embedded in the scrollable body
- [ ] `ShellRoute` integration: home screen is the root of the Home tab with persistent bottom nav
- [ ] Write widget smoke test: screen mounts without overflow errors in loading and populated states

### References

- `5.1 Home Screen` (`docs/02-technical/ui-spec.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)
- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)

---

## T-154 — Implement Cursor-Based Paginated Transaction List Provider

**Parent Epic:** E-8
**Parent Story:** S-57

### Todo

- [ ] Create `HomeTransactionListNotifier` as `@riverpod AsyncNotifier` in `lib/features/home/presentation/notifiers/home_transaction_list_notifier.dart`
- [ ] Implement cursor-based pagination: `WHERE date < :cursor ORDER BY date DESC LIMIT 51`; extra row determines `hasNextPage`
- [ ] Parameterise query by `(year, month)` from `HomeNotifier.selectedMonth`; reset cursor on month change
- [ ] Expose `loadNextPage()` method; suppress call when `hasNextPage = false` or already loading
- [ ] Apply exclusion predicates: `is_deleted = false`, `status != 'voided'`, `purpose != 'adjustment'` (invisible journal), `is_superseded = false`
- [ ] Write unit tests: page boundary logic; exclusion predicates applied; month-change resets cursor

### References

- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)
- `6.8.4 Excluded from Default List` (`docs/02-technical/ux-flows.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-155 — Implement 3-Column Transaction Row Widget

**Parent Epic:** E-8
**Parent Story:** S-57

### Todo

- [ ] Create `TransactionRow` `StatelessWidget` in `lib/features/home/presentation/widgets/transaction_row.dart`
- [ ] C1 (Leading): `Column` with `Icon(categoryIcon, 24)` + `Text(parentName)` row 1; `Text(subcategoryName)` row 2 if subcategory exists; "Transfer" label for transfers (no icon)
- [ ] C2 (Title/Account): Row 1 `Text(title)` `bodyLarge onSurface`; Row 2 `Text(accountInfo)` `bodySmall onSurfaceVariant`; accountInfo = source for expense, destination for income, "Source → Destination" for transfer
- [ ] C3 (Trailing): Row 1 amount + currency symbol `numericMedium`; Row 2 FX equivalent `numericSmall onSurfaceVariant` only for foreign-currency accounts; income green, expense red, transfer neutral
- [ ] Pending badge: `Badge` overlay on C1 icon, `tertiary/onTertiary`, "Pending" label; muted `onSurfaceVariant` styling on entire row
- [ ] ISO 4217 code disambiguation: show ISO code when ≥ 2 currencies share a symbol
- [ ] Write golden test for all 3 transaction types (expense/income/transfer) and for foreign-currency row

### References

- `6.8.2 Row Layout (3-Column)` (`docs/02-technical/ux-flows.md`)
- `5.1.2 Transaction Row (3-Column ListTile)` (`docs/02-technical/ui-spec.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-156 — Implement Date-Group Headers and SliverList Builder

**Parent Epic:** E-8
**Parent Story:** S-57

### Todo

- [ ] Create `TransactionDateGroupHeader` widget: `Text` `bodyMedium bold`, `onSurfaceVariant`, left-aligned, 8 dp vertical padding
- [ ] Implement `SliverList.builder` in `HomeScreen` that inserts a group header `SliverPersistentHeader` (not pinned) before the first row of each new calendar day
- [ ] Grouping performed in query/DAO layer: query returns rows annotated with `date_group` key; widget uses it to detect group boundaries
- [ ] Confirm `SliverList.builder` pattern; never use `ListView` with pre-built children list
- [ ] Write widget test: 3 transactions across 2 days renders 2 headers and 3 rows in correct order

### References

- `6.8.3 Grouping & Ordering` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)

---

## T-157 — Implement Swipe Actions and Long-Press Menu on Transaction Rows

**Parent Epic:** E-8
**Parent Story:** S-57

### Todo

- [ ] Wrap `TransactionRow` in `Dismissible` for swipe-left (delete) and swipe-right (edit)
- [ ] Swipe-left: red `errorContainer` background, `Icons.delete_outline`; on confirm show dialog "Delete this transaction?"; on confirm post soft-delete; show snackbar with "Undo" action; undo re-posts the transaction
- [ ] Swipe-right: green `secondaryContainer` background, `Icons.edit_outlined`; navigate to `/transaction/:id/edit`
- [ ] Long-press: open `ModalBottomSheet` with `ListTile` Edit and `ListTile` Delete; Edit navigates to edit screen; Delete shows same dialog as swipe-left
- [ ] Write widget test: swipe-left confirm deletes row; undo restores row; swipe-right navigates; long-press menu has both actions

### References

- `6.8.5 Swipe Actions` (`docs/02-technical/ux-flows.md`)
- `6.8.6 Long-Press Contextual Menu` (`docs/02-technical/ux-flows.md`)
- `5.1.2 Transaction Row (3-Column ListTile)` (`docs/02-technical/ui-spec.md`)
- `6.8 Void / Soft-Delete Flows` (`docs/02-technical/ui-spec.md`)

---

## T-158 — Implement FTS5 Search DAO and `SearchRanker`

**Parent Epic:** E-8
**Parent Story:** S-58

### Todo

- [ ] Create `SearchDao` in `lib/features/home/data/daos/search_dao.dart`
- [ ] Implement Stage 1 FTS5 query: `SELECT transaction_id, rank FROM transactions_fts WHERE transactions_fts MATCH '{title account_name}: "^{query}" OR {description category_name}: "{query}"' ORDER BY rank LIMIT 500`
- [ ] Join FTS candidate IDs back to `transactions` + `accounts` + `categories` tables for full row data
- [ ] Create `SearchRanker` in `lib/features/home/domain/services/search_ranker.dart`
- [ ] Apply field-weight scoring: exact title 1.00, prefix title 0.80, prefix account 0.70, substring title 0.60, substring description 0.30, substring category 0.25
- [ ] Apply Levenshtein distance-1 typo tolerance in Dart on the ≤500 candidate set
- [ ] Tiebreaker: equal scores sort by `transaction_date DESC`
- [ ] Write unit tests: ranking order for exact vs. prefix vs. substring; typo tolerance ("cofee" → "coffee"); empty query returns empty

### References

- `2.8.2 FTS5 Schema` (`docs/02-technical/sds.md`)
- `2.8.3 Ranking Algorithm` (`docs/02-technical/sds.md`)
- `10.1 transactions_fts` (`docs/02-technical/data-model.md`)
- `10.2 transactions_search_view` (`docs/02-technical/data-model.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)

---

## T-159 — Implement `SearchNotifier` with Global Scope and Debounce

**Parent Epic:** E-8
**Parent Story:** S-58

### Todo

- [ ] Create `SearchNotifier` as `@riverpod Notifier<SearchState>` in `lib/features/home/presentation/notifiers/search_notifier.dart`
- [ ] `SearchState` fields: `query`, `results`, `isActive`, `isLoading`
- [ ] On query change: debounce 300 ms then call `SearchDao` with global scope (no date predicate per TC-050)
- [ ] On query clear: set `isActive = false`; home list re-engages month filter
- [ ] Expose `activate()`, `updateQuery(String)`, `dismiss()` methods
- [ ] When filter is also active, pass filter criteria to the DAO alongside the FTS query
- [ ] Write unit tests: debounce fires after 300 ms; clear re-engages month filter; global scope has no date constraint

### Notes

- TC-050 founder resolution: search must NOT include a date predicate. SDS §2.8.4 describes month-scoped search — this is a known inconsistency; ignore SDS §2.8.4 for the date predicate.

### References

- `2.8.4 Search Scope` (`docs/02-technical/sds.md`)
- `7.8.2 Search Flow — Step by Step` (`docs/02-technical/ux-flows.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)

---

## T-160 — Implement Search Overlay UI (M3 SearchBar + Results List)

**Parent Epic:** E-8
**Parent Story:** S-58

### Todo

- [ ] Implement M3 `SearchBar` → `SearchView` expand animation within the Home `ShellRoute`; does not push a new route
- [ ] `AppBar` replaced by full-width `SearchBar` when active: leading `Icons.arrow_back`, trailing `Icons.close` (visible on non-empty query)
- [ ] Render search results as `CustomScrollView` with date-grouped `SliverList`; same 3-column `TransactionRow` layout
- [ ] Matched text highlighted via `RichText`/`TextSpan` with `primary` bold in title and account name columns
- [ ] Show `Icons.filter_list` `IconButton` in trailing area; opens `FilterBottomSheet` on top of search results
- [ ] Hide FAB while search is active
- [ ] Implement all 7 states: idle, active-empty, typing, results, no-results, search+filter, dismissed
- [ ] Write widget tests for idle→active, results rendering, highlight spans, and dismiss→month-filter restore

### References

- `6.7 Search Overlay` (`docs/02-technical/ui-spec.md`)
- `6.7.1 Components` (`docs/02-technical/ui-spec.md`)
- `6.7.2 Search Ranking Display Order` (`docs/02-technical/ui-spec.md`)
- `6.7.3 States` (`docs/02-technical/ui-spec.md`)
- `7.8.1 Search Entry States` (`docs/02-technical/ux-flows.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)

---

## T-161 — Implement `FilterState` and `FilterNotifier`

**Parent Epic:** E-8
**Parent Story:** S-59

### Todo

- [ ] Create `FilterState` Freezed entity: fields for type set, category IDs, subcategory IDs, account IDs, date range, amount min/max, boolean toggles, sort field + direction
- [ ] Create `FilterNotifier` as `@riverpod Notifier<FilterState>` in `lib/features/home/presentation/notifiers/filter_notifier.dart`
- [ ] Implement `toggleType()`, `setCategories()`, `setAccounts()`, `setDateRange()`, `setAmountRange()`, `toggleBoolean()`, `setSortField()`, `reset()` methods
- [ ] Auto-deselect categories belonging to a type when that type is removed
- [ ] Filters are non-persistent: `FilterNotifier` is scoped to the home screen route and disposed on navigation away
- [ ] Write unit tests: type removal auto-deselects categories; reset clears all fields; non-persistence verified by scope

### References

- `7.7.2 Filter Criteria` (`docs/02-technical/ux-flows.md`)
- `7.7.3 Category Filter Interaction with Type Filter` (`docs/02-technical/ux-flows.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)

---

## T-162 — Implement Filter Bottom Sheet UI

**Parent Epic:** E-8
**Parent Story:** S-59

### Todo

- [ ] Create `FilterBottomSheet` widget in `lib/features/home/presentation/widgets/filter_bottom_sheet.dart`
- [ ] Use `DraggableScrollableSheet` (min 50%, max 95%); drag handle `Container 32×4 dp`, `outlineVariant`
- [ ] Header row: Text("Filters", `sectionHeading`) + TextButton "Reset" (right-aligned)
- [ ] Implement type `FilterChip` row: Income / Expense / Transfer; multi-select; `accentPastel` selected fill
- [ ] Category and subcategory multi-select pickers (tap to open sub-sheet)
- [ ] Account multi-select `OutlinedTextField`
- [ ] Date range section: preset `FilterChip` row + `DateRangePicker` for "Custom"
- [ ] Amount range: two `OutlinedTextField` (Min / Max), both optional, numeric
- [ ] Boolean `SwitchListTile` rows: Has photo / Has title / Has description / Is recurring / Is voided
- [ ] Sort `SegmentedButton` rows: Date (desc/asc) + Amount (desc/asc)
- [ ] Live match count text + full-width `FilledButton` "Apply"; "Apply" dismisses sheet and pushes state to `FilterNotifier`
- [ ] Write widget test: all inputs bind to `FilterNotifier`; Apply emits correct state; Reset clears all

### References

- `6.6 Filter Bottom Sheet` (`docs/02-technical/ui-spec.md`)
- `6.6.1 Components` (`docs/02-technical/ui-spec.md`)
- `6.6.3 States` (`docs/02-technical/ui-spec.md`)
- `7.7.2 Filter Criteria` (`docs/02-technical/ux-flows.md`)
- `7.7.4 Sort Controls (within filter sheet)` (`docs/02-technical/ux-flows.md`)

---

## T-163 — Implement Active Filter Chip Strip

**Parent Epic:** E-8
**Parent Story:** S-59

### Todo

- [ ] Create `ActiveFilterChipStrip` widget in `lib/features/home/presentation/widgets/active_filter_chip_strip.dart`
- [ ] Render horizontally scrollable `Row` of `InputChip` widgets; one chip per active filter criterion; `accentPastel` fill
- [ ] Each chip label summarises the criterion (e.g., "Type: Income", "Account: Savings"); trailing `Icons.close`
- [ ] Tapping the close icon on a chip calls the appropriate `FilterNotifier` method to remove that criterion
- [ ] "Clear all" `InputChip` (`errorContainer / onErrorContainer`): removes all filters; chip strip hidden after
- [ ] Strip hidden when no active filters; appears above transaction list when ≥ 1 active filter
- [ ] 0-results: empty-state text "No transactions match your filters." + `FilledButton` "Clear filters"
- [ ] Write widget test: chip strip visible when filter active; clear-all removes all chips; 0-results empty state shown

### References

- `6.6.2 Active Filter Chip Strip (above list)` (`docs/02-technical/ui-spec.md`)
- `7.7.5 Filter → List Effect` (`docs/02-technical/ux-flows.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)

---

## T-164 — Implement Filtered Transaction List Query

**Parent Epic:** E-8
**Parent Story:** S-59

### Todo

- [ ] Extend `HomeTransactionListNotifier` to accept `FilterState` as a parameter
- [ ] Build SQL predicate from `FilterState`: type IN, category_id IN, account_id IN, date BETWEEN, amount BETWEEN, boolean flags
- [ ] When search is active, combine FTS candidate IDs with filter predicate (intersection)
- [ ] When search is inactive, combine month date bounds with filter predicate
- [ ] Apply sort order from `FilterState.sortField` + `sortDirection` to the query
- [ ] Write unit tests: filter predicate SQL correct for each criterion type; search ∩ filter intersection; sort order applied

### References

- `7.7.5 Filter → List Effect` (`docs/02-technical/ux-flows.md`)
- `7.8.1 Search Entry States` (`docs/02-technical/ux-flows.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)

---

## T-165 — Implement SpeedDial FAB Widget

**Parent Epic:** E-8
**Parent Story:** S-60

### Todo

- [ ] Create `HomeSpeedDial` widget in `lib/features/home/presentation/widgets/home_speed_dial.dart`
- [ ] Collapsed: large `FloatingActionButton`, `Icons.add`, `primaryContainer / onPrimaryContainer`
- [ ] Expanded: scrim `ColoredBox` (color `scrim`, tap to dismiss); 3 `SmallFloatingActionButton` widgets stacked above anchor with text labels right-aligned
- [ ] Expense action: `Icons.arrow_upward`, `errorContainer / onErrorContainer`, label "Expense"
- [ ] Income action: `Icons.arrow_downward`, `secondaryContainer / onSecondaryContainer`, label "Income"
- [ ] Transfer action: `Icons.swap_horiz`, `tertiaryContainer / onTertiaryContainer`, label "Transfer"
- [ ] Tap action navigates to `/transaction/new` with query param `type=expense|income|transfer`
- [ ] Tap scrim or FAB again collapses SpeedDial via local `ValueNotifier<bool>`
- [ ] FAB hidden (`Visibility`) while search is active (watches `SearchNotifier.isActive`)
- [ ] Write widget tests: 3 actions render when expanded; scrim tap collapses; navigation params correct

### References

- `5.1.3 SpeedDial Anatomy (M3)` (`docs/02-technical/ui-spec.md`)
- `6.7 FAB Behaviour` (`docs/02-technical/ux-flows.md`)
- `HOME-03 — Quick-Entry FAB` (`docs/02-technical/feature-dag.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)

---

## T-166 — Implement Drafts Entry Point in SpeedDial

**Parent Epic:** E-8
**Parent Story:** S-60

### Todo

- [ ] Read `back_button_behaviour` setting from `AppSettingsNotifier`
- [ ] When `back_button_behaviour = auto_save_draft`, add a 4th `SmallFAB` action "Drafts" to the SpeedDial expansion (`Icons.drafts_outlined`, `surfaceContainerHigh / onSurface`)
- [ ] Tap "Drafts" navigates to `/drafts`
- [ ] When `back_button_behaviour != auto_save_draft`, Drafts action is absent from the SpeedDial
- [ ] Write widget test: Drafts action present only when setting is `auto_save_draft`; absent otherwise

### References

- `HOME-03 — Quick-Entry FAB` (`docs/02-technical/feature-dag.md`)
- `6.7 FAB Behaviour` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)

---

## T-167 — Implement `AlertsStrip` Widget Container

**Parent Epic:** E-8
**Parent Story:** S-61

### Todo

- [ ] Create `AlertsStrip` widget in `lib/features/home/presentation/widgets/alerts_strip.dart`
- [ ] Render a `Column` of alert cards; apply display priority: pending confirmations first, then credit card due, then backup reminder
- [ ] Use `outlined` `Card` variant, `elevation=0`, `outline` border for each card
- [ ] If no alerts exist, render an empty `SizedBox` (no visible space)
- [ ] Consume `AlertsState` from `AlertsNotifier`; wrap in `AsyncValueWidget` for loading/error
- [ ] Write widget test: correct priority order when all 3 alert types are present

### References

- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `HOME-04 — Alerts Section` (`docs/02-technical/feature-dag.md`)

---

## T-168 — Implement Pending Recurring Confirmation Alert Cards

**Parent Epic:** E-8
**Parent Story:** S-61

### Todo

- [ ] Query `scheduled_occurrences` where `status = 'pending'` joined to `recurring_templates` where `confirmation_mode = 'remind_and_confirm'`
- [ ] Render one card per pending occurrence: template name, scheduled date, amount, account, category
- [ ] Action buttons: Confirm (`FilledButton`), Edit (`TextButton`, navigates to edit form pre-filled), Dismiss (`TextButton`)
- [ ] On Dismiss: show `AlertDialog` "Skip this occurrence? It will not be posted." → Confirm / Cancel; on Confirm update `scheduled_occurrences.status = 'skipped'`
- [ ] On Confirm: post the occurrence via `ConfirmOccurrenceUseCase`
- [ ] If occurrence count > 3: show 3 cards + `TextButton` "View all" that navigates to Pending Confirmations screen
- [ ] Write unit tests: query returns correct pending rows; dismiss updates status to skipped; confirm posts occurrence

### References

- `HOME-04 — Alerts Section` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## T-169 — Implement Credit Card Payment Due Alert Cards

**Parent Epic:** E-8
**Parent Story:** S-61

### Todo

- [ ] Query `accounts` where `category = 'credit'` and billing due date is within the reminder window
- [ ] Render one card per qualifying account: card name, amount due (current balance), due date
- [ ] Action button: "Open payment entry" (`TextButton`) navigates to `/transaction/new?type=expense&account=:id` pre-populated
- [ ] Card clears from the strip when the due date passes (date comparison at render time) or when a payment transaction is posted to the account
- [ ] Write unit tests: card renders for accounts within reminder window; absent for accounts outside window; clears after payment posted

### References

- `HOME-04 — Alerts Section` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)

---

## T-170 — Implement Backup Reminder Alert Card and Trigger Logic

**Parent Epic:** E-8
**Parent Story:** S-62

### Todo

- [ ] Create `BackupReminderChecker` service in `lib/features/home/domain/services/backup_reminder_checker.dart`
- [ ] Read `onboarding_complete` timestamp and compute elapsed days; read transaction count from `transactions` table (non-deleted, non-voided)
- [ ] Return `shouldShow = true` when: `(today - onboarding_complete_date) >= 30 days` OR `transactionCount >= 50`
- [ ] Skip check (return `shouldShow = false`) when `backup_reminder_shown = 1` in `app_settings`
- [ ] Render backup reminder alert card in `AlertsStrip` (lowest priority) when `shouldShow = true`
- [ ] Card action: tap navigates to `/settings/backup`; if route returns `RouteNotFoundError`, show a `SnackBar` "Backup not yet available"
- [ ] On dismiss: call `AppSettingsRepository.set('backup_reminder_shown', '1')`; card never shown again
- [ ] Write unit tests: both trigger conditions independently produce `shouldShow = true`; flag=1 skips; flag write on dismiss

### References

- `HOME-05 — Backup Reminder Alert` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## T-171 — Implement `GetCatchUpBannerUseCase` and Catch-Up Banner Widget

**Parent Epic:** E-8
**Parent Story:** S-63

### Todo

- [ ] Create `GetCatchUpBannerUseCase` in `lib/features/home/domain/use_cases/get_catch_up_banner_use_case.dart`
- [ ] Query `scheduled_occurrences` for rows auto-posted at the current app launch session (e.g., rows with `status = 'auto_posted'` and `auto_post_timestamp` within the current session window)
- [ ] Return `Future<Result<List<RecurringTemplate>>>` with the list of templates whose occurrences were auto-posted
- [ ] Create `CatchUpBanner` widget in `lib/features/home/presentation/widgets/catch_up_banner.dart`
- [ ] Render `FilledCard` (`surfaceContainerHigh`, `bodySmall`): "[N] recurring transactions were auto-posted while you were away."
- [ ] "View details" `TextButton` applies a filter via `FilterNotifier` scoping the list to the auto-posted transaction IDs
- [ ] Banner absent when use case returns empty list
- [ ] Write unit test: use case returns correct count; widget renders with N; "View details" calls `FilterNotifier` with correct IDs

### References

- `2.10.1 Use Cases` (`docs/02-technical/api-contracts.md`)
- `6.6 Recurring Catch-Up Banner` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)

---

## T-172 — AppSettings DAO + IAppSettingsRepository implementation

**Parent Epic:** E-9
**Parent Story:** S-64

### Todo

- [ ] Create `AppSettingsDao` in Drift: `watch()` returning `Stream<AppSettings>` and `upsert(patch)` method
- [ ] Implement `AppSettingsRepositoryImpl` satisfying `IAppSettingsRepository`; wrap DAO calls with `Result` type
- [ ] Seed default values for all `app_settings` keys on first launch (insert row with defaults if table is empty); call from app startup before first paint
- [ ] Write unit tests for default seeding, watch stream emission on update, and upsert idempotency

### References

- `2.9.1 IAppSettingsRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## T-173 — AppSettingsNotifier + Riverpod provider wiring

**Parent Epic:** E-9
**Parent Story:** S-64

### Todo

- [ ] Implement `AppSettingsNotifier` as an `AsyncNotifier<AppSettings>` watching `IAppSettingsRepository.watch()`
- [ ] Register provider in the Riverpod DI graph; ensure it is accessible from all settings screens and from the theme layer (INFRA-5)
- [ ] Expose an `update(patch)` method on the notifier that calls `IAppSettingsRepository.update(patch)` and propagates result errors
- [ ] Write unit tests for notifier initial load, update propagation, and error state

### References

- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.9.1 IAppSettingsRepository` (`docs/02-technical/api-contracts.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## T-174 — Settings Hub screen widget

**Parent Epic:** E-9
**Parent Story:** S-64

### Todo

- [ ] Build `SettingsHubScreen` at route `/settings`; render 15 section entries in spec order as a sectioned `ListView`
- [ ] Each row is a `ListTile` with title, optional subtitle, and trailing chevron; tap triggers GoRouter push to the correct route
- [ ] Handle `AppSettingsNotifier` loading and error states gracefully (no blank screen)
- [ ] Write widget test asserting all 15 rows render and navigate correctly
- [ ] Write golden test for hub loaded state

### References

- `9.1 Screen: Settings Hub` (`docs/02-technical/ux-flows.md`)
- `9.1 Settings Hub` (`docs/02-technical/ui-spec.md`)
- `9.1.2 Settings Hub Sections (display order)` (`docs/02-technical/ux-flows.md`)
- `9.1.2 Section Groups (display order)` (`docs/02-technical/ui-spec.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## T-175 — Appearance settings screen widget

**Parent Epic:** E-9
**Parent Story:** S-64

### Todo

- [ ] Build `AppearanceSettingsScreen` at route `/settings/appearance`
- [ ] Theme segmented button (Light / Dark / System default); writes `app_settings.theme` via `AppSettingsNotifier.update(patch)`
- [ ] Color scheme segmented button (Dynamic / Custom / Catppuccin); writes `app_settings.color_scheme_mode`
- [ ] Seed color picker row (visible only when color scheme = Custom); writes `app_settings.color_seed`
- [ ] Animations toggle switch; writes `app_settings.animations_enabled`
- [ ] "Preview color scheme" tappable row navigates to `/settings/appearance/preview`
- [ ] Changes apply immediately via INFRA-5 theme rebuild (reactive to `AppSettingsNotifier` stream)
- [ ] Write widget tests for each control save path; golden test for loaded state

### References

- `9.2 Screen: Appearance Settings` (`docs/02-technical/ux-flows.md`)
- `9.2 Appearance Settings` (`docs/02-technical/ui-spec.md`)
- `9.2.2 Settings` (`docs/02-technical/ux-flows.md`)
- `9.2.1 Components` (`docs/02-technical/ui-spec.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-176 — Dynamic color OEM fallback + Color Scheme Preview screen

**Parent Epic:** E-9
**Parent Story:** S-64

### Todo

- [ ] Wrap theme root with `DynamicColorBuilder`; when builder returns null, auto-switch `color_scheme_mode` to `custom` and show inline note "Dynamic color not available on this device" in Appearance screen
- [ ] Build `ColorSchemePreviewScreen` at route `/settings/appearance/preview`; render M3 token swatches (primary, secondary, tertiary, surface, on-surface) labelled with role names; derived from active mode
- [ ] Write widget test for the fallback inline note display
- [ ] Write golden test for the preview screen swatch grid

### References

- `9.2.3 Dynamic Color Unavailable` (`docs/02-technical/ux-flows.md`)
- `9.2.4 Color Scheme Preview Screen` (`docs/02-technical/ux-flows.md`)
- `9.2.3 Color Scheme Preview Sub-screen` (`docs/02-technical/ui-spec.md`)
- `TC-048: Minimum API level inconsistency with dynamic color` (`docs/01-product/technical-clarifications.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)

---

## T-177 — Locale & Format settings screen widget

**Parent Epic:** E-9
**Parent Story:** S-65

### Todo

- [ ] Build `LocaleFormatSettingsScreen` at route `/settings/locale`
- [ ] Home currency picker row: opens full-screen currency picker (backed by bundled ISO 4217 list from CURR-01); on select, writes `app_settings.home_currency`
- [ ] Decimal separator selector (period / comma); thousands grouping selector (none / western / Indian)
- [ ] Currency symbol placement (before/after amount) and spacing (space/no-space) controls
- [ ] Week start day selector; time format selector (12h/24h); percentage decimal precision selector
- [ ] All saves via `AppSettingsNotifier.update(patch)`; amount re-render happens immediately via reactive rebuild
- [ ] Write widget tests for each field save path

### References

- `9.3 Screen: Locale & Format Settings` (`docs/02-technical/ux-flows.md`)
- `9.3 Locale & Format Settings` (`docs/02-technical/ui-spec.md`)
- `9.3.2 Settings` (`docs/02-technical/ux-flows.md`)
- `9.3.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `SET-02 — Locale + Format Settings` (`docs/02-technical/feature-dag.md`)

---

## T-178 — Home currency change semantics + display formatting pipeline

**Parent Epic:** E-9
**Parent Story:** S-65

### Todo

- [ ] Implement the amount formatting utility that reads `app_settings` locale keys (decimal separator, grouping, symbol placement/spacing) and formats a `Money` value; used by all amount display widgets
- [ ] Verify that changing `home_currency` writes only `app_settings.home_currency` and does not rewrite any `transactions.exchange_rate_to_home` rows
- [ ] Unit tests: Indian grouping produces correct 2-2-3 output for amounts >= 1,00,000; western grouping produces correct 3-group output; symbol placement/spacing variants all produce correct strings
- [ ] Unit test: home currency change does not trigger any DB migration or bulk update

### References

- `SET-02 — Locale + Format Settings` (`docs/02-technical/feature-dag.md`)
- `TC-029: How does the app handle home currency changes after transactions exist?` (`docs/01-product/technical-clarifications.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `12.3 Money Value Object` (`docs/02-technical/data-model.md`)

---

## T-179 — Transaction Entry settings screen widget

**Parent Epic:** E-9
**Parent Story:** S-66

### Todo

- [ ] Build `TransactionEntrySettingsScreen` at route `/settings/transaction-entry`
- [ ] Description max length integer field; validates > 0; writes `app_settings.description_max_length`
- [ ] Back-button behaviour segmented control: Ask / Auto-save draft / Discard immediately; writes `app_settings.back_button_behaviour`
- [ ] Render draft lifecycle info card (5-slot FIFO, no expiry) as an inline informational card when auto-save is selected
- [ ] All saves via `AppSettingsNotifier.update(patch)`
- [ ] Write widget tests for each field and the info card visibility logic (visible only when auto-save selected)

### References

- `9.4 Screen: Transaction Entry Settings` (`docs/02-technical/ux-flows.md`)
- `9.4 Transaction Entry Settings` (`docs/02-technical/ui-spec.md`)
- `9.4.3 Draft Lifecycle Note (displayed as info card in screen)` (`docs/02-technical/ux-flows.md`)
- `9.4.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-03 — Transaction Entry Settings` (`docs/02-technical/feature-dag.md`)

---

## T-180 — IDraftRepository implementation + FIFO enforcement

**Parent Epic:** E-9
**Parent Story:** S-66

### Todo

- [ ] Implement `DraftRepositoryImpl` satisfying `IDraftRepository` (`watchAll`, `upsert`, `delete`); backed by the `drafts` Drift table
- [ ] Implement `DraftListNotifier` as `AsyncNotifier<List<Draft>>` watching `IDraftRepository.watchAll()`
- [ ] Implement FIFO cap logic: before inserting a new draft, if count == 5, delete the oldest (by `created_at` ascending); then insert
- [ ] Show toast "Oldest draft was removed to make room." on eviction
- [ ] `payload_json` must include a `schema_version` field; on load, discard rows where schema version does not match the current app version schema
- [ ] Unit tests: FIFO eviction at cap (count stays <= 5); stale draft detection and discard; toast fires exactly once on eviction

### References

- `2.9.2 IDraftRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `9.2 drafts` (`docs/02-technical/data-model.md`)
- `TC-005: "Auto-save as draft" back button behaviour — draft lifecycle` (`docs/01-product/technical-clarifications.md`)
- `SET-03 — Transaction Entry Settings` (`docs/02-technical/feature-dag.md`)

---

## T-181 — Warnings & Limits screen: per-account thresholds

**Parent Epic:** E-9
**Parent Story:** S-67

### Todo

- [ ] Build the Per-Account Limits sub-screen at `/settings/warnings/accounts`
- [ ] Load all accounts via `IAccountRepository.watchAll()`; render as a list with an inline threshold amount field per row
- [ ] Field label shows the account's native currency symbol
- [ ] On change, call `IAccountRepository.update(id, patch)` writing `large_txn_threshold`
- [ ] Entry point screen (`/settings/warnings`) renders two navigation rows: "Per-Account Limits" and "Per-Category Limits"
- [ ] Write widget tests for list render, field save, and multi-currency label correctness

### References

- `9.5 Screen: Warnings & Limits` (`docs/02-technical/ux-flows.md`)
- `9.5.2 Per-Account Limits Sub-screen` (`docs/02-technical/ux-flows.md`)
- `9.5.2 Per-Account Limits Sub-screen` (`docs/02-technical/ui-spec.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `2.1.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `SET-04 — Warnings + Limits Settings` (`docs/02-technical/feature-dag.md`)
- `TC-047: Per-account and per-category large transaction thresholds — currency handling` (`docs/01-product/technical-clarifications.md`)

---

## T-182 — Warnings & Limits screen: per-category thresholds

**Parent Epic:** E-9
**Parent Story:** S-67

### Todo

- [ ] Build the Per-Category Limits sub-screen at `/settings/warnings/categories`
- [ ] Load all expense/income categories (excluding BAI/BAE system categories); render with inline threshold field per row; label shows home currency symbol
- [ ] On change, call `ICategoryRepository.update(id, patch)` writing `large_txn_threshold`
- [ ] Write widget tests for list render, BAI/BAE exclusion, and field save

### References

- `9.5.3 Per-Category Limits Sub-screen` (`docs/02-technical/ux-flows.md`)
- `9.5.3 Per-Category Limits Sub-screen` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `SET-04 — Warnings + Limits Settings` (`docs/02-technical/feature-dag.md`)
- `TC-047: Per-account and per-category large transaction thresholds — currency handling` (`docs/01-product/technical-clarifications.md`)

---

## T-183 — Profile settings screen widget

**Parent Epic:** E-9
**Parent Story:** S-68

### Todo

- [ ] Build `ProfileSettingsScreen` at route `/settings/profile`
- [ ] Single `TextField` for display name; pre-filled from `AppSettingsNotifier`; optional (allows empty string)
- [ ] On submit/blur, call `AppSettingsNotifier.update(patch)` writing `display_name`
- [ ] Home screen greeting widget rebuilds reactively from `AppSettingsNotifier` stream: shows "Hi, [name]!" when non-empty, "Hi!" when empty
- [ ] Widget tests: non-empty name shows correct greeting; clearing field shows "Hi!" greeting

### References

- `9.6 Screen: Profile Settings` (`docs/02-technical/ux-flows.md`)
- `9.6 Profile Settings` (`docs/02-technical/ui-spec.md`)
- `9.6.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-05 — Profile Settings (Display Name)` (`docs/02-technical/feature-dag.md`)

---

## T-184 — Security settings screen + lock timeout

**Parent Epic:** E-9
**Parent Story:** S-69

### Todo

- [ ] Build `SecuritySettingsScreen` at route `/settings/security`
- [ ] Lock timeout selector (options: 1 min / 5 min / 15 min / never); writes `app_settings.lock_timeout_seconds`
- [ ] "Set PIN" / "Change PIN" row navigates to PIN setup screen (mode=set or mode=change)
- [ ] App lifecycle listener: on background → foreground, check elapsed time vs. `lock_timeout_seconds`; if exceeded, show lock overlay gating `account_details` sensitive field display
- [ ] GoRouter guard: applies ONLY to the `account_details` sensitive fields route; no other routes redirected
- [ ] Write widget tests for timeout selector save and screen navigation

### References

- `9.7 Security Settings` (`docs/02-technical/ui-spec.md`)
- `9.7.1 Components` (`docs/02-technical/ui-spec.md`)
- `5.1 App Lock Overlay` (`docs/02-technical/ux-flows.md`)
- `5.1.2 Lock Conditions` (`docs/02-technical/ux-flows.md`)
- `1.6.12 Security Lock Scope — Sensitive Fields Only` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## T-185 — PIN setup, change, and entry screens

**Parent Epic:** E-9
**Parent Story:** S-69

### Todo

- [ ] Build `PinSetupScreen` (mode=set: enter + confirm PIN; mode=change: verify current PIN, then enter + confirm new PIN); store encrypted PIN via `flutter_secure_storage`
- [ ] Build `PinEntryOverlay` / `PinEntryScreen`: numeric keypad, attempt counter displayed after first failure, "Forgot PIN" link
- [ ] Implement `local_auth` Keyguard call as the primary authentication attempt; fall back to in-app PIN when `local_auth` returns `notAvailable` or `notEnrolled`
- [ ] After 15 consecutive PIN failures: wipe only encrypted rows in `account_details`; reset attempt counter; show confirmation snackbar
- [ ] Write widget tests for PIN setup (set and change modes), PIN entry states, and lockout wipe behaviour

### References

- `5.2 PIN Setup Screen` (`docs/02-technical/ux-flows.md`)
- `5.3 PIN Entry Screen` (`docs/02-technical/ux-flows.md`)
- `5.7 Flow — PIN Setup: First Time` (`docs/02-technical/ux-flows.md`)
- `5.8 Flow — PIN Setup: Change PIN` (`docs/02-technical/ux-flows.md`)
- `5.9 Flow — PIN Reset: Forgot PIN` (`docs/02-technical/ux-flows.md`)
- `4.3 PIN Setup Screen` (`docs/02-technical/ui-spec.md`)
- `4.4 PIN Entry Screen / Overlay` (`docs/02-technical/ui-spec.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## T-186 — Resolve OQ-SDS-SC-001: secure storage backup exclusion

**Parent Epic:** E-9
**Parent Story:** S-69

### Todo

- [ ] Investigate `flutter_secure_storage` behaviour under Android `BackupAgent` on API 31+
- [ ] Add `android:allowBackup="false"` or configure `excludeFromEncryptedBackup` rules in `AndroidManifest.xml` / backup rules XML to exclude `flutter_secure_storage` data from device backups
- [ ] Verify the exclusion is effective: install app, set PIN, trigger backup, restore on a fresh device — PIN must not be present after restore
- [ ] Document resolution in the SDS open questions section (OQ-SDS-SC-001 status set to resolved)

### Notes

- Blocking requirement before S-69 (SET-06) can ship

### References

- `1.6.12 Security Lock Scope — Sensitive Fields Only` (`docs/02-technical/sds.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## T-187 — Backup screen widget + SAF file picker integration

**Parent Epic:** E-9
**Parent Story:** S-70

### Todo

- [ ] Build `BackupDataScreen` at route `/settings/backup`; show last backup timestamp (from `app_settings.last_backup_at`); "Backup Now" button
- [ ] On tap: launch Android SAF directory picker (`ACTION_OPEN_DOCUMENT_TREE`); on selection, start export service
- [ ] Fall back to `Downloads` directory if SAF returns null or fails
- [ ] Show in-progress indicator during export; show success snackbar with file path on completion; show error snackbar on failure
- [ ] Write widget tests for loaded state (with and without previous backup), in-progress state, and success/error states

### References

- `SET-07 — Data Backup (Export ZIP)` (`docs/02-technical/feature-dag.md`)
- `2.17 Backup Format` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-188 — ZIP export engine (manifest + entity serialisation + photos)

**Parent Epic:** E-9
**Parent Story:** S-70

### Todo

- [ ] Implement `BackupService` running in a background isolate: opens a Drift read-only transaction, serialises all non-deleted entities to `variance_export.json`, collects attached photo paths from `attachments` table
- [ ] Build `manifest.json`: `backup_format_version: 1`, `app_version` (from package info), `created_at` ISO 8601 UTC, `schema_version` (from `app_settings.schema_backup_version`)
- [ ] Assemble ZIP: add `manifest.json`, `variance_export.json`, and each resolved photo file; skip files that do not exist on disk (log warning, continue)
- [ ] After successful write, call `AppSettingsNotifier.update({last_backup_at: now_unix_epoch})`
- [ ] Unit tests: manifest JSON structure is valid; soft-deleted entities are absent from export; missing photo files are skipped without exception; `last_backup_at` is written on success

### References

- `2.17.1 Decision — TC-054: Versioned ZIP Archive with Manifest` (`docs/02-technical/sds.md`)
- `2.17 Backup Format` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `11.2 Soft Delete Policy` (`docs/02-technical/data-model.md`)
- `SET-07 — Data Backup (Export ZIP)` (`docs/02-technical/feature-dag.md`)

---

## T-189 — Account Management screen widget

**Parent Epic:** E-9
**Parent Story:** S-71

### Todo

- [ ] Build `AccountManagementScreen` at route `/settings/accounts`
- [ ] Load accounts via `IAccountRepository.watchAll()` (including soft-deleted); group active by account category in fixed type order, alphabetical within group; section headers when > 1 group
- [ ] Render each row: account name + account category badge + currency symbol if multi-currency
- [ ] Soft-deleted accounts in a separate section with visual indicator and "Reinstate" action; tap "Reinstate" calls `IAccountRepository.reinstate(id)`
- [ ] Tap active row → navigate to account detail (`/accounts/:id`); FAB or top-right button → navigate to create account (`/accounts/new`)
- [ ] Write widget tests: loaded state (active + soft-deleted), empty state, grouping order, reinstate action

### References

- `SET-08 — Account Management Screen` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `2.1.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `TC-057: Multiple accounts per account category — display and disambiguation` (`docs/01-product/technical-clarifications.md`)

---

## T-190 — Category Management screen widget

**Parent Epic:** E-9
**Parent Story:** S-72

### Todo

- [ ] Build `CategoryManagementScreen` at route `/settings/categories`
- [ ] Render two-level expandable tree: parent categories with expand/collapse chevron; child categories indented below parent
- [ ] `+` button at parent level opens create parent category form; `+` at child level opens create child category form within that parent
- [ ] Exclude BAI/BAE system categories from the list (filter by `is_system = true` or equivalent flag)
- [ ] Long-press or swipe on any row opens contextual menu: rename, reorder, delete
- [ ] Write widget tests: tree render, BAI/BAE exclusion, empty parent (no children), `+` button navigation

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.8.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.8.3 Behaviour Notes` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `SET-09 — Category Management Screen` (`docs/02-technical/feature-dag.md`)

---

## T-191 — Category icon picker widget

**Parent Epic:** E-9
**Parent Story:** S-72

### Todo

- [ ] Build `CategoryIconPickerSheet` bottom sheet: searchable grid of the curated ~250-icon `material_symbols_icons` subset
- [ ] Define the curated icon list as a `const List<IconData>` in a dedicated constants file; use placeholder set while curation is finalised (TC-014)
- [ ] On icon tap, return selected `IconData` to caller; render selected icon in the category create/edit form
- [ ] Search field filters the grid by icon name substring
- [ ] Write widget tests for grid render, search filtering, and selection callback

### References

- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.9.1 Components` (`docs/02-technical/ui-spec.md`)
- `TC-014: "Curated subset" of material_symbols_icons — who defines it and when` (`docs/01-product/technical-clarifications.md`)
- `SET-09 — Category Management Screen` (`docs/02-technical/feature-dag.md`)

---

## T-192 — Recurring & Installment Management screen: recurring templates section

**Parent Epic:** E-9
**Parent Story:** S-73

### Todo

- [ ] Build `RecurringManagementScreen` at route `/settings/recurring`
- [ ] Load recurring templates via `IRecurringTemplateRepository.watchAll()`; group by state: active, paused, archived (soft-deleted)
- [ ] Render each row: template name, recurrence summary (e.g. "Monthly on the 1st"), posting behaviour badge (auto-post / remind)
- [ ] Contextual menu or swipe actions: pause (active→paused), unpause (paused→active), archive (non-archived→soft-deleted); archived section shows restore action only
- [ ] Tap row → navigate to template detail/edit screen
- [ ] Write widget tests: loaded state (all three groups), empty state, contextual action triggers

### References

- `SET-10 — Recurring + Installment Management Screen` (`docs/02-technical/feature-dag.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)

---

## T-193 — Recurring Management screen: installment plans section

**Parent Epic:** E-9
**Parent Story:** S-73

### Todo

- [ ] Add installment plans section to `RecurringManagementScreen` (separate section below recurring templates)
- [ ] Load plans via `IInstallmentPlanRepository.watchAll()`; group by state: active, completed, archived
- [ ] Render each row: plan description, instalment count (paid / total), next due date
- [ ] Tap row → navigate to installment plan detail screen
- [ ] Write widget tests for plans section render, empty section state, and navigation

### Notes

- SOFT dependency on INST-01; this task ships only after INST-01 is available

### References

- `SET-10 — Recurring + Installment Management Screen` (`docs/02-technical/feature-dag.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)

---

## T-194 — AppSettingsDao: read and write app_settings rows

**Parent Epic:** E-10
**Parent Story:** S-75

### Todo

- [ ] Create `AppSettingsDao` using Drift `DatabaseAccessor` annotation targeting the `app_settings` table
- [ ] Implement `Future<String?> getValue(String key)` — returns `value` column for given key or `null` if absent
- [ ] Implement `Future<void> setValue(String key, String value)` — upserts row (INSERT OR REPLACE) and sets `updated_at` to current epoch
- [ ] Implement `Future<bool> getOnboardingComplete()` — calls `getValue('onboarding_complete')`, returns `true` if value is `'1'`
- [ ] Implement `Future<void> setOnboardingComplete()` — calls `setValue('onboarding_complete', '1')`
- [ ] Implement `Future<String> getHomeCurrency()` — calls `getValue('home_currency')`, falls back to `'INR'`
- [ ] Implement `Future<void> setHomeCurrency(String code)` — calls `setValue('home_currency', code)`
- [ ] Write unit tests using `NativeDatabase.memory()` for all DAO methods

### References

- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.3 Database and Persistence` (`docs/02-technical/sds.md`)

---

## T-195 — AppSettingsRepository and AppSettingsNotifier (Riverpod)

**Parent Epic:** E-10
**Parent Story:** S-75

### Todo

- [ ] Create `AppSettingsRepository` interface with methods: `getOnboardingComplete`, `setOnboardingComplete`, `getHomeCurrency`, `setHomeCurrency`
- [ ] Create `AppSettingsRepositoryImpl` backed by `AppSettingsDao`
- [ ] Declare `appSettingsRepositoryProvider` as `keepAlive` Riverpod provider returning `AppSettingsRepository`
- [ ] Create `AppSettingsNotifier` (`@riverpod Notifier<AppSettingsState>`) that holds a cached `AppSettingsState` (struct with `onboardingComplete: bool`, `homeCurrency: String`)
- [ ] `AppSettingsNotifier.build()` reads both values from repository synchronously at initialisation (use `ref.read` on a `FutureProvider` that pre-loads at app startup, or initialise via `AsyncNotifier` pre-warm)
- [ ] Expose `setOnboardingComplete()` and `setHomeCurrency(String)` mutators that update the cache and write through to repository
- [ ] Write unit tests for notifier state transitions using fake repository

### References

- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)

---

## T-196 — GoRouter redirect guard wired to AppSettingsNotifier

**Parent Epic:** E-10
**Parent Story:** S-75

### Todo

- [ ] In the GoRouter configuration, add a top-level `redirect` callback
- [ ] Callback reads `appSettingsNotifierProvider` synchronously via `ref.read`; if `state.onboardingComplete == false`, return `'/onboarding'`; otherwise return `null` (allow through)
- [ ] Ensure `AppSettingsNotifier` is pre-warmed before `MaterialApp.router` is built — wrap app root in an `AsyncValue` load that awaits the notifier's initial state before constructing the router
- [ ] Register `/onboarding` as a non-shell modal `GoRoute` (outside `StatefulShellRoute`)
- [ ] Write widget tests: with `onboardingComplete = false`, verify navigation to `/`, `/accounts`, `/settings` all redirect to `/onboarding`
- [ ] Write widget tests: with `onboardingComplete = true`, verify navigation to `/` succeeds without redirect

### References

- `2.4.3 Navigation Rules` (`docs/02-technical/sds.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-197 — OnboardingWizardScreen scaffold and PageController

**Parent Epic:** E-10
**Parent Story:** S-74

### Todo

- [ ] Create `OnboardingWizardScreen` as a `StatefulWidget` owning a `PageController` (initialPage: 0, physics: `NeverScrollableScrollPhysics` — navigation is CTA-driven only)
- [ ] Scaffold: `Scaffold` with no `AppBar`, no `NavigationBar`; body is a `Column` containing `Expanded(child: PageView(...))` + chrome bar at bottom
- [ ] Chrome bar: `LinearProgressIndicator` (height 4 dp, `primary` fill, `surfaceContainerHighest` track) above full-width `FilledButton`
- [ ] Top-right: `Stack` or `AppBar`-less header row with `Skip TextButton` (`primary`); hidden (opacity 0 / `Visibility`) on pages 0 and 4
- [ ] CTA label map: index 0 → "Get started", 1 → "Confirm", 2 → "Create account", 3 → "Done", 4 → "Start tracking"
- [ ] `PageView` children: placeholder widgets for each step (to be replaced by step widgets from subsequent tasks)
- [ ] Progress value: `(currentPage + 1) / 5`

### References

- `3.1 Screen` (`docs/02-technical/ui-spec.md`)
- `3.2 Wizard Chrome (persistent across all steps)` (`docs/02-technical/ui-spec.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)

---

## T-198 — Step 1 Welcome widget

**Parent Epic:** E-10
**Parent Story:** S-76

### Todo

- [ ] Create `OnboardingStep1Welcome` as a `StatelessWidget`
- [ ] Layout: centered `Column` — app logo/wordmark icon (`primary`), app name text (`VarianceTypography.displayLargeAmount`, 36 sp, `onSurface`), tagline (`VarianceTypography.bodyLarge`, 16 sp, `onSurfaceVariant`), 3 value prop bullets (`VarianceTypography.bodyMedium`, 14 sp, `onSurfaceVariant`) with leading check icons
- [ ] Widget accepts no callbacks — chrome CTA is owned by `OnboardingWizardScreen`
- [ ] Write golden test for loaded state

### References

- `3.3 Step 1 — Welcome` (`docs/02-technical/ui-spec.md`)
- `3.3.1 Components` (`docs/02-technical/ui-spec.md`)

---

## T-199 — Locale-to-currency detection service

**Parent Epic:** E-10
**Parent Story:** S-77

### Todo

- [ ] Create `LocaleCurrencyDetector` service in the domain layer
- [ ] Implement `String detect()` — reads `Platform.localeName` (or `Localizations.localeOf`), maps language/country tag to ISO 4217 code using a hardcoded lookup map (covering all ~180 bundled currencies by country)
- [ ] Return `'INR'` as fallback if locale is null, unrecognised, or throws
- [ ] Service is a pure synchronous function — no async, no network
- [ ] Write unit tests for: known locale → correct code, unrecognised locale → INR, null locale → INR

### References

- `2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset` (`docs/02-technical/sds.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)

---

## T-200 — Step 2 Currency Selection widget

**Parent Epic:** E-10
**Parent Story:** S-77

### Todo

- [ ] Create `OnboardingStep2Currency` as a `ConsumerStatefulWidget`
- [ ] On mount: call `LocaleCurrencyDetector.detect()` asynchronously (wrap in `FutureBuilder` or `AsyncNotifier`); during detection show `CircularProgressIndicator` (20 dp) inside field and disable CTA
- [ ] Once resolved: pre-populate detected code and display row ("We think your currency is {symbol} {code}")
- [ ] `OutlinedTextField` with search: filters a `ListView.builder` of all currencies from `currencyRepositoryProvider` by code and name substring (case-insensitive)
- [ ] Tapping a currency row selects it (updates local state); confirmation row updates
- [ ] "Confirm": calls `appSettingsNotifierProvider.setHomeCurrency(selectedCode)` then invokes `onNext()` callback
- [ ] "Skip" (wired from chrome): calls `appSettingsNotifierProvider.setHomeCurrency(detectedCode)` then invokes `onNext()`
- [ ] Write widget tests for loading, nominal, and fallback states

### References

- `3.4 Step 2 — Currency Selection` (`docs/02-technical/ui-spec.md`)
- `3.4.1 Components` (`docs/02-technical/ui-spec.md`)
- `3.4.2 States` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)

---

## T-201 — Step 3 Account Creation widget

**Parent Epic:** E-10
**Parent Story:** S-78

### Todo

- [ ] Create `OnboardingStep3Account` as a `ConsumerStatefulWidget`
- [ ] Form fields: account name `OutlinedTextField` (required, `error` role on empty submit), account category `ExposedDropdownMenu` (8 fixed values: cash, bank_account, credit_card, debit_card, top_up_wallet, loan, investment, other), initial balance `OutlinedTextField` (optional, numeric, default 0, `numericMedium` 16 sp)
- [ ] NO currency field — currency is read from `appSettingsNotifierProvider.state.homeCurrency` at submit time
- [ ] CTA enabled only when name is non-empty and category is selected
- [ ] On CTA tap: call `CreateAccountUseCase` with `{name, account_category, initial_balance_minor, currency_code: homeCurrency}`; on success invoke `onNext()`; on error show inline snackbar
- [ ] "Skip" (wired from chrome): invoke `onNext()` with no DB write
- [ ] Write widget tests for: valid submit, invalid submit (errors shown), skip (no DB write)

### References

- `3.5 Step 3 — Create First Account` (`docs/02-technical/ui-spec.md`)
- `3.5.1 Components` (`docs/02-technical/ui-spec.md`)
- `3.5.2 States` (`docs/02-technical/ui-spec.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-202 — Step 4 Quick Highlights widget

**Parent Epic:** E-10
**Parent Story:** S-79

### Todo

- [ ] Create `OnboardingStep4Highlights` as a `StatefulWidget` with an internal `PageController` for the card `PageView`
- [ ] Define 2–3 highlight card data objects (const list): each has an icon (`IconData`), headline string, and body string
- [ ] Render `PageView` of `Card` widgets (`surfaceContainerLow` fill) with M3 icon (40 dp, `primary`), headline (`sectionHeading`, 20 sp, `onSurface`), body (`bodyMedium`, 14 sp, `onSurfaceVariant`)
- [ ] Dot indicator row below cards: filled circle for active page (`primary`), outline circle for inactive (`outlineVariant`)
- [ ] "Skip" and "Done" (from chrome) both invoke `onNext()` — no side effect
- [ ] Write golden test for Step 4

### References

- `3.6 Step 4 — Quick Highlights` (`docs/02-technical/ui-spec.md`)
- `3.6.1 Components` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)

---

## T-203 — Step 5 Done widget and onboarding_complete write

**Parent Epic:** E-10
**Parent Story:** S-80

### Todo

- [ ] Create `OnboardingStep5Done` as a `ConsumerStatefulWidget`
- [ ] On mount: start a `Timer(Duration(milliseconds: 1500), _complete)` where `_complete` writes `onboarding_complete = 1` and calls `context.go('/')`
- [ ] Cancel timer if CTA is tapped first to avoid double navigation
- [ ] Components: completion illustration widget (abstract geometric using `primary` + `tertiary` theme colors), headline "You're all set!" (`displayLargeAmount`, 36 sp, `onSurface`), sub-copy (`bodyLarge`, 16 sp, `onSurfaceVariant`)
- [ ] CTA "Start tracking": call `appSettingsNotifierProvider.setOnboardingComplete()`, cancel timer, call `context.go('/')`
- [ ] No skip button (hidden by chrome)
- [ ] Write widget test: tapping CTA writes `onboarding_complete = 1` and triggers navigation to `/`

### References

- `3.7 Step 5 — Done` (`docs/02-technical/ui-spec.md`)
- `3.7.1 Components` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)

---

## T-204 — Wire step widgets into OnboardingWizardScreen

**Parent Epic:** E-10
**Parent Story:** S-74

### Todo

- [ ] Replace placeholder `PageView` children in `OnboardingWizardScreen` with: `OnboardingStep1Welcome`, `OnboardingStep2Currency`, `OnboardingStep3Account`, `OnboardingStep4Highlights`, `OnboardingStep5Done`
- [ ] Pass `onNext` callback to each step that requires it (steps 2 and 3); steps 1, 4, and 5 are driven by the chrome CTA or internal logic
- [ ] CTA tap in chrome delegates to current step's `onNext` or advances the `PageController` directly (steps 1, 4, 5 have no conditional logic; steps 2 and 3 validate before advancing)
- [ ] "Skip" tap in chrome: for step 2 → trigger step 2 skip path; for step 3 → trigger step 3 skip path; for step 4 → advance to step 5
- [ ] Verify `LinearProgressIndicator` value updates on each `PageController` page change

### References

- `3. Onboarding & First Launch` (`docs/02-technical/ui-spec.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)

---

## T-205 — Home screen zero-accounts empty state

**Parent Epic:** E-10
**Parent Story:** S-81

### Todo

- [ ] In `HomeScreen`, add a check for empty account list from `accountListProvider`
- [ ] When account list is empty: render empty-state widget with copy "No accounts yet" and a `FilledButton` "Create your first account" that calls `context.push('/accounts/new')`
- [ ] Net worth card: when no accounts exist, render `0` with home currency symbol (read from `appSettingsNotifierProvider.state.homeCurrency`) — no null error
- [ ] Transaction list: when no transactions exist, render empty-state text (no error widget)
- [ ] Write widget test: `HomeScreen` with `accountListProvider` overridden to empty list renders empty state and CTA without throwing

### References

- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)
- `2.1 Empty State CTA Wording Per Screen` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-206 — Integration test: full onboarding happy path

**Parent Epic:** E-10
**Parent Story:** S-82

### Todo

- [ ] Create `integration_test/onboarding_happy_path_test.dart`
- [ ] Scenario: fresh DB → app starts → wizard step 1 visible → tap "Get started" → step 2 visible → tap "Confirm" (INR pre-selected) → step 3 visible → enter account name "Cash" → select category "cash" → tap "Create account" → step 4 visible → tap "Done" → step 5 visible → tap "Start tracking" → home screen visible → account "Cash" appears
- [ ] Assertions: each step heading is visible before advancing; home screen is not `/onboarding`; `onboarding_complete` reads `1` from DAO after test
- [ ] Use `pumpAndSettle` after each navigation; no `sleep` calls

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)

---

## T-207 — Integration test: skip-all onboarding path

**Parent Epic:** E-10
**Parent Story:** S-82

### Todo

- [ ] Create scenario in integration test file: fresh DB → step 1 → "Get started" → step 2 → "Skip" (INR written) → step 3 → "Skip" (no account written) → step 4 → "Skip" → step 5 → "Start tracking" → home screen shows empty-state CTA
- [ ] Assertions: no account rows in DB after test; home screen renders empty-state CTA "Create your first account"; `onboarding_complete` reads `1`
- [ ] Confirm CTA navigates to `/accounts/new` without error

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)
- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)

---

## T-208 — Integration test: returning user bypass

**Parent Epic:** E-10
**Parent Story:** S-82

### Todo

- [ ] Create scenario: DB seeded with `onboarding_complete = 1` → app starts → assert `/onboarding` route is NOT visited → home screen renders directly
- [ ] Use `GoRouter`'s `RouteInformationProvider` or `navigatorKey` to assert current route is `/` on first frame after pump
- [ ] Confirm wizard `PageView` widget is not in the widget tree

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `2.4.3 Navigation Rules` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## T-209 — DebugErrorOverlay widget scaffold

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Create `lib/presentation/debug/debug_error_overlay.dart` with a `DebugErrorOverlay` stateful widget that wraps `child` only when `kDebugMode == true`; in release the widget returns `child` directly with zero overhead
- [ ] Define an internal `_ErrorEntry` model holding: `errorType` (String), `message` (String), `tersedTrace` (String, first 10 frames via `Chain.terse`), `fullTrace` (String, raw), `route` (String?), `useCaseName` (String?), `timestamp` (DateTime)
- [ ] Expose a `static void capture(Object error, StackTrace stack, {String? route, String? useCaseName})` method that appends an `_ErrorEntry` to an internal `ValueNotifier<List<_ErrorEntry>>`; no-op outside `kDebugMode`
- [ ] Add `package:stack_trace` to `pubspec.yaml` dev/dependency block if not already present
- [ ] Confirm the widget compiles and the `kDebugMode` guard eliminates the tree in a release build (run `flutter build apk --release --no-pub` and check for zero compile errors)

### Notes

- `Chain.terse` strips internal Flutter/Dart framework frames; the full raw trace is kept separately for the clipboard payload

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.12.4 Build Flavors` (`docs/02-technical/sds.md`)

---

## T-210 — Flutter framework and async error capture

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] In `main_dev.dart` (or the dev-flavor entry point), after `WidgetsFlutterBinding.ensureInitialized()`, assign `FlutterError.onError` to forward `FlutterErrorDetails` to `DebugErrorOverlay.capture`; preserve any existing handler by chaining
- [ ] Assign `PlatformDispatcher.instance.onError` to forward unhandled async errors and their stack traces to `DebugErrorOverlay.capture`; return `true` to mark the error as handled
- [ ] Both assignments must be conditional on `kDebugMode`; production entry points are not touched
- [ ] Write a widget test that pumps a widget which calls `FlutterError.reportError` with a synthetic `FlutterErrorDetails` and asserts the overlay becomes visible

### Notes

- Do not modify `main.dart` (prod entry point) or `main_staging.dart`; changes are confined to `main_dev.dart`

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.12.4 Build Flavors` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-211 — Riverpod ProviderObserver for domain Failure capture

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Create `lib/presentation/debug/debug_error_observer.dart` implementing `ProviderObserver`; override `didUpdateProvider` to detect when `newValue` is an `AsyncValue.error` whose error is `Err(Failure)`; extract the `Failure.message` and call `DebugErrorOverlay.capture` with the provider name as `useCaseName`
- [ ] Register the observer on the root `ProviderScope` in `main_dev.dart` only; guard with `kDebugMode`
- [ ] Write a widget test: override a `FutureProvider` to emit `AsyncValue.error(Err(DatabaseFailure('test')), StackTrace.empty)`, pump, and assert the overlay shows "DatabaseFailure" and "test"

### Notes

- Do not modify any production notifier or use case; the observer is a pure side-channel read

### References

- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)
- `2.9.3 Layer-Boundary Rules` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-212 — Overlay UI: scrollable error detail panel

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Build the overlay panel as a full-screen `Material` widget layered via `Stack` at the root; panel is scrollable (`SingleChildScrollView`)
- [ ] Display per `_ErrorEntry`: error type (bold), message, abbreviated stack trace (first 10 frames from `Chain.terse`), route (if non-null), use-case name (if non-null), and formatted timestamp
- [ ] All text in the panel must be wrapped in `SelectableText` to allow full-text selection and copy
- [ ] When multiple errors are captured, show a header "Error N of M" with prev/next navigation arrows to page between entries
- [ ] Write a widget test: inject two `_ErrorEntry` instances via `DebugErrorOverlay.capture`, pump, and assert both entries are navigable and their fields render correctly

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-213 — Clipboard actions: Copy and Record Bug buttons

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Add a "Copy" `TextButton` to the overlay panel; on tap, call `Clipboard.setData` with a payload containing: error type, message, and the full raw stack trace (not tersed)
- [ ] Add a "Record Bug" `TextButton`; on tap, build a plain-text template: header line "Bug Report", error type, message, full stack trace, current route, and ISO-8601 timestamp; call `Clipboard.setData` with this string
- [ ] Write widget tests for both buttons: mock `Clipboard.setData` via the test binding, tap each button, and assert (a) Copy payload is non-empty and contains the error message, (b) Record Bug payload contains the literal string "Bug Report" and the error message

### Notes

- Use `flutter_test`'s `TestWidgetsFlutterBinding` clipboard mock; no real clipboard access needed in tests

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-214 — Dismiss action and persistent error-count badge

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Add a "Dismiss" `IconButton` (close icon) to the overlay; on tap, hide the full panel but do not clear the `_ErrorEntry` list
- [ ] When the panel is dismissed and the error list is non-empty, render a persistent floating `FloatingActionButton`-style badge in the bottom-right corner showing the error count
- [ ] Tapping the badge re-opens the full overlay panel at the last-viewed entry
- [ ] Write widget tests: (a) dismiss the overlay and assert the panel is not in the tree but the badge is visible with correct count, (b) tap the badge and assert the panel re-appears

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-215 — Widget test suite: full overlay behaviour coverage

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Write a test: trigger a `FlutterError` overflow (pump a widget wider than constraints), assert the overlay panel appears within one frame (after `pump()`)
- [ ] Write a test: inject a `DatabaseFailure` via the Riverpod observer path, assert overlay panel shows `DatabaseFailure` type and its message
- [ ] Write a test: inject a `ValidationFailure` via the Riverpod observer path, assert overlay panel shows `ValidationFailure` type
- [ ] Write a test: overlay is not present in the widget tree when `kDebugMode` is false (build a release-mode widget with the overlay wrapper and assert no overlay-specific widget key exists)
- [ ] Ensure all tests pass with `flutter test --coverage`; confirm overlay-related files appear in coverage report

### Notes

- The `kDebugMode` release test can be achieved by wrapping the app root with a test double that forces `kDebugMode = false` via a parameter flag on `DebugErrorOverlay`

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## T-216 — Release build verification: zero debug overlay code in APK

**Parent Epic:** E-1
**Parent Story:** S-83

### Todo

- [ ] Run `flutter build apk --release --flavor prod` and confirm the build succeeds with zero compile errors
- [ ] Run `strings build/app/outputs/flutter-apk/app-prod-release.apk | grep -i DebugErrorOverlay` and assert zero matches
- [ ] Document the verification command and expected output in a comment block inside `main_dev.dart` as a reminder for future maintainers
- [ ] Add the `strings` grep command as a step in a local CI check script (`scripts/verify-release-clean.sh`) so it can be re-run on demand

### Notes

- This task is verification-only; no production code changes are expected. If the `kDebugMode` guard is correctly placed in T-209, this should pass without further changes.

### References

- `2.12.4 Build Flavors` (`docs/02-technical/sds.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)

---
