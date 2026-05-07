## Stories

## E10-S1 — Onboarding Wizard Shell and Chrome

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

## E10-S2 — GoRouter Redirect Guard for Onboarding

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

## E10-S3 — Step 1: Welcome Screen

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

## E10-S4 — Step 2: Currency Selection

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

## E10-S5 — Step 3: Create First Account

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

## E10-S6 — Step 4: Quick Highlights

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

## E10-S7 — Step 5: Done Screen and Completion Write

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

## E10-S8 — Home Screen Empty-State Handling for Zero Accounts

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

## E10-S9 — Onboarding Integration Test

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

## Tasks

## E10-T1 — AppSettingsDao: read and write app_settings rows

**Parent Epic:** E-10
**Parent Story:** E10-S2

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

## E10-T2 — AppSettingsRepository and AppSettingsNotifier (Riverpod)

**Parent Epic:** E-10
**Parent Story:** E10-S2

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

## E10-T3 — GoRouter redirect guard wired to AppSettingsNotifier

**Parent Epic:** E-10
**Parent Story:** E10-S2

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

## E10-T4 — OnboardingWizardScreen scaffold and PageController

**Parent Epic:** E-10
**Parent Story:** E10-S1

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

## E10-T5 — Step 1 Welcome widget

**Parent Epic:** E-10
**Parent Story:** E10-S3

### Todo

- [ ] Create `OnboardingStep1Welcome` as a `StatelessWidget`
- [ ] Layout: centered `Column` — app logo/wordmark icon (`primary`), app name text (`VarianceTypography.displayLargeAmount`, 36 sp, `onSurface`), tagline (`VarianceTypography.bodyLarge`, 16 sp, `onSurfaceVariant`), 3 value prop bullets (`VarianceTypography.bodyMedium`, 14 sp, `onSurfaceVariant`) with leading check icons
- [ ] Widget accepts no callbacks — chrome CTA is owned by `OnboardingWizardScreen`
- [ ] Write golden test for loaded state

### References

- `3.3 Step 1 — Welcome` (`docs/02-technical/ui-spec.md`)
- `3.3.1 Components` (`docs/02-technical/ui-spec.md`)

---

## E10-T6 — Locale-to-currency detection service

**Parent Epic:** E-10
**Parent Story:** E10-S4

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

## E10-T7 — Step 2 Currency Selection widget

**Parent Epic:** E-10
**Parent Story:** E10-S4

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

## E10-T8 — Step 3 Account Creation widget

**Parent Epic:** E-10
**Parent Story:** E10-S5

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

## E10-T9 — Step 4 Quick Highlights widget

**Parent Epic:** E-10
**Parent Story:** E10-S6

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

## E10-T10 — Step 5 Done widget and onboarding_complete write

**Parent Epic:** E-10
**Parent Story:** E10-S7

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

## E10-T11 — Wire step widgets into OnboardingWizardScreen

**Parent Epic:** E-10
**Parent Story:** E10-S1

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

## E10-T12 — Home screen zero-accounts empty state

**Parent Epic:** E-10
**Parent Story:** E10-S8

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

## E10-T13 — Integration test: full onboarding happy path

**Parent Epic:** E-10
**Parent Story:** E10-S9

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

## E10-T14 — Integration test: skip-all onboarding path

**Parent Epic:** E-10
**Parent Story:** E10-S9

### Todo

- [ ] Create scenario in integration test file: fresh DB → step 1 → "Get started" → step 2 → "Skip" (INR written) → step 3 → "Skip" (no account written) → step 4 → "Skip" → step 5 → "Start tracking" → home screen shows empty-state CTA
- [ ] Assertions: no account rows in DB after test; home screen renders empty-state CTA "Create your first account"; `onboarding_complete` reads `1`
- [ ] Confirm CTA navigates to `/accounts/new` without error

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `5.4 Flow — First Launch → Onboarding → Home` (`docs/02-technical/ux-flows.md`)
- `6.1 Home Screen States` (`docs/02-technical/ux-flows.md`)

---

## E10-T15 — Integration test: returning user bypass

**Parent Epic:** E-10
**Parent Story:** E10-S9

### Todo

- [ ] Create scenario: DB seeded with `onboarding_complete = 1` → app starts → assert `/onboarding` route is NOT visited → home screen renders directly
- [ ] Use `GoRouter`'s `RouteInformationProvider` or `navigatorKey` to assert current route is `/` on first frame after pump
- [ ] Confirm wizard `PageView` widget is not in the widget tree

### References

- `2.11.5 Integration Tests` (`docs/02-technical/sds.md`)
- `2.4.3 Navigation Rules` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---
