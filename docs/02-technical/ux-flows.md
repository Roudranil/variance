---
version: 0.1.0
status: draft
last_updated: 2026-04-29
---

# UX Flows

## 1. Shared Sub-flows

### 1.1 Category Picker (UX-11)

**Invocation:** bottom sheet, pushed from transaction entry (income/expense forms only). Not used on transfer forms.

#### 1.1.1 Sheet States

| State | Condition | UI |
|-------|-----------|----|
| Loading | Initial open, categories loading | Shimmer skeleton list |
| Recents | <5 categories used | "Recents" chip strip above full list |
| Populated | Categories exist | Search field + recents strip + scrollable two-level list |
| Empty (no categories) | Zero categories in tree | Inline empty label + "Create category" CTA |
| Search results | Query entered | Filtered flat list (parent + child matched); "No results" + inline create if zero matches |
| Inline create | User taps "+ New" | Inline row expands: icon picker + name field + confirm |

#### 1.1.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Sheet opens | — | Loads category tree for active transaction type (income or expense) | Populated or Empty |
| 2 | Search field | Types query | Filters list: parents then children, fuzzy match | Search results |
| 3 | Recent chip strip | Taps a recent category | Selection applied; sheet dismisses | Picker closed; category field updated |
| 4 | Parent row (no children) | Taps row | Selection applied; sheet dismisses | Picker closed |
| 5 | Parent row (has children) | Taps row | Expands child list inline below parent | Children visible |
| 6 | Child row | Taps row | Selection applied (parent + child both stored); sheet dismisses | Picker closed |
| 7 | "+ New category" button | Taps | Inline create row appears at list bottom | Inline create state |
| 8 | Inline create — icon picker | Taps icon field | Icon picker sub-sheet opens (grid of ~250 curated icons, searchable) | Icon sub-sheet |
| 9 | Inline create — name field | Types name | Real-time uniqueness check within tree | Input active |
| 10 | Inline create — confirm | Taps confirm (or Enter) | Validates (name non-empty, unique); creates category; auto-selects it; sheet dismisses | Picker closed; category field updated |
| 11 | Inline create — name conflict | Duplicate name | Inline error: "Name already exists in this tree" | Input error |
| 12 | Drag handle / back | Dismisses | Sheet closes with no selection change | Picker closed; field unchanged |

#### 1.1.3 Rules

- Soft-deleted categories hidden from picker except when editing a transaction that already references one (shown as special "current" entry at top, per PRD §5.2.2).
- Inline create creates a **parent category only**. Child (subcategory) creation is in Settings > Categories.
- Recents: up to 5 most recently used categories for the active type, ordered by recency.
- Sheet title: "Select Category" with active tree label ("Income" or "Expense").

---

### 1.2 Payee Picker

**Invocation:** bottom sheet from transaction entry (Title field shortcut or dedicated Payee field — deferred to field spec). v1: Payee is free-text backed by a suggestion list derived from existing transaction titles/payees.

#### 1.2.1 Sheet States

| State | Condition | UI |
|-------|-----------|----|
| Loading | Initial open | Shimmer list |
| Suggestions | Query empty | Recent/frequent payees list |
| Search results | Query entered | Filtered suggestion list |
| No results | No match | "No results" label + "+ Use '[query]'" inline create row |

#### 1.2.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Sheet opens | — | Loads recent payees | Suggestions |
| 2 | Search field | Types name | Filters suggestions; fuzzy match | Search results |
| 3 | Suggestion row | Taps | Selection applied; sheet dismisses | Picker closed; title/payee field updated |
| 4 | "+ Use '[query]'" row | Taps | Creates new payee entry; selection applied; sheet dismisses | Picker closed |
| 5 | Back / drag handle | Dismisses | Sheet closes with no change | Picker closed |

---

### 1.3 Tag Picker

**Status:** Tags are deferred to v2 (not in PRD §8.1 v1 scope). This sub-flow spec is a placeholder for v2. No tag picker is implemented in v1.

---

### 1.4 Account Picker

**Invocation:** bottom sheet from transaction entry (source account, destination account fields) and transfer destination selection.

#### 1.4.1 Sheet States

| State | Condition | UI |
|-------|-----------|----|
| Loading | Initial open | Shimmer list |
| Populated | Accounts exist | Scrollable account list grouped by account category |
| Empty | No eligible accounts | Inline empty + "Create account" CTA |
| Filtered (transfer) | Source already selected | Destination list excludes source account |

#### 1.4.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Sheet opens | — | Loads active (non-deleted) accounts eligible for this field | Populated or Empty |
| 2 | Account row | Taps | Selection applied; sheet dismisses | Picker closed; account field updated |
| 3 | Back / drag handle | Dismisses | Sheet closes with no change | Picker closed |

#### 1.4.3 Rules

- Soft-deleted accounts excluded (PRD §5.1.1.5).
- For transfer destination: source account excluded from list.
- Each row shows: account name, account category type, current balance (formatted with currency).
- Sheet title context: "Select Source Account" or "Select Destination Account".

---

### 1.5 Currency Picker

**Invocation:** full-screen modal from account creation (currency field) and onboarding step 2 (home currency selection).

#### 1.5.1 Screen States

| State | Condition | UI |
|-------|-----------|----|
| Loading | — | Full-screen shimmer list |
| Populated | ISO 4217 list loaded | Search field + scrollable list of currencies (code + name + symbol) |
| Search results | Query entered | Filtered list; fuzzy match on code, name, or symbol |
| No results | No match | "No currencies match '[query]'" label |

#### 1.5.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Modal opens | — | Loads bundled ISO 4217 list; highlights current selection | Populated |
| 2 | Search field | Types code or name | Filters list; fuzzy match | Search results |
| 3 | Currency row | Taps | Selection applied; modal dismisses | Modal closed; currency field updated |
| 4 | Back arrow / system back | Dismisses | Modal closes with no change | Previous screen |

#### 1.5.3 Rules

- Full-screen (not bottom sheet) — long list warrants full height.
- Current selection displayed with checkmark.
- Popular currencies (INR, USD, EUR, GBP, JPY) pinned at top of unpinned list.
- Account currency picker shows immutability tooltip inline: "Currency cannot be changed after creation."

---

### 1.6 Amount Entry (UX-12)

**Invocation:** Amount field on all transaction entry forms. System keyboard only — no custom numeric pad.

#### 1.6.1 Field States

| State | Condition | UI |
|-------|-----------|----|
| Empty | Field unfocused, no value | Placeholder "0.00" |
| Active | Field focused | System numeric keyboard; current expression shown in field |
| Expression | User types arithmetic (e.g. "120+80") | Expression shown as typed; no intermediate evaluation |
| Evaluated | User taps Done / Next | Expression evaluated to result (e.g. "200.00"); result replaces expression |
| Error | Expression invalid (e.g. "120++") | Field border error colour; expression retained; submission blocked |
| Validated | Valid positive decimal | Inline home-currency estimate shown below field if account currency ≠ home currency |

#### 1.6.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Amount field | Taps | System keyboard opens; field highlighted | Active |
| 2 | Keyboard | Types numeric expression | Expression displayed in field character by character | Expression |
| 3 | "Done" / "Next" key | Taps | Expression parsed and evaluated (supports +, −, ×, ÷, parentheses); result formatted to 2 d.p. | Evaluated or Error |
| 4 | Invalid expression | — | Inline error: "Invalid expression"; field border red; form save blocked | Error |
| 5 | Valid result | — | Amount field shows result; if account ≠ home currency, home-currency estimate appears below (informational) | Validated |

#### 1.6.3 Rules

- Locale-aware decimal separator (comma or period per Settings §5.4.2).
- Must be > 0 (PRD §5.2.1 field table).
- Expression evaluation is client-side, no network call.
- Supported operators: `+`, `-`, `*`, `/`, `(`, `)`.
- Result is truncated (not rounded) to the account currency's decimal precision.

---

### 1.7 Photo Attachment (UX-14)

**Invocation:** bottom sheet from transaction entry or transaction detail edit (photo field area tap / "Add photo" button).

#### 1.7.1 Sheet States

| State | Condition | UI |
|-------|-----------|----|
| Chooser | Sheet opened, < 2 photos attached | Action list: Camera, Gallery, Cancel |
| Full | 2 photos already attached | "Add photo" button disabled; tooltip "Maximum 2 photos per transaction" |

#### 1.7.2 Interaction Flow — Attach

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Photo area / "Add photo" | Taps | Bottom sheet opens with Camera / Gallery options | Chooser |
| 2 | "Camera" option | Taps | System camera intent launched; user takes photo | Camera active |
| 3 | Photo captured | Confirms in camera | Photo compressed; thumbnail preview shown in form | Preview inline |
| 4 | "Gallery" option | Taps | System gallery intent launched; user selects image | Gallery active |
| 5 | Image selected | Confirms in gallery | Photo compressed; thumbnail preview shown in form | Preview inline |
| 6 | Second photo | Taps "Add photo" | Sheet opens again (Camera / Gallery); max 2 enforced | Chooser (if 1 photo) or disabled (if 2 photos) |
| 7 | Cancel | Taps Cancel or drag-dismisses | Sheet closes; no change | No change |

#### 1.7.3 Rules

- Max 2 photos per transaction (PRD §5.2.3).
- Photos stored in app-private storage; not exposed to OS gallery.
- Compression applied before storage (algorithm deferred to implementation task).
- Photos deleted permanently when transaction is soft-deleted (PRD §5.2.3).
- "Add photo" action available on both new entry and edit (photos are in-place editable, PRD §5.2.2).
- Each thumbnail tap → Photo Viewer (§1.8).

---

### 1.8 Photo Viewer

**Invocation:** Tapping a photo thumbnail in transaction detail or edit form.

#### 1.8.1 Viewer States

| State | Condition | UI |
|-------|-----------|----|
| Viewing | Photo loaded | Full-screen image; translucent top bar with back arrow + delete icon |
| Loading | Photo loading | Centred circular progress indicator |
| Error | Photo missing or corrupt | Centred error icon + "Photo unavailable" label |
| Delete confirm | User taps delete | Bottom confirm sheet: "Delete photo?" with Delete / Cancel |

#### 1.8.2 Interaction Flow

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Thumbnail | Taps | Full-screen viewer opens; image loads | Viewing |
| 2 | Pinch/spread | Gesture | Zoom in/out (standard photo viewer behaviour) | Viewing |
| 3 | Delete icon | Taps | Confirm sheet appears | Delete confirm |
| 4 | "Delete" (confirm) | Taps | Photo removed from storage; thumbnail removed from form | Viewer closes; form updated |
| 5 | "Cancel" (confirm) | Taps | Confirm sheet dismissed | Viewing |
| 6 | Back arrow / system back | Taps | Viewer closes | Previous screen |

#### 1.8.3 Rules

- Delete action available in viewer only when accessed from transaction detail/edit (not from a voided transaction in read-only state).
- Photo deletion is immediate and permanent (in-place edit, no ledger entry).
- Swipe between photos if multiple attached (up to 2).

---

### 1.9 Draft Auto-save

**Trigger:** Back navigation or app backgrounding while transaction entry form has any field populated.

#### 1.9.1 Draft States

| State | Condition | UI |
|-------|-----------|----|
| No draft | No prior session | Normal empty form |
| Draft exists | Prior interrupted session | Form pre-filled with last draft values; banner: "Draft restored" |
| Draft discarded | User explicitly discards | Form cleared; banner dismissed |

#### 1.9.2 Interaction Flow — Save

| Step | UI element | User action | System response | Next state |
|------|-----------|-------------|-----------------|------------|
| 1 | Form (any field populated) | Taps back or home button | System detects unsaved form state | Draft save triggered |
| 2 | — | — | Form state serialised to local storage; back navigation completes | Draft stored |
| 3 | User re-opens transaction entry | — | Draft detected; form pre-populated; "Draft restored" banner shown | Draft exists |
| 4 | "Discard" action (banner or menu) | Taps | Draft deleted from storage; form cleared | No draft |
| 5 | Successful submission | — | Draft deleted from storage on successful post | No draft |

#### 1.9.3 Rules

- Draft is per transaction type (income / expense / transfer stored separately).
- Only one draft per type is retained; opening new entry overwrites prior draft of same type.
- Draft includes all field values at time of back-navigation, including partially entered expressions in Amount.
- Draft is not shown for edit flows (edits have existing persisted data).
- No explicit "save draft" button — draft is implicit and automatic.
- Draft TTL: retained until explicitly discarded or submitted. No expiry.

---

