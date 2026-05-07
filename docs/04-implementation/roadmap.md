<!-- TOC -->
<!-- Generated: 2026-05-07 -->
<!-- /TOC -->

# Variance — Sprint Roadmap

## 1. Overview

Sprint planning derived from the Feature DAG build order (`docs/02-technical/feature-dag.md §5`).
Each DAG phase maps to one or more sprints. Tasks within a sprint are ordered by intra-phase dependency. Tasks marked **BLOCKED** cannot begin until the listed blocker is complete.

**Phase → Sprint mapping principle**
- Phase 0 (all INFRA) is dense; split into 2 sprints.
- Phases 1–3 (domain data layer + first screens) map to 3 sprints.
- Phases 4–6 (features + polish) map to 3 sprints.
- Phases 7–9 (home screen + late features) map to 1 sprint.
- Onboarding has its own dedicated sprint at the end (gated on Phase 3 completion).

**Critical path (12 hops):**
`INFRA-1 → INFRA-7 → ACC-01 + CAT-01 → TXN-01 → ACC-04 → TXN-05 → TXN-08 → SET-01 → HOME-01 → HOME-02`

---

## 2. Sprint Breakdown

### 2.1 Sprint 1 — DB Schema + Domain Skeleton

**DAG Phase:** 0 (partial — INFRA-1, INFRA-2)
**Goal:** Encrypted database wired and compiling; all domain entities + use case shells in place.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-1 — Add SQLCipher + Drift deps | S-1 | — |
| 2 | T-2 — Implement AppDatabase + encryption key management | S-1 | T-1 |
| 3 | T-3 — Define all 18 Drift table classes + FTS5 | S-1 | T-2 |
| 4 | T-4 — Implement versioned migration scaffold | S-1 | T-3 |
| 5 | T-5 — Implement one DatabaseAccessor DAO per aggregate | S-1 | T-4 |
| 6 | T-6 — Write SchemaVerifier test for v1 schema | S-1 | T-5 |
| 7 | T-7 — Define all 16 Freezed domain entities | S-2 | T-3 (schema shapes entities) |
| 8 | T-8 — Define abstract repository interfaces | S-2 | T-7 |
| 9 | T-9 — Implement Result sealed type + Failure hierarchy | S-2 | — |
| 10 | T-10 — Scaffold all use case shells | S-2 | T-8, T-9 |
| 11 | T-11 — Verify domain package compiles without Flutter dep | S-2 | T-10 |

---

### 2.2 Sprint 2 — DI + Navigation + Theme + Currency Bundle + Ledger Engine

**DAG Phase:** 0 (remaining — INFRA-3, INFRA-4, INFRA-5, INFRA-6, INFRA-7)
**Goal:** Full INFRA phase complete. App navigates with placeholder screens; theme system live; ledger engine tested.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-12 — Define AppDatabaseProvider + DAO providers | S-3 | T-5 (Sprint 1) |
| 2 | T-13 — Define repo impl providers + use case providers | S-3 | T-12, T-10 |
| 3 | T-14 — Wire ProviderScope in main.dart + integration test | S-3 | T-13 |
| 4 | T-15 — Define complete GoRouter route tree | S-4 | T-14 |
| 5 | T-16 — Implement onboarding redirect guard | S-4 | T-15 |
| 6 | T-17 — Add placeholder screens for 3 tabs + validate params | S-4 | T-15 |
| 7 | T-18 — Define light/dark ThemeData with ColorScheme.fromSeed | S-5 | — |
| 8 | T-19 — Implement VarianceColors ThemeExtension | S-5 | T-18 |
| 9 | T-20 — Write widget tests for VarianceColors + DynamicColorBuilder | S-5 | T-19 |
| 10 | T-21 — Create and bundle currencies.json asset | S-6 | — |
| 11 | T-22 — Seed currencies table via onCreate migration | S-6 | T-21, T-3 |
| 12 | T-23 — Implement CurrencyRepository + keepAlive CurrencyProvider | S-6 | T-22, T-13 |
| 13 | T-24 — Implement PostingCaseSelector | S-7 | T-9 |
| 14 | T-25 — Implement LedgerEngine with balanced entry assertion | S-7 | T-24 |
| 15 | T-26 — Implement BalanceCalculator | S-7 | T-25 |
| 16 | T-27 — Implement PeriodCalculator with edge case handling | S-7 | T-25 |
| 17 | T-28 — Write unit tests for all posting cases + LedgerEngine | S-7 | T-25, T-26, T-27 |

