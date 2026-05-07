# Epics

## E-1 — Infrastructure Foundations

### Objectives

- Provision and verify the encrypted SQLite database (SQLCipher, AES-256, WAL mode) with all 18 tables + FTS5 virtual table and a versioned migration scaffold
- Produce all Freezed domain entities, abstract repository interfaces, and the `Result<T>` / `Failure` sealed hierarchy as a pure-Dart, Flutter-free package
- Wire the full Riverpod provider graph from `AppDatabase` through DAOs, repositories, and use cases as the single composition root
- Establish the `StatefulShellRoute.indexedStack` 3-tab navigation shell with all named routes and the onboarding redirect guard
- Define and verify the centralized `ThemeData` (light + dark) with `ColorScheme.fromSeed`, `DynamicColorBuilder` fallback, and `VarianceColors` semantic token extension
- Bundle the ~180-currency ISO 4217 JSON asset, seed the `currencies` table on fresh install, and expose a `keepAlive` Riverpod provider
- Implement the four stateless domain services — `LedgerEngine`, `BalanceCalculator`, `PostingCaseSelector`, `PeriodCalculator` — covering all DEB invariants and posting cases

### Notes

- All feature nodes (Phases 1–9) hard-depend on all seven INFRA nodes; no feature work may begin until this epic is fully done
- INFRA-1 and INFRA-2 are independent root nodes and can proceed in parallel; INFRA-3 depends on both; INFRA-4 depends on INFRA-3; INFRA-6 and INFRA-7 depend on INFRA-1 and INFRA-2 respectively; INFRA-5 is standalone
- SQLCipher key stored via `flutter_secure_storage` backed by Android Keystore; encryption is non-negotiable
- Domain package must compile with zero Flutter dependency — CI enforces this

### Definition of Done

- `flutter test` passes `SchemaVerifier` for v1 schema; `AppDatabase` opens on a fresh emulator without exception; all DAOs have generated `.g.dart` files
- `dart analyze lib/domain/` returns zero errors; domain package builds without `flutter` as a direct dependency
- `main.dart` starts without runtime `ProviderException`; a provider test resolves at least one repository against an in-memory Drift database
- All named routes compile; bottom-nav tab switches render placeholder screens; onboarding redirect fires on fresh-install state
- `VarianceColors` extension resolves non-null tokens in both light and dark mode; `DynamicColorBuilder` null-fallback path is covered by a widget test
- `currencies` table populated with ≥ 170 rows on fresh install; `CurrencyRepository.getAll()` returns correct entries for USD, JPY, and BHD
- Unit tests cover all posting cases from `ledger-entry.md` (Cases 1.1, 1.2, 1.3, 1.3a, 2.2a/b, 2.3a/b, 2.4a/b, 2.5a, 3.1); `Σdebit = Σcredit` assertion fails with `BusinessRuleFailure` on a deliberately imbalanced input

### References