## 2. UX Pre-work Resolutions (UX-1 — UX-14)

| ID | Decision | Rationale |
|----|----------|-----------|
| UX-1 | **3-tab bottom navigation bar:** Home · Accounts · Settings. Labels visible at all times. | TC-031 resolved; LE owns. 3 tabs — minimal, clean. |
| UX-2 | **Speed dial FAB** on Home screen only. Expands to 3 labeled mini-FABs: Income / Expense / Transfer. Collapsed by default; tapping FAB opens dial. | PRD §5.8.6 defers to UX; speed dial surfaces all 3 types without extra navigation. |
| UX-3 | Account detail screen shows: (a) account metadata header (name, type, balance, currency), (b) edit / reconcile / delete actions, (c) per-account transaction list (same 3-column layout as home). | Consistent with unified list pattern; per-account filter is a common high-frequency action. |
| UX-4 | Transaction list row: 3-column layout (C1: category icon + name, C2: title + account, C3: amount + currency). Grouped by date descending, day-level headers. Group header shows date label only — no group subtotal in v1. Running balance column hidden in v1. | PRD §5.2.1.1 defines columns. Subtotals and running balance deferred to v2. |
| UX-5 | **Home screen hero:** Net worth figure (sum of included accounts, home currency). Displayed at display-large size, above monthly income/expense/net summary row. | PRD §5.8.2 defines net worth as primary; income/expense are secondary. |
| UX-6 | **Running balance column** hidden in v1. Not shown in transaction list rows or group headers. | Deferred — adds visual weight; v2 candidate. |
| UX-7 | Category picker opens as bottom sheet (§1.1 above) triggered by tapping the Category field in the transaction entry form. Parent and subcategory selected in a single sheet interaction (expand parent → tap child). | High-frequency field; bottom sheet avoids full-screen nav cost. |
| UX-8 | Transfer entry is a **single unified form** (one screen). Source account, destination account, amount, date, title, description, photos — all on one form. Transfer fee section conditionally revealed when "Add fee" is toggled. | PRD §5.1.5b defines fee fields; one form avoids two-screen navigation overhead. |
| UX-9 | **Snackbar undo** for single soft-delete (5 s window, "Undo" action). **Confirmation dialog** for bulk delete ("Delete [N] transactions? This cannot be undone."). | Snackbar for single: low friction. Dialog for bulk: destructive, high impact. |
| UX-10 | **Void** is the result of soft-delete (transaction is voided; reversing entry posted). **Delete** is the user-facing action label. "Delete" is the only label shown in contextual menus (§5.5.1). The word "Void" is never shown to users — it is an internal domain term. | Reduces terminology confusion; "Delete" aligns with user mental model. |
| UX-11 | See §1.1 (Category Picker sub-flow). Bottom sheet with search, recents strip, two-level expandable list, inline create for parent categories. | — |
| UX-12 | See §1.6 (Amount Entry sub-flow). System keyboard; expression evaluation on Done/Next. | — |
| UX-13 | **Empty state pattern:** Outlined icon (Material Symbols, muted tone) centred at 60% height. Two-line copy: heading (bold, `bodyLarge`) + sub-label (`bodyMedium`, muted). Primary CTA: filled button below copy. Per-screen CTA wording below. No illustrations — icon-only for consistency and bundle size. | Illustrations add binary size; icons reuse existing bundled asset set. |
| UX-14 | See §1.7 (Photo Attachment sub-flow). Bottom sheet chooser: Camera / Gallery / Cancel. Preview inline. Max 2 enforced. | — |

### 2.1 Empty State CTA Wording Per Screen

| Screen | Icon | Heading | Sub-label | CTA label |
|--------|------|---------|-----------|-----------|
| Home — no accounts | `account_balance_wallet` | "No accounts yet" | "Add your first account to start tracking" | "Add Account" |
| Home — no transactions (account exists) | `receipt_long` | "No transactions" | "Tap + to record your first transaction" | — (FAB is primary) |
| Account list | `account_balance_wallet` | "No accounts yet" | "Add an account to begin" | "Add Account" |
| Account detail — no transactions | `receipt_long` | "No transactions" | "No transactions recorded for this account" | — |
| Settings > Categories — empty tree | `category` | "No categories" | "Add a category to organise your transactions" | "Add Category" |
| Pending Confirmations — none | `check_circle` | "All caught up" | "No recurring transactions awaiting confirmation" | — |

---

## 3. App Shell & Navigation

### 3.1 Route Map

| Route | Screen | Shell? | Notes |
|-------|--------|--------|-------|
| `/` | `HomeScreen` | Yes — Tab 0 | |
| `/accounts` | `AccountListScreen` | Yes — Tab 1 | |
| `/settings` | `SettingsScreen` | Yes — Tab 2 | |
| `/onboarding` | `OnboardingWizardScreen` | No — full-screen modal | Shown once; GoRouter redirect guard |
| `/settings/security/pin-setup` | `PinSetupScreen` | No — full-screen modal | Entry from onboarding or Security Settings |
| `/settings/security/pin-entry` | `PinEntryScreen` | No — overlay | Shown when biometric fails or unavailable |
| `/transaction/new` | `CreateTransactionScreen` | No — full-screen modal | |
| `/transaction/:id` | `TransactionDetailScreen` | Yes — pushed on Tab 0 stack | |
| `/accounts/:id` | `AccountDetailScreen` | Yes — pushed on Tab 1 stack | |

---

### 3.2 Shell States

**Route:** `/`, `/accounts`, `/settings` via `StatefulShellRoute.indexedStack`

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| **Populated** | Any tab active, onboarding complete | `NavigationBar` + active tab content | Tab-specific |
| **Loading** | App start, restoring state | Splash retained; shell scaffold visible | None |

> No empty or error state at shell level — each tab manages its own empty/error states independently.

### 3.3 Tab Behaviour

| # | Tab label | Root route | Stack preserved? |
|---|-----------|------------|-----------------|
| 0 | Home | `/` | Yes — `IndexedStack` |
| 1 | Accounts | `/accounts` | Yes — `IndexedStack` |
| 2 | Settings | `/settings` | Yes — `IndexedStack` |

- Tapping the **active** tab icon when the stack has >1 screen: pop to tab root.
- Tapping the **active** tab icon when already at tab root: no-op.
- Tapping a **different** tab: switch branch; restore stack exactly as left.
- `NavigationBar` is **always visible** at shell level; hidden only inside full-screen modal routes.

### 3.4 Back-Stack Rules

| Scenario | Behaviour |
|----------|-----------|
| Android back gesture on tab root | Exit app (system back exits from shell root) |
| Android back gesture on deep screen within tab | Pop to previous screen in that tab's stack |
| Full-screen modal (e.g. `CreateTransactionScreen`) | Android back dismisses modal; shell remains |
| GoRouter `context.go(...)` | Replaces root of current tab stack |
| GoRouter `context.push(...)` | Pushes onto current tab stack |

---

## 4. Onboarding & First Launch

**Route:** `/onboarding`
**Guard:** GoRouter redirect — if `onboardingComplete == false` in local storage, all routes redirect here.
**Entry:** First launch only. Never shown again once `onboardingComplete` is written.

### 4.1 Step States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| **Active step** | Normal progression | Step content + progress indicator | "Next" / "Done" |
| **Skip available** | Steps 2–4 | "Skip" text button in top-right | "Skip" → lands on Home |
| **Loading (currency detect)** | Step 2 — locale lookup | Spinner inside currency field | None until resolved |
| **Error (currency detect)** | Locale lookup fails | Fallback to INR; no error shown to user | "Confirm" with INR pre-selected |
| **Validation error (account form)** | Step 3 — submit with invalid data | Inline field errors | "Create" (disabled until valid) |

### 4.2 Per-Step Detail

#### Step 1 — Welcome

| Element | Detail |
|---------|--------|
| Content | App name, tagline, "local-first, private, no sign-up required" |
| Skip button | Hidden |
| CTA | "Get started" → Step 2 |

#### Step 2 — Currency Selection

| Element | Detail |
|---------|--------|
| Content | Detected currency shown: "We think your currency is ₹ INR." |
| Editable | Searchable currency picker (ISO 4217 bundled list) |
| Fallback | INR if locale detection fails |
| Skip button | Visible — sets detected/fallback currency silently |
| CTA | "Confirm" → Step 3 |

#### Step 3 — Create First Account

| Element | Detail |
|---------|--------|
| Content | Simplified form: Account name (required), Account category (required, picker from 8 fixed types), Initial balance (optional, default 0) |
| Skip button | Visible — skips account creation; home shows empty-state CTA |
| CTA | "Create account" → Step 4 |
| On success | Account written to DB; proceed to Step 4 |

#### Step 4 — Quick Highlights

| Element | Detail |
|---------|--------|
| Content | 2–3 swipeable cards: track expenses / recurring transactions / multiple accounts |
| Navigation | Swipe or dot indicators |
| Skip button | Visible |
| CTA | "Done" → Step 5 |

#### Step 5 — Done

| Element | Detail |
|---------|--------|
| Content | Completion graphic; "You're all set!" |
| Action | Auto-transition to `/` (Home) after brief delay OR immediate on CTA |
| CTA | "Start tracking" → `context.go('/')` |
| Side effect | `onboardingComplete = true` written to local storage before transition |

---

## 5. App Lock & Security Flows

### 5.1 App Lock Overlay

**Scope:** Protects **sensitive account detail fields only** (card numbers, bank account numbers). Does NOT gate any other screen or route. GoRouter guards never redirect to lock for core routes.

**Lock overlay surface:** Rendered inside `AccountDetailScreen` only — not as a route, not as a shell-level widget.

#### 5.1.1 Lock States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| **Locked** | App backgrounded and timeout elapsed; first entry to account details without prior auth | Blurred/obscured sensitive fields; lock icon badge | "Unlock" button |
| **Biometric prompt active** | User taps "Unlock"; device biometrics available | System biometric bottom sheet | Biometric sensor |
| **PIN entry** | Biometric unavailable or user taps "Use PIN" | `PinEntryScreen` overlay | PIN keypad |
| **Unlocked** | Successful auth | Sensitive fields revealed | None |
| **Lockout** | 5 consecutive failed PIN attempts | Lockout banner with countdown timer (1 hr); "Unlock" disabled | None until timeout |
| **Wiped** | 15 total consecutive failed attempts | Banner: "Sensitive data has been deleted. Account details unavailable." | "OK" |

#### 5.1.2 Lock Conditions

| Condition | Lock behaviour |
|-----------|---------------|
| App backgrounded | Lock re-engages after configured timeout (default: Immediately) |
| App foregrounded within timeout | Lock does NOT re-engage |
| App foregrounded after timeout | Lock re-engages; user must re-auth to view sensitive fields |
| Timeout options | Immediately / 30 s / 1 min / 5 min |
| Failed attempts counter | Resets to 0 on any successful auth |
| Wipe target | Encrypted rows in `account_details` only; transactions and balances untouched |

---

### 5.2 PIN Setup Screen

**Route:** `/settings/security/pin-setup`
**Entry points:**
- Onboarding: no device lock detected → prompted after Step 5
- Settings > Security > "Set PIN" or "Change PIN"

#### 5.2.1 PIN Setup States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| **Enter new PIN** | Screen open | PIN entry field (6-digit keypad, masked) | None until 6 digits entered |
| **Confirm PIN** | 6 digits entered | "Confirm your PIN" header; re-entry keypad | None until 6 digits entered |
| **Mismatch error** | Confirm entry ≠ first entry | Inline error: "PINs do not match. Try again." | Clears confirm field; re-enter |
| **Success** | Confirm entry matches | Brief success indicator | Auto-dismiss; returns to caller |
| **Cancelled** | Back gesture | Discard; return to caller with no PIN saved | — |

---

### 5.3 PIN Entry Screen

**Route:** `/settings/security/pin-entry` (also rendered as overlay within `AccountDetailScreen`)
**Entry:** Biometric fails or unavailable; user taps "Use PIN" on lock overlay.

#### 5.3.1 PIN Entry States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| **Idle** | Screen/overlay shown | 6-digit keypad, masked entry, attempts remaining indicator (shown after first failure) | "Confirm" (auto-submits on 6th digit) |
| **Wrong PIN** | Entry does not match stored PIN | Shake animation; "Incorrect PIN. X attempts remaining." | Retry |
| **Lockout** | 5 consecutive failures | "Too many attempts. Try again in 1:00:00."; keypad disabled | None |
| **Forgot PIN** | User taps "Forgot PIN" link | → [PIN Reset Flow §5.7] | "Forgot PIN" link |
| **Success** | Correct PIN | Overlay dismisses; sensitive fields revealed | — |

