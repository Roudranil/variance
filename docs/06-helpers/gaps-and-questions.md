---
name: Gaps and Open Questions
status: in progress
owner: pm
created: 2026-04-13
last_updated: 2026-04-14
depends_on: [01-product/prd.md]
outputs_to: [02-technical/ux-flows.md, 02-technical/sds.md]
---

# Variance — Gaps & Open Questions

> **Last Updated:** 2026-04-14
>
> This document is a comprehensive reference for product gaps and questions. It is organized into four parts:
>
> - **Part 1 — PRD Questions (Q47–Q76):** ✅ **ALL RESOLVED** in the PRD. Question text removed from this document — resolutions are baked into the PRD body; the resolved questions log is in `docs/06-helpers/ideation-tracker.md`.
>
> - **Part 2 — UX Flows Pre-Work Topics (UX-1–UX-14):** Interaction design decisions that belong in `docs/02-technical/ux-flows.md`, not the PRD. These do not block the PRD sign-off but must be resolved before the UX Flows document can be completed. Items UX-7 and UX-8 are deferred with budgets to v2.
>
> - **Part 3 — Feature Gap Analysis:** ✅ **ALL RESOLVED.** FG-A1 through FG-A31 resolved on 2026-04-14. FG-B1 through FG-B9 resolved on 2026-04-14; FG-B3 and FG-B6 deferred with budgets to v2. FG-C1 through FG-C21 resolved on 2026-04-14; 7 baked into v1, 7 deferred to v2, 1 deferred to v3, 3 rejected, 2 no action needed.
>
> - **Part 4 — Founder Decisions (from TC Review):** 5 items escalated from the Technical Clarifications review (TC-014, TC-022, TC-029, TC-031, TC-050). These require founder decisions before downstream work can proceed. PM recommendations are provided for each.
>
> The authoritative status of each question is tracked in `docs/06-helpers/ideation-tracker.md`.

---

## Part 1 — PRD Questions

> ✅ **All 30 questions (Q47–Q76) were resolved on 2026-04-13 and baked into the PRD.** Resolutions are in the PRD document body. The full resolved questions log is in `docs/06-helpers/ideation-tracker.md`. Part 1 has been removed from this document — see those sources for details.

---

## Part 2 — UX Flows Pre-Work Topics

> These are interaction design decisions. They belong in `docs/02-technical/ux-flows.md`, not the PRD. They do not block PRD sign-off but must be answered before UX Flows can be written.

### App Structure & Navigation

| ID | Topic | Notes |
|----|-------|-------|
| UX-1 | **Primary navigation model** — What is the app's top-level navigation structure? Bottom navigation bar? Navigation drawer? What are the top-level destinations and their labels (e.g., Home, Accounts, Transactions, Budgets, Settings)? | Every screen's entry point depends on this. It is the skeleton of the entire UX Flows document. |
| UX-2 | **Transaction creation entry point** — Is there a FAB (Floating Action Button)? A speed dial that splits into income / expense / transfer? Where does it live — home screen only, or persistent across all screens? | The most frequent user action in the app has no specified entry point. |
| UX-3 | **Account detail screen** — Does tapping an account navigate to a detail view? If so, what does it show? Options: balance over time, transaction list filtered to that account, account metadata and edit access. | Depends on Q64 (unified vs. per-account transaction list). |

---

### Screen-Level Design

| ID | Topic | Notes |
|----|-------|-------|
| UX-4 | **Transaction list row design and grouping** — What does each transaction row display (category icon, title or category name, amount, account, date)? How are transactions grouped — by day, by week, by month? Is there a group subtotal or running balance? | Complements Q53 and Q54 (title/description display) once those are resolved. |
| UX-7 | **Budget home period display** — Which period is shown on the home screen budget summary? Is the period label shown (e.g., "April 2026")? Is there a way to navigate to adjacent periods from the home screen? | Depends on Q68 (budget period lifecycle) and Q69 (historical periods). |
| UX-13 | **Empty states** — What does each major screen show when it has no data: no accounts created, no transactions recorded, no budgets defined? Each screen needs an illustration or icon, instructional copy, and a primary CTA (e.g., "Create your first account"). | Must be defined per screen in UX Flows. |

