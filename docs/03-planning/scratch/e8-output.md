## Stories

## E8-S1 — Home Screen Dashboard Layout + Riverpod Wiring

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

## E8-S2 — Home Screen Transaction List (Monthly View)

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

## E8-S3 — Global FTS5 Search

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

## E8-S4 — Multi-Facet Filter Sheet

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

## E8-S5 — Quick-Entry FAB (SpeedDial)

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

## E8-S6 — Alerts Section (Recurring + Credit Card)

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

## E8-S7 — Backup Reminder Alert

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

## E8-S8 — Recurring Catch-Up Banner

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

## Tasks

## E8-T1 — Implement `HomeState` Domain Entity and `HomeNotifier`

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T2 — Implement `WatchNetWorthUseCase`

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T3 — Implement `WatchMonthlySummaryUseCase`

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T4 — Implement Greeting Row Widget

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T5 — Implement Financial Summary Card Grid

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T6 — Implement Month Selector Widget

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T7 — Implement Home Screen Skeleton, Error, and FX Banner States

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T8 — Implement `HomeScreen` Scaffold (CustomScrollView + SliverList)

**Parent Epic:** E-8
**Parent Story:** E8-S1

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

## E8-T9 — Implement Cursor-Based Paginated Transaction List Provider

**Parent Epic:** E-8
**Parent Story:** E8-S2

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

## E8-T10 — Implement 3-Column Transaction Row Widget

**Parent Epic:** E-8
**Parent Story:** E8-S2

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

## E8-T11 — Implement Date-Group Headers and SliverList Builder

**Parent Epic:** E-8
**Parent Story:** E8-S2

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

## E8-T12 — Implement Swipe Actions and Long-Press Menu on Transaction Rows

**Parent Epic:** E-8
**Parent Story:** E8-S2

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

## E8-T13 — Implement FTS5 Search DAO and `SearchRanker`

**Parent Epic:** E-8
**Parent Story:** E8-S3

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

## E8-T14 — Implement `SearchNotifier` with Global Scope and Debounce

**Parent Epic:** E-8
**Parent Story:** E8-S3

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

## E8-T15 — Implement Search Overlay UI (M3 SearchBar + Results List)

**Parent Epic:** E-8
**Parent Story:** E8-S3

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

## E8-T16 — Implement `FilterState` and `FilterNotifier`

**Parent Epic:** E-8
**Parent Story:** E8-S4

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

## E8-T17 — Implement Filter Bottom Sheet UI

**Parent Epic:** E-8
**Parent Story:** E8-S4

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

## E8-T18 — Implement Active Filter Chip Strip

**Parent Epic:** E-8
**Parent Story:** E8-S4

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

## E8-T19 — Implement Filtered Transaction List Query

**Parent Epic:** E-8
**Parent Story:** E8-S4

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

## E8-T20 — Implement SpeedDial FAB Widget

**Parent Epic:** E-8
**Parent Story:** E8-S5

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

## E8-T21 — Implement Drafts Entry Point in SpeedDial

**Parent Epic:** E-8
**Parent Story:** E8-S5

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

## E8-T22 — Implement `AlertsStrip` Widget Container

**Parent Epic:** E-8
**Parent Story:** E8-S6

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

## E8-T23 — Implement Pending Recurring Confirmation Alert Cards

**Parent Epic:** E-8
**Parent Story:** E8-S6

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

## E8-T24 — Implement Credit Card Payment Due Alert Cards

**Parent Epic:** E-8
**Parent Story:** E8-S6

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

## E8-T25 — Implement Backup Reminder Alert Card and Trigger Logic

**Parent Epic:** E-8
**Parent Story:** E8-S7

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

## E8-T26 — Implement `GetCatchUpBannerUseCase` and Catch-Up Banner Widget

**Parent Epic:** E-8
**Parent Story:** E8-S8

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