---

### 2.3 Sprint 3 — Accounts Data Layer + Categories Data Layer

**DAG Phase:** 1 (ACC-01 data layer, CAT-01 data layer, SET-01 data layer)
**Goal:** Account and Category domain data layers fully wired; use cases testable without UI.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-29 — Define Account + AccountDetail Freezed entities | S-8 | T-7 (Sprint 1) |
| 2 | T-30 — Define IAccountRepository interface | S-8 | T-29 |
| 3 | T-31 — Implement AccountDao | S-9 | T-5, T-3 (Sprint 1) |
| 4 | T-32 — Implement AccountRepositoryImpl + DTOs | S-9 | T-31, T-30 |
| 5 | T-33 — Implement CreateAccountUseCase | S-10 | T-32, T-25 (ledger engine) |
| 6 | T-34 — Implement UpdateAccountUseCase + SoftDeleteAccountUseCase | S-10 | T-32 |
| 7 | T-35 — Implement WatchAccountsUseCase + Riverpod account providers | S-10 | T-32, T-13 |
| 8 | T-36 — Implement account_details persistence + encryption | S-11 | T-32 |
| 9 | T-37 — Implement loan installment suggestion | S-11 | T-36 |
| 10 | T-62 — Define Category Freezed domain entity | S-29 | T-7 |
| 11 | T-63 — Define ICategoryRepository interface | S-29 | T-62 |
| 12 | T-64 — Implement CategoryDto with Drift row mapper | S-29 | T-5, T-3 |
| 13 | T-65 — Implement CategoryDao | S-29 | T-64 |
| 14 | T-66 — Implement CategoryRepositoryImpl | S-30 | T-65, T-63 |
| 15 | T-67 — Implement CreateCategoryUseCase | S-30 | T-66 |
| 16 | T-68 — Implement UpdateCategoryUseCase | S-30 | T-66 |
| 17 | T-69 — Implement DeleteCategoryUseCase | S-30 | T-66 |
| 18 | T-70 — Implement CategoryListNotifier + Riverpod DI wiring | S-30 | T-66, T-13 |
| 19 | T-77 — Implement default category seeding migration | S-34 | T-65, T-4 |
| 20 | T-172 — AppSettings DAO + IAppSettingsRepository | S-64 | T-5, T-3 |
| 21 | T-173 — AppSettingsNotifier + Riverpod provider wiring | S-64 | T-172, T-13 |

---

### 2.4 Sprint 4 — Accounts + Categories UI; Transaction Data Layer

**DAG Phase:** 2 (ACC-01 UI, CAT-01/CAT-04 UI, TXN-01 data layer, SET-01/SET-05/SET-06 screens)
**Goal:** Accounts CRUD screens live; categories management live; transaction domain wired at data layer.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-38 — Implement balance stream + net worth aggregation | S-12 | T-35 (Sprint 3) |
| 2 | T-39 — Build AccountListScreen + net worth card | S-13 | T-38, T-19 (theme) |
| 3 | T-40 — Build AccountFormScreen (create + edit) | S-13 | T-39, T-33, T-34 |
| 4 | T-71 — Category Management Screen scaffold + loading/error states | S-31 | T-70 (Sprint 3) |
| 5 | T-72 — Category Management Screen populated state + row actions | S-31 | T-71 |
| 6 | T-73 — Category Detail Screen — Create mode | S-32 | T-67 |
| 7 | T-74 — Category Detail Screen — Edit mode + parent/child views | S-32 | T-68, T-73 |
| 8 | T-75 — Category Deletion Wizard — Steps 1 + 2 | S-33 | T-69 |
| 9 | T-76 — Category Deletion Wizard — Steps 3 + 4 | S-33 | T-75 |
| 10 | T-78 — Protected category guard widget tests | S-35 | T-72 |
| 11 | T-79 — Implement Category Picker Sheet | S-35 | T-70, T-72 |
| 12 | T-45 — Define Transaction + Entry + Tag Freezed entities | S-16 | T-7 |
| 13 | T-46 — Define ITransactionRepository interface | S-16 | T-45 |
| 14 | T-47 — Implement TransactionDao | S-17 | T-5, T-3 |
| 15 | T-48 — Implement TransactionRepositoryImpl + DTOs | S-17 | T-47, T-46 |
| 16 | T-49 — Implement CreateTransactionUseCase (income + expense) | S-18 | T-48, T-25, T-32 |
| 17 | T-50 — Implement CreateTransactionUseCase (transfer + cross-currency + fee) | S-19 | T-49 |
| 18 | T-174 — Settings Hub screen widget | S-64 | T-173 (Sprint 3), T-17 |
| 19 | T-175 — Appearance settings screen widget | S-64 | T-174, T-19 |
| 20 | T-176 — Dynamic color OEM fallback + Color Scheme Preview | S-64 | T-175 |
| 21 | T-80 — Define ExchangeRate + Currency domain entities | S-37 | T-7 |
| 22 | T-81 — Bundle currencies.json asset + pubspec.yaml register | S-37 | T-21 (Sprint 2, same asset) |
| 23 | T-82 — Implement currencies Drift table + seed migration | S-37 | T-81, T-4 |
| 24 | T-83 — Implement ICurrencyRepository + CurrencyRepositoryImpl | S-37 | T-82, T-23 |