---

### First Launch & Onboarding

| ID | Topic | Notes |
|----|-------|-------|
| UX-5 | **Onboarding wizard design** — If Q65 resolves to "yes, there is an onboarding flow", what are the steps, screens, and state transitions? Candidate steps: welcome, currency selection, create first account, optional quick-start guide. | Gated on Q65. |
| UX-6 | **Currency selection flow** — If Q67 resolves to "currency selection is mandatory on first launch", what does the currency picker screen look like? Is it a searchable list of ISO 4217 currencies? Where does it appear in the launch sequence — before or after the onboarding wizard? | Gated on Q67. |

---

### Transaction Entry

| ID | Topic | Notes |
|----|-------|-------|
| UX-11 | **Category picker** — When recording a transaction, how does the user select a category and subcategory? Options: bottom sheet with a two-level list, full-screen modal, inline dropdown. Is there search within the picker? Are recently used or most-used categories surfaced at the top of the list? | Used in every expense and income transaction. High-frequency interaction. |
| UX-12 | **Amount entry** — Does the app use the system keyboard or a custom numeric keyboard? Does the input support calculator-style expressions (e.g., "50 + 30 = 80")? How are locale-specific decimal separators handled? | Amount entry is the first field in every transaction. |
| UX-14 | **Photo capture source** — When attaching photos to a transaction, does the app present camera, device gallery, or a chooser for both? Is there an in-app preview before attaching? Can photos be added after a transaction is saved (since photos are an in-place editable field per §5.2.2)? | §5.2.3 defines storage but not the capture interaction. |

---

### UX Patterns (Cross-Cutting)

| ID | Topic | Notes |
|----|-------|-------|
| UX-8 | **In-app alert visual treatment** — When a budget threshold is crossed, what does the in-app alert look like? Options: persistent banner at the top of the budget screen, dismissible snackbar, badge on the nav item, or a dedicated notifications/alerts screen with a history. Are alerts dismissible? Do they persist across sessions until dismissed? | §5.3.4 confirms in-app only, no OS notifications. The visual form is unspecified. |
| UX-9 | **Soft-delete UX pattern** — When the user deletes a transaction (or account, or category), what is the interaction pattern? Options: (a) confirmation dialog ("Are you sure?") before the action; (b) immediate soft-delete with a time-limited undo snackbar (e.g., "Undo" toast for 5 seconds); (c) immediate soft-delete with no affordance. This pattern applies across all soft-delete actions in the app. | Consistent destructive action pattern must be established for the whole app. |
| UX-10 | **App lock screen design** — What does the lock screen look like? Full-screen overlay that completely obscures app content (required for privacy — account balances must not be visible behind the lock UI). What does the PIN entry field and biometric prompt look like? Is the app name / icon shown? | Gated on Q73 (lock activation timing). Privacy requires full content obscuring. |

---

## Part 0 — Internal Errors & Inconsistencies

> ✅ All errors resolved.

| ID | Document | Section | Error | Status |
|----|----------|---------|-------|--------|
| ERR-1 | `docs/01-product/prd.md` | §4.5 Transaction Rules by Type — Expense | Debit/credit sides were reversed. | ✅ Fixed — §4.5 now correctly reads "debit side" for expense category and "credit side" for account. |
| ERR-2 | `docs/01-product/prd.md` | §4.2 Accounting Equation | The second equation was missing the Equity term. | ✅ Fixed — Equity term added; Variance-specific note added explaining EQ exclusion from user-facing computation. |
| ERR-3 | `docs/01-product/prd.md` | §4.11 Notation line | Notation legend used retired `L = liability account` symbol. | ✅ Fixed — Replaced with `A = any user-facing account`; added `FC` symbol. |

### LC — Ledger Case Coverage Gaps

> ✅ All gaps resolved on 2026-04-14. Cases added to both `docs/01-product/ledger-entry.md` and the PRD §4.11 compact summary table.

