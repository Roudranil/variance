## Stories

## E6-S1 — Scheduling Infrastructure: App-Launch Sweep + WorkManager

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

## E6-S2 — Recurring Template Creation

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

## E6-S3 — Recurring Templates List + Detail/Edit Screen

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

## E6-S4 — Recurring Template Pause/Unpause

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

## E6-S5 — Remind-and-Confirm: Exact Alarm Notification + Confirm/Edit/Dismiss Actions

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

## E6-S6 — Runtime Permission Handling for Scheduling

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

## E6-S7 — Stacked Missed Occurrences: Auto-Approval + Summary Notification

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

## Tasks

## E6-T1 — Define `IScheduledOccurrenceRepository` + Drift DAO for `scheduled_occurrences`

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T2 — Define `IRecurringTemplateRepository` + Drift DAO for `recurring_templates`

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T3 — Implement `PostDueOccurrencesUseCase`

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T4 — Implement 90-day Lookahead Generation Logic

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T5 — Implement `AppInitializer` Synchronous Launch Sweep

**Parent Epic:** E-6
**Parent Story:** E6-S1

### Todo

- [ ] Create `AppInitializer` class in `infrastructure/` (or `app/`)
- [ ] In `main.dart`, call `AppInitializer.run()` before `runApp()`; it must complete before the first frame
- [ ] `AppInitializer.run()` calls `PostDueOccurrencesUseCase(asOf: DateTime.now())` synchronously
- [ ] `AppInitializer.run()` calls `GenerateLookaheadUseCase()` to refresh the 90-day window
- [ ] Store the count of auto-posted occurrences returned by `PostDueOccurrencesUseCase` for use by the Catch-Up Banner (E6-S7)
- [ ] Write unit test: mock use cases; verify both are called in order; verify result count is stored

### References

- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 Decision — TC-041: Hybrid WorkManager + Exact Alarm Model` (`docs/02-technical/sds.md`)
- `1.4.3 Background Write — Recurring Auto-Post` (`docs/02-technical/sds.md`)

---

## E6-T6 — Register WorkManager `PostingSweeperWorker`

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T7 — Implement `RecurringTemplate` Domain Entity + `CreateRecurringTemplateUseCase`

**Parent Epic:** E-6
**Parent Story:** E6-S2

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

## E6-T8 — Build Create Recurring Template Screen (UI + Form)

**Parent Epic:** E-6
**Parent Story:** E6-S2

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

## E6-T9 — Implement Recurrence Rule Validation + First-Date Preview Logic

**Parent Epic:** E-6
**Parent Story:** E6-S2

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

## E6-T10 — Build Recurring Templates List Screen

**Parent Epic:** E-6
**Parent Story:** E6-S3

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

## E6-T11 — Build Recurring Template Detail / Edit Screen

**Parent Epic:** E-6
**Parent Story:** E6-S3

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

## E6-T12 — Implement `UpdateRecurringTemplateUseCase` (Editable Fields Only)

**Parent Epic:** E-6
**Parent Story:** E6-S3

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

## E6-T13 — Implement Template Delete + Child Occurrence Cancellation

**Parent Epic:** E-6
**Parent Story:** E6-S3

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

## E6-T14 — Implement `SkipOccurrenceUseCase` + Child Transaction "Manually Handled" Marking

**Parent Epic:** E-6
**Parent Story:** E6-S3

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

## E6-T15 — Implement Pause Dialog UI + `PauseRecurringTemplateUseCase`

**Parent Epic:** E-6
**Parent Story:** E6-S4

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

## E6-T16 — Implement Unpause + Sweep Auto-Resume Logic

**Parent Epic:** E-6
**Parent Story:** E6-S4

### Todo

- [ ] In `IRecurringTemplateRepository.resume(id)`: set `status = 'active'`, `pause_until = NULL`, `updated_at = now()`
- [ ] Wire manual Unpause long-tap menu item to `resume(id)` with a confirmation snackbar
- [ ] In `PostDueOccurrencesUseCase` (E6-T3): before the posting loop, query templates where `status = 'paused'` and `pause_until <= now`; call `resume(id)` for each; do NOT retroactively post their skipped occurrences
- [ ] After resume: ensure sweep only picks up occurrences with `status = 'pending'` and `scheduled_date <= now` (skipped ones are not re-queued)
- [ ] Write unit tests: manual unpause sets active; auto-resume on sweep when pause_until passed; skipped occurrences remain skipped after resume

### References

- `RECUR-03 — Recurring Template Pause/Unpause` (`docs/02-technical/feature-dag.md`)
- `SCHED-01 — Scheduling Infrastructure (WorkManager + App-Launch Sweep)` (`docs/02-technical/feature-dag.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)

---

## E6-T17 — Implement `ReminderAlarmScheduler` Service

**Parent Epic:** E-6
**Parent Story:** E6-S5

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

## E6-T18 — Implement Notification Action Handlers (Confirm / Edit / Dismiss)

**Parent Epic:** E-6
**Parent Story:** E6-S5

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

## E6-T19 — Implement Alerts Strip Pending-Confirmation Card

**Parent Epic:** E-6
**Parent Story:** E6-S5

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

## E6-T20 — Declare Android Manifest Permissions + Runtime Permission Request Flow

**Parent Epic:** E-6
**Parent Story:** E6-S6

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

## E6-T21 — Implement Graceful Degradation on Permission Denial

**Parent Epic:** E-6
**Parent Story:** E6-S6

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

## E6-T22 — Implement Stacked Missed Occurrences Auto-Approval in Sweep

**Parent Epic:** E-6
**Parent Story:** E6-S7

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

## E6-T23 — Implement Summary Notification + Recurring Catch-Up Banner

**Parent Epic:** E-6
**Parent Story:** E6-S7

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

## E6-T24 — Integration Test: App-Launch Sweep End-to-End

**Parent Epic:** E-6
**Parent Story:** E6-S1

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

## E6-T25 — Integration Test: Remind-and-Confirm Full Flow

**Parent Epic:** E-6
**Parent Story:** E6-S5

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