---

### 5.4 Flow — First Launch → Onboarding → Home

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | App start | `onboardingComplete == false` in local storage | GoRouter redirect fires; route `/onboarding` | 2 |
| 2 | Default category seeding | Always on first launch | 30+ default categories written to DB (silent, background) | 3 |
| 3 | Step 1 — Welcome | — | Display welcome screen | 4 |
| 4 | Step 2 — Currency | User taps "Confirm" or "Skip" | Write home currency to settings | 5 |
| 4a | Step 2 — Currency | User taps "Skip" | Write locale-derived or INR fallback | 5 |
| 5 | Step 3 — Account | User fills form and taps "Create account" | Write account row to DB | 6 |
| 5a | Step 3 — Account | User taps "Skip" | No account written | 6 |
| 6 | Step 4 — Highlights | User swipes through or taps "Skip"/"Done" | — | 7 |
| 7 | Step 5 — Done | — | Write `onboardingComplete = true`; check device lock availability | 8 |
| 8 | PIN Setup prompt | Device lock NOT configured AND app is capable of in-app PIN | Navigate to `/settings/security/pin-setup` | 9 |
| 8a | PIN Setup prompt | Device lock IS configured OR user skips PIN setup | Skip PIN setup | 9 |
| 9 | Home (`/`) | — | `context.go('/')` | — |

### 5.5 Flow — App Lock: Background → Foreground Unlock (Biometric Path)

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | App backgrounded | — | Lock timeout starts per configured setting | 2 |
| 2 | App foregrounded | Timeout elapsed AND user is on `AccountDetailScreen` | Lock overlay shown; sensitive fields obscured | 3 |
| 2a | App foregrounded | Timeout NOT elapsed | Overlay not shown; sensitive fields remain visible | End |
| 3 | Lock overlay | Device biometrics available | System biometric prompt shown | 4 |
| 4 | Biometric prompt | Auth succeeds | Overlay dismissed; sensitive fields revealed | End |
| 4a | Biometric prompt | Auth fails (biometric mismatch) | Error shown in system prompt; retry offered (system-managed) | 3 |
| 4b | Biometric prompt | User taps "Use PIN" | Navigate to PIN entry overlay | [§5.6 Step 1] |

### 5.6 Flow — App Lock: Background → Foreground Unlock (PIN Fallback Path)

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | Lock overlay | Biometric unavailable OR user selected PIN path | PIN entry overlay shown | 2 |
| 2 | `PinEntryScreen` overlay | User enters 6-digit PIN | Validate against stored hash | 3 |
| 3 | PIN entry | Correct PIN | Overlay dismissed; sensitive fields revealed; failure counter reset | End |
| 3a | PIN entry | Wrong PIN; attempts < 5 | Shake animation; decrement remaining count; show "X attempts remaining" | 2 |
| 3b | PIN entry | 5th consecutive failure | Lockout state; keypad disabled; 1-hr countdown shown | — |
| 3c | PIN entry | Lockout timer expires | Keypad re-enabled; 5 new attempts | 2 |
| 3d | PIN entry | 15th total consecutive failure | Encrypted `account_details` rows deleted; wipe banner shown | End |

### 5.7 Flow — PIN Setup: First Time

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | `/settings/security/pin-setup` | Opened from onboarding or Settings | Show "Create a PIN" header | 2 |
| 2 | PIN entry (first) | User enters 6 digits | Mask digits; advance to confirm step | 3 |
| 3 | PIN confirm | User enters 6 digits | Compare with first entry | 4 |
| 4 | Confirm | Entries match | Hash and store PIN; write `pinEnabled = true` | 5 |
| 4a | Confirm | Entries mismatch | Inline error; clear confirm field | 3 |
| 5 | Success | — | Brief success indicator; return to caller | End |

### 5.8 Flow — PIN Setup: Change PIN

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | Settings > Security | User taps "Change PIN" | Navigate to `/settings/security/pin-setup` with `mode=change` | 2 |
| 2 | `PinSetupScreen` | `mode=change` | Show "Enter current PIN" step first | 3 |
| 3 | Current PIN verification | User enters current 6-digit PIN | Validate against stored hash | 4 |
| 3a | Current PIN verification | Wrong PIN | Inline error; retry | 3 |
| 4 | New PIN entry | Verification passed | Show "Enter new PIN" | 5 |
| 5 | Confirm new PIN | User enters confirmation | Compare entries | 6 |
| 6 | Confirm | Entries match | Hash and store new PIN | 7 |
| 6a | Confirm | Entries mismatch | Inline error; clear confirm | 5 |
| 7 | Success | — | Brief success; return to Settings > Security | End |

### 5.9 Flow — PIN Reset: Forgot PIN

| Step | Screen/component | Condition | System action | Next step |
|------|-----------------|-----------|---------------|-----------|
| 1 | `PinEntryScreen` | User taps "Forgot PIN" | Show confirmation dialog: "Resetting your PIN requires device authentication" | 2 |
| 2 | Confirmation dialog | User confirms | Invoke Android Keyguard (`local_auth` device credential intent) | 3 |
| 2a | Confirmation dialog | User cancels | Dismiss dialog; return to PIN entry | End |
| 3 | Device credential prompt | Device lock IS configured | System prompt (device PIN/pattern/biometric) | 4 |
| 3a | Device credential prompt | Device lock NOT configured | Show informational dialog: "Set up device security in Android Settings to reset your PIN." | End |
| 4 | Device credential | Auth succeeds | Clear stored PIN hash; write `pinEnabled = false` | 5 |
| 4a | Device credential | Auth fails | Return to `PinEntryScreen`; no change | End |
| 5 | `/settings/security/pin-setup` | Redirected after credential success | Fresh PIN setup flow | [§5.7 Step 1] |

---

## 6. Home Tab

### 6.1 Home Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Cold start; data not yet read from local DB | Skeleton placeholders for greeting, summary cards, list rows | None |
| Empty (no transactions) | No transactions exist for selected month | Greeting + summary (all zeros) + empty-state illustration + prompt text "No transactions this month" | FAB → Create transaction |
| Populated | Transactions exist for selected month | Greeting, financial summary, month selector, alerts strip, transaction list, FAB | FAB → Create transaction |
| Error | DB read failure | Error card with retry button; stale data retained if available | Retry |
| Stale FX rate | Cached exchange rate > 14 days old; net worth includes foreign-currency accounts | Staleness banner above net worth: "This value may be inaccurate as the exchange rate has not been updated recently." | Dismiss (one-time per session) |
| No FX rate | Never fetched; foreign-currency accounts exist | Disclaimer instead of converted net worth figure | — |
| Future month | User navigates month selector past current month | Shows pending transactions with "Pending" badge; summary shows projected figures | FAB → Create transaction |

### 6.2 Greeting

| Condition | Displayed text |
|-----------|---------------|
| Display name set in Settings > Profile | "Hi, [display name]!" |
| No display name | "Hi!" |

### 6.3 Financial Summary

| Element | Value shown | Currency |
|---------|-------------|---------|
| Net worth | Sum of all `include_in_net_worth = true`, non-deleted account balances (current/latest) | Home currency; converted at cached rate |
| Month income | Sum of income transactions in selected month | Home currency |
| Month expenses | Sum of expense transactions in selected month | Home currency |
| Month net | Income − Expenses for selected month | Home currency |

- Net worth is **unaffected** by month selector.
- Excluded accounts shown greyed-out below contributing accounts with "excluded" indicator.

### 6.4 Month Selector

| Interaction | Result |
|-------------|--------|
| Tap left arrow | Previous month; transaction list + income/expense/net figures update |
| Tap right arrow | Next month; future transactions shown as pending |
| Default | Current calendar month |

### 6.5 Alerts Strip

| Alert type | Trigger | Content | Actions |
|------------|---------|---------|---------|
| Pending recurring confirmation | "Remind and confirm" template has an unconfirmed occurrence | Template name, date, amount, account, category | Confirm / Edit before confirming / Dismiss |
| Credit card payment due | Payment reminder fires per §5.1.7 schedule | Card name, amount due, due date | Open CC payment entry form |
| Backup reminder | First month of use OR first 50 transactions, no backup taken | Prompt text | Navigate to Settings > Data > Backup |

- Alerts persist until acted upon; backup reminder clears once dismissed or backup taken.
- Dismiss on recurring confirmation → confirmation dialog: "Skip this occurrence? It will not be posted." → Confirm / Cancel.

### 6.6 Recurring Catch-Up Banner

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Shown | App launch; catch-up sweep posted ≥ 1 auto-approved missed recurring transactions | Top-of-list banner: "[N] recurring transactions were auto-posted while you were away." | "View details" → filters list to those transactions |
| Not shown | No missed occurrences processed at launch | Banner absent | — |

### 6.7 FAB Behaviour

| Mode | UI |
|------|----|
| Single FAB tap | Opens Create Transaction screen; default type = Expense |
| Speed-dial (if implemented) | Expands to: Expense / Income / Transfer / Drafts |
| Drafts entry point | Opens Drafts list (if "Auto-save as draft" enabled in Settings) |

---

### 6.8 Transaction List (Home Screen — Monthly View)

#### 6.8.1 List States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Initial load | Skeleton rows | — |
| Empty (month) | No transactions in selected month | Empty-state illustration + "No transactions this month" | FAB |
| Populated | Transactions exist | Date-grouped rows, date descending; running balance per account NOT shown in home list | Tap row → detail |
| Filtered | Active filter applied | Filter chip strip above list; "X results" count | Clear filters |
| Search active | Search bar focused | Month scope suspended; global results across all dates | Clear search |
| Error | DB error on list render | Inline error card | Retry |
| Pending month | Future month selected | Pending transactions with "Pending" badge; muted styling | — |

#### 6.8.2 Row Layout (3-Column)

| Column | Content |
|--------|---------|
| C1 — Category | Parent category icon + name; if subcategory: parent name row 1, subcategory name row 2. Transfer: "Transfer" label (no icon). |
| C2 — Title & Account | Row 1: Title (blank if not provided). Row 2: Expense → source account name; Income → destination account name; Transfer → "Source → Destination". |
| C3 — Amount & Currency | Amount with currency symbol. Foreign currency account: original amount + home currency equivalent on row 2. Income: green. Expense: red. Transfer: neutral. |

- Currency symbol disambiguation: ISO 4217 code shown when ≥ 2 currencies share a symbol.
- Timestamp hidden; revealed in detail view.
- Pending transactions: "Pending" badge on row; muted styling.

#### 6.8.3 Grouping & Ordering

| Rule | Value |
|------|-------|
| Grouping | Date header per calendar day |
| Within-group order | Most-recent time first |
| Default sort | Date descending (most recent at top) |
| Sort overrides | Via filter sheet (date asc, amount asc/desc) |

#### 6.8.4 Excluded from Default List

- Soft-deleted (voided) transactions
- Pending (future-dated) transactions — unless current month = future month
- Superseded versions of corrected transactions (only final corrected version shown)
- Invisible journal adjustments (user chose "No" on balance-edit prompt)

#### 6.8.5 Swipe Actions

| Direction | Action | Confirmation required | Undo available |
|-----------|--------|-----------------------|---------------|
| Swipe left | Delete (soft) | Dialog: "Delete this transaction?" Confirm / Cancel | Yes — snackbar with "Undo" (single delete only) |
| Swipe right | Edit | No | N/A — navigates to edit screen |

#### 6.8.6 Long-Press Contextual Menu

| Action | Notes |
|--------|-------|
| Edit | Navigates to `/transaction/:id/edit` |
| Delete | Same as swipe-left; shows confirmation dialog |

---

## 7. Transaction Screens & Flows

### 7.1 Transaction Detail Screen

**Route:** `/transaction/:id`

#### 7.1.1 Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push; reading record from DB | Skeleton | — |
| Populated (normal) | Transaction found | Full detail (see §7.1.2) | 3-dot menu → Edit / Delete |
| Populated (pending) | Transaction is future-dated | Full detail + "Pending" badge; Edit and Delete available; no correction model | Edit / Delete |
| Populated (voided) | Transaction is soft-deleted (reached via filter "Is voided = true") | Full detail + "Voided" badge; no edit/delete actions | — |
| Populated (correction — final) | Transaction is the final corrected version of an edited transaction | Full detail; no v1 correction history link (v2) | Edit / Delete |
| Error | Record not found or DB error | Error screen with back button | Back |

#### 7.1.2 Detail Content