| ID | Event | Resolution |
|----|-------|-----------|
| LC-1 | Modify transfer-with-fee | ✅ Case 1.6a added — reverse both (transfer + fee) + correct both. 4 txns, 8 entries. |
| LC-2 | Soft-delete transfer-with-fee | ✅ Case 1.9a added — reverse both (transfer + fee). 2 linked txns, 4 entries. |
| LC-3 | Account deletion balance transfer | ✅ Case 2.5a added — with sub-cases for positive and negative balance. System-generated, non-editable. |
| LC-4 | Batch category migration | ✅ Case 3.7 added — per transaction: reversing + corrected pair. Atomicity note for SDS. |

---

## Part 3 — Feature Gap Analysis

> ✅ **All feature gap items (FG-A, FG-B, FG-C) are resolved.** Resolutions are baked into the PRD and tracked in `docs/06-helpers/ideation-tracker.md`. Full text of resolved items has been removed from this document. All v2-deferred decisions are consolidated in `docs/01-product/prd-v2-draft.md`.

---

### FG-A — Existing Features: Edge Cases & Missing Detail

> ✅ **FG-A1 through FG-A11 were resolved on 2026-04-14 and baked into the PRD.** 
> See `docs/06-helpers/ideation-tracker.md` for the full decision log.
>
> ✅ **FG-A12 through FG-A31 were resolved on 2026-04-14 and baked into the PRD.** Resolutions summary:
> See `docs/06-helpers/ideation-tracker.md` for the full decision log.

---

### FG-B — Features Implied or Mentioned But Never Specified

> ✅ **FG-B1 through FG-B9 were resolved on 2026-04-14 and baked into the PRD.** FG-B3 and FG-B6 deferred with budgets to v2. 
> All v2-deferred decisions consolidated in `docs/01-product/prd-v2-draft.md`. 
> See `docs/06-helpers/ideation-tracker.md` for the full decision log.

---

### FG-C — Features Never Discussed

> ✅ **FG-C1 through FG-C21 were resolved on 2026-04-14.** Resolutions:
>
> - **Baked into v1 PRD:** FG-C2 (duplicate detection), FG-C6 (balance reconciliation — all accounts), FG-C11 (Indian numbering), FG-C12 (exchange rate estimate in entry), FG-C13 (currency symbol disambiguation), FG-C18 (large transaction warning + credit card limit validation), FG-C20 (back button behaviour).
> - **Deferred to v2:** FG-C4 (combined search + filter), FG-C5 (balance history), FG-C8 (budget period start day), FG-C9 (income budgets), FG-C10 (app data wipe), FG-C14 (account statement export), FG-C21 (auto-detect transactions from SMS/email — new item).
> - **Deferred to v3:** FG-C7 (Android home screen widget).
> - **Rejected:** FG-C1 (quick-entry templates — no value, UI clutter), FG-C15 (undo snackbar — standard delete suffices), FG-C19 (default account — no pre-selection).
> - **No action needed:** FG-C16 (photo storage on uninstall — accept Android default), FG-C17 (already resolved in prior sessions).
>
> See `docs/06-helpers/ideation-tracker.md` for the full decision log. All v2-deferred decisions consolidated in `docs/01-product/prd-v2-draft.md`.

---

## Part 4 — Founder Decisions (from TC Review)

> 5 items were escalated from the Technical Clarifications review because they require founder decisions. The PM and LE agree on the framing and options for each item; the founder decides. PM recommendations are marked below. Source: `docs/01-product/technical-clarifications.md`.

---

### TC-014: Category Icon Subset Size

| Field | Detail |
|-------|--------|
| **ID** | TC-014 |
| **Title** | Category icon subset size for the category picker |
| **The Problem** | Categories use icons from the `material_symbols_icons` Flutter package. The PRD says a "curated subset" will be bundled for the category picker, but neither the number of icons nor the selection criteria are defined. Someone needs to decide how many icons to include and which ones. |
| **Why it matters (Product)** | If the subset is too small, users cannot find an icon that matches their category (e.g., "Groceries" but no shopping cart icon). If the subset is too large, the picker becomes overwhelming and slow to browse. The default icon assignments for the built-in category tree also depend on this subset being defined. |
| **Why it matters (Engineering)** | The icon bundling strategy (tree-shaking individual icons vs. importing the full icon font) depends on the count. Binary size scales roughly linearly with the number of bundled icons. The category picker grid layout and any search/filter within it also depend on knowing the approximate count. |
| **Options** | **(A) ~200-300 icons** -- Covers all major spending/income categories with room for personal customization. Keeps the picker browsable with a search bar. Moderate binary size impact. **(PM recommendation.)** | 
| | **(B) ~100 icons** -- Minimal set. Smaller binary. Risk of users not finding appropriate icons for niche categories. |
| | **(C) ~500+ icons** -- Comprehensive. Larger binary (~1-2 MB additional). Picker needs robust search/filter to be usable. |
| **Blocks** | Default category icon assignments (PRD SS5.2.4, SS5.6.1). Category picker UX design (UX-11). Icon bundling strategy in SDS. |

