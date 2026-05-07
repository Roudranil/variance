## Stories

## E9-S1 — Settings Hub + Appearance

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

## E9-S2 — Locale & Format Settings

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

## E9-S3 — Transaction Entry Settings + Draft Lifecycle

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

## E9-S4 — Warnings & Limits Settings

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

## E9-S5 — Profile Settings

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

## E9-S6 — Security Settings (Lock Timeout + PIN)

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

## E9-S7 — Data Backup (Export ZIP via SAF)

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

## E9-S8 — Account Management Access Screen

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

## E9-S9 — Category Management Access Screen

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

## E9-S10 — Recurring & Installment Management Screen

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

## Tasks

## E9-T1 — AppSettings DAO + IAppSettingsRepository implementation

**Parent Epic:** E-9
**Parent Story:** E9-S1

### Todo

- [ ] Create `AppSettingsDao` in Drift: `watch()` returning `Stream<AppSettings>` and `upsert(patch)` method
- [ ] Implement `AppSettingsRepositoryImpl` satisfying `IAppSettingsRepository`; wrap DAO calls with `Result` type
- [ ] Seed default values for all `app_settings` keys on first launch (insert row with defaults if table is empty); call from app startup before first paint
- [ ] Write unit tests for default seeding, watch stream emission on update, and upsert idempotency

### References

- `2.9.1 IAppSettingsRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## E9-T2 — AppSettingsNotifier + Riverpod provider wiring

**Parent Epic:** E-9
**Parent Story:** E9-S1

### Todo

- [ ] Implement `AppSettingsNotifier` as an `AsyncNotifier<AppSettings>` watching `IAppSettingsRepository.watch()`
- [ ] Register provider in the Riverpod DI graph; ensure it is accessible from all settings screens and from the theme layer (INFRA-5)
- [ ] Expose an `update(patch)` method on the notifier that calls `IAppSettingsRepository.update(patch)` and propagates result errors
- [ ] Write unit tests for notifier initial load, update propagation, and error state

### References

- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.9.1 IAppSettingsRepository` (`docs/02-technical/api-contracts.md`)
- `2.2 State Management and Reactivity` (`docs/02-technical/sds.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## E9-T3 — Settings Hub screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S1

### Todo

- [ ] Build `SettingsHubScreen` at route `/settings`; render 15 section entries in spec order as a sectioned `ListView`
- [ ] Each row is a `ListTile` with title, optional subtitle, and trailing chevron; tap triggers GoRouter push to the correct route
- [ ] Handle `AppSettingsNotifier` loading and error states gracefully (no blank screen)
- [ ] Write widget test asserting all 15 rows render and navigate correctly
- [ ] Write golden test for hub loaded state

### References

- `9.1 Screen: Settings Hub` (`docs/02-technical/ux-flows.md`)
- `9.1 Settings Hub` (`docs/02-technical/ui-spec.md`)
- `9.1.2 Settings Hub Sections (display order)` (`docs/02-technical/ux-flows.md`)
- `9.1.2 Section Groups (display order)` (`docs/02-technical/ui-spec.md`)
- `2.4.2 Route Structure` (`docs/02-technical/sds.md`)
- `SET-01 — Settings Hub + Appearance` (`docs/02-technical/feature-dag.md`)

---

## E9-T4 — Appearance settings screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S1

### Todo

- [ ] Build `AppearanceSettingsScreen` at route `/settings/appearance`
- [ ] Theme segmented button (Light / Dark / System default); writes `app_settings.theme` via `AppSettingsNotifier.update(patch)`
- [ ] Color scheme segmented button (Dynamic / Custom / Catppuccin); writes `app_settings.color_scheme_mode`
- [ ] Seed color picker row (visible only when color scheme = Custom); writes `app_settings.color_seed`
- [ ] Animations toggle switch; writes `app_settings.animations_enabled`
- [ ] "Preview color scheme" tappable row navigates to `/settings/appearance/preview`
- [ ] Changes apply immediately via INFRA-5 theme rebuild (reactive to `AppSettingsNotifier` stream)
- [ ] Write widget tests for each control save path; golden test for loaded state

### References

- `9.2 Screen: Appearance Settings` (`docs/02-technical/ux-flows.md`)
- `9.2 Appearance Settings` (`docs/02-technical/ui-spec.md`)
- `9.2.2 Settings` (`docs/02-technical/ux-flows.md`)
- `9.2.1 Components` (`docs/02-technical/ui-spec.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)
- `2.18.1 Decision: Type-Safe ThemeExtension` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## E9-T5 — Dynamic color OEM fallback + Color Scheme Preview screen

