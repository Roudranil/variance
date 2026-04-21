---
name: System Design Spec
status: in-progress
owner: architect
created: 2026-04-20
last_updated: 2026-04-20
depends_on:
  - 01-product/prd.md
  - 01-product/ledger-entry.md
  - 01-product/input-fields.md
  - 01-product/technical-clarifications.md
outputs_to:
  - 02-technical/data-model.md
  - 02-technical/api-contracts.md
  - 02-technical/ux-flows.md
  - 02-technical/feature-dag.md
  - 03-planning/task-breakdown.md
---

- [System Design Spec — Variance](#system-design-spec--variance)
  - [1. Architecture Overview](#1-architecture-overview)
    - [1.1 Architectural Style](#11-architectural-style)
      - [1.1.1 Why Clean Architecture](#111-why-clean-architecture)
      - [1.1.2 Why Not Plain MVVM](#112-why-not-plain-mvvm)
      - [1.1.3 State Management Choice: Riverpod](#113-state-management-choice-riverpod)
    - [1.2 Layer Diagram](#12-layer-diagram)
      - [1.2.1 Dependency Direction Rule](#121-dependency-direction-rule)
    - [1.3 Layer Definitions](#13-layer-definitions)
      - [1.3.1 Presentation Layer](#131-presentation-layer)
        - [1.3.1.1 Navigation](#1311-navigation)
      - [1.3.2 Domain Layer](#132-domain-layer)
        - [1.3.2.1 Domain Services](#1321-domain-services)
        - [1.3.2.2 Use Cases](#1322-use-cases)
      - [1.3.3 Data Layer](#133-data-layer)
        - [1.3.3.1 ORM Choice: Drift](#1331-orm-choice-drift)
      - [1.3.4 Infrastructure Cross-Cut](#134-infrastructure-cross-cut)
    - [1.4 Data Flow](#14-data-flow)
      - [1.4.1 User-Initiated Write — Transaction Creation](#141-user-initiated-write--transaction-creation)
      - [1.4.2 Reactive Read — Transaction List](#142-reactive-read--transaction-list)
      - [1.4.3 Background Write — Recurring Auto-Post](#143-background-write--recurring-auto-post)
      - [1.4.4 Account Balance Read](#144-account-balance-read)
    - [1.5 Module and Feature Boundaries](#15-module-and-feature-boundaries)
      - [1.5.1 Folder Structure](#151-folder-structure)
      - [1.5.2 Feature Boundary Rules](#152-feature-boundary-rules)
      - [1.5.3 Domain Boundary Rules](#153-domain-boundary-rules)
    - [1.6 Key Architectural Constraints](#16-key-architectural-constraints)
      - [1.6.1 Offline-First — Local Storage Is Source of Truth](#161-offline-first--local-storage-is-source-of-truth)
      - [1.6.2 ACID Atomicity for All Ledger Operations](#162-acid-atomicity-for-all-ledger-operations)
      - [1.6.3 Domain Layer Must Have Zero Flutter Dependency](#163-domain-layer-must-have-zero-flutter-dependency)
      - [1.6.4 Android Only, Material 3, API 31+](#164-android-only-material-3-api-31)
      - [1.6.5 Zero Telemetry, Zero Network for Core Features](#165-zero-telemetry-zero-network-for-core-features)
      - [1.6.6 Universal Soft-Delete](#166-universal-soft-delete)
      - [1.6.7 Transaction Immutability and Correction Model](#167-transaction-immutability-and-correction-model)
      - [1.6.8 Scheduling Architecture](#168-scheduling-architecture)
      - [1.6.9 File Size Constraint — 800-Line Maximum](#169-file-size-constraint--800-line-maximum)
      - [1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations](#1610-o1-date-arithmetic--no-iteration-loops-for-period-calculations)
    - [1.7 Explicit Out-of-Scope](#17-explicit-out-of-scope)
  - [2. Tech Stack](#2-tech-stack)
    - [2.1 Core Runtime](#21-core-runtime)
      - [2.1.1 Flutter SDK](#211-flutter-sdk)
      - [2.1.2 Dart SDK](#212-dart-sdk)
      - [2.1.3 Android Target](#213-android-target)
    - [2.2 State Management and Reactivity](#22-state-management-and-reactivity)
      - [2.2.1 Riverpod](#221-riverpod)
      - [2.2.2 Provider Patterns in Use](#222-provider-patterns-in-use)
      - [2.2.3 Dependency Injection Strategy](#223-dependency-injection-strategy)
      - [2.2.4 Provider Scoping Rules](#224-provider-scoping-rules)
    - [2.3 Database and Persistence](#23-database-and-persistence)
      - [2.3.1 Drift ORM](#231-drift-orm)
      - [2.3.2 WAL Mode and PRAGMA Configuration](#232-wal-mode-and-pragma-configuration)
      - [2.3.3 Migration Strategy](#233-migration-strategy)
      - [2.3.4 DAO Structure](#234-dao-structure)
    - [2.4 Navigation](#24-navigation)
      - [2.4.1 GoRouter](#241-gorouter)
      - [2.4.2 Route Structure](#242-route-structure)
      - [2.4.3 Navigation Rules](#243-navigation-rules)
    - [2.5 Data Modeling and Serialization](#25-data-modeling-and-serialization)
      - [2.5.1 Freezed — Domain Entities](#251-freezed--domain-entities)
      - [2.5.2 json\_serializable — Data Transfer Objects](#252-json_serializable--data-transfer-objects)
      - [2.5.3 Serialization Field Naming](#253-serialization-field-naming)
    - [2.6 Scheduling](#26-scheduling)
      - [2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model](#261-decision--tc-041-hybrid-workmanager--exact-alarm-model)
    - [2.7 Exchange Rate](#27-exchange-rate)
      - [2.7.1 Decision — TC-006: fawazahmed0 Exchange API](#271-decision--tc-006-fawazahmed0-exchange-api)
      - [2.7.2 Fetch Trigger and Schedule](#272-fetch-trigger-and-schedule)
      - [2.7.3 Cache Schema](#273-cache-schema)
      - [2.7.4 Staleness and Offline Fallback](#274-staleness-and-offline-fallback)
      - [2.7.5 Architectural Isolation](#275-architectural-isolation)
    - [2.8 Search](#28-search)
      - [2.8.1 Decision — TC-009: SQLite FTS5 with Dart-Side Scoring](#281-decision--tc-009-sqlite-fts5-with-dart-side-scoring)
      - [2.8.2 FTS5 Schema](#282-fts5-schema)
      - [2.8.3 Ranking Algorithm](#283-ranking-algorithm)
      - [2.8.4 Search Scope](#284-search-scope)
    - [2.9 Error Handling Patterns](#29-error-handling-patterns)
      - [2.9.1 Decision — TC-033: Result Type Pattern](#291-decision--tc-033-result-type-pattern)
      - [2.9.2 Result Type Definition](#292-result-type-definition)
      - [2.9.3 Layer-Boundary Rules](#293-layer-boundary-rules)
      - [2.9.4 Ledger Operation Failure Modes](#294-ledger-operation-failure-modes)
      - [2.9.5 Form State Preservation](#295-form-state-preservation)
    - [2.10 Code Generation Pipeline](#210-code-generation-pipeline)
      - [2.10.1 Build Runner](#2101-build-runner)
      - [2.10.2 Generator Execution Order](#2102-generator-execution-order)
      - [2.10.3 Output File Conventions](#2103-output-file-conventions)
      - [2.10.4 CI Build Sequence](#2104-ci-build-sequence)
    - [2.11 Testing Stack](#211-testing-stack)
      - [2.11.1 Test Pyramid Targets](#2111-test-pyramid-targets)
      - [2.11.2 Unit Testing](#2112-unit-testing)
      - [2.11.3 Widget Testing](#2113-widget-testing)
      - [2.11.4 Golden Tests](#2114-golden-tests)
      - [2.11.5 Integration Tests](#2115-integration-tests)
    - [2.12 Build and Release Tooling](#212-build-and-release-tooling)
      - [2.12.1 App Icon Generation](#2121-app-icon-generation)
      - [2.12.2 Splash Screen](#2122-splash-screen)
      - [2.12.3 ProGuard / R8](#2123-proguard--r8)
      - [2.12.4 Build Flavors](#2124-build-flavors)
      - [2.12.5 Version Management](#2125-version-management)
    - [2.13 Linting and Static Analysis](#213-linting-and-static-analysis)
      - [2.13.1 Analysis Configuration](#2131-analysis-configuration)
      - [2.13.2 Formatting and Auto-Fix](#2132-formatting-and-auto-fix)
    - [2.14 Complete Dependency Table](#214-complete-dependency-table)
      - [2.14.1 Production Dependencies](#2141-production-dependencies)
      - [2.14.2 Development Dependencies](#2142-development-dependencies)
      - [2.14.3 Dependency Notes](#2143-dependency-notes)
    - [2.15 Photo Compression](#215-photo-compression)
      - [2.15.1 Decision — TC-007: JPEG Compression with 1920px Cap](#2151-decision--tc-007-jpeg-compression-with-1920px-cap)
    - [2.16 Currency Bundle](#216-currency-bundle)
      - [2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset](#2161-decision--tc-044-bundled-iso-4217-static-asset)
    - [2.17 Backup Format](#217-backup-format)
      - [2.17.1 Decision — TC-054: Versioned ZIP Archive with Manifest](#2171-decision--tc-054-versioned-zip-archive-with-manifest)
    - [2.18 Theming Architecture](#218-theming-architecture)
      - [2.18.1 Decision: Type-Safe ThemeExtension](#2181-decision-type-safe-themeextension)


# System Design Spec — Variance

Variance is a local-first, Android-only personal expense tracker built on a double-entry bookkeeping (DEB) engine. This document is the authoritative technical specification for the v1 system. It defines architecture, layer boundaries, data flows, module organisation, constraints, and key engineering decisions. All downstream documents (data model, API contracts, UX flows, feature DAG, test strategy, security model) are derived from it.


## 1. Architecture Overview

### 1.1 Architectural Style

Variance uses a **three-layer Clean Architecture** variant tailored for a Flutter mobile application with no network backend.

The three layers are: **Presentation**, **Domain**, and **Data**. An Infrastructure cross-cut provides platform services (scheduling, notifications, file I/O, crash reporting) without belonging to any single layer.

#### 1.1.1 Why Clean Architecture

The DEB ledger engine is the core business invariant. It must be isolated from both the Flutter widget tree and SQLite specifics. Three reasons drove this choice:

1. **Domain isolation.** The balance formula, posting-case logic, and transaction-validity rules are pure Dart — no Flutter, no SQLite. Isolating them makes them independently testable and prevents widget-rebuild semantics from leaking into financial computation.
2. **Presentation independence.** The presentation layer calls use cases, not repositories. This means the same ledger rules apply regardless of whether the entry point is the main form, the onboarding wizard, or a recurring-template auto-post.
3. **Testability.** The test pyramid (unit > integration > E2E) requires that each layer can be exercised in isolation. Clean Architecture enforces the dependency direction that makes this possible.

#### 1.1.2 Why Not Plain MVVM

A flat ViewModel-over-repository arrangement collapses the domain layer into the ViewModel. For a read-heavy CRUD app that is acceptable, but Variance has domain rules with non-trivial invariants (DEB balance constraint, posting-case selection, soft-delete correction chains, installment running totals). Embedding those rules in ViewModels couples business logic to the UI lifecycle. Clean Architecture separates them explicitly.

#### 1.1.3 State Management Choice: Riverpod

State management within the Presentation layer uses **Riverpod** (via code-generated providers with `@riverpod`). Rationale:

| Criterion | Riverpod | BLoC/Cubit | ValueNotifier |
|-----------|----------|------------|---------------|
| Testability | Excellent — providers override cleanly in tests | Excellent | Moderate |
| Compile-time safety | Strong — no `context.read` risks | Strong | Weak |
| Reactivity granularity | Fine-grained — `select`, `watch` | Coarse — full-state rebuild | Coarse |
| Boilerplate | Low with code gen | Medium | Low |
| No-backend fit | Excellent — local-only state patterns native | Good | Good |
| DI integration | Providers are the DI graph | External DI needed | External DI needed |

Riverpod is chosen because its provider graph doubles as the composition root for dependency injection, eliminating a separate DI library. `@riverpod` code generation reduces boilerplate. Fine-grained `select` watchers prevent unnecessary rebuilds in a list-heavy UI (10,000-transaction render target, PRD NF-3).

Tradeoff accepted: Riverpod adds a build-step dependency (`riverpod_generator`). This is offset by the elimination of `get_it` and the elimination of BLoC event/state class proliferation.

---

### 1.2 Layer Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│                                                                   │
│  Screens / Pages        Widgets          Providers (Riverpod)    │
│  (GoRouter routes)      (stateless)      (AsyncNotifier / @riverpod) │
│                                                                   │
│   depends on: Domain (use cases only), never Data directly       │
└──────────────────────────────┬──────────────────────────────────┘
                               │ calls
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Domain Layer                            │
│                                                                  │
│  Entities          Repository Interfaces    Use Cases            │
│  (pure Dart)       (abstract — no impl)     (orchestration)      │
│                                                                  │
│  DEB engine        Posting-case selector    Transaction commands │
│  Balance formula   Balance calculator       Account commands     │
│                                                                  │
│   depends on: nothing outside this layer (pure Dart)            │
└──────────────────────────────┬──────────────────────────────────┘
                               │ implements
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                           Data Layer                            │
│                                                                 │
│  Repository Impls      Local Data Sources      DTOs              │
│  (implement Domain     (drift / SQLite         (fromRow/toEntity │
│   interfaces)           queries)               mapping)          │
│                                                                  │
│   depends on: Domain interfaces only (via inversion)            │
└──────────────────────────────┬──────────────────────────────────┘
                               │ uses platform APIs via
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Infrastructure Cross-Cut                    │
│                                                                   │
│  Scheduler (WorkManager)    Notifications (flutter_local_notifications) │
│  File I/O (backup/photos)   Crash logging (firebase_crashlytics) │
│  Exchange rates (HTTP)      Secure storage (flutter_secure_storage) │
│                                                                   │
│   Platform-specific. No business logic. No layer owns it.       │
└─────────────────────────────────────────────────────────────────┘
```

#### 1.2.1 Dependency Direction Rule

```
Presentation → Domain ← Data
Infrastructure ← Data (data layer wires infra)
```

No upward dependencies. No circular dependencies. Presentation never imports Data directly.

---

### 1.3 Layer Definitions

#### 1.3.1 Presentation Layer

| Attribute | Specification |
|-----------|---------------|
| **Responsibility** | Render UI, handle user input, translate domain state into display state |
| **May import** | Domain entities, domain use case interfaces, Riverpod providers, GoRouter |
| **Must not import** | Data layer packages, SQLite, drift, repository implementations |
| **State pattern** | Riverpod `@riverpod` providers; `AsyncNotifier` for async operations; `Notifier` for sync state |
| **Widget pattern** | `ConsumerWidget` / `ConsumerStatefulWidget`; extract to named widget classes (never helper methods) |
| **Key rule** | Calls use cases, not repositories. The provider resolves the use case via DI. |

##### 1.3.1.1 Navigation

Navigation uses **GoRouter** with a `ShellRoute` wrapping the three-tab bottom navigation. Each tab maintains its own navigation stack. Deep modal screens (transaction entry form, photo viewer) push on top of the active stack with bottom bar hidden.

| Route | Shell behaviour |
|-------|----------------|
| `/ (home)` | Tab 1 root — transaction list + dashboard |
| `/accounts` | Tab 2 root — account list |
| `/settings` | Tab 3 root — settings hub |
| `/transactions/new` | Modal over active tab — hides bottom bar |
| `/transactions/:id` | Pushed onto initiating tab stack |
| `/accounts/:id` | Pushed onto Accounts tab stack |
| `/onboarding` | Full-screen — no shell |

#### 1.3.2 Domain Layer

| Attribute | Specification |
|-----------|---------------|
| **Responsibility** | Express all DEB rules, business invariants, and application workflows as pure Dart |
| **May import** | No Flutter packages. No database packages. `dart:core`, `equatable` or `freezed` for value objects only. |
| **Must not import** | `package:flutter`, `drift`, `riverpod`, any infrastructure package |
| **Key contents** | Entities (Transaction, Entry, Account, Category, RecurringTemplate), repository abstract interfaces, use cases, domain services (LedgerEngine, BalanceCalculator, PostingCaseSelector) |
| **Key rule** | `domain/` must compile as a pure Dart library with zero Flutter SDK dependency. CI enforces this. |

##### 1.3.2.1 Domain Services

Four domain services encapsulate the DEB engine logic:

- **LedgerEngine** — validates posting cases, constructs entry sets, enforces `Σdebit = Σcredit` invariant (PRD §4.4).
- **BalanceCalculator** — computes account balances using the universal formula `balance = Σdebit − Σcredit` (PRD §4.6). Handles multi-currency conversion via `exchange_rate_to_home`.
- **PostingCaseSelector** — given an event type (create, modify, delete, balance-edit) and entity state, selects the correct ledger posting case from PRD §4.11 and `ledger-entry.md`.
- **PeriodCalculator** — O(1) computation of the current period window for recurring templates and budgets. Takes a start date, period type (daily/weekly/monthly/yearly/custom), and a reference date; returns a `DateRange`. No iteration. Handles month-boundary and leap-year edge cases via Dart `DateTime` constructor arithmetic. See §1.6.10.

These are stateless. They take entities as input and return entry sets or computed values. They have no I/O.

##### 1.3.2.2 Use Cases

Each user-facing operation maps to a use case class in `domain/usecases/`. Use cases:
- Accept validated input models (not raw UI form state)
- Call repository interfaces (never concrete implementations)
- Call domain services for DEB logic
- Return result types (success value or typed failure)

One use case per domain operation. Examples: `CreateTransactionUseCase`, `EditTransactionUseCase`, `SoftDeleteAccountUseCase`, `AutoPostRecurringUseCase`.

#### 1.3.3 Data Layer

| Attribute | Specification |
|-----------|---------------|
| **Responsibility** | Persist and retrieve domain entities; map DTOs to/from domain types at the repository boundary |
| **May import** | Domain interfaces (to implement), `drift`, `sqflite` or equivalent, infrastructure services via constructor injection |
| **Must not import** | Presentation layer, Riverpod providers, GoRouter |
| **Key contents** | Repository implementations, drift table definitions, DAO classes, DTO models with `fromRow` / `toEntity` methods |
| **Key rule** | The repository implementation is the only place where domain entity ↔ DTO mapping occurs. Domain entities never contain drift `TableInfo` or JSON annotations. |

##### 1.3.3.1 ORM Choice: Drift

Drift (formerly Moor) is chosen for SQLite access. Rationale: type-safe Dart queries without raw SQL strings, reactive `Stream<T>` query results for Riverpod watching, compile-time schema verification, and built-in migration support. Tradeoff: code generation step added to build; acceptable given the same dependency already exists for Riverpod and Freezed.

#### 1.3.4 Infrastructure Cross-Cut

| Service | Package | Purpose |
|---------|---------|---------|
| Background scheduling | `workmanager` | Recurring transaction auto-post; catch-up sweep on app launch |
| Exact-alarm notifications | `flutter_local_notifications` | Remind-and-confirm recurring prompts; credit card payment reminders |
| File I/O | `dart:io` + platform file picker | Backup zip export; photo attachment storage |
| HTTP (opportunistic) | `http` | Exchange rate fetch (background, offline-tolerant) |
| Database encryption | `sqlcipher_flutter_libs` | SQLCipher encryption at rest for all financial data |
| Secure storage | `flutter_secure_storage` | SQLCipher key material; PIN hash; app lock state (backed by Android Keystore) |
| Crash reporting | `firebase_crashlytics` (opt-in build flavour) | Crash capture; zero PII |

**Database encryption is a v1 requirement (AP-4 from competitive analysis).** All financial data is encrypted at rest using SQLCipher. The encryption key is derived from a biometric-backed Android Keystore entry, accessed exclusively via `flutter_secure_storage`. There is no unencrypted migration path — the database is created encrypted from first launch. The `sqlite3_flutter_libs` plain SQLite binding is replaced by `sqlcipher_flutter_libs` (see §2.3.1).

Infrastructure services are injected into the Data layer or domain services via constructor injection. They are never imported by the Domain layer directly — domain abstractions (e.g., `IdGenerator`, `ClockService`) are defined in the domain layer and implemented in infrastructure.

---

### 1.4 Data Flow

#### 1.4.1 User-Initiated Write — Transaction Creation

```
[User taps Save on transaction form]
         │
         ▼
[Presentation: TransactionFormNotifier]
  — validates UI form state
  — constructs CreateTransactionInput value object
         │
         ▼
[Domain: CreateTransactionUseCase]
  — calls PostingCaseSelector → identifies posting case (e.g., Case 1.1 Expense)
  — calls LedgerEngine.buildEntries(input) → produces balanced Entry set
  — calls LedgerEngine.validate(transaction) → asserts Σdebit = Σcredit
  — calls TransactionRepository.save(transaction, entries) [interface call]
         │
         ▼
[Data: TransactionRepositoryImpl]
  — opens drift database transaction
  — maps Transaction + Entry domain entities → drift table rows
  — writes atomically (ACID — NF-8)
  — on success: returns saved Transaction with generated id
  — on failure: rolls back entire write; throws domain-typed exception
         │
         ▼
[Domain: use case returns Success(transaction) | Failure(reason)]
         │
         ▼
[Presentation: notifier emits new state]
  — on Success: invalidates affected providers (transaction list, account balance)
  — on Failure: emits error state with preserved form data (TC-033)
         │
         ▼
[Reactive: Riverpod watchers rebuild affected widgets]
  — TransactionList provider re-fetches (drift Stream emits new row)
  — AccountBalance provider re-computes
```

#### 1.4.2 Reactive Read — Transaction List

```
[SQLite table mutation (insert/update/delete via drift)]
         │
         ▼
[Data: TransactionLocalDataSource]
  — drift watchStatement() emits new snapshot on every write
  — query uses cursor-based pagination: WHERE date < :cursor ORDER BY date DESC LIMIT :pageSize+1
  — the +1 result determines hasNextPage without a separate COUNT query
         │
         ▼
[Data: TransactionRepositoryImpl.watchTransactions(cursor, pageSize)]
  — maps DTO rows → domain Transaction entities
  — emits Stream<PagedResult<Transaction>>
         │
         ▼
[Domain: no use case involved — reads are pure projections]
         │
         ▼
[Presentation: transactionsProvider (AsyncNotifier)]
  — manages current page cursor, loading state, hasNextPage flag
  — triggers next-page load when user scrolls within threshold of list bottom
  — ref.watch() → rebuilds only affected widgets via select()
         │
         ▼
[Widget: TransactionListView — SliverList.builder pattern]
  — never loads full dataset; renders only the paged window
  — grouped by date (grouping performed in query layer, not widget layer)
```

**Pagination requirement (AP-5 from competitive analysis):** Loading the full transaction table into a `StreamBuilder` (as in Cashew's `DEFAULT_LIMIT = 100000` pattern) is a time bomb at 3,000+ transactions. The transaction list must use cursor-based pagination. The cursor is the `date` of the last-seen transaction; the next page loads records with `date < cursor`. Page size: 50 transactions per page (configurable constant). `SliverList.builder` is the required widget pattern — no `ListView` with a pre-built children list. Financial aggregation (category totals, net worth computation) that operates on more than 500 rows must be offloaded to a background isolate via `Isolate.run()` or `compute()` to protect the main thread from frame drops.

#### 1.4.3 Background Write — Recurring Auto-Post

```
[WorkManager fires scheduled task (or app launch catch-up sweep)]
         │
         ▼
[Infrastructure: RecurringPostWorker]
  — queries due recurring templates from Data layer
  — for each due template: calls AutoPostRecurringUseCase
         │
         ▼
[Domain: AutoPostRecurringUseCase]
  — selects posting case (same as user-initiated path)
  — delegates to LedgerEngine.buildEntries + validate
  — calls TransactionRepository.save
         │
         ▼
[Data: writes atomically — identical to user-initiated path]
         │
         ▼
[Reactive: Stream emits → UI updates if app is foregrounded]
```

The recurring auto-post path reuses the same domain and data layer as user-initiated writes. No special-case code in the domain layer for background context.

#### 1.4.4 Account Balance Read

```
[Presentation: accountBalanceProvider watches AccountRepository.watchBalance(accountId)]
         │
         ▼
[Data: drift query — SELECT SUM(amount) WHERE side='debit' MINUS SUM(amount) WHERE side='credit']
  — returns reactive balance stream
         │
         ▼
[Domain: BalanceCalculator — validates formula application]
         │
         ▼
[Presentation: renders balance with sign-based colour coding (PRD §5.1.4)]
```

Balance is computed as a database aggregate, not cached in a separate column. This eliminates a class of balance-drift bugs. The index design (defined in data-model.md) ensures this aggregation meets the <500ms render target (NF-3).

---

### 1.5 Module and Feature Boundaries

#### 1.5.1 Folder Structure

```
lib/
├── main.dart                          # App entry point; initialises DI, runs app
├── app.dart                           # MaterialApp.router, theme, top-level providers
│
├── domain/                            # Pure Dart — zero Flutter imports
│   ├── entities/                      # Immutable value objects (freezed)
│   │   ├── transaction.dart
│   │   ├── entry.dart
│   │   ├── account.dart
│   │   ├── category.dart
│   │   ├── recurring_template.dart
│   │   └── ...
│   ├── repositories/                  # Abstract interfaces only
│   │   ├── transaction_repository.dart
│   │   ├── account_repository.dart
│   │   ├── category_repository.dart
│   │   └── ...
│   ├── usecases/                      # One class per operation
│   │   ├── transaction/
│   │   │   ├── create_transaction_use_case.dart
│   │   │   ├── edit_transaction_use_case.dart
│   │   │   └── delete_transaction_use_case.dart
│   │   ├── account/
│   │   ├── recurring/
│   │   └── ...
│   └── services/                      # Domain services (no I/O)
│       ├── ledger_engine.dart
│       ├── balance_calculator.dart
│       ├── posting_case_selector.dart
│       └── period_calculator.dart
│
├── data/                              # Implements domain interfaces
│   ├── database/                      # Drift schema + database class
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── migrations/
│   ├── datasources/                   # DAO classes per entity
│   │   ├── transaction_local_data_source.dart
│   │   ├── account_local_data_source.dart
│   │   └── ...
│   ├── models/                        # DTOs with fromRow / toEntity
│   │   ├── transaction_dto.dart
│   │   ├── account_dto.dart
│   │   └── ...
│   └── repositories/                  # Repository implementations
│       ├── transaction_repository_impl.dart
│       ├── account_repository_impl.dart
│       └── ...
│
├── presentation/                      # Flutter widgets + Riverpod providers
│   ├── providers/                     # @riverpod generated providers
│   │   ├── transaction_providers.dart
│   │   ├── account_providers.dart
│   │   └── ...
│   ├── features/                      # Feature-scoped screen + widget trees
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── transaction_entry/
│   │   │   ├── transaction_entry_screen.dart
│   │   │   └── widgets/
│   │   ├── accounts/
│   │   ├── settings/
│   │   ├── onboarding/
│   │   └── ...
│   ├── navigation/                    # GoRouter configuration
│   │   └── app_router.dart
│   └── theme/                         # ThemeData, tokens, colour scheme
│       └── app_theme.dart
│
└── infrastructure/                    # Platform services + third-party integrations
    ├── scheduling/
    │   └── recurring_post_worker.dart
    ├── notifications/
    │   └── notification_service.dart
    ├── backup/
    │   └── backup_service.dart
    ├── exchange_rates/
    │   └── exchange_rate_service.dart
    └── security/
        └── pin_service.dart
```

#### 1.5.2 Feature Boundary Rules

Each feature in `presentation/features/` is self-contained:

- It owns its screens and private widgets.
- It may read from shared `presentation/providers/` but never imports another feature's internals.
- Cross-feature navigation is done via GoRouter named routes — no direct widget imports between features.
- Shared UI components live in `presentation/widgets/` (not inside any feature folder).

#### 1.5.3 Domain Boundary Rules

- Domain entities are immutable (`freezed`-annotated). No setters.
- Domain services are stateless. No shared mutable state in the domain layer.
- Use cases do not call other use cases. If shared orchestration is needed, extract to a domain service.
- Repository interfaces in `domain/repositories/` define only the operations the domain layer needs. They are not one-to-one with database tables.

---

### 1.6 Key Architectural Constraints

The following constraints are non-negotiable and architectural decisions must comply with them.

#### 1.6.1 Offline-First — Local Storage Is Source of Truth

**Constraint (PRD C1, NF-2, A3):** All core v1 functionality operates without internet. SQLite is the single source of truth. No read-through caches to a remote server. No write-through to any network endpoint.

**Architectural implication:** The repository implementation pattern in v1 has no remote data source. `TransactionRepositoryImpl` wraps only a local data source. The remote data source slot (which exists in the generic repository pattern) is intentionally left unimplemented in v1. When v2 introduces optional cloud backup, the implementation will be added without changing the domain interface.

**Conflict resolution:** Not applicable in v1 — single device, single writer.

#### 1.6.2 ACID Atomicity for All Ledger Operations

**Constraint (PRD NF-8, TC-033):** Every ledger operation that touches multiple entries must be atomic. Partial writes are forbidden.

**Architectural implication:** All multi-entry operations (create, modify, delete transactions) are wrapped in a single drift database transaction. The `TransactionRepository.save` interface accepts a `(Transaction, List<Entry>)` tuple and writes them as one atomic unit. Use cases never call `save(entry)` individually.

#### 1.6.3 Domain Layer Must Have Zero Flutter Dependency

**Constraint:** The domain layer must compile as a standalone Dart package. This is enforced structurally — `domain/` has its own `pubspec.yaml` as a path dependency if needed for strict enforcement, or CI runs `dart compile` without the Flutter toolchain on `lib/domain/` as a lint step.

**Architectural implication:** Domain entities use `freezed` (Dart-only annotation library). Domain services use only `dart:core`. No `BuildContext`, `Widget`, or `State` references appear anywhere in `domain/`.

#### 1.6.4 Android Only, Material 3, API 31+

**Constraint (PRD NF-9, NF-10, C6):** Target Android API 31+. Material You dynamic color on API 31+.

**Architectural implication:** No iOS-specific platform channels. No adaptive layout for iPad. Dynamic color via `ColorScheme.fromImageProvider` or `DynamicColorBuilder` — seed color fallback for API < 31 not applicable since API 31 is the minimum. RTL layout support is required (PRD §8.1 FG-A30) — all layout widgets must use `start`/`end` insets, not `left`/`right`.

#### 1.6.5 Zero Telemetry, Zero Network for Core Features

**Constraint (PRD NF-1, C4):** The app never initiates a network call for any core functionality. Exchange rate fetching is an opportunistic background operation — its failure must never block any user flow.

**Architectural implication:** Exchange rates are fetched in `infrastructure/exchange_rates/` as a best-effort WorkManager task. The domain layer always reads the last cached rate from SQLite. If no cached rate exists, the UI shows a staleness warning (PRD §5.2.1 FG-C12) but the transaction can still be saved.

#### 1.6.6 Universal Soft-Delete

**Constraint (PRD C8):** No entity is ever permanently deleted. All deletes set `deleted_at` / `is_deleted` flags.

**Architectural implication:** All repository read interfaces default to filtering `WHERE is_deleted = FALSE`. Separate query methods (`watchIncludingDeleted`) are provided for the filter view (PRD §8.1 FG-B9) and historical lookup. Soft-delete does not extend to voided transactions from reversing entries — those are never "deleted", they are always visible in the audit trail (even if hidden from the default list view).

#### 1.6.7 Transaction Immutability and Correction Model

**Constraint (PRD §4.8):** Posted transactions are permanently immutable. Financial edits produce reversing + corrected transaction pairs. In-place edits are limited to non-financial fields (title, description, photos, date/time).

**Architectural implication:** The `EditTransactionUseCase` branches on field type: non-financial fields call a direct `update` on the transaction record; financial fields trigger the posting-case-selected reversal + correction flow. The data layer never issues a SQL `UPDATE` on financial entry rows — it only inserts new correction entries.

#### 1.6.8 Scheduling Architecture

**Decision (TC-041):** Hybrid scheduling model:
- **WorkManager periodic task**: catch-up sweep on app launch and scheduled background windows — posts all overdue recurring transactions and auto-dates future transactions.
- **`flutter_local_notifications` with exact alarms**: time-critical "remind and confirm" notifications (`SCHEDULE_EXACT_ALARM` permission — PRD NF-1).
- **On-app-launch sweep** (in `main.dart` initialisation): synchronous catch-up for missed postings before first frame render.

Rationale: WorkManager alone cannot guarantee exact-time notification delivery. Exact alarms alone are battery-heavy for frequent postings. The hybrid model uses exact alarms only for user-visible notification events and WorkManager for silent background posting, matching Android OS guidelines for the two permission classes.

#### 1.6.9 File Size Constraint — 800-Line Maximum

**Constraint:** No source file in `lib/` may exceed 800 lines. The target is 200–400 lines per file. This is enforced at code review: any PR introducing a file over 800 lines is rejected by the reviewer.

**Rationale (AP-2 from competitive analysis):** Cashew's `tables.dart` at 7,667 lines and `addTransactionPage.dart` at 5,207 lines demonstrate the compounding cost of unchecked file growth. God files create merge conflict magnets, cognitive overload, and block safe refactoring. The folder structure in §1.5.1 is designed to make large files structurally impossible: domain concepts are split by entity, DAOs are split by aggregate, and presentation screens split by feature. The 800-line cap is the enforcement boundary.

**Architectural implication:** Drift's `@DriftDatabase` class is a thin shell (table registrations and DAO declarations only — under 100 lines). Query methods live in per-aggregate DAO files, not on the database class.

#### 1.6.10 O(1) Date Arithmetic — No Iteration Loops for Period Calculations

**Constraint:** Budget period, recurring template schedule, and any other date-range calculation must be solved using direct arithmetic — not forward-iteration loops. The current period index for any recurring entity with a known start date and period length is computed as `periodIndex = (today - startDate) ~/ periodLength`. For variable-length periods (monthly, yearly), Dart's `DateTime` constructor arithmetic handles overflow natively.

**Rationale (AP-9 from competitive analysis):** Cashew's `getBudgetDate()` iterates forward from the start date one period at a time, up to 10,000 iterations. For a daily budget created two years ago, that is 730 iterations per render on the main thread. At five budgets on the home screen, that is 3,650 iterations per rebuild. O(1) arithmetic replaces this entirely for all period types.

**Architectural implication:** Period calculations live in the domain layer as pure functions in `domain/services/period_calculator.dart`. They are stateless, take a start date, period type, and reference date as inputs, and return a `DateRange`. They are exhaustively unit-tested with edge cases for month boundaries, leap years, and DST transitions.

---

### 1.7 Explicit Out-of-Scope

The following are deliberately excluded from the v1 architecture. Adding any of these in v1 would require an explicit architectural change request.

| Excluded Concern | Rationale |
|-----------------|-----------|
| Cloud sync / remote backend | PRD permanently out of scope (§8.4). Architecture has no sync layer by design. |
| Authentication server / user accounts | No multi-user, no cloud. Device lock is PIN-only via `flutter_secure_storage`. |
| REST or GraphQL API layer | No server. No network API surface in v1. |
| iOS / macOS / Web / Desktop targets | Android-only. No platform-adaptive code beyond RTL layout. |
| Multi-device data merge / CRDT | Single device, no sync. No conflict resolution logic needed. |
| Bank API / Open Banking connectors | Permanently out of scope (§8.4). |
| Real-time analytics or telemetry | Zero telemetry constraint (NF-1, C4). |
| In-app purchase / subscription | No monetisation. Ever. |
| Background sync with remote source | Exchange rate fetch is the only network operation — offline-tolerant, best-effort, no core-feature dependency. |
| Server-side push notifications | OS-level local notifications only (NF-1). No FCM, APNs, or push infrastructure. |
| Biometric authentication | Security model uses device lock + optional PIN (PRD §5.4.6). Biometric is an OS delegate, not an app-level auth layer. |
| Budgeting features | Deferred to v2 (PRD §5.3, §8.2). No budget entity in the v1 domain layer. |

---

## 2. Tech Stack

### 2.1 Core Runtime

#### 2.1.1 Flutter SDK

| Attribute | Value |
|-----------|-------|
| **SDK channel** | `stable` |
| **Version pin strategy** | Pin to a specific stable version in `.fvmrc` via Flutter Version Management (FVM). Bumps are explicit, reviewed, and committed. No floating `stable` in CI. |
| **Minimum Flutter version** | 3.24.x (the earliest stable release supporting Material 3 dynamic color with API 31+ constraint without conditional branching) |

**Rationale for FVM pinning:** Floating on `stable` causes silent build-environment divergence between developer machines and CI. FVM pins the exact toolchain to a committed `.fvmrc` file, producing reproducible builds. Version bumps become an explicit PR-reviewed decision.

#### 2.1.2 Dart SDK

| Attribute | Value |
|-----------|-------|
| **SDK constraint** | `sdk: '>=3.4.0 <4.0.0'` |
| **Null safety** | Sound null safety enforced. No `--no-sound-null-safety` flag anywhere in the build pipeline. |
| **Language version** | Dart 3.x — sealed classes, patterns, records, exhaustive switches all available. |

#### 2.1.3 Android Target

| Attribute | Value |
|-----------|-------|
| **`minSdkVersion`** | 31 (Android 12) |
| **`targetSdkVersion`** | 35 (Android 15) |
| **`compileSdkVersion`** | 35 |
| **ABI targets** | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| **Material You** | `DynamicColorBuilder` from `dynamic_color` package — always active on API 31+. No API-level conditional required since API 31 is the minimum. |

---

### 2.2 State Management and Reactivity

#### 2.2.1 Riverpod

| Attribute | Value |
|-----------|-------|
| **Package** | `flutter_riverpod ^2.6.1` |
| **Code-gen annotation package** | `riverpod_annotation ^2.3.5` |
| **Code-gen builder** | `riverpod_generator ^2.4.3` (dev dependency) |
| **Lint rules** | `riverpod_lint ^2.3.13` (dev dependency) |

All providers are declared using the `@riverpod` annotation. Raw `Provider(...)` constructor syntax is forbidden outside of legacy or third-party integration code.

#### 2.2.2 Provider Patterns in Use

| Provider Type | Usage |
|---------------|-------|
| `@riverpod` `AsyncNotifier<T>` | Repository-backed screen state that loads asynchronously (e.g., `TransactionListNotifier`, `AccountListNotifier`) |
| `@riverpod` `Notifier<T>` | Synchronous state that is already in memory (e.g., active filter state, form field state) |
| `@riverpod` `StreamProvider<T>` | Wrapping Drift `Stream<T>` reactive queries — the primary reactivity bridge between the database and UI |
| `@riverpod` (functional) | Pure derivations — computed values from other providers with no side effects (e.g., filtered transaction list derived from a stream) |
| `@riverpod` (functional, `keepAlive: true`) | Repository instances and database singletons — constructed once, never disposed |

#### 2.2.3 Dependency Injection Strategy

Riverpod's provider graph is the composition root. Repositories and infrastructure services are exposed as `keepAlive` providers. Use cases receive their dependencies via constructor injection from their own provider. There is no `get_it` or `injectable` package — Riverpod's `ref.watch` / `ref.read` is the only DI mechanism.

```
DatabaseProvider (keepAlive)
  └── TransactionDaoProvider (keepAlive)
        └── TransactionRepositoryProvider (keepAlive)
              └── CreateTransactionUseCaseProvider
                    └── TransactionFormNotifier (scoped to screen)
```

#### 2.2.4 Provider Scoping Rules

- **Global (root) scope:** Database, repositories, infrastructure services (exchange rate cache, notification scheduler).
- **Route scope (`ProviderScope` override at route level):** Form notifiers, screen-specific state.
- **Widget scope:** Ephemeral local state that does not need to survive navigation — use `ValueNotifier` + `ValueListenableBuilder` directly, not Riverpod.

---

### 2.3 Database and Persistence

> **Full schema reference:** See [`docs/02-technical/data-model.md`](data-model.md) for the complete entity definitions, column specifications, index catalogue, Drift type mappings, and soft-delete/void-chain policies.

#### 2.3.1 Drift ORM

| Attribute | Value |
|-----------|-------|
| **Package** | `drift ^2.21.0` |
| **Dev dependency** | `drift_dev ^2.21.0` |
| **SQLite binding** | `sqlcipher_flutter_libs ^0.3.0` (SQLCipher-encrypted SQLite; replaces plain `sqlite3_flutter_libs` — all financial data is encrypted at rest) |
| **Database file** | `variance.db` in `getApplicationDocumentsDirectory()` — encrypted; key stored in Android Keystore via `flutter_secure_storage` |

**Why SQLCipher over plain SQLite:** A personal finance app stores the most sensitive data a user owns. Plain SQLite (as used in Cashew) means any process with filesystem access — a rooted device, a backup extraction tool, a future cloud backup — can read the entire financial history in the clear. SQLCipher adds AES-256 encryption at the page level with ~5–15% overhead on mobile, which is acceptable for a local-first app with no real-time sync requirements. The encryption key is never stored in plaintext; it lives in Android Keystore hardware-backed storage and is retrieved via `flutter_secure_storage` on every database open. See §1.3.4 for the full infrastructure setup.

#### 2.3.2 WAL Mode and PRAGMA Configuration

The database is opened with the following pragmas applied on every connection:

| PRAGMA | Value | Rationale |
|--------|-------|-----------|
| `journal_mode` | `WAL` | Write-ahead logging enables concurrent readers with a writer, reducing UI jank from background writes |
| `foreign_keys` | `ON` | Enforces referential integrity at the SQLite level — domain constraint, not application-level only |
| `synchronous` | `NORMAL` | Safe with WAL; `FULL` is unnecessarily slow on mobile |
| `busy_timeout` | `5000` (ms) | Prevents immediate `SQLITE_BUSY` errors on concurrent access |
| `cache_size` | `-20000` (20 MB) | Page cache sized for 10,000-transaction datasets; negative value sets kibibytes |

#### 2.3.3 Migration Strategy

- **Versioned migrations only.** Drift's auto-migration (`SchemaVerifier`) is used in development to detect schema drift, but production migrations are hand-written, reviewed, and committed as explicit migration steps.
- **Schema version file:** `lib/data/database/schema/` contains one `.json` schema dump per version, generated by `drift_dev`. These are committed and diffed in code review.
- **Migration wrapper:** `MigrationStrategy` with `onUpgrade` callback — each migration step is an idempotent SQL block. `onCreate` runs the full schema for fresh installs.
- **Destructive fallback:** `destroyEverything()` is explicitly disabled in production. Data loss on migration failure triggers a user-visible error requiring manual backup-restore via the export feature.
- **No migration downgrades:** Schema version is monotonically increasing. Downgrade protection is enforced by checking `schemaVersion` on open; if the on-disk version is higher than the app's compiled version, the app throws a `SchemaMismatchException` and surfaces a "please update the app" prompt.

#### 2.3.4 DAO Structure

Each domain aggregate has a dedicated DAO. DAOs are Drift `DatabaseAccessor` subclasses. They are not repositories — they execute queries, not domain logic.

| DAO | Responsibility |
|-----|---------------|
| `TransactionDao` | CRUD on `transactions` and `entries` tables, atomic transaction+entries writes |
| `AccountDao` | CRUD on `accounts` table, balance query helpers |
| `CategoryDao` | CRUD on `categories` table, tree structure queries |
| `TemplateDao` | CRUD on `recurring_templates` and `installment_templates` |
| `ExchangeRateDao` | Read/write on `exchange_rate_cache` table |
| `CurrencyDao` | Read-only access to bundled `currencies` reference table |

---

### 2.4 Navigation

#### 2.4.1 GoRouter

| Attribute | Value |
|-----------|-------|
| **Package** | `go_router ^14.6.2` |
| **Shell route** | `StatefulShellRoute.indexedStack` for the 3-tab bottom navigation shell, preserving each tab's navigation stack independently |

#### 2.4.2 Route Structure

The app uses a shell-routed 3-tab structure. Each tab is an independent `StatefulNavigationShell` branch.

```
/                             → HomeScreen (Tab 0: Home)
  /transaction/new            → CreateTransactionScreen
  /transaction/:id            → TransactionDetailScreen
  /transaction/:id/edit       → EditTransactionScreen

/accounts                     → AccountListScreen (Tab 1: Accounts)
  /accounts/:id               → AccountDetailScreen
  /accounts/new               → CreateAccountScreen

/settings                     → SettingsScreen (Tab 2: Settings)
  /settings/currency          → CurrencySettingsScreen
  /settings/categories        → CategoryManagementScreen
  /settings/categories/:id    → CategoryDetailScreen
  /settings/backup            → BackupRestoreScreen
  /settings/about             → AboutScreen
```

Modal routes (not part of the shell) are pushed as full-screen dialogs:

```
/onboarding                   → OnboardingWizardScreen (shown once on fresh install)
/filter                       → FilterSheet (bottom sheet modal)
/exchange-rate-detail         → ExchangeRateDetailScreen
```

#### 2.4.3 Navigation Rules

- The bottom navigation bar is rendered by the `StatefulShellRoute` scaffold — it is never duplicated in individual screens.
- Deep links within a tab use `context.go(...)` (replaces stack) for tab-root transitions and `context.push(...)` for stack-pushes within a tab.
- The onboarding wizard uses `redirect` guard: if `onboardingComplete` is `false` in local storage, all routes redirect to `/onboarding`.
- Route parameters are typed — `GoRouterState.pathParameters` values are parsed and validated at the route builder; invalid parameters navigate to an error screen rather than crashing.

---

### 2.5 Data Modeling and Serialization

#### 2.5.1 Freezed — Domain Entities

| Attribute | Value |
|-----------|-------|
| **Package** | `freezed_annotation ^2.4.4` |
| **Dev dependency** | `freezed ^2.5.7` |

Freezed is used exclusively for **domain layer entities and value objects**. Every domain entity is a `@freezed` class with:
- Immutable `const` constructor (enforced by Freezed's generated code).
- `copyWith` for non-destructive updates.
- `==` and `hashCode` based on field equality (structural equality, not identity).
- `when` / `maybeWhen` for sealed union types (e.g., `TransactionStatus`, `PostingCase`).

**Rule:** Freezed classes in the domain layer have zero Flutter dependencies. They do not carry `json_serializable` annotations — JSON conversion belongs in the data layer DTOs.

#### 2.5.2 json_serializable — Data Transfer Objects

| Attribute | Value |
|-----------|-------|
| **Package** | `json_annotation ^4.9.0` |
| **Dev dependency** | `json_serializable ^6.8.0` |

`json_serializable` is used for:
- **Data layer DTOs** that map to/from Drift table row types (`fromRow` / `toJson` for import-export).
- **Exchange rate API response parsing** — the HTTP response from the exchange rate API is deserialized into a DTO before being mapped to a domain `ExchangeRate` value object.
- **Backup/restore file format** — the JSON export schema uses `json_serializable` annotated classes for forward-compatible versioned serialization.

`json_serializable` is **not** used on domain entities. Domain entities have no serialization knowledge. The data layer `fromRow` / `toEntity` mapping methods are hand-written on the DAO layer, keeping the domain free of framework annotations.

#### 2.5.3 Serialization Field Naming

All `json_serializable` classes use `@JsonSerializable(fieldRename: FieldRename.snake)` to produce `snake_case` JSON keys consistent with the exchange rate API response format and the backup file schema.

---

### 2.6 Scheduling

#### 2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model

**Decision:** Hybrid scheduling using WorkManager for silent background posting and `flutter_local_notifications` with exact alarms for user-visible "remind and confirm" notifications.

| Package | Version | Role |
|---------|---------|------|
| `workmanager` | `^0.5.2` | Silent background auto-post sweep |
| `flutter_local_notifications` | `^18.0.1` | Exact-alarm "remind and confirm" notifications |

**Options evaluated:**

| Option | Pros | Cons |
|--------|------|------|
| **App-launch sweep only** | Zero permissions, zero background power | Misses postings if user does not open app on posting day |
| **AlarmManager only** | Exact timing guaranteed | Battery-heavy for frequent periodic work; `SCHEDULE_EXACT_ALARM` requires runtime user grant on API 31+ |
| **WorkManager only** | OS-managed battery efficiency; survives force-stop after device restart | Cannot guarantee exact delivery time; 15-minute minimum period; unsuitable for time-critical notifications |
| **WorkManager + Exact Alarm (chosen)** | WorkManager handles silent posting (battery-safe, OS-managed); exact alarm handles only the time-critical notification event — minimal exact alarm usage | Two scheduling systems to maintain; `SCHEDULE_EXACT_ALARM` permission still required |

**Rationale:** WorkManager is the Android-recommended mechanism for deferrable background work. It survives device restart and force-stop (with the `RECEIVE_BOOT_COMPLETED` permission), which satisfies the catch-up requirement. Exact alarms are reserved exclusively for "remind and confirm" notification delivery — the only case where the user has explicitly requested an on-time event. This minimizes exact alarm usage to the OS-permitted minimum and avoids battery-heavy always-on alarms for silent posting.

**Scheduling model:**

1. **App-launch sweep (synchronous, in `AppInitializer`):** On every cold start, before the first frame, sweep all templates and future-dated transactions with `scheduled_date <= today`. Post any overdue items synchronously. This is the primary catch-up mechanism.
2. **WorkManager periodic task (`PostingSweeperWorker`):** Registered once on install with a 6-hour minimum period. Executes the same catch-up sweep in the background when the device is idle and charging (constraints: `NetworkType.not_required`, `requiresCharging: false`, `requiresDeviceIdle: false`). Ensures postings do not wait until the user next opens the app.
3. **Exact alarm (`ReminderAlarmScheduler`):** Scheduled only for recurring templates with `posting_mode = REMIND_AND_CONFIRM`. Uses `flutter_local_notifications` `AndroidScheduleMode.exactAllowWhileIdle`. Fires the "review and confirm" notification at the template's scheduled time. If the user denies `SCHEDULE_EXACT_ALARM`, the app degrades gracefully: "remind and confirm" templates fall back to app-launch posting with a settings-screen notice.

**Permission manifest entries:** `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS` (runtime grant on API 33+).

---

### 2.7 Exchange Rate

#### 2.7.1 Decision — TC-006: fawazahmed0 Exchange API

**Decision:** Use the **fawazahmed0/exchange-api** (`cdn.jsdelivr.net/npm/@fawazahmed0/currency-api`) served via jsDelivr CDN as the exchange rate data source.

**Options evaluated:**

| API | Auth required | Free tier limits | Currency coverage | CDN-backed | Verdict |
|-----|--------------|------------------|-------------------|------------|---------|
| **fawazahmed0/exchange-api** (chosen) | None | Unlimited, no rate limits documented | 537 fiat + crypto currencies | Yes (jsDelivr global edge) | **Selected** |
| Frankfurter | None | Unlimited (open-source, ECB data) | ~33 major currencies only | No (self-hosted) | Rejected — 33-currency ceiling insufficient; no crypto |
| Open Exchange Rates | API key required (free tier) | 1,000 req/month on free tier | 170+ currencies | No | Rejected — key management on a local-only app is friction with no user benefit |
| ExchangeRate-API | API key required | 1,500 req/month free | 160+ currencies | No | Rejected — same key management friction |
| Fixer.io | API key required (paid for HTTPS) | HTTPS requires paid plan | 170+ currencies | No | Rejected — cost |
| CurrencyLayer | API key required | 100 req/month free | 168 currencies | No | Rejected — too low free tier |

**Rationale for fawazahmed0/exchange-api:**
- No API key — no secrets management problem on a local-only app.
- 537 currencies including fiat and crypto (BTC, ETH, ADA, DOGE, etc.) — full coverage of PRD §7.1 currency list with room for v2 crypto expansion.
- CDN-served via jsDelivr global edge network — high availability; no single-origin dependency.
- Updated daily; response includes a `date` field confirming the publication date.
- Zero cost, zero auth complexity. Adopted by production open-source finance apps with confirmed reliability (competitive analysis, Bonus Finding 1).

**Response format:**
```
GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{base_currency}.min.json
Response: {"date": "2024-01-15", "{base_currency}": {"eur": 0.912, "inr": 83.12, ...}}
```

**Tradeoffs accepted:**
- Single maintainer open-source project — no formal SLA or guaranteed uptime. Mitigated by aggressive caching: the 14-day stale threshold (§2.7.4) means a multi-day outage does not degrade the user experience. A provider swap (to Frankfurter or any REST-JSON API) requires changing one URL constant in `ExchangeRateService` — the abstraction boundary in §2.7.5 makes this a one-line change.
- No historical rates endpoint — only latest rates available (same limitation as Frankfurter). Variance uses only current rates, so this is not a constraint.
- CDN-cached data (jsDelivr edge may serve a rate up to ~1 hour stale). Acceptable for a daily-fetch cadence.

#### 2.7.2 Fetch Trigger and Schedule

- **Trigger:** WorkManager one-time task, enqueued on app launch if the last successful fetch is older than 23 hours (allowing a daily cadence with a 1-hour tolerance for WorkManager scheduling jitter).
- **Constraint:** `NetworkType.connected` — only fires when internet is available. No retry on failure (silent failure per TC-006 PM response).
- **Scope:** Fetch only the currencies for which the user has active accounts (TC-006 PM requirement). The query `SELECT DISTINCT currency FROM accounts WHERE is_deleted = FALSE` is executed before the network call. If the user has only one currency (the home currency), no fetch is issued.
- **Endpoint:** `GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{base_currency}.min.json` — one request per base currency needed (typically one, the home currency). The response contains all target currency rates in a single payload; no per-pair requests.
- **Timeout:** 10 seconds. On timeout, the WorkManager task exits cleanly; failure is not rethrown.

#### 2.7.3 Cache Schema

```sql
CREATE TABLE exchange_rate_cache (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    from_currency   TEXT    NOT NULL,
    to_currency     TEXT    NOT NULL,
    rate            REAL    NOT NULL,
    fetched_at      INTEGER NOT NULL,  -- Unix epoch seconds
    rate_date       TEXT    NOT NULL,  -- ISO 8601 date from API response
    UNIQUE (from_currency, to_currency)
);

CREATE INDEX idx_exchange_rate_pair ON exchange_rate_cache (from_currency, to_currency);
```

- `UNIQUE (from_currency, to_currency)` — `INSERT OR REPLACE` upserts rates on each successful fetch.
- `fetched_at` — wall-clock time of the fetch; used to compute staleness.
- `rate_date` — the publication date from the API response `date` field; shown in the UI alongside the rate.

#### 2.7.4 Staleness and Offline Fallback

| Condition | Behaviour |
|-----------|-----------|
| Rate age ≤ 14 days | Use cached rate silently |
| Rate age > 14 days | Show "Rate last updated N days ago" disclaimer inline (PRD §5.2.1 FG-C12) — transaction can still be saved |
| No rate exists for a pair | Show "Exchange rate unavailable" — home currency equivalent field is omitted from display |
| Fetch succeeds | Upsert all returned pairs; update `fetched_at` |
| Fetch fails / times out | Retain existing cache; no user notification |

#### 2.7.5 Architectural Isolation

The exchange rate service lives entirely in `lib/infrastructure/exchange_rates/`. It has no imports from the domain layer (other than `ExchangeRate` value object from `lib/domain/`). The domain layer reads rates exclusively through `ExchangeRateRepository` — an interface defined in the domain layer and implemented in the data layer. Core functionality (posting, balance calculation) has no compile-time dependency on the exchange rate infrastructure module.

The provider URL is stored as a single named constant in `ExchangeRateService`. Swapping to an alternative provider (e.g., Frankfurter) requires changing one constant and one response-parsing method — no domain or data layer changes.

---

### 2.8 Search

#### 2.8.1 Decision — TC-009: SQLite FTS5 with Dart-Side Scoring

**Decision:** SQLite FTS5 virtual table for full-text indexing, with a Dart-side scoring pass for ranking and typo-tolerance.

**Options evaluated:**

| Option | Pros | Cons |
|--------|------|------|
| **Pure Dart in-memory filtering** | Simple, no schema dependency, easy typo-tolerance | Requires loading all 10,000 records into memory; O(N) scan on every keystroke; 500ms budget (NF-3) is tight at scale |
| **SQLite FTS5 only** | Sub-millisecond index lookup; database-native; no memory pressure | FTS5 tokenizer is word-based — typo-tolerance requires custom tokenizer or secondary pass; ranking function (`bm25`) does not support field-weight bias |
| **FTS5 + Dart scoring pass (chosen)** | FTS5 narrows the candidate set to hundreds of rows; Dart pass applies field-weight ranking and typo-tolerance on the small result set; stays well within 500ms | Two-stage pipeline to maintain; FTS5 virtual table is additional schema surface |

**Rationale:** At 10,000 transactions, a pure Dart O(N) scan on every keystroke risks exceeding the 500ms budget, particularly on mid-range Android devices (PRD NF-3 baseline). FTS5 reduces the candidate set before the Dart pass, bounding the Dart work to a small result set regardless of total transaction count. This hybrid approach satisfies the performance target while enabling the fzf-style ranking the PRD requires.

#### 2.8.2 FTS5 Schema

```sql
CREATE VIRTUAL TABLE transactions_fts USING fts5(
    transaction_id UNINDEXED,
    title,
    description,
    account_name,
    category_name,
    content='transactions_search_view',
    content_rowid='rowid',
    tokenize='unicode61 remove_diacritics 2'
);
```

- `title` and `account_name` are indexed with default tokenization.
- `description` and `category_name` are included for substring matching.
- `transaction_id UNINDEXED` is stored in the FTS table for joining back to the main `transactions` table without a rowid translation.
- `content=` specifies a `transactions_search_view` that denormalizes the joined fields for FTS indexing.
- `tokenize='unicode61 remove_diacritics 2'` handles accented characters (e.g., "café" matches "cafe").

FTS5 content sync is maintained by `AFTER INSERT`, `AFTER UPDATE`, `AFTER DELETE` triggers on the `transactions` table (Drift trigger definitions in `TransactionDao`).

#### 2.8.3 Ranking Algorithm

Search is executed as a two-stage pipeline:

**Stage 1 — FTS5 prefix and exact match query (SQL):**
```sql
SELECT transaction_id, rank
FROM transactions_fts
WHERE transactions_fts MATCH '{title account_name}: "^{query}" OR {description category_name}: "{query}"'
ORDER BY rank
LIMIT 500;
```

The `^` prefix in the title/account_name clause matches prefix hits (higher rank). The full-text clause on description/category_name provides substring recall. FTS5 `rank` (`bm25` with default field weights) is used for initial ordering.

**Stage 2 — Dart scoring pass (`SearchRanker`):**

After the FTS5 query returns at most 500 candidates, the Dart `SearchRanker` assigns a composite score:

| Signal | Weight | Rationale |
|--------|--------|-----------|
| Exact match on title | 1.00 | Highest confidence — user typed the exact title |
| Prefix match on title | 0.80 | Strong intent signal |
| Prefix match on account name | 0.70 | Account names are short and memorable |
| Substring match on title | 0.60 | Less specific but still title-relevant |
| Substring match on description | 0.30 | Description is free text; lower signal |
| Substring match on category name | 0.25 | Category is navigable by other means |
| Typo-tolerant match (edit distance 1) | 0.40 (title) / 0.20 (other fields) | Applied via Dart-side Levenshtein on the candidate set |

**Tiebreaker:** Equal scores sort by `transaction_date DESC` (most recent first, per TC-009 PM requirement).

**Typo tolerance:** Levenshtein distance-1 matching is applied in Dart on the candidate set returned by FTS5 (at most 500 rows). This is computationally bounded regardless of total transaction count.

#### 2.8.4 Search Scope

- Search operates on the active (non-deleted) transaction set only.
- The month filter on the home screen and the search query are combined — FTS5 query is augmented with a `WHERE transaction_date BETWEEN :start AND :end` join on the main table (TC-050 scoping per PM response).
- Unified transaction list search (all-time) uses the FTS5 table without a date filter.

---

### 2.9 Error Handling Patterns

#### 2.9.1 Decision — TC-033: Result Type Pattern

**Decision:** Standardize on a `Result<T, E>` sealed type for all repository and use case return values. Exception-based error propagation is permitted only within a single layer and must not cross layer boundaries.

**Options evaluated:**

| Option | Pros | Cons |
|--------|------|------|
| **Exception-based (throw/catch)** | Familiar to most Dart developers; less boilerplate for happy path | Exceptions are invisible in type signatures; callers can silently ignore error paths; hard to exhaustively handle in UI |
| **Result type (chosen)** | Error paths are explicit in the type signature; callers must handle both branches; `sealed` + `switch` gives exhaustive compile-time checking; aligns with Dart 3 pattern matching idioms | Slightly more verbose in the happy path; requires a thin `Result` type definition |

**Rationale:** Variance is a financial app. Every ledger write failure must be surfaced to the user (TC-033 PM requirement: no silent failures, preserved form state). The Result type makes it structurally impossible to forget the error case — the UI presenter cannot call `.value` without handling `.error` first. Combined with Dart 3 sealed classes and exhaustive switch, this produces compile-time-verified error handling across all ledger operations.

#### 2.9.2 Result Type Definition

```dart
// lib/domain/core/result.dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
```

`Failure` is a sealed hierarchy covering all domain error types:

```dart
// lib/domain/core/failure.dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class DatabaseFailure extends Failure { ... }
final class ValidationFailure extends Failure { ... }
final class NetworkFailure extends Failure { ... }
final class NotFoundFailure extends Failure { ... }
final class BusinessRuleFailure extends Failure { ... }
```

#### 2.9.3 Layer-Boundary Rules

| Layer | Error handling rule |
|-------|---------------------|
| **Data layer (DAOs, repositories)** | Catches `DriftDatabaseException` and `SqliteException`; wraps in `Err(DatabaseFailure(...))`. Never rethrows raw exceptions across the boundary. |
| **Domain layer (use cases)** | Returns `Result<T>`. Business rule violations (e.g., posting to a deleted account) return `Err(BusinessRuleFailure(...))`. Never throws. |
| **Presentation layer (notifiers)** | Receives `Result<T>` from use cases. Maps `Err` to a `ScreenState.error(message)` variant. Sets `AsyncValue.error` via `AsyncNotifier`. Never swallows errors. |
| **Infrastructure layer** | Internal exceptions (network timeout, JSON parse error) are caught and converted to `Err(NetworkFailure(...))` before crossing into the domain. |

#### 2.9.4 Ledger Operation Failure Modes

| Failure mode | ACID guarantee | User experience |
|--------------|---------------|-----------------|
| Database write fails mid-transaction | Full rollback (Drift wraps in SQLite transaction) | "Unable to save this transaction. Please try again." — form data preserved in notifier state |
| Validation failure before write | No DB access attempted | Inline field error on the form — no toast or dialog |
| Reversal succeeds but correction fails | Full rollback — both operations are in a single `database.transaction(() {...})` call | "Unable to update this transaction. Please try again." — form data preserved |
| Account balance would go negative (future rule) | Rejected at use case level before DB write | `BusinessRuleFailure` → inline error message |
| Foreign key violation (e.g., deleted account referenced) | DB rejects insert; rolled back | `DatabaseFailure` mapped to generic retry message |

#### 2.9.5 Form State Preservation

The `TransactionFormNotifier` (a Riverpod `Notifier`) holds the full form state. On save failure, the notifier transitions to `FormState.saveError(message)` while retaining all field values. The form screen observes this state and shows a `SnackBar` with the error message — form fields remain populated and editable. The user can correct any issue and retry without re-entering data.

---

### 2.10 Code Generation Pipeline

#### 2.10.1 Build Runner

| Attribute | Value |
|-----------|-------|
| **Package** | `build_runner ^2.4.13` (dev dependency) |
| **Execution mode** | Single-shot (`dart run build_runner build --delete-conflicting-outputs`) for CI and clean builds. Watch mode (`dart run build_runner watch`) for local development. |

#### 2.10.2 Generator Execution Order

`build_runner` resolves generator order via declared input/output file extensions. The effective execution order is:

```
1. drift_dev          →  *.drift.dart, *.g.dart (DAO queries, table definitions)
2. freezed            →  *.freezed.dart (domain entities, union types)
3. json_serializable  →  *.g.dart (DTO fromJson/toJson)
4. riverpod_generator →  *.g.dart (provider declarations)
```

Drift must run before Riverpod because DAOs and table row types generated by Drift are referenced in repository provider declarations.

#### 2.10.3 Output File Conventions

| Generator | Output extension | Committed to repo? |
|-----------|----------------|--------------------|
| `drift_dev` | `*.g.dart` | No — generated |
| `freezed` | `*.freezed.dart` | No — generated |
| `json_serializable` | `*.g.dart` | No — generated |
| `riverpod_generator` | `*.g.dart` | No — generated |

All `*.g.dart` and `*.freezed.dart` files are listed in `.gitignore`. They are regenerated in CI as the first build step before compilation.

#### 2.10.4 CI Build Sequence

```
1. flutter pub get
2. dart run build_runner build --delete-conflicting-outputs
3. dart analyze
4. dart format --set-exit-if-changed .
5. flutter test
6. flutter build apk --release (for release CI only)
```

---

### 2.11 Testing Stack

#### 2.11.1 Test Pyramid Targets

| Test type | Coverage target | Tooling |
|-----------|----------------|---------|
| Unit (domain + use cases) | 90% line coverage | `flutter_test` |
| Unit (repositories + DAOs) | 85% line coverage | `flutter_test` + Drift in-memory DB |
| Widget tests | All non-trivial widgets | `flutter_test` |
| Golden tests | All screens, key states (empty, loaded, error) | `alchemist ^0.8.0` |
| Integration tests | Critical user flows (create transaction, edit transaction, balance check) | `integration_test` |
| **Overall minimum** | **80%** | — |

#### 2.11.2 Unit Testing

| Attribute | Value |
|-----------|-------|
| **Framework** | `flutter_test` (included with Flutter SDK — no separate package) |
| **Mocking** | `mocktail ^1.0.4` — type-safe mocking without code generation; fakes preferred over mocks for repository boundaries |
| **Drift in-memory DB** | `NativeDatabase.memory()` from `drift` package — used in repository unit tests to exercise real SQL queries without file I/O |

**Rule:** Domain use cases are tested against fake repository implementations (handwritten classes that implement the repository interface), not mocks. Mocks are used only for infrastructure boundaries (network client, notification scheduler) where the implementation detail is irrelevant to the test.

#### 2.11.3 Widget Testing

Standard `flutter_test` `WidgetTester`. Providers are overridden in a `ProviderScope` wrapper around the widget under test. No `BuildContext` threading — all state is injected via Riverpod overrides.

#### 2.11.4 Golden Tests

| Attribute | Value |
|-----------|-------|
| **Package** | `alchemist ^0.8.0` |
| **Strategy** | Per-screen golden snapshots for: empty state, loading state, populated state, error state |
| **CI enforcement** | `alchemist` `--ci` mode in CI pipeline; mismatches are build failures |
| **Update workflow** | Goldens are updated locally by the developer with `--update-goldens`; updated snapshots are committed and reviewed in PR |
| **Platform baseline** | Goldens are captured on a fixed Android emulator (API 34, Pixel 6 form factor) to ensure consistent rendering |

The founder is the visual reviewer for golden test failures in code review (per project visual testing strategy).

#### 2.11.5 Integration Tests

`integration_test` package (Flutter SDK). Critical flows tested end-to-end on device/emulator:

1. Onboarding → create first account → create first transaction → verify balance.
2. Create recurring template → advance clock → verify auto-post on app launch.
3. Edit transaction (non-financial field) → verify in-place update.
4. Edit transaction (financial field) → verify reversal + correction pair.
5. Delete account → verify soft-delete and balance zeroing.

---

### 2.12 Build and Release Tooling

#### 2.12.1 App Icon Generation

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_launcher_icons` | `^0.14.3` (dev) | Generates all Android mipmap icon densities from a single source PNG |

Configuration is in `flutter_launcher_icons.yaml`. The icon source file is `assets/icon/app_icon.png` (1024×1024, no transparency). Adaptive icon foreground and background layers are specified separately for Android API 26+ adaptive icon support.

#### 2.12.2 Splash Screen

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_native_splash` | `^2.4.3` (dev) | Generates Android 12 splash screen XML and pre-API-31 launch theme |

Configuration is in `flutter_native_splash.yaml`. The splash uses the app's seed color as background with the icon centered. Dark mode variant is specified separately.

#### 2.12.3 ProGuard / R8

`flutter build apk --release` and `flutter build appbundle --release` enable R8 by default. The project maintains `android/app/proguard-rules.pro` with explicit keep rules for:

- Drift reflection stubs (Drift requires keeping database class names for SQLite open).
- `json_serializable` generated classes (if used in any reflection-dependent path).
- `workmanager` worker class names (WorkManager resolves worker classes by name at runtime).
- `flutter_local_notifications` receiver and service classes.

#### 2.12.4 Build Flavors

Three build flavors are defined in `android/app/build.gradle`:

| Flavor | Application ID suffix | Purpose |
|--------|----------------------|---------|
| `dev` | `.dev` | Local development — verbose logging, debug overlay |
| `staging` | `.staging` | QA and pre-release testing — release-mode build, test data seeding permitted |
| `prod` | _(none)_ | App Store submission — no debug output, no test data |

Flavor-specific configuration (API endpoint for exchange rates, logging level) is injected via `dart-define-from-file` from flavor-specific `.env.json` files. These files are not committed — they are populated in CI from secrets.

#### 2.12.5 Version Management

Version is controlled exclusively via the `version` file at the repo root (owner: founder). The `pubspec.yaml` `version` field is kept in sync with the `version` file by a CI check — a mismatch is a build warning, not a failure, to avoid blocking the founder's workflow.

---

### 2.13 Linting and Static Analysis

#### 2.13.1 Analysis Configuration

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_lints` | `^5.0.0` (dev) | Flutter-recommended lint ruleset, extends `lints` |

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml` with the following additional rules enabled:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    dead_code: warning
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    always_use_package_imports: true
    avoid_dynamic_calls: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_locals: true
    require_trailing_commas: true
    use_string_buffers: true
    avoid_positional_boolean_parameters: true
    use_super_parameters: true
```

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis to avoid false positives from generator output.

#### 2.13.2 Formatting and Auto-Fix

- **`dart format`:** Enforced in CI (`dart format --set-exit-if-changed .`). Line length: 80 characters (Dart default).
- **`dart fix`:** Run locally as a pre-commit step. Fixes are committed before pushing. CI does not run `dart fix` automatically to avoid non-deterministic CI mutations.
- **Pre-commit hook:** Defined in `.git/hooks/pre-commit` (installed via `scripts/install-hooks.sh`). Runs `dart format` and `dart analyze` on staged Dart files.

---

### 2.14 Complete Dependency Table

All packages use `^` (caret) constraints. Version numbers reflect the latest stable release as of April 2026. Versions are to be validated against pub.dev at project initialisation and pinned in `pubspec.lock`.

#### 2.14.1 Production Dependencies

| Package | Version constraint | Purpose |
|---------|-------------------|---------|
| `flutter_riverpod` | `^2.6.1` | State management and DI graph |
| `riverpod_annotation` | `^2.3.5` | `@riverpod` annotations for code-gen providers |
| `drift` | `^2.21.0` | Type-safe SQLite ORM with reactive streams |
| `sqlcipher_flutter_libs` | `^0.3.0` | SQLCipher-encrypted SQLite for Android — replaces plain `sqlite3_flutter_libs` |
| `go_router` | `^14.6.2` | Declarative routing with deep link and shell route support |
| `freezed_annotation` | `^2.4.4` | Immutable data class annotations |
| `json_annotation` | `^4.9.0` | JSON serialization annotations for DTOs |
| `workmanager` | `^0.5.2` | Android WorkManager for background posting sweeps |
| `flutter_local_notifications` | `^18.0.1` | Exact-alarm "remind and confirm" notifications |
| `http` | `^1.2.2` | Exchange rate API HTTP client |
| `dynamic_color` | `^1.7.0` | Material You dynamic color from Android 12 wallpaper |
| `flutter_secure_storage` | `^9.2.2` | Secure storage for PIN and sensitive preferences |
| `intl` | `^0.19.0` | Date/number formatting, locale-aware display |
| `path_provider` | `^2.1.4` | Platform-aware paths for database and export files |
| `share_plus` | `^10.1.2` | Share/export backup files via Android share sheet |
| `file_picker` | `^8.1.4` | Import backup files from device storage |
| `image_picker` | `^1.1.2` | Attach photos to transactions (camera and gallery) |
| `flutter_image_compress` | `^2.3.0` | Photo compression before storage (TC-007) |
| `path` | `^1.9.0` | File path utilities |
| `collection` | `^1.18.0` | Extended collection utilities (`groupBy`, `sorted`) |
| `decimal` | `^3.0.2` | Arbitrary-precision decimal arithmetic for currency amounts |
| `material_symbols_icons` | `^4.2832.0` | Curated vector icon set for category icons (TC-014; ~250 icon subset, tree-shaken) |
| `local_auth` | `^2.3.0` | Biometric and device-credential authentication for sensitive account detail lock (PRD §5.4.6) |

#### 2.14.2 Development Dependencies

| Package | Version constraint | Purpose |
|---------|-------------------|---------|
| `riverpod_generator` | `^2.4.3` | Code generator for `@riverpod` annotated providers |
| `riverpod_lint` | `^2.3.13` | Lint rules enforcing Riverpod best practices |
| `drift_dev` | `^2.21.0` | Code generator for Drift table definitions and DAOs |
| `freezed` | `^2.5.7` | Code generator for `@freezed` immutable data classes |
| `json_serializable` | `^6.8.0` | Code generator for `@JsonSerializable` DTOs |
| `build_runner` | `^2.4.13` | Build system orchestrating all code generators |
| `mocktail` | `^1.0.4` | Type-safe mocking for unit tests |
| `alchemist` | `^0.8.0` | Golden test framework with CI comparison support |
| `flutter_lints` | `^5.0.0` | Flutter lint ruleset |
| `flutter_launcher_icons` | `^0.14.3` | Generates Android adaptive icon assets |
| `flutter_native_splash` | `^2.4.3` | Generates Android 12 splash screen assets |

#### 2.14.3 Dependency Notes

- **`decimal` over `double` for amounts:** All monetary amounts are stored and computed using the `decimal` package's `Decimal` type. `double` is forbidden for financial arithmetic. Amounts are persisted in SQLite as `INTEGER` (smallest currency unit, e.g., paise for INR, cents for USD) and converted to `Decimal` at the DAO boundary.
- **`http` over `dio`:** A single exchange rate endpoint with no interceptor chain, retry middleware, or auth headers does not justify `dio`'s overhead. `http` is lighter and sufficient.
- **`sqlcipher_flutter_libs` replaces `sqlite3_flutter_libs`:** Plain SQLite is not acceptable for a personal finance app. `sqlcipher_flutter_libs` drops in as the SQLite binding for Drift with no query-API changes; only the database open call is augmented with the encryption key. Must be kept in sync with `drift`'s tested SQLCipher version — check `drift` changelog and `sqlcipher_flutter_libs` release notes on every `drift` version bump.
- **SQLCipher key management:** The database key is generated on first launch, stored in Android Keystore via `flutter_secure_storage`, and retrieved on every subsequent open. The key is never written to SharedPreferences, logs, or any plaintext storage. Loss of the key (e.g., uninstall, wiped Keystore) means the database is unrecoverable — this is by design for a local-only app with no cloud sync.
- **`material_symbols_icons` tree-shaking:** Import only named constants from the curated ~250-icon subset. Do not import the full symbol set. The exact subset is defined during the icon curation task (TC-014 dependency for category seeding). Each icon constant is a `const IconData`; unused constants are tree-shaken by the Dart compiler at build time. Use `MaterialSymbols` class with selective imports, not `Icons.xxx`.
- **`local_auth` scope:** Used exclusively to authenticate the user before displaying sensitive account fields (card numbers, bank account numbers). Not used to gate app launch or core functionality (PRD §5.4.6.1). The `BiometricType` availability check determines whether to show biometric or fall back to the in-app PIN flow.

---

### 2.15 Photo Compression

#### 2.15.1 Decision — TC-007: JPEG Compression with 1920px Cap

**Decision:** Use `flutter_image_compress` to compress all photo attachments to JPEG before on-device storage.

| Parameter | Value | Source |
|-----------|-------|--------|
| Output format | JPEG | TC-007 PM response |
| Max dimension (width or height) | 1920 px | TC-007 PM response |
| Target file size | < 500 KB | TC-007 PM response (guideline, not hard cap) |
| JPEG quality | 85 (starting point) | SDS decision — within "legible for receipt text" floor |
| Upscale images smaller than 1920px | No | TC-007 PM response |
| Preserve original | No | TC-007 PM response |

**Compression pipeline:**

1. User selects photo via `image_picker` (camera or gallery).
2. `PhotoCompressionService` runs `flutter_image_compress` synchronously on a background thread (the package uses isolates internally).
3. If the result exceeds 500 KB at quality 85, reduce quality in 5-point steps until < 500 KB or quality reaches 60 (floor — below this, receipt text may be illegible).
4. Store the compressed bytes in `getApplicationDocumentsDirectory()/attachments/{uuid}.jpg`.
5. Record the file path in the `attachments` table.

**Why JPEG quality 85:** Industry baseline for legible document/receipt scans. The iterative reduction handles edge cases (high-detail images, low compression ratio scenes) without requiring a fixed quality parameter that may fail the legibility floor for some inputs.

---

### 2.16 Currency Bundle

#### 2.16.1 Decision — TC-044: Bundled ISO 4217 Static Asset

**Decision:** Bundle the full active ISO 4217 currency list as a static JSON asset. No runtime network fetch.

| Attribute | Value | Source |
|-----------|-------|--------|
| Source | ISO 4217 active currencies | TC-044 PM response |
| Scope | ~180 active currencies; obsolete excluded | TC-044 PM response |
| Fields per entry | `code`, `name`, `symbol`, `minor_units` | TC-044 PM response |
| Asset path | `assets/data/currencies.json` | SDS decision |
| Maintenance | Updated via app update if ISO list changes | TC-044 LE note |

**Asset schema (per currency entry):**
```json
{
  "code": "USD",
  "name": "US Dollar",
  "symbol": "$",
  "minor_units": 2
}
```

**`minor_units` usage:**

| Context | Rule |
|---------|------|
| Amount input field | Decimal keyboard restricts to `minor_units` decimal places. JPY (`minor_units=0`): no decimal point accepted. BHD (`minor_units=3`): up to 3 places. |
| Amount display | Format to `minor_units` decimal places. |
| Storage | Amounts stored as `INTEGER` in minor units (e.g., 50000 = USD $500.00). |
| Exchange rate storage | Rates stored with 6 decimal places of precision (`rate_micro` as integer, divide by 1,000,000). |

**Loading strategy:** `CurrencyRepository` loads the asset once on app startup via `rootBundle.loadString`, parses into a `List<Currency>` domain object, and holds it in a `keepAlive` Riverpod provider. No DB table needed for the reference list (read-only static data). The `currencies` table in the schema is the in-DB representation used by foreign key references and joins — it is seeded from this asset on fresh install.

---

### 2.17 Backup Format

#### 2.17.1 Decision — TC-054: Versioned ZIP Archive with Manifest

**Decision:** Backup is a ZIP archive containing a manifest file plus a database export. The manifest enables forward-compatible restore in v2.

| Attribute | Value | Source |
|-----------|-------|--------|
| Archive format | ZIP | PRD §5.4.10 |
| Manifest filename | `manifest.json` | SDS decision |
| Export filename | `variance_export.json` | SDS decision |

**Manifest schema (v1):**
```json
{
  "backup_format_version": 1,
  "app_version": "1.0.0",
  "created_at": "2026-04-21T10:00:00Z",
  "schema_version": 1
}
```

| Field | Type | Purpose |
|-------|------|---------|
| `backup_format_version` | `integer` | Incremented when backup structure changes. v2 restore reads this to select the correct importer. |
| `app_version` | `string` | Semver of the app that created the backup. |
| `created_at` | `string` (ISO 8601 UTC) | Backup timestamp. |
| `schema_version` | `integer` | DB schema version at time of backup. Used by v2 importer to detect schema migrations needed. |

**Export content:** `variance_export.json` is a `json_serializable`-annotated full-data export (all non-deleted entities serialized using versioned DTOs). Soft-deleted entities are excluded from export (they are recoverable via the ledger correction chain, not needed for restore).

**v1 constraint:** v1 ships export only. Import/restore is v2. The manifest is a forward-compatibility requirement baked into v1 so v2 can detect and handle v1 backups.

---

### 2.18 Theming Architecture

#### 2.18.1 Decision: Type-Safe ThemeExtension

**Decision:** `ThemeExtension<VarianceColors>` with named getters. No string-keyed color lookups.

| Attribute | Value | Source |
|-----------|-------|--------|
| Base | `ColorScheme.fromSeed()` | Material 3 standard |
| Dynamic color | `DynamicColorBuilder` from `dynamic_color` package | TC-048; PRD §5.4.1 |
| Fallback (OEM restriction) | Custom seed color from `app_settings.color_seed` | TC-048 PM clarification |
| User preference | `app_settings.color_scheme_mode`: `dynamic` or `custom` | PRD §5.4.1 |
| Custom token layer | `ThemeExtension<VarianceColors>` — named getters, compile-time safe | Competitive analysis §5 |

**`VarianceColors` semantic tokens (minimal set):**

| Token | Purpose |
|-------|---------|
| `incomeAmount` | Positive financial amounts (green shade, theme-adaptive) |
| `expenseAmount` | Negative financial amounts (red shade, theme-adaptive) |
| `warningAmount` | Budget/threshold warning (orange shade, theme-adaptive) |
| `accentPastel` | Lightened/darkened accent for category chips, surfaces |

All other color roles use Material 3 `ColorScheme` built-in tokens directly (29 roles cover the remaining surfaces). Tokens are added to `VarianceColors` only when `ColorScheme` roles are insufficient.

**Why `dynamic_color` over `system_theme` package:** `dynamic_color` is the official Google-maintained package for Material You wallpaper-based color extraction. `system_theme` (used by the reference open-source app) requires manual `Color.alphaBlend` blending and has known Samsung OEM bugs. No advantage over the official approach.

---

## 3. Performance Constraints

### 3.1 Latency Budgets

| Operation | Budget | Source |
|-----------|--------|--------|
| Cold start (mid-range hardware) | < 2 s | NF-3 |
| Transaction list render (10,000 records) | < 500 ms | NF-3 |
| Search results (10,000 records) | < 500 ms | TC-009 |
| Batch category migration (N = 500) | < 5 s | TC-034 |
| Account balance read | O(1) via indexed query | §1.4.4 |

### 3.2 Frame Rate Requirements

| Context | Target |
|---------|--------|
| List scroll (transaction list, account list) | 60 fps — no jank |
| Home screen rebuild | 60 fps — no jank |

- No expensive ops (DB queries, Decimal arithmetic) in `build()`.
- Heavy computation (e.g., balance aggregation) runs in `Isolate` or background `Provider` via `AsyncNotifier`.

### 3.3 Query Performance Rules

#### 3.3.1 Index Requirements

All filter columns and join columns must be indexed. See `data-model.md §13` for full catalogue. Key indexes:

| Query pattern | Index |
|---------------|-------|
| Default transaction list (status + purpose filter) | `idx_txn_status_purpose` |
| Date range queries | `idx_txn_date` |
| Account ledger (entries by account) | `idx_entries_account` |
| Balance computation (debit/credit split) | `idx_entries_account_side` |
| Scheduler sweep (overdue recurring) | `idx_sched_occ_status_date`, `idx_templates_next` |
| Category aggregation | `idx_entries_category` |
| Search (FTS5) | `transactions_fts` virtual table |

#### 3.3.2 Query Rules

- No N+1 queries. Entry lists fetched in single JOIN with parent transaction.
- No unbounded queries. All list queries require `LIMIT` + cursor/offset pagination.
- Soft-delete filter (`WHERE is_deleted = FALSE`) applied at DAO layer, backed by `idx_accounts_deleted`.
- Balance is computed via SQL aggregate (`SUM`) over `entries` — never iterated in Dart.

### 3.4 Date and Period Arithmetic

- All period calculations use O(1) direct arithmetic. No forward-iteration loops. (§1.6.10)
- Formula: `periodIndex = (today − startDate) ~/ periodLength`
- Variable-length periods (monthly, yearly) use `DateTime` constructor overflow arithmetic.
- Implementation: `domain/services/period_calculator.dart` — pure, stateless, no Flutter dependency.

### 3.5 Memory and Storage Budgets

| Resource | Budget | Rationale |
|----------|--------|-----------|
| APK install size | < 50 MB | Mobile install size baseline |
| Photo attachment (per photo) | < 500 KB after JPEG compression | TC-007 |
| Photo max dimension | 1920 px (longest side) | TC-007; legibility floor |
| Original photo | Not preserved — compressed only | TC-007 |
| In-memory state | Only active screen providers loaded | Riverpod `autoDispose` |

### 3.6 Background Task Constraints

| Task | Mechanism | Constraint |
|------|-----------|------------|
| Recurring auto-post sweep | WorkManager periodic | OS-scheduled; no wall-clock guarantee |
| Remind-and-confirm notifications | `flutter_local_notifications` exact alarm | `SCHEDULE_EXACT_ALARM` permission; battery cost justified by user-visible event only |
| On-launch catch-up sweep | Synchronous in `main.dart` init | Must complete before first frame render; keep < 200 ms |
| Exchange rate fetch | WorkManager opportunistic | Failure must never block any user flow (§1.6.5) |

### 3.7 Batch Operation Thresholds

| Operation | Threshold | Behaviour |
|-----------|-----------|-----------|
| Category migration progress dialog | N > 10 | Show "Migrating... [X of N]" dialog |
| Category migration extra confirmation | N > 50 | Show "N transactions will be migrated. Cannot be undone." |
| Category migration implementation | Any N | Single DB transaction with batched writes; atomic (TC-034) |

### 3.8 File Size Constraint

- Max 800 lines per source file in `lib/`. Target 200–400 lines. (§1.6.9)
- Drift `@DriftDatabase` class: < 100 lines (table registrations + DAO declarations only).
- Enforced at code review; PRs with files > 800 lines are rejected.

---

## 4. Security Considerations

### 4.1 Threat Surface Summary

| Surface | Exposure | Mitigation |
|---------|----------|-----------|
| SQLite database on disk | Full read if rooted or backup-extracted | SQLCipher AES-256 at rest (§2.3.1) |
| SQLCipher key | Exposure if stored in plaintext | Android Keystore hardware-backed; accessed via `flutter_secure_storage` only |
| Sensitive account fields (card/account numbers) | Column-level exposure | Encrypted column `detail_value_encrypted` in `account_details` (§3.2) |
| Backup zip exported to user-chosen location | Plain filesystem; shared storage | User-controlled path; no auto-upload; sensitive fields AES-encrypted inside zip |
| Exchange rate HTTP fetch | Only outbound network surface | Scoped to `infrastructure/exchange_rates/`; failure never blocks core flows (§1.6.5) |
| Android auto-backup | Could expose DB to Google cloud | DB file must be excluded from Android auto-backup manifest (see §4.5) |
| Logcat (dev builds) | Financial amounts in debug output | PII/amounts stripped from release build logs (see §4.6) |
| In-app user action / error logs | Persistent files with financial context | `filesDir` only; excluded from backup; cleared on data wipe (see §4.7) |
| App lock bypass | PIN brute-force | 5-attempt lockout, 1-hour timeout, wipe at 15 failures (PRD §5.4.6.4) |

---

### 4.2 Local Data Protection

#### 4.2.1 Database Encryption

- **SQLCipher AES-256** encrypts the entire `variance.db` at page level.
- Key generated on first launch; never stored in plaintext, SharedPreferences, or logs.
- Key lives in **Android Keystore** (hardware-backed on supported devices); retrieved via `flutter_secure_storage` on every DB open.
- Key loss (uninstall, wiped Keystore) = unrecoverable DB. Acceptable: no cloud sync in v1.
- No unencrypted migration path — database is created encrypted from day one.

#### 4.2.2 Sensitive Field Encryption

- `account_details.detail_value_encrypted` stores card numbers and account numbers as AES-encrypted blobs (§3.2).
- Plain-text `detail_value` is used only for non-sensitive fields (bank name, branch, etc.).
- Revealed only after lock authentication (PRD §5.4.6.1).

#### 4.2.3 Storage Location

- All app data (`variance.db`, photos, logs) in `getApplicationDocumentsDirectory()` / `filesDir` — app-private, not world-readable.
- No files written to external shared storage except user-initiated backup export (via system file picker).

---

### 4.3 Biometric / App Lock

#### 4.3.1 Scope (PRD §5.4.6.1)

- Lock protects **sensitive account detail fields only** (card numbers, account numbers).
- Core features (transactions, balances, accounts list) always accessible without auth.
- No whole-app lock.

#### 4.3.2 Lock Mechanism (PRD §5.4.6.2)

| Priority | Mechanism | Condition |
|----------|-----------|-----------|
| 1 | Android Keyguard (biometrics / device PIN) | Device lock configured |
| 2 | Device-level per-app biometric lock | OS supports it |
| 3 | In-app PIN | Fallback only |

- Lock re-engages on app backgrounding per configured timeout (`Immediately` default).
- In-app PIN hash stored in `flutter_secure_storage` (Keystore-backed).

#### 4.3.3 Failed PIN Lockout (PRD §5.4.6.4)

| Event | Action |
|-------|--------|
| 5 consecutive failures | 1-hour lockout; no further attempts accepted |
| 15 total failures (3 cycles) | `detail_value_encrypted` rows deleted; transaction history unaffected |
| Successful auth | Failure count reset |

#### 4.3.4 PIN Recovery (PRD §5.4.6.3)

- Reset only via device credential (Android Keyguard).
- No email recovery, no cloud recovery. Local-only by design.

---

### 4.4 Backup Exposure

#### 4.4.1 User-Initiated Backup (PRD §5.4.10.1)

| Item | Included | Notes |
|------|----------|-------|
| `variance.db` | Yes (encrypted) | SQLCipher-encrypted; unreadable without key |
| `account_details` sensitive fields | Yes (encrypted) | `detail_value_encrypted` blobs included |
| Transaction photos | Yes | Attached images bundled in zip |
| `manifest.json` | Yes (required) | `backup_format_version`, `app_version`, `created_at`, `schema_version` (TC-054) |

- User selects destination via system file picker. App does not auto-upload.
- No v1 restore path — export only.

#### 4.4.2 Android Auto-Backup

- **`variance.db` MUST be excluded** from Android auto-backup (`android/app/res/xml/backup_rules.xml`).
- **`flutter_secure_storage` key material** is automatically excluded (Keystore-backed; not backed up by Android).
- Log files (§4.7) MUST be excluded from backup rules.
- OQ-SDS-SC-001: Confirm `flutter_secure_storage` backup exclusion behavior on all supported API levels (31+).

---

### 4.5 Network Surface

> Zero-network constraint: §1.6.5. This section scopes the single exception.

| Endpoint | Trigger | Scope |
|----------|---------|-------|
| `cdn.jsdelivr.net/gh/fawazahmed0/...` (exchange rates) | WorkManager background task | `infrastructure/exchange_rates/` only |

- No user credentials, device IDs, or financial data transmitted.
- Failure = staleness warning in UI; never blocks transaction save.
- Domain layer reads only from local cache (`exchange_rate_cache` table).
- No other outbound HTTP in v1.

---

### 4.6 Dev Log Hygiene (Release Builds)

- `dart:developer log` calls are used in debug/profile; suppressed or no-op in release.
- **No raw amounts, account numbers, card numbers, or PII** in any `log()` call.
- ProGuard/R8 (§2.12.3) strips unused debug symbols in release APK.
- `firebase_crashlytics` (opt-in flavour) captures stack traces only — zero financial data in crash payloads.

---

### 4.7 Persistent Log Files

| Log type | Purpose | Location | Backup | Cleared on |
|----------|---------|----------|--------|------------|
| User action log | Audit trail (if implemented) | `filesDir/logs/` | Excluded from backup manifest | Full data wipe |
| Error / crash log | Offline diagnostics | `filesDir/logs/` | Excluded from backup manifest | Full data wipe |

- Both logs are **app-private** (`filesDir`); not accessible to other apps.
- Must **never** contain raw amounts, account numbers, or card numbers.
- OQ-SDS-SC-002: Confirm whether a persistent user action log is in v1 scope (not yet specified in PRD). If yes, define retention limit.

---

### 4.8 Ledger History Tamper-Resistance

- Posted entries never `UPDATE`d. Financial corrections produce reversal + correction pair (§1.6.7).
- Soft-deletes are `status='voided'` + a `purpose='reversal'` insert — original row preserved (§11.3 data-model).
- No physical row deletion for transactions (hard-delete not supported).
- `corrects_transaction_id` chain is immutable once written; integrity enforced at domain layer (not DB FK, to avoid cascade complications).

---

### 4.9 Input Validation

| Boundary | Validation location | Enforcement |
|----------|--------------------|----|
| User form input | Presentation layer (form validators) | Immediate UI feedback |
| Domain invariants (amounts, dates, account types) | Domain layer use cases | `Result.failure` returned; never throws to UI |
| Repository writes | Data layer DAOs | Type-safe Drift DSL; parameterized queries only |
| Backup import (v2) | Not applicable in v1 | — |

- No raw SQL string concatenation anywhere. Drift DSL + parameterized queries only.
- All amounts stored as `INTEGER` minor units; no floating-point arithmetic at persistence boundary.

---

### 4.10 Permissions

| Permission | Purpose | When requested |
|-----------|---------|----------------|
| `POST_NOTIFICATIONS` (API 33+) | Recurring remind-and-confirm; CC payment reminders | On first use of scheduling feature |
| `SCHEDULE_EXACT_ALARM` | Exact-time notification delivery | On first use |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Lock auth delegation to Keyguard | On first access to sensitive account details |
| `INTERNET` | Exchange rate fetch | Declared in manifest; no runtime prompt |
| Storage (via SAF) | Backup export to user-chosen path | System file picker; no `READ/WRITE_EXTERNAL_STORAGE` |

- Minimum permission footprint. No location, contacts, or camera permissions in v1.
- OQ-SDS-SC-003: Confirm whether `CAMERA` permission is needed for photo attachments or if the SAF/photo picker path avoids it.

---

## 5. Cross-cutting Concerns

### 5.1 Logging

Three distinct subsystems. Each is independent.

#### 5.1.1 Dev Logs (transient)

| Property | Value |
|----------|-------|
| API | `dart:developer log()` only |
| Tags | `DB`, `STATE`, `NAV`, `ERROR` |
| Release behavior | Silent — `assert`-guarded or stripped by R8 (§2.12.3) |
| PII rule | No amounts, no field values, no entity content in messages |
| Entity IDs | Permitted in dev logs; stripped from persistent logs |

#### 5.1.2 User Action Log (persistent)

- **Purpose:** Local audit trail of all user-initiated mutations.
- **Covered events:** create / edit / delete / void transactions; account changes; category changes; settings changes.
- **Storage path:** `filesDir/logs/actions/` — app-private, not world-readable.
- **Android auto-backup:** Excluded (see §4.7 when written; declared in `res/xml/backup_rules.xml`).

**Format — append-only structured lines:**

| Field | Value |
|-------|-------|
| `ts` | ISO-8601 timestamp (UTC) |
| `action` | Enum string — `CREATE`, `EDIT`, `DELETE`, `VOID`, `ACCOUNT_CHANGE`, `CATEGORY_CHANGE`, `SETTINGS_CHANGE` |
| `entity_type` | Enum string — `TRANSACTION`, `ACCOUNT`, `CATEGORY`, `SETTING` |
| `entity_id` | UUID — opaque; no user-readable content |

- No raw amounts, no currency codes, no display text.

**Rotation policy:**

| Property | Limit |
|----------|-------|
| Max file size | 2 MB |
| Max files | 5 (oldest purged at limit) |
| Total budget | ≤ 10 MB |
| Purge trigger | Rotation limit hit OR full data wipe |

#### 5.1.3 Error / Crash Log (persistent)

- **Purpose:** Silent local capture of unhandled errors and caught exceptions.
- **Storage path:** `filesDir/logs/errors/` — same privacy rules as §5.1.2.
- **Android auto-backup:** Excluded (same rule as §5.1.2).
- **No automatic remote transmission** — zero telemetry (§1.6.5).
- **Export:** User-initiated share sheet only (support use case).
- **Purge:** On full data wipe.

**Format:**

| Field | Value |
|-------|-------|
| `ts` | ISO-8601 timestamp (UTC) |
| `error_type` | Exception class name |
| `stack_trace` | Full Dart stack trace |
| `app_version` | Semver string from `pubspec.yaml` |

- No user financial data in any field.

**Rotation policy:** Identical to §5.1.2 (2 MB / 5 files / ≤ 10 MB).

---

### 5.2 Analytics

| Property | Value |
|----------|-------|
| In-app analytics | None — prohibited (PRD NF-1, §1.6.5) |
| Third-party SDKs | None — Firebase Analytics, Mixpanel, etc. explicitly excluded |
| Usage telemetry | None |

---

### 5.3 Crash Reporting

| Property | Value |
|----------|-------|
| Remote crash reporting | None — prohibited (PRD NF-1, §1.6.5) |
| Services | Crashlytics, Sentry, etc. explicitly excluded |
| Sole capture mechanism | Local error log (§5.1.3) |
| Support path | User exports log manually via share sheet |

---

### 5.4 Internationalisation / Localisation

#### 5.4.1 App Language

- English only — v1 and all foreseeable versions (PRD §5.4.2 scope note).
- Non-English localisation out of scope.

#### 5.4.2 Number and Currency Formatting

| Concern | Implementation |
|---------|----------------|
| Currency formatting | `NumberFormat` with device locale; symbol placement and spacing from user setting (PRD §5.4.2) |
| Decimal separator | User-overridable; inferred from locale (comma or period) |
| Thousands grouping | Standard 3-digit or Indian lakh/crore (2-2-3); inferred from locale; user-overridable (PRD FG-C11) |
| Symbol placement | Prefix / suffix inferred from home currency locale; user-overridable |

- No hardcoded format strings in UI layer.

#### 5.4.3 Date and Time Formatting

| Concern | Implementation |
|---------|----------------|
| Date display | Device locale via `intl` package — no hardcoded formats |
| Time format | 12h / 24h inferred from device; user-overridable (PRD §5.4.2) |
| Week start | Monday default; user-overridable to Sunday (PRD §5.4.2) |
| Timezone | Device local time for display; UTC for storage |

#### 5.4.4 RTL Layout

- Supported in v1 via Flutter's `Directionality` system (PRD §5.4.11).
- No manual RTL overrides; use `EdgeInsetsDirectional` and directional icons throughout.

---

### 5.5 Accessibility

| Dimension | v1 Requirement | Source |
|-----------|----------------|--------|
| Standard | WCAG 2.1 AA baseline | PRD NF-5 |
| Contrast | ≥ 4.5:1 text-to-background | WCAG 2.1 AA |
| Touch targets | ≥ 48 × 48 dp (Material 3 baseline) | Material 3 |
| Font scaling | UI adapts to system font scale up to 200%; layouts reflow, no overflow | PRD §5.4.11 |
| Semantic labels | All buttons, icons, form fields carry content descriptions | PRD §5.4.11 |
| TalkBack | Best-effort v1; complex custom widgets and charts may defer to v2 | PRD §5.4.11 |
| RTL | `Directionality` system; see §5.4.4 | PRD §5.4.11 |

- No in-app accessibility toggles; all a11y settings are system-level.
- Screen reader audit for complex financial widgets deferred to v2.

---

### 5.6 Theme and Dark Mode

| Property | Value |
|----------|-------|
| Design system | Material 3 (Material You) — §1.6.4, PRD NF-10 |
| Light + dark | Both themes required; `theme` + `darkTheme` in `MaterialApp` |
| Dynamic color | API 31+ via `DynamicColorTheme`; fallback to custom seed color on OEM restriction (TC-048) |
| Seed color | User-selectable in Settings > Appearance (PRD §5.4.1) |
| Theme definition | Centralized `ThemeData` in `presentation/theme/` — not duplicated per feature |

- No per-feature color overrides outside the centralized theme.
- Implementation detail: see §2.1.3 (Android target) and §2.14.1 (dependency table).
