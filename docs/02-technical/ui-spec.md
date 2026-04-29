---
title: UI Spec
status: draft
owner: le
updated: 2026-04-29
---

# UI Spec



## 1. Global Design Decisions

| Decision | Resolution |
|---|---|
| Bottom nav icons | `home`, `account_balance_wallet`, `settings` (Material Symbols) |
| Bottom nav labels | Home / Accounts / Settings |
| FAB vs SpeedDial | SpeedDial with 3 actions: Expense / Income / Transfer (resolves UX-2) |
| Amount entry | System keyboard (resolves UX-12) |
| Empty state illustration | Abstract geometric, theme-colored (resolves UX-13) |
| Snackbar vs dialog on delete | Snackbar + undo for soft-delete; AlertDialog for irreversible destructive only (resolves UX-9) |
| Transaction list grouping | Date headers only; no running balance in list (v2) |
| Category chip style | SuggestionChip — tonal, small, category icon left |
| Account detail hero | Balance amount + compact balance history bar strip |
| Home greeting | Dynamic time-of-day: Good morning / afternoon / evening, [name] |

---

## 2. App Shell & Navigation

### 2.1 Shell Scaffold

| Field | Value |
|---|---|
| Scaffold | `StatefulShellRoute.indexedStack` (GoRouter ^14.6.2) |
| Tab count | 3 |
| Bottom bar component | M3 `NavigationBar` |
| Elevation | `NavigationBar` uses M3 elevation token `level2` (surface tint applied) |
| Height | M3 default: 80 dp |
| Indicator | M3 active indicator pill (`secondaryContainer` fill, `onSecondaryContainer` icon) |
| FAB | SpeedDial — present only on Tab 0 (Home) and Tab 1 (Accounts); absent on Tab 2 (Settings) |
| Transition default | Fade-through (`FadeTransition`) for tab switches; slide-right push for in-tab navigation |

### 2.2 NavigationBar Item Spec

| # | Label | Icon (Material Symbols) | Active indicator color |
|---|---|---|---|
| 0 | Home | `home` | `secondaryContainer` |
| 1 | Accounts | `account_balance_wallet` | `secondaryContainer` |
| 2 | Settings | `settings` | `secondaryContainer` |

- Icon size: 24 dp (M3 default)
- Label style: `VarianceTypography.tabLabel` (12 sp), `onSurfaceVariant` inactive, `onSecondaryContainer` active
- State layer opacity: M3 standard (hover 8%, pressed 12%, focused 12%)

### 2.3 Route Map

| Route | Screen | In shell? | Notes |
|---|---|---|---|
| `/` | `HomeScreen` | Yes — Tab 0 | |
| `/accounts` | `AccountListScreen` | Yes — Tab 1 | |
| `/settings` | `SettingsScreen` | Yes — Tab 2 | |
| `/transaction/new` | `CreateTransactionScreen` | No — full-screen modal | Slide-up |
| `/transaction/:id` | `TransactionDetailScreen` | Yes — pushed on Tab 0 stack | |
| `/transaction/:id/edit` | `EditTransactionScreen` | No — full-screen modal | Slide-up |
| `/accounts/:id` | `AccountDetailScreen` | Yes — pushed on Tab 1 stack | |
| `/accounts/new` | `CreateAccountScreen` | No — full-screen modal | Slide-up |
| `/settings/security/pin-setup` | `PinSetupScreen` | No — full-screen modal | Slide-up |
| `/settings/security/pin-entry` | `PinEntryScreen` | No — overlay | Covers shell entirely |
| `/onboarding` | `OnboardingWizardScreen` | No — full-screen modal | Shown once; redirect guard |

### 2.4 Tab Behaviour

| Scenario | Behaviour |
|---|---|
| Tap active tab icon, stack depth > 1 | Pop to tab root |
| Tap active tab icon, already at root | No-op |
| Tap different tab | Switch branch; restore stack exactly as left |
| `NavigationBar` visibility | Always visible in shell; hidden inside full-screen modal routes |

### 2.5 Back-Stack Rules

| Scenario | Behaviour |
|---|---|
| Android back at tab root | Exit app |
| Android back on deep screen within tab | Pop to previous screen in that tab's stack |
| Android back inside full-screen modal | Dismiss modal; shell remains |
| `context.go(...)` | Replaces root of current tab stack |
| `context.push(...)` | Pushes onto current tab stack |

### 2.6 Shell States

| State | Trigger | UI |
|---|---|---|
| Populated | Onboarding complete, any tab active | `NavigationBar` + active tab content |
| Loading | App start, restoring state | Splash retained; shell scaffold visible |

> No shell-level empty or error state — each tab owns its own empty/error handling.

### 2.7 Transition Defaults

| Context | Transition |
|---|---|
| Tab switch | Fade-through |
| In-tab push (e.g. Account → Account Detail) | Right-to-left slide push |
| Full-screen modal open | Slide up from bottom |
| Full-screen modal dismiss | Slide down to bottom |
| Overlay (PIN entry) | Fade in |

---

## 3. Onboarding & First Launch

### 3.1 Screen

| Field | Value |
|---|---|
| Route | `/onboarding` |
| Scaffold | Full-screen modal (no shell, no `NavigationBar`) |
| AppBar | None |
| Scroll | `PageView` (horizontal, 5 pages) |
| FAB | None |
| Transition | Slide-up from bottom on entry; `context.go('/')` on exit |
| Guard | GoRouter redirect: `onboardingComplete == false` → redirect all routes here |

### 3.2 Wizard Chrome (persistent across all steps)

| Zone | Component | Token / Role |
|---|---|---|
| Top-right | Skip `TextButton` (hidden on Steps 1 and 5) | `primary` |
| Bottom | Step progress — `LinearProgressIndicator` (5 steps) | `primary` fill, `surfaceContainerHighest` track |
| Bottom | Primary CTA `FilledButton` | `primary` / `onPrimary` |

- Progress indicator height: 4 dp
- CTA width: full-width (`double.infinity`)
- CTA label style: `VarianceTypography.buttonText` (14 sp)

### 3.3 Step 1 — Welcome

| Field | Value |
|---|---|
| Skip button | Hidden |
| CTA label | "Get started" |
| CTA action | Advance to Step 2 |

#### 3.3.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Center | App logo / wordmark | `primary` |
| Center | App name headline | `VarianceTypography.displayLargeAmount` (36 sp), `onSurface` |
| Center | Tagline | `VarianceTypography.bodyLarge` (16 sp), `onSurfaceVariant` |
| Center | Value prop bullets (3 items) | `VarianceTypography.bodyMedium` (14 sp), `onSurfaceVariant` |

### 3.4 Step 2 — Currency Selection

| Field | Value |
|---|---|
| Skip button | Visible — silently sets detected/fallback currency |
| CTA label | "Confirm" |
| CTA action | Persist home currency; advance to Step 3 |

#### 3.4.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Top | Section heading | `VarianceTypography.sectionHeading` (20 sp), `onSurface` |
| Center | Detected currency display row | `VarianceTypography.bodyLarge` (16 sp), `onSurface` |
| Center | `OutlinedTextField` — currency search | `outline` border, `onSurface` label |
| Center | Currency list (ISO 4217 bundled) — `ListView.builder` | `VarianceTypography.bodyMedium` (14 sp) |

#### 3.4.2 States

| State | Treatment |
|---|---|
| Loading (locale detect) | `CircularProgressIndicator` (20 dp) inside field; CTA disabled |
| Error (locale detect) | Fallback to INR silently; field pre-populated |
| Nominal | Currency pre-selected, editable |

### 3.5 Step 3 — Create First Account

| Field | Value |
|---|---|
| Skip button | Visible — skips account creation; home shows empty-state CTA |
| CTA label | "Create account" |
| CTA action | Write account to DB; advance to Step 4 |
| CTA enabled | Only when required fields valid |

#### 3.5.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Top | Section heading | `VarianceTypography.sectionHeading` (20 sp), `onSurface` |
| Form | Account name `OutlinedTextField` (required) | `error` role on validation failure |
| Form | Account category `ExposedDropdownMenu` (8 fixed types) | `VarianceTypography.bodyMedium` (14 sp) |
| Form | Initial balance `OutlinedTextField` (optional, default 0) | `VarianceTypography.numericMedium` (16 sp) |

#### 3.5.2 States

| State | Treatment |
|---|---|
| Invalid submission | Inline field error below failing field; `error` color role |
| Valid | CTA enabled (`FilledButton` active) |

### 3.6 Step 4 — Quick Highlights

| Field | Value |
|---|---|
| Skip button | Visible |
| CTA label | "Done" |
| CTA action | Advance to Step 5 |

#### 3.6.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Center | `PageView` — 2–3 swipeable highlight cards | `surfaceContainerLow` card fill |
| Center | Dot page indicator | `primary` active, `outlineVariant` inactive |
| Card | Feature icon (M3 Symbols, 40 dp) | `primary` |
| Card | Card headline | `VarianceTypography.sectionHeading` (20 sp), `onSurface` |
| Card | Card body | `VarianceTypography.bodyMedium` (14 sp), `onSurfaceVariant` |

### 3.7 Step 5 — Done

| Field | Value |
|---|---|
| Skip button | Hidden |
| CTA label | "Start tracking" |
| CTA action | `onboardingComplete = true` → `context.go('/')` |
| Auto-transition | After ≤ 1.5 s if user does not tap CTA |

#### 3.7.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Center | Completion illustration — abstract geometric, theme-colored | `primary` / `tertiary` palette |
| Center | Headline: "You're all set!" | `VarianceTypography.displayLargeAmount` (36 sp), `onSurface` |
| Center | Sub-copy | `VarianceTypography.bodyLarge` (16 sp), `onSurfaceVariant` |

---

## 4. App Lock & Security Screens

### 4.1 Scope

- App lock protects **sensitive account detail fields only** (card numbers, bank account numbers).
- No shell-level route guard — core routes are never blocked.
- Lock overlay is rendered inside `AccountDetailScreen`; it is not a route.

### 4.2 App Lock Overlay

| Field | Value |
|---|---|
| Scaffold | Overlay widget inside `AccountDetailScreen` — not a route |
| AppBar | None (overlay covers only sensitive field zone) |
| Scroll | None |
| FAB | None |
| Transition | Fade in on lock; fade out on unlock |

#### 4.2.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Sensitive fields zone | Blurred container (`BackdropFilter` + `ImageFilter.blur`) | `surfaceContainerHigh` tint |
| Center | Lock icon (`lock`, 32 dp) | `onSurfaceVariant` |
| Center | "Unlock" `FilledButton` | `primary` / `onPrimary` |
| Center | "Use PIN" `TextButton` (shown when biometric available) | `primary` |

#### 4.2.2 States

| State | Treatment |
|---|---|
| Locked | Blur overlay visible; "Unlock" button shown; biometric prompt auto-triggers |
| Biometric prompt active | System bottom sheet; overlay remains |
| PIN entry | `PinEntryScreen` overlay shown above lock overlay |
| Unlocked | Overlay dismissed; sensitive fields revealed |
| Lockout (5 failures) | Lockout banner with countdown timer; "Unlock" disabled; `warningAmount` color |
| Wiped (15 failures) | Banner: "Sensitive data has been deleted."; `error` color role; "OK" `TextButton` |

#### 4.2.3 Lock Conditions

| Condition | Behaviour |
|---|---|
| App backgrounded | Lock re-engages after configured timeout |
| App foregrounded within timeout | Overlay not shown |
| App foregrounded after timeout | Overlay shown; re-auth required |
| Timeout options | Immediately / 30 s / 1 min / 5 min |
| Failure counter reset | On any successful auth |
| Wipe target | Encrypted rows in `account_details` only; balances and transactions untouched |

### 4.3 PIN Setup Screen

| Field | Value |
|---|---|
| Route | `/settings/security/pin-setup` |
| Scaffold | Full-screen modal |
| AppBar | `SmallTopAppBar` — title: "Set PIN" or "Change PIN" per mode; back arrow closes without saving |
| Scroll | None |
| FAB | None |
| Transition | Slide-up modal |
| Modes | `mode=create` (first time) / `mode=change` (existing PIN) |

#### 4.3.1 Components — Enter PIN Step

| Zone | Component | Token / Role |
|---|---|---|
| AppBar | Title | `VarianceTypography.sectionHeading` (20 sp), `onSurface` |
| Center | Step label: "Create a PIN" / "Confirm your PIN" | `VarianceTypography.bodyLarge` (16 sp), `onSurfaceVariant` |
| Center | 6-dot masked PIN indicator row | `primary` filled dot per entered digit, `outlineVariant` empty dot |
| Center | Custom numeric keypad grid (3×4, digits 0–9 + backspace) | `surfaceContainerLow` key fill, `onSurface` label |
| Bottom | Mismatch error `Text` (shown conditionally) | `VarianceTypography.bodySmall` (12 sp), `error` |