---

### 2.5 Sprint 5 — Transactions UI; Currency + Settings Screens; Account Detail

**DAG Phase:** 3 (ACC-03, ACC-05, ACC-07, ACC-09, TXN-02, TXN-03, TXN-04, TXN-06, TXN-10, CURR-03, RECUR-01, SET-03, SET-04, SET-07, SET-08, OB-01, HOME-03)
**Goal:** Transaction entry forms live; core settings screens complete; onboarding infrastructure laid down.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-51 — Build transaction entry form (income/expense) | S-18 | T-49 (Sprint 4) |
| 2 | T-52 — Build transaction entry form (transfer variant) | S-19 | T-50 |
| 3 | T-53 — Implement CorrectTransactionUseCase | S-20 | T-48, T-25 |
| 4 | T-54 — Build TransactionDetailScreen | S-21 | T-53, T-51 |
| 5 | T-55 — Implement photo attach, compress, and delete | S-22 | T-48 |
| 6 | T-41 — Build AccountDetailScreen | S-14 | T-40 (Sprint 4), T-38 |
| 7 | T-42 — Implement credit card payment flow | S-15 | T-41, T-36 |
| 8 | T-43 — Implement balance reconciliation | S-15 | T-38 |
| 9 | T-44 — Implement overdraft + credit limit warnings | S-15 | T-38, T-36 |
| 10 | T-84 — Implement exchange_rates Drift table + DAO | S-36 | T-82 (Sprint 4) |
| 11 | T-85 — Implement IExchangeRateRepository + ExchangeRateRepositoryImpl | S-36 | T-84 |
| 12 | T-86 — Implement ExchangeRateService (HTTP fetch + parse) | S-36 | T-85 |
| 13 | T-87 — Implement RefreshExchangeRatesUseCase | S-36 | T-86 |
| 14 | T-88 — Implement ExchangeRateFetchWorker (WorkManager) | S-36 | T-87 |
| 15 | T-90 — Implement Symbol Disambiguation Helper | S-38 | T-83 |
| 16 | T-91 — Wire disambiguation into Account List Row | S-38 | T-90, T-39 |
| 17 | T-92 — Wire disambiguation into Net Worth Card + Transaction Views | S-38 | T-90, T-39, T-54 |
| 18 | T-93 — Implement GetExchangeRateUseCase | S-39 | T-85 |
| 19 | T-94 — Implement Exchange Rate Estimate Widget | S-39 | T-93 |
| 20 | T-95 — Wire exchange rate estimate into Transaction Entry Form ViewModel | S-39 | T-94, T-51 |
| 21 | T-96 — Implement Currency Settings Screen + CurrencySettingsNotifier | S-40 | T-83, T-173 |
| 22 | T-97 — Implement Currency Picker Screen | S-40 | T-96 |
| 23 | T-98 — Implement Exchange Rate Detail Screen | S-40 | T-85 |
| 24 | T-177 — Locale & Format settings screen widget | S-65 | T-174, T-83 |
| 25 | T-178 — Home currency change semantics + display formatting pipeline | S-65 | T-177, T-93 |
| 26 | T-179 — Transaction Entry settings screen widget | S-66 | T-174 |
| 27 | T-180 — IDraftRepository impl + FIFO enforcement | S-66 | T-48, T-179 |
| 28 | T-181 — Warnings & Limits screen: per-account thresholds | S-67 | T-174, T-35 |
| 29 | T-182 — Warnings & Limits screen: per-category thresholds | S-67 | T-181, T-70 |
| 30 | T-183 — Profile settings screen widget | S-68 | T-174 |
| 31 | T-184 — Security settings screen + lock timeout | S-69 | T-174, T-172 |
| 32 | T-185 — PIN setup, change, and entry screens | S-69 | T-184 |
| 33 | T-60 — Implement future-dated + pending transaction flow | S-27 | T-48, T-25 |
| 34 | T-99 — Define IScheduledOccurrenceRepository + Drift DAO | S-41 | T-5, T-3 |
| 35 | T-100 — Define IRecurringTemplateRepository + Drift DAO | S-41 | T-5, T-3 |
| 36 | T-101 — Implement PostDueOccurrencesUseCase | S-41 | T-99, T-100, T-49 |
| 37 | T-102 — Implement 90-day lookahead generation logic | S-41 | T-99, T-100 |
| 38 | T-103 — Implement AppInitializer synchronous launch sweep | S-41 | T-101, T-102 |
| 39 | T-104 — Register WorkManager PostingSweeperWorker | S-41 | T-103 |
| 40 | T-194 — AppSettingsDao: read/write app_settings rows | S-74/S-75 | T-5, T-3 |
| 41 | T-195 — AppSettingsRepository + AppSettingsNotifier (Riverpod) | S-75 | T-194, T-13 |
| 42 | T-196 — GoRouter redirect guard wired to AppSettingsNotifier | S-75 | T-195, T-15 |

