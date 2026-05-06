---
title: API Contracts
version: 0.1.0
status: draft
last_updated: 2026-05-06
---

# API Contracts — Variance

> Internal layer boundaries only. No method bodies. Developer derives implementation from SDS + data model.
>
> **Legend:** Repos → `domain/` interfaces. Implementations → `data/`. Use cases → `domain/`. Notifiers → `presentation/`.
> THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

---

## 1. Cross-Cutting Types

```
Result<T>       sealed: Ok<T> | Err<T>
Failure         sealed: DatabaseFailure | ValidationFailure | NetworkFailure
                        | NotFoundFailure | BusinessRuleFailure
Money           value object: amount (int minor units) + currencyCode (String ISO 4217)
AppSettings     flat value object (mirrors app_settings table)
```

All `watch*` → `Stream` (Drift reactive). All writes → `Future<Result<T>>`. Never throw across layer boundaries.

---

## 2. Domain Contracts

### 2.1 Accounts

#### 2.1.1 IAccountRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                           | Return                    |
| -------------------------------- | ------------------------- |
| `watchAll()`                     | `Stream<List<Account>>`   |
| `watchById(id)`                  | `Stream<Account?>`        |
| `create(account)`                | `Future<Result<Account>>` |
| `update(account)`                | `Future<Result<Account>>` |
| `softDelete(id)`                 | `Future<Result<void>>`    |
| `watchBalance(id, currencyCode)` | `Stream<Money>`           |

#### 2.1.2 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                   | Return                    |
| -------------------------- | ------------------------- |
| `CreateAccountUseCase`     | `Future<Result<Account>>` |
| `UpdateAccountUseCase`     | `Future<Result<Account>>` |
| `DeleteAccountUseCase`     | `Future<Result<void>>`    |
| `WatchAccountsUseCase`     | `Stream<List<Account>>`   |
| `GetAccountBalanceUseCase` | `Stream<Money>`           |

#### 2.1.3 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier                | State                       |
| ----------------------- | --------------------------- |
| `AccountListNotifier`   | `AsyncValue<List<Account>>` |
| `AccountDetailNotifier` | `AsyncValue<AccountDetail>` |

---

### 2.2 Transactions

#### 2.2.1 ITransactionRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                                | Return                              | Notes                                  |
| ------------------------------------- | ----------------------------------- | -------------------------------------- |
| `watchByMonth(year, month, filters?)` | `Stream<List<Transaction>>`         |                                        |
| `watchById(id)`                       | `Stream<Transaction?>`              |                                        |
| `create(draft)`                       | `Future<Result<Transaction>>`       |                                        |
| `correctFinancial(id, draft)`         | `Future<Result<Transaction>>`       | reversal + correction in single DB txn |
| `updateNonFinancial(id, patch)`       | `Future<Result<Transaction>>`       | in-place; no ledger entries            |
| `void_(id)`                           | `Future<Result<void>>`              |                                        |
| `bulkVoid(ids)`                       | `Future<Result<void>>`              |                                        |
| `search(query, filters?)`             | `Future<Result<List<Transaction>>>` | FTS5                                   |

#### 2.2.2 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                          | Return                              |
| --------------------------------- | ----------------------------------- |
| `CreateTransactionUseCase`        | `Future<Result<Transaction>>`       |
| `EditTransactionUseCase`          | `Future<Result<Transaction>>`       |
| `VoidTransactionUseCase`          | `Future<Result<void>>`              |
| `SearchTransactionsUseCase`       | `Future<Result<List<Transaction>>>` |
| `WatchMonthlyTransactionsUseCase` | `Stream<List<Transaction>>`         |
| `CheckDuplicateUseCase`           | `Future<Result<bool>>`              |
| `CheckOverdraftUseCase`           | `Future<Result<bool>>`              |

#### 2.2.3 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier                  | State                           | Notes                                                     |
| ------------------------- | ------------------------------- | --------------------------------------------------------- |
| `TransactionFormNotifier` | `TransactionFormState`          | holds all fields + save error; preserves state on failure |
| `TransactionListNotifier` | `AsyncValue<List<Transaction>>` |                                                           |

---

### 2.3 Entries (Ledger Engine — internal)

> No direct UI surface. Called only by ledger engine inside a DB transaction.

#### 2.3.1 IEntryRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                      | Return                 |
| --------------------------- | ---------------------- |
| `watchByAccount(accountId)` | `Stream<List<Entry>>`  |
| `insertPair(debit, credit)` | `Future<Result<void>>` |