- Digit dots: 14 dp diameter, 12 dp gap
- Keypad key size: 72 dp × 72 dp, `OutlineButton` shape with `StadiumBorder`
- Keypad label style: `VarianceTypography.numericLarge` (24 sp), `onSurface`
- Auto-advance to confirm step on 6th digit (no explicit "Next" button)

#### 4.3.2 States

| State | Treatment |
|---|---|
| Entering first PIN | Dot indicator fills left-to-right |
| Entering confirm PIN | "Confirm your PIN" label; same keypad |
| Mismatch | Shake animation on dot row; error text shown; confirm field cleared |
| Match | Brief success indicator (checkmark, 500 ms); screen dismissed |
| Cancelled (back) | No PIN saved; return to caller |

#### 4.3.3 Change PIN — Additional Step (mode=change)

| Step | Component | Detail |
|---|---|---|
| 0 (prepended) | "Enter current PIN" step | Same keypad; validates against stored hash before proceeding |
| 0a wrong PIN | Inline error: "Incorrect PIN" | Clears entry; retry |

### 4.4 PIN Entry Screen / Overlay

| Field | Value |
|---|---|
| Route | `/settings/security/pin-entry` (also rendered as overlay in `AccountDetailScreen`) |
| Scaffold | Full-screen overlay (`ColoredBox` + content column) OR inline overlay widget |
| AppBar | None |
| Scroll | None |
| FAB | None |
| Transition | Fade in |

#### 4.4.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Top | Label: "Enter your PIN" | `VarianceTypography.bodyLarge` (16 sp), `onSurface` |
| Center | 6-dot masked PIN indicator row | same spec as §4.3.1 |
| Center | Attempts remaining indicator (shown after first failure) | `VarianceTypography.bodySmall` (12 sp), `warningAmount` |
| Center | Custom numeric keypad grid (3×4) | same spec as §4.3.1 |
| Bottom | "Forgot PIN" `TextButton` | `primary`, `VarianceTypography.bodySmall` (12 sp) |

- Auto-submit on 6th digit
- Shake animation on wrong PIN

#### 4.4.2 States

| State | Treatment |
|---|---|
| Idle | Keypad active; no attempt count shown |
| Wrong PIN | Shake on dot row; "Incorrect PIN. X attempts remaining." in `warningAmount`; field cleared |
| Lockout (5 failures) | "Too many attempts. Try again in 1:00:00." banner; keypad disabled; `error` role |
| Lockout expired | Keypad re-enabled; 5 new attempts |
| Wipe (15 failures) | "Sensitive data has been deleted." banner; `error` role; "OK" dismisses overlay |
| Success | Overlay dismissed; failure counter reset |

#### 4.4.3 Forgot PIN Flow Entry

| User Action | Result |
|---|---|
| Tap "Forgot PIN" | `AlertDialog`: "Resetting your PIN requires device authentication" + Confirm / Cancel |
| Confirm | Invoke `local_auth` device credential intent |
| Device auth success | Clear PIN hash; `pinEnabled = false`; navigate to `/settings/security/pin-setup` (`mode=create`) |
| Device auth fail | Return to PIN entry; no change |
| Device lock not configured | Informational `AlertDialog`: "Set up device security in Android Settings." |

---


## 5. Home Tab

### 5.1 Home Screen

| Field | Value |
|---|---|
| Scaffold | ShellRoute (persistent bottom nav) |
| AppBar | none — greeting and summary embedded in scrollable body |
| Scroll | CustomScrollView + SliverList (pinned month-selector + sliver transaction groups) |
| FAB | SpeedDial — bottom-right; 3 actions: Expense / Income / Transfer |
| Transition | default fade (tab switch); shared-element not applicable |

#### 5.1.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Greeting row | Text | `bodyLarge`, `onSurface` |
| Net Worth card | ElevatedCard (M3 `elevation=1`) | `surfaceContainerLow`; amount `numericLarge`, `onSurface` |
| Income card | ElevatedCard | `surfaceContainerLow`; amount `numericLarge`, `incomeAmount` |
| Expenses card | ElevatedCard | `surfaceContainerLow`; amount `numericLarge`, `expenseAmount` |
| Net card | ElevatedCard | `surfaceContainerLow`; amount `numericLarge`, color conditional: `incomeAmount` if positive, `expenseAmount` if negative, `onSurface` if zero |
| Summary card grid | 2×2 Row/Column layout | 8 dp gaps |
| Month selector | Row: IconButton(`chevron_left`) + Text + IconButton(`chevron_right`) | Text `bodyMedium`, `onSurface`; buttons `onSurfaceVariant` |
| Alerts strip | Card (`outlined` variant, `elevation=0`) | `outline` border; content `bodySmall`, `onSurfaceVariant`; action TextButton `primary` |
| Recurring catch-up banner | FilledCard (`surfaceContainerHigh`) | `bodySmall`; CTA TextButton `primary` |
| Date group header | SliverPersistentHeader (not pinned) | `sectionHeading`... wait — Text `bodyMedium` bold, `onSurfaceVariant`, left-aligned, 8 dp vertical padding |
| Transaction row | ListTile (3-zone custom layout — see §5.1.2) | — |
| SpeedDial FAB | FloatingActionButton.extended collapsed; expands to 3 SmallFABs with labels | `primaryContainer` / `onPrimaryContainer` per M3 SpeedDial anatomy |
| Staleness banner | Banner (M3 MaterialBanner) | `warningAmount` tinted surface; `bodySmall`; dismiss action |
| FX disclaimer | Inline Text below net worth amount | `bodySmall`, `onSurfaceVariant` |

#### 5.1.2 Transaction Row (3-Column ListTile)

| Column | Widget | Token |
|---|---|---|
| Leading (C1) | Column: Icon(categoryIcon, size 24) + Text(parentName) [row 1]; Text(subcategoryName) [row 2, if present] | Icon `onSurfaceVariant`; name `bodySmall`, `onSurfaceVariant` |
| Title/Subtitle (C2) | Row 1: Text(title) — `bodyLarge`, `onSurface`; Row 2: Text(accountInfo) — `bodySmall`, `onSurfaceVariant` | — |
| Trailing (C3) | Column: Text(amount + symbol) [row 1]; Text(fxEquivalent) [row 2, foreign only] | Row 1 `numericMedium`, color: `incomeAmount` / `expenseAmount` / `onSurface`; Row 2 `numericSmall`, `onSurfaceVariant` |
| Pending badge | Badge overlay on C1 icon | `tertiary` / `onTertiary`; `label` |

- Swipe left → delete: DismissibleWidget, red `errorContainer` background, `Icons.delete_outline`.
- Swipe right → edit: green `secondaryContainer` background, `Icons.edit_outlined`.
- Long-press → ModalBottomSheet with ListTiles: Edit / Delete.

#### 5.1.3 SpeedDial Anatomy (M3)

| Element | Spec |
|---|---|
| Collapsed state | FAB large, icon `Icons.add`, `primaryContainer` |
| Expanded state | Scrim overlay `scrim`; 3 SmallFABs stacked above anchor with text labels right-aligned |
| Action: Expense | Icon `Icons.arrow_upward`, label "Expense", `errorContainer` / `onErrorContainer` |
| Action: Income | Icon `Icons.arrow_downward`, label "Income", `secondaryContainer` / `onSecondaryContainer` |
| Action: Transfer | Icon `Icons.swap_horiz`, label "Transfer", `tertiaryContainer` / `onTertiaryContainer` |
| Dismiss | Tap scrim or FAB again |

#### 5.1.4 States

| State | Treatment |
|---|---|
| loading | Skeleton shimmer: greeting line 120 dp, 4 card placeholders 80 dp each, 6 row placeholders |
| empty (no txns) | Abstract geometric illustration (theme-colored) + Text("No transactions this month", `bodyLarge`, `onSurfaceVariant`) + SpeedDial visible |
| error | ErrorCard (`errorContainer`) + retry FilledButton |
| stale FX | MaterialBanner above net worth card: warning icon + "Exchange rate may be outdated" + Dismiss TextButton |
| no FX rate | Net worth card shows "—" with disclaimer `bodySmall` footnote |
| future month | Pending transactions: muted `onSurfaceVariant` styling, "Pending" Badge on each row; summary shows projected label |
| nominal | Full layout as described in §5.1.1 |

---

### 5.2 Exchange Rate Detail Screen

| Field | Value |
|---|---|
| Scaffold | Modal push (full-screen, part of transaction entry flow) |
| AppBar | SmallTopAppBar — title "Exchange Rate", back arrow |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | push |

#### 5.2.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Rate display | Text (large) | `displayLargeAmount` (36 sp), `onSurface` |
| Currency pair label | Text | `bodyMedium`, `onSurfaceVariant` |
| Last updated row | Row: Icon(`schedule`) + Text(datetime) | `bodySmall`, `onSurfaceVariant` |
| Source row | Row: Icon(`info_outline`) + Text("Sourced from …") | `bodySmall`, `onSurfaceVariant` |
| Override toggle | SwitchListTile | `primary` active color |
| Override input field | OutlinedTextField | `bodyLarge`; visible only when override toggle is on |
| Apply button | FilledButton full-width | `primary` |
| Staleness warning | Card (`warningAmount` tinted, `outlined`) | `bodySmall` |

#### 5.2.2 States

| State | Treatment |
|---|---|
| loading | Skeleton shimmer: rate line + metadata rows |
| fetched | Rate + metadata + optional override section |
| stale (>14 days) | `warningAmount`-tinted Card above rate: "Rate is X days old" |
| never fetched | Placeholder "—" + info Card: "Rate unavailable" |
| override active | Override input visible; Apply button enabled |
| error | ErrorCard + retry TextButton |

---

### 5.3 Color Scheme Preview Screen

| Field | Value |
|---|---|
| Scaffold | Push from Appearance Settings |
| AppBar | SmallTopAppBar — title "Color Preview", back arrow |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | push |

#### 5.3.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Scheme name | Text | `sectionHeading`, `onSurface` |
| Color swatch grid | Wrap of ColorSwatch items (48×48 dp rounded squares) | All `ColorScheme` roles: `primary`, `secondary`, `tertiary`, `error`, surface variants |
| Sample card | Card with title + subtitle + button | Demonstrates `surface`, `onSurface`, `primary` |
| Sample transaction row | Mock ListTile | `incomeAmount` / `expenseAmount` on trailing amount |
| Apply button | FilledButton | `primary` |

#### 5.3.2 States

| State | Treatment |
|---|---|
| nominal | Swatches + sample components rendered |
| applied | Checkmark badge on scheme + Snackbar "Theme applied" |

---

### 5.4 Warning Dialogs

#### 5.4.1 Duplicate Transaction Warning

| Field | Value |
|---|---|
| Component | AlertDialog (M3) |
| Trigger | Duplicate detection on Save in Create/Edit screen |

| Element | Spec |
|---|---|
| Icon | `Icons.content_copy`, `warningAmount` |
| Title | "Possible duplicate" |
| Body | "A similar transaction was found: [title], [amount], [date]. Save anyway?" |
| Actions | TextButton "Cancel" + FilledButton "Save Anyway" |
| Dismiss | Tap outside → Cancel |

#### 5.4.2 Large Transaction Warning

| Field | Value |
|---|---|
| Component | AlertDialog (M3) |
| Trigger | Amount exceeds configured large-transaction threshold on Save |

| Element | Spec |
|---|---|
| Icon | `Icons.warning_amber`, `warningAmount` |
| Title | "Large transaction" |
| Body | "This transaction of [amount] is above your [threshold] limit. Confirm?" |
| Actions | TextButton "Cancel" + FilledButton "Confirm" |
| Dismiss | Tap outside → Cancel |

#### 5.4.3 Overdraft Warning

| Field | Value |
|---|---|
| Component | AlertDialog (M3) |
| Trigger | Expense would bring account balance below zero (or configured overdraft limit) |

| Element | Spec |
|---|---|
| Icon | `Icons.account_balance_wallet`, `expenseAmount` |
| Title | "Insufficient balance" |
| Body | "This expense would leave [Account] at [projected balance]. Proceed?" |
| Actions | TextButton "Cancel" + FilledButton "Proceed" |
| Dismiss | Tap outside → Cancel |

---

## 6. Transaction Screens & Flows

### 6.1 Transaction Detail Screen

| Field | Value |
|---|---|
| Scaffold | Full-screen push from transaction row tap |
| AppBar | SmallTopAppBar — title "Transaction", back arrow, 3-dot overflow menu |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | push |

