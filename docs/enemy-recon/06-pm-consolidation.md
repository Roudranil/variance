# Product Intelligence Report: Cashew vs. Variance

**Date:** 2026-04-15
**Author:** PM (Product Intelligence Consolidation)
**Sources:** Reports 01 through 05 (Architecture, UI/UX, State Management, Feature Engineering, Security)
**Audience:** Founder

---

## Executive Summary

Cashew is a polished, well-loved expense tracker that proves one thing conclusively: users will adopt a personal finance app if it is beautiful, fast, and frictionless. It has earned its audience through visual delight, thoughtful home screen composition, and an effortless transaction entry flow.

But underneath the polish, Cashew is built on sand. Its single-entry bookkeeping model has no mathematical invariant. Its transfer support was bolted on at schema version 46. Its mutable transaction history means a corrupted record is undetectable. Its security posture is negligent -- no database encryption, no secure storage, zero test coverage.

Variance does not need to out-polish Cashew on day one. It needs to match the entry speed, match the visual quality, and then let the DEB engine do what Cashew structurally cannot: guarantee that the user's financial data is always correct, always auditable, and always recoverable. That is the wedge.

---

## 1. Product Strengths We Should Learn From

### 1.1 The Transaction Entry Flow Is Fast

Cashew's guided entry sequence -- category first, then amount -- is genuinely good UX. The user picks a category icon from a visual grid (low cognitive load), taps a calculator-style amount pad, and is done. The form never shows all 25+ fields at once. Additional options are behind expandable sections. The save is debounce-protected and the dismissal animation begins while the frame is still rendering. The result: entry feels instant.

**What makes it work:**
- Category selection via visual icon grid, not a text list
- Calculator-style amount input (not a text field with keyboard)
- Bottom sheets for sub-flows (category, date, wallet) instead of full page pushes
- Conditional rendering -- recurrence options appear only when the type demands them
- Hard lock on double-tap saves

This is the bar we must meet. If Variance takes more than 30 seconds from cold open to saved transaction (our SC-1), we lose.

### 1.2 Home Screen Composition Is Best-In-Class

Cashew's home screen is configurable, reorderable, and information-dense without feeling cluttered. The section registry pattern -- 13 independently toggleable and reorderable widgets -- gives users control without complexity. Key sections:

- Horizontal wallet switcher cards
- Pinned budget progress
- Overdue/upcoming transaction alerts
- Net worth display
- Spending line graph, pie chart, and GitHub-style heatmap
- Recent transactions with income/expense tab selector

The wide-screen layout splits into three columns with marker-based ordering. Each section is wrapped in `KeepAliveClientMixin` for scroll position preservation. The greeting banner uses parallax scroll animation.

**The lesson:** Users want a dashboard, not just a list. Our v1 home screen (greeting + net worth + monthly summary + transaction list + alerts + FAB) is scoped correctly, but we must design it to be extensible for v2 analytics widgets. The section registry pattern is worth studying for our future architecture.

### 1.3 Visual Delight Without Excess

Cashew's animation system is sophisticated and disciplined:

- **Three-tier opt-out:** Battery saver (no shadows), reduced animations (zero duration), full animations. Every animation widget checks before rendering.
- **Curve discipline:** `easeInOutCubicEmphasized` is the dominant curve. Elastic curves (`ElasticOutCurve(0.5)`) are reserved for delight moments (pie chart reveals, badge pop-ins). This consistency creates a cohesive feel.
- **Timing discipline:** Tap feedback is 150-230ms. Content reveals are 500-1500ms. The app responds instantly to touch but takes its time for visual storytelling.
- **Platform-adaptive touch:** On Android, Material ripple with `InkSparkle`. On iOS, opacity fade (50% on press, recover on release). This single pattern (`Tappable`) makes the app feel native on both platforms.

The `dynamicPastel()` function -- which lightens colors in light mode and darkens them in dark mode -- is a genuinely elegant solution for making category colors work across themes. The `PinWheelReveal` for pie charts (clockwise sweep over 850ms) is a small but memorable touch.

