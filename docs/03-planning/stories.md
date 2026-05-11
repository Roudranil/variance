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


## S-8 — Account Domain Entities + Repository Interface

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a developer, I want typed domain entities and a repository interface for accounts, so that all account feature work builds on a stable, dependency-free domain layer.

### Objectives

- Define `Account` and `AccountDetail` Freezed entities with all system fields (id, created_at, updated_at, is_deleted, deleted_at, is_protected, is_system, display_order)
- Define `IAccountRepository` abstract interface covering CRUD, watch, and balance-stream methods
- Define `CreateAccountParams` and `UpdateAccountParams` input value objects

### Definition of Done

- `Account` and `AccountDetail` entities compile with no Flutter imports
- `IAccountRepository` interface matches API contracts spec exactly
- All entity fields match Data Model §3.1 and §3.2

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## S-9 — Account DAO + Repository Implementation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a developer, I want a Drift DAO and repository implementation for accounts, so that all account use cases can persist and query data correctly.

### Objectives

- Implement `AccountDao` with queries for CRUD, soft-delete, name-uniqueness check, and balance stream
- Implement `AccountRepositoryImpl` backed by `AccountDao`
- Map Drift rows to/from domain `Account` entities via DTOs
- Register `AccountDao` and `AccountRepositoryImpl` providers in Riverpod DI graph

### Definition of Done

- `AccountDao` covers all `IAccountRepository` method shapes
- Name uniqueness check includes soft-deleted rows
- Balance stream emits on every `entries` write for the account within 1 s
- Repository provider wired into Riverpod graph
- Integration tests cover create/read/update/soft-delete on an in-memory DB

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## S-10 — Account CRUD Use Cases + Guard Rails

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to create, edit, and soft-delete accounts with all business rules enforced, so that my account data is always valid and consistent.

### Objectives

- Implement `CreateAccountUseCase`: validate input, check name uniqueness (including soft-deleted), post opening balance via `LedgerEngine` if non-zero, offer reinstatement when name+category match a soft-deleted account
- Implement `UpdateAccountUseCase`: validate editable fields, enforce account category immutability
- Implement `SoftDeleteAccountUseCase`: enforce last-account guard, set `is_deleted = true`
- Implement `WatchAccountsUseCase` and `GetAccountUseCase`
- Wire all use cases as Riverpod providers

### Definition of Done

- Creating an account with non-zero opening balance produces balanced `entries` rows; EQ account created atomically if it does not exist
- Name uniqueness rejects names matching soft-deleted accounts; reinstatement offer fires on name+category match
- Last-account guard prevents deletion when exactly one account exists
- All use cases return typed `Result<T, Failure>`
- Unit tests with mock repository cover all guard rails

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1 Account CRUD` (`docs/01-product/prd.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `TC-035: Soft-deleted entity reinstatement` (`docs/01-product/technical-clarifications.md`)
- `TC-045: EQ (Opening Balance equity account)` (`docs/01-product/technical-clarifications.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## S-11 — Account Category-Specific Fields (account_details)

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to enter and view category-specific fields for my accounts, so that I can track bank names, card numbers, billing dates, and other per-category metadata.

### Objectives

- Persist all 23 `detail_key` values to `account_details` via DAO
- Encrypt `card_number` and `account_number` fields at rest; reveal requires biometric/PIN auth
- Never store CVV
- Show loan installment suggestion post-save when `initial_balance < 0` or EMI fields provided

### Definition of Done

- All 23 detail keys save and reload correctly per their account category
- `card_number` and `account_number` stored in `detail_value_encrypted`; plain-text read requires auth
- CVV field is absent from all forms
- Loan installment suggestion bottom sheet fires on negative initial balance
- Widget tests verify encrypted field reveal flow

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2 Account Categories (Fixed Set — No Custom Categories)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `TC-013: Notification reschedule triggers on credit card field edits` (`docs/01-product/technical-clarifications.md`)

---

## S-12 — Account Balance Stream + Net Worth Aggregation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see real-time account balances and aggregate net worth, so that I always know my current financial position.

### Objectives

- Compute balance as `Σdebit − Σcredit` over non-void entries via Drift stream
- Aggregate net worth in home currency using `exchange_rate_to_home`; exclude soft-deleted and `include_in_net_worth = 0` accounts
- Show negative balances in warning color; show excluded-account balances grayed-out inline below net worth total
- Surface staleness indicator when exchange rate is >14 days old

### Definition of Done

- Balance stream emits updated value within 1 s of a new entry insert
- Net worth correctly excludes soft-deleted and excluded-flag accounts
- Negative balance renders in warning color token in widget test
- Performance: balance query completes in <500 ms for 10,000 entries (index on `entries(account_id, side)`)

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.4 Account Balance View` (`docs/01-product/prd.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `TC-045: EQ (Opening Balance equity account) — balance and auditability` (`docs/01-product/technical-clarifications.md`)

---

## S-13 — Account List Screen + Create/Edit Form

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see all my accounts grouped by category with balances, and create or edit accounts via a form, so that I can manage my financial accounts.

### Objectives

- Render account list grouped by account category with per-account balance and net worth summary card
- Show excluded-account section below net worth; empty state CTA when no accounts exist
- Account create form: name, account_category (9 values), initial_balance, currency, include_in_net_worth, notes, category-specific fields
- Account edit form: pre-populate all editable fields; disable account_category field; show currency immutability info tooltip

### Definition of Done

- Account list groups and balances update reactively via Riverpod stream provider
- FAB navigates to create form; row tap navigates to account detail
- Reinstatement dialog fires when name+category match a soft-deleted account
- All form validations fire inline; successful create/edit returns to list with updated state
- Widget tests cover empty state, grouped list render, and form validation errors

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.1.1 Create Account — Fields` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## S-14 — Account Detail Screen

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see all information about a single account — including balance, metadata, and transaction history — so that I can review and manage it in one place.

### Objectives

- Display account name, category, currency, current balance, notes, and category-specific fields
- Render per-account paginated transaction list (all months, cursor-based, 50 rows)
- Credit card accounts: show outstanding balance, statement balance, and Pay FAB
- Contextual menu: Edit, Soft-delete (with last-account guard), Reconcile

### Definition of Done

- Balance and transaction list update reactively
- Per-account transaction list is not month-filtered; paginates at 50 rows
- Pay FAB appears only on credit_card category accounts
- Soft-delete action shows confirmation dialog; blocked with tooltip when last account
- Widget tests cover credit card variant and empty transaction list

### References

- `ACC-04 — Account Detail Screen` (`docs/02-technical/feature-dag.md`)
- `5.1.3 Account Detail Screen` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)

---

## S-15 — Credit Card Payment Flow + Balance Reconciliation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to pay my credit card balance and reconcile account balances, so that I can keep my accounts accurate.

### Objectives

- Pay FAB on credit card detail screen: pre-fill transfer form (source = linked bank account or picker, destination = credit card, amount = outstanding balance)
- Balance reconciliation: user enters actual balance; app computes delta; posts a Balance Adjustment income or expense transaction
- Overdraft warning: non-blocking inline warning when transaction would push asset balance below zero
- Credit limit warning: non-blocking inline warning when expense/transfer would exceed `credit_limit_minor`

### Definition of Done

- Pay FAB creates a transfer transaction with correct source/destination pre-filled
- Reconciliation delta posted as Balance Adjustment using `BAI`/`BAE` protected categories
- Overdraft and credit limit warnings render correctly in widget tests; they are non-blocking (user can proceed)

### References

- `ACC-05 — Credit Card Payment Flow` (`docs/02-technical/feature-dag.md`)
- `ACC-06 — Balance Reconciliation` (`docs/02-technical/feature-dag.md`)
- `5.1.5 Credit Card Payment` (`docs/01-product/prd.md`)
- `5.1.6 Balance Reconciliation` (`docs/01-product/prd.md`)
- `5.1.4.2 Overdraft warning` (`docs/01-product/prd.md`)
- `5.1.4.3 Credit card limit warning (FG-C18)` (`docs/01-product/prd.md`)

---

## S-16 — Transaction Domain Entities + Repository Interface

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a developer, I want typed domain entities and a repository interface for transactions, so that all transaction feature work builds on a stable domain layer.

### Objectives

- Define `Transaction`, `Entry`, `Tag`, `CompoundGroup` Freezed entities with all fields from Data Model §3.3–§3.4
- Define `ITransactionRepository` abstract interface covering CRUD, watch, paginated list, and FTS5 search
- Define `CreateTransactionParams`, `UpdateTransactionParams` input value objects

### Definition of Done

- All entities compile with no Flutter imports
- `ITransactionRepository` matches API contracts exactly
- `type` field defined as immutable sealed enum (income/expense/transfer)

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## S-17 — Transaction DAO + Repository Implementation

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a developer, I want a Drift DAO and repository implementation for transactions, so that all transaction use cases can persist and query data correctly.

### Objectives

- Implement `TransactionDao` with queries for insert, soft-delete, paginated watch, per-account list, and FTS5 search
- Implement `TransactionRepositoryImpl` backed by `TransactionDao`
- Map Drift rows to/from domain entities via DTOs
- Register providers in Riverpod DI graph

### Definition of Done

- `TransactionDao` covers all `ITransactionRepository` shapes
- Paginated query uses cursor (last `date_time` + `id`) not OFFSET
- FTS5 insert trigger keeps `transactions_fts` in sync on every insert
- Integration tests cover create/read/soft-delete on in-memory DB

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)

---

## S-18 — Transaction Entry Form — Income + Expense

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to create income and expense transactions via a form, so that my account balances stay accurate.

### Objectives

- Form fields: type toggle (income/expense), amount, account picker, category + subcategory picker, date/time, title, description, tags
- On submit: call `LedgerEngine.post` → `TransactionRepository.save` in single ACID transaction; invalidate `transactionsProvider` and `accountBalanceProvider`
- Duplicate detection: non-blocking warning on matching type + amount + account + category on same calendar day
- Amount stored as minor units; `currency_code` derived from account (immutable after save)

### Definition of Done

- Saving income or expense produces balanced `entries` rows with `status = 'posted'`, `purpose = 'user'`
- Account balance updates reactively after save
- Duplicate detection warning appears but does not block save
- `description` max length enforced per `app_settings.description_max_length`
- Widget tests cover field validation, duplicate warning, and successful save state

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## S-19 — Transaction Entry Form — Transfer with Fee

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to record transfers between accounts including optional fees, so that my ledger correctly reflects cross-account movements.

### Objectives

- Transfer form fields: source account, destination account, amount, exchange rate (cross-currency), date/time, title, description, tags; optional fee leg
- Cross-currency transfer: capture `exchange_rate_micro` on transaction row
- Transfer-with-fee: create compound group (`compound_group_id`, `compound_role`) — primary leg + fee leg in same DB transaction
- `type` immutable after save; no `category_id` on transfers

### Definition of Done

- Transfer creates balanced entries for both source and destination accounts
- Cross-currency transfer stores `exchange_rate_micro`; both account balances update correctly
- Fee leg creates a second transaction row with `compound_role = 'fee'` in same `compound_group_id`
- Widget tests cover same-currency, cross-currency, and with-fee variants

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## S-20 — Transaction Immutability + Correction Model

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want edits to financial fields on posted transactions to produce a correction chain, so that my ledger history is always auditable and immutable.

### Objectives

- Financial-field edit: void original (`status → voided`), post reversal row (`purpose = 'reversal'`), post correction row (`purpose = 'correction'`)
- In-place edit fields (no correction): `title`, `description`, `photos`, `date_time`
- Soft-delete: void original, post reversal; no correction row
- Correction chain: `corrects_transaction_id` points to immediately preceding transaction

### Definition of Done

- Editing `amount_minor`, `account_source_id`, `category_id` on a posted transaction produces void + reversal + correction
- Editing `title` or `description` updates the row directly; no new entries written
- Voided transactions excluded from default list and balance computation
- No transaction ever permanently deleted
- Unit tests cover all correction-chain branches including correcting a correction

### References

- `TXN-02 — Transaction Immutability + Correction Model` (`docs/02-technical/feature-dag.md`)
- `5.2.2 Transaction Immutability & Editing` (`docs/01-product/prd.md`)
- `1.6.7 Transaction Immutability and Correction Model` (`docs/02-technical/sds.md`)
- `3.3.1 Correction Chain` (`docs/02-technical/data-model.md`)
- `TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md` (`docs/01-product/technical-clarifications.md`)

---

## S-21 — Transaction Detail View

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to tap a transaction and see all its details, so that I can review and act on it.

### Objectives

- Show all §5.2.1.6 fields: type, amount, account(s), category, date/time, title, description, exchange rate, fee breakdown, tags, photos
- Photo carousel: up to 2 photos, full-screen tap, per-photo delete action
- Contextual menu: Edit (opens entry form), Soft-delete (confirmation dialog)
- Pending transactions: all fields freely editable in-place (correction model does NOT apply)

### Definition of Done

- All v1 fields from §5.2.1.6 present and correctly populated
- Compound transfer-with-fee shows fee breakdown section
- Photo carousel shows up to 2 photos; deleting a photo removes both `attachments` row and physical file
- Edit action opens pre-filled entry form; soft-delete triggers confirmation then voids transaction
- Widget tests cover compound transfer detail and empty photo carousel

### References

- `TXN-03 — Transaction Detail View` (`docs/02-technical/feature-dag.md`)
- `5.2.1.5 Transaction Detail View` (`docs/01-product/prd.md`)
- `5.2.1.6 v1 contents` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## S-22 — Photo Attachments

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to attach photos to transactions, so that I can keep receipts alongside my records.

### Objectives

- Attach up to 2 photos per transaction (camera or gallery)
- Compress: JPEG, max 1920px, target < 500KB (quality 85 → iterative 5-point reduction, floor 60)
- Store in app-private directory; `attachments` row records relative path + metadata
- Delete physical file when transaction voided