#### 6.1.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Type badge | AssistChip or FilledChip | "Income" `secondaryContainer`; "Expense" `errorContainer`; "Transfer" `tertiaryContainer`; `label` |
| Amount | Text | `displayLargeAmount` (36 sp), color: `incomeAmount` / `expenseAmount` / `onSurface` |
| FX equivalent | Text (below amount) | `bodyMedium`, `onSurfaceVariant`; visible only if account currency ≠ home currency |
| Exchange rate row | InkWell ListTile — tappable | `bodySmall`, `onSurfaceVariant`; trailing `Icons.chevron_right`; navigates to Exchange Rate Detail |
| Date/time row | ListTile, leading `Icons.schedule` | `bodyMedium`, `onSurface` |
| Title row | ListTile, leading `Icons.title` | `bodyMedium`, `onSurface`; omitted if blank |
| Description row | ListTile, leading `Icons.notes` | `bodyMedium`, `onSurfaceVariant`; omitted if blank |
| Account info row | ListTile, leading `Icons.account_balance_wallet` | `bodyMedium`; expense: source name; income: destination name; transfer: "Src → Dst" |
| Category row | ListTile, leading category icon | `bodyMedium`; parent + subcategory if present |
| Fee breakdown rows | ListTile pair (Transfer amount / Fee amount) | `bodySmall`, `onSurfaceVariant`; visible for transfer-with-fee only |
| Photo carousel | PageView of ClipRRect image widgets, max 2 | Tap → full-screen PhotoViewer push |
| Delete photo button | IconButton overlay on each photo | `Icons.close`, `errorContainer` |
| Pending badge | Badge on type chip | `tertiary` / `onTertiary` |
| Voided badge | Badge on type chip | `outlineVariant` / `onSurfaceVariant` |
| 3-dot menu | PopupMenuButton — AppBar trailing | Items: Edit / Delete (conditionally shown) |

#### 6.1.2 States

| State | Treatment |
|---|---|
| loading | Skeleton shimmer: badge + large amount + 5 list-tile placeholders |
| populated (normal) | Full detail; 3-dot: Edit + Delete |
| populated (pending) | Full detail + Pending badge; 3-dot: Edit + Delete |
| populated (voided) | Full detail + Voided badge; 3-dot menu absent |
| error | ErrorCard + back TextButton |

---

### 6.2 Create Transaction Screen

| Field | Value |
|---|---|
| Scaffold | Full-screen modal (from SpeedDial or FAB tap) |
| AppBar | SmallTopAppBar — title dynamic ("New Expense" / "New Income" / "New Transfer"), close `Icons.close` leading |
| Scroll | SingleChildScrollView (form body) |
| FAB | none |
| Transition | modal-slide-up |

#### 6.2.1 Type Selector

| Component | Spec |
|---|---|
| Widget | SegmentedButton (M3) — 3 segments |
| Segments | Expense / Income / Transfer |
| Default | Expense |
| Switching | Reloads field sequence below; preserves Amount, Date, Title, Description if already entered |

#### 6.2.2 Components — Common Fields

| Zone | Component | Token / Role |
|---|---|---|
| Amount field | OutlinedTextField, large input | `displayHeroAmount` (48 sp) centered; numeric keyboard; `primary` focused border |
| FX estimate row | Text below amount | `bodySmall`, `onSurfaceVariant`; "≈ [amount] [homeCurrency]"; hidden when currencies match |
| FX stale warning | Row: Icon(`warning_amber`) + Text | `warningAmount`; `bodySmall` |
| FX unavailable | Text | `bodySmall`, `onSurfaceVariant`; "Exchange rate unavailable" |
| Account picker field | OutlinedTextField (read-only, tap to open AccountPicker sheet) | `bodyLarge`; leading account icon; trailing `Icons.expand_more` |
| Category picker field | OutlinedTextField (read-only, tap to open CategoryPicker sheet) | `bodyLarge`; leading category icon; trailing `Icons.expand_more` |
| Subcategory picker field | OutlinedTextField (read-only) | Same as category; conditionally shown when parent category selected; `bodyLarge` |
| Date/time field | OutlinedTextField (tap to open DatePicker + TimePicker dialogs) | `bodyLarge`; leading `Icons.calendar_today` |
| Title field | OutlinedTextField | `bodyLarge`; optional badge `bodySmall` |
| Description field | OutlinedTextField multiline | `bodyLarge`; max lines 4; char count in helper text |
| Photo attachment row | Row of ClipRRect thumbnails (48×48) + `Icons.add_photo_alternate` button | Max 2 photos |
| Save button | FilledButton full-width | `primary`; disabled when required fields empty |
| Inline warning card | Card (`warningAmount` tinted, `outlined`) | `bodySmall`; actions TextButton pair |

#### 6.2.3 Components — Transfer-Specific

| Zone | Component | Token / Role |
|---|---|---|
| Source account field | OutlinedTextField (picker) | Same as common account picker |
| Destination account field | OutlinedTextField (picker) | Enabled only after source selected; disabled + helper "Select source first" otherwise |
| Fee panel | ExpansionTile (collapsed by default) | Title "Transfer fee (optional)", `bodyMedium` |
| Fee mode toggle | SegmentedButton: Flat / % | Inside fee panel |
| Fee amount field | OutlinedTextField | `bodyLarge`, numeric |
| Fee category picker | OutlinedTextField (picker) | Mirrors category picker |

#### 6.2.4 Inline Warning Cards

| Warning | Color | Actions |
|---|---|---|
| Overdraft | `expenseAmount` tinted Card | "Proceed" FilledButton + "Edit amount" TextButton |
| Credit limit exceeded | `warningAmount` tinted Card | "Proceed" FilledButton + "Edit" TextButton |
| Stale FX | `warningAmount` tinted row | Informational only |
| No FX rate | `onSurfaceVariant` text row | Informational only |

#### 6.2.5 Back / Discard Flow

| Setting | Dialog |
|---|---|
| Ask before discarding (default) | AlertDialog: "Discard changes?" — TextButton "Keep editing" + FilledButton "Discard" |
| Auto-save as draft | No dialog; Snackbar "Draft saved" |
| Discard immediately | No dialog |

#### 6.2.6 States

| State | Treatment |
|---|---|
| initial (empty) | Type selector + blank fields; Save button disabled |
| partially filled | Inline validation errors on blur; Save enabled when required fields valid |
| warning active | Inline warning card rendered above Save; Save remains tappable |
| saving | Save button replaced with CircularProgressIndicator (M3 `ButtonLoading`) |
| saved | Modal dismissed; parent list refreshes |
| save error | Snackbar `error` role: "Failed to save. Try again." |
| draft restored | Fields pre-populated; banner: "Restoring draft" + `bodySmall` |
| future date | AlertDialog info: "Held as pending until [date]." → OK |

---

### 6.3 Create Recurring Template Screen

| Field | Value |
|---|---|
| Scaffold | Full-screen modal |
| AppBar | SmallTopAppBar — title "New Recurring Template", close `Icons.close` |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | modal-slide-up |

#### 6.3.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Type selector | SegmentedButton: Expense / Income / Transfer | Same as §6.2.1; immutable after save |
| Amount field | OutlinedTextField, `displayHeroAmount` | Required; numeric |
| Account picker(s) | OutlinedTextField(s) (read-only, tap to open picker) | Immutable label badge `bodySmall` on field after save |
| Category picker | OutlinedTextField (read-only) | Expense/Income only |
| Title / Description | OutlinedTextField(s) | Optional |
| Recurrence N field | OutlinedTextField, numeric | Required; `bodyLarge` |
| Recurrence unit picker | DropdownMenu: day / week / month / year | `bodyLarge`; M3 DropdownMenu anatomy |
| Recurrence constraints | FilterChips row (Weekdays only / Weekends only / Start of month / End of month) | `accentPastel` selected tint; `chipText`; horizontal scroll |
| Start date field | OutlinedTextField (tap → DatePicker) | Required; default today |
| End date field | OutlinedTextField (tap → DatePicker) | Optional; "No end date" toggle SwitchListTile |
| Posting behaviour toggle | SegmentedButton: Auto-post / Remind & confirm | `bodyMedium` |
| Transfer fee panel | ExpansionTile | Same as §6.2.3; collapsed by default |
| First occurrence preview | Card (`surfaceContainerLow`) — "First occurrence: [date]" | `bodySmall`, `onSurfaceVariant`; live-computed |
| Immutable field info chip | Chip with `Icons.lock_outline` + "Cannot be changed after saving" | `bodySmall`, `onSurfaceVariant`; shown on IM fields |
| Save button | FilledButton full-width | `primary` |

#### 6.3.2 States

| State | Treatment |
|---|---|
| empty | All fields blank; Save disabled |
| filled | First occurrence preview visible; Save enabled |
| saving | Save button loading |
| saved | Modal dismissed; Snackbar "Recurring template saved" |

---

### 6.4 Create Installment Screen

| Field | Value |
|---|---|
| Scaffold | Full-screen modal |
| AppBar | SmallTopAppBar — title "New Installment Plan", close `Icons.close` |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | modal-slide-up |

#### 6.4.1 Components — Additional (beyond §6.3.1)

| Zone | Component | Token / Role |
|---|---|---|
| Total amount field | OutlinedTextField, `displayHeroAmount` | Required; immutable label badge after save |
| Number of installments field | OutlinedTextField, numeric | Required |
| Per-installment amount | OutlinedTextField (auto-calculated, overridable) | `bodyLarge`; helper "Auto: total ÷ count" |
| End date display | Text (read-only) | `bodyMedium`, `onSurfaceVariant`; "Ends: [computed date]" |
| Total mismatch warning | Card (`warningAmount` tinted) | `bodySmall`; visible when sum of manual per-installment ≠ total |

#### 6.4.2 States

| State | Treatment |
|---|---|
| empty | Blank fields; Save disabled |
| filled | End date computed and shown; Save enabled |
| total mismatch | Warning card above Save button; Save still enabled (non-blocking) |
| saving | Loading state |
| saved | Modal dismissed; Snackbar "Installment plan saved" |

---
### 6.5 Edit Transaction Screen

| Field | Value |
|---|---|
| Scaffold | Full-screen modal push from Detail screen or swipe-right action |
| AppBar | SmallTopAppBar — title "Edit Transaction", close `Icons.close` |
| Scroll | SingleChildScrollView |
| FAB | none |
| Transition | push (from detail) / shared-element (from list swipe) |

#### 6.5.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Correction indicator badge | Badge or OutlinedChip on financial fields | `Icons.edit_note`; `tertiaryContainer`; `bodySmall` "Changing will create correction entries" |
| Amount field | OutlinedTextField `displayHeroAmount` | Pre-filled; correction badge if posted |
| Account picker(s) | OutlinedTextField (picker) | Pre-filled; correction badge if posted |
| Category picker | OutlinedTextField (picker) | Pre-filled; correction badge if posted; soft-deleted category shown as top option with strikethrough |
| Date/time field | OutlinedTextField (DatePicker + TimePicker) | Pre-filled; IP — no ledger effect |
| Title field | OutlinedTextField | Pre-filled; IP |
| Description field | OutlinedTextField multiline | Pre-filled; IP |
| Photos row | Thumbnails + add button | IP; delete per photo |
| Correction notice card | Card (`tertiaryContainer`, `outlined`) | `bodySmall`; "Editing financial fields will record a correction. Original entry remains hidden." |
| Save button | FilledButton full-width | `primary` |

#### 6.5.2 Field Edit Modes

| Field | Mode | Badge |
|---|---|---|
| Amount | Ledger Edit (LE) — posted | Correction indicator |
| Account | LE — posted | Correction indicator |
| Category / Subcategory | LE — posted | Correction indicator |
| Date / Time | In-place (IP) | None |
| Title / Description / Photos | IP | None |
| All fields (pending) | In-place (no correction model) | None |

#### 6.5.3 States

| State | Treatment |
|---|---|
| loading | Skeleton shimmer |
| loaded (posted) | Fields pre-filled; LE fields show correction badge; correction notice card visible |
| loaded (pending) | Fields pre-filled; no badges; no correction card |
| saving | Save button loading |
| saved | Modal dismissed; list shows final corrected version only |
| save error | Snackbar `error`: "Save failed. Try again." |

---
### 6.6 Filter Bottom Sheet

| Field | Value |
|---|---|
| Scaffold | ModalBottomSheet (M3 DraggableScrollableSheet) |
| AppBar | drag handle + Row: Text("Filters", `sectionHeading`) + TextButton "Reset" |
| Scroll | DraggableScrollableSheet — min 50%, max 95% screen height |
| FAB | none |
| Transition | modal-slide-up |