### 1.4 Theming Is Comprehensive

Material 3 with `ColorScheme.fromSeed()`, plus 14 custom semantic color tokens via `AppColors` extension, plus a grayscale fallback for gray accent colors (because `fromSeed()` produces ugly results with gray inputs). Material You dynamic color support with Samsung bug detection. Six font options with Inter as fallback.

Users who care about aesthetics have every lever they need.

### 1.5 The Recurring Transaction Engine Works

Despite the messy implementation, Cashew's lazy materialization model (generate the next instance only when the current one is paid) is pragmatic and battle-tested. The predictable key generation for sync (`abc::predict::1`, `abc::predict::2`) prevents duplicates across devices. The auto-pay logic handles overdue stacking with a 50-iteration recursion cap.

Their approach validates our decision to invest in a proper 4-state template lifecycle. Their problems (no pause without workarounds, no installment tracking, confusing paid/unpaid semantics for debt) are exactly the gaps our model fills.

### 1.6 Budget Filtering Is Genuinely Powerful

Cashew's composable filter expression system deserves respect. The `Expression<bool>` builder pattern allows any query to apply any combination of category, wallet, budget, date range, income/expense, paid status, and search text. Every filter function is a pure expression builder. This is clean architecture in a codebase that otherwise lacks it.

---

## 2. Product Weaknesses We Can Exploit

### 2.1 No Data Integrity Guarantee (CRITICAL)

This is the single largest product gap. Cashew's single-entry model has no mathematical invariant. There is no mechanism to verify that `sum(debits) == sum(credits)` because debits and credits do not exist. A transaction can be silently corrupted -- wrong sign, wrong wallet FK, orphaned record -- with no detection.

The `fixWandering*` cleanup methods in the codebase confirm that referential integrity violations occur in production. The absence of explicit database indexes means these fixups are slow. The lack of foreign key enforcement (`PRAGMA foreign_keys = ON` is never set) means the database cannot prevent corruption in the first place.

**Our advantage:** Every Variance transaction satisfies `sum(debit) == sum(credit)`. We can run a ledger verification check at any time and mathematically prove the data is correct. This is not a feature users see -- it is a property they feel, through confidence that their balances are always right.

### 2.2 Transfers Are a Hack

Cashew did not support transfers until schema version 46. Even now, a transfer is two separate transactions linked by `pairedTransactionFk`, with a heuristic fallback (same timestamp within 1 second, opposite income flag, category PK "0") when the explicit link is missing. The UI asks "Update both transfers?" on edit because the pair can become desynchronized.

**Our advantage:** A Variance transfer is a single transaction with two entries: `Dr Destination, Cr Source`. There is no pair to desynchronize. Editing a transfer edits one entity. The DEB model handles this natively.

### 2.3 Mutable History Means No Audit Trail

Cashew edits transactions in place. The `dateTimeModified` field exists for sync, not for the user. There is no way to know what a transaction used to be, when it was changed, or why. For a personal finance app, this means the user cannot answer: "Wait, did I change this amount last week?"

**Our advantage:** Variance's immutable correction model (reversing + corrected entries) means every change is permanent and traceable. In v1, only the final corrected version is visible. In v2, the audit view surfaces the full history. The data is there from day one.

### 2.4 Multi-Currency Is Lossy

Cashew converts through USD as a pivot: `CAD -> USD -> INR`. This means two floating-point multiplications per conversion, compounding rounding errors. Exchange rates are fetched once (current only) and cached in SharedPreferences. There are no historical rates -- every past transaction is converted at today's rate when displayed.

**Our advantage:** Variance captures the exchange rate at transaction time and stores it with the transaction. Historical amounts are always displayed at their original economic value. Net worth uses the current rate (reflecting market value). This is the correct accounting treatment.

### 2.5 Security Is Negligent

This is where Cashew is most vulnerable to competitor positioning:

- **No database encryption.** All financial data is stored as plaintext SQLite.
- **No secure storage.** Zero usage of `flutter_secure_storage`. Auth tokens, emails, and settings are all in SharedPreferences.
- **Unencrypted backups.** Raw SQLite files uploaded to Google Drive.
- **Firebase API keys committed to source.**
- **Deep link creates arbitrary transactions** without user confirmation.
- **Zero test coverage.** The only test file is the Flutter scaffold placeholder.
- **Notification listener reads all device notifications** (even behind a debug flag, the manifest permission is always declared).

**Our advantage:** Variance encrypts sensitive fields at rest (card numbers, bank account numbers). The security lock protects sensitive account details. No cloud dependency means no attack surface for data exfiltration. Our 80% test coverage minimum means we catch regressions. Our zero-telemetry, zero-network-call constraint (NF-1, FC-1) eliminates an entire class of privacy risks.

### 2.6 UX Rough Edges

Despite the overall polish, several UX patterns are problematic:

- **Inverted `paid` semantics for credit/debt.** The code comments acknowledge this is "the opposite of what is expected." Users who track debts are likely confused.
- **Magic category PK "0" for balance corrections.** Users see a cryptic "Balance Correction" category with forced timestamp manipulation (second=30 for negative, second=31 for positive). Our protected "Balance Adjustment" system category is cleaner.
- **5,207-line AddTransactionPage.** The form has 25 separate `setState` variables. This is not a user-facing issue today, but it means Cashew will have increasing difficulty adding features to this page without regressions.
- **Search is LIKE-based.** No typo tolerance, no fuzzy matching, no stemming. Our fzf-style search will feel dramatically better.
- **Bill splitter data lives in SharedPreferences.** Not in the database. Not persistent. This is a half-baked feature.

### 2.7 Global Mutable State

Cashew's state management is a 170-key mutable `Map<String, dynamic>` with no type safety, accessed directly from widget `build()` methods, refreshed via `GlobalKey`-based imperative calls. This is not a user-facing issue, but it is a structural weakness: it makes the app fragile, untestable, and increasingly difficult to maintain. As we build Variance with proper state management (Riverpod, BLoC, or equivalent), our development velocity will compound over time while theirs stagnates.

---

## 3. Feature Comparison Matrix