---

### 2.4 Categories

#### 2.4.1 ICategoryRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                           | Return                     |
| -------------------------------- | -------------------------- |
| `watchAll()`                     | `Stream<List<Category>>`   |
| `create(category)`               | `Future<Result<Category>>` |
| `update(category)`               | `Future<Result<Category>>` |
| `softDelete(id, replacementId?)` | `Future<Result<void>>`     |

#### 2.4.2 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                | Return                     |
| ----------------------- | -------------------------- |
| `CreateCategoryUseCase` | `Future<Result<Category>>` |
| `UpdateCategoryUseCase` | `Future<Result<Category>>` |
| `DeleteCategoryUseCase` | `Future<Result<void>>`     |

#### 2.4.3 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier               | State                        |
| ---------------------- | ---------------------------- |
| `CategoryListNotifier` | `AsyncValue<List<Category>>` |

---

### 2.5 Currency & Exchange Rates

#### 2.5.1 ICurrencyRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                  | Return                   |
| ----------------------- | ------------------------ |
| `watchAll()`            | `Stream<List<Currency>>` |
| `watchEnabled()`        | `Stream<List<Currency>>` |
| `setHomeCurrency(code)` | `Future<Result<void>>`   |
| `enableCurrency(code)`  | `Future<Result<void>>`   |
| `disableCurrency(code)` | `Future<Result<void>>`   |

#### 2.5.2 IExchangeRateRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                          | Return                    | Notes                               |
| ------------------------------- | ------------------------- | ----------------------------------- |
| `getRate(from, to, date)`       | `Future<Result<Decimal>>` | cache-first, then staleness warning |
| `getCachedRate(from, to, date)` | `Result<Decimal>`         | sync; returns `Err` if not cached   |
| `fetchAndCache()`               | `Future<Result<void>>`    | called by WorkManager               |

#### 2.5.3 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                      | Return                    |
| ----------------------------- | ------------------------- |
| `GetExchangeRateUseCase`      | `Future<Result<Decimal>>` |
| `RefreshExchangeRatesUseCase` | `Future<Result<void>>`    |

#### 2.5.4 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier                   | State                               |
| -------------------------- | ----------------------------------- |
| `CurrencySettingsNotifier` | `AsyncValue<CurrencySettingsState>` |

---

### 2.6 Recurring & Scheduling

#### 2.6.1 IRecurringTemplateRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method             | Return                                    |
| ------------------ | ----------------------------------------- |
| `watchAll()`       | `Stream<List<RecurringTemplate>>`         |
| `watchById(id)`    | `Stream<RecurringTemplate?>`              |
| `create(template)` | `Future<Result<RecurringTemplate>>`       |
| `update(template)` | `Future<Result<RecurringTemplate>>`       |
| `pause(id)`        | `Future<Result<void>>`                    |
| `resume(id)`       | `Future<Result<void>>`                    |
| `softDelete(id)`   | `Future<Result<void>>`                    |
| `getDue(asOf)`     | `Future<Result<List<RecurringTemplate>>>` |

#### 2.6.2 IScheduledOccurrenceRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                          | Return                 |
| ------------------------------- | ---------------------- |
| `markPosted(id, transactionId)` | `Future<Result<void>>` |
| `markSkipped(id)`               | `Future<Result<void>>` |

#### 2.6.3 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                         | Return                              | Notes                                      |
| -------------------------------- | ----------------------------------- | ------------------------------------------ |
| `CreateRecurringTemplateUseCase` | `Future<Result<RecurringTemplate>>` |                                            |
| `UpdateRecurringTemplateUseCase` | `Future<Result<RecurringTemplate>>` |                                            |
| `PostDueOccurrencesUseCase`      | `Future<Result<int>>`               | returns count posted; called on app launch |
| `SkipOccurrenceUseCase`          | `Future<Result<void>>`              |                                            |

#### 2.6.4 Notifiers & Services

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Class                           | Type     | State / Notes                                                   |
| ------------------------------- | -------- | --------------------------------------------------------------- |
| `RecurringTemplateListNotifier` | Notifier | `AsyncValue<List<RecurringTemplate>>`                           |
| `RecurringSchedulerService`     | Service  | called by WorkManager; delegates to `PostDueOccurrencesUseCase` |

---

### 2.7 Installments