- `2. Infrastructure Foundations` (`docs/02-technical/feature-dag.md`)
- `5. Build Order` (`docs/02-technical/feature-dag.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-2 — Accounts Domain

### Objectives

- Enable full account lifecycle: create (with opening balance + EQ account), view, edit, and soft-delete financial accounts across 9 account categories
- Persist and display category-specific fields (bank name, card number, billing date, etc.) with AES encryption for sensitive fields
- Compute and stream real-time account balances from `entries` using `BalanceCalculator`; aggregate multi-currency net worth in home currency
- Render the Account Detail screen with per-account transaction list, contextual actions, and (for credit cards) the outstanding/statement balance + Pay FAB
- Implement balance reconciliation, journal balance-adjustment posting, and the full credit card payment flow
- Enforce all guard rails: last-account deletion block, overdraft warnings, credit limit warnings, and soft-deleted account reinstatement offer

### Notes

- All ACC nodes depend on the complete INFRA epic (E-1); this epic begins only after E-1 is done
- `CURR-01` (E-5) is a direct dependency of ACC-03 (balance view multi-currency conversion); ACC-03 stories must be sequenced after CURR-01 lands
- EQ account lazy creation is an atomic responsibility of `LedgerEngine` (INFRA-7); ACC-01 invokes it, not owns it

### Definition of Done

- Account create / read / edit / soft-delete pass unit and widget tests
- Opening balance produces balanced `entries` rows; EQ account row created on first non-zero opening balance
- Name uniqueness check (including soft-deleted) enforced; reinstatement offer fires on matching name + category
- Balance stream emits updated value within 1 s of a new entry insert; net worth excludes soft-deleted and excluded-flag accounts
- Sensitive `account_details` fields saved encrypted and non-readable without auth
- Account Detail screen renders balance, per-account paginated list, and contextual actions; Pay FAB appears only on credit card accounts
- Overdraft and credit limit warnings render correctly in widget tests

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `3. Use Cases` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-3 — Transactions Domain

### Objectives

- Implement the transaction entry form for income, expense, and transfer types; submit path runs through `LedgerEngine` in a single ACID transaction
- Implement the immutability + correction model: financial-field edits produce a reversal + correction pair; in-place edits bypass the model
- Render the Transaction Detail view (all fields, photo carousel, contextual menu) and support up to 2 compressed photo attachments
- Deliver the unified paginated transaction list (all accounts, month-filtered) and the per-account transaction list (all months)
- Implement search, filter, duplicate detection, and the draft / pending transaction flows
- Support transfer-with-fee compound groups, tagging, and the FTS5 full-text search index

### Notes

- TXN-01 is the single highest-blocking node in the entire DAG — 16 downstream nodes depend on it
- CAT-01 (E-4) and ACC-01 (E-2) are hard dependencies of TXN-01; this epic begins only after E-2 and E-4 Phase-1 stories land
- CURR-01 (E-5) is a hard dependency of TXN-01 for currency code at write time
- `type` is immutable after first save; correction model does not allow type changes

### Definition of Done

- User can save an income, expense, and transfer; each write produces balanced `entries` rows with `status = 'posted'`, `purpose = 'user'`; account balances update reactively
- Editing a financial field on a posted transaction produces: original `status → voided`, `purpose = 'reversal'` row, `purpose = 'correction'` row; in-place field edits update the row directly
- Transaction Detail view renders all §5.2.1.6 fields; photo carousel shows up to 2 photos; photo deletion removes file from storage
- Unified list and per-account list paginate at 50 rows, grouped by date; default filter excludes voided and reversal rows
- Duplicate detection fires a non-blocking warning on matching type + amount + account + category on the same calendar day
- FTS5 search returns results for partial title and description matches

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `4. Core Model: Double-Entry Bookkeeping` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-4 — Categories Domain

### Objectives

- Implement two-level (parent / child) category CRUD for separate income and expense trees; enforce name uniqueness, parent-delete guard, and two-level maximum
- Seed all default income and expense categories (including icons from the curated ~250-icon subset) on first install
- Implement the multi-step soft-delete + transaction migration wizard; batch migration must be atomic and handle N > 500 transactions within 5 s
- Protect the `Balance Adjustment` system category pair (income + expense trees); enforce picker exclusion and management-screen hiding

### Notes

- CAT-01 is a Phase-1 node that blocks TXN-01 — it must land as part of early Phase 1 alongside ACC-01 and CURR-01
- Icon curation (TC-014 founder resolution) is a soft dependency for CAT-02 seeding; schema and business logic can proceed before icons are confirmed
- `sort_order` column included in v1 schema as NULL to avoid a future migration (TC-028)

### Definition of Done

- CRUD routes work end-to-end; name uniqueness (case-insensitive, within same tree + parent, including soft-deleted) enforced at app layer
- Parent-with-children delete blocked; `sort_order` column present in schema
- First-install DB contains all default categories from PRD §5.2.4; `Balance Adjustment` rows seeded with `is_protected = 1` in both trees
- Soft-delete wizard executes all four steps in correct order; batch migration is atomic and rolls back on app kill; soft-deleted categories hidden from pickers but visible in filter dropdowns
- `is_protected = 1` categories excluded from transaction entry picker and category management screen in all widget tests

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `3. Use Cases` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-5 — Currency Domain

### Objectives

- Implement the exchange rate background fetch (WorkManager, daily max, scoped to user's account currencies) and the 14-day staleness disclaimer
- Implement automatic currency symbol disambiguation: when two active-account currencies share the same display symbol, append the ISO 4217 code in all affected views
- Surface a real-time home-currency estimate below the amount field during transaction entry for foreign-currency accounts; show staleness warning or "unavailable" note as appropriate

### Notes

- CURR-01 is a Phase-1 node and a hard dependency of ACC-03 (balance view) and TXN-01 (transaction entry) — it must land in parallel with ACC-01 and CAT-01
- Exchange rate fetch is opportunistic and silent; failure never blocks a transaction save
- Home currency change (TC-029) does not recompute existing `exchange_rate_to_home` values; the two-field model (`exchange_rate_to_home` + `home_currency_at_capture`) handles display-layer chain-conversion

### Definition of Done

- Exchange rate background fetch operational; `exchange_rates` table upserted on success; no network call issued when all accounts are in home currency
- Staleness disclaimer shown when `fetched_at > 14 days` in net worth view; no staleness warning blocks transaction save
- In a two-currency scenario with a shared symbol, ISO code appears alongside the symbol in account list, net worth view, transaction list, and transaction detail; single-currency scenario shows no change
- Entry form for a foreign-currency account shows `≈ [home symbol][amount]`; stale rate shows warning icon; no rate shows disclaimer; home-currency account entry form shows neither

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `4. Core Model: Double-Entry Bookkeeping` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-6 — Recurring & Scheduling Domain

### Objectives

- Deliver the scheduling infrastructure (app-launch sweep + WorkManager background task) that materializes and posts recurring and future-dated transactions
- Enable users to create, edit, pause, and archive recurring transaction templates with full lifecycle management
- Implement `remind_and_confirm` exact-alarm notifications with graceful permission-denied degradation
- Handle stacked missed occurrences on launch with chronological auto-approval and summary notification

### Notes

- SCHED-01 (sweep infrastructure) is a hard prerequisite for RECUR-01, SCHED-02, and TXN-10 — it must land first
- `RECEIVE_BOOT_COMPLETED` and `SCHEDULE_EXACT_ALARM` (Android 12+) and `POST_NOTIFICATIONS` (Android 13+) runtime permissions required
- Occurrence records are materialized rows (not computed exception lists); 90-day lookahead window refreshed on each launch
- Immutable template fields (type, recurrence definition, start/end date) are enforced at application layer only

### Definition of Done

- App-launch sweep posts all overdue occurrences before first frame; WorkManager task registered with 6-hour period
- Recurring template CRUD (create, edit editable fields, pause/unpause, archive/delete) fully functional
- `remind_and_confirm` exact alarm fires local notification; Confirm/Edit/Dismiss actions work; graceful fallback on permission denial
- Stacked missed occurrences auto-approved in chronological order; summary notification shown on launch
- Pause sets `pause_until`; skipped occurrences during pause are NOT backfilled on resume; auto-resume fires on launch when `pause_until <= now`
- Child transaction edit/delete marks occurrence as `skipped`; template delete cancels future occurrences

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-7 — Installments Domain

### Objectives

- Enable users to create installment series (fixed total divided into materialized per-period occurrences) for income, expense, and transfer transaction types
- Compute and display the four tracking amounts (total configured, running total, total remaining, projected final total) entirely at query time
- Implement the early-close flow: optional final payment, cancel remaining occurrences, archive template, mismatch check with update/keep options

### Notes

- Installment templates share the `recurring_templates` base with `is_installment = 1` discriminator; RECUR-01 (E-6) is a hard prerequisite
- All `installment_occurrences` rows are created eagerly at template creation time (unlike recurring 90-day lookahead)
- `total_configured` is immutable post-creation except via the guarded `updateTotalOnEarlyClose()` code path
- Per-installment amount mismatch warning is non-blocking; user can proceed with mismatched sum

### Definition of Done

- Installment template creates `recurring_templates` (is_installment=1) + `installment_plans` + all `installment_occurrences` rows eagerly; end date computed and read-only
- All three transaction types (income, expense, transfer-with-fee) work for installment templates
- Four tracking amounts computed correctly in all states: no postings, partial postings, voided children, corrected children
- Mismatch warning fires when `projected_final_total ≠ total_configured`
- Early-close flow completes all steps: final payment (optional) posts and links; remaining occurrences cancelled; template archived; both mismatch resolution paths (update/keep) work
- Add/remove future occurrence rows updates `total_remaining` and `projected_final_total` correctly

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-8 — Home / Dashboard Domain

### Objectives

- Deliver the home screen with greeting, net worth, monthly income/expense/net summary, and month-scoped transaction list
- Implement global FTS5 search (not month-scoped) and multi-facet filter (date range, account, category, transaction type)
- Add the Quick-Entry FAB that navigates to the transaction entry form, accommodating the draft resume entry point
- Render the alerts section (pending recurring confirmations, credit card payment due, backup reminder) with correct dismissal semantics
- Implement the one-time backup reminder alert triggered by first-month or 50-transaction threshold

### Notes

- HOME-01 is the root dependency for all other home domain nodes — it must land first
- Financial summary aggregates to home currency using `exchange_rate_to_home`; stale/missing rates trigger a staleness indicator, not an error
- Search is global (not month-scoped) per TC-050 founder resolution; SDS §2.8.4 has a known inconsistency that does not affect implementation
- Alert priority order (engineering decision): pending confirmations → credit card due → backup reminder
- No dedicated `alerts` table; state derived at runtime from `scheduled_occurrences`, `accounts`, and `app_settings`

### Definition of Done

- Month selector navigates forward/back; summary figures and transaction list re-query reactively via Riverpod stream provider
- Net worth excludes EQ accounts; empty month state shows CTA; future months show only pending transactions
- FTS5 search returns results within 500 ms for 10,000 transactions; clearing search re-engages month filter
- Filter sheet applies correctly on top of month-filtered or search-results list
- FAB navigates to `/transaction/new`; draft resume entry point accessible from FAB when `back_button_behaviour = auto_save_draft`
- All three alert card types render and their action/dismiss flows execute correctly
- Backup reminder appears exactly once when either trigger condition fires; flag written on dismiss or backup taken

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `5. Functional Requirements (Feature Graph)` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-9 — Settings Domain

### Objectives

- Build the Settings hub screen as the entry point to all preference groups, seeding and reading appearance keys (theme, color scheme, animations) from `app_settings`
- Deliver locale/format settings (home currency, decimal separator, thousands grouping, symbol placement, week start, time format, percentage precision)
- Implement transaction entry settings (description max length, back-button behaviour) and draft lifecycle (5-slot FIFO)
- Provide warnings/limits configuration (per-account and per-category large-transaction thresholds), profile settings (display name), and security settings (lock timeout, in-app PIN + Keyguard)
- Implement local data backup (versioned ZIP export via Android SAF, manifest + JSON + photos) with `last_backup_at` tracking
- Deliver account management and category management access surfaces (list, navigation to CRUD forms)
- Build the recurring + installment management screen (list templates by state, navigate to edit/detail)

### Notes

- SET-01 (hub + appearance) is a hard dependency of every other SET node — it must land first
- Home currency change (TC-029) does not recompute existing transaction `exchange_rate_to_home` values; display layer handles chain-conversion
- Lock never gates core functionality — it applies only to `account_details` sensitive field display
- Data backup (SET-07) is v1 export-only; import/restore deferred to v2
- SET-08 and SET-09 are access surfaces only; CRUD logic lives in ACC and CAT epics

### Definition of Done

- Settings hub renders all group entries; appearance changes apply immediately without restart
- All locale keys save and apply; home currency change affects only new account creation; formatting changes are display-only with no data migration
- Back-button behaviour on transaction form matches configured mode; draft count respects 5-slot FIFO limit
- Per-account and per-category threshold values save to their respective entity tables; TXN-07 fires warnings correctly
- Display name saves and appears in home screen greeting; empty/null shows fallback greeting
- Security lock gates only `account_details` sensitive field display; Keyguard → in-app PIN fallback hierarchy works; PIN recovery requires device security
- Backup ZIP written to selected SAF destination with valid manifest; `last_backup_at` updated; backup reminder clears
- Account management screen lists active and soft-deleted accounts; create/edit/reinstate/soft-delete flows accessible
- Category management screen shows two-level tree; create/rename/reorder/soft-delete/migration flows work; BAI/BAE categories hidden
- Recurring + installment management screen lists templates by state (active/paused/archived); edit/detail navigation works

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `5. Functional Requirements (Feature Graph)` (`docs/01-product/prd.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)