| Section | Content | Condition |
|---------|---------|-----------|
| Header badge | "Income" / "Expense" / "Transfer" (colour-coded) | Always |
| Amount | Full amount + currency symbol; home currency equivalent if foreign-currency account | Always; equivalent shown only if account currency ≠ home currency |
| Exchange rate | Stored `exchange_rate_to_home` at time of transaction | Only if account currency ≠ home currency; tap → Exchange Rate Detail screen |
| Date & time | Full date and local timestamp | Always |
| Title | Title text | If provided |
| Description | Full description text | If provided |
| Account info | Expense: source account. Income: destination account. Transfer: source → destination. | Always; account names preserved even if account soft-deleted |
| Category | Parent category icon + name; subcategory name if any | Income and Expense only |
| Fee breakdown | Transfer amount and fee amount separately; fee category | Transfer-with-fee only |
| Photo carousel | Horizontally scrollable; tap → full-screen | If ≥ 1 photo attached; max 2 |
| Pending badge | "Pending" label/badge | Future-dated transactions |
| Voided badge | "Voided" label/badge | Soft-deleted transactions |

#### 7.1.3 Actions (3-dot menu / contextual menu)

| Action | Available when | Notes |
|--------|---------------|-------|
| Edit | Transaction is posted (non-voided) or pending | Posted → correction model. Pending → in-place edit. |
| Delete | Any non-voided transaction | Posted → soft-delete with reversing entry. Pending → void without reversing entry. |
| Delete photo | Photo visible in carousel | Deletes individual photo in-place |

---

### 7.2 Create Transaction Screen

**Route:** `/transaction/new`

#### 7.2.1 Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Empty (initial) | Screen opens | Type selector (Expense pre-selected), all fields blank/default | Save |
| Partially filled | User has entered some fields | Entered fields populated; validation errors shown inline on blur | Save |
| Warning active | Duplicate / overdraft / large-txn / credit-limit warning triggered | Non-blocking warning card/dialog inline | Confirm and save / Cancel |
| Saving | User taps Save; async write in progress | Save button → loading indicator | — |
| Saved | Write succeeds | Screen dismissed; transaction appears in list | — |
| Save error | DB write failure | Error snackbar; form stays open with data intact | Retry |
| Draft restored | User resumed a draft | Form pre-populated with saved draft state | Save |
| Future date info | User selects a future date | Info popup: "This transaction is dated in the future. It will be held as pending and posted on [date]." | OK |

#### 7.2.2 Type Selector

| Type | Availability |
|------|-------------|
| Expense | Always |
| Income | Always |
| Transfer | Always (validation at destination picker level; blocked if no same-currency destination account exists) |

#### 7.2.3 Field Sequence — Expense

| Order | Field | Required | Notes |
|-------|-------|----------|-------|
| 1 | Amount | Yes | Numeric > 0; FX estimate shown below if account currency ≠ home currency |
| 2 | Source account | Yes | Account picker; grouped by category; currency symbol if multi-currency |
| 3 | Category | Yes | Expense category tree picker |
| 4 | Subcategory | No | Filtered by selected parent category; optional |
| 5 | Date and time | Yes | Default: now |
| 6 | Title | No | Short text |
| 7 | Description | No | Long text; max chars per Settings |
| 8 | Photos | No | Max 2; camera or gallery |

#### 7.2.4 Field Sequence — Income

| Order | Field | Required | Notes |
|-------|-------|----------|-------|
| 1 | Amount | Yes | |
| 2 | Destination account | Yes | Where funds arrive |
| 3 | Category | Yes | Income category tree picker |
| 4 | Subcategory | No | |
| 5 | Date and time | Yes | Default: now |
| 6 | Title | No | |
| 7 | Description | No | |
| 8 | Photos | No | |

#### 7.2.5 Field Sequence — Transfer

| Order | Field | Required | Notes |
|-------|-------|----------|-------|
| 1 | Amount | Yes | |
| 2 | Source account | Yes | Must be selected before destination becomes available |
| 3 | Destination account | Yes | Picker shows only accounts with same currency as source; if none → disabled with empty-state message |
| 4 | Transfer fee panel | No | Collapsed by default; expands to: Fee mode (Flat/%) + Fee amount + Fee category |
| 5 | Date and time | Yes | Default: now |
| 6 | Title | No | |
| 7 | Description | No | |
| 8 | Photos | No | |

- Cross-currency transfers blocked in v1 at destination picker level.

#### 7.2.6 Inline Warnings at Entry Time

| Warning | Trigger | UI | User action |
|---------|---------|-----|-------------|
| Exchange rate estimate | Account currency ≠ home currency | "≈ [home amount]" below amount field | Informational; no action |
| Stale FX rate | Cached rate > 14 days | "⚠ Rate may be outdated" alongside estimate | Informational |
| No FX rate | No cached rate | "Exchange rate unavailable." (estimate omitted) | Informational |
| Overdraft | Transaction would push balance below zero or deepen negative balance | Inline warning card: "This transaction will result in a negative balance of [amount] for [Account]." | Proceed / Edit amount |
| Credit card limit | Expense/transfer on CC would exceed configured credit limit | Inline warning: "This transaction will exceed the credit limit of [limit] for [Card]. Outstanding will be [amount]." | Proceed / Edit amount |
| Large transaction | Amount exceeds per-account or per-category threshold | Dialog: "This is a large transaction — [amount]. Confirm?" | Confirm / Cancel |
| Future date | User selects a future date | Info popup (see §7.2.1) | OK |

#### 7.2.7 Back Button Behaviour (Android)

| Setting | Behaviour |
|---------|-----------|
| Ask before discarding (default) | Dialog: "Discard changes?" Discard / Keep editing |
| Auto-save as draft | Form state saved to `drafts` table (max 5; FIFO eviction); screen dismissed |
| Discard immediately | Form discarded without confirmation |

---

### 7.3 Create Recurring Transaction Screen

**Route:** `/transaction/new` (type = recurring template; accessed via dedicated recurring template creation entry point)

#### 7.3.1 Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Empty | Screen opens | Transaction type selector + all template fields blank | Save template |
| Filled | Fields populated | Live preview of first scheduled date; computed end date (installments: read-only) | Save template |
| Saving | Save tapped | Loading state | — |
| Saved | Write succeeds | Screen dismissed; template appears in Settings > Recurring & Installments | — |

#### 7.3.2 Template Fields

| Field | Mutable after save | Notes |
|-------|-------------------|-------|
| Transaction type | No (IM) | Expense / Income / Transfer |
| Amount | Yes (IP) | Future occurrences only |
| Account(s) | Yes (IP) | Future occurrences only |
| Category / Subcategory | Yes (IP) | Future occurrences only; Transfer has no category |
| Title / Description | Yes (IP) | |
| Recurrence — N | No (IM) | |
| Recurrence — unit | No (IM) | day / week / month / year |
| Recurrence — constraints | No (IM) | Weekdays only / Weekends only / Start of month / End of month / etc. |
| Start date | No (IM) | Default: today |
| End date | No (IM) | Optional; no end = indefinite; installments: computed read-only |
| Posting behaviour | Yes (IP) | Auto-post (default) / Remind and confirm |
| Transfer fee panel | Yes (IP) | Transfer type only; collapsed by default |

---

### 7.4 Create Installment Transaction Screen

**Route:** `/transaction/new` (type = installment template)

#### 7.4.1 Additional Installment Fields

| Field | Required | Mutable | Notes |
|-------|----------|---------|-------|
| Total amount | Yes | No (IM) | Immutable except during early close |
| Number of installments | Yes | Yes (IP — future only) | User can add/remove future unposted installments |
| Per-installment amounts | Auto-calculated | Yes (IP — future unposted) | Auto = total ÷ count; manual override allowed |
| End date | — | Read-only | Computed: start_date + (N installments × recurrence period) |

- If Projected final total ≠ Total configured after manual adjustment: non-blocking warning at save time.
- Transfer-type installments: source/destination + fee panel same as §7.2.5.

---

### 7.5 Edit Transaction Screen

**Route:** `/transaction/:id/edit`

#### 7.5.1 Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Skeleton | — |
| Loaded — posted | Normal posted transaction | Form pre-filled; financial fields (amount, account, category) marked with correction indicator | Save correction |
| Loaded — pending | Future-dated, unposted transaction | Form pre-filled; all fields freely editable; no correction model | Save |
| Saving — in-place | IP fields only changed (title, description, photos, date/time) | Loading | — |
| Saving — correction | Financial field (amount / account / category) changed | Loading; system will post reversing + corrected entries | — |
| Saved | Write succeeds | Screen dismissed; list reflects: final corrected version only (original + reversal hidden) | — |
| Save error | DB write failure | Error snackbar; form stays open | Retry |

#### 7.5.2 Edit Rules per Field

| Field | Edit type | Ledger effect |
|-------|-----------|--------------|
| Amount | LE | Reversing + corrected pair (Cases 1.4–1.6a) |
| Account | LE | Reversing + corrected pair |
| Category / Subcategory | LE | Reversing + corrected pair (EC' / IC' in Cases 1.4–1.5) |
| Date / Time | IP | No ledger entries; may shift reporting period |
| Title | IP | No ledger entries |
| Description | IP | No ledger entries |
| Photos | IP | No ledger entries |

- Soft-deleted category in edit form: shown as "current" entry at top of category picker; user may re-select it (no change) or pick an active category (triggers LE correction).
- Compound transfer-with-fee: both transfer + fee components corrected atomically (Case 1.6a).
- Pending transaction: all fields freely editable (no correction model).

#### 7.5.3 Correction Visibility

- Only the final corrected transaction is shown in the list.
- Original + reversing entry hidden from all user-facing views (v2 audit view will surface them).

---

### 7.6 Void / Soft-Delete Flow

#### 7.6.1 Void (soft-delete) — Single Transaction

| Step | Screen / Component | User action | System response | Next step |
|------|--------------------|-------------|-----------------|-----------|
| 1 | Transaction list or detail | Tap Delete (swipe-left or 3-dot menu) | Show confirmation dialog | 2 |
| 2 | Confirmation dialog | "Delete this transaction?" — Confirm | Post reversing entry (Cases 1.7–1.9a); transaction status → voided; hidden from list | 3 |
| 2b | Confirmation dialog | Cancel | Dialog dismissed; no change | — |
| 3 | Transaction list | — | Snackbar: "Transaction deleted. Undo." (5 s) | 4 if undo tapped |
| 4 | Snackbar | Tap Undo | Reversing entry removed; transaction status → posted; reappears in list | — |

- Pending transactions (unposted): deletion sets status to `voided`; no reversing entry (never posted).
- Pending deletion confirmation text: "This transaction has not been posted yet. Delete it?"

#### 7.6.2 Void vs. Delete Distinction (user-visible)

| Concept | User label | Ledger action | Undo available |
|---------|-----------|---------------|---------------|
| Soft delete (posted) | "Delete" | Reversing entry posted; original record retained | Yes — snackbar (5 s) |
| Soft delete (pending) | "Delete" | Status → voided; no reversing entry | Yes — snackbar (5 s) |
| Void (v2, explicit void action) | "Void" | Same as soft delete but surfaced in audit view | Not applicable (v2) |

#### 7.6.3 Bulk Delete

| Step | Screen / Component | User action | System response | Next step |
|------|--------------------|-------------|-----------------|-----------|
| 1 | Transaction list | Long-press → enter selection mode | Checkboxes appear on rows | 2 |
| 2 | Selection mode | Select ≥ 2 transactions | "Delete [N] transactions?" confirm dialog | 3 |
| 3 | Confirm dialog | Confirm | Reversing entries posted for each; transactions hidden | 4 |
| 4 | Transaction list | — | No undo for bulk delete | — |

---

### 7.7 Filter Sheet

**Route:** `/filter` (bottom sheet modal)

#### 7.7.1 Sheet States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Empty (no filters) | Sheet opens; no prior filters | All criteria in default/unset state | Apply |
| Filters active | User has set ≥ 1 criterion | Active criteria highlighted; preview count: "X matching transactions" | Apply |
| Applied | User taps Apply | Sheet dismisses; list shows filtered results; filter chip strip appears above list | — |
| Reset | User taps Reset | All criteria cleared; sheet stays open | Apply |

#### 7.7.2 Filter Criteria