**Parent Epic:** E-9
**Parent Story:** E9-S1

### Todo

- [ ] Wrap theme root with `DynamicColorBuilder`; when builder returns null, auto-switch `color_scheme_mode` to `custom` and show inline note "Dynamic color not available on this device" in Appearance screen
- [ ] Build `ColorSchemePreviewScreen` at route `/settings/appearance/preview`; render M3 token swatches (primary, secondary, tertiary, surface, on-surface) labelled with role names; derived from active mode
- [ ] Write widget test for the fallback inline note display
- [ ] Write golden test for the preview screen swatch grid

### References

- `9.2.3 Dynamic Color Unavailable` (`docs/02-technical/ux-flows.md`)
- `9.2.4 Color Scheme Preview Screen` (`docs/02-technical/ux-flows.md`)
- `9.2.3 Color Scheme Preview Sub-screen` (`docs/02-technical/ui-spec.md`)
- `TC-048: Minimum API level inconsistency with dynamic color` (`docs/01-product/technical-clarifications.md`)
- `2.18 Theming Architecture` (`docs/02-technical/sds.md`)

---

## E9-T6 — Locale & Format settings screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S2

### Todo

- [ ] Build `LocaleFormatSettingsScreen` at route `/settings/locale`
- [ ] Home currency picker row: opens full-screen currency picker (backed by bundled ISO 4217 list from CURR-01); on select, writes `app_settings.home_currency`
- [ ] Decimal separator selector (period / comma); thousands grouping selector (none / western / Indian)
- [ ] Currency symbol placement (before/after amount) and spacing (space/no-space) controls
- [ ] Week start day selector; time format selector (12h/24h); percentage decimal precision selector
- [ ] All saves via `AppSettingsNotifier.update(patch)`; amount re-render happens immediately via reactive rebuild
- [ ] Write widget tests for each field save path

### References

- `9.3 Screen: Locale & Format Settings` (`docs/02-technical/ux-flows.md`)
- `9.3 Locale & Format Settings` (`docs/02-technical/ui-spec.md`)
- `9.3.2 Settings` (`docs/02-technical/ux-flows.md`)
- `9.3.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `4.1 currencies` (`docs/02-technical/data-model.md`)
- `SET-02 — Locale + Format Settings` (`docs/02-technical/feature-dag.md`)

---

## E9-T7 — Home currency change semantics + display formatting pipeline

**Parent Epic:** E-9
**Parent Story:** E9-S2

### Todo

- [ ] Implement the amount formatting utility that reads `app_settings` locale keys (decimal separator, grouping, symbol placement/spacing) and formats a `Money` value; used by all amount display widgets
- [ ] Verify that changing `home_currency` writes only `app_settings.home_currency` and does not rewrite any `transactions.exchange_rate_to_home` rows
- [ ] Unit tests: Indian grouping produces correct 2-2-3 output for amounts >= 1,00,000; western grouping produces correct 3-group output; symbol placement/spacing variants all produce correct strings
- [ ] Unit test: home currency change does not trigger any DB migration or bulk update

### References

- `SET-02 — Locale + Format Settings` (`docs/02-technical/feature-dag.md`)
- `TC-029: How does the app handle home currency changes after transactions exist?` (`docs/01-product/technical-clarifications.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `12.3 Money Value Object` (`docs/02-technical/data-model.md`)

---

## E9-T8 — Transaction Entry settings screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S3

### Todo