### Definition of Done

- Up to 2 photos attachable; 3rd photo blocked with message
- Compressed output is JPEG ≤ 500KB in all widget test scenarios
- `attachments` rows and physical files deleted on transaction soft-delete
- Missing file on delete is handled idempotently (no crash)

### References

- `TXN-04 — Photo Attachments` (`docs/02-technical/feature-dag.md`)
- `5.2.3 Photo Attachments` (`docs/01-product/prd.md`)
- `2.15 Photo Compression` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `TC-007: Photo compression parameters` (`docs/01-product/technical-clarifications.md`)

---

## S-23 — Transaction List — Unified + Per-Account

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to browse all my transactions in a paginated list grouped by date, so that I can quickly review my recent financial activity.

### Objectives

- Unified list (home screen): month-filtered, cursor-paginated at 50 rows, grouped by date, excludes voided and reversal rows by default
- Per-account list (account detail screen): all months, same pagination and grouping
- Each row: type icon, title, category, amount, account name
- Swipe-to-delete and long-press contextual menu

### Definition of Done

- Both lists paginate correctly at 50 rows using cursor (not OFFSET)
- Date-group headers re-render correctly when month changes
- Voided and reversal rows excluded from default filter
- Swipe-to-delete fires confirmation; long-press opens contextual menu
- Widget tests cover empty month, multi-page scroll, and voided exclusion

### References

- `TXN-05 — Transaction List (Unified)` (`docs/02-technical/feature-dag.md`)
- `TXN-12 — Per-Account Transaction List` (`docs/02-technical/feature-dag.md`)
- `5.2.4 Transaction List` (`docs/01-product/prd.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## S-24 — Duplicate Detection + Warning

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want a warning when I try to save a transaction that looks like a duplicate, so that I avoid accidentally recording the same transaction twice.

### Objectives

- Detect: same type + amount + account + category on same calendar day (transfers: type + amount + source + destination)
- Non-blocking: warning shown but save is not blocked
- Warning includes matched transaction details; user can dismiss and proceed

### Definition of Done

- Duplicate check fires on every save attempt before calling `LedgerEngine.post`
- Warning bottom sheet shows matched transaction title, date, amount
- Dismissing warning proceeds with save normally
- Unit tests cover all detection combinations (income, expense, transfer)

### References

- `TXN-06 — Duplicate Detection` (`docs/02-technical/feature-dag.md`)
- `5.2.1.8 Duplicate detection` (`docs/01-product/prd.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## S-25 — Transaction Search — FTS5

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to search my transactions by title and description, so that I can quickly find specific transactions.

### Objectives

- Global FTS5 search (not month-scoped) over `title` and `description`
- Results ranked by relevance; partial matches supported
- Clearing search re-engages the active month filter
- Search results use same list row widget as transaction list

### Definition of Done

- FTS5 query returns results within 500 ms for 10,000 transactions
- Partial title and description matches return results
- Clearing search input returns to month-filtered list
- Widget tests cover empty results state and partial match rendering

### References

- `TXN-08 — Transaction Search` (`docs/02-technical/feature-dag.md`)
- `5.2.5 Search` (`docs/01-product/prd.md`)
- `1.4.3 FTS5 Search` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## S-26 — Transaction Filter Sheet

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to filter my transaction list by date range, account, category, and type, so that I can focus on specific subsets of my transactions.

### Objectives

- Filter criteria: date range, account (multi-select), category (multi-select), transaction type, amount range
- Filter sheet applied on top of month-filtered or search-results list
- Active filter chip strip below search bar; each chip dismissible
- Filter state persisted in `FilterNotifier` (Riverpod); cleared on month change

### Definition of Done

- All filter criteria apply correctly and compose with each other
- Filter chip strip reflects active filters; tapping chip removes that criterion
- Filter sheet dismissal without change leaves existing filter intact
- Widget tests cover multi-criterion filter and chip dismissal

### References

- `TXN-09 — Transaction Filter` (`docs/02-technical/feature-dag.md`)
- `5.2.6 Filter` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## S-27 — Future-Dated + Pending Transactions

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to record future-dated transactions that stay pending until their date, so that I can plan ahead without affecting current balances.

### Objectives

- Transaction with `date_time > now` saved with `status = 'pending'`; excluded from balance computation until posted
- App-launch sweep (SCHED-01) posts pending transactions when `date_time <= now`
- Pending transactions shown in future-month lists; "Pending" badge on list row
- All fields freely editable on pending transactions (correction model does not apply)

### Definition of Done

- Pending transaction excluded from `watchBalance` result until `status = 'posted'`
- Sweep posts pending transactions in chronological order; balance updates reactively after each post
- "Pending" badge renders on list row in widget test
- Edit form for pending transaction has all fields unlocked

### References

- `TXN-10 — Future-Dated Transactions` (`docs/02-technical/feature-dag.md`)
- `TXN-11 — Pending Transaction Management` (`docs/02-technical/feature-dag.md`)
- `5.2.7 Pending Transactions` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## S-28 — Transaction Drafts

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want my half-filled transaction form to be saved as a draft when I navigate away, so that I don't lose my work.

### Objectives

- Auto-save draft when back button pressed (if `back_button_behaviour = auto_save_draft`)
- 5-slot FIFO draft queue stored in `app_settings`
- Draft resume entry point from FAB (when draft exists) and home screen alert
- Explicit discard clears the draft slot

### Definition of Done

- Draft saved on back navigation when setting enabled
- 6th draft evicts the oldest; FIFO order preserved
- FAB shows "Resume draft" option when draft exists
- Discarding draft clears slot; resuming draft pre-populates form
- Widget tests cover FIFO eviction and resume pre-population

### References

- `DRAFT-01 — Transaction Drafts` (`docs/02-technical/feature-dag.md`)
- `5.2.8 Drafts` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## S-29 — Category Domain Entity, Repository Interface, and DAO

**Parent Epic:** E-4 — Categories Domain

**Story:** As an engineer, I want the `Category` domain entity, `ICategoryRepository` interface, `CategoryDao`, and `CategoryRepositoryImpl` to exist so that all higher-level category use cases have a fully wired persistence layer to build on.

### Objectives

- Define the `Category` freezed entity in `lib/domain/entities/category.dart` with all columns from data model §3.5 (`id`, `parentId`, `treeType`, `name`, `iconRef`, `isDeleted`, `deletedAt`, `isProtected`, `sortOrder`, `createdAt`, `updatedAt`)
- Define `ICategoryRepository` in `lib/domain/repositories/category_repository.dart` with the four methods: `watchAll()`, `create()`, `update()`, `softDelete(id, replacementId?)`
- Define the `CategoryDto` in `lib/data/models/category_dto.dart` with `fromRow` / `toEntity` mappers
- Implement `CategoryDao` as a Drift `DatabaseAccessor` in `lib/data/datasources/` with tree queries (`watchAll`, by tree type, by parent, protected guard)
- Implement `CategoryRepositoryImpl` in `lib/data/repositories/` wrapping the DAO; `softDelete` checks child count > 0 and returns `Err(BusinessRuleFailure)` if blocked
- Composite index `(tree_type, parent_id, name)` confirmed present (non-unique; case check is app-layer)

### Definition of Done

- `Category` entity compiles; all fields present; `freezed` codegen passes
- `ICategoryRepository` defines all four method signatures
- `CategoryDao` unit-tested with Drift in-memory DB: CRUD round-trips pass
- `CategoryRepositoryImpl` unit-tested: `softDelete` on parent with children returns `BusinessRuleFailure`
- `watchAll()` emits updated stream on any categories table write

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `2.4 Categories` (`docs/02-technical/api-contracts.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `1.5.1 Folder Structure` (`docs/02-technical/sds.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)

---

## S-30 — Category CRUD Use Cases and Riverpod Wiring

**Parent Epic:** E-4 — Categories Domain

**Story:** As an engineer, I want `CreateCategoryUseCase`, `UpdateCategoryUseCase`, and `DeleteCategoryUseCase` implemented and Riverpod-wired so that the presentation layer can drive all category mutations through type-safe, validated use cases.

### Objectives

- Implement `CreateCategoryUseCase`: validates name uniqueness (case-insensitive, within same `tree_type` + `parent_id`, including soft-deleted rows), enforces two-level-max depth (parent_id must itself be a root), delegates to `ICategoryRepository.create()`
- Implement `UpdateCategoryUseCase`: validates same uniqueness constraint on rename; returns `Err(ValidationFailure)` on conflict
- Implement `DeleteCategoryUseCase`: calls `ICategoryRepository.softDelete()`; propagates `BusinessRuleFailure` from repo when child count > 0
- Register `CategoryListNotifier` as a Riverpod `AsyncNotifier` emitting `AsyncValue<List<Category>>`; expose via auto-generated providers
- Wire `ICategoryRepository` → `CategoryRepositoryImpl` in the DI provider file

### Definition of Done

- All three use cases unit-tested with fake `ICategoryRepository`
- Name uniqueness test: duplicate name in same tree+parent returns `Err(ValidationFailure)`
- Name uniqueness test: duplicate name under different parent succeeds
- Name uniqueness test: name matching a soft-deleted category in same tree+parent returns `Err(ValidationFailure)`
- `CategoryListNotifier` widget-tested: provider override propagates list to `AsyncValue.data`
- DI wiring: `CategoryRepositoryImpl` is returned by the Riverpod repository provider

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.4.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## S-31 — Category Management Screen (Settings)

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a Category Management screen in Settings that shows all my categories in tabbed Expense / Income trees so that I can see, add, edit, and delete categories from a single screen.

### Objectives

- Implement `/settings/categories` screen with `TabBar` ("Expense" / "Income"), `ListView` of parent category rows (icon + name + child count), FAB "Add Category"
- Implement all four screen states: Loading (shimmer), Loaded-empty (empty state + FilledButton), Loaded-populated (tabbed list), Error (inline banner + Retry)
- Long-press contextual menu: Edit, Delete (disabled with tooltip if children exist), Add Child Category
- "Balance Adjustment" parent categories (`is_protected = 1`) filtered out entirely from this screen
- FAB navigates to Category Detail screen in create mode (tree pre-selected by active tab)
- Delete action on a leaf parent (no children) opens deletion wizard flow (CAT-03 prerequisite — placeholder navigation only in this story)

### Definition of Done

- Widget test: Loading state renders shimmer list
- Widget test: Loaded-populated state renders two tabs; Expense tab shows correct category rows
- Widget test: `is_protected = 1` rows absent from both tabs
- Widget test: Delete menu item is disabled and shows tooltip when category has children
- Golden tests for empty, loading, and populated states on both tabs
- Route `/settings/categories` resolves correctly in GoRouter

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `9.8 Screen: Category Management` (`docs/02-technical/ux-flows.md`)
- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.22.1 From Settings` (`docs/02-technical/ux-flows.md`)

---

## S-32 — Category Detail / Edit Screen

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a Category Detail screen where I can create or edit a category (name and icon), and for parent categories also manage subcategories, so that my category library stays accurate and well-organised.

### Objectives

- Implement `/settings/categories/:id` screen (create and edit modes) with name `OutlinedTextField`, icon picker row, Save in AppBar
- Parent category view: subcategory section with list rows, "Add subcategory" button, "No subcategories" empty state
- Child category view: read-only parent label row; no subcategory section
- Real-time name uniqueness validation: `TextField` error text "Name already in use" on conflict
- Icon picker `ModalBottomSheet`: `GridView` of ~250 `material_symbols_icons`; search `TextField` at top; 48 dp touch targets
- Save enabled only when form is dirty and name passes validation
- Inline category creation from Settings flow: tree selector at top on create screen; subcategory creation pre-sets parent

### Definition of Done

- Widget test: Save button disabled when name is empty
- Widget test: Save button disabled when name matches existing category (same tree + parent)
- Widget test: parent category view renders subcategory section; child view does not
- Widget test: icon picker sheet opens on icon row tap; selection updates icon preview
- Golden tests for loading, parent-loaded, child-loaded, dirty, and name-conflict states
- Successful save calls `CreateCategoryUseCase` or `UpdateCategoryUseCase` and navigates back

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `9.9 Screen: Category Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.22 Flow: Category Creation — Inline vs. From Settings` (`docs/02-technical/ux-flows.md`)

---

## S-33 — Category Soft-Delete Wizard

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a guided multi-step wizard when deleting a category so that my recurring templates and historical transactions are handled correctly before the category disappears.

### Objectives

- Implement four-step deletion flow in exact order: (1) template handling dialog if templates reference the category, (2) usage count info dialog if N > 0 active transactions, (3) migration choice dialog (No migration / Migrate all / Choose specific), (4) soft-delete execution
- Step 1a: template migration picker (category picker filtered to same tree; or archive option)
- Step 3a: "Migrate all" → destination category picker (same tree filter)
- Step 3b: "Choose specific" → multi-select transaction `BottomSheet` with checkbox rows
- Step 4: batch > 50 transactions triggers additional `AlertDialog` confirmation; progress dialog for N > 10
- Batch migration executes in a single Drift DB transaction; rolls back to pre-deletion state on app kill
- Performance target: ≤ 5 s for N = 500 transactions on mid-range Android device
- Soft-deleted category: hidden from pickers; visible in filter dropdowns; historical transactions retain old label

### Definition of Done

- Unit test: step sequence is always 1 → 2 → 3 → 4; no step is skipped or reordered
- Unit test: template handling fires before transaction migration when both apply
- Unit test: batch migration rolls back atomically on simulated failure mid-transaction
- Widget test: "No migration" option always available as default in step 3
- Widget test: migration destination picker filters to same `tree_type` only
- Widget test: batch > 50 renders extra confirmation dialog with correct transaction count
- Soft-deleted category does not appear in category picker sheet after deletion completes

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Deletion Flow Components` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)