| Criterion | Input type | Notes |
|-----------|-----------|-------|
| Transaction type | Multi-select toggle: Income / Expense / Transfer | |
| Category | Multi-select picker | Dynamically filtered by selected types; soft-deleted categories included |
| Subcategory | Multi-select picker | Filtered by selected categories |
| Account | Multi-select picker | Includes soft-deleted accounts for historical filtering |
| Date range | Date range picker or preset chips (This month / Last 7 days / Last 30 days / Custom) | |
| Amount range | Two numeric fields: Min / Max (both optional) | Inclusive bounds |
| Has photo | Boolean toggle | |
| Has title | Boolean toggle | |
| Has description | Boolean toggle | |
| Is recurring | Boolean toggle | Matches `parent_template_id IS NOT NULL` |
| Is voided | Boolean toggle | Shows soft-deleted transactions |

#### 7.7.3 Category Filter Interaction with Type Filter

| Type selection state | Category picker behaviour |
|---------------------|--------------------------|
| Income only | Income categories only |
| Expense only | Expense categories only |
| Both Income + Expense | Both trees with visual separator |
| Transfer (alone or mixed) | Category criterion disabled for transfer results; still applies to income/expense results |
| None selected | All categories from both trees |
| Type removed | Its categories auto-deselected from category selection |

#### 7.7.4 Sort Controls (within filter sheet)

| Sort field | Options |
|-----------|---------|
| Date | Descending (recent first — default) / Ascending |
| Amount | Descending (largest first) / Ascending |

- Filters do NOT persist across navigation; list resets to unfiltered default-sorted view on nav away.

#### 7.7.5 Filter → List Effect

| Outcome | UI |
|---------|-----|
| Filters applied | Filter chip strip above list; each active criterion shown as a dismissible chip |
| Dismiss chip | Removes that criterion; list updates |
| "Clear all" chip | All criteria removed; chip strip hidden |
| 0 results | Empty-state: "No transactions match your filters." + "Clear filters" CTA |

---

### 7.8 Search Flow

#### 7.8.1 Search Entry States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Idle | Default home screen | Search icon in app bar | Tap → activate search |
| Active — empty query | Search bar focused; no input | Search bar focused; recent searches (v2); instruction text "Search transactions" | — |
| Active — typing | User typing query | Ranked results update in real time (debounced) | Tap result → detail |
| Active — results | Query entered | Results list (date-grouped); matched text highlighted | Tap result → detail |
| Active — no results | Query entered; no matches | "No transactions found for '[query]'" | Clear query |
| Active — with filter | Filter applied while search active | Both search and filter active; filter chips shown; results = search ∩ filter | — |
| Dismissed | User clears search bar or taps back | Search dismissed; month filter re-engages; list returns to selected month | — |

#### 7.8.2 Search Flow — Step by Step

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Home screen | Tap search icon | — | Search bar appears focused; month scope suspended | 2 |
| 2 | Search bar | Type query | Min 1 character | Results ranked; debounce ~300 ms; global scope (all dates) | 3 |
| 3 | Search results list | — | — | Results grouped by date; matched text highlighted; amount exact-match only | 4 |
| 4 | Search results list | Tap a result | — | Navigate to `/transaction/:id` (detail screen) | — |
| 5 | Search results list | Tap filter icon | — | Filter sheet opens; filter applies on top of search results | — |
| 6 | Search bar | Tap × (clear) | — | Query cleared; results cleared; month filter re-engages | 1 |
| 7 | Search bar | Tap back or dismiss | — | Search dismissed; home list returns to selected month view | — |

#### 7.8.3 Search Ranking Rules

| Rank | Match type |
|------|-----------|
| 1 | Exact match on title or account name |
| 2 | Prefix match on title or account name |
| 3 | Substring match on title or account name |
| 4 | Exact match on amount (exact value only) |
| 5 | Matches on category / subcategory name |
| 6 | Matches on description or date |

- Typo-tolerant: 1–2 character transpositions/substitutions matched.
- Soft-deleted account and category names remain searchable.

---

### 7.9 Exchange Rate Detail Screen

**Route:** `/exchange-rate-detail` (modal)

#### 7.9.1 Screen States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Fresh rate | Cached rate ≤ 14 days old | Rate value, source label, last-updated timestamp | Close |
| Stale rate | Cached rate > 14 days old | Rate value + staleness warning: "This value may be inaccurate as the exchange rate has not been updated recently." + last-updated timestamp | Close |
| No rate | Never fetched | "Exchange rate unavailable." disclaimer | Close |
| Transaction-level rate | Opened from transaction detail | Historical rate stored at time of transaction; "Rate at time of transaction" label; staleness indicator not shown (historical rate is always definitive) | Close |

#### 7.9.2 Content

| Element | Content |
|---------|---------|
| Currency pair | e.g., "USD → INR" |
| Rate value | Numeric rate with appropriate precision |
| Rate type | "Cached (live estimate)" or "Stored at time of transaction" |
| Last updated | Date/time of last successful fetch; "Never" if unavailable |
| Staleness warning | Shown when cached rate > 14 days |
| Manual override (v2) | Deferred |

---

### 7.10 Duplicate Transaction Warning Dialog

#### 7.10.1 States

| State | Trigger | UI shown | Actions |
|-------|---------|----------|---------|
| Shown | Same type + amount + account + category on same calendar day found | Dialog: "A similar transaction already exists today ([amount], [category], [account]). Add anyway?" | Add anyway (save) / Cancel (return to form) |
| Not shown | No duplicate detected | — | — |
| Not shown | Transfer type (checked by type + amount + source + destination) | Identical dialog if match found | Add anyway / Cancel |

- Check is always active; no user toggle.
- If user confirms: transaction saved; no further duplicate warning for that pair.

---

### 7.11 Large Transaction Warning Dialog

#### 7.11.1 States