#### 6.6.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Drag handle | Container 32×4 dp, `outlineVariant`, rounded, centered | M3 bottom sheet handle |
| Type toggle row | FilterChip row: Income / Expense / Transfer (multi-select) | `accentPastel` selected fill; `chipText` |
| Category picker section | Heading + multi-select OutlinedTextField (tap to open sub-sheet) | `bodyMedium`, `onSurfaceVariant` |
| Subcategory picker section | Same as category; shown only after category selected | — |
| Account picker section | Multi-select OutlinedTextField | Same pattern |
| Date range section | FilterChip row: presets + DateRangePicker for "Custom" | Preset chips `accentPastel`; custom activates DatePicker dialogs |
| Amount range section | Row: OutlinedTextField (Min) + Text("–") + OutlinedTextField (Max) | `bodyLarge`; numeric; both optional |
| Boolean toggles section | SwitchListTile rows: Has photo / Has title / Has description / Is recurring / Is voided | `primary` active color |
| Sort section | SegmentedButton rows: Date (desc/asc) + Amount (desc/asc) | `bodyMedium` |
| Match count | Text above Apply button | `bodySmall`, `onSurfaceVariant`; "X matching transactions"; live-updated |
| Apply button | FilledButton full-width | `primary` |
| Reset button | TextButton in header | `primary` |

#### 6.6.2 Active Filter Chip Strip (above list)

| Component | Spec |
|---|---|
| Strip container | Horizontal ScrollView, no scrollbar |
| Filter chip | InputChip (M3): label = criterion summary + `Icons.close` trailing | `accentPastel` fill; `chipText` |
| "Clear all" chip | InputChip: label "Clear all", `Icons.close` | `errorContainer` / `onErrorContainer`; `chipText` |

#### 6.6.3 States

| State | Treatment |
|---|---|
| no filters | All toggles off; presets unselected; Apply enabled (applies empty = clears) |
| filters active | Active fields highlighted; match count shown |
| applied | Sheet dismissed; chip strip renders above list |
| 0 results | Chip strip visible; list shows empty state: "No transactions match your filters." + FilledButton "Clear filters" |
| reset | All criteria cleared; sheet stays open; match count shows total count |

---
### 6.7 Search Overlay

| Field | Value |
|---|---|
| Scaffold | Overlay within Home ShellRoute (SearchBar expands, not full-screen push) |
| AppBar | SmallTopAppBar replaced by SearchBar (M3) — full-width, leading back `Icons.arrow_back`, trailing `Icons.close` |
| Scroll | CustomScrollView — search results grouped by date |
| FAB | hidden while search active |
| Transition | SearchBar expand animation (M3 SearchBar → SearchView pattern) |

#### 6.7.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| SearchBar | M3 SearchBar — `surfaceContainerHigh`, `bodyLarge`, `onSurface` | Leading `Icons.search`; trailing `Icons.close` (visible on non-empty query) |
| Search results list | SliverList of date-grouped transaction rows | Same 3-column layout as §5.1.2; `bodyMedium` matched text highlighted via `RichText` / `TextSpan` with `primary` color bold |
| Highlighted match spans | TextSpan (`primary`, bold weight) within title and account name | `bodyLarge` / `bodySmall` respective |
| Filter icon button | IconButton `Icons.filter_list` — AppBar trailing | Opens Filter Sheet on top of search results |
| Filter chip strip | Same as §6.6.2 | Shown below SearchBar when filter active |
| No results state | Text("No transactions found for '[query]'", `bodyLarge`, `onSurfaceVariant`) centered | — |
| Empty query hint | Text("Search transactions", `bodyMedium`, `onSurfaceVariant`) centered | Visible when query is empty and search is active |

#### 6.7.2 Search Ranking Display Order

| Rank | Match type | Visual indicator |
|---|---|---|
| 1 | Exact title / account match | — |
| 2 | Prefix title / account match | — |
| 3 | Substring title / account match | — |
| 4 | Exact amount match | — |
| 5 | Category / subcategory match | Category name also highlighted |
| 6 | Description / date match | — |

- Results grouped by date descending regardless of rank within the same date group.
- Typo-tolerant (1–2 character transpositions); no visual indicator for fuzzy match.

#### 6.7.3 States

| State | Treatment |
|---|---|
| idle | SearchBar shows in AppBar; not focused |
| active empty | SearchBar focused; hint text "Search transactions"; list hidden |
| typing | Results list live-updates (debounced 300 ms); global scope — all dates |
| results | Date-grouped list; matched text highlighted |
| no results | Empty state text: "No transactions found for '[query]'" |
| search + filter active | Filter chip strip below SearchBar; results = search ∩ filter |
| dismissed | SearchBar collapses; home list returns to selected month view |

---
### 6.8 Void / Soft-Delete Flows

#### 6.8.1 Single Delete Confirmation Dialog

| Element | Spec |
|---|---|
| Component | AlertDialog (M3) |
| Icon | `Icons.delete_outline`, `error` role |
| Title | "Delete transaction?" |
| Body (posted) | "This will reverse the transaction from your account balance." |
| Body (pending) | "This transaction has not been posted yet. Delete it?" |
| Actions | TextButton "Cancel" + FilledButton "Delete" (`error` / `onError`) |
| On confirm | Snackbar: "Transaction deleted. Undo." (5 s timeout, `undoAction` TextButton) |

#### 6.8.2 Bulk Delete Confirmation Dialog

| Element | Spec |
|---|---|
| Component | AlertDialog (M3) |
| Title | "Delete [N] transactions?" |
| Body | "This will reverse [N] transactions from your account balances. This cannot be undone." |
| Actions | TextButton "Cancel" + FilledButton "Delete [N]" (`error` / `onError`) |
| No undo | Snackbar: "[N] transactions deleted." (no undo action) |

#### 6.8.3 Bulk Selection Mode

| Component | Spec |
|---|---|
| Entry | Long-press any row → selection mode activates |
| Row state | Checkbox leading replaces category icon; `primaryContainer` highlight on selected row |
| AppBar (selection mode) | SmallTopAppBar replaced: leading `Icons.close` (exit), title "[N] selected", trailing `Icons.delete_outline` |
| Exit | Tap `Icons.close` or back → deselects all, normal mode |

#### 6.8.4 Snackbar Spec (Single Delete + Undo)

| Element | Spec |
|---|---|
| Component | M3 Snackbar |
| Text | "Transaction deleted." |
| Action | TextButton "Undo" |
| Duration | 5 seconds |
| Undo effect | Reversing entry removed; transaction reappears in list |

---
### 6.9 Warning Dialogs (Create / Edit — Inline & Modal)

#### 6.9.1 Duplicate Transaction Warning

| Element | Spec |
|---|---|
| Component | AlertDialog (M3) |
| Icon | `Icons.content_copy`, `warningAmount` |
| Title | "Possible duplicate" |
| Body | "A similar transaction already exists today ([amount], [category], [account]). Add anyway?" |
| Actions | TextButton "Cancel" + FilledButton "Add Anyway" |
| Trigger | Same type + amount + account + category on same calendar day |
| Always active | Yes — no user toggle |

#### 6.9.2 Large Transaction Warning