- [ ] Build `TransactionEntrySettingsScreen` at route `/settings/transaction-entry`
- [ ] Description max length integer field; validates > 0; writes `app_settings.description_max_length`
- [ ] Back-button behaviour segmented control: Ask / Auto-save draft / Discard immediately; writes `app_settings.back_button_behaviour`
- [ ] Render draft lifecycle info card (5-slot FIFO, no expiry) as an inline informational card when auto-save is selected
- [ ] All saves via `AppSettingsNotifier.update(patch)`
- [ ] Write widget tests for each field and the info card visibility logic (visible only when auto-save selected)

### References

- `9.4 Screen: Transaction Entry Settings` (`docs/02-technical/ux-flows.md`)
- `9.4 Transaction Entry Settings` (`docs/02-technical/ui-spec.md`)
- `9.4.3 Draft Lifecycle Note (displayed as info card in screen)` (`docs/02-technical/ux-flows.md`)
- `9.4.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-03 — Transaction Entry Settings` (`docs/02-technical/feature-dag.md`)

---

## E9-T9 — IDraftRepository implementation + FIFO enforcement

**Parent Epic:** E-9
**Parent Story:** E9-S3

### Todo

- [ ] Implement `DraftRepositoryImpl` satisfying `IDraftRepository` (`watchAll`, `upsert`, `delete`); backed by the `drafts` Drift table
- [ ] Implement `DraftListNotifier` as `AsyncNotifier<List<Draft>>` watching `IDraftRepository.watchAll()`
- [ ] Implement FIFO cap logic: before inserting a new draft, if count == 5, delete the oldest (by `created_at` ascending); then insert
- [ ] Show toast "Oldest draft was removed to make room." on eviction
- [ ] `payload_json` must include a `schema_version` field; on load, discard rows where schema version does not match the current app version schema
- [ ] Unit tests: FIFO eviction at cap (count stays <= 5); stale draft detection and discard; toast fires exactly once on eviction

### References

