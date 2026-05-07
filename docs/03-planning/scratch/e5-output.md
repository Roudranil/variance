## Stories

## E5-S1 — Exchange Rate Background Fetch + Cache

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

## E5-S2 — Currency Bundle Seeding + Repository

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

## E5-S3 — Currency Symbol Disambiguation

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

## E5-S4 — Exchange Rate Estimate on Transaction Entry Form

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

## E5-S5 — Currency Settings Screen

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

## Tasks

## E5-T1 — Define `ExchangeRate` and `Currency` Domain Entities

**Parent Epic:** E-5
**Parent Story:** E5-S2

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

## E5-T2 — Bundle `currencies.json` Asset and Register in `pubspec.yaml`

**Parent Epic:** E-5
**Parent Story:** E5-S2

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

## E5-T3 — Implement `currencies` Drift Table and Seed Migration

**Parent Epic:** E-5
**Parent Story:** E5-S2

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

## E5-T4 — Implement `ICurrencyRepository` and `CurrencyRepositoryImpl`

**Parent Epic:** E-5
**Parent Story:** E5-S2

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

## E5-T5 — Implement `exchange_rates` Drift Table and DAO

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T6 — Implement `IExchangeRateRepository` and `ExchangeRateRepositoryImpl`

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T7 — Implement `ExchangeRateService` (HTTP Fetch + Parse)

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T8 — Implement `RefreshExchangeRatesUseCase`

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T9 — Implement `ExchangeRateFetchWorker` (WorkManager Task)

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T10 — Net Worth Card: Staleness Disclaimer

**Parent Epic:** E-5
**Parent Story:** E5-S1

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

## E5-T11 — Implement Symbol Disambiguation Helper

**Parent Epic:** E-5
**Parent Story:** E5-S3

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

## E5-T12 — Wire Symbol Disambiguation into Account List Row

**Parent Epic:** E-5
**Parent Story:** E5-S3

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

## E5-T13 — Wire Symbol Disambiguation into Net Worth Card + Transaction Views

**Parent Epic:** E-5
**Parent Story:** E5-S3

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

## E5-T14 — Implement `GetExchangeRateUseCase`

**Parent Epic:** E-5
**Parent Story:** E5-S4

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

## E5-T15 — Implement Exchange Rate Estimate Widget

**Parent Epic:** E-5
**Parent Story:** E5-S4

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

## E5-T16 — Wire Exchange Rate Estimate into Transaction Entry Form ViewModel

**Parent Epic:** E-5
**Parent Story:** E5-S4

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

## E5-T17 — Implement Currency Settings Screen + `CurrencySettingsNotifier`

**Parent Epic:** E-5
**Parent Story:** E5-S5

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

## E5-T18 — Implement Currency Picker Screen

**Parent Epic:** E-5
**Parent Story:** E5-S5

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

## E5-T19 — Implement Exchange Rate Detail Screen

**Parent Epic:** E-5
**Parent Story:** E5-S4

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