---

### 2.6 Sprint 6 — Transactions Advanced; Recurring Templates; Account + Category Advanced Features

**DAG Phase:** 4 (ACC-04, ACC-06, ACC-08, ACC-10, ACC-11, ACC-12, TXN-07, CAT-03, RECUR-02, RECUR-03, INST-01, DRAFT-01)
**Goal:** Recurring templates fully functional; transaction list and duplication detection live; advanced account + category features wired.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-56 — Build TransactionListScreen (unified + per-account) | S-23 | T-54 (Sprint 5), T-53 |
| 2 | T-57 — Implement duplicate detection | S-24 | T-48 |
| 3 | T-61 — Implement transaction drafts | S-28 | T-180 (Sprint 5), T-48 |
| 4 | T-105 — Implement RecurringTemplate domain entity + CreateRecurringTemplateUseCase | S-42 | T-100 (Sprint 5), T-49 |
| 5 | T-106 — Build Create Recurring Template Screen (UI + form) | S-42 | T-105, T-51 |
| 6 | T-107 — Implement recurrence rule validation + first-date preview | S-42 | T-105 |
| 7 | T-108 — Build Recurring Templates List Screen | S-43 | T-105 |
| 8 | T-109 — Build Recurring Template Detail / Edit Screen | S-43 | T-108 |
| 9 | T-110 — Implement UpdateRecurringTemplateUseCase | S-43 | T-105 |
| 10 | T-111 — Implement template delete + child occurrence cancellation | S-43 | T-110 |
| 11 | T-112 — Implement SkipOccurrenceUseCase + "manually handled" marking | S-44 | T-101 (Sprint 5) |
| 12 | T-113 — Implement Pause Dialog UI + PauseRecurringTemplateUseCase | S-44 | T-105 |
| 13 | T-114 — Implement Unpause + sweep auto-resume logic | S-44 | T-113, T-103 |
| 24 | T-124 — Define Drift table classes for installment_plans + installment_occurrences | S-48 | T-3 (Sprint 1) |
| 15 | T-125 — Write Drift schema migration for installment tables | S-48 | T-124, T-4 |
| 16 | T-126 — Implement InstallmentPlanDao + InstallmentOccurrenceDao | S-48 | T-125 |
| 17 | T-127 — Define InstallmentPlan + InstallmentOccurrence domain entities | S-49 | T-7 |
| 18 | T-128 — Define IInstallmentPlanRepository + IInstallmentOccurrenceRepository | S-49 | T-127 |
| 19 | T-129 — Implement repository classes + DTOs for installment entities | S-50 | T-126, T-128 |
| 20 | T-89 — Net Worth Card: staleness disclaimer | S-36 | T-88 (Sprint 5), T-39 |