- `2.9.2 IDraftRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `9.2 drafts` (`docs/02-technical/data-model.md`)
- `TC-005: "Auto-save as draft" back button behaviour — draft lifecycle` (`docs/01-product/technical-clarifications.md`)
- `SET-03 — Transaction Entry Settings` (`docs/02-technical/feature-dag.md`)

---

## E9-T10 — Warnings & Limits screen: per-account thresholds

**Parent Epic:** E-9
**Parent Story:** E9-S4

### Todo

- [ ] Build the Per-Account Limits sub-screen at `/settings/warnings/accounts`
- [ ] Load all accounts via `IAccountRepository.watchAll()`; render as a list with an inline threshold amount field per row
- [ ] Field label shows the account's native currency symbol
- [ ] On change, call `IAccountRepository.update(id, patch)` writing `large_txn_threshold`
- [ ] Entry point screen (`/settings/warnings`) renders two navigation rows: "Per-Account Limits" and "Per-Category Limits"
- [ ] Write widget tests for list render, field save, and multi-currency label correctness

### References

- `9.5 Screen: Warnings & Limits` (`docs/02-technical/ux-flows.md`)
- `9.5.2 Per-Account Limits Sub-screen` (`docs/02-technical/ux-flows.md`)
- `9.5.2 Per-Account Limits Sub-screen` (`docs/02-technical/ui-spec.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `2.1.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `SET-04 — Warnings + Limits Settings` (`docs/02-technical/feature-dag.md`)
- `TC-047: Per-account and per-category large transaction thresholds — currency handling` (`docs/01-product/technical-clarifications.md`)

---

## E9-T11 — Warnings & Limits screen: per-category thresholds

**Parent Epic:** E-9
**Parent Story:** E9-S4

### Todo

- [ ] Build the Per-Category Limits sub-screen at `/settings/warnings/categories`
- [ ] Load all expense/income categories (excluding BAI/BAE system categories); render with inline threshold field per row; label shows home currency symbol
- [ ] On change, call `ICategoryRepository.update(id, patch)` writing `large_txn_threshold`
- [ ] Write widget tests for list render, BAI/BAE exclusion, and field save

### References

- `9.5.3 Per-Category Limits Sub-screen` (`docs/02-technical/ux-flows.md`)
- `9.5.3 Per-Category Limits Sub-screen` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `SET-04 — Warnings + Limits Settings` (`docs/02-technical/feature-dag.md`)
- `TC-047: Per-account and per-category large transaction thresholds — currency handling` (`docs/01-product/technical-clarifications.md`)

---

## E9-T12 — Profile settings screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S5

### Todo

- [ ] Build `ProfileSettingsScreen` at route `/settings/profile`
- [ ] Single `TextField` for display name; pre-filled from `AppSettingsNotifier`; optional (allows empty string)
- [ ] On submit/blur, call `AppSettingsNotifier.update(patch)` writing `display_name`
- [ ] Home screen greeting widget rebuilds reactively from `AppSettingsNotifier` stream: shows "Hi, [name]!" when non-empty, "Hi!" when empty
- [ ] Widget tests: non-empty name shows correct greeting; clearing field shows "Hi!" greeting

### References

- `9.6 Screen: Profile Settings` (`docs/02-technical/ux-flows.md`)
- `9.6 Profile Settings` (`docs/02-technical/ui-spec.md`)
- `9.6.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-05 — Profile Settings (Display Name)` (`docs/02-technical/feature-dag.md`)

---

## E9-T13 — Security settings screen + lock timeout

**Parent Epic:** E-9
**Parent Story:** E9-S6

### Todo

- [ ] Build `SecuritySettingsScreen` at route `/settings/security`
- [ ] Lock timeout selector (options: 1 min / 5 min / 15 min / never); writes `app_settings.lock_timeout_seconds`
- [ ] "Set PIN" / "Change PIN" row navigates to PIN setup screen (mode=set or mode=change)
- [ ] App lifecycle listener: on background → foreground, check elapsed time vs. `lock_timeout_seconds`; if exceeded, show lock overlay gating `account_details` sensitive field display
- [ ] GoRouter guard: applies ONLY to the `account_details` sensitive fields route; no other routes redirected
- [ ] Write widget tests for timeout selector save and screen navigation

### References

- `9.7 Security Settings` (`docs/02-technical/ui-spec.md`)
- `9.7.1 Components` (`docs/02-technical/ui-spec.md`)
- `5.1 App Lock Overlay` (`docs/02-technical/ux-flows.md`)
- `5.1.2 Lock Conditions` (`docs/02-technical/ux-flows.md`)
- `1.6.12 Security Lock Scope — Sensitive Fields Only` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## E9-T14 — PIN setup, change, and entry screens

**Parent Epic:** E-9
**Parent Story:** E9-S6

### Todo

- [ ] Build `PinSetupScreen` (mode=set: enter + confirm PIN; mode=change: verify current PIN, then enter + confirm new PIN); store encrypted PIN via `flutter_secure_storage`
- [ ] Build `PinEntryOverlay` / `PinEntryScreen`: numeric keypad, attempt counter displayed after first failure, "Forgot PIN" link
- [ ] Implement `local_auth` Keyguard call as the primary authentication attempt; fall back to in-app PIN when `local_auth` returns `notAvailable` or `notEnrolled`
- [ ] After 15 consecutive PIN failures: wipe only encrypted rows in `account_details`; reset attempt counter; show confirmation snackbar
- [ ] Write widget tests for PIN setup (set and change modes), PIN entry states, and lockout wipe behaviour

### References

- `5.2 PIN Setup Screen` (`docs/02-technical/ux-flows.md`)
- `5.3 PIN Entry Screen` (`docs/02-technical/ux-flows.md`)
- `5.7 Flow — PIN Setup: First Time` (`docs/02-technical/ux-flows.md`)
- `5.8 Flow — PIN Setup: Change PIN` (`docs/02-technical/ux-flows.md`)
- `5.9 Flow — PIN Reset: Forgot PIN` (`docs/02-technical/ux-flows.md`)
- `4.3 PIN Setup Screen` (`docs/02-technical/ui-spec.md`)
- `4.4 PIN Entry Screen / Overlay` (`docs/02-technical/ui-spec.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## E9-T15 — Resolve OQ-SDS-SC-001: secure storage backup exclusion