---

## S-34 — Default Category Seeding

**Parent Epic:** E-4 — Categories Domain

**Story:** As a new user, I want all default income and expense categories pre-loaded on first install so that I can start entering transactions immediately without any category setup.

### Objectives

- Implement first-install seeding migration: inserts all default categories from PRD §5.6.1 into the `categories` table using `INSERT OR IGNORE` for idempotency
- Seed `Balance Adjustment` (income parent + BAI child) and `Balance Adjustment` (expense parent + BAE child) with `is_protected = 1` and icon `balance`
- Seed `Financial` (expense parent, `is_protected = 0`) and `Fees & Charges` (child of Financial, `is_protected = 1`)
- All default category icons drawn from the curated ~250-icon subset (TC-014 founder-approved set)
- Seeding runs only on fresh install (guarded by `schema_migrations` version check); re-run is safe
- `sort_order` is NULL for all seeded rows (v1 — alphabetical display)

### Definition of Done

- Unit test: after `onCreate` migration, `categories` table contains all expected default rows
- Unit test: idempotency — running seeding migration twice produces no duplicate rows
- Unit test: `Balance Adjustment` income and expense parent rows have `is_protected = 1`
- Unit test: BAI and BAE child rows have `is_protected = 1`
- Unit test: `Fees & Charges` child row has `is_protected = 1`
- Unit test: all seeded rows have `sort_order = NULL`

### References

- `CAT-02 — Default Category Seeding` (`docs/02-technical/feature-dag.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)

---

## S-35 — Protected Category Guards and Category Picker Sheet

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want protected "Balance Adjustment" categories to be invisible in transaction entry and category management, and I want a functional Category Picker bottom sheet for transaction forms, so that system categories are never accidentally used or modified.

### Objectives

- Implement the Category Picker `ModalBottomSheet` (`DraggableScrollableSheet`, 0.6 initial / 0.92 max extent) for use in transaction entry (income and expense only; not transfer)
- Sheet states: Loading (shimmer), Populated (search + recents strip + two-level list), Empty (no categories), Search results (flat filtered list), Inline create
- Recents: up to 5 most recently used categories for the active `tree_type`, ordered by recency
- Inline create within picker: parent category only; icon picker sub-sheet + name field + real-time uniqueness check; calls `CreateCategoryUseCase`
- `is_protected = 1` categories filtered out from picker at application layer (not DB constraint)
- Category management screen already filters `is_protected = 1` rows (validated in S-31)
- Soft-deleted categories hidden from picker except when editing a transaction that already references one (shown as special "current" entry at top)

### Definition of Done

- Widget test: `is_protected = 1` categories absent from picker list
- Widget test: soft-deleted category absent from picker in create mode; present as "current" entry in edit mode when transaction references it
- Widget test: inline create path calls `CreateCategoryUseCase` and auto-selects new category on success
- Widget test: empty tree shows "No categories yet" + "Create category" CTA; Save button on transaction form is disabled with message "No categories available. Create a category in Settings."
- Widget test: search filters parent and child rows; "No results" state shows inline create
- Golden tests for loading, populated, empty, search-active, and inline-create states

### References

- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `1.1 Category Picker (UX-11)` (`docs/02-technical/ux-flows.md`)
- `8.1 Category Picker Sheet` (`docs/02-technical/ui-spec.md`)

---

## S-36 — Exchange Rate Background Fetch + Cache

**Parent Epic:** E-5 — Currency Domain

**Story:** As a user with foreign-currency accounts, I want exchange rates to be fetched automatically in the background so that my net worth displays up-to-date home-currency equivalents without any manual action.

### Objectives

- Implement WorkManager one-time task (`ExchangeRateFetchWorker`) enqueued on app launch when last successful fetch is older than 23 hours
- Scope the fetch to currencies present in active accounts only; skip the network call if all accounts are in home currency
- Call the fawazahmed0/exchange-api endpoint and upsert all returned pairs into the `exchange_rates` table via `IExchangeRateRepository.fetchAndCache()`
- Handle timeout (10 s) and network failure silently — no user notification, no retry
- Surface staleness disclaimer in the net worth view when any cached rate is older than 14 days

### Definition of Done

- `exchange_rates` table is upserted correctly after a successful fetch; `fetched_at` and `rate_date` columns are populated
- No network call is issued when the user holds only home-currency accounts
- WorkManager task respects `NetworkType.connected` constraint
- Fetch failure leaves existing cache intact and does not surface any error to the user
- Net worth card shows "Exchange rate may be outdated" when a cached rate is older than 14 days
- Unit tests cover: fetch-scope query, upsert logic, staleness threshold, and silent-failure path

### References

- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `2.7 Exchange Rate` (`docs/02-technical/sds.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.5 Currency & Exchange Rates` (`docs/02-technical/api-contracts.md`)
- `8.1 Screen: Account List` (`docs/02-technical/ux-flows.md`)

---

## S-37 — Currency Bundle Seeding + Repository

**Parent Epic:** E-5 — Currency Domain

**Story:** As the app, I want the bundled ISO 4217 currency list to be loaded from a static asset and seeded into the `currencies` table on fresh install so that account creation, transaction entry, and exchange rate logic have access to accurate currency metadata.

### Objectives

- Bundle `assets/data/currencies.json` (~180 active ISO 4217 currencies) with fields `code`, `name`, `symbol`, `minor_units`
- Seed the `currencies` table from the asset during `onCreate` migration
- Implement `ICurrencyRepository` with `watchAll()`, `watchEnabled()`, `setHomeCurrency()`, `enableCurrency()`, `disableCurrency()`
- Hold the loaded list in a `keepAlive` Riverpod provider; no repeated asset parses at runtime
- Enforce `minor_units` downstream contract: amount input restricts decimal places; amounts stored as integers in minor units; display formats to `minor_units` decimal places

### Definition of Done

- `currencies` table contains ≥ 170 rows after fresh install
- `ICurrencyRepository.watchAll()` returns correct entries for USD (`minor_units=2`), JPY (`minor_units=0`), BHD (`minor_units=3`)
- `keepAlive` provider parses the asset exactly once per app lifecycle
- Unit tests verify seeding, `watchEnabled()` filtering, and `minor_units` values for canonical currencies

### References

- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `INFRA-6 — Currency Bundle` (`docs/02-technical/feature-dag.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.5 Currency & Exchange Rates` (`docs/02-technical/api-contracts.md`)

---

## S-38 — Currency Symbol Disambiguation

**Parent Epic:** E-5 — Currency Domain

**Story:** As a user holding accounts in currencies that share the same display symbol, I want the ISO 4217 code to appear alongside the symbol in all affected views so that I can always distinguish which currency a balance or transaction refers to.

### Objectives

- Implement symbol-collision detection: at render time, compute the set of active-account currencies; flag any symbol appearing for more than one currency
- When collision is detected, render `$USD` / `$SGD` style formatting (symbol + ISO code) in all four affected views: account list row, net worth card, transaction list row, transaction detail view
- Single-currency users and users with no symbol collision see no change in display
- Disambiguation does not apply to the currency picker in settings

### Definition of Done

- Two-currency scenario with a shared symbol: ISO code appears in all four views
- Single-currency scenario: display is unchanged (no ISO code appended)
- Three-or-more-currency scenario where only a subset share a symbol: disambiguation applies only to the colliding symbol
- No user action required; logic is automatic and derived from the active-account currency set
- Unit tests cover: no-collision, partial-collision, and full-collision cases

### References

- `CURR-02 — Currency Symbol Disambiguation` (`docs/02-technical/feature-dag.md`)
- `8.1 Screen: Account List` (`docs/02-technical/ux-flows.md`)
- `2.5 Currency & Exchange Rates` (`docs/02-technical/api-contracts.md`)

---

## S-39 — Exchange Rate Estimate on Transaction Entry Form

**Parent Epic:** E-5 — Currency Domain

**Story:** As a user entering a transaction against a foreign-currency account, I want to see a real-time home-currency estimate below the amount field so that I can understand the approximate home-currency impact of the transaction before saving.

### Objectives

- Display `≈ [home symbol][amount]` below the amount field whenever the selected account's currency differs from the home currency
- Update the estimate reactively as the user types the amount
- Show `⚠ Rate may be outdated` warning icon alongside the estimate when the cached rate is older than 14 days
- Show `Exchange rate unavailable.` note (omit estimate entirely) when no cached rate exists for the currency pair
- Home-currency accounts: show neither the estimate widget nor any disclaimer
- Expose the rate-fetch interface from `IExchangeRateRepository` to the entry form ViewModel; the displayed rate does not affect the posted amount

### Definition of Done

- Foreign-currency account entry form shows `≈ [home symbol][amount]` that updates live as amount changes
- Stale-rate state (cached rate > 14 days) shows `⚠ Rate may be outdated` icon
- No-rate state omits the estimate and shows `Exchange rate unavailable.`
- Home-currency account entry form shows no estimate widget
- Transaction save is never blocked by rate staleness or absence
- Widget tests cover: fresh rate, stale rate, no rate, home-currency account

### References

- `CURR-03 — Exchange Rate Estimate During Entry + Staleness Warning` (`docs/02-technical/feature-dag.md`)
- `7.2.6 Inline Warnings at Entry Time` (`docs/02-technical/ux-flows.md`)
- `7.9 Exchange Rate Detail Screen` (`docs/02-technical/ux-flows.md`)
- `2.7.4 Staleness and Offline Fallback` (`docs/02-technical/sds.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)
- `2.5 Currency & Exchange Rates` (`docs/02-technical/api-contracts.md`)

---

## S-40 — Currency Settings Screen

**Parent Epic:** E-5 — Currency Domain

**Story:** As a user, I want a currency settings screen that shows my home currency and the exchange rate staleness for each active secondary currency so that I can understand the current state of my rate data and change my home currency if needed.

### Objectives

- Implement `/settings/currency` screen with: home currency row (code + name, tappable to open currency picker) and secondary currencies list (derived from active accounts, not user-managed)
- Display per-secondary-currency exchange rate staleness: last-fetched timestamp; "Outdated" label when rate is older than 14 days
- Show warning banner on the home currency row: "Changing home currency does not affect existing transactions. Net worth display will recalculate using new exchange rates."
- Home currency change calls `ICurrencyRepository.setHomeCurrency(code)` — does not recompute existing `exchange_rate_to_home` values on transactions
- Wire `CurrencySettingsNotifier` to drive screen state

### Definition of Done

- Screen loads with correct home currency and derived secondary currency list
- Home currency row opens the ISO 4217 searchable currency picker on tap
- Warning banner is visible on the home currency row
- Per-secondary-currency staleness label shows "Outdated" when `(now - fetched_at) > 14 * 86400`
- `setHomeCurrency()` updates the persisted setting; screen reflects new home currency immediately
- Widget tests cover: loaded state, staleness display, currency picker launch

### References

- `CURR-01 — Multi-Currency Display + Exchange Rate Cache` (`docs/02-technical/feature-dag.md`)
- `9.10 Screen: Currency Settings` (`docs/02-technical/ux-flows.md`)
- `1.5 Currency Picker` (`docs/02-technical/ux-flows.md`)
- `2.5 Currency & Exchange Rates` (`docs/02-technical/api-contracts.md`)
- `4.2 exchange_rates` (`docs/02-technical/data-model.md`)

---

## S-41 — Scheduling Infrastructure: App-Launch Sweep + WorkManager

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As the system, I want a synchronous app-launch sweep and a WorkManager background task so that all overdue recurring and future-dated transactions are posted before the user sees any data.

### Objectives

- Implement `AppInitializer` that runs a synchronous sweep before the first frame on every cold start
- Sweep queries all `scheduled_occurrences` rows with `status = 'pending'` and `scheduled_date <= today`; posts each via the ledger engine
- Register `PostingSweeperWorker` (WorkManager) once at install with a 6-hour minimum period; no network or charging constraints
- Register `RECEIVE_BOOT_COMPLETED` in the Android manifest so WorkManager re-registers after device restart
- On each sweep: check all `recurring_templates` with `status = 'paused'` and `pause_until <= now`; auto-resume by setting `status = 'active'`, clearing `pause_until`
- Regenerate `scheduled_occurrences` lookahead rows up to 90 days ahead for all active templates on each sweep

### Definition of Done

- App-launch sweep completes and all overdue pending occurrences are posted before the first frame renders
- WorkManager periodic task is registered at install and executes the same sweep in background
- `RECEIVE_BOOT_COMPLETED` is declared in `AndroidManifest.xml`; WorkManager survives device restart
- Templates with `pause_until <= now` are auto-resumed on sweep execution
- 90-day lookahead window is refreshed on every sweep run
- Unit tests cover sweep logic with in-memory Drift DB; WorkManager integration tests confirm task is registered

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6 Scheduling` (`docs/02-technical/sds.md`)
- `1.4.3 Background Write — Recurring Auto-Post` (`docs/02-technical/sds.md`)
- `1.6.8 Scheduling Architecture` (`docs/02-technical/sds.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)

---

## S-42 — Recurring Template Creation

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want to create a recurring transaction template with a recurrence rule and posting behaviour, so that transactions are automatically posted on a defined schedule without manual entry each time.

### Objectives

- Build the Create Recurring Template screen (`/transaction/new` in recurring mode): transaction type selector, amount, accounts, category, recurrence fields (N, unit, constraints), start/end date, posting behaviour
- On save: write `recurring_templates` row; generate initial `scheduled_occurrences` batch up to 90 days ahead
- Validate all required fields; preview first scheduled date as recurrence fields are filled
- Handle end-of-month day clamping for month/year recurrences (e.g., day 31 → Feb 28)
- Support entry point from §9.23 flow (toggle "Make recurring" in transaction entry form)