---

### 2.7 Sprint 7 — Installments; Search + Filter; Permission Handling

**DAG Phase:** 5 (TXN-05, TXN-11, INST-02, SET-09, SET-10)
**Goal:** Installment plans creatable; transaction search + filter wired; notification permissions handled.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-130 — Implement CreateInstallmentPlanUseCase — core | S-50 | T-129 (Sprint 6), T-49 |
| 2 | T-131 — Implement CreateInstallmentPlanUseCase — transfer + fee | S-50 | T-130, T-50 |
| 3 | T-132 — Implement tracking amount query service | S-51 | T-129 |
| 4 | T-133 — Implement InstallmentPlanDetailNotifier Riverpod provider | S-51 | T-132, T-13 |
| 5 | T-134 — Build CreateInstallmentScreen scaffold + installment fields | S-52 | T-130 |
| 6 | T-135 — Wire reactive end date, per-installment auto-calc, mismatch warning | S-52 | T-134 |
| 7 | T-136 — Connect create screen to use case + handle all transaction types | S-52 | T-135, T-131 |
| 8 | T-58 — Implement FTS5 search | S-25 | T-47 (Sprint 4) |
| 9 | T-59 — Build transaction filter sheet | S-26 | T-56 (Sprint 6) |
| 10 | T-115 — Implement ReminderAlarmScheduler service | S-45 | T-103 (Sprint 5) |
| 11 | T-116 — Implement Notification Action Handlers (Confirm/Edit/Dismiss) | S-45 | T-115 |
| 12 | T-117 — Implement Alerts Strip pending-confirmation card | S-45 | T-116 |
| 13 | T-118 — Declare Android Manifest permissions + runtime permission request flow | S-46 | T-115 |
| 14 | T-119 — Implement graceful degradation on permission denial | S-46 | T-118 |
| 15 | T-186 — Resolve OQ-SDS-SC-001: secure storage backup exclusion | S-70 | T-184 (Sprint 5) |
| 16 | T-187 — Backup screen widget + SAF file picker integration | S-70 | T-186 |
| 17 | T-188 — ZIP export engine (manifest + entity serialisation + photos) | S-70 | T-187 |
| 18 | T-143 — Unit tests: CreateInstallmentPlanUseCase | S-56 (tests) | T-131 |
| 19 | T-144 — Unit tests: tracking amount queries + CloseInstallmentPlanUseCase | S-56 (tests) | T-132, T-141* |

> *T-141 is Phase 6; these tests run partial until then.

---

### 2.8 Sprint 8 — Home Screen; Installment Detail; Advanced Recurring + Notifications