**Parent Epic:** E-9
**Parent Story:** E9-S6

### Todo

- [ ] Investigate `flutter_secure_storage` behaviour under Android `BackupAgent` on API 31+
- [ ] Add `android:allowBackup="false"` or configure `excludeFromEncryptedBackup` rules in `AndroidManifest.xml` / backup rules XML to exclude `flutter_secure_storage` data from device backups
- [ ] Verify the exclusion is effective: install app, set PIN, trigger backup, restore on a fresh device — PIN must not be present after restore
- [ ] Document resolution in the SDS open questions section (OQ-SDS-SC-001 status set to resolved)

### Notes

- Blocking requirement before E9-S6 (SET-06) can ship

### References

- `1.6.12 Security Lock Scope — Sensitive Fields Only` (`docs/02-technical/sds.md`)
- `SET-06 — Security Settings (Lock + PIN)` (`docs/02-technical/feature-dag.md`)

---

## E9-T16 — Backup screen widget + SAF file picker integration

**Parent Epic:** E-9
**Parent Story:** E9-S7

### Todo

- [ ] Build `BackupDataScreen` at route `/settings/backup`; show last backup timestamp (from `app_settings.last_backup_at`); "Backup Now" button
- [ ] On tap: launch Android SAF directory picker (`ACTION_OPEN_DOCUMENT_TREE`); on selection, start export service
- [ ] Fall back to `Downloads` directory if SAF returns null or fails
- [ ] Show in-progress indicator during export; show success snackbar with file path on completion; show error snackbar on failure
- [ ] Write widget tests for loaded state (with and without previous backup), in-progress state, and success/error states

### References