### Definition of Done

- Template save writes exactly one `recurring_templates` row and the correct initial `scheduled_occurrences` batch
- First-scheduled-date preview updates live as recurrence N, unit, and start date change
- Required-field validation blocks save; error messages are shown inline
- End-of-month clamping produces the correct date for all month/year edge cases
- `CreateRecurringTemplateUseCase` unit tests pass with fake repository; golden test covers filled state

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `7.3 Create Recurring Transaction Screen` (`docs/02-technical/ux-flows.md`)
- `7.16 Flow — Create Recurring Template` (`docs/02-technical/ux-flows.md`)
- `9.23 Flow: Recurring Template Creation` (`docs/02-technical/ux-flows.md`)
- `7.3.2 Template Fields` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## S-43 — Recurring Templates List + Detail/Edit Screen

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want to view all my recurring templates in a list and edit the editable fields of an active template, so that I can manage my recurring schedules without having to recreate them.

### Objectives

- Build the Recurring Templates List screen (`/settings/recurring`): two tabs (Recurring / Installments); within Recurring tab: three groups (Active, Paused, Archived)
- Each row shows title, badge, recurrence summary, next due date, and long-tap contextual menu (Edit, Delete, Pause, View child transactions)
- Build the Recurring Template Detail/Edit screen (`/settings/recurring/:id`): editable fields enabled, immutable fields read-only with tooltip; Save button disabled until dirty
- `UpdateRecurringTemplateUseCase`: write only editable fields; reject writes to immutable fields at the application layer
- Template delete: cancel all future `scheduled_occurrences` (status = `cancelled`); soft-delete `recurring_templates` row; hide from list
- Child transaction edit/delete marks the corresponding `scheduled_occurrences` row `status = 'skipped'`

### Definition of Done

- List screen shows correct grouping (Active / Paused / Archived) for all template states
- Long-tap menu items are present and functional for each state
- Detail/Edit screen: editable fields are writable; immutable fields are read-only with tooltip copy from §9.14.2
- Save writes only editable columns; any attempt to write an immutable column is rejected (no DB update issued)
- Template delete sets `is_deleted = 1` and cancels all future occurrences
- Golden tests cover list (populated state) and edit screen (loaded + dirty states)

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `RECUR-02 — Recurring Template Editing + Child Transaction Handling` (`docs/02-technical/feature-dag.md`)
- `9.13 Screen: Recurring Templates List` (`docs/02-technical/ux-flows.md`)
- `9.14 Screen: Recurring Template Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `9.14.2 Immutable Fields` (`docs/02-technical/ux-flows.md`)
- `9.14.3 Editable Fields` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## S-44 — Recurring Template Pause/Unpause

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want to pause a recurring template for a defined duration so that no transactions are posted while I am away, and they resume automatically when the pause period ends.

### Objectives

- Pause dialog: two modes — N units of the template's recurrence unit, or custom date/time; open-ended pause not allowed
- On confirm: set `status = 'paused'`, write `pause_until` epoch; mark all `scheduled_occurrences` rows with `scheduled_date` inside the pause window as `status = 'skipped'`
- SCHED-01 sweep skips templates where `status = 'paused'` and `pause_until > now`
- On sweep when `pause_until <= now`: auto-resume by setting `status = 'active'`, clearing `pause_until`; skipped occurrences are NOT retroactively posted
- Manual unpause (from list/detail long-tap): set `status = 'active'`, clear `pause_until`; resume from next scheduled occurrence after current date

### Definition of Done

- Pause dialog validates: N > 0 for unit mode; custom date must be in the future; no open-ended pause option exists
- Pausing writes `status = 'paused'` + `pause_until`; all in-window occurrences are set to `skipped`
- Sweep correctly skips paused templates; auto-resumes when `pause_until <= now`
- Skipped occurrences remain skipped after resume (no backfill)
- Manual unpause sets `status = 'active'` and clears `pause_until`
- Unit tests cover pause, auto-resume, and skip-no-backfill invariants

### References

- `RECUR-03 — Recurring Template Pause/Unpause` (`docs/02-technical/feature-dag.md`)
- `9.14.4 Pause Flow` (`docs/02-technical/ux-flows.md`)
- `9.14.5 Next Due Date Display` (`docs/02-technical/ux-flows.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.2 IScheduledOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## S-45 — Remind-and-Confirm: Exact Alarm Notification + Confirm/Edit/Dismiss Actions

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want to receive an exact-alarm notification when a recurring transaction is due for confirmation, so that I can review and approve, edit, or dismiss each occurrence before it is posted.

### Objectives

- Implement `ReminderAlarmScheduler`: schedule one `flutter_local_notifications` exact alarm per pending `remind_and_confirm` occurrence using `AndroidScheduleMode.exactAllowWhileIdle`
- Notification payload: template name, date, amount, account, category; action buttons: Confirm / Edit / Dismiss
- Confirm action: call `PostDueOccurrencesUseCase` for that occurrence; mark `status = 'posted'`
- Dismiss action: show confirmation dialog ("Skip this occurrence? It will not be posted."); on confirm → `SkipOccurrenceUseCase`; mark `status = 'skipped'`
- Edit action: deep-link to the transaction entry screen pre-filled with template defaults
- 24-hour auto-post: occurrences with no interaction after 24 hours are auto-approved on next app launch sweep
- Home screen Alerts Strip shows pending confirmations (§6.5); dismissal from strip follows same Dismiss semantics

### Definition of Done