**DAG Phase:** 6 (TXN-08, TXN-09, TXN-12, INST-03, HOME-01)
**Goal:** Home dashboard live; installment detail + list screens complete; stacked missed occurrences handled.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-146 — Implement HomeState domain entity + HomeNotifier | S-56 | T-35 (Sprint 3), T-13 |
| 2 | T-147 — Implement WatchNetWorthUseCase | S-56 | T-38 (Sprint 4) |
| 3 | T-148 — Implement WatchMonthlySummaryUseCase | S-56 | T-48 (Sprint 4) |
| 4 | T-149 — Implement Greeting Row Widget | S-56 | T-146, T-19 |
| 5 | T-150 — Implement Financial Summary Card Grid | S-56 | T-147, T-148 |
| 6 | T-151 — Implement Month Selector Widget | S-57 | T-150 |
| 7 | T-152 — Implement Home Screen Skeleton, Error, and FX Banner states | S-56 | T-146 |
| 8 | T-153 — Implement HomeScreen Scaffold (CustomScrollView + SliverList) | S-56 | T-149, T-150, T-152 |
| 9 | T-154 — Implement cursor-based paginated transaction list provider | S-57 | T-153, T-48 |
| 10 | T-155 — Implement 3-Column Transaction Row Widget | S-57 | T-154, T-19 |
| 11 | T-156 — Implement Date-Group Headers + SliverList builder | S-57 | T-155 |
| 12 | T-157 — Implement Swipe Actions + Long-Press Menu on transaction rows | S-57 | T-156 |
| 13 | T-137 — Build InstallmentPlanDetailScreen — summary card + scaffold | S-53 | T-133 (Sprint 7) |
| 14 | T-138 — Build per-installment list with inline editing + add/remove actions | S-53 | T-137 |
| 15 | T-139 — Build InstallmentPlansListScreen — Installments tab | S-54 | T-133 |
| 16 | T-140 — Implement long-press contextual menu on installment row | S-54 | T-139 |
| 17 | T-120 — Implement stacked missed occurrences auto-approval in sweep | S-47 | T-103 (Sprint 5), T-101 |
| 18 | T-121 — Implement summary notification + recurring catch-up banner | S-47 | T-120, T-116 |
| 19 | T-122 — Integration test: app-launch sweep end-to-end | S-47 | T-120 |
| 20 | T-123 — Integration test: remind-and-confirm full flow | S-45 | T-116, T-115 |
| 21 | T-145 — Golden tests for installment screens | S-55 (tests) | T-138, T-139 |

---

### 2.9 Sprint 9 — Search + Filter on Home; Settings Remaining; Alerts + FAB; Phase 7–9 nodes

**DAG Phase:** 7 (SCHED-03, HOME-02) + Phase 8 (HOME-04) + Phase 9 (HOME-05)
**Goal:** All home screen capabilities complete; settings fully wired; alerts strip live.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-158 — Implement FTS5 Search DAO + SearchRanker | S-58 | T-58 (Sprint 7), T-47 |
| 2 | T-159 — Implement SearchNotifier with global scope + debounce | S-58 | T-158 |
| 3 | T-160 — Implement Search Overlay UI (M3 SearchBar + results) | S-58 | T-159, T-19 |
| 4 | T-161 — Implement FilterState + FilterNotifier | S-59 | T-48 |
| 5 | T-162 — Implement Filter Bottom Sheet UI | S-59 | T-161, T-19 |
| 6 | T-163 — Implement Active Filter Chip Strip | S-59 | T-162 |
| 7 | T-164 — Implement Filtered Transaction List Query | S-59 | T-163, T-154 |
| 8 | T-165 — Implement SpeedDial FAB Widget | S-60 | T-153 (Sprint 8) |
| 9 | T-166 — Implement Drafts Entry Point in SpeedDial | S-60 | T-165, T-61 (Sprint 6) |
| 10 | T-167 — Implement AlertsStrip Widget Container | S-61 | T-153 |
| 11 | T-168 — Implement Pending Recurring Confirmation Alert Cards | S-61 | T-167, T-117 (Sprint 7) |
| 12 | T-169 — Implement Credit Card Payment Due Alert Cards | S-61 | T-167, T-42 (Sprint 5) |
| 13 | T-170 — Implement Backup Reminder Alert Card + trigger logic | S-62 | T-167, T-188 (Sprint 7) |
| 14 | T-171 — Implement GetCatchUpBannerUseCase + Catch-Up Banner Widget | S-63 | T-121 (Sprint 8), T-167 |
| 15 | T-141 — Implement CloseInstallmentPlanUseCase | S-55 | T-129 (Sprint 6), T-49 |
| 16 | T-142 — Build early-close UI flow dialogs + transaction entry handoff | S-55 | T-141, T-138 (Sprint 8) |
| 17 | T-189 — Account Management screen widget (Settings) | S-71 | T-174 (Sprint 4), T-39 |
| 18 | T-190 — Category Management screen widget (Settings) | S-72 | T-174, T-72 (Sprint 4) |
| 19 | T-191 — Category icon picker widget | S-72 | T-73 (Sprint 4) |
| 20 | T-192 — Recurring & Installment Management screen: recurring section | S-73 | T-174, T-108 (Sprint 6) |
| 21 | T-193 — Recurring Management screen: installment plans section | S-73 | T-192, T-139 (Sprint 8) |