| Feature | Cashew | Variance v1 | Advantage |
|---------|--------|-------------|-----------|
| **Bookkeeping model** | Single-entry (signed amounts) | Double-entry (debit/credit entries) | **Variance** -- mathematical integrity |
| **Transfers** | Paired transactions (bolt-on at v46) | First-class transfer entity (1 txn, 2 entries) | **Variance** -- no desync risk |
| **Transaction editing** | Mutable in-place | Immutable + reversing/correcting entries | **Variance** -- audit trail from day one |
| **Multi-currency exchange rates** | Current rate only, USD pivot, cached | Transaction-level capture, locked at creation | **Variance** -- historically accurate |
| **Account types** | Single "wallet" type | 8 fixed categories with per-type fields | **Variance** -- richer modeling |
| **Credit card model** | No special treatment | Two-balance model (outstanding + statement) + payment reminders | **Variance** -- materially better CC UX |
| **Recurring templates** | Template-in-place (paid/unpaid flags) | 4-state lifecycle (active/paused/archived/deleted) | **Variance** -- cleaner state machine |
| **Installments** | Not supported | Full installment sub-type with 4-way tracking | **Variance** -- gap feature |
| **Transfer fees** | Not supported | Optional flat/percentage fee as compound transaction | **Variance** -- gap feature |
| **Loan accounts** | Objective table with confusing semantics | Loan account category with installment suggestion | **Variance** -- better loan UX |
| **Search** | SQL LIKE (no fuzzy matching) | fzf-style fuzzy search | **Variance** -- meaningfully better |
| **Database encryption** | None | Encrypted sensitive fields at rest | **Variance** -- basic security hygiene |
| **Soft delete** | Hard delete + tombstone log | Universal soft-delete, no entity ever permanently deleted | **Variance** -- data durability |
| **Budgets** | Rich (category filters, shared, per-category limits) | Deferred to v2 | **Cashew** -- gap for us |
| **Savings goals** | Objective table with goal/loan types | Deferred to v2 | **Cashew** -- gap for us |
| **Charts and analytics** | Pie chart, line graph, heatmap, bar graph | Deferred to v2 | **Cashew** -- gap for us |
| **Cloud sync** | Google Drive full-DB sync | Not planned (permanent anti-goal) | **Cashew** -- but their sync is fragile |
| **Shared budgets** | Firebase Firestore | Not planned (permanent anti-goal) | **Cashew** -- we will never match this |
| **CSV import/export** | Both supported | Export deferred to v2 | **Cashew** -- gap for us |
| **Home screen widgets (Android)** | 4 widget types | Deferred to v3 | **Cashew** -- gap for us |
| **Notification scanning** | Email + notification parsing (experimental) | Deferred to v2 | **Cashew** -- but their approach is rudimentary |
| **Bill splitter** | Standalone calculator (not in DB) | Not planned | **Cashew** -- but half-baked |
| **Onboarding** | 3-page swipeable wizard | 5-step wizard with account creation | **Variance** -- gets user to usable state faster |
| **Home screen composition** | 13 configurable, reorderable sections | Fixed layout: greeting + net worth + monthly summary + list + alerts | **Cashew** -- more customizable |
| **Animation system** | 3-tier opt-out, elastic curves, platform-adaptive | TBD (not yet designed) | **Cashew** -- mature system |
| **Test coverage** | Zero | 80% minimum requirement | **Variance** -- not even close |
| **Telemetry / privacy** | Firebase, Google Sign-In for cloud features | Zero telemetry, zero network calls | **Variance** -- absolute privacy |
| **Photo attachments** | Google Drive (privacy concern) | Local-only private storage | **Variance** -- better privacy |
| **Balance reconciliation** | Not supported | Full reconciliation flow on all accounts | **Variance** -- gap feature |
| **Duplicate detection** | Not supported | Same-day duplicate warning | **Variance** -- gap feature |
| **Draft transactions** | Not supported | Auto-save as draft option | **Variance** -- gap feature |

### Gap Summary

**Features where Cashew leads and we must acknowledge the gap:**
- Budgeting (v2 for us)
- Savings goals (v2)
- Charts and analytics (v2)
- CSV import/export (v2)
- Cloud sync (never for us -- by design)
- Shared budgets (never for us -- by design)
- Home screen customization (v1 is fixed layout)
- Android home widgets (v3)

**Features where Variance leads at v1 launch:**
- Double-entry bookkeeping with mathematical integrity
- First-class transfers
- Immutable correction model with audit trail
- Transaction-level exchange rate capture
- 8 account categories with per-type fields
- Credit card two-balance model + payment reminders
- Installment tracking with 4-way running total
- Transfer fees
- Loan account modeling
- Fuzzy search
- Balance reconciliation
- Duplicate transaction detection
- Database security (encrypted sensitive fields)
- Universal soft-delete
- Zero telemetry
- Test coverage

---

## 4. UX Patterns Worth Adopting

### 4.1 Transaction Entry: Category-First Guided Flow

Cashew's "initial add transaction sequence" should directly inform our UX Flows design. The pattern:

1. Open entry form
2. Show category grid immediately (visual, tappable icons -- low friction)
3. On category selection, transition to amount input (calculator pad)
4. Show remaining fields only after the two most important decisions are made
5. Additional options are behind expandable sections

**Adaptation for DEB:** Our entry form has source/destination accounts in addition to category. The sequence should be: type selection (income/expense/transfer) -> category (if applicable) -> account(s) -> amount -> optional fields. Transfer entry skips category entirely.

### 4.2 Platform-Adaptive Touch Feedback

The `Tappable` pattern is worth adopting directly:
- Android: Material ripple with `InkSparkle` splash factory
- iOS (if we ever support it): opacity fade (50% on press, 230ms recovery)

Since we are Android-only, we should use the Android path. But designing the abstraction now means we do not regret it later.

### 4.3 Bottom Sheets Over Full-Page Navigation

