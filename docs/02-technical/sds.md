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
    - [1.7 Explicit Out-of-Scope](#17-explicit-out-of-scope)


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

Three domain services encapsulate the DEB engine logic:

- **LedgerEngine** — validates posting cases, constructs entry sets, enforces `Σdebit = Σcredit` invariant (PRD §4.4).
- **BalanceCalculator** — computes account balances using the universal formula `balance = Σdebit − Σcredit` (PRD §4.6). Handles multi-currency conversion via `exchange_rate_to_home`.
- **PostingCaseSelector** — given an event type (create, modify, delete, balance-edit) and entity state, selects the correct ledger posting case from PRD §4.11 and `ledger-entry.md`.

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
| HTTP (opportunistic) | `dio` | Exchange rate fetch (background, offline-tolerant) |
| Secure storage | `flutter_secure_storage` | PIN hash; app lock state |
| Crash reporting | `firebase_crashlytics` (opt-in build flavour) | Crash capture; zero PII |

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
         │
         ▼
[Data: TransactionRepositoryImpl.watchTransactions()]
  — maps DTO rows → domain Transaction entities
  — emits Stream<List<Transaction>>
         │
         ▼
[Domain: no use case involved — reads are pure projections]
         │
         ▼
[Presentation: transactionsProvider (AsyncNotifier or StreamProvider)]
  — ref.watch() → rebuilds only affected widgets via select()
         │
         ▼
[Widget: TransactionListView rebuilds with new data]
```

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
│       └── posting_case_selector.dart
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