- Exact alarm fires at the scheduled time for every `remind_and_confirm` occurrence
- Confirm, Edit, and Dismiss actions work from both the notification and the Alerts Strip
- 24-hour auto-post is applied on next launch sweep for unconfirmed occurrences
- Dismiss shows confirmation dialog; confirmed dismiss marks occurrence as `skipped`, does not post
- `ReminderAlarmScheduler` unit tests (mocked `flutter_local_notifications`) cover schedule, cancel, and reschedule paths
- Alerts Strip golden test covers pending-confirmation state

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `2.6 Scheduling` (`docs/02-technical/sds.md`)
- `1.6.8 Scheduling Architecture` (`docs/02-technical/sds.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## S-46 — Runtime Permission Handling for Scheduling

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want the app to request only the scheduling permissions I need and gracefully degrade when I deny them, so that core functionality is never blocked by permission decisions.

### Objectives

- Declare `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, and `POST_NOTIFICATIONS` in `AndroidManifest.xml`
- Request `SCHEDULE_EXACT_ALARM` (Android 12+ / API 31+) at runtime when a `remind_and_confirm` template is first created or when the user switches a template's posting behaviour to `remind_and_confirm`
- Request `POST_NOTIFICATIONS` (Android 13+ / API 33+) at the same time
- Graceful degradation on `SCHEDULE_EXACT_ALARM` denial: `remind_and_confirm` templates fall back to app-launch auto-posting; Settings screen displays a persistent notice explaining the degradation
- Graceful degradation on `POST_NOTIFICATIONS` denial: occurrence still auto-posts at launch after 24 hours; only the notification delivery is lost

### Definition of Done

- All three permissions declared in manifest
- `SCHEDULE_EXACT_ALARM` runtime request fires when a `remind_and_confirm` template is created or posting behaviour is changed to `remind_and_confirm`
- Denial of `SCHEDULE_EXACT_ALARM` triggers fallback: no alarm scheduled; settings notice displayed
- Denial of `POST_NOTIFICATIONS` does not block auto-posting; no crash
- Unit tests cover the permission-denied code path for both graceful-degradation cases

### References

- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `1.6.8 Scheduling Architecture` (`docs/02-technical/sds.md`)

---

## S-47 — Stacked Missed Occurrences: Auto-Approval + Summary Notification

**Parent Epic:** E-6 — Recurring & Scheduling Domain

**Story:** As a user, I want all missed remind-and-confirm occurrences to be auto-approved and posted in chronological order on my next launch, with a summary notification, so that my ledger stays up to date even when I have been away.

### Objectives

- During the app-launch sweep: identify all `remind_and_confirm` occurrences with `status = 'pending'` and `scheduled_date < now - 24h`
- Post them in ascending `scheduled_date` order using original scheduled dates; suppress duplicate-detection and overdraft warnings for auto-approved occurrences
- Fire one summary notification after posting: "[N] recurring transactions were auto-posted while you were away."
- Show the Recurring Catch-Up Banner on the Home screen (§6.6): "[N] recurring transactions were auto-posted while you were away." with a "View details" CTA that filters the transaction list to those transactions
- If N = 0, banner is not shown and summary notification is not sent

### Definition of Done

- Sweep identifies all overdue `remind_and_confirm` pending occurrences (past 24-hour window)
- Occurrences are posted in strict chronological order with original scheduled dates
- Duplicate-detection and overdraft warnings are suppressed for auto-approved occurrences
- Summary notification is sent exactly once per launch sweep that auto-approves ≥ 1 occurrence
- Catch-Up Banner appears on Home screen when N ≥ 1; is absent when N = 0
- "View details" CTA correctly filters the transaction list to the auto-posted transactions
- Integration test: advance clock past 24-hour window; launch app; verify N postings and banner

### References

- `RECUR-01 — Recurring Transaction Templates` (`docs/02-technical/feature-dag.md`)
- `SCHED-02 — Remind-and-Confirm Exact Alarm + Notifications` (`docs/02-technical/feature-dag.md`)
- `6.6 Recurring Catch-Up Banner` (`docs/02-technical/ux-flows.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `2.6.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## S-48 — Installment Template Schema and DAOs

**Parent Epic:** E-7 — Installments Domain

**Story:** As a developer, I want the database schema, Drift table definitions, and DAO methods for installment plans and occurrences wired up, so that all higher layers have a persistence foundation to build on.

### Objectives

- Define Drift table classes for `installment_plans` and `installment_occurrences` in `app_database.dart`
- Implement `InstallmentPlanDao` with CRUD + watch methods
- Implement `InstallmentOccurrenceDao` with watch-by-plan, status update, and bulk-insert methods
- Enforce FK cascade from `recurring_templates` → `installment_plans` → `installment_occurrences`
- Add required indexes: `idx_inst_occ_template_seq` (unique) and `idx_inst_occ_status_date`
- Write a Drift migration step (schema version bump) that creates both tables

### Definition of Done

- `installment_plans` and `installment_occurrences` tables created in schema migration; `flutter test` passes with in-memory Drift DB
- FK constraint `ON DELETE CASCADE` propagates deletion from `recurring_templates` through both tables
- `InstallmentPlanDao.watchAll()` and `watchById()` emit correct streams
- `InstallmentOccurrenceDao.watchByPlan()` returns rows ordered by `sequence_number`
- Unique index on `(template_id, sequence_number)` rejects duplicate sequence numbers at DB level
- Migration JSON schema dump committed under `lib/data/database/schema/`

### References

- `8. Installments` (`docs/02-technical/data-model.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `2.3 Database and Persistence` (`docs/02-technical/sds.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## S-49 — Installment Domain Entities and Repository Interfaces

**Parent Epic:** E-7 — Installments Domain

**Story:** As a developer, I want immutable domain entities for `InstallmentPlan` and `InstallmentOccurrence`, and repository interfaces with all required operations, so that use cases and the presentation layer have a type-safe, Flutter-free domain model.

### Objectives

- Define `InstallmentPlan` and `InstallmentOccurrence` as `@freezed` entities in `domain/entities/`
- Define `IInstallmentPlanRepository` with `watchAll()`, `watchById()`, `create()`, `update()`, and `closeEarly()` methods
- Define `IInstallmentOccurrenceRepository` with `watchByPlan()` and `markPosted()` methods
- Implement `InstallmentPlanRepositoryImpl` and `InstallmentOccurrenceRepositoryImpl` in the data layer, delegating to DAOs
- Define DTOs (`InstallmentPlanDto`, `InstallmentOccurrenceDto`) with `fromRow` / `toEntity` conversions

### Definition of Done

- `InstallmentPlan` and `InstallmentOccurrence` entities compile with zero Flutter imports; `==` and `copyWith` generated by Freezed
- Repository interfaces match the signatures in `2.7 Installments` API contracts doc
- Repository implementations pass unit tests against an in-memory Drift DB (`NativeDatabase.memory()`)
- All repository methods return `Result<T>` (never throw across layer boundary)

### References

- `2.7 Installments` (`docs/02-technical/api-contracts.md`)
- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)
- `2.7.2 IInstallmentOccurrenceRepository` (`docs/02-technical/api-contracts.md`)
- `2.5 Data Modeling and Serialization` (`docs/02-technical/sds.md`)
- `1.5.3 Domain Boundary Rules` (`docs/02-technical/sds.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## S-50 — Create Installment Template Use Case

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want to create an installment plan (fixed total divided into eager occurrences) for any transaction type, so that I can track a series of payments against a target total.

### Objectives

- Implement `CreateInstallmentPlanUseCase` that, in a single atomic transaction:
  - Writes a `recurring_templates` row (`is_installment = 1`)
  - Writes an `installment_plans` row with `total_configured_minor`
  - Eagerly materialises all `installment_occurrences` rows (`sequence_number` 1…N, `scheduled_date` computed per period, `amount_minor` = `total_configured / N`)
  - Computes and stores `end_date = start_date + (N × recurrence_period)` as a read-only field
- Validate: `total_configured > 0`, `number_of_installments > 0`, `start_date` present
- Support all three transaction types: income, expense, transfer (with optional fee)
- Enforce `total_configured` immutability — no update path outside `closeEarly()`

### Definition of Done

- Use case creates all three rows atomically; rollback on any partial failure
- End date matches `start_date + (N × recurrence_period)` for day/week/month/year units
- Per-installment `amount_minor` = `floor(total_configured_minor / N)` for all occurrences (remainder handling documented)
- Transfer-type installments populate `account_source_id`, `account_destination_id`, and optional fee columns on the template
- Unit tests cover: income, expense, transfer, transfer-with-fee; mismatched per-installment sums (save succeeds); zero count (validation failure); zero total (validation failure)

### Notes

- Eager materialisation differs from recurring 90-day lookahead: all occurrences are written immediately at creation time
- `total_configured` immutability is enforced at application layer; no DB constraint

### References

- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)
- `2.7.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)

---

## S-51 — Installment Tracking Amount Queries

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want to see four live tracking amounts for any installment plan (target total, paid to date, remaining, projected total), so that I always know how the series is progressing.

### Objectives

- Implement query methods on `InstallmentOccurrenceDao` (or a dedicated query service) to compute at query time:
  - `running_total` = `SUM(amount_minor) WHERE status='posted'` joined to exclude voided transactions (`transactions.is_deleted = 0`)
  - `total_remaining` = `SUM(amount_minor) WHERE status='pending'`
  - `projected_final_total` = `running_total + total_remaining`
  - `total_configured` = read from `installment_plans.total_configured_minor`
- Expose as a reactive `Stream<InstallmentTrackingAmounts>` consumed by the `InstallmentPlanDetailNotifier`
- Correctly handle: no postings yet, partial postings, voided child transactions, corrected child transactions (reflect corrected amount)

### Definition of Done

- All four amounts computed from `installment_occurrences` + joined `transactions` — no stored computed columns
- `running_total` excludes voided transactions (`is_deleted = 1` on the child transaction)
- `running_total` uses corrected transaction amount when a correction chain exists
- Mismatch flag (`projected_final_total ≠ total_configured`) returned as part of the tracking model
- Unit tests cover: zero-posted state, partial-posted, all-posted, voided-child, corrected-child

### References

- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `2.7.4 Notifiers` (`docs/02-technical/api-contracts.md`)
- `9.16.2 Summary Card (4 Tracked Amounts)` (`docs/02-technical/ux-flows.md`)

---

## S-52 — Create Installment Plan Screen (UI)

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want a full-screen modal to create a new installment plan with all required fields, so that I can set up a payment series in one guided flow.

### Objectives

- Build `CreateInstallmentScreen` at route `/transaction/new` (type = installment template), extending the recurring template form (§6.3 in UI spec)
- Add installment-specific fields: Total amount (required, immutable-after-save badge), Number of installments (required), Per-installment amounts (auto-calculated, overridable), End date (computed read-only)
- Show mismatch warning card (non-blocking) when projected total ≠ total configured
- Support all three transaction types; expose transfer source/destination and fee panel when type = transfer
- Wire to `CreateInstallmentPlanUseCase`; show loading state while saving; dismiss modal and show snackbar on success

### Definition of Done

- End date field auto-updates reactively when start date or number of installments changes
- Per-installment auto-calculation fires on total amount or count change
- Mismatch warning card is visible but Save button remains enabled when totals diverge
- Transfer type exposes account picker fields; fee panel appears when fee mode selected
- Golden tests pass for: empty state, filled state, mismatch state, saving state
- Widget test confirms `CreateInstallmentPlanUseCase` is called with correct arguments on tap Save

### References

- `6.4 Create Installment Screen` (`docs/02-technical/ui-spec.md`)
- `6.4.1 Components — Additional (beyond §6.3.1)` (`docs/02-technical/ui-spec.md`)
- `6.4.2 States` (`docs/02-technical/ui-spec.md`)
- `7.4 Create Installment Transaction Screen` (`docs/02-technical/ux-flows.md`)
- `7.17 Flow — Create Installment (additional steps after §7.16 steps 1–2)` (`docs/02-technical/ux-flows.md`)
- `5.1 Template Creation` (`docs/01-product/input-fields.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## S-53 — Installment Plan Detail / Edit Screen (UI)

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want a detail screen for each installment plan showing the 4 tracked amounts and a per-installment list with inline editing, so that I can monitor and manage the series over time.

### Objectives

- Build `InstallmentPlanDetailScreen` at route `/settings/installments/:id`
- Render summary card with 4-cell 2×2 grid: Target total / Paid to date / Remaining / Projected total
- Render mismatch warning banner when `projected_final_total ≠ total_configured` (non-blocking, inline)
- Render per-installment list with columns: #, scheduled date, amount, status badge
- Allow inline amount editing for unposted installment rows (tap to edit)
- Allow swipe-delete on unposted rows
- Provide FAB "Add installment" that appends a new occurrence with computed date and auto-filled amount
- Save button in AppBar enabled only when dirty; persists edits via repository

### Definition of Done

- Summary card shows all four tracking amounts reactively (stream-driven)
- Mismatch banner appears/disappears correctly when amounts are adjusted
- Inline amount edit on unposted row updates `installment_occurrences.amount_minor`; posted rows are read-only
- Swipe-delete removes unposted row and updates tracking amounts live
- FAB adds new occurrence with correct `sequence_number` and `scheduled_date`
- Golden tests pass for: loading, loaded, dirty-with-mismatch, dirty-without-mismatch states

### References

- `9.16 Screen: Installment Plan Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `9.16.2 Summary Card (4 Tracked Amounts)` (`docs/02-technical/ux-flows.md`)
- `9.16.3 Per-Installment List` (`docs/02-technical/ux-flows.md`)
- `9.16.4 Add / Remove Installments` (`docs/02-technical/ux-flows.md`)
- `9.16 Installment Plan Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.16.1 Components` (`docs/02-technical/ui-spec.md`)
- `INST-02 — Installment Running Total Tracking` (`docs/02-technical/feature-dag.md`)

---

## S-54 — Installment Plans List Screen (UI)

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want to see all my installment plans listed in the Installments tab of the Recurring & Installments settings screen, so that I can navigate to any plan and take contextual actions.

### Objectives

- Wire the Installments tab in `RecurringTemplatesListScreen` (route `/settings/recurring`) to show only `is_installment = 1` templates grouped as Active / Paused / Archived
- Render `InstallmentTemplateRow` with: title, `LinearProgressIndicator` (paid/total count), "₹X paid of ₹Y" running total label
- Implement long-press contextual menu: Edit / Delete / Pause / Unpause / View child transactions / View progress / Mark series as complete
- "Mark series as complete" entry point triggers the early-close flow (S-55)

### Definition of Done

- Installments tab populated from `InstallmentPlanListNotifier` stream
- Row progress bar value = (posted occurrence count) / (total occurrence count)
- Running total label reads from live tracking amount query (not stale value)
- Long-press menu items are conditionally shown based on template status (e.g., Pause hidden for Archived)
- Golden tests for: empty, populated (active + paused + archived groups), loading, error states

### References

- `9.15 Screen: Installment Plans List` (`docs/02-technical/ux-flows.md`)
- `9.13.3 Template Row (Installment)` (`docs/02-technical/ux-flows.md`)
- `9.13 Screen: Recurring Templates List` (`docs/02-technical/ux-flows.md`)
- `9.15 Installment Plans List` (`docs/02-technical/ui-spec.md`)
- `9.13 Recurring Templates List` (`docs/02-technical/ui-spec.md`)
- `9.13.3 Installment Template Row` (`docs/02-technical/ui-spec.md`)
- `INST-01 — Installment Template` (`docs/02-technical/feature-dag.md`)

---

## S-55 — Installment Early Close Flow

**Parent Epic:** E-7 — Installments Domain

**Story:** As a user, I want to close an installment series early via "Mark series as complete", with the option to record a final payment, so that I can cleanly terminate a partially-completed installment plan.

### Objectives

- Implement `CloseInstallmentPlanUseCase` that:
  - Accepts optional final-payment transaction data
  - Posts the final payment as a child transaction (linked to plan) if provided
  - Sets all pending `installment_occurrences.status` = `'cancelled'`
  - Sets `recurring_templates.status` = `'archived'`, `archived_reason` = `'early_close'`
  - Optionally updates `installment_plans.total_configured_minor` = `running_total` (guarded via `updateTotalOnEarlyClose()`)
- Build the early-close UI flow: final payment dialog → (optional) pre-filled transaction entry → target mismatch dialog
- Both mismatch resolution paths (Update target / Keep original) must reach archived state

### Definition of Done

- Final payment transaction is posted and linked (`parent_template_id` set) before remaining occurrences are cancelled
- All pending occurrences transition to `cancelled` in same DB transaction as template archival
- `updateTotalOnEarlyClose()` is the only code path that writes `total_configured_minor` post-creation
- Mismatch dialog fires only when `running_total ≠ total_configured` after close
- "Update target" path sets `total_configured_minor = running_total`; "Keep original" path archives with mismatch
- Unit tests cover: no-final-payment path, final-payment path, mismatch-update path, mismatch-keep path
- Integration test: full early-close flow end-to-end from contextual menu to archived template state

### Notes

- `archived` state is terminal — no reactivation path exists
- Final payment type matches the installment template type (expense/income/transfer)

### References

- `INST-03 — Installment Early Close` (`docs/02-technical/feature-dag.md`)
- `9.16.5 Early Close Flow` (`docs/02-technical/ux-flows.md`)
- `9.16.2 Early Close Flow Components` (`docs/02-technical/ui-spec.md`)
- `2.7.3 Use Cases` (`docs/02-technical/api-contracts.md`)
- `5.2 Installment Early Close (§5.2.8, FG-B7)` (`docs/01-product/input-fields.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `8.2 installment_occurrences` (`docs/02-technical/data-model.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)

---

## S-56 — Home Screen Dashboard Layout + Riverpod Wiring

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to see a greeting, net worth, and monthly income/expense/net summary on the home screen so that I have a real-time financial snapshot every time I open the app.

### Objectives

- Implement the `HomeScreen` widget using `CustomScrollView` + `SliverList` with a pinned month selector
- Render the greeting row (name-conditional text per `display_name` in `app_settings`)
- Render the 2×2 summary card grid: Net Worth, Income, Expenses, Net
- Implement `WatchNetWorthUseCase` as a `StreamProvider` that aggregates account balances in home currency excluding EQ accounts
- Implement `WatchMonthlySummaryUseCase` as a `StreamProvider` parameterised by `(year, month)`
- Wire `HomeNotifier` (Riverpod `AsyncNotifier<HomeState>`) to drive all home screen zones
- Implement month selector widget (left/right `IconButton` + month label) with reactive re-query on month change
- Handle Stale FX and No FX states with `MaterialBanner` and inline disclaimer respectively
- Implement loading skeleton, empty-month, error, and future-month screen states

### Definition of Done

- Greeting shows "Hi, [name]!" when `display_name` is set; "Hi!" otherwise
- Net worth reflects all `include_in_net_worth = true` non-deleted accounts in home currency; EQ accounts excluded
- Income, Expenses, Net cards update reactively when month selector changes
- Stale FX banner appears when `last_exchange_rate_fetch` is > 14 days old; dismisses for the session
- Loading skeleton renders 4 card placeholders and 6 row placeholders
- Empty month shows illustration + "No transactions this month" copy
- Future month shows projected label on summary cards; pending transactions only in list
- All states covered by widget tests

### References

- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)
- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)
- `6.2 Greeting` (`docs/02-technical/ux-flows.md`)
- `6.3 Financial Summary` (`docs/02-technical/ux-flows.md`)
- `6.4 Month Selector` (`docs/02-technical/ux-flows.md`)
- `5.1 Home Screen` (`docs/02-technical/ui-spec.md`)
- `2.10 Home / Dashboard` (`docs/02-technical/api-contracts.md`)
- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)

---

## S-57 — Home Screen Transaction List (Monthly View)

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to see my transactions grouped by date for the selected month so that I can review my spending at a glance and take quick actions on individual rows.

### Objectives

- Implement cursor-based paginated transaction list scoped to the selected month
- Render date-group headers as `SliverPersistentHeader`
- Implement the 3-column `ListTile` row: C1 category icon/name, C2 title/account, C3 amount with FX equivalent for foreign-currency accounts
- Apply Pending badge and muted styling for future-dated transactions
- Implement swipe-left (soft-delete) with confirmation dialog, undo snackbar, and swipe-right (navigate to edit)
- Implement long-press contextual `ModalBottomSheet` with Edit / Delete actions
- Apply exclusion rules: voided, superseded corrections, and invisible journal adjustments hidden from default list
- Implement loading, empty, error, filtered, search-active, and pending-month list states

### Definition of Done

- List renders using `SliverList.builder` with cursor-based pagination (page size 50); next page loads on scroll threshold
- Transactions grouped by calendar day, most-recent time first within group
- 3-column layout matches `§5.1.2` spec: C1 icon+name, C2 title+account, C3 amount+FX row
- Swipe-left opens delete dialog; snackbar with Undo appears after confirm; undo restores the transaction
- Swipe-right navigates to `/transaction/:id/edit`
- Long-press sheet shows Edit / Delete with correct navigation
- Voided, superseded, and invisible-adjustment rows are absent from the default list
- Pending rows show "Pending" badge with muted styling

### References

- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)
- `6.8 Transaction List (Home Screen — Monthly View)` (`docs/02-technical/ux-flows.md`)
- `6.8.1 List States` (`docs/02-technical/ux-flows.md`)
- `6.8.2 Row Layout (3-Column)` (`docs/02-technical/ux-flows.md`)
- `6.8.3 Grouping & Ordering` (`docs/02-technical/ux-flows.md`)
- `6.8.4 Excluded from Default List` (`docs/02-technical/ux-flows.md`)
- `6.8.5 Swipe Actions` (`docs/02-technical/ux-flows.md`)
- `6.8.6 Long-Press Contextual Menu` (`docs/02-technical/ux-flows.md`)
- `5.1.2 Transaction Row (3-Column ListTile)` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Reactive Read — Transaction List` (`docs/02-technical/sds.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## S-58 — Global FTS5 Search

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to search all my transactions globally by title, account, category, or description so that I can find any transaction quickly regardless of which month it occurred in.