| Element | Spec |
|---|---|
| Component | AlertDialog (M3) |
| Icon | `Icons.warning_amber`, `warningAmount` |
| Title | "Large transaction" |
| Body | "This transaction of [amount] is above your threshold. Confirm?" |
| Actions | TextButton "Cancel" + FilledButton "Confirm" |
| Priority | Account threshold takes precedence over category threshold if both triggered |
| Trigger | Amount exceeds per-account (account's native currency) or per-category (home currency) threshold |

#### 6.9.3 Overdraft / Credit Limit Warning

| Element | Spec |
|---|---|
| Component | Inline warning Card (not dialog) — on Create/Edit form |
| Widget | Card (`outlined`, `errorContainer` tinted) inside form body |
| Icon | `Icons.account_balance_wallet`, `expenseAmount` |
| Overdraft body | "This transaction will result in a negative balance of [amount] for [Account]." |
| Credit limit body | "This transaction will exceed the credit limit of [limit] for [Card]. Outstanding will be [projected]." |
| Actions | FilledButton "Proceed" + TextButton "Edit amount" |
| Placement | Below amount field, above Save button |
| Not shown for | Auto-approved recurring catch-up transactions |

---

### 6.10 Transaction Flow Summary

| Flow | Entry Point | Screen(s) | Notes |
|---|---|---|---|
| Create Expense | SpeedDial "Expense" | Create Transaction (Expense type) | Default type on single FAB tap |
| Create Income | SpeedDial "Income" | Create Transaction (Income type) | — |
| Create Transfer | SpeedDial "Transfer" | Create Transaction (Transfer type) | Cross-currency blocked in v1 |
| Create Recurring | Settings > Recurring | Create Recurring Template | Separate entry point from normal create |
| Create Installment | Settings > Recurring | Create Installment Screen | Extends recurring template flow |
| View Detail | Transaction row tap | Transaction Detail | — |
| Edit Posted | Detail 3-dot / List swipe-right | Edit Transaction | Correction model for financial fields |
| Edit Pending | Detail 3-dot / List swipe-right | Edit Transaction | All fields in-place; no correction |
| Delete (single) | Swipe-left / 3-dot / Detail | Confirmation Dialog → Snackbar+Undo | 5-second undo window |
| Delete (bulk) | Long-press → selection mode | Bulk Delete Dialog | No undo |
| Filter | Filter icon in Home AppBar | Filter Bottom Sheet | Chips strip remains on list |
| Search | Search icon in Home AppBar | Search Overlay | Suspends month scope |
| Exchange Rate | Tap FX row in Detail | Exchange Rate Detail | Rate override available |


## 7. Accounts Tab

### 7.1 Screen: Account List

| Field | Value |
|---|---|
| Scaffold | ShellRoute tab body |
| AppBar | SmallTopAppBar — title "Accounts"; trailing: search icon |
| Scroll | CustomScrollView + SliverList |
| FAB | FAB(icon: add, label: "Add Account") |
| Transition | None (tab switch) |

#### 7.1.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Top card | M3 Card (FilledCard) — net worth total | `displayLargeAmount` (48sp) for total; `bodyMedium` label above |
| Net worth total | Text | `ColorScheme.onSurface`; multi-currency → `bodySmall` exchange note below |
| Staleness chip | M3 SuggestionChip — "Rate may be outdated" | `ColorScheme.errorContainer` / `ColorScheme.onErrorContainer` |
| Account row | M3 ListTile — 3 lines; leading: account type icon in `CircleAvatar` | — |
| Account name | ListTile.title | `bodyLarge` / `ColorScheme.onSurface` |
| Category badge | M3 SuggestionChip — tonal; category icon left | `chipText` / `accentPastel` surface |
| Balance | ListTile.trailing — right-aligned | `numericMedium`; positive → `ColorScheme.onSurface`; negative → `warningAmount` |
| Currency code | Text beside balance | `bodySmall` / `ColorScheme.onSurfaceVariant`; shown when ≥2 accounts share same symbol |
| Excluded section header | M3 ListTile — section divider text "Excluded from net worth" | `bodySmall` / `ColorScheme.onSurfaceVariant`; grayed |
| Excluded account row | Same ListTile; reduced opacity 0.5 | — |

#### 7.1.2 States

| State | Treatment |
|---|---|
| loading | Shimmer skeleton: 1 card-height block + 3–5 shimmer `ListTile` rows |
| empty | Abstract geometric illustration (theme-colored) + "No accounts yet" (`sectionHeading`) + "Add your first account to start tracking" (`bodyMedium`) + FilledButton "Add Account" |
| error | `ErrorCard` inline: "Could not load accounts. Tap to retry." + retry `TextButton` |
| nominal | Net worth `FilledCard` + account rows grouped (contributing / excluded) |

#### 7.1.3 Long-press Contextual Menu

| Action | Label |
|---|---|
| Primary | Edit |
| Secondary | Delete |
| Secondary | Reconcile |

---

### 7.2 Screen: Account Detail

| Field | Value |
|---|---|
| Scaffold | Push route `/accounts/:id` |
| AppBar | SmallTopAppBar — title = account name; trailing: edit icon, 3-dot menu |
| Scroll | CustomScrollView + SliverAppBar (collapsible hero) + SliverList |
| FAB | Conditional: Credit Card only — ExtendedFAB "Pay" |
| Transition | Push (slide-left) |

#### 7.2.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Hero header | Collapsible SliverAppBar expanded area | — |
| Account name | Text in SliverAppBar | `sectionHeading` / `ColorScheme.onSurface` |
| Category badge | SuggestionChip — tonal | `chipText` / `accentPastel` |
| Balance display | Text — current computed balance | `displayLargeAmount` (36sp); negative → `warningAmount` |
| History bar strip | Compact horizontal bar strip (12 bars, last 12 months) | `ColorScheme.primary` positive bars; `expenseAmount` negative bars; height 32dp; no labels |
| Net worth chip | M3 AssistChip — "Included in net worth" / "Excluded from net worth" | `ColorScheme.secondaryContainer` |
| CC statement row | M3 ListTile — "Statement balance" label + value | `numericMedium` |
| CC outstanding row | M3 ListTile — "Outstanding balance" label + value | `numericMedium` |
| Metadata section | M3 ListTile rows for category-specific fields; sensitive fields masked | `bodyMedium` |
| Reveal button | `TextButton` — "Reveal" beside masked field | Triggers biometric/PIN auth |
| Search bar | M3 SearchBar (docked, persistent) — filters transactions | `ColorScheme.surfaceContainerHigh` |
| Filter button | M3 IconButton (filter_list) — opens filter sheet | `ColorScheme.onSurface` |
| Transaction list | Identical 3-column layout to Home Tab (§6) scoped to this account | — |

#### 7.2.2 States

| State | Treatment |
|---|---|
| loading | Shimmer hero block (80dp height) + 3 shimmer `ListTile` rows |
| loaded-empty | Hero (name, badge, balance = 0) + abstract geometric illustration "No transactions yet" + `bodyMedium` subtext |
| loaded-populated | Hero + history strip + metadata + search bar + transaction list |
| credit-card | Loaded-populated + statement balance row + outstanding balance row + Pay FAB |
| error-not-found | Full-screen: "Account not found" (`sectionHeading`) + FilledButton "Go Back" |

#### 7.2.3 3-dot Menu Actions

| Action | Available when |
|---|---|
| Edit | Always |
| Delete | Always |
| Reconcile | Always |
| Edit Balance | Always |

---

### 7.3 Screen: Create Account

| Field | Value |
|---|---|
| Scaffold | Full-screen push route `/accounts/new` |
| AppBar | SmallTopAppBar — title "New Account"; leading: close icon (X) |
| Scroll | SingleChildScrollView |
| FAB | None |
| Transition | Modal slide-up |

#### 7.3.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Name field | M3 OutlinedTextField — label "Account name" | `bodyLarge` input; error state → `ColorScheme.error` |
| Category selector | M3 OutlinedTextField (read-only tap target) → opens ModalBottomSheet picker | `bodyLarge`; trailing: chevron icon |
| Currency field | M3 OutlinedTextField (read-only tap target) → opens full-screen Currency Picker | `bodyLarge`; highlighted border when ≠ home currency; trailing: lock icon (post-creation) |
| Currency immutability tooltip | M3 PlainTooltip — "Account currency cannot be changed after creation." | `bodySmall` / `ColorScheme.onSurfaceVariant` |
| Initial balance field | M3 OutlinedTextField — numeric; system keyboard | `bodyLarge`; leading: currency symbol |
| Include in net worth | M3 SwitchListTile | `bodyMedium` label |
| Notes field | M3 OutlinedTextField — multiline, max 3 visible lines | `bodyMedium` |
| Category-specific section | Animated expansion (AnimatedSize) — appears when category selected | — |
| Sensitive field (encrypted) | M3 OutlinedTextField — obscured; trailing: visibility toggle icon | `bodyMedium` |
| Section dividers | M3 Divider + section label | `bodySmall` / `ColorScheme.onSurfaceVariant` |
| Save button | M3 FilledButton full-width — "Save"; disabled until required fields filled | `buttonText` |
| Duplicate name error | Inline text below Name field | `bodySmall` / `ColorScheme.error` |

#### 7.3.2 Category-Specific Field Sections

Animated in when category selected. Fields per §8.3.4 of UX Flows.

| Category | Required fields | Optional fields |
|---|---|---|
| Cash | _(none beyond common)_ | — |
| Bank Account | Bank name | Account number (encrypted), Branch, IFSC |
| Credit Card | Billing date (day picker 1–28), Payment due date (day picker 1–28) | Card name, Card number (encrypted), Expiry date (MM/YY), Credit limit, Linked bank account |
| Debit Card | _(none beyond common)_ | Card name, Card number (encrypted), Expiry date (MM/YY), Linked bank account |
| Top-Up Wallet | _(none beyond common)_ | Wallet provider name, Linked phone number |
| Loan | _(none beyond common)_ | Lender/borrower name, Principal amount, Interest rate, EMI amount, EMI date, Due date |
| Investment | Investment type (FD / Mutual Fund / Stocks / PPF / NPS / Other) | Institution name, Current value |
| Other | _(none beyond common)_ | — |

#### 7.3.3 States

| State | Treatment |
|---|---|
| idle | Form; Save button disabled |
| category-selected | Category-specific section animates in (`AnimatedSize`, 250ms ease) |
| currency-non-default | Currency field border highlighted (`ColorScheme.primary` 2dp); tooltip visible |
| saving | `FilledButton` shows `CircularProgressIndicator` (size 20); form fields disabled |
| duplicate-name | Inline error under Name field; Save remains disabled |
| soft-deleted-match | `AlertDialog` — "Reinstate [name]?" — Yes (reinstate) / No (must rename) |
| error | `SnackBar` — "Failed to create account. Try again." |

#### 7.3.4 Currency Immutability Confirmation Dialog

| Element | Spec |
|---|---|
| Trigger | Save tapped when currency ≠ home currency |
| Title | "Confirm currency" |
| Body | "Your account will be created in [Currency]. This cannot be changed later." |
| Primary action | FilledButton "Confirm" → proceeds to save |
| Secondary action | TextButton "Cancel" → dismisses dialog |

#### 7.3.5 Post-Save Loan Suggestion Dialog

| Element | Spec |
|---|---|
| Trigger | Category = Loan AND (initial balance < 0 OR EMI amount/date filled) |
| Title | "Set up installment plan?" |
| Body | "Would you like to set up an installment plan for this loan?" |
| Primary action | FilledButton "Set up" → navigates to Create Installment screen (pre-filled) |
| Secondary action | TextButton "Skip" → dismisses |

---

### 7.4 Screen: Edit Account

| Field | Value |
|---|---|
| Scaffold | Full-screen push route `/accounts/:id/edit` |
| AppBar | SmallTopAppBar — title "Edit Account"; leading: back arrow |
| Scroll | SingleChildScrollView |
| FAB | None |
| Transition | Push (slide-left) |

#### 7.4.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Name field | M3 OutlinedTextField — pre-filled | `bodyLarge`; error on duplicate |
| Account category | M3 OutlinedTextField (read-only, no tap) — grayed; trailing: lock icon | `bodyLarge` / `ColorScheme.onSurfaceVariant` opacity 0.5 |
| Currency field | M3 OutlinedTextField (read-only, no tap); trailing: lock icon | `bodyLarge` / `ColorScheme.onSurfaceVariant` opacity 0.5; tap → `PlainTooltip` "Currency cannot be changed." |
| Initial balance | Not shown in edit form | — |
| Include in net worth | M3 SwitchListTile — pre-filled | `bodyMedium` |
| Notes | M3 OutlinedTextField — multiline, pre-filled | `bodyMedium` |
| Category-specific editable fields | Same OutlinedTextField components as Create; pre-filled | — |
| Immutable field lock tooltip | M3 PlainTooltip on tap of locked field | `bodySmall` |
| Save button | M3 FilledButton full-width — "Save"; enabled only when dirty | `buttonText` |

#### 7.4.2 Immutable Fields Treatment

| Field | Treatment |
|---|---|
| Account category | Read-only chip (no interactive tap target); lock icon; section note "Cannot be changed after creation" |
| Currency | Read-only text with lock icon; tap anywhere on field → PlainTooltip |
| Initial balance | Not rendered; section note "Balance changes via Edit Balance or Reconcile" |

#### 7.4.3 States

| State | Treatment |
|---|---|
| loading | Shimmer form — same height/layout as populated form |
| idle | Pre-filled form; Save button disabled (not dirty) |
| dirty | Save button enabled |
| saving | FilledButton shows `CircularProgressIndicator` (size 20); fields disabled |
| error | `SnackBar` — "Failed to save changes." |

---

## 8. Shared Components

### 8.1 Category Picker Sheet

| Field | Value |
|---|---|
| Scaffold | ModalBottomSheet — `DraggableScrollableSheet`; initial extent 0.6; max 0.92 |
| AppBar | Sheet drag handle only; no `AppBar` |
| Scroll | `DraggableScrollableSheet` inner `CustomScrollView` |
| FAB | None |
| Transition | Modal slide-up |

#### 8.1.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Sheet handle | M3 drag indicator bar (centered, 32×4dp) | `ColorScheme.onSurfaceVariant` |
| Sheet title | Text "Select Category" + tree label ("Income" / "Expense") | `sectionHeading` / `ColorScheme.onSurface` |
| Search bar | M3 SearchBar (docked) — auto-focused on open | `ColorScheme.surfaceContainerHigh` |
| Recents row | Horizontal scroll of up to 5 M3 SuggestionChips | `chipText` / `accentPastel` surface; category icon left |
| Recents label | Text "Recent" | `label` / `ColorScheme.onSurfaceVariant` |
| Parent category row | M3 ListTile — leading: category icon; trailing: chevron (if has children) | `bodyLarge` title; `bodySmall` subtitle (child count) |
| Expanded children | Indented `ListTile` rows (16dp left padding) | `bodyMedium`; `ColorScheme.onSurface` |
| "+ New category" button | M3 TextButton at list bottom | `buttonText` / `ColorScheme.primary`; leading: `+` icon |
| Inline create row | Animated expansion: icon picker chip + name `TextField` + confirm `IconButton` | `bodyMedium` |
| Icon picker trigger | M3 OutlinedButton with icon preview | Opens icon sub-sheet |
| Confirm icon button | M3 FilledTonalIconButton (check) | Enabled only when name non-empty + unique |
| Empty state | Inline text "No categories yet" + TextButton "Create category" | `bodyMedium` |
| No-results state | Inline text "No results for '[query]'" + TextButton "+ Create '[query]'" | `bodyMedium` |

#### 8.1.2 States

| State | Treatment |
|---|---|
| loading | Shimmer: 1 chip strip skeleton + 3–5 shimmer `ListTile` rows |
| recents-populated | Recents chip strip visible above full list |
| populated | Search bar + recents + scrollable two-level category list |
| search-active | Filtered flat list; parent then child matches |
| search-no-results | "No results" + "+ Create '[query]'" inline row |
| empty | "No categories yet" + "Create category" `TextButton` |
| inline-create | Inline row animates in at bottom; icon picker + name field + confirm |
| inline-create-error | Name field error border + "Name already exists" `bodySmall` error |

#### 8.1.3 Rules

| Rule |
|---|
| Soft-deleted categories hidden unless currently referenced by transaction being edited |
| Inline create → parent category only; subcategory creation only in Settings |
| Recents: up to 5 most recently used, by transaction type (income / expense) |
| Sheet title includes tree label: "Select Category — Income" / "Select Category — Expense" |

---

### 8.2 Payee Picker Sheet

| Field | Value |
|---|---|
| Scaffold | ModalBottomSheet — `DraggableScrollableSheet`; initial extent 0.5; max 0.85 |
| Transition | Modal slide-up |

#### 8.2.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Sheet handle | M3 drag indicator | `ColorScheme.onSurfaceVariant` |
| Sheet title | Text "Select Payee" | `sectionHeading` |
| Search bar | M3 SearchBar (docked) — auto-focused | `ColorScheme.surfaceContainerHigh` |
| Suggestion row | M3 ListTile — leading: `person_outline` icon; title: payee name | `bodyLarge` |
| "+ Use '[query]'" row | M3 ListTile — leading: `add` icon; title in primary color | `bodyLarge` / `ColorScheme.primary` |
| No results | Inline text "No results" + "+ Use '[query]'" row | `bodyMedium` |
| Recents/frequent header | Section label "Recent" | `label` / `ColorScheme.onSurfaceVariant` |

#### 8.2.2 States

| State | Treatment |
|---|---|
| loading | Shimmer 4–5 `ListTile` rows |
| suggestions | Recent/frequent payee list |
| search-active | Filtered suggestion list |
| no-results | "No results" + "+ Use '[query]'" inline create row |

---

### 8.3 Tag Picker Sheet

| Field | Value |
|---|---|
| Status | **Deferred — v2 only.** Not implemented in v1. |
| Scaffold | ModalBottomSheet (placeholder spec; not built) |

> No tag picker is specified for v1. This section is a placeholder for v2 planning.

---

### 8.4 Account Picker Sheet

| Field | Value |
|---|---|
| Scaffold | ModalBottomSheet — `DraggableScrollableSheet`; initial extent 0.55; max 0.85 |
| Transition | Modal slide-up |

#### 8.4.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Sheet handle | M3 drag indicator | `ColorScheme.onSurfaceVariant` |
| Sheet title | Context-aware: "Select Source Account" / "Select Destination Account" / "Select Account" | `sectionHeading` |
| Section header (by category) | Sticky M3 `SliverPersistentHeader` — category label | `bodySmall` / `ColorScheme.onSurfaceVariant` |
| Account row | M3 ListTile — leading: account type icon in `CircleAvatar`; title: name; subtitle: balance + currency code | `bodyLarge` title; `numericSmall` balance |
| Selected indicator | Trailing `Icons.check` | `ColorScheme.primary` |
| Excluded row | Same `ListTile` with `opacity 0.4`; not tappable when ineligible | — |
| Empty state | "No eligible accounts" + TextButton "Create account" | `bodyMedium` |

#### 8.4.2 States

| State | Treatment |
|---|---|
| loading | Shimmer 3–4 `ListTile` rows |
| populated | Account rows grouped by category; sticky section headers |
| transfer-filtered | Source account row excluded from destination list |
| empty | "No eligible accounts" + "Create account" `TextButton` |

#### 8.4.3 Rules

| Rule |
|---|
| Soft-deleted accounts excluded |
| Transfer destination excludes source account |
| Each row: name, category type, current balance (formatted with currency) |

---

### 8.5 Currency Picker (Full-Screen Modal)

| Field | Value |
|---|---|
| Scaffold | Full-screen modal route (not bottom sheet) |
| AppBar | SmallTopAppBar — title "Select Currency"; leading: back arrow |
| Scroll | CustomScrollView + SliverList |
| FAB | None |
| Transition | Modal slide-up |

#### 8.5.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Search bar | M3 SearchBar (docked, persistent top) — auto-focused | `ColorScheme.surfaceContainerHigh` |
| Pinned header | Section label "Popular" | `bodySmall` / `ColorScheme.onSurfaceVariant` |
| Popular row | M3 ListTile — leading: flag emoji or ISO code chip; title: currency name; trailing: ISO code | `bodyLarge` title; `bodyMedium` trailing |
| All currencies header | Section label "All currencies" | `bodySmall` / `ColorScheme.onSurfaceVariant` |
| Currency row | M3 ListTile — title: name; subtitle: code + symbol | `bodyLarge` title; `bodySmall` subtitle |
| Selected checkmark | Trailing `Icons.check` on currently selected row | `ColorScheme.primary` |
| Immutability note | M3 InfoCard below search bar (account creation only) — "Currency cannot be changed after creation." | `bodySmall` / `ColorScheme.onSurfaceVariant` surface |
| No results | Inline "No currencies match '[query]'" | `bodyMedium` |

#### 8.5.2 States

| State | Treatment |
|---|---|
| loading | Full-screen shimmer list |
| populated | Pinned popular currencies + all currencies alphabetically |
| search-active | Filtered list; fuzzy match on code, name, symbol |
| no-results | "No currencies match '[query]'" inline |

#### 8.5.3 Rules

| Rule |
|---|
| Popular currencies pinned at top: INR, USD, EUR, GBP, JPY |
| Current selection highlighted with trailing checkmark |
| Immutability tooltip note shown inline only from account creation context |
| Back / system back → dismisses without selection change |

---

### 8.6 Amount Entry

| Field | Value |
|---|---|
| Scaffold | Inline field within transaction entry forms (not a separate screen) |
| Keyboard | System numeric keyboard (`TextInputType.numberWithOptions(decimal: true, signed: false)`) |

#### 8.6.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Amount field | M3 OutlinedTextField — label "Amount"; leading: currency symbol | `numericLarge` (24sp) input text |
| Placeholder | "0.00" | `ColorScheme.onSurfaceVariant` |
| Expression input | Same field; expression shown verbatim as typed | `numericLarge` |
| Error state | Field border → `ColorScheme.error`; helper text "Invalid expression" | `bodySmall` / `ColorScheme.error` |
| Home-currency estimate | Helper text below field: "≈ [amount] [home currency]" | `bodySmall` / `ColorScheme.onSurfaceVariant`; shown when account currency ≠ home currency |
| Evaluated result | Expression replaced by formatted decimal | `numericLarge` / `ColorScheme.onSurface` |

#### 8.6.2 States

| State | Treatment |
|---|---|
| empty | Placeholder "0.00"; no helper text |
| active | System keyboard open; expression typed verbatim |
| evaluated | Formatted decimal result; home-currency estimate helper (if applicable) |
| error | Error border; "Invalid expression" helper; form Save blocked |
| validated | Valid amount; home-currency estimate visible if cross-currency |

#### 8.6.3 Rules

| Rule |
|---|
| System keyboard only — no custom numpad |
| Supported operators: `+`, `−`, `×`, `÷`, `(`, `)` |
| Evaluation on "Done" / "Next" IME action |
| Locale-aware decimal separator (per Settings) |
| Must be > 0; result truncated (not rounded) to currency decimal precision |
| Expression evaluation is fully client-side |

---

### 8.7 Photo Attachment Chooser Sheet

| Field | Value |
|---|---|
| Scaffold | ModalBottomSheet — fixed height (not scrollable); action list only |
| Transition | Modal slide-up |

#### 8.7.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Sheet handle | M3 drag indicator | `ColorScheme.onSurfaceVariant` |
| Sheet title | Text "Add Photo" | `sectionHeading` |
| Camera option | M3 ListTile — leading: `Icons.camera_alt`; title "Camera" | `bodyLarge` |
| Gallery option | M3 ListTile — leading: `Icons.photo_library`; title "Gallery" | `bodyLarge` |
| Cancel option | M3 ListTile — leading: `Icons.close`; title "Cancel" | `bodyLarge` / `ColorScheme.error` |
| Full tooltip | M3 PlainTooltip — "Maximum 2 photos per transaction" when button disabled | `bodySmall` |
| Thumbnail preview | M3 Card with `Image.file` (80×80dp); trailing remove `IconButton` | Shown inline in form after attachment |
| Remove icon | `Icons.close` on thumbnail | `ColorScheme.error` |

#### 8.7.2 States

| State | Treatment |
|---|---|
| chooser | Camera / Gallery / Cancel action rows |
| full (2 photos) | "Add photo" button disabled; `PlainTooltip` on tap |
| loading (post-capture) | Thumbnail slot shows `CircularProgressIndicator` during compression |
| preview-1-photo | One 80×80dp thumbnail + remove icon |
| preview-2-photos | Two thumbnails side by side; "Add photo" button hidden |

#### 8.7.3 Rules

| Rule |
|---|
| Max 2 photos per transaction |
| Photos stored in app-private storage; not exposed to OS gallery |
| Compression applied before storage |
| Photos deleted permanently when transaction is soft-deleted |
| Each thumbnail tap → Photo Viewer (§8.8) |

---

### 8.8 Photo Viewer

| Field | Value |
|---|---|
| Scaffold | Full-screen overlay (push route or `Navigator.push` over current route) |
| AppBar | Translucent `SmallTopAppBar` — leading: back arrow; trailing: delete `IconButton` |
| Scroll | `PageView` (swipe between photos when 2 attached) |
| Transition | Fade or shared-element (hero transition from thumbnail) |

#### 8.8.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Background | `Colors.black` full-screen | — |
| Photo | `InteractiveViewer` wrapping `Image.file` — pinch-to-zoom | Max scale 4×; min scale 1× |
| Top bar | Translucent `AppBar` — back + delete icons | `Colors.white` icons over dark overlay |
| Delete icon | `Icons.delete_outline` | `Colors.white` |
| Page indicator | Dot indicators (2 dots max) at bottom when 2 photos | `ColorScheme.primary` active; `Colors.white54` inactive |
| Loading state | Centered `CircularProgressIndicator` | `Colors.white` |
| Error state | Centered `Icons.broken_image` + "Photo unavailable" | `Colors.white70` |
| Delete confirm sheet | M3 ModalBottomSheet — title "Delete photo?"; FilledButton "Delete" (red); TextButton "Cancel" | `ColorScheme.error` for delete button |

#### 8.8.2 States

| State | Treatment |
|---|---|
| loading | Centered `CircularProgressIndicator` on black background |
| viewing | Full-screen photo; translucent top bar; page dots if 2 photos |
| delete-confirm | Bottom sheet "Delete photo?" with Delete / Cancel |
| error | Centered broken-image icon + "Photo unavailable" label |

#### 8.8.3 Rules

| Rule |
|---|
| Delete available only when accessed from transaction detail / edit (not read-only voided transactions) |
| Photo deletion is immediate and permanent |
| Swipe between photos when multiple attached (up to 2) |
| Pinch-to-zoom via `InteractiveViewer` |

---

### 8.9 Draft Auto-Save Indicator

| Field | Value |
|---|---|
| Scaffold | Inline UI within transaction entry form — not a separate screen |
| Placement | Persistent bottom area of form, above Save button |

#### 8.9.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Draft restored banner | M3 `MaterialBanner` — text "Draft restored"; action: TextButton "Discard" | `ColorScheme.secondaryContainer` background; `bodyMedium` text |
| Auto-save indicator | Subtle `bodySmall` text "Draft saved" with `Icons.cloud_done_outlined` (16dp) | `ColorScheme.onSurfaceVariant`; shown briefly after save (2s fade-out) |
| Discard button | `TextButton` "Discard" within the banner | `ColorScheme.error` |

#### 8.9.2 States

| State | Treatment |
|---|---|
| no-draft | No banner; no indicator visible |
| draft-restored | `MaterialBanner` at top of form — "Draft restored" + "Discard" action |
| auto-saved | Inline "Draft saved" + icon; fades out after 2 seconds |
| discarded | Banner dismissed; form fields cleared |

#### 8.9.3 Rules

| Rule |
|---|
| Draft triggered on back navigation or app backgrounding when any field is populated |
| One draft retained per transaction type (income / expense / transfer); new entry overwrites prior draft of same type |
| Draft includes all field values including partially entered amount expressions |
| No explicit "Save draft" button — auto-save only |
| No draft TTL — retained until discarded or successfully submitted |
| Draft not applied on edit flows (edits use persisted data) |


## 9. Settings Tab

### 9.1 Settings Hub

| Field | Value |
|---|---|
| Route | `/settings` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, no back arrow (tab root), "Settings" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push from tab tap |

#### 9.1.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section divider label | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Each settings group row | `ListTile` | `bodyLarge` title, `bodySmall` subtitle, `ChevronRight` trailing icon, `onSurfaceVariant` |
| Leading icon per row | `Icon` | M3 `onSurfaceVariant` |

#### 9.1.2 Section Groups (display order)

| # | Group label | Rows inside | Route |
|---|---|---|---|
| 1 | Personalisation | Appearance | `/settings/appearance` |
| 1 | Personalisation | Locale & Format | `/settings/locale` |
| 1 | Personalisation | Transaction Entry | `/settings/transaction-entry` |
| 1 | Personalisation | Warnings & Limits | `/settings/warnings` |
| 2 | Account | Profile | `/settings/profile` |
| 2 | Account | Security | `/settings/security` |
| 3 | Data | Accounts | `/settings/accounts` (deep-links to Accounts tab) |
| 3 | Data | Categories | `/settings/categories` |
| 3 | Data | Currency | `/settings/currency` |
| 3 | Data | Tags | `/settings/tags` |
| 3 | Data | Payees | `/settings/payees` |
| 3 | Data | Recurring & Installments | `/settings/recurring` |
| 3 | Data | Drafts | `/settings/drafts` |
| 4 | App | Backup & Data | `/settings/backup` |
| 4 | App | About | `/settings/about` |

#### 9.1.3 States

| State | Treatment |
|---|---|
| Loaded | Full sectioned list |

---

### 9.2 Appearance Settings

| Field | Value |
|---|---|
| Route | `/settings/appearance` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Appearance" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.2.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Theme row | `ListTile` + `SegmentedButton` trailing | `bodyLarge`; M3 `SegmentedButton` 3 segments: Light / Dark / System |
| Color scheme row | `ListTile` + `SegmentedButton` trailing | 3 segments: Dynamic / Custom / Catppuccin |
| Seed color picker row | `ListTile` + `ColorSwatch` trailing (44×44 dp tappable) | Shown only when Color scheme = Custom; hidden otherwise |
| Catppuccin flavour note | `ListTile` with subtitle only (no control) | `bodySmall`, `onSurfaceVariant`; "Auto-bound to theme: Light→Latte, Dark→Mocha" |
| Animations row | `ListTile` + `Switch` trailing | M3 `Switch`; `bodyLarge` title |
| Preview row | `ListTile` + `ChevronRight` trailing | Navigates to `/settings/appearance/preview` |
| Dynamic color unavailable banner | `Card` with `Icon(info_outline)` + `Text` | M3 `surfaceContainerLow`, `onSurfaceVariant`; shown conditionally |

#### 9.2.2 States

| State | Treatment |
|---|---|
| Loaded | All controls pre-filled from user preferences |
| Color scheme = Custom | Seed color picker row visible |
| Color scheme ≠ Custom | Seed color picker row hidden |
| Dynamic unavailable | Info `Card` replaces Dynamic segment (segment still present but auto-switches on selection) |

#### 9.2.3 Color Scheme Preview Sub-screen

| Field | Value |
|---|---|
| Route | `/settings/appearance/preview` |
| AppBar | `SmallTopAppBar`, back arrow, "Color Preview" |
| Scroll | `ListView` |
| FAB | none |

| Zone | Component | Token / Role |
|---|---|---|
| Swatch grid | `GridView` 2-col; each cell: `Container` (color fill) + `Text` label | M3 role names (`primary`, `secondary`, `tertiary`, `surface`, `onSurface`, etc.); `label` token 11 sp |
| Active scheme label | `Text` at top | `bodyMedium`, current mode name |

---

### 9.3 Locale & Format Settings

| Field | Value |
|---|---|
| Route | `/settings/locale` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Locale & Format" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.3.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Home currency row | `ListTile` + current value trailing + `ChevronRight` | Navigates to `/settings/currency` |
| Decimal separator | `ListTile` + `SegmentedButton` trailing | 2 segments: Comma / Period |
| Thousands grouping | `ListTile` + `SegmentedButton` trailing | 2 segments: Standard / Indian |
| Symbol placement | `ListTile` + `SegmentedButton` trailing | 2 segments: Prefix / Suffix |
| Symbol spacing | `ListTile` + `SegmentedButton` trailing | 2 segments: None / Space |
| Week start | `ListTile` + `SegmentedButton` trailing | 2 segments: Mon / Sun |
| Time format | `ListTile` + `SegmentedButton` trailing | 2 segments: 12h / 24h |
| Percentage precision | `ListTile` + `DropdownButton` trailing | 0 / 1 / 2 decimals |
| Format preview strip | `Card` at bottom | Shows live-formatted sample amount + date using current settings; `bodyMedium`, `surfaceContainerLow` |

#### 9.3.2 States

| State | Treatment |
|---|---|
| Loaded | All controls pre-filled; format preview updates live on every change |

---

### 9.4 Transaction Entry Settings

| Field | Value |
|---|---|
| Route | `/settings/transaction-entry` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Transaction Entry" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.4.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Description max length | `ListTile` + `DropdownButton` trailing | Options: 500 / 1000 / 2000 chars; `bodyLarge` title |
| Back button behaviour | `ListTile` group header + 3 `RadioListTile` rows | Ask / Auto-save / Discard; `bodyLarge` |
| Draft lifecycle info card | `Card` (`surfaceContainerLow`) + `Icon(info_outline)` + `Text` | Shown only when Auto-save selected; `bodySmall`, `onSurfaceVariant`; "Max 5 drafts. Oldest evicted silently when limit hit." |

#### 9.4.2 States

| State | Treatment |
|---|---|
| Loaded | Controls pre-filled |
| Back behaviour = Auto-save | Draft lifecycle info card visible |
| Back behaviour ≠ Auto-save | Info card hidden |

---

### 9.5 Warnings & Limits

| Field | Value |
|---|---|
| Route | `/settings/warnings` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Warnings & Limits" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.5.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Per-Account Limits row | `ListTile` + `ChevronRight` | Navigates to `/settings/warnings/accounts` |
| Per-Category Limits row | `ListTile` + `ChevronRight` | Navigates to `/settings/warnings/categories` |

#### 9.5.2 Per-Account Limits Sub-screen

| Field | Value |
|---|---|
| Route | `/settings/warnings/accounts` |
| AppBar | `SmallTopAppBar`, back arrow, "Account Spending Limits" |
| Scroll | `ListView` |
| FAB | none |

| Zone | Component | Token / Role |
|---|---|---|
| Account row — no limit set | `ListTile` + `Text("Not set")` trailing | `bodyLarge` title, `bodySmall` `onSurfaceVariant` trailing |
| Account row — limit set | `ListTile` + formatted amount trailing | `warningAmount` on trailing if balance nearing threshold |
| Tap to edit | `ListTile` tapped → expands inline `TextField` + confirm/clear actions | M3 `OutlinedTextField`; amount input; confirm: `IconButton(check)`; clear: `IconButton(close)` |

| State | Treatment |
|---|---|
| Empty | Abstract geometric + "No active accounts" copy |
| Populated | List of all active accounts with limit or "Not set" |

#### 9.5.3 Per-Category Limits Sub-screen

| Field | Value |
|---|---|
| Route | `/settings/warnings/categories` |
| AppBar | `SmallTopAppBar`, back arrow, "Category Spending Limits" |
| Scroll | `ListView` |
| FAB | none |

| Zone | Component | Token / Role |
|---|---|---|
| Category row — parent | `ListTile` leading icon, title, subtitle "Home currency only" | `bodyLarge`, `bodySmall` |
| Category row — no limit | Trailing `Text("Not set")` | `onSurfaceVariant` |
| Category row — limit set | Trailing formatted amount + ISO code | `bodyMedium`; `warningAmount` when threshold nearing |
| Tap to edit | Inline `TextField` expand same as account sub-screen | — |

| State | Treatment |
|---|---|
| Empty | Abstract geometric + "No expense categories" copy |
| Populated | Expense categories (parent + children) |

---

### 9.6 Profile Settings

| Field | Value |
|---|---|
| Route | `/settings/profile` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Profile" |
| Scroll | `ListView` |
| FAB | none; "Save" in AppBar actions (`TextButton`) |
| Transition | push |

#### 9.6.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Avatar section | Centred `CircleAvatar` (72 dp) + `IconButton(edit)` overlay | `primaryContainer` fill if no image; tap to open system image picker |
| Display name field | `OutlinedTextField` | `bodyLarge`; label "Display name (optional)"; single line; max 60 chars |
| Local-only info row | `ListTile` with subtitle | `Icon(lock_outline)`, `bodySmall` "Stored on-device only. Never uploaded." |
| Save button | `AppBar` trailing `TextButton` | Enabled when dirty; disabled otherwise; M3 `colorScheme.primary` |

#### 9.6.2 States

| State | Treatment |
|---|---|
| Loaded | Form pre-filled |
| Dirty | Save enabled |
| Saved | Snackbar "Profile updated" |

---

### 9.7 Security Settings

| Field | Value |
|---|---|
| Route | `/settings/security` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Security" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.7.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Scope clarification card | `Card` (`surfaceContainerLow`) + `Icon(shield_outlined)` + `Text` | `bodySmall`, `onSurfaceVariant`; "The lock protects sensitive account details (card numbers, account numbers). Core app features are always accessible." |
| Lock timeout row | `ListTile` + `DropdownButton` trailing | Options: Immediately / 30s / 1 min / 5 min |
| Biometric row | `ListTile` + `Switch` trailing | Shown only when biometrics enrolled |
| Change PIN row | `ListTile` + `ChevronRight` | Shown only when in-app PIN active; navigates to PIN change flow |
| PIN recovery info row | `ListTile` with subtitle | `Icon(help_outline)`, `bodySmall` "Forgot PIN? Use your device security to reset."; tappable → device security settings |
| Device lock notice | `ListTile` with subtitle | Shown when no in-app PIN; "Using device lock for sensitive field protection." |

#### 9.7.2 States

| State | Treatment |
|---|---|
| Loaded — in-app PIN active | Scope card + lock timeout + biometric toggle + Change PIN + PIN recovery rows |
| Loaded — no in-app PIN | Scope card + device lock notice; PIN rows hidden |

---

### 9.8 Category Management

| Field | Value |
|---|---|
| Route | `/settings/categories` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Categories" |
| Scroll | `TabBarView` inside `ListView` header |
| FAB | `FloatingActionButton` with `add` icon + label "Add Category" |
| Transition | push |

#### 9.8.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Tab bar | M3 `TabBar` 2 tabs: "Expense" / "Income" | `primaryContainer` indicator |
| Category row | `ListTile` leading `Icon` (category icon) + title + trailing `Text` (child count) | `bodyLarge` title; `bodySmall` child count `onSurfaceVariant` |
| Shimmer rows | `ShimmerWidget` × 6 | `surfaceContainerHighest` fill |
| Long-press contextual menu | `ModalBottomSheet` with `ListTile` actions | Edit / Delete / Add Child Category; Delete disabled if children exist |
| Error banner | M3 `Banner` + Retry `TextButton` | `errorContainer` |

#### 9.8.2 States

| State | Treatment |
|---|---|
| Loading | Shimmer list |
| Loaded — empty | Abstract geometric + "No categories yet" + FilledButton "Add Category" |
| Loaded — populated | Tabbed list; FAB always visible |
| Error | Inline error banner + Retry |

#### 9.8.3 Behaviour Notes

- "Balance Adjustment" category is hidden from this screen (system-protected).
- Delete action on parent category with children: menu item disabled; `Tooltip` "Remove all subcategories first."

---

### 9.9 Category Detail / Edit

| Field | Value |
|---|---|
| Route | `/settings/categories/:id` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Edit Category" / "New Category" |
| Scroll | `ListView` |
| FAB | none; Save in AppBar actions |
| Transition | push |

#### 9.9.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Icon picker row | `ListTile` + `Icon` trailing (current icon, 32 dp) | Tappable; opens icon picker `ModalBottomSheet` |
| Icon picker sheet | `GridView` of ~250 `material_symbols_icons` items; search `TextField` at top | `IconButton` cells, 48 dp touch target each |
| Name field | `OutlinedTextField` | `bodyLarge`; label "Category name"; real-time uniqueness validation |
| Parent label row | `ListTile` with subtitle (read-only) | Shown for child categories only; `bodySmall` "Parent: [name]" |
| Subcategory section header | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Subcategory row | `ListTile` icon + name | Long-press → Edit / Delete contextual menu |
| Add subcategory button | `OutlinedButton` with `add` icon | "Add subcategory"; navigates to new category screen (pre-set parent) |
| No subcategories empty | `Text` + `OutlinedButton` | `bodySmall` "No subcategories" + "Add first subcategory" |
| Save button | AppBar trailing `FilledButton` | Enabled when dirty and name valid |

#### 9.9.2 States

| State | Treatment |
|---|---|
| Loading | Shimmer form |
| Loaded — parent | Name + icon + subcategory section |
| Loaded — child | Name + icon + read-only parent label; no subcategory section |
| Dirty | Save enabled |
| Name conflict | `TextField` error text "Name already in use" |
| Error | Snackbar "Failed to save." |

#### 9.9.3 Deletion Flow Components

| Step | Component | Notes |
|---|---|---|
| Template conflict dialog | `AlertDialog` | "This category is used by [N] template(s). Migrate or stop?" with Migrate / Stop / Cancel actions |
| Transaction migration dialog | `AlertDialog` with `RadioListTile` choices | No migration / Migrate all / Choose specific |
| Destination picker | Category picker `ModalBottomSheet` | Same tree (income/expense) filter enforced |
| Specific transaction sheet | Multi-select `BottomSheet` transaction list | Checkbox per row |
| Batch > 50 confirmation | `AlertDialog` | "Re-categorise [N] transactions?" |

---

### 9.10 Currency Settings

| Field | Value |
|---|---|
| Route | `/settings/currency` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Currency" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.10.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header "Home Currency" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Home currency row | `ListTile` + ISO code + name subtitle + `ChevronRight` | Tappable; opens ISO 4217 searchable picker; `bodyLarge` code |
| Change warning card | `Card` (`surfaceContainerLow`) + `Icon(info_outline)` + `Text` | `bodySmall`; "Changing home currency does not affect existing transactions. Net worth display will recalculate using new exchange rates." |
| Section header "Secondary Currencies" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Secondary currency row | `ListTile` + last-fetched timestamp trailing | `bodyLarge` code + name; `bodySmall` "Last updated [date]" or "Outdated" in `warningAmount` if > 14 days |
| Derived note | `Text` caption below list | `bodySmall`, `onSurfaceVariant`; "Secondary currencies are derived from your account currencies." |

#### 9.10.2 States

| State | Treatment |
|---|---|
| Loaded | Home currency row + warning card + secondary list |
| No secondary currencies | Section header + `Text` "No secondary currencies in use" |
| Exchange rate outdated | "Outdated" label `warningAmount` on affected row |

---

### 9.11 Tags Management

| Field | Value |
|---|---|
| Route | `/settings/tags` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Tags" + search `IconButton` |
| Scroll | `ListView` |
| FAB | `FloatingActionButton` with `add` icon (when populated) |
| Transition | push |

#### 9.11.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Tag row | `ListTile` leading `Icon(label_outline)` + title + trailing `Text` usage count | `bodyLarge` name; `bodySmall` count `onSurfaceVariant` |
| Shimmer rows | `ShimmerWidget` × 5 | — |
| Long-press / swipe-left menu | `ListTile` actions: Rename / Delete | Rename → inline `TextField` replace; Delete → `AlertDialog` confirm |
| Delete dialog | `AlertDialog` | "Delete tag '[name]'? It will be removed from all [N] transactions." + Delete / Cancel |
| Inline rename field | `TextField` inline in list row | `bodyLarge`; auto-focus; uniqueness validated on submit |
| Error banner | Inline M3 `Banner` + Retry | — |

#### 9.11.2 States

| State | Treatment |
|---|---|
| Loading | Shimmer |
| Empty | Abstract geometric + "No tags yet" + FilledButton "Add Tag" |
| Populated | Alphabetical list; FAB visible |
| Error | Inline error + Retry |

---

### 9.12 Payees Management

| Field | Value |
|---|---|
| Route | `/settings/payees` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Payees" + search `IconButton` |
| Scroll | `ListView` |
| FAB | `FloatingActionButton` with `add` icon (when populated) |
| Transition | push |

#### 9.12.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Payee row | `ListTile` leading avatar initials `CircleAvatar` + title + subtitle | `bodyLarge` name; `bodySmall` "Last used [relative date] · [N] transactions" |
| Long-press contextual menu | `ModalBottomSheet` with `ListTile` actions | Rename / Merge / Delete |
| Rename | Inline `TextField` in row | Uniqueness validated |
| Merge dialog | `AlertDialog` + payee picker | Select target payee; "All transactions from [source] will be moved to [target]." |
| Delete dialog | `AlertDialog` | "Remove [name] from pickers? Past transactions will retain the payee name." |
| Shimmer rows | `ShimmerWidget` × 5 | — |

#### 9.12.2 States

| State | Treatment |
|---|---|
| Loading | Shimmer |
| Empty | Abstract geometric + "No payees yet" + FilledButton "Add Payee" |
| Populated | Alphabetical list; FAB visible |
| Error | Inline error + Retry |

---

### 9.13 Recurring Templates List

| Field | Value |
|---|---|
| Route | `/settings/recurring` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Recurring & Installments" |
| Scroll | `TabBarView` per tab |
| FAB | none |
| Transition | push |

#### 9.13.1 Components — Shared

| Zone | Component | Token / Role |
|---|---|---|
| Tab bar | M3 `TabBar` 2 tabs: "Recurring" / "Installments" | `primaryContainer` indicator |
| Group header | `Text` ("Active" / "Paused" / "Archived") | `sectionHeading`, `onSurfaceVariant` |
| Status badge | M3 `Chip` | Active: `accentPastel` green; Paused: `warningAmount` amber; Archived: `onSurfaceVariant` |

#### 9.13.2 Recurring Template Row

| Zone | Component | Token / Role |
|---|---|---|
| Title | `ListTile` title | `bodyLarge` |
| Recurrence summary | `ListTile` subtitle | `bodySmall`, `onSurfaceVariant`; "Every 2 weeks · Auto-post" |
| Next due | `ListTile` trailing `Text` | `bodySmall`; date string; hidden for Archived |
| Status badge | `Chip` leading | see above |
| Long-press menu | `ModalBottomSheet` | Edit / Delete / Pause or Unpause / View transactions (Active/Paused); View transactions only (Archived) |

#### 9.13.3 Installment Template Row

| Zone | Component | Token / Role |
|---|---|---|
| Title | `ListTile` title | `bodyLarge` |
| Progress bar | `LinearProgressIndicator` below title | M3; value = paid/total; `primaryContainer` track |
| Running total label | `Text` below progress bar | `bodySmall`; "₹X paid of ₹Y" |
| Long-press menu | `ModalBottomSheet` | Edit / Delete / Pause / Unpause / View transactions / View progress / Mark complete |

#### 9.13.4 States

| State | Treatment |
|---|---|
| Loading | Shimmer |
| Empty | Abstract geometric + "No recurring templates" (per tab) |
| Populated | Grouped rows: Active → Paused → Archived |
| Error | Inline error + Retry |

---

### 9.14 Recurring Template Detail / Edit

| Field | Value |
|---|---|
| Route | `/settings/recurring/:id` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Edit Template" |
| Scroll | `ListView` |
| FAB | none; Save in AppBar actions |
| Transition | push |

#### 9.14.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header "Template Info" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Immutable field row | `ListTile` + `Chip` trailing | Read-only; chip label shows current value; `onSurfaceVariant` fill; tap → `Tooltip` explaining immutability |
| Status chip | M3 `Chip` in subtitle area | Active / Paused / Archived colours (see 9.13.1) |
| Next due / paused-until row | `ListTile` + date `Text` trailing | `bodyMedium`; "Next due: [date]" / "Paused until [date]" / "Archived" |
| Section header "Editable Fields" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Amount field | `OutlinedTextField` with `amountKeyboard` | `bodyLarge`; "Applies to future occurrences" hint |
| Account row | `ListTile` + account name trailing + `ChevronRight` | Navigates to account picker |
| Category row | `ListTile` + category name trailing + `ChevronRight` | Navigates to category picker |
| Title field | `OutlinedTextField` | Optional; `bodyLarge` |
| Description field | `OutlinedTextField` multiline | Optional |
| Posting behaviour row | `ListTile` + `SegmentedButton` | Auto-post / Remind |
| Save button | AppBar trailing `FilledButton` | Disabled until dirty |

#### 9.14.2 Pause Flow Dialog

| Step | Component | Notes |
|---|---|---|
| Pause duration dialog | `AlertDialog` with `RadioListTile` | N units OR Custom date picker; indefinite not allowed |
| Confirm | `AlertDialog` confirm button | Template status → Paused |

#### 9.14.3 States

| State | Treatment |
|---|---|
| Loading | Shimmer form |
| Loaded | Fields populated; immutable fields read-only |
| Dirty | Save enabled |
| Saving | `CircularProgressIndicator` on Save button |
| Error | Snackbar "Failed to save." |

---

### 9.15 Installment Plans List

| Field | Value |
|---|---|
| Route | `/settings/recurring` → Installments tab |
| Note | Rendered inside `TabBarView` of 9.13; not a separate route |

#### 9.15.1 States

Identical to §9.13.4, filtered to installment-type templates. Rows use installment row spec (§9.13.3).

---

### 9.16 Installment Plan Detail / Edit

| Field | Value |
|---|---|
| Route | `/settings/installments/:id` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Installment Plan" |
| Scroll | `ListView` |
| FAB | `FloatingActionButton` with `add` icon — "Add Installment" (per-installment list section) |
| Transition | push |

#### 9.16.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Summary card | M3 `Card` (`surfaceContainerLow`) with 4-cell `GridView` 2×2 | `bodySmall` label + `bodyLarge` value per cell; labels: "Target total" / "Paid to date" / "Remaining" / "Projected total" |
| Mismatch warning banner | M3 `Banner` `warningAmount` / `warningContainer` | "Total paid will be [X], original target was [Y]."; shown when projected ≠ configured |
| Section header "Installments" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Installment row | `DataTable` row OR `ListTile` custom | # (number) + scheduled date + amount + status badge; tap amount (unposted) → inline edit; swipe-left (unposted) → delete |
| Status badge | M3 `Chip` | Scheduled: default; Posted: `primaryContainer`; Manually handled: `secondaryContainer`; Cancelled: `onSurfaceVariant` |
| Amount inline edit | `TextField` inline | Shown on tap for unposted rows; `bodyLarge` |
| Add installment FAB | `FloatingActionButton` | Extended: "Add installment"; auto-fills next scheduled date + amount |
| Save button | AppBar trailing `FilledButton` | Enabled when dirty |

#### 9.16.2 Early Close Flow Components

| Step | Component | Notes |
|---|---|---|
| Contextual menu | Long-press `ModalBottomSheet` | "Mark series as complete" action |
| Final payment dialog | `AlertDialog` | "Record a final payment before closing?" — Yes / No |
| Pre-filled transaction form | Transaction entry screen | Push; pre-filled with plan details |
| Target mismatch dialog | `AlertDialog` | "Update target to [running total]?" — Yes / No |

#### 9.16.3 States

| State | Treatment |
|---|---|
| Loading | Shimmer |
| Loaded | Summary card + installment list |
| Dirty | Save enabled; mismatch banner if totals diverge |
| Mismatch | Non-blocking banner above installment list |

---

### 9.17 Backup & Restore

| Field | Value |
|---|---|
| Route | `/settings/backup` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Backup & Data" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.17.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Section header "Backup" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Export row | `ListTile` + `Icon(download)` leading + `ChevronRight` trailing | "Export backup"; `bodyLarge` |
| Export subtitle | `ListTile` subtitle | `bodySmall`; "Saves a ZIP to your device containing all data and photos" |
| Section header "Restore" | `Text` | `sectionHeading`, `onSurfaceVariant` |
| Import row (v2) | `ListTile` + `Icon(upload)` leading | Greyed out; `onSurfaceVariant`; subtitle "Coming in a future update"; non-interactive |
| Exporting overlay | `LinearProgressIndicator` modal overlay | Blocks interaction; `CircularProgressIndicator` centred |

#### 9.17.2 States

| State | Treatment |
|---|---|
| Idle | Export row active; import row greyed out |
| Exporting | Progress overlay; export row non-interactive |
| Export success | Snackbar "Backup saved to [path]" |
| Export error | `AlertDialog` "Export failed. Check storage permissions and available space." + Retry / Cancel |

---

### 9.18 About

| Field | Value |
|---|---|
| Route | `/settings/about` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "About" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.18.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| App logo + name | Centred `Column` (logo `Image` 64 dp + `Text`) | `sectionHeading`; padded header area |
| Version row | `ListTile` + version string trailing | `bodyLarge` "Version"; `bodySmall` `onSurfaceVariant` semver |
| Licenses row | `ListTile` + `ChevronRight` | "Open-source licenses"; navigates to Flutter `LicensePage` |
| Acknowledgements row | `ListTile` + `ChevronRight` | "Acknowledgements"; static `ListView` of credits |
| Support row | `ListTile` + `Icon(open_in_new)` trailing | Tappable URL; `bodyLarge` |

#### 9.18.2 States

| State | Treatment |
|---|---|
| Loaded | Static content only; no loading states |

---

### 9.19 Drafts

| Field | Value |
|---|---|
| Route | `/settings/drafts` |
| Scaffold | standard settings |
| AppBar | `SmallTopAppBar`, back arrow, "Drafts" |
| Scroll | `ListView` |
| FAB | none |
| Transition | push |

#### 9.19.1 Components

| Zone | Component | Token / Role |
|---|---|---|
| Limit banner (5 drafts) | M3 `Banner` (`surfaceContainerLow`) + `Icon(info_outline)` | `bodySmall`; "Maximum 5 drafts stored. Oldest discarded when new draft saved."; shown only at limit |
| Shimmer rows | `ShimmerWidget` × 3 | — |
| Draft row | `ListTile` | Leading: transaction type `Chip` (Expense/Income/Transfer); title: partial title or "Untitled"; subtitle: amount or "—" + relative timestamp `bodySmall` |
| Type chip | M3 `Chip` | `chipText` 12 sp; Expense: `errorContainer`; Income: `accentPastel` green; Transfer: `secondaryContainer` |
| Amount text | `ListTile` trailing | `bodyMedium`; "—" if empty |
| Long-press menu | `ModalBottomSheet` | "Delete draft" only |
| Delete confirm | `AlertDialog` | "Delete this draft?" — Delete / Cancel |

#### 9.19.2 States

| State | Treatment |
|---|---|
| Loading | Shimmer |
| Empty | Abstract geometric + "No drafts saved" + `bodySmall` "Drafts are saved when you back out of an unsaved transaction." |
| Populated ≤ 5 | Draft rows; no FAB |
| At limit (5) | Limit banner at top |
| Error | Inline error + Retry |

#### 9.19.3 Resume Behaviour

| Trigger | System response |
|---|---|
| Tap draft row | Push transaction entry screen pre-filled with draft state; draft record deleted immediately on open |