| State | Trigger | UI shown | Actions |
|-------|---------|----------|---------|
| Shown — account threshold | Amount exceeds per-account threshold (compared in account's native currency) | Dialog: "This is a large transaction — [amount]. Confirm?" | Confirm / Cancel |
| Shown — category threshold | Amount exceeds per-category threshold (compared in home currency); account threshold NOT exceeded | Same dialog | Confirm / Cancel |
| Shown — both thresholds | Both exceeded | One dialog only (account threshold takes precedence) | Confirm / Cancel |
| Not shown | No threshold configured or amount below all thresholds | — | — |
| No FX rate (category threshold) | Foreign currency, no cached rate | Category threshold check skipped; account threshold check still applies | — |

---

### 7.12 Overdraft Warning Dialog

#### 7.12.1 States

| State | Trigger | UI shown | Actions |
|-------|---------|----------|---------|
| Shown — would go negative | Transaction would push account balance below zero | Inline warning card on entry form: "This transaction will result in a negative balance of [amount] for [Account Name]." | Proceed / Edit amount |
| Shown — deepens negative | Account already negative; transaction deepens it | Same warning | Proceed / Edit amount |
| Shown — credit card limit | Expense/transfer on CC would exceed configured credit limit | Inline warning: "This transaction will exceed the credit limit of [limit] for [Card Name]. Outstanding will be [projected amount]." | Proceed / Edit amount |
| Not shown | Balance stays ≥ 0; or credit limit not configured | — | — |
| Not shown (auto-approved missed recurring) | Catch-up sweep on launch | Overdraft warnings suppressed for auto-approved occurrences | — |

---

### 7.13 Flow — Create Expense

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Home FAB | Tap FAB | — | Open `/transaction/new`; type = Expense pre-selected | 2 |
| 2 | Type selector | Confirm Expense (or change type) | — | Field set updates for Expense | 3 |
| 3 | Amount field | Enter amount | Must be > 0; numeric | FX estimate shown if account currency ≠ home currency | 4 |
| 4 | Source account picker | Select account | Account must exist and be active | Account selected; overdraft/CC limit check queued | 5 |
| 5 | Category picker | Select parent category | Must be expense category | Category selected | 6 |
| 6 | Subcategory picker | Select subcategory (optional) | Must be child of selected parent | Subcategory selected | 7 |
| 7 | Date/time picker | Set date/time (default: now) | Any date allowed | If future date: info popup shown | 8 |
| 8 | Title field | Enter title (optional) | Max text length | — | 9 |
| 9 | Description field | Enter description (optional) | Max chars per Settings | — | 10 |
| 10 | Photo attach | Attach photo(s) (optional) | Max 2 | — | 11 |
| 11 | Save tapped | Tap Save | All required fields valid | Run entry-time checks (duplicate, overdraft, CC limit, large-txn) | 12 |
| 12 | Warning dialogs | Confirm or cancel each warning | — | If confirmed: proceed to write. If cancelled: return to form | 13 |
| 13 | DB write | — | — | Ledger entries posted (Case 1.1); transaction record saved | 14 |
| 14 | Home screen | — | — | Screen dismissed; transaction appears in list | — |

### 7.14 Flow — Create Income: Differences from Expense

| Field | Income behaviour |
|-------|-----------------|
| Account field label | "Destination account" (where funds arrive) |
| Category picker | Income category tree |
| Ledger entries | Case 1.2 (Dr destination account, Cr income category) |

### 7.15 Flow — Create Transfer

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Home FAB | Tap FAB; select Transfer | — | Transfer form opens | 2 |
| 2 | Amount field | Enter amount | > 0 | — | 3 |
| 3 | Source account picker | Select source account | Must exist and be active | Destination picker unlocked; filtered to same currency | 4 |
| 4 | Destination account picker | Select destination | Must be same currency as source; cannot be same as source | If no valid destination: empty state message; Save disabled | 5 |
| 5 | Fee panel | Expand and fill fee fields (optional) | Fee mode required if panel open; fee amount > 0 | Fee category defaults to "Financial > Fees & Charges" | 6 |
| 6 | Date/time | Set date/time | — | Future date: info popup | 7 |
| 7 | Title / Description / Photos | Fill optional fields | — | — | 8 |
| 8 | Save tapped | Tap Save | Required fields valid; destination account exists | Run entry-time checks | 9 |
| 9 | DB write | — | — | Case 1.3 (or 1.3a with fee); 2 linked transactions grouped | 10 |
| 10 | Home screen | — | — | Screen dismissed; transfer row appears | — |

### 7.16 Flow — Create Recurring Template

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Template creation screen | Select transaction type | — | Fields for selected type shown | 2 |
| 2 | Amount + Accounts + Category | Fill as per type | Required fields; amount > 0 | — | 3 |
| 3 | Recurrence fields | Set N + unit + constraints | N > 0; unit required | First scheduled date previewed | 4 |
| 4 | Start date / End date | Set start date; optionally end date | Start date required; end ≥ start if set | — | 5 |
| 5 | Posting behaviour | Select Auto-post or Remind and confirm | Required | — | 6 |
| 6 | Fee panel (transfer type) | Optional fee fields | Fee mode required if panel open | — | 7 |
| 7 | Title / Description | Optional | — | — | 8 |
| 8 | Save | Tap Save | All required fields valid | Template saved; first occurrence scheduled | 9 |
| 9 | Dismiss | — | — | Screen dismissed; template in Settings > Recurring | — |

### 7.17 Flow — Create Installment (additional steps after §7.16 steps 1–2)

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 3 | Total amount field | Enter total amount | > 0 | — | 4 |
| 4 | Recurrence fields | Set N + unit (same as recurring) | N > 0 | — | 5 |
| 5 | Number of installments | Enter count or accept derived | Integer > 0 | Per-installment amount auto-calculated; end date computed (read-only) | 6 |
| 6 | Per-installment amounts | Adjust individual amounts (optional) | Each > 0 | If Projected final total ≠ Total configured: non-blocking mismatch warning at save | 7 |
| 7 | Start date | Set start date | Required | End date auto-updates | 8 |
| 8 | Save | Tap Save | — | Template saved; all installment occurrence records materialised | 9 |

### 7.18 Flow — Edit Transaction (Posted)

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Transaction detail | Tap 3-dot menu → Edit | — | Navigate to `/transaction/:id/edit`; form pre-filled | 2 |
| 2 | Edit form | Modify IP fields only (title, description, photos, date/time) | — | No correction indicator; direct save | 7 |
| 3 | Edit form | Modify any LE field (amount, account, category) | Required fields valid | Correction indicator shown; "A correcting entry will be created" notice | 4 |
| 4 | Entry-time checks | — | — | Overdraft / CC limit / large-txn / duplicate warnings fire if triggered | 5 |
| 5 | Warning dialogs | Confirm or cancel | — | Confirmed → proceed to write | 6 |
| 6 | DB write | — | — | Reversing entry posted + corrected transaction posted; original hidden | 7 |
| 7 | Transaction detail | — | — | Screen returns to detail of final corrected transaction | — |

### 7.19 Flow — Void (Soft-Delete)

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Transaction list or detail | Swipe left or 3-dot menu → Delete | — | Confirmation dialog | 2 |
| 2 | Dialog | Confirm delete | — | Reversing entry posted (Cases 1.7–1.9a); transaction status → voided; hidden from list | 3 |
| 3 | Transaction list | — | — | Snackbar: "Transaction deleted. Undo." (5 s) | 4 if undo |
| 4 | Snackbar | Tap Undo | Within 5 s | Reversing entry removed; transaction restored to `posted`; reappears in list | — |

### 7.20 Flow — Filter Sheet Apply

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Transaction list | Tap filter icon | — | Filter sheet opens as bottom sheet modal | 2 |
| 2 | Filter sheet | Set criteria (type, category, account, date range, amount range, booleans) | — | "X matching transactions" preview count updates live | 3 |
| 3 | Filter sheet | Tap Apply | — | Sheet dismisses; list filtered; chip strip shown | 4 |
| 4 | Transaction list | Tap chip × or "Clear all" | — | Criterion removed; list updates | — |
| 5 | Filter sheet | Tap Reset | — | All criteria cleared; count resets to total | 2 |

### 7.21 Flow — Search

| Step | Screen / Component | User action | Validation | System response | Next step |
|------|--------------------|-------------|------------|-----------------|-----------|
| 1 | Home screen | Tap search icon | — | Search bar appears; month scope suspended | 2 |
| 2 | Search bar | Type query | ≥ 1 char | Results ranked globally (all dates); debounced ~300 ms | 3 |
| 3 | Results list | — | — | Date-grouped results; matched text highlighted | 4 |
| 4 | Results list | Tap a result row | — | Navigate to `/transaction/:id` | — |
| 5 | Results list | Tap filter icon | — | Filter sheet; applies on top of search | — |
| 6 | Search bar | Tap × (clear) | — | Query cleared; month filter re-engages; home list returns | 1 |

---

## 8. Accounts Tab

### 8.1 Screen: Account List

**Route:** `/accounts`

#### 8.1.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Tab first-mounted; accounts stream not yet emitted | Shimmer skeleton rows (3–5 rows) + shimmer net worth card | — |
| Empty | No accounts exist | Illustration + "No accounts yet" label + subtext "Add your first account to start tracking" | FAB: "Add Account" |
| Populated | Accounts stream emits ≥ 1 active account | Net worth summary card (top) + account list rows; each row: name, category badge, balance, currency | FAB: "Add Account" |
| Error | DB read failure | Inline error banner "Could not load accounts. Tap to retry." | Retry tap target |

#### 8.1.2 Net Worth Card

| Element | Rule |
|---------|------|
| Net worth total | Sum of balances for accounts where `include_in_net_worth = true` and `is_deleted = false` |
| Currency display | Home currency; if multi-currency, shows home-currency equivalent with staleness indicator if rate > 14 days old |
| Excluded accounts | Shown below net-worth-contributing accounts, grayed-out, with "Excluded" label; balances not summed |
| Staleness indicator | "Exchange rate may be outdated" label when cached rate older than 14 days |

#### 8.1.3 Account Row

| Element | Rule |
|---------|------|
| Balance colour | Default `ColorScheme.onSurface`; negative balance → `VarianceColors.warningAmount` |
| Negative balance | Colour only — no minus sign in primary balance display; accessibility label must include "negative" |
| Currency code | ISO 4217 code shown beside symbol when ≥ 2 accounts share same symbol |
| Long-tap | Opens contextual menu: Edit, Delete, Reconcile |

---

### 8.2 Screen: Account Detail

**Route:** `/accounts/:id`

#### 8.2.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push before account + transactions loaded | Shimmer header + shimmer list | — |
| Loaded – no transactions | Account exists; `transaction_count = 0` | Header (name, badge, currency) + balance section + metadata section + empty state illustration "No transactions yet" | App-bar actions: Edit, Delete, Reconcile |
| Loaded – populated | Account exists; transactions > 0 | Header + balance section + metadata section + transaction list (all months, unfiltered) + search bar + filter button | App-bar actions: Edit, Delete, Reconcile |
| Credit card loaded | Account category = Credit Card | Same as Loaded + statement balance row + outstanding balance row + Pay FAB | Pay FAB (bottom-right) |
| Error – not found | `:id` does not match any account | "Account not found" full-screen error + Back button | Back |

#### 8.2.2 Sections

| Section | Content |
|---------|---------|
| Header | Name (headline), category badge chip, currency code |
| Balance | Current computed balance (large numeric, `VarianceTypography.displayLargeAmount`); negative → `VarianceColors.warningAmount` |
| Credit card extra | Statement balance (labelled) + outstanding balance (labelled) |
| Metadata | Category-specific fields (§5.1.2) read-only; sensitive fields masked — reveals on biometric/PIN auth |
| Net worth indicator | "Included in net worth" or "Excluded from net worth" chip |
| Transaction list | Same 3-column layout as home; search + filter scoped to this account; all months (not month-filtered) |

---

### 8.3 Screen: Create Account

**Route:** `/accounts/new`

#### 8.3.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Idle | Screen opened | Form with common fields; category-specific section hidden until category selected | "Save" (disabled until required fields filled) |
| Category selected | User picks account category | Category-specific fields animate in below common fields | "Save" |
| Currency changed | User changes currency from home currency default | Visual change indicator (highlighted border) on currency field; info tooltip visible | "Save" |
| Saving | User taps Save | Loading overlay on Save button | — |
| Duplicate name | Name matches existing (including soft-deleted) account | Inline error under Name field: "An account with this name already exists." | — |
| Soft-deleted match (name + category) | Name + category match a soft-deleted account | Dialog: "You previously had an account with this name. Reinstate it?" — Yes / No | Yes → reinstate; No → must change name |
| Error | Save fails (DB write error) | Snackbar: "Failed to create account. Try again." | — |

#### 8.3.2 Currency Immutability Warning Flow

| Step | Trigger | UI |
|------|---------|-----|
| 1 | Currency field has a non-home-currency value at any time during form fill | Highlighted field border + info tooltip: "Account currency cannot be changed after creation. Select carefully." |
| 2 | User taps Save with currency ≠ home currency default | Confirmation dialog: "Your account will be created in [Currency]. This cannot be changed later. Continue?" — Confirm / Cancel |
| 3 | Confirm | Proceeds to save |
| 4 | Cancel | Dialog dismissed; form remains open |

#### 8.3.3 Post-Save: Loan Account Suggestion

| Condition | Dialog |
|-----------|--------|
| Initial balance < 0 OR EMI amount/date filled | After save: "Would you like to set up an installment plan for this loan?" — Set up / Skip |

#### 8.3.4 Field Sequence by Account Category

| Category | Required fields shown (in order) | Optional fields shown |
|----------|-----------------------------------|-----------------------|
| Cash | Name, Category, Currency, Initial balance, Include in net worth, Notes | — |
| Bank Account | Name, Category, Currency, Bank name, Initial balance, Include in net worth, Notes | Account number, Branch, IFSC |
| Credit Card | Name, Category, Currency, Billing date, Payment due date, Initial balance, Include in net worth, Notes | Card name, Card number, Expiry date, Credit limit, Linked bank account |
| Debit Card | Name, Category, Currency, Initial balance, Include in net worth, Notes | Card name, Card number, Expiry date, Linked bank account |
| Top-Up Wallet | Name, Category, Currency, Initial balance, Include in net worth, Notes | Wallet provider name, Linked phone number |
| Loan | Name, Category, Currency, Initial balance, Include in net worth, Notes | Lender/borrower name, Principal amount, Interest rate, EMI amount, EMI date, Due date |
| Investment | Name, Category, Currency, Investment type, Initial balance, Include in net worth, Notes | Institution name, Current value |
| Other | Name, Category, Currency, Initial balance, Include in net worth, Notes | — |

---

### 8.4 Screen: Edit Account

**Route:** `/accounts/:id/edit`

#### 8.4.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push before account data loaded | Shimmer form | — |
| Idle | Account data loaded | Form pre-filled; immutable fields shown read-only (greyed, non-interactive) | "Save" |
| Dirty | Any editable field changed | "Save" enabled | "Save" |
| Saving | User taps Save | Loading indicator on Save button | — |
| Error | Save fails | Snackbar: "Failed to save changes." | — |

#### 8.4.2 Immutable Fields

| Field | Why immutable | What user sees if they try |
|-------|--------------|---------------------------|
| Account category | Category determines posting direction; changing retroactively breaks ledger integrity | Field rendered as read-only chip; no tap target; no edit affordance |
| Currency | All existing transactions and ledger entries reference this currency; retroactive change is undefined | Field rendered as read-only text with lock icon; tapping shows tooltip: "Currency cannot be changed after the account is created." |
| Initial balance | Already posted to ledger as an opening transaction; re-editing would require void + re-post | Not shown in edit form; balance changes happen through Edit Balance flow |

#### 8.4.3 Editable Fields

- Name (uniqueness validated on save, same rule as create)
- Notes
- Include in net worth
- All category-specific optional fields (§2.2 input-fields.md)
- Credit Card: billing date, payment due date, credit limit, linked bank account

---

## 9. Settings Tab

### 9.1 Screen: Settings Hub

**Route:** `/settings`

#### 9.1.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Tab mounted | Sectioned list of all settings groups | — |

#### 9.1.2 Settings Hub Sections (display order)

| # | Section | Route |
|---|---------|-------|
| 1 | Appearance | `/settings/appearance` |
| 2 | Locale & Format | `/settings/locale` |
| 3 | Transaction Entry | `/settings/transaction-entry` |
| 4 | Warnings & Limits | `/settings/warnings` |
| 5 | Profile | `/settings/profile` |
| 6 | Security | `/settings/security` |
| 7 | Accounts | `/settings/accounts` |
| 8 | Categories | `/settings/categories` |
| 9 | Currency | `/settings/currency` |
| 10 | Tags | `/settings/tags` |
| 11 | Payees | `/settings/payees` |
| 12 | Recurring & Installments | `/settings/recurring` |
| 13 | Drafts | `/settings/drafts` |
| 14 | Backup & Data | `/settings/backup` |
| 15 | About | `/settings/about` |

---

### 9.2 Screen: Appearance Settings

**Route:** `/settings/appearance`

#### 9.2.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | All appearance settings pre-filled with current values | — |

#### 9.2.2 Settings

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Theme | Segmented button | Light / Dark / System default | System default |
| Color scheme | Segmented button | Dynamic / Custom / Catppuccin | Dynamic |
| Seed color picker | Color picker (shown only when Color scheme = Custom) | Any color | Device wallpaper color fallback |
| Catppuccin flavour | Not user-selectable in v1 — auto-bound: Light→Latte, Dark→Mocha | — | — |
| Animations | Toggle switch | Enabled / Disabled | Enabled |
| Preview color scheme | Tappable row | Navigates to color preview screen | — |

#### 9.2.3 Dynamic Color Unavailable

| Condition | Fallback |
|-----------|---------|
| Device does not support wallpaper color extraction (OEM restriction) | Color scheme mode auto-falls back to Custom seed; user sees "Dynamic color not available on this device" inline note |

#### 9.2.4 Color Scheme Preview Screen

**Route:** `/settings/appearance/preview`

| State | UI |
|-------|-----|
| Loaded | Material 3 color swatch grid: primary, secondary, tertiary, surface, on-surface tokens; derived from active mode (dynamic / custom seed / catppuccin flavour); labelled with M3 role names |

---

### 9.3 Screen: Locale & Format Settings

**Route:** `/settings/locale`

#### 9.3.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | All locale settings pre-filled | — |

#### 9.3.2 Settings

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Home currency | Searchable picker → `/settings/currency` | ISO 4217 list (bundled ~180) | Inferred from device locale; fallback INR |
| Decimal separator | Segmented button | Comma / Period | Inferred from locale |
| Thousands grouping | Segmented button | Standard 3-digit / Indian (lakh/crore) | Inferred from locale |
| Currency symbol placement | Segmented button | Prefix / Suffix | Inferred from home currency locale |
| Currency symbol spacing | Segmented button | No space / Space | Inferred from home currency locale |
| Week start | Segmented button | Monday / Sunday | Monday |
| Time format | Segmented button | 12-hour / 24-hour | Inferred from device |
| Percentage precision | Dropdown | 0 / 1 / 2 decimal places | 0 |

---

### 9.4 Screen: Transaction Entry Settings

**Route:** `/settings/transaction-entry`

#### 9.4.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | All transaction entry settings pre-filled | — |

#### 9.4.2 Settings

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Description max length | Dropdown | 500 / 1000 / 2000 chars | 1000 |
| Back button behaviour | Segmented / Radio | Ask before discarding / Auto-save as draft / Discard immediately | Ask before discarding |

#### 9.4.3 Draft Lifecycle Note (displayed as info card in screen)

| Rule | Display |
|------|---------|
| Max 5 drafts; oldest evicted silently when limit hit | Shown as informational caption below "Back button behaviour" when Auto-save is selected |

---

### 9.5 Screen: Warnings & Limits

**Route:** `/settings/warnings`

#### 9.5.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | Two rows: Per-Account Limits, Per-Category Limits | — |

#### 9.5.2 Per-Account Limits Sub-screen

**Route:** `/settings/warnings/accounts`

| State | UI |
|-------|-----|
| Empty | "No accounts" empty state |
| Populated | List of all active accounts; each row shows account name + current threshold or "Not set" |
| Tapping a row | Inline edit field (amount input); save on confirm; clear = "Not set" |

#### 9.5.3 Per-Category Limits Sub-screen

**Route:** `/settings/warnings/categories`

| State | UI |
|-------|-----|
| Empty | "No categories" empty state |
| Populated | List of expense categories (parent + children); each row shows category name + threshold in home currency or "Not set" |
| Threshold currency | Always home currency (ISO code displayed beside amount) |
| Tapping a row | Inline edit field; save on confirm; clear = "Not set" |

---

### 9.6 Screen: Profile Settings

**Route:** `/settings/profile`

#### 9.6.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | Display name field + avatar section (local only) | "Save" |
| Saved | Tap Save | Snackbar "Profile updated" | — |

#### 9.6.2 Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| Display name | Text (optional) | Empty | Used in home screen greeting "Hi, [name]!"; empty → "Hi!" |
| Avatar | Image (local only) | System default icon | Selected from device gallery; stored on-device; never uploaded |

---

### 9.7 Screen: Security Settings

**Route:** `/settings/security`

#### 9.7.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | Lock timeout + PIN management rows | — |
| No in-app PIN set | Device lock is primary | PIN rows hidden; info text: "Using device lock for sensitive field protection." | — |
| In-app PIN active | Neither device lock nor device app-specific lock available | Lock timeout picker + Change PIN row + Biometric toggle | — |

#### 9.7.2 Settings

| Setting | Control | Options | Default | Notes |
|---------|---------|---------|---------|-------|
| Lock timeout | Dropdown | Immediately / 30 seconds / 1 minute / 5 minutes | Immediately | Time after backgrounding before lock re-engages |
| Biometric toggle | Toggle switch | Enabled / Disabled | Enabled (if biometric enrolled) | Only shown when biometrics are available |
| Change PIN | Tappable row | Navigates to PIN change flow | — | Only shown when in-app PIN is active |

#### 9.7.3 Scope Clarification (info card)

Displayed at top of screen: "The lock protects sensitive account details (card numbers, account numbers). Core app features are always accessible."

#### 9.7.4 PIN Recovery Info Row

Shown when in-app PIN active: "Forgot PIN? Use your device security to reset." — tap navigates to device security settings.

---

### 9.8 Screen: Category Management

**Route:** `/settings/categories`

#### 9.8.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer list | — |
| Loaded – empty | No user categories (only defaults) | Default categories listed alphabetically per tree | FAB: "Add Category" |
| Loaded – populated | Categories exist | Two tabs: "Expense" / "Income"; each tab shows parent categories only, alphabetically; each row: icon + name + child count | FAB: "Add Category" |
| Error | DB read failure | Inline error banner + Retry | Retry |

#### 9.8.2 Category Row Actions (long-tap contextual menu)

| Entity | Actions |
|--------|---------|
| Parent category (has children) | Edit, Delete (disabled until all children soft-deleted), Add Child Category |
| Parent category (no children / leaf) | Edit, Delete, Add Child Category |
| Soft-deleted category | Reinstate |

#### 9.8.3 "Balance Adjustment" Category

- Hidden from this screen entirely (protected system category).

---

### 9.9 Screen: Category Detail / Edit

**Route:** `/settings/categories/:id`

#### 9.9.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Loaded – parent category | Category is a parent | Name field, icon picker, subcategory list below with + button | "Save" |
| Loaded – child category | Category is a subcategory | Name field, icon picker, read-only parent label | "Save" |
| Dirty | Any field changed | "Save" enabled | "Save" |
| Error | Save fails | Snackbar "Failed to save." | — |

#### 9.9.2 Fields

| Field | Mutable | Notes |
|-------|---------|-------|
| Icon | Yes | Selected from curated ~250-icon subset of `material_symbols_icons`; icon picker sheet |
| Name | Yes | Unique within tree level (case-insensitive); unique including soft-deleted |
| Parent category | No (IM) | Shown read-only on child categories; parent reassignment deferred to v2 |

#### 9.9.3 Subcategory Section (parent category view only)

| State | UI |
|-------|-----|
| No subcategories | "No subcategories" + "Add first subcategory" button |
| Has subcategories | List of subcategory rows (icon + name); long-tap for Edit / Delete |

#### 9.9.4 Category Deletion Flow

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Contextual menu | Tap Delete | Check: any recurring/installment templates reference this category? | If yes → blocking dialog | Step 1a |
| 1a (if templates) | Dialog: template handling | Choose Migrate or Stop; if Migrate: select replacement category | Replacement must be same tree (income/expense) | Templates migrated or archived | Step 2 |
| 2 | Info dialog | — | Compute N active transactions | If N > 0: "This category is used by [N] transaction(s)." | Step 3 |
| 3 | Dialog: migration choice | Choose No migration / Migrate all / Choose specific | — | If Migrate all: select destination. If Choose specific: multi-select transaction sheet | Step 4 |
| 3a (Migrate all) | Category picker | Select destination category | Must be same tree | All transactions re-categorised via ledger correction (§4.8) | Step 4 |
| 3b (Choose specific) | Transaction multi-select sheet | Select subset | — | Selected transactions migrated; others retain old label | Step 4 |
| 4 | — | — | Batch > 50: additional confirmation dialog | Soft-delete proceeds; category hidden from pickers | Done |

---

### 9.10 Screen: Currency Settings

**Route:** `/settings/currency`

#### 9.10.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | Home currency row (with change warning) + secondary currencies list | — |

#### 9.10.2 Home Currency Row

| Element | Rule |
|---------|------|
| Display | Current home currency code + name |
| Change | Tapping opens ISO 4217 searchable picker |
| Warning banner | "Changing home currency does not affect existing transactions. Net worth display will recalculate using new exchange rates." |
| No hard block | Home currency is always changeable; it only affects defaults and display aggregation |

#### 9.10.3 Secondary Currencies

- Listed: all currencies currently used by active accounts (derived, not user-managed).
- Exchange rate staleness shown per currency: last-fetched timestamp; "Outdated" label if > 14 days.
- No add/remove action — secondary currencies are derived from account currencies.

---

### 9.11 Screen: Tags Management

**Route:** `/settings/tags`

#### 9.11.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Empty | No tags exist | "No tags yet" illustration | FAB: "Add Tag" |
| Populated | Tags exist | Alphabetical list; each row: tag name + usage count | FAB: "Add Tag" |
| Error | DB failure | Inline error + Retry | Retry |

#### 9.11.2 Tag Row Actions (long-tap or swipe)

| Action | Notes |
|--------|-------|
| Rename | Inline text edit; uniqueness validated |
| Delete | Confirmation: "Delete tag '[name]'? It will be removed from all transactions." |

---

### 9.12 Screen: Payees Management

**Route:** `/settings/payees`

#### 9.12.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Empty | No payees exist | "No payees yet" illustration | FAB: "Add Payee" |
| Populated | Payees exist | Alphabetical list; each row: payee name + last-used date + transaction count | FAB: "Add Payee" |
| Error | DB failure | Inline error + Retry | Retry |

#### 9.12.2 Payee Row Actions (long-tap contextual menu)

| Action | Notes |
|--------|-------|
| Rename | Inline text edit; uniqueness validated |
| Merge | Select target payee; all transactions referencing source payee re-assigned to target; source payee deleted |
| Delete | Confirmation dialog: payee removed from future pickers; historical transactions retain payee label |

---

### 9.13 Screen: Recurring Templates List

**Route:** `/settings/recurring`

#### 9.13.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Empty | No templates exist | "No recurring templates" illustration | — |
| Populated | Templates exist | Two tabs: "Recurring" / "Installments"; within each tab: three groups: Active, Paused, Archived | — |
| Error | DB failure | Inline error + Retry | Retry |

#### 9.13.2 Template Row (Recurring)

| Element | Content |
|---------|---------|
| Title | Template title (or amount + category if no title) |
| Badge | "Active" (green) / "Paused" (amber) / "Archived" (grey) |
| Recurrence summary | e.g., "Every 2 weeks · Auto-post" |
| Next due | Next scheduled date (active/paused only) |
| Long-tap menu — Active | Edit template, Delete template, Pause, View child transactions |
| Long-tap menu — Paused | Edit template, Delete template, Unpause, View child transactions |
| Long-tap menu — Archived | View child transactions (read-only) |

#### 9.13.3 Template Row (Installment)

| Element | Content |
|---------|---------|
| Title | Template title or amount |
| Progress indicator | Linear progress bar: paid / total installment count |
| Running total | "₹X paid of ₹Y" |
| Long-tap menu — Active | Edit template, Delete template, Pause, Unpause, View child transactions, View payment progress, Mark series as complete |
| Long-tap menu — Paused | Edit template, Delete template, Unpause, View child transactions, View payment progress, Mark series as complete |
| Long-tap menu — Archived | View child transactions, View payment progress (read-only) |

---

### 9.14 Screen: Recurring Template Detail / Edit

**Route:** `/settings/recurring/:id`

#### 9.14.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer form | — |
| Loaded | Template data ready | All fields; immutable fields read-only | "Save" (disabled until dirty) |
| Dirty | Editable field changed | "Save" enabled | "Save" |
| Saving | Tap Save | Loading on Save button | — |
| Error | Save fails | Snackbar "Failed to save." | — |

#### 9.14.2 Immutable Fields

| Field | Why immutable | What user sees if they try |
|-------|--------------|---------------------------|
| Transaction type | Changes would invalidate historical child transactions | Read-only chip; tooltip: "Transaction type cannot be changed. Create a new template to change the type." |
| Recurrence N, unit, constraints | Schedule structure cannot be changed retroactively | Read-only; tooltip: "Recurrence schedule cannot be changed. Archive this template and create a new one." |
| Start date | Posted occurrences anchored to this date | Read-only |
| End date | Must match series boundary | Read-only |

#### 9.14.3 Editable Fields

| Field | Rule |
|-------|------|
| Amount | Applies to future unposted occurrences only |
| Account(s) | Future occurrences only; account must be active (not soft-deleted) |
| Category / subcategory | Future occurrences only |
| Title | Future occurrences only |
| Description | Future occurrences only |
| Posting behaviour | Auto-post ↔ Remind and confirm |
| Transfer fee fields | Transfer-type templates only; future occurrences only |

#### 9.14.4 Pause Flow

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Contextual menu | Tap Pause | — | Pause duration dialog opens | Step 2 |
| 2 | Dialog: pause duration | Select mode: N units OR Custom date; enter value | N > 0; custom date must be in future; indefinite pause not allowed | — | Step 3 |
| 3 | — | Confirm | — | Template status → Paused; future occurrences within pause window suppressed | Done |

#### 9.14.5 Next Due Date Display

| Template state | Display |
|----------------|---------|
| Active | "Next due: [date]" |
| Paused | "Paused until [date]" |
| Archived | "Archived" |

---

### 9.15 Screen: Installment Plans List

**Route:** `/settings/recurring` → Installments tab

(Same route as §9.13; rendered in Installments tab)

#### 9.15.1 States

Identical to Recurring Templates List (§9.13.1) but filtered to installment type.

---

### 9.16 Screen: Installment Plan Detail / Edit

**Route:** `/settings/installments/:id`

#### 9.16.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Loaded | Template data ready | Summary card + per-installment list | "Save" |
| Dirty | Editable field or installment amount changed | "Save" enabled; mismatch warning shown if Projected ≠ Configured | "Save" |
| Mismatch warning | Projected final total ≠ Total configured | Non-blocking inline banner: "Total paid will be [X], original target was [Y]." | — |

#### 9.16.2 Summary Card (4 Tracked Amounts)

| Amount | Label |
|--------|-------|
| Total configured | "Target total" |
| Running total | "Paid to date" |
| Total remaining | "Remaining" |
| Projected final total | "Projected total" |

#### 9.16.3 Per-Installment List

| Column | Content |
|--------|---------|
| # | Installment number |
| Scheduled date | Date of scheduled posting |
| Amount | Editable for unposted installments; read-only for posted |
| Status | Scheduled / Posted / Manually handled / Cancelled |
| Actions | Swipe to delete (unposted only); tap to edit amount (unposted only) |

#### 9.16.4 Add / Remove Installments

| Action | Availability |
|--------|-------------|
| Add future installment | FAB at bottom of per-installment list; adds row with computed date and auto-filled amount |
| Remove unposted installment | Swipe-delete on list row; mismatch warning fires if total diverges |

#### 9.16.5 Early Close Flow

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Contextual menu → "Mark series as complete" | Tap | — | Dialog: "Record a final payment before closing?" — Yes / No | Step 2 |
| 2a (Yes) | Transaction entry form (pre-filled) | Enter final payment amount; adjust fields as needed | Amount > 0 | Transaction posted as child; remaining installments cancelled; template archived | Step 3 |
| 2b (No) | — | Confirm | — | Remaining installments cancelled; template archived | Step 3 |
| 3 (if Running ≠ Configured) | Dialog | Choose: "Update target to [running total]?" — Yes / No | — | Yes: Total configured updated. No: archived with mismatch. | Done |

---

### 9.17 Screen: Backup & Restore

**Route:** `/settings/backup`

#### 9.17.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Idle | Route push | Two rows: "Export backup" + "Import backup (v2)"; import row greyed out with "Coming soon" label | "Export backup" |
| Exporting | Tap Export | Progress indicator overlay | — |
| Export success | ZIP written to device | Snackbar: "Backup saved to [path]" | — |
| Export error | File write failure | Dialog: "Export failed. Check storage permissions and available space." | Retry / Cancel |

#### 9.17.2 Export Flow

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Backup screen | Tap "Export backup" | — | System file picker opens (Android storage access framework); default: Downloads | Step 2 |
| 2 | File picker | Choose save location; confirm | — | App assembles ZIP: `manifest.json` + `variance_export.json` + attached photos | Step 3 |
| 3 | — | — | — | ZIP written to selected location; progress indicator shown | Step 4 |
| 4 | — | — | Write succeeds | Snackbar: "Backup saved to [path/filename]" | Done |
| 4 (error) | — | — | Write fails | Error dialog; retry or cancel | — |

#### 9.17.3 ZIP Contents

| File | Description |
|------|-------------|
| `manifest.json` | `backup_format_version`, `app_version`, `created_at`, `schema_version` |
| `variance_export.json` | All non-soft-deleted entities serialized as versioned DTOs |
| `photos/` | All attached transaction photos; filenames match transaction attachment records |

#### 9.17.4 Import / Restore (v2)

| Element | Display |
|---------|---------|
| Import row | Greyed out; labelled "Restore from backup — Coming in a future update" |
| Import action | Not interactive in v1 |

---

### 9.18 Screen: About

**Route:** `/settings/about`

#### 9.18.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loaded | Route push | Static info screen | — |

#### 9.18.2 Sections

| Section | Content |
|---------|---------|
| App version | Semantic version string from `pubspec.yaml` |
| Open-source licenses | "View licenses" row → Flutter `LicensePage` |
| Acknowledgements | Credits and attributions |
| Support | Support link (tappable URL) |

---

### 9.19 Screen: Drafts

**Route:** `/settings/drafts`

#### 9.19.1 States

| State | Trigger | UI shown | Primary CTA |
|-------|---------|----------|-------------|
| Loading | Route push | Shimmer | — |
| Empty | No drafts exist | "No drafts saved" illustration + "Drafts are saved when you back out of an unsaved transaction." | — |
| Populated (≤ 5) | Drafts exist | List of draft rows | — |
| Error | DB read failure | Inline error + Retry | Retry |

#### 9.19.2 Draft Row

| Element | Content |
|---------|---------|
| Transaction type | Income / Expense / Transfer badge |
| Amount | Partial amount if filled; "—" if not yet entered |
| Title | Partial title if filled; "Untitled" if not |
| Saved at | Relative timestamp (e.g., "2 hours ago") |
| Actions | Tap to resume; long-tap → Delete draft |

#### 9.19.3 Resume Draft

| Step | System response |
|------|-----------------|
| Tap draft | Opens transaction entry form pre-filled with draft state; draft record deleted immediately on open |

#### 9.19.4 Draft Limit Note

| Condition | Display |
|-----------|---------|
| 5 drafts stored (limit reached) | Info banner at top: "Maximum 5 drafts stored. The oldest draft will be discarded when a new draft is saved." |

---

### 9.20 Flow: Account Creation

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Account list | Tap FAB "Add Account" | — | `/accounts/new` pushed | Step 2 |
| 2 | Create Account form | Select account category | — | Category-specific fields animate in | Step 3 |
| 3 | Create Account form | Fill Name | — | Uniqueness validated on change: inline error if duplicate (including soft-deleted match → reinstatement dialog) | Step 4 |
| 4 | Create Account form | Select currency | Defaults to home currency | If changed: highlighted border + tooltip warning | Step 5 |
| 5 | Create Account form | Enter initial balance | Numeric; valid for currency minor_units | — | Step 6 |
| 6 | Create Account form | Fill category-specific fields | Required fields for category | — | Step 7 |
| 7 | Create Account form | Tap Save | All required fields present | If currency ≠ home: confirmation dialog | Step 8 |
| 8 | Confirmation dialog | Confirm | — | Account + opening ledger entry written | Step 9 |
| 9 | — | — | Account is Loan with negative balance or EMI fields filled | Post-save suggestion dialog: "Set up installment plan?" | Step 10 |
| 10 | Account list | — | — | Navigates back; new account visible | Done |

### 9.21 Flow: Account Edit — Immutable Field Warning

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Account detail or account list | Tap Edit (contextual menu or app bar) | — | `/accounts/:id/edit` pushed; form pre-filled | Step 2 |
| 2 | Edit Account form | Taps Currency field | — | Tooltip shown: "Currency cannot be changed after the account is created." Field non-interactive. | Step 2 (no transition) |
| 3 | Edit Account form | Taps Account Category field | — | Field rendered as read-only chip; no action taken | Step 3 (no transition) |
| 4 | Edit Account form | Edits Name | Uniqueness validated on change | Inline error if duplicate | Step 5 |
| 5 | Edit Account form | Tap Save | Required fields valid | Account record updated | Step 6 |
| 6 | Account detail | — | — | Returns to account detail; updated fields reflected | Done |

### 9.22 Flow: Category Creation — Inline vs. From Settings

#### 9.22.1 From Settings

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Category Management | Tap FAB "Add Category" | — | Create Category sheet / screen opens; tree (Income / Expense) selector at top | Step 2 |
| 2 | Create Category | Select tree (Income / Expense) | — | — | Step 3 |
| 3 | Create Category | Select icon from curated picker | — | Icon picker sheet; ~250 icons | Step 4 |
| 4 | Create Category | Enter name | Unique within tree and level (including soft-deleted) | — | Step 5 |
| 5 | Create Category | Tap Save | — | Parent category created; navigates back to list | Done |

To create a subcategory from Settings: tap parent category row → navigates to Category Detail → tap + button in subcategory section → subcategory create sheet; same fields (icon + name); parent field read-only.

#### 9.22.2 Inline (during Transaction Entry)

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Transaction Entry form | Tap category picker | — | Category picker sheet opens | Step 2 |
| 2 | Category picker sheet | Tap "+ New category" | — | Inline create form (icon + name + tree selector) within sheet | Step 3 |
| 3 | Inline create form | Fill and confirm | Unique within tree/level | New category created; picker auto-selects new category; sheet dismisses | Done |

Both paths produce identical entity records. No difference in result.

### 9.23 Flow: Recurring Template Creation

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Transaction Entry form | Fill transaction fields; toggle "Make recurring" | — | Recurrence section expands below form | Step 2 |
| 2 | Recurrence section | Set recurrence N and unit | N > 0; unit ∈ {day, week, month, year} | — | Step 3 |
| 3 | Recurrence section | (Optional) Set recurrence constraints | Mutually exclusive subset | — | Step 4 |
| 4 | Recurrence section | Set start date | ≥ today | — | Step 5 |
| 5 | Recurrence section | (Optional) Set end date | > start date | — | Step 6 |
| 6 | Recurrence section | Select posting behaviour | Auto-post or Remind and confirm | If Remind and confirm: OS notification permission requested if not yet granted | Step 7 |
| 7 | Transaction Entry form | Tap Save | All required fields present | Transaction posted as first occurrence + recurring template created | Step 8 |
| 8 | Home / previous screen | — | — | Navigates back; new transaction visible | Done |

### 9.24 Flow: Backup — Export ZIP

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Settings hub | Tap "Backup & Data" | — | `/settings/backup` pushed | Step 2 |
| 2 | Backup screen | Tap "Export backup" | — | Android storage access framework file picker opens | Step 3 |
| 3 | File picker | Choose location (default: Downloads); confirm filename | — | File picker returns URI | Step 4 |
| 4 | — | — | — | App assembles export: serializes all non-soft-deleted entities to `variance_export.json`; writes `manifest.json`; bundles attached photos into `photos/`; writes ZIP to selected URI | Step 5 |
| 5 | Backup screen | — | Write success | Snackbar: "Backup saved to [filename]" | Done |
| 5 (error) | Backup screen | — | Write failure | Dialog: "Export failed. Check storage permissions and available space." — Retry / Cancel | — |

### 9.25 Flow: Color Scheme Selection

| Step | Screen / component | User action | Validation | System response | Next step |
|------|-------------------|-------------|------------|-----------------|-----------|
| 1 | Settings hub | Tap "Appearance" | — | `/settings/appearance` pushed | Step 2 |
| 2 | Appearance screen | Tap color scheme mode | — | Segmented button updates | Step 3a/3b/3c |
| 3a (Dynamic) | Appearance screen | Select "Dynamic" | — | `color_scheme_mode = dynamic`; `DynamicColorBuilder` activates; if device unsupported: auto-fallback to Custom + inline note | Done |
| 3b (Custom) | Appearance screen | Select "Custom" | — | Seed color picker widget appears | Step 4 |
| 4 | Appearance screen | Pick seed color from color picker | — | `color_seed` written to `app_settings`; theme rebuilds with `ColorScheme.fromSeed(seedColor: chosen)` | Step 5 |
| 5 | Appearance screen | (Optional) Tap "Preview color scheme" | — | `/settings/appearance/preview` pushed | Step 6 |
| 6 | Preview screen | View M3 token swatch grid | — | Grid shows primary, secondary, tertiary, surface, on-surface swatches derived from active scheme | Back to Appearance |
| 3c (Catppuccin) | Appearance screen | Select "Catppuccin" | — | `color_scheme_mode = catppuccin`; Light mode → Latte flavour; Dark mode → Mocha flavour; `VarianceColors` tokens re-mapped per Catppuccin palette | Done |

---

## 10. Immutable Field Reference

| Field | Entity | Why immutable | What user sees if they try |
|-------|--------|--------------|---------------------------|
| Account currency | Account | All transactions + ledger entries reference it; retroactive change undefined | Read-only text with lock icon; tap → tooltip: "Currency cannot be changed after the account is created." |
| Account category | Account | Determines posting direction and category-specific fields; change would break ledger model | Read-only chip; no edit affordance; no tooltip needed (not tappable) |
| Initial balance | Account | Already posted as opening ledger entry | Not shown in edit form |
| Transaction type | Recurring template | Child transactions already posted under this type; change invalidates them | Read-only chip; tooltip: "Transaction type cannot be changed. Archive this template and create a new one." |
| Recurrence N, unit, constraints | Recurring / installment template | Posted occurrences anchored to schedule; retroactive change undefined | Read-only row with lock icon; tooltip: "Recurrence cannot be changed. Archive and create a new template." |
| Start date | Recurring / installment template | Occurrence series calculated from this anchor | Read-only date chip |
| End date | Recurring template | Series boundary | Read-only date chip |
| End date | Installment template | Computed from installment count × period; always derived | Read-only derived value label |
| Total configured | Installment template | Immutable during normal operation; only modifiable during early close flow | Read-only; shown as non-interactive amount; early close is the only code path |
| Parent category | Subcategory | Reassignment deferred to v2 | Read-only label; tooltip: "Changing the parent category is not supported in this version." |