### Objectives

- Implement the M3 `SearchBar` → `SearchView` expand animation overlay within the Home `ShellRoute`
- Implement two-stage search pipeline: FTS5 SQL query → Dart `SearchRanker` scoring pass
- Apply global scope (no date predicate) when search is active per TC-050 founder resolution
- Debounce search input at 300 ms; return results within 500 ms for 10,000 transactions
- Render results as date-grouped `SliverList` with matched text highlighted via `RichText`/`TextSpan`
- Support all 6 ranking tiers (exact title → prefix → substring → amount → category → description/date)
- Apply typo-tolerance (Levenshtein distance-1) in Dart on the FTS5 candidate set (max 500 rows)
- Clear search re-engages month filter; FAB hidden while search is active
- Handle idle, active-empty, typing, results, no-results, and dismissed states

### Definition of Done

- Tapping search icon expands `SearchBar` and suspends month scope
- FTS5 query returns candidate set; Dart `SearchRanker` re-ranks with field weights
- Results render within 500 ms for a 10,000-transaction dataset (widget/integration test with seeded data)
- Matched text highlighted in title and account name columns with `primary` bold `TextSpan`
- Clearing search collapses overlay and restores month-filtered list
- Typo test: "cofee" returns "coffee" transactions (edit distance 1)
- All 7 search entry states render correctly in widget tests

### References

- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)
- `7.8 Search Flow` (`docs/02-technical/ux-flows.md`)
- `7.8.1 Search Entry States` (`docs/02-technical/ux-flows.md`)
- `7.8.2 Search Flow — Step by Step` (`docs/02-technical/ux-flows.md`)
- `7.8.3 Search Ranking Rules` (`docs/02-technical/ux-flows.md`)
- `6.7 Search Overlay` (`docs/02-technical/ui-spec.md`)
- `6.7.1 Components` (`docs/02-technical/ui-spec.md`)
- `6.7.3 States` (`docs/02-technical/ui-spec.md`)
- `2.8 Search` (`docs/02-technical/sds.md`)
- `2.8.1 Decision — TC-009: SQLite FTS5 with Dart-Side Scoring` (`docs/02-technical/sds.md`)
- `2.8.2 FTS5 Schema` (`docs/02-technical/sds.md`)
- `2.8.3 Ranking Algorithm` (`docs/02-technical/sds.md`)
- `2.8.4 Search Scope` (`docs/02-technical/sds.md`)
- `10.1 transactions_fts` (`docs/02-technical/data-model.md`)
- `10.2 transactions_search_view` (`docs/02-technical/data-model.md`)

---

## S-59 — Multi-Facet Filter Sheet

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to filter my transaction list by type, category, account, date range, amount range, and boolean flags so that I can narrow down to exactly the transactions I care about.

### Objectives

- Implement `FilterBottomSheet` as a `DraggableScrollableSheet` (min 50%, max 95% screen height)
- Implement all 11 filter criteria: type multi-select, category/subcategory pickers, account picker, date range (presets + custom `DateRangePicker`), amount min/max, and boolean toggles (has photo, has title, has description, is recurring, is voided)
- Implement sort controls: Date (desc/asc) and Amount (desc/asc) as `SegmentedButton` rows
- Auto-deselect categories when the associated type filter is removed
- Display live match count ("X matching transactions") above the Apply button
- Render the active filter chip strip (`InputChip` row) above the transaction list after Apply; each chip dismissible
- Filter applies on top of month-filtered list when search inactive; on top of global search results when search active
- Filters do not persist across navigation

### Definition of Done

- Sheet opens from home screen filter icon and from search overlay filter icon
- All 11 criteria inputs render and capture state correctly
- Category picker is dynamically scoped by selected type (income-only/expense-only/both/none)
- Date preset chips ("This month", "Last 7 days", "Last 30 days", "Custom") apply correct date bounds
- Match count updates live as criteria change
- Apply dismisses sheet; chip strip renders with one chip per active criterion
- Dismissing a chip removes that criterion; list updates immediately
- "Clear all" chip removes all filters; chip strip hides
- 0-results state shows "No transactions match your filters." + "Clear filters" CTA
- Reset button clears all criteria without dismissing the sheet

### References

- `HOME-02 — Home Screen Search + Filter` (`docs/02-technical/feature-dag.md`)
- `7.7 Filter Sheet` (`docs/02-technical/ux-flows.md`)
- `7.7.1 Sheet States` (`docs/02-technical/ux-flows.md`)
- `7.7.2 Filter Criteria` (`docs/02-technical/ux-flows.md`)
- `7.7.3 Category Filter Interaction with Type Filter` (`docs/02-technical/ux-flows.md`)
- `7.7.4 Sort Controls (within filter sheet)` (`docs/02-technical/ux-flows.md`)
- `7.7.5 Filter → List Effect` (`docs/02-technical/ux-flows.md`)
- `6.6 Filter Bottom Sheet` (`docs/02-technical/ui-spec.md`)
- `6.6.1 Components` (`docs/02-technical/ui-spec.md`)
- `6.6.2 Active Filter Chip Strip (above list)` (`docs/02-technical/ui-spec.md`)
- `6.6.3 States` (`docs/02-technical/ui-spec.md`)

---

## S-60 — Quick-Entry FAB (SpeedDial)

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want a FAB on the home screen that opens the transaction entry form for Expense, Income, or Transfer so that I can add a new transaction in two taps.

### Objectives

- Implement the M3 SpeedDial `FloatingActionButton` with 3 actions: Expense / Income / Transfer
- Collapsed state: large FAB, `Icons.add`, `primaryContainer`
- Expanded state: scrim overlay + 3 `SmallFAB` actions stacked above anchor with labels
- Tapping an action navigates to `/transaction/new` with the appropriate type pre-selected
- When `back_button_behaviour = auto_save_draft`, the SpeedDial includes a Drafts entry point that navigates to the Drafts list
- FAB is visible only on the Home tab root route (`/`); hidden on sub-routes and while search is active
- Tapping scrim or FAB again collapses the SpeedDial

### Definition of Done

- SpeedDial renders on home root route; hidden on sub-routes and during active search
- Expense action: icon `Icons.arrow_upward`, `errorContainer` / `onErrorContainer`, navigates to `/transaction/new?type=expense`
- Income action: icon `Icons.arrow_downward`, `secondaryContainer` / `onSecondaryContainer`, navigates to `/transaction/new?type=income`
- Transfer action: icon `Icons.swap_horiz`, `tertiaryContainer` / `onTertiaryContainer`, navigates to `/transaction/new?type=transfer`
- Drafts entry point visible in SpeedDial when `back_button_behaviour = auto_save_draft`; navigates to Drafts list
- Tap scrim or FAB collapses SpeedDial; scrim overlay dismisses

### References

- `HOME-03 — Quick-Entry FAB` (`docs/02-technical/feature-dag.md`)
- `6.7 FAB Behaviour` (`docs/02-technical/ux-flows.md`)
- `5.1.3 SpeedDial Anatomy (M3)` (`docs/02-technical/ui-spec.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## S-61 — Alerts Section (Recurring + Credit Card)

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to see actionable alert cards for pending recurring confirmations and credit card payment due dates so that I can act on time-sensitive items without leaving the home screen.

### Objectives

- Implement the `AlertsStrip` widget rendered above the transaction list
- Render pending recurring confirmation cards: template name, date, amount, account, category with Confirm / Edit / Dismiss actions
- On Dismiss of a confirmation: show dialog "Skip this occurrence? It will not be posted." → Confirm / Cancel
- Render credit card payment due cards: card name, amount due, due date with "Open CC payment entry form" action
- Derive alert state at runtime from `scheduled_occurrences` (status = `pending`) and `accounts` (billing period + reminder)
- Apply display priority: pending confirmations → credit card due → backup reminder
- If pending confirmations > 3, show at most 3 cards + "View all" CTA navigating to the Pending Confirmations screen
- No separate `alerts` table; all state is derived at query time

### Definition of Done

- Pending confirmation cards render for each `scheduled_occurrences` row with `status = 'pending'` belonging to a "remind and confirm" template
- Confirm action posts the occurrence; Edit action navigates to edit form pre-filled; Dismiss shows confirmation dialog and skips the occurrence on confirm
- Credit card payment due cards render for accounts with an approaching billing due date
- Priority order is: recurring confirmations first, then credit card due
- "View all" CTA appears when > 3 pending confirmation items exist
- Alert cards render with `outlined` card variant, `bodySmall` content, `primary` action `TextButton` per UI spec
- Widget tests cover all card types and their action flows

### References

- `HOME-04 — Alerts Section` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## S-62 — Backup Reminder Alert

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want a one-time backup reminder alert after my first month of use or 50 transactions so that I am prompted to protect my data before losing it.

### Objectives

- Implement trigger evaluation on each home screen load: check `onboarding_complete` date (first 30 days) OR transaction count ≥ 50
- Read `backup_reminder_shown` flag from `app_settings`; skip rendering if flag is set
- Render backup reminder card in the `AlertsStrip` (lowest priority, below recurring + credit card alerts)
- Card action navigates to Settings > Data > Backup (`/settings/backup`); gracefully handles SET-07 not yet built
- On dismiss or on backup taken: write `backup_reminder_shown = 1` to `app_settings`; card never shown again

### Definition of Done

- Reminder card appears when: `(today - onboarding_complete_date) >= 30 days` OR `COUNT(transactions) >= 50` AND `backup_reminder_shown = 0`
- Reminder card does NOT appear if `backup_reminder_shown = 1`
- Tap "Navigate to Backup" navigates to `/settings/backup`; if route unavailable shows a "not yet available" placeholder
- Dismiss writes `backup_reminder_shown = 1`; card absent on all subsequent home loads
- Trigger check is idempotent — calling it N times does not flip the flag unless one condition is true and the card is acted upon
- Unit test verifies both trigger conditions independently and the flag-write-once guarantee

### References

- `HOME-05 — Backup Reminder Alert` (`docs/02-technical/feature-dag.md`)
- `6.5 Alerts Strip` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## S-63 — Recurring Catch-Up Banner

**Parent Epic:** E-8 — Home / Dashboard Domain

**Story:** As a user, I want to see a banner on the home screen when recurring transactions were auto-posted while I was away so that I am aware of automatic postings and can review them.

### Objectives

- Implement `GetCatchUpBannerUseCase` that returns the list of auto-approved missed recurring templates posted at app launch
- Render the catch-up banner (`FilledCard`, `surfaceContainerHigh`) at the top of the transaction list when ≥ 1 auto-posting occurred
- Banner copy: "[N] recurring transactions were auto-posted while you were away."
- "View details" CTA filters the transaction list to show only the auto-posted transactions
- Banner absent when no missed occurrences were processed at launch

### Definition of Done

- `GetCatchUpBannerUseCase` returns a non-empty list only when auto-postings occurred at the current launch session
- Banner renders above the transaction list when the use case returns ≥ 1 item
- Tap "View details" applies a filter scoping the list to those specific transaction IDs
- Banner absent when no auto-postings occurred
- Widget test: banner visible with correct count when use case returns items; absent when returns empty

### References

- `HOME-01 — Home Screen Dashboard` (`docs/02-technical/feature-dag.md`)
- `6.6 Recurring Catch-Up Banner` (`docs/02-technical/ux-flows.md`)
- `5.1.1 Components` (`docs/02-technical/ui-spec.md`)
- `2.10 Home / Dashboard` (`docs/02-technical/api-contracts.md`)
- `7.2 scheduled_occurrences` (`docs/02-technical/data-model.md`)

---

## S-64 — Settings Hub + Appearance

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want a Settings hub screen that lists all preference groups and lets me configure theme, color scheme, and animations, so that I can personalise the app's look and feel without restarting.

### Objectives

- Render the Settings hub (`/settings`) as a sectioned list of all group entries in the order specified by the UX spec
- Seed `app_settings` with default values on first launch; handle missing keys gracefully at every read site
- Implement the Appearance settings screen (`/settings/appearance`) with theme (Light/Dark/System), color scheme (Dynamic/Custom/Catppuccin), seed color picker, and animations toggle
- Wire `DynamicColorBuilder` for OEM runtime fallback; show inline note when dynamic color is unavailable
- Implement the Color Scheme Preview sub-screen (`/settings/appearance/preview`) rendering all Material 3 `ColorScheme` tokens
- Register `AppSettingsNotifier` (watches `app_settings` stream) and wire through `IAppSettingsRepository.update(patch)`
- All appearance changes persist to `app_settings` and apply to the running theme immediately without restart

### Notes

- SET-01 is a hard prerequisite for every other SET node; must ship before any other settings story
- INFRA-5 must initialise with defaults before first paint to avoid circular init risk
- Catppuccin flavour auto-bound in v1: Light→Latte, Dark→Mocha; no user selector

### Definition of Done

- Hub screen renders all 15 section entries in spec order; tapping each navigates to its route
- Missing `app_settings` keys fall back to code-defined defaults without crash or empty UI
- Theme, color scheme, seed color, and animations changes write to `app_settings` and reflect in the UI on the same frame
- `DynamicColorBuilder` unavailability shows the fallback inline note and switches mode to Custom
- Color Scheme Preview screen renders all M3 token swatches labelled with role names
- Widget tests cover hub render, appearance screen controls, and dynamic color fallback
- Golden tests cover the hub screen loaded state and appearance screen loaded state

### References

- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)
- `4.8 Settings Domain` (`docs/02-technical/feature-dag.md`)
- `9.1 Screen: Settings Hub` (`docs/02-technical/ux-flows.md`)
- `9.2 Screen: Appearance Settings` (`docs/02-technical/ux-flows.md`)
- `9.1 Settings Hub` (`docs/02-technical/ui-spec.md`)
- `9.2 Appearance Settings` (`docs/02-technical/ui-spec.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.9 App Settings & Drafts` (`docs/02-technical/api-contracts.md`)

---

## S-65 — Locale & Format Settings

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to configure home currency, number formatting, date and time preferences, and percentage precision, so that all amounts and dates display in my preferred regional format.

### Objectives

- Implement the Locale & Format settings screen (`/settings/locale`)
- Home currency picker backed by the bundled ISO 4217 currency list (from CURR-01); writes to `app_settings.home_currency`
- Decimal separator, thousands grouping (including Indian 2-2-3 lakh/crore), currency symbol placement and spacing fields
- Week start day, time format (12h/24h), and percentage decimal precision fields
- All changes write to `app_settings` locale keys and re-render displayed amounts/dates app-wide immediately (display-only; no data migration)
- Home currency change does NOT rewrite existing `exchange_rate_to_home` values; takes effect on next new account creation form open

### Notes

- Depends on CURR-01 for the ISO 4217 currency list in the home currency picker
- Indian grouping default inferred from device locale at first launch
- No warning dialog on home currency change (TC-029 founder resolution)

### Definition of Done

- All locale fields render pre-filled with current `app_settings` values
- Saving any field writes the correct key to `app_settings` and re-renders all amount displays app-wide
- Home currency change does not trigger any migration or data rewrite; new account creation form picks up new default
- Indian grouping (`number_thousands_grouping = indian`) formats amounts as 2-2-3 groups (e.g. ₹10,00,000)
- Widget tests cover each field save path and amount re-render

### References

- `SET-02 — Locale + Format Settings` (`docs/02-technical/feature-dag.md`)
- `9.3 Screen: Locale & Format Settings` (`docs/02-technical/ux-flows.md`)
- `9.3 Locale & Format Settings` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `2.9 App Settings & Drafts` (`docs/02-technical/api-contracts.md`)

---

## S-66 — Transaction Entry Settings + Draft Lifecycle

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to configure description max length and the back-button behaviour for the transaction entry form, and have the 5-slot FIFO draft lifecycle work when auto-save is active, so that partially entered transactions are not accidentally lost.

### Objectives

- Implement the Transaction Entry settings screen (`/settings/transaction-entry`)
- Description max length field (integer); enforced at entry time only; does not truncate existing descriptions
- Back-button behaviour selector: Ask / Auto-save draft / Discard immediately
- When `auto_save_draft` is active: on back press write to `drafts` table; enforce 5-slot FIFO cap; show toast "Oldest draft was removed to make room." on overflow
- `payload_json` in `drafts` must include a schema version field for stale-draft detection
- Display draft lifecycle info card in the Transaction Entry settings screen

### Notes

- Draft FIFO enforcement and toast belong in the transaction entry form logic, not in settings; this story covers the settings screen plus the FIFO enforcement wiring
- Duplicate detection (TXN-06) is always-on; not a toggle here

### Definition of Done

- Settings screen saves `back_button_behaviour` and `description_max_length` to `app_settings`
- Back-button behaviour on the transaction form matches the configured mode in all three paths
- With `auto_save_draft`: draft table never exceeds 5 rows; FIFO eviction fires the correct toast
- `payload_json` for new drafts includes a `schema_version` field
- Stale draft (old schema version) is detected and discarded without crash
- Unit tests for FIFO eviction logic; widget tests for settings screen fields

### References

- `SET-03 — Transaction Entry Settings` (`docs/02-technical/feature-dag.md`)
- `9.4 Screen: Transaction Entry Settings` (`docs/02-technical/ux-flows.md`)
- `9.4 Transaction Entry Settings` (`docs/02-technical/ui-spec.md`)
- `1.9 Draft Auto-save` (`docs/02-technical/ux-flows.md`)
- `8.9 Draft Auto-Save Indicator` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `9.2 drafts` (`docs/02-technical/data-model.md`)
- `2.9 App Settings & Drafts` (`docs/02-technical/api-contracts.md`)

---

## S-67 — Warnings & Limits Settings

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to set per-account and per-category large-transaction thresholds, so that I am warned during entry when a transaction amount exceeds my configured limit.

### Objectives

- Implement the Warnings & Limits screen (`/settings/warnings`) as an entry point to two sub-screens
- Per-Account Limits sub-screen: list all accounts; inline threshold field per row; stored on `accounts.large_txn_threshold` in the account's native currency
- Per-Category Limits sub-screen: list all expense/income categories; inline threshold field per row; stored on `categories.large_txn_threshold` in home currency
- When both thresholds are exceeded for the same transaction, account threshold takes precedence (shown; category suppressed)
- Overdraft and credit-limit warnings are always-on and NOT configurable here

### Notes

- Threshold storage is on `accounts` and `categories` tables, not on `app_settings`
- This screen is a configuration surface only; the warning firing logic lives in TXN-07

### Definition of Done

- Per-account threshold saves to `accounts.large_txn_threshold`; per-category saves to `categories.large_txn_threshold`
- Both sub-screens list all relevant entities with correct currency labelling
- TXN-07 correctly reads thresholds at entry time (verified by integration test)
- Account threshold takes precedence when both are exceeded on the same transaction
- Widget tests for both sub-screen list renders and inline field save

### References

- `SET-04 — Warnings + Limits Settings` (`docs/02-technical/feature-dag.md`)
- `9.5 Screen: Warnings & Limits` (`docs/02-technical/ux-flows.md`)
- `9.5 Warnings & Limits` (`docs/02-technical/ui-spec.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)