- `SET-07 — Data Backup (Export ZIP)` (`docs/02-technical/feature-dag.md`)
- `2.17 Backup Format` (`docs/02-technical/sds.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)

---

## E9-T17 — ZIP export engine (manifest + entity serialisation + photos)

**Parent Epic:** E-9
**Parent Story:** E9-S7

### Todo

- [ ] Implement `BackupService` running in a background isolate: opens a Drift read-only transaction, serialises all non-deleted entities to `variance_export.json`, collects attached photo paths from `attachments` table
- [ ] Build `manifest.json`: `backup_format_version: 1`, `app_version` (from package info), `created_at` ISO 8601 UTC, `schema_version` (from `app_settings.schema_backup_version`)
- [ ] Assemble ZIP: add `manifest.json`, `variance_export.json`, and each resolved photo file; skip files that do not exist on disk (log warning, continue)
- [ ] After successful write, call `AppSettingsNotifier.update({last_backup_at: now_unix_epoch})`
- [ ] Unit tests: manifest JSON structure is valid; soft-deleted entities are absent from export; missing photo files are skipped without exception; `last_backup_at` is written on success

### References

- `2.17.1 Decision — TC-054: Versioned ZIP Archive with Manifest` (`docs/02-technical/sds.md`)
- `2.17 Backup Format` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `9.1 app_settings` (`docs/02-technical/data-model.md`)
- `11.2 Soft Delete Policy` (`docs/02-technical/data-model.md`)
- `SET-07 — Data Backup (Export ZIP)` (`docs/02-technical/feature-dag.md`)

---

## E9-T18 — Account Management screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S8

### Todo

- [ ] Build `AccountManagementScreen` at route `/settings/accounts`
- [ ] Load accounts via `IAccountRepository.watchAll()` (including soft-deleted); group active by account category in fixed type order, alphabetical within group; section headers when > 1 group
- [ ] Render each row: account name + account category badge + currency symbol if multi-currency
- [ ] Soft-deleted accounts in a separate section with visual indicator and "Reinstate" action; tap "Reinstate" calls `IAccountRepository.reinstate(id)`
- [ ] Tap active row → navigate to account detail (`/accounts/:id`); FAB or top-right button → navigate to create account (`/accounts/new`)
- [ ] Write widget tests: loaded state (active + soft-deleted), empty state, grouping order, reinstate action

### References

- `SET-08 — Account Management Screen` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `2.1.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `TC-057: Multiple accounts per account category — display and disambiguation` (`docs/01-product/technical-clarifications.md`)

---

## E9-T19 — Category Management screen widget

**Parent Epic:** E-9
**Parent Story:** E9-S9

### Todo

- [ ] Build `CategoryManagementScreen` at route `/settings/categories`
- [ ] Render two-level expandable tree: parent categories with expand/collapse chevron; child categories indented below parent
- [ ] `+` button at parent level opens create parent category form; `+` at child level opens create child category form within that parent
- [ ] Exclude BAI/BAE system categories from the list (filter by `is_system = true` or equivalent flag)
- [ ] Long-press or swipe on any row opens contextual menu: rename, reorder, delete
- [ ] Write widget tests: tree render, BAI/BAE exclusion, empty parent (no children), `+` button navigation

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.8.1 Components` (`docs/02-technical/ui-spec.md`)
- `9.8.3 Behaviour Notes` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `SET-09 — Category Management Screen` (`docs/02-technical/feature-dag.md`)

---

## E9-T20 — Category icon picker widget

**Parent Epic:** E-9
**Parent Story:** E9-S9

### Todo

- [ ] Build `CategoryIconPickerSheet` bottom sheet: searchable grid of the curated ~250-icon `material_symbols_icons` subset
- [ ] Define the curated icon list as a `const List<IconData>` in a dedicated constants file; use placeholder set while curation is finalised (TC-014)
- [ ] On icon tap, return selected `IconData` to caller; render selected icon in the category create/edit form
- [ ] Search field filters the grid by icon name substring
- [ ] Write widget tests for grid render, search filtering, and selection callback

### References

- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.9.1 Components` (`docs/02-technical/ui-spec.md`)
- `TC-014: "Curated subset" of material_symbols_icons — who defines it and when` (`docs/01-product/technical-clarifications.md`)
- `SET-09 — Category Management Screen` (`docs/02-technical/feature-dag.md`)

---

## E9-T21 — Recurring & Installment Management screen: recurring templates section

**Parent Epic:** E-9
**Parent Story:** E9-S10

### Todo

- [ ] Build `RecurringManagementScreen` at route `/settings/recurring`
- [ ] Load recurring templates via `IRecurringTemplateRepository.watchAll()`; group by state: active, paused, archived (soft-deleted)
- [ ] Render each row: template name, recurrence summary (e.g. "Monthly on the 1st"), posting behaviour badge (auto-post / remind)
- [ ] Contextual menu or swipe actions: pause (active→paused), unpause (paused→active), archive (non-archived→soft-deleted); archived section shows restore action only
- [ ] Tap row → navigate to template detail/edit screen
- [ ] Write widget tests: loaded state (all three groups), empty state, contextual action triggers

### References

- `SET-10 — Recurring + Installment Management Screen` (`docs/02-technical/feature-dag.md`)
- `7.1 recurring_templates` (`docs/02-technical/data-model.md`)
- `2.6.1 IRecurringTemplateRepository` (`docs/02-technical/api-contracts.md`)
- `2.6.4 Notifiers & Services` (`docs/02-technical/api-contracts.md`)

---

## E9-T22 — Recurring Management screen: installment plans section

**Parent Epic:** E-9
**Parent Story:** E9-S10

### Todo

- [ ] Add installment plans section to `RecurringManagementScreen` (separate section below recurring templates)
- [ ] Load plans via `IInstallmentPlanRepository.watchAll()`; group by state: active, completed, archived
- [ ] Render each row: plan description, instalment count (paid / total), next due date
- [ ] Tap row → navigate to installment plan detail screen
- [ ] Write widget tests for plans section render, empty section state, and navigation

### Notes

- SOFT dependency on INST-01; this task ships only after INST-01 is available

### References

- `SET-10 — Recurring + Installment Management Screen` (`docs/02-technical/feature-dag.md`)
- `8.1 installment_plans` (`docs/02-technical/data-model.md`)
- `2.7.1 IInstallmentPlanRepository` (`docs/02-technical/api-contracts.md`)

---