Cashew uses bottom sheets for category selection, amount input, date picking, and wallet selection. This keeps the user in context -- they never lose sight of the form they are filling. The snap points (60% and 100% on tall phones) are thoughtful.

**Adoption:** Use bottom sheets for all sub-selections within the transaction entry form. Full-page navigation only for entity creation (new account, new category) and detail views.

### 4.4 Animation Timing and Curves

Adopt these specific values:
- **Default curve:** `easeInOutCubicEmphasized` (Material 3 standard)
- **Delight moments:** `ElasticOutCurve(0.5-0.6)` for pop-in effects
- **Tap feedback:** 150ms response
- **Content reveals:** 500-800ms
- **Size transitions:** `AnimatedSize` with 800ms `easeInOutCubicEmphasized`
- **Cross-fade content swaps:** `AnimatedSwitcher` with 250ms

### 4.5 Three-Tier Animation Opt-Out

Every animation widget should check a global setting before rendering:
1. **Full:** All animations active
2. **Reduced:** Minimal transitions (our Settings > Appearance > Animations toggle covers this)
3. **Battery saver / accessibility:** Zero animations, no shadows

This is not just polish -- it is an accessibility requirement. Users with vestibular disorders need to disable motion.

### 4.6 Dynamic Color Adaptation for Category Colors

The `dynamicPastel()` pattern (lighten in light mode, darken in dark mode using `Color.alphaBlend`) should be adopted for category icon backgrounds and any color-coded UI element. Adjacent items with the same color should get automatic differentiation (every Nth item gets additional lightening/darkening).

### 4.7 Number Animation for Financial Amounts

Cashew's `CountNumber` widget (animating between numeric values with `easeOutQuint` over 1000ms) is a small but effective touch for net worth and summary displays. Financial amounts should animate when they change, not jump.

### 4.8 Customizable Nav Bar Icons

Cashew's long-press-to-reassign bottom nav icons is a power-user feature that adds perceived customizability with minimal implementation cost. Worth considering for v2 when we have more screens.

---

## 5. UX Patterns to Avoid

### 5.1 String-Based Color Lookup

Cashew uses `getColor(context, "lightDarkAccent")` -- a string-keyed color lookup with no compile-time safety. A typo produces a runtime error. Use an enum-based or `ThemeExtension`-based approach.

### 5.2 Global Mutable Settings Map

The `appStateSettings` pattern (170+ keys in a `Map<String, dynamic>`, mutated in place, accessed directly in widget `build()` methods) is the opposite of what we should build. Use typed, immutable settings classes with a proper state management solution.

### 5.3 GlobalKey-Based Imperative Refresh

Cashew declares 15+ `GlobalKey` references and refreshes UI by calling `currentState?.refreshState()`. This is tightly coupled, fragile, and untestable. Use reactive state management where UI rebuilds automatically when the underlying data changes.

### 5.4 God Files

`tables.dart` (7,667 lines), `addTransactionPage.dart` (5,207 lines), and `functions.dart` (1,489 lines) are maintenance hazards. Our coding standards (200-400 lines typical, 800 max) exist for good reason. Enforce them from day one.

### 5.5 Inverted Semantics

Cashew's `paid` field means the opposite for credit/debt transactions ("paid = true means active, paid = false means settled"). The code comments acknowledge this is confusing. Our two-field model (`status` x `purpose`) is cleaner. Never introduce semantic inversions to save a column.

### 5.6 JSON-in-Columns

Cashew stores lists of category PKs, budget filters, and wallet PKs as JSON-encoded strings in text columns. This prevents SQL-level querying -- the app uses string `contains()` checks instead of proper joins. Use junction tables or proper array types.

### 5.7 Full-Database Sync Upload

Uploading the entire SQLite file for sync is a brute-force approach that does not scale. While we have sync as a permanent anti-goal, if we ever add any cloud backup feature, it must be differential.

### 5.8 Forked Third-Party Packages