---

## S-68 — Profile Settings

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to set an optional display name used in the home screen greeting, so that the app feels personalised to me.

### Objectives

- Implement the Profile settings screen (`/settings/profile`)
- Single text field for `display_name`; optional (empty → greeting shows "Hi!" with no name)
- Writes to `app_settings.display_name`; `AppSettingsNotifier` propagates change to home screen greeting immediately

### Definition of Done

- Display name field saves to `app_settings.display_name`
- Home screen greeting reactively shows "Hi, [name]!" when non-empty; "Hi!" when empty
- Widget test covers empty and non-empty display name paths

### References

- `SET-05 — Profile Settings (Display Name)` (`docs/02-technical/feature-dag.md`)
- `9.6 Screen: Profile Settings` (`docs/02-technical/ux-flows.md`)
- `9.6 Profile Settings` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## S-69 — Security Settings (Lock Timeout + PIN)

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to configure a lock timeout for sensitive account detail fields and manage an in-app PIN fallback, so that card and bank account numbers are protected even if I leave the app briefly.

### Objectives

- Implement the Security settings screen (`/settings/security`) with lock timeout selector; writes to `app_settings.lock_timeout_seconds`
- Lock applies only to `account_details` sensitive columns — never gates core navigation (GoRouter guards must not redirect other routes)
- Implement PIN Setup screen (mode=set, mode=change) and PIN Entry overlay; hierarchical lock mechanism: (1) Android Keyguard via `local_auth`, (2) device per-app lock, (3) in-app PIN
- Prompt in-app PIN setup on first access to sensitive fields when no device security is configured
- PIN recovery flow: deep-link to Android security settings if device security is absent
- Failed PIN wipe: after 15 consecutive failures, wipe only encrypted rows in `account_details`; never transactions, entries, or accounts
- Resolve OQ-SDS-SC-001 before shipping: ensure `flutter_secure_storage` data is excluded from Android backups

### Notes

- Lock scope is `account_details` sensitive fields only (SDS §1.6.12) — not whole-app
- OQ-SDS-SC-001 (secure storage backup exclusion) must be resolved before this story ships

### Definition of Done

- Lock timeout saves to `app_settings.lock_timeout_seconds`; sensitive fields lock after the configured idle period
- Keyguard authentication succeeds on devices with biometrics/device PIN; falls back to in-app PIN when absent
- PIN set/change/reset flows complete without error on all three lock mechanism levels
- 15 consecutive PIN failures wipe only `account_details` encrypted rows; no other tables affected
- GoRouter guards do not redirect any route except sensitive field display
- OQ-SDS-SC-001 is resolved and documented
- Widget tests for PIN setup states and lockout counter

### References

- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)
- `5. App Lock & Security Flows` (`docs/02-technical/ux-flows.md`)
- `4. App Lock & Security Screens` (`docs/02-technical/ui-spec.md`)
- `9.7 Security Settings` (`docs/02-technical/ui-spec.md`)
- `1.6.12 Security Lock Scope — Sensitive Fields Only` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)

---

## S-70 — Data Backup (Export ZIP via SAF)

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want to manually trigger a local data backup that exports a versioned ZIP archive to a destination I choose, so that I have an offline copy of all my financial data and attached photos.

### Objectives

- Implement the Backup & Data screen (`/settings/backup`) with a "Backup now" action and last backup timestamp display
- Launch Android SAF file-picker for destination selection; write `variance_backup_YYYYMMDD_HHmmss.zip`; fall back to `Downloads` if SAF is unavailable
- ZIP contents: `manifest.json` (`backup_format_version: 1`, `app_version`, `created_at` ISO 8601 UTC, `schema_version`) + `variance_export.json` (all non-deleted entities) + attached photos from `attachments` table
- Execute backup inside a Drift read-only snapshot (database transaction) in a background isolate to avoid blocking WAL
- Skip missing/deleted photo files with a logged warning; do not fail the export
- After successful export, write `last_backup_at` (unix epoch) to `app_settings`
- v1 is export-only; no import/restore UI

### Notes

- HOME-05 reads `last_backup_at` to clear its backup reminder; this story is the write side
- Soft-deleted entities excluded from export

### Definition of Done

- ZIP is written to the selected SAF destination with correct filename
- `manifest.json` and `variance_export.json` are present and valid in the archive
- All non-deleted entities are serialised; soft-deleted entities are absent
- Attached photos are included; missing photo files are skipped with a log warning (no crash)
- `last_backup_at` in `app_settings` is updated after successful export
- Export runs in a background isolate; UI remains responsive
- Unit tests for manifest generation and entity serialisation; integration test for full export flow

### References

- `SET-07 — Data Backup (Export ZIP)` (`docs/02-technical/feature-dag.md`)
- `2.17 Backup Format` (`docs/02-technical/sds.md`)
- `2.17.1 Decision — TC-054: Versioned ZIP Archive with Manifest` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)

---

## S-71 — Account Management Access Screen

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want a Settings > Accounts screen that lists all active and soft-deleted accounts with disambiguation, so that I can initiate create, edit, reinstate, and soft-delete flows from one place.

### Objectives

- Implement the Account Management screen (`/settings/accounts`)
- List active accounts grouped by account category in fixed type order; alphabetical within group; section headers when multiple groups exist
- Show soft-deleted accounts in a separate section with a visual indicator and a "Reinstate" option
- Each row: account name (primary) + account category badge (secondary) + currency symbol if multi-currency
- Tapping an account navigates to the account detail screen (ACC-04); edit accessed via contextual menu or edit button within detail
- Create account action accessible from this screen (navigates to ACC-01 create form)

### Notes

- Access surface only; account CRUD logic lives in E-1 (ACC-01, ACC-11)
- Depends on ACC-01 (accounts must exist)

### Definition of Done

- All active accounts are listed, grouped by category in spec order, alphabetically within group
- Soft-deleted accounts appear in a separate section with reinstatement action
- Row layout matches spec: name + category badge + currency symbol
- Tapping an account navigates to account detail; create action navigates to account create form
- Widget tests cover loaded state (active + soft-deleted accounts), empty state, and grouping

### References

- `SET-08 — Account Management Screen` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `2.1 Accounts` (`docs/02-technical/api-contracts.md`)

---

## S-72 — Category Management Access Screen

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want a Settings > Categories screen showing the two-level income/expense category tree, so that I can create, rename, reorder, and soft-delete categories from one place.

### Objectives

- Implement the Category Management screen (`/settings/categories`)
- Render two-level tree: parent list with expandable children; `+` button at each level
- Protected BAI/BAE "Balance Adjustment" system categories are never shown
- Icon picker using the curated ~250-icon `material_symbols_icons` subset (TC-014)
- Before soft-deleting a category with assigned transactions or templates, trigger the migration dialog (CAT-03)
- Depends on CAT-01 (categories exist) and CAT-03 (soft-delete migration flow)

### Notes

- Access surface only; category CRUD logic lives in E-3 (CAT-01, CAT-03)
- Icon picker can be built against the placeholder set while curation runs in parallel (TC-014)

### Definition of Done

- Two-level tree renders correctly; tap parent to expand/collapse children; `+` at each level opens create form
- BAI/BAE categories are absent from the tree
- Icon picker shows the curated icon subset; selected icon persists on save
- Soft-delete with assigned items fires the CAT-03 migration dialog before proceeding
- Widget tests for tree render, empty state, BAI/BAE exclusion, and soft-delete guard

### References

- `SET-09 — Category Management Screen` (`docs/02-technical/feature-dag.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.4 Categories` (`docs/02-technical/api-contracts.md`)
- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)

---

## S-73 — Recurring & Installment Management Screen

**Parent Epic:** E-9 — Settings Domain

**Story:** As a user, I want a Settings > Recurring & Installments screen that lists all templates by state (active, paused, archived), so that I can review, pause, unpause, and archive them from one place.

### Objectives

- Implement the Recurring & Installments screen (`/settings/recurring`)
- List recurring templates grouped by state: active, paused, archived (soft-deleted)
- Per-template row: template name, recurrence summary, posting behaviour indicator
- Contextual menu or swipe actions for: pause, unpause, archive
- Tapping a template navigates to its edit/detail screen (RECUR-02 / RECUR-03)
- Installment plans listed in the same screen (separate section); depends on INST-01 (SOFT dependency)