---

### TC-022: Should Installments Support Transfer Transaction Type?

| Field | Detail |
|-------|--------|
| **ID** | TC-022 |
| **Title** | Installment support for transfer transactions (loan repayments) |
| **The Problem** | The PRD says installments generate entries "identical to Case 1.1 (expense) or 1.2 (income)" -- limiting them to expense and income types only. But the loan account installment suggestion (SS5.1.2) pre-fills a destination account (the loan account), which implies a transfer. Recurring templates already support all three types. The loan repayment use case -- arguably the primary reason installments exist -- is broken without transfer support. TC-038 is a duplicate of this same issue. |
| **Why it matters (Product)** | Loan repayment is a core installment use case. If you set up a loan account and want to create an installment plan to pay it off, you need a transfer from your bank account to your loan account. Without transfer support, there is no way to automate loan payments through installments, making the loan account feature significantly less useful. |
| **Why it matters (Engineering)** | Case 3.2 in `ledger-entry.md` needs to be updated to reference Cases 1.1, 1.2, AND 1.3 (or 1.3a if fee applies). The installment form needs source and destination account fields when the type is transfer. The template schema needs to accommodate all three transaction types. This also affects TC-038 (which is the same issue surfaced from a different angle). |
| **Options** | **(A) Installments support all three types: income, expense, transfer.** Consistent with how recurring templates already work. Enables the loan repayment use case. Requires updating Case 3.2 and the installment form to handle transfers. **(PM recommendation.)** |
| | **(B) Loan repayments modeled as expenses.** Conceptually incorrect from a double-entry bookkeeping perspective (a loan repayment is not an expense -- it reduces a liability). Would require rethinking the loan installment suggestion in SS5.1.2. |
| **Blocks** | Installment template schema design. Ledger-entry.md Case 3.2 update. Loan installment suggestion form (SS5.1.2). TC-038 resolution (duplicate). |

---

### TC-029: What Happens When Home Currency Changes?

| Field | Detail |
|-------|--------|
| **ID** | TC-029 |
| **Title** | Impact of home currency change on historical exchange rates |
| **The Problem** | The PRD says the home currency is "changeable at any time in Settings," but it does not address what happens to existing transactions. Every foreign-currency transaction stores an `exchange_rate_to_home` field -- that rate is relative to the home currency at the time of capture. If you change your home currency from USD to EUR, all those stored rates are now rates-to-USD, not rates-to-EUR. The app has no way to know the difference. |
| **Why it matters (Product)** | After changing home currency, all historical foreign-currency amounts would display incorrect home-currency equivalents. Net worth would be wrong. Category balance totals (which aggregate across currencies using these rates) would be wrong. Users may not understand why their numbers suddenly changed. |
| **Why it matters (Engineering)** | The `exchange_rate_to_home` field on every transaction becomes ambiguous after a currency change -- the app cannot tell which home currency the rate was captured against. Category balance computation (which sums amounts converted via these rates) would produce incorrect results. The schema needs to either prevent this scenario or store enough metadata to handle it. TC-046 (LE note) confirms that `home_currency_at_capture` is essential for correct category balance computation. |
| **Options** | **(A) Preserve stored rates as historical; refetch/recompute for new currency.** Expensive -- requires fetching historical exchange rates for every past transaction. May be impossible for old dates where rate data is unavailable. |
| | **(B) Allow change with a warning; store `home_currency_at_capture` alongside the rate.** Future logic can detect stale rates and either recompute or display with a caveat. Does not require retroactive refetching. Adds one field per transaction. **(PM recommendation.)** |
| | **(C) Restrict home currency changes when foreign-currency accounts exist.** Simplest engineering path. Prevents the problem entirely. May frustrate users who relocate or whose financial situation changes. |
| **Blocks** | `exchange_rate_to_home` schema design. Category balance computation logic. Net worth display logic. Any multi-currency aggregation. |