Cashew forks `sliding_sheet` and `implicitly_animated_reorderable_list` -- modified copies of packages that now require manual maintenance. Prefer composable alternatives or upstream contributions. If we must customize a package, isolate the customization layer.

### 5.9 O(n) Budget Period Calculation

Cashew finds the current budget period by iterating forward up to 10,000 times from the start date. This is O(n) where n is the number of periods elapsed. Use arithmetic: `periods_elapsed = floor((today - start) / period_length)`. When we build budgets in v2, this must be O(1).

### 5.10 Hiding Rendering Errors in Production

Cashew replaces Flutter's error widget with a transparent container in release mode. This silently swallows rendering errors. We should log errors even when hiding the red screen from users.

---

## 6. Competitive Positioning Statement

### The Narrative

**Cashew is the app you use when you want to feel good about tracking expenses. Variance is the app you use when you want to know your money is right.**

Cashew is beautiful, fast, and fun. It solves the "I don't track my expenses because it's tedious" problem through visual delight and frictionless entry. It deserves credit for proving that a local-first, open-source expense tracker can compete on design quality.

But Cashew is a notepad with a beautiful cover. It records what you tell it, but it cannot tell you if what you recorded is correct. It has no mathematical invariant. It has no audit trail. It has no immutability guarantee. It stores your financial data in plaintext. It has zero tests.

Variance is a ledger with a beautiful cover. Under the same modern Material 3 surface, every transaction satisfies `sum(debit) == sum(credit)`. Every edit preserves history. Every balance is computed, never stored. Every sensitive field is encrypted. The data is provably correct at any point in time.

### Positioning for Different Audiences

**For the casual tracker** (Cashew's core audience): "Variance tracks your income, expenses, and transfers just like Cashew -- same speed, same simplicity. But it also handles credit cards properly, warns you about duplicates, gives you real balance reconciliation, and never loses your data."

**For the financially literate user** (Cashew's gap): "Variance uses real accounting principles under the hood. Your balances are always mathematically correct. Transfers actually work. Multi-currency amounts are captured at the historical rate. You get installment tracking, loan modeling, and balance reconciliation."

**For the privacy-conscious user** (our strongest differentiation): "Variance never makes a network call. Ever. No telemetry. No analytics. No Firebase. No Google Sign-In. Your financial data stays on your device, encrypted at rest, with zero cloud dependency."

### What We Must NOT Do

- Do not position as "the DEB expense tracker." Users do not care about bookkeeping models. They care about correct balances and trustworthy data.
- Do not lead with features Cashew lacks. Lead with the experience being equally fast and beautiful, then let the structural advantages emerge through use.
- Do not apologize for missing budgets and charts in v1. Frame it as "focused on getting the core right" and ship v2 features on a cadence that shows momentum.

### The v1 Bet

Our bet is that a user who uses Variance for 30 days will trust it more than they ever trusted Cashew. Not because of any single feature, but because balances are always right, corrections are always traceable, and the app never does anything unexpected with their data. Trust compounds. Delight is table stakes.

---

## Appendix: Key Files from Cashew Recon

For engineering reference, the most instructive files in the Cashew codebase:

| File | Why It Matters |
|------|----------------|
| `tables.dart` (7,667 lines) | Full data model, query layer, filter expressions -- study the filter architecture, avoid the God file |
| `addTransactionPage.dart` (5,207 lines) | Transaction entry UX -- study the guided flow, avoid the monolithic structure |
| `navigationFramework.dart` | Navigation shell with `LazyIndexedStack` -- study the tab preservation pattern |
| `homePage.dart` | Section registry and configurable layout -- study for v2 home screen extensibility |
| `currencyFunctions.dart` | Exchange rate caching and conversion math -- study the USD pivot approach |
| `upcomingTransactionsFunctions.dart` | Recurring transaction materialization -- study the predictable key generation |
| `settings.dart` | The 170-key global settings map -- study as an anti-pattern |
| `initializeBiometrics.dart` | Biometric auth gate -- study the bypass vulnerability |
| `syncClient.dart` | Full-DB sync protocol -- study the tombstone pattern |