### Notes

- Access surface only; CRUD logic lives in RECUR-01, RECUR-02, RECUR-03, INST-01, INST-03
- Archived = soft-deleted; archived templates show no action except restore
- INST-01 is a SOFT dependency; recurring templates section ships without it if needed

### Definition of Done

- Templates are listed in three state groups: active, paused, archived
- Pause, unpause, and archive actions are accessible and execute correctly
- Tapping a template navigates to its edit/detail screen
- Installment plans section renders when INST-01 is available
- Widget tests for loaded state (all three groups), empty state, and contextual actions

### References

- `SET-10 — Recurring + Installment Management Screen` (`docs/02-technical/feature-dag.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `2.6 Recurring & Scheduling` (`docs/02-technical/api-contracts.md`)
- `2.7 Installments` (`docs/02-technical/api-contracts.md`)

---

## S-74 — Onboarding Wizard Shell and Chrome

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want a full-screen wizard scaffold with step progress and navigation controls, so that I have a consistent container for all onboarding steps.

### Objectives

- Implement `OnboardingWizardScreen` as a full-screen `PageView` with 5 pages, no shell `NavigationBar`
- Render persistent chrome: `LinearProgressIndicator` (4 dp height, `primary` fill / `surfaceContainerHighest` track), full-width `FilledButton` CTA, and `Skip TextButton` top-right (hidden on Steps 1 and 5)
- Manage `PageController` state: advance on CTA tap, skip jumps to Step 5 (sets defaults first), Step 5 writes `onboarding_complete = 1` and calls `context.go('/')`
- Entry: slide-up from bottom. Exit: `context.go('/')` with no back stack
- All five step page widgets are wired into the `PageView` in order

### Definition of Done

- `OnboardingWizardScreen` renders at `/onboarding` with no shell bar
- `LinearProgressIndicator` advances correctly at each step (1/5 → 5/5)
- Skip button is hidden on Steps 1 and 5; visible and functional on Steps 2–4
- CTA label changes per step: "Get started", "Confirm", "Create account", "Done", "Start tracking"
- Step 5 auto-transitions to `/` within ≤ 1.5 s if CTA not tapped

### References

- `3. Onboarding & First Launch` (`docs/02-technical/ui-spec.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)
- `2.4 Navigation` (`docs/02-technical/sds.md`)

---

## S-75 — GoRouter Redirect Guard for Onboarding

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a returning user, I want the app to bypass the onboarding wizard after I have completed it, so that I land directly on the home screen on every subsequent launch.

### Objectives

- Add a GoRouter `redirect` callback that reads `onboarding_complete` from an `AppSettingsNotifier` Riverpod provider
- Guard fires synchronously using a cached in-memory value — no async DB read inside the redirect
- If `onboarding_complete == 0`, redirect any route to `/onboarding`
- If `onboarding_complete == 1`, allow route through unchanged
- `AppSettingsNotifier` is initialised at app startup (before the router is constructed) so the cached value is always present on first redirect evaluation

### Definition of Done

- Fresh install (no DB): all routes redirect to `/onboarding`
- After wizard completes (`onboarding_complete = 1`): cold-start routes to `/` without showing wizard
- Redirect does not cause an async gap or loading flash — guard reads from synchronous cached state
- Widget test confirms redirect fires for `/`, `/accounts`, and `/settings` when `onboarding_complete == 0`

### References

- `2.4.3 Navigation Rules` (`docs/02-technical/sds.md`)
- `2.4 Navigation` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)

---

## S-76 — Step 1: Welcome Screen

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want to see a welcome screen with the app name, tagline, and value proposition, so that I understand what Variance is before I start configuring it.

### Objectives

- Implement `OnboardingStep1Welcome` widget
- Display: app logo/wordmark (`primary`), app name headline (`displayLargeAmount`, 36 sp, `onSurface`), tagline (`bodyLarge`, 16 sp, `onSurfaceVariant`), 3 value prop bullets (`bodyMedium`, 14 sp, `onSurfaceVariant`)
- Skip button: hidden
- CTA label: "Get started" — advances `PageController` to Step 2

### Definition of Done

- Step 1 renders all required components with correct tokens
- No skip button visible
- "Get started" advances to Step 2
- Golden test captured for Step 1 loaded state

### References

- `3.3 Step 1 — Welcome` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)

---

## S-77 — Step 2: Currency Selection

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want to confirm or change my home currency using a locale-prefilled picker, so that the app is configured for my region without manual lookup.

### Objectives

- Implement `OnboardingStep2Currency` widget
- Detect locale on mount; map to ISO 4217 code; pre-populate `OutlinedTextField` — fallback to INR on any detection failure (silent, no error shown)
- Render: section heading (`sectionHeading`, 20 sp), detected currency display row, searchable `OutlinedTextField`, `ListView.builder` of ISO 4217 bundled currencies
- Loading state: `CircularProgressIndicator` (20 dp) inside field; CTA disabled until resolved
- "Confirm" writes selected currency to `app_settings.home_currency` via `AppSettingsNotifier`; advances to Step 3
- "Skip" writes locale-derived or INR fallback to `app_settings.home_currency`; advances to Step 3

### Definition of Done

- Currency field is pre-populated from locale on mount; INR used on fallback
- Loading state shows spinner and disables CTA
- "Confirm" writes `home_currency` to `app_settings` and advances to Step 3
- "Skip" writes default currency and advances to Step 3
- Search filters the `ListView.builder` by code and name
- Golden tests captured for: loading, nominal (currency pre-selected), and error/fallback states

### References

- `3.4 Step 2 — Currency Selection` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.16 Currency Bundle` (`docs/02-technical/sds.md`)

---

## S-78 — Step 3: Create First Account

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want to optionally create my first account during onboarding, so that I can start tracking expenses immediately without navigating to account settings.

### Objectives

- Implement `OnboardingStep3Account` widget with simplified form: account name (`OutlinedTextField`, required), account category (`ExposedDropdownMenu`, 8 fixed types), initial balance (`OutlinedTextField`, optional, default 0)
- Currency field is NOT shown; currency silently defaults to `app_settings.home_currency`
- CTA "Create account" is disabled until required fields are valid
- On CTA tap: write account row to DB via `CreateAccountUseCase`; advance to Step 4
- "Skip" advances to Step 4 without writing any account; home screen handles empty state
- Inline validation errors shown below failing fields in `error` color role

### Definition of Done

- No currency field visible in the form
- Account is created with `currency_code = app_settings.home_currency`
- CTA disabled when account name is empty or account category unselected
- Inline field errors appear on invalid submission attempt
- "Skip" advances to Step 4 without any DB write
- Widget test: skip → home shows empty-state CTA (no error)
- Golden tests captured for: valid (CTA enabled), invalid (errors shown), and skip states

### References

- `3.5 Step 3 — Create First Account` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## S-79 — Step 4: Quick Highlights

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want to swipe through 2–3 feature highlight cards, so that I get a brief overview of key app capabilities before I start.

### Objectives

- Implement `OnboardingStep4Highlights` widget
- Render a `PageView` of 2–3 swipeable cards (`surfaceContainerLow` fill) with dot indicator (`primary` active, `outlineVariant` inactive)
- Each card: feature icon (M3 Symbols, 40 dp, `primary`), headline (`sectionHeading`, 20 sp, `onSurface`), body (`bodyMedium`, 14 sp, `onSurfaceVariant`)
- Skip button: visible — advances to Step 5
- CTA "Done": advances to Step 5

### Definition of Done

- Cards are swipeable; dot indicator updates with page position
- "Skip" and "Done" both advance to Step 5
- All highlight card content renders with correct tokens
- Golden test captured for Step 4

### References

- `3.6 Step 4 — Quick Highlights` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)

---

## S-80 — Step 5: Done Screen and Completion Write

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a first-time user, I want a confirmation screen that signals I am ready to use the app, and I want `onboarding_complete` to be set so I never see the wizard again.

### Objectives

- Implement `OnboardingStep5Done` widget
- Render: completion illustration (abstract geometric, `primary`/`tertiary` palette), headline "You're all set!" (`displayLargeAmount`, 36 sp, `onSurface`), sub-copy (`bodyLarge`, 16 sp, `onSurfaceVariant`)
- Skip button: hidden
- CTA "Start tracking": writes `onboarding_complete = 1` to `app_settings` via `AppSettingsNotifier`, then calls `context.go('/')`
- Auto-transition: if user does not tap CTA within ≤ 1.5 s, same write + navigate fires automatically
- After write, GoRouter redirect guard allows all subsequent navigations through

### Definition of Done

- `onboarding_complete = 1` is written to `app_settings` before `context.go('/')` fires
- Auto-transition fires within ≤ 1.5 s
- Skip button is hidden
- After completion, cold-start goes directly to home (wizard not shown)
- Widget test: tapping "Start tracking" writes `onboarding_complete = 1` and navigates to `/`

### References

- `3.7 Step 5 — Done` (`docs/02-technical/ui-spec.md`)
- `4.2 Per-Step Detail` (`docs/02-technical/ux-flows.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)

---

## S-81 — Home Screen Empty-State Handling for Zero Accounts

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a user who skipped account creation in onboarding, I want the home screen to show a useful empty state with a CTA, so that I can create my first account without encountering an error.

### Objectives

- Ensure `HomeScreen` handles zero accounts without error (net worth = 0, no crash from ACC-03)
- Render empty-state CTA ("Create your first account") that navigates to `/accounts/new`
- Transaction list shows empty state (no transactions message, no error)

### Definition of Done

- Home screen renders without error when account list is empty
- Net worth card shows `0` with home currency symbol (no null or error state)
- Empty-state CTA is visible and navigates correctly to `/accounts/new`
- Widget test: `HomeScreen` with zero accounts renders empty state and CTA

### References

- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)
- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)
- `2.1 Empty State CTA Wording Per Screen` (`docs/02-technical/ux-flows.md`)

---

## S-82 — Onboarding Integration Test

**Parent Epic:** E-10 — Onboarding Domain

**Story:** As a developer, I want an end-to-end integration test covering the full onboarding flow, so that regressions in the wizard, guard, and first account creation are caught automatically.

### Objectives

- Write integration test: fresh install → wizard step 1 → step 2 (confirm currency) → step 3 (create account) → step 4 → step 5 → home screen shows account
- Write integration test: fresh install → skip at step 2 → skip at step 3 → step 4 → step 5 → home shows empty state CTA
- Write integration test: `onboarding_complete = 1` on cold start → wizard is not shown → home renders

### Definition of Done

- All three integration test scenarios pass on Android emulator (API 34)
- Tests are runnable with `flutter test integration_test/`
- No flaky assertions — all waits use `pumpAndSettle` or explicit widget finders

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)

---

## S-83 — Debug Error Overlay and Bug-Report Shortcut

**Parent Epic:** E-1 — Infrastructure Foundations

**Story:** As a developer running a debug build, I want every unhandled exception and domain `Failure` to appear in a readable, copyable on-screen overlay with a one-tap bug-report shortcut, so that I can diagnose faults quickly and feed them directly into the bug-tracking workflow without losing context.

### Objectives

- Implement a `DebugErrorOverlay` widget that wraps the app root exclusively in `kDebugMode` (zero-cost tree in release)
- Capture all Flutter framework errors via `FlutterError.onError` and unhandled async errors via `PlatformDispatcher.instance.onError`; route both to the overlay
- Capture domain `Failure` values surfaced by Riverpod notifiers (e.g. `AsyncValue.error`) via a global Riverpod observer; route to the overlay
- Overlay displays: error type, message, abbreviated stack trace (first 10 frames), and originating context (screen route + use-case name where available)
- Overlay is scrollable and full-text selectable
- "Copy" button copies the full error payload (type + message + full stack trace) to the system clipboard
- "Record Bug" button pre-fills a plain-text bug-report template (error type, message, full stack trace, current route, timestamp) and copies it to clipboard — ready to paste into the `log bug` TPM workflow
- "Dismiss" button removes the overlay without clearing the error log; a persistent floating badge shows the count of captured errors and re-opens the overlay on tap
- All overlay code is gated behind `kDebugMode`; no import, widget, or provider from this feature is present in a release build

### Notes

- Hook into the existing `dev` build flavor defined in the SDS (`2.12.4 Build Flavors`) — the overlay is active only in that flavor's debug mode
- The `Failure` sealed hierarchy (`DatabaseFailure`, `ValidationFailure`, `NetworkFailure`, `NotFoundFailure`, `BusinessRuleFailure`) is already defined; the observer reads `.message` from each variant
- Do not modify any production notifier or use case — the capture mechanism is a side-channel observer only
- Stack trace formatting: use `Chain.terse` from `package:stack_trace` to strip framework frames; full raw trace still included in the clipboard payload

### Definition of Done

- In a debug build, triggering a `FlutterError` (e.g. overflow) causes the overlay to appear within one frame
- In a debug build, a notifier that emits `AsyncValue.error(Err(DatabaseFailure(...)))` causes the overlay to appear
- Overlay displays error type, message, and at least one stack frame
- "Copy" taps copy a non-empty string containing the error message to the clipboard (verified by widget test)
- "Record Bug" taps copy a non-empty string containing the word "Bug Report" and the error message to the clipboard
- Dismissed overlay re-opens via the floating error-count badge
- `flutter build apk --release` succeeds with zero references to `DebugErrorOverlay` in the compiled output (verified by `strings` grep on the APK classes.dex)
- All overlay behaviour is covered by widget tests; no integration test required

### References

- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)
- `2.9.3 Layer-Boundary Rules` (`docs/02-technical/sds.md`)
- `2.12.4 Build Flavors` (`docs/02-technical/sds.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---