#### 2.7.1 IInstallmentPlanRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method           | Return                            |
| ---------------- | --------------------------------- |
| `watchAll()`     | `Stream<List<InstallmentPlan>>`   |
| `watchById(id)`  | `Stream<InstallmentPlan?>`        |
| `create(plan)`   | `Future<Result<InstallmentPlan>>` |
| `update(plan)`   | `Future<Result<InstallmentPlan>>` |
| `closeEarly(id)` | `Future<Result<void>>`            |

#### 2.7.2 IInstallmentOccurrenceRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method                          | Return                                |
| ------------------------------- | ------------------------------------- |
| `watchByPlan(planId)`           | `Stream<List<InstallmentOccurrence>>` |
| `markPosted(id, transactionId)` | `Future<Result<void>>`                |

#### 2.7.3 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                       | Return                            |
| ------------------------------ | --------------------------------- |
| `CreateInstallmentPlanUseCase` | `Future<Result<InstallmentPlan>>` |
| `CloseInstallmentPlanUseCase`  | `Future<Result<void>>`            |

#### 2.7.4 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier                        | State                               |
| ------------------------------- | ----------------------------------- |
| `InstallmentPlanListNotifier`   | `AsyncValue<List<InstallmentPlan>>` |
| `InstallmentPlanDetailNotifier` | `AsyncValue<InstallmentPlanDetail>` |

---

### 2.8 Payees & Tags

#### 2.8.1 IPayeeRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method             | Return                  |
| ------------------ | ----------------------- |
| `watchAll()`       | `Stream<List<Payee>>`   |
| `create(name)`     | `Future<Result<Payee>>` |
| `rename(id, name)` | `Future<Result<Payee>>` |
| `softDelete(id)`   | `Future<Result<void>>`  |

#### 2.8.2 ITagRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method             | Return                 |
| ------------------ | ---------------------- |
| `watchAll()`       | `Stream<List<Tag>>`    |
| `create(name)`     | `Future<Result<Tag>>`  |
| `rename(id, name)` | `Future<Result<Tag>>`  |
| `softDelete(id)`   | `Future<Result<void>>` |

> No dedicated use cases. Repos consumed directly by `TransactionFormNotifier`.

---

### 2.9 App Settings & Drafts

#### 2.9.1 IAppSettingsRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method          | Return                 |
| --------------- | ---------------------- |
| `watch()`       | `Stream<AppSettings>`  |
| `update(patch)` | `Future<Result<void>>` |

#### 2.9.2 IDraftRepository

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Method          | Return                  |
| --------------- | ----------------------- |
| `watchAll()`    | `Stream<List<Draft>>`   |
| `upsert(draft)` | `Future<Result<Draft>>` |
| `delete(id)`    | `Future<Result<void>>`  |

> No use cases. Repos consumed directly by notifiers.

#### 2.9.3 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier              | State                     |
| --------------------- | ------------------------- |
| `AppSettingsNotifier` | `AsyncValue<AppSettings>` |
| `DraftListNotifier`   | `AsyncValue<List<Draft>>` |

---

### 2.10 Home / Dashboard

> No repository. Aggregates from accounts + transactions repos.

#### 2.10.1 Use Cases

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Use Case                     | Return                                    | Notes                                |
| ---------------------------- | ----------------------------------------- | ------------------------------------ |
| `WatchMonthlySummaryUseCase` | `Stream<MonthlySummary>`                  | income, expenses, net — per currency |
| `WatchNetWorthUseCase`       | `Stream<Money>`                           | converted to home currency           |
| `GetCatchUpBannerUseCase`    | `Future<Result<List<RecurringTemplate>>>` | overdue templates count              |

#### 2.10.2 Notifiers

THIS IS A VERY HIGH LEVEL DOCUMENT. EXACT IMPLEMENTATION MIGHT NEED FINER DETAILS.

| Notifier       | State                   |
| -------------- | ----------------------- |
| `HomeNotifier` | `AsyncValue<HomeState>` |

---

## 3. Constraints

| Rule                         | Detail                                               |
| ---------------------------- | ---------------------------------------------------- |
| Repos are interfaces         | defined in `domain/`; implementations in `data/`     |
| Use cases are stateless      | single `execute(params)` method only                 |
| Notifiers consume use cases  | never repos directly — except §2.9 (settings/drafts) |
| DAOs are data-layer internal | not part of public API surface                       |
| No throws across boundaries  | all failures via `Err(Failure)`                      |