---

### 2.10 Sprint 10 — Onboarding Flow

**DAG Phase:** Phase 3 pre-req (OB-01 + onboarding sub-tasks)
**Goal:** Full onboarding wizard live; redirect guard wired; integration tests pass.

> **Blocker:** Requires T-195, T-196 (Sprint 5) + T-33 (Sprint 3, account creation) + T-83 (Sprint 4, currency list) + T-199 (locale detection) to all be complete before the wizard can be wired.

| # | Task | Story | Blocked By |
|---|------|-------|-----------|
| 1 | T-199 — Locale-to-currency detection service | S-77 | T-83 (Sprint 4) |
| 2 | T-197 — OnboardingWizardScreen scaffold + PageController | S-74 | T-196 (Sprint 5), T-17 |
| 3 | T-198 — Step 1 Welcome widget | S-76 | T-197 |
| 4 | T-200 — Step 2 Currency Selection widget | S-77 | T-199, T-197 |
| 5 | T-201 — Step 3 Account Creation widget | S-78 | T-197, T-33 (Sprint 3) |
| 6 | T-202 — Step 4 Quick Highlights widget | S-79 | T-197 |
| 7 | T-203 — Step 5 Done widget + onboarding_complete write | S-80 | T-197, T-195 |
| 8 | T-204 — Wire step widgets into OnboardingWizardScreen | S-74 | T-198, T-200, T-201, T-202, T-203 |
| 9 | T-205 — Home screen zero-accounts empty state | S-81 | T-153 (Sprint 8), T-39 |
| 10 | T-206 — Integration test: full onboarding happy path | S-82 | T-204 |
| 11 | T-207 — Integration test: skip-all onboarding path | S-82 | T-204 |
| 12 | T-208 — Integration test: returning user bypass | S-82 | T-196 (Sprint 5) |

---

## 3. Blocking Summary

Key cross-sprint dependency chains:

| Later Task | Sprint | Blocked By | In Sprint |
|------------|--------|-----------|-----------|
| T-13 (repo providers) | 2 | T-12 | 2 |
| T-33 (CreateAccount) | 3 | T-25 (ledger engine) | 2 |
| T-49 (CreateTransaction) | 4 | T-25 (ledger engine) | 2 |
| T-51 (tx entry UI) | 5 | T-49 | 4 |
| T-101 (PostDueOccurrences) | 5 | T-49 | 4 |
| T-105 (RecurringTemplate) | 6 | T-100 | 5 |
| T-130 (CreateInstallment) | 7 | T-129 | 6 |
| T-153 (HomeScreen) | 8 | T-38, T-147, T-148 | 4 / 8 |
| T-158 (FTS5 search) | 9 | T-58 | 7 |
| T-197 (Onboarding scaffold) | 10 | T-196 | 5 |

---

## 4. Phase → Sprint Map

| DAG Phase | Nodes | Sprint(s) |
|-----------|-------|-----------|
| 0 | INFRA-1..7 | Sprint 1, Sprint 2 |
| 1 | ACC-01, CAT-01, CURR-01, SCHED-01, SET-01 | Sprint 3 |
| 2 | ACC-02, TXN-01, CAT-02, CAT-04, CURR-02, SCHED-02, SET-02, SET-05, SET-06 | Sprint 4 |
| 3 | ACC-03, ACC-05, ACC-07, ACC-09, TXN-02, TXN-03, TXN-04, TXN-06, TXN-10, CURR-03, RECUR-01, SET-03, SET-04, SET-07, SET-08, OB-01, HOME-03 | Sprint 5 |
| 4 | ACC-04, ACC-06, ACC-08, ACC-10, ACC-11, ACC-12, TXN-07, CAT-03, RECUR-02, RECUR-03, INST-01, DRAFT-01 | Sprint 6 |
| 5 | TXN-05, TXN-11, INST-02, SET-09, SET-10 | Sprint 7 |
| 6 | TXN-08, TXN-09, TXN-12, INST-03, HOME-01 | Sprint 8 |
| 7–9 | SCHED-03, HOME-02, HOME-04, HOME-05 | Sprint 9 |
| — | OB-01 sub-tasks (onboarding wizard) | Sprint 10 |