---

### TC-031: App Navigation Model

| Field | Detail |
|-------|--------|
| **ID** | TC-031 |
| **Title** | Top-level app navigation structure |
| **The Problem** | The PRD describes individual screens (home, settings, account detail, pending confirmations) but never specifies how the user moves between them. There is no defined top-level navigation structure -- no bottom bar, no drawer, no tab layout. Every "navigate to X" reference in the PRD is ungrounded. |
| **Why it matters (Product)** | This is the skeleton of the entire app. Every screen layout, every user journey, and every "navigate to X" reference depends on this decision. The entire UX Flows document (which is the next deliverable after PRD sign-off) cannot be started until this is resolved. UX-1, UX-2, and UX-3 all depend on this. |
| **Why it matters (Engineering)** | The GoRouter route hierarchy, the app's scaffold architecture (shell routes, nested navigation), and navigation state management all depend on this choice. It determines the top-level widget tree structure for the entire Flutter app. |
| **Options** | **(A) Bottom navigation bar with 3-4 tabs (e.g., Home, Accounts, Settings) plus a FAB or speed dial for transaction creation.** Standard Material 3 pattern. Always-visible tabs provide instant access to major sections. The transaction creation entry point (the most frequent user action) gets a prominent, persistent FAB. **(PM recommendation.)** |
| | **(B) Single primary screen (Home) with drawer navigation.** Simpler but less discoverable -- secondary screens are hidden behind a hamburger menu. Works for apps with one dominant screen but makes multi-section apps feel cramped. |
| | **(C) Bottom nav with 3 tabs (Home, Accounts, Settings) plus a floating action button for entry.** Similar to (A) but with a fixed 3-tab layout and a dedicated FAB rather than a speed dial. Slightly simpler than (A). |
| **Blocks** | UX Flows document (entirely -- cannot begin without this). GoRouter route hierarchy. Scaffold architecture. All screen-to-screen navigation references in the PRD. UX-1, UX-2, UX-3. |

---

### TC-050: Should Home Screen Search Override the Month Filter?

| Field | Detail |
|-------|--------|
| **ID** | TC-050 |
| **Title** | Home screen search scope -- month-filtered or global |
| **The Problem** | The PRD says search on the home screen operates on the "currently displayed (month-filtered) set." This means if you are viewing March and search for a transaction you made in February, you will not find it. The only way to search across all time is via the account detail screen, which only shows transactions for one account at a time. There is no cross-account, all-time search surface in v1. |
| **Why it matters (Product)** | Users frequently do not remember which month a transaction was in. Forcing them to navigate month-by-month to find a transaction is a significant usability limitation. The account detail screen provides a partial workaround (all-time search for a single account) but not a full solution. This is one of the most common frustrations in expense tracking apps. |
| **Why it matters (Engineering)** | If search overrides the month filter, the search query scope changes from "transactions in month X" to "all transactions." This is manageable within the 500ms performance target for 10k records. The search engine needs to support both scoped and global query modes. The home screen transaction list display needs to handle showing results from multiple months (date grouping headers, scroll position). |
| **Options** | **(A) Keep current spec -- home search is month-scoped.** Global cross-account search is deferred to v2 (FG-C4). Simpler to implement. Users must navigate month-by-month or use account detail for broader search. |
| | **(B) Home search ignores month filter when active; month filter re-engages when search is cleared.** Much better UX for the "find that transaction" use case. Manageable performance. Requires the transaction list to display results from multiple months with appropriate date grouping. **(PM recommendation.)** |
| **Blocks** | Search engine scope design (scoped vs. global query modes). Home screen search implementation. Home screen transaction list display (multi-month results handling). |