---

## E-10 — Onboarding Domain

### Objectives

- Deliver the 5-step first-launch wizard: welcome, currency selection (locale-prefilled), simplified account creation (name + type + initial balance, currency silent-defaulted), quick highlights, and done
- Gate all app routes behind a GoRouter redirect guard until `app_settings.onboarding_complete = 1`
- Write `home_currency` to `app_settings` at step 2 completion; set `onboarding_complete = 1` on wizard completion or skip

### Notes

- OB-01 depends on CAT-02 (default category seeding), CURR-01 (ISO 4217 list), and SET-02 (home currency write) — all three must be in place before this epic ships
- Category seeding runs at DB init (first migration) before any route renders; no race condition risk
- Step 3 account creation does NOT show the currency field; currency silently defaults to `app_settings.home_currency`
- Wizard cannot be re-run after `onboarding_complete = 1`; users adjust settings via individual Settings screens
- GoRouter guard must initialise `app_settings` provider at app startup (synchronous cached read) to avoid async blocking on redirect

### Definition of Done

- Wizard renders all 5 steps in order; skip on steps 2–4 writes locale-derived defaults and sets `onboarding_complete = 1`
- Step 2 currency selection writes `home_currency` to `app_settings`; picker uses the bundled ISO 4217 list
- Step 3 account creation creates the account with `home_currency` as currency; currency field is not shown
- GoRouter redirect guard routes all paths to `/onboarding` while `onboarding_complete = 0`; after wizard completes, subsequent cold starts bypass the wizard
- Home screen handles zero accounts gracefully (empty state CTA, no error from ACC-03)

### References

- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
- `4. Onboarding & First Launch` (`docs/02-technical/ux-flows.md`)
- `1. Architecture Overview` (`docs/02-technical/sds.md`)
