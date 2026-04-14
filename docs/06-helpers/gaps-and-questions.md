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

> **Last Updated:** 2026-04-14 (PRD v0.4.0)
>
> This document is a comprehensive reference for product gaps and questions. It is organized into three parts:
>
> - **Part 1 — PRD Questions (Q47–Q76):** ✅ **ALL RESOLVED** in PRD v0.3.0. Question text removed from this document — resolutions are baked into the PRD body; the resolved questions log is in `docs/06-helpers/ideation-tracker.md`.
>
> - **Part 2 — UX Flows Pre-Work Topics (UX-1–UX-14):** Interaction design decisions that belong in `docs/02-technical/ux-flows.md`, not the PRD. These do not block the PRD sign-off but must be resolved before the UX Flows document can be completed. Items UX-7 and UX-8 are deferred with budgets to v2.
>
> - **Part 3 — Feature Gap Analysis:** A user-perspective audit of the PRD identifying (A) existing features with unresolved edge cases or missing detail, (B) features mentioned or implied but never fully specified, and (C) features never discussed that a user would encounter or expect. Budget-related items are marked as deferred to v2. FG-A1 through FG-A11 were resolved on 2026-04-14 (PRD v0.4.0).
>
> The authoritative status of each question is tracked in `docs/06-helpers/ideation-tracker.md`.

---

## Part 1 — PRD Questions

> ✅ **All 30 questions (Q47–Q76) were resolved on 2026-04-13 and baked into PRD v0.3.0.** Resolutions are in the PRD document body. The full resolved questions log is in `docs/06-helpers/ideation-tracker.md`. Part 1 has been removed from this document — see those sources for details.

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

> Errors found in existing documents that need to be fixed.

| ID | Document | Section | Error |
|----|----------|---------|-------|
| ERR-1 | `docs/01-product/prd.md` | §4.5 Transaction Rules by Type — Expense | Debit/credit sides are reversed. PRD says "expense category entry (credit side), account entry (debit side)" but §4.11 Case 1.1 and `ledger-entry.md` Case 1.1 both record `Dr EC, Cr A` — expense category is **debited**, source account is **credited**. **Fix: swap the side labels in §4.5.** |

---

## Part 3 — Feature Gap Analysis

> This section is a user-perspective audit of the PRD. It is organized into three groups:
>
> - **FG-A** — Existing features that are underspecified, missing edge case handling, or have details that need to be fleshed out before SDS/UX can proceed.
> - **FG-B** — Features mentioned or implied in the PRD but never fully discussed.
> - **FG-C** — Features never considered that a user would reasonably expect.
>
> Each item has a user-impact note. Items marked **[SDS]** have schema or architectural implications. Items marked **[Policy]** require a product decision before proceeding.

---

### FG-A — Existing Features: Edge Cases & Missing Detail

> ✅ **FG-A1 through FG-A11 were resolved on 2026-04-14 and baked into PRD v0.4.0.** Resolutions are in the PRD body (§4.6, §5.1.1–§5.1.7, §5.2.2, §5.2.4, §5.2.7). See `docs/06-helpers/ideation-tracker.md` for the full decision log.

---

#### FG-A12 — Transaction Filter: Amount Range Is Missing

§5.2.6 defines the full filter criteria set. There is no amount range filter.

**Gap:** Can the user filter transactions by amount (e.g., "show all expenses above Rs. 1,000" or "between Rs. 500 and Rs. 2,000")? Amount range filtering is one of the most common use cases in personal finance — identifying large purchases, finding specific transactions by value.

**[Policy]**

---

#### FG-A13 — Transaction Filter: Multi-Select on Category and Combining Logic

§5.2.6 allows filtering by category (contextual). It does not specify whether multiple categories can be selected simultaneously, or whether filters are combined with AND or OR logic.

**Gap:** (1) Can the user select "Food OR Transportation" as a combined category filter? (2) Are all filter criteria combined with AND (expense AND food AND last month AND has photo)? (3) If the user selects both a category filter and the "Is voided" filter, does the result show voided food transactions?

**[Policy]**

---

#### FG-A14 — Transaction Filter: State Persistence

The PRD defines a "dedicated filter view" but doesn't specify whether the applied filter persists when the user navigates away from the transaction list and returns.

**Gap:** Does the filter state reset on navigation (every time you leave the list, filters clear), or persist until the user explicitly clears them? A persistent filter is powerful but confusing ("why does my list look wrong?"). A clearing filter is safer but requires re-applying on every return.

**[Policy]**

---

#### FG-A15 — Transaction Search: "Fuzzy" Is Undefined

§5.2.5 says "fuzzy search across all fields." Fuzzy search is an overloaded term.

**Gap:** Define what "fuzzy" means: (a) substring/contains match (typing "groc" finds "Groceries"); (b) typo-tolerant match (typing "grocieries" still finds "Groceries"); (c) full-text search with ranking. The choice affects performance, library selection (SQLite FTS vs. custom), and user expectations. Searching by amount (e.g., "500") also needs definition — does it match exact amounts only, or amounts containing "500" (so 5000 also matches)?

**[SDS]**

---

#### FG-A16 — Transaction List Sort Order

The PRD never defines the default sort order for the transaction list, or whether the user can change it.

**Gap:** Is the transaction list always sorted by date descending (most recent first)? Can the user sort by amount, by category, or ascending/descending? Sort order is a basic table UX affordance that's entirely unspecified.

**[Policy]**

---

#### FG-A17 — Budget Creation Fields Are Never Specified *(Deferred to v2 with budgets)*

§5.3.1 describes the budget model conceptually but never defines what fields are required to create a budget.

**Gap:** What does the "create budget" form look like? Required fields presumably include: budget name, amount, time horizon (weekly/monthly/quarterly/annual), and whether it's a total budget or a per-category budget (and if per-category, which category). Are there optional fields (notes, start date for the first period)?

**[Policy]**

---

#### FG-A18 — Budget Currency: Home Currency Only? *(Deferred to v2 with budgets)*

§5.3.1 defines budgets in terms of amounts, but never specifies what currency a budget is denominated in.

**Gap:** Are budgets always in the home currency? If a user has accounts in USD and INR, and the home currency is INR, does an expense in USD get converted to INR before being counted against the budget? At what rate — the cached exchange rate? If the rate is stale (up to 14 days old per §7), the budget accounting could be meaningfully inaccurate for foreign-currency spenders.

**[Policy] [SDS]**

---

#### FG-A19 — Budget Period Start Day *(Deferred to v2 with budgets)*

§5.4.2 has a "week start" setting (Monday/Sunday). Monthly budgets presumably run from the 1st to the last day of the month. But many users are paid mid-month (e.g., the 15th or 25th) and want their budget month to align with their pay cycle.

**Gap:** Is the monthly budget period always the calendar month (1st–last), or can the user configure a custom monthly start day? If configurable, this is a per-budget setting or a global settings option.

**[Policy]**

---

#### FG-A20 — Budget Rollover: Overspend Carries Forward Too? *(Deferred to v2 with budgets)*

§5.3.5 says rollover carries "unused remaining budget ($N$ at period end)" forward. This implies rollover only applies to underspend.

**Gap:** If the user overspent by Rs. 500 in January and rollover is enabled, does February's budget start at `M − 500` (penalising the overspend) or simply at `M` (ignoring the overspend)? And is there a maximum rollover cap — to prevent a user who never spends from accumulating years of unused budget that makes the feature meaningless?

**[Policy]**

---

#### FG-A21 — Budget: What Transactions Count Against It? *(Deferred to v2 with budgets)*

§5.3.3 says "real-time comparison of budgeted amount vs. actual spending." What exactly counts as "spending"?

**Gap:** (1) Do only expense transactions count, or do transfers also reduce the budget? (2) Does the "Balance Adjustment" protected category count against any budget? (3) Are voided/reversed transactions excluded from the budget calculation? (4) If a child recurring transaction is voided, is the budget retroactively updated? (5) Does a transaction count against the budget of the period when it was *recorded*, or when its *date* falls?

**[Policy] [SDS]**

---

#### FG-A22 — Forgotten PIN: No Recovery Path

§5.4.3 defines PIN lock with biometric fallback. There is no mention of what happens when the user forgets their PIN and biometric fails (or biometric is not enrolled).

**Gap:** Since there is no cloud account and no recovery email, forgetting the PIN means the user is permanently locked out of all their financial data. Options: (a) accept this as a consequence of local-only design (user must uninstall, losing all data); (b) offer a recovery via a backup code shown during PIN setup; (c) allow PIN reset via device credential (device pattern/PIN). This is a critical UX and data-safety question.

**[Policy]**

---

#### FG-A23 — Failed PIN Attempts: No Lockout Defined

Related to FG-A22: what happens after N consecutive failed PIN attempts?

**Gap:** Is there a lockout delay (increasing delays after each failure)? A temporary full lock? A limit before the app self-destructs data? Or no limit at all (infinite attempts allowed)? No lockout policy means a brute-force attack on a 4-digit PIN requires at most 10,000 attempts.

**[Policy]**

---

#### FG-A24 — "Balance Adjustment" in Income and Expense Trees: Name Collision

The protected "Balance Adjustment" category exists in both the income and expense trees. Both are named "Balance Adjustment." They are system-managed and not user-selectable.

**Gap:** When a "Balance Adjustment" transaction appears in the transaction list, how does the user distinguish whether it was an income-direction or expense-direction adjustment? The category name alone is ambiguous. The transaction type (income vs. expense) differentiates them, but this depends on Q53 (title/description display) and Q72 (correction visibility).

**[Policy]**

---

#### FG-A25 — Category Picker During Edit: Soft-Deleted Category Is the Current Value

When a user edits a transaction whose category has since been soft-deleted, the category picker no longer shows that deleted category (per §5.2.4: "soft-deleted categories are hidden from the category picker in new transaction entry"). However, the current transaction is referencing it.

**Gap:** In the edit flow, what is shown as the currently selected category when it's soft-deleted? Is it shown as a disabled/greyed entry at the top of the picker? Is the user forced to select a new category before saving? Or is the deleted category shown with a "(deleted)" label?

**[Policy]**

---

#### FG-A26 — Net Worth View: Excluded Accounts — Shown Separately or Hidden?

§5.1.4 says accounts flagged as excluded from net worth are "shown separately or not shown." This is ambiguous.

**Gap:** Explicitly define: are excluded accounts (a) shown in a separate "excluded from net worth" section below the main net worth total, (b) hidden entirely from the net worth screen and only accessible from the accounts list, or (c) shown grayed-out inline?

**[Policy]**

---

#### FG-A27 — Transfer Fee / Same-Currency Transfer With an Incidental Cost

A bank transfer between two accounts of the same currency may incur a transaction fee (e.g., NEFT/IMPS fee of Rs. 5–25). The transfer transaction itself moves the principal amount, but the fee is a separate expense.

**Gap:** Is there a "transfer fee" field on the Transfer transaction entry form? Or is the user expected to record a separate expense transaction for the fee? If separate, the workflow is two actions for one real-world event. If bundled, the DEB posting is more complex (Dr A₂, Cr A₁ for principal; Dr Expense category, Cr A₁ for fee — combined into one transaction with 3+ entries).

**[Policy] [SDS]**

---

#### FG-A28 — Installment and Loan Account: No Defined Connection

The app has a Loan account category (§5.1.2) with EMI amount and interest rate fields. It also has an Installment transaction sub-type (§5.2.8). These two concepts seem naturally related — an installment series should ideally post payments against the Loan account — but the PRD never connects them.

**Gap:** (1) Can an installment transaction template be linked to a Loan account so that each installment auto-generates a transfer payment to the loan? (2) If not, the Loan account's "EMI amount" and "EMI date" fields are metadata with no functional behaviour — the user must manually remember to create a recurring transaction aligned to these values.

**[Policy]**

---

#### FG-A29 — Account Deletion: What If the Only Other Account Is a Different Currency?

§5.1.1 describes a flow where the user can transfer their remaining balance to another account before soft-deleting. Cross-currency transfers are blocked in v1 (Q46/§7).

**Gap:** If the user only has one other account and it is in a different currency, the balance transfer option is impossible. The app must handle this case: (a) skip the transfer offer entirely and go straight to the net-worth-change warning, (b) inform the user "no same-currency account available for transfer", or (c) block deletion until the user creates a same-currency account. None of these cases is defined.

**[Policy]**

---

#### FG-A30 — Accessibility: Font Scaling, TalkBack, and RTL

§NF-5 states "WCAG 2.1 AA baseline" but nothing else.

**Gap:** Three specific accessibility dimensions are unaddressed:
1. **Font scaling**: Android allows users to set a system font scale (up to 200%). Does the app's UI adapt gracefully at large font sizes, or do elements overflow/clip?
2. **TalkBack (screen reader)**: Are interactive elements properly labelled for Android's screen reader? This requires explicit semantic labelling in the UI layer.
3. **RTL layout**: Android supports right-to-left layouts. Is RTL support in scope? Many Indian users use English UI but if the app is distributed internationally, RTL will matter.

**[Policy]**

---

#### FG-A31 — Data Loss on Device Loss: No Backup in v1

§8 explicitly defers "data management: backup/restore, CSV export, CSV import, data wipe" to v2. This means v1 has **zero** data recovery mechanism.

**Gap:** If the user's device is stolen, lost, or factory-reset, all financial history is permanently gone. There is no local backup file, no export, no cloud sync. This is a deliberate constraint but one that users will hit. The app should at minimum surface a clear warning that data is not backed up, and ideally offer some basic local backup in v1 (e.g., a single "export to file" action with no import support). This is worth explicitly calling out as a known gap accepted for v1.

**[Policy]**

---

### FG-B — Features Implied or Mentioned But Never Specified

#### FG-B1 — Transaction Detail View: Content Never Defined

The PRD defines what fields are collected on transaction entry (§5.2.1) but never specifies what a transaction detail view shows after the fact.

**Gap:** What additional information does the detail view surface that the list row does not? Candidates:
- Full description (long-form text)
- Photo attachments (thumbnail grid with tap-to-expand)
- The recurring template this transaction was generated from (if applicable)
- The budget pool(s) this transaction was added to (if any)
- Correction history: "This transaction was corrected on [date]" (connected to Q72)
- Timestamps: created at, last edited at

This is a foundational screen in the app and entirely undefined.

---

#### FG-B2 — Home Screen Dashboard: Content Undefined

§8 (in-scope for v1) lists "basic home summary (account balances, net worth)" but this is the entire specification for the home screen.

**Gap:** What does the home screen show? Reasonable candidates:
- Net worth figure (prominently)
- Account list with current balances (or a summarised version)
- Income vs. expense summary for the current period (this month)
- A "recent transactions" list (how many? from all accounts?)
- Budget at-a-glance widget (current period spend vs. budget)
- Quick-entry FAB (connects to UX-2)

None of these are confirmed or denied in the PRD. The home screen is the first thing the user sees every time they open the app.

---

#### FG-B3 — In-App Alert History: Where Do Past Alerts Go? *(Deferred to v2 with budgets)*

§5.3.4 says in-app alerts fire at configurable thresholds. Once an alert fires, what happens to it?

**Gap:** Is the alert a one-time event (fires once at the threshold, never repeats for the same budget period)? Or does it fire every time the threshold is crossed (including correction-triggered recalculations)? Where does the alert go after it fires — is there a notification center / alert history the user can review, or does it disappear forever after dismissal?

---

#### FG-B4 — Recurring Transaction: "Remind and Confirm" Inbox

§5.2.7 says recurring transactions in "remind and confirm" mode prompt the user to review and confirm before posting. There must be a UI surface where pending confirmations live.

**Gap:** Is there a dedicated "pending confirmations" screen? Or are pending items surfaced inline on the home screen? What does a pending confirmation item show (template name, scheduled date, amount, account, category)? Can the user edit the amount/details before confirming?

---

#### FG-B5 — Category Usage Count / Impact Warning on Deletion

When the user soft-deletes a category that is referenced by hundreds of historical transactions, they should be informed of the impact.

**Gap:** Does the app show "This category is used by 47 transactions. Deleting it will not affect those transactions, but it will be removed from the filter and picker." This is a transparency affordance. Without it, the user may not understand the consequences of deleting a category.

---

#### FG-B6 — Budget and Soft-Deleted Categories *(Deferred to v2 with budgets)*

If a per-category budget exists for a category that is subsequently soft-deleted, what happens to the budget?

**Gap:** Options: (a) the budget is automatically archived; (b) the budget continues to exist but shows "deleted category" as its label; (c) the budget is blocked from being created for a deleted category (already covered), but existing ones become orphaned. This is a data integrity question with budget-engine implications.

**[Policy] [SDS]**

---

#### FG-B7 — Installment: Early Completion and Final Reconciliation

§5.2.8 notes that per-installment amounts can be adjusted manually and the total may not match the target (non-blocking warning). But it never specifies what happens at the end of the installment series.

**Gap:** (1) If the sum of posted installments is less than the target total (because individual amounts were reduced), does the app flag this as an outstanding balance? (2) Can the user mark the installment series as "paid in full" regardless of the total tracking? (3) Is there an "overpay" installment if the user paid more in some periods and wants to close the series early?

---

#### FG-B8 — "Per-Account Settings" in Settings: Vague

§5.4.4 lists "Settings > Accounts: view and manage all accounts, including soft-deleted; per-account settings." The phrase "per-account settings" is undefined.

**Gap:** What are "per-account settings"? The account edit form covers name, notes, include-in-net-worth, and category-specific fields. Are there additional settings accessible only from Settings > Accounts that are not available from the account edit form? Or is "per-account settings" just another way of saying "edit account"?

---

#### FG-B9 — Transactions From Soft-Deleted Accounts in Search and Filter

§5.1.1 says soft-deleted accounts are "hidden from all user-facing views." But the transaction list and search cover all transactions.

**Gap:** If a user searches for a transaction that was recorded against a soft-deleted account, does it appear in search results? What is the account label on that transaction (the account name, or "(deleted account)")?

---

### FG-C — Features Never Discussed

#### FG-C1 — Transaction Quick-Entry Templates (Not Recurring)

Recurring transactions auto-post on a schedule. But there is no concept of a "saved template" for manual quick-entry. A user who buys coffee every few days at roughly the same amount wants to tap a template, adjust the amount if needed, and confirm — without filling in all fields from scratch every time.

**Gap:** Should v1 support user-saved transaction templates for manual reuse? This is distinct from recurring (no schedule, no auto-post — purely a form pre-fill). Could be implemented as a "Save as template" action in the transaction entry form.

---

#### FG-C2 — Duplicate Transaction Detection

When a user manually enters a transaction, they may accidentally enter it twice (same amount, same date, same category, same account). No detection or warning mechanism is defined.

**Gap:** Should the app detect probable duplicates and surface a warning? Rule example: if a transaction with the same type, amount, account, and category already exists within a 1-hour window of the submitted date/time, show "A similar transaction already exists. Add anyway?" This is a common UX safeguard in finance apps.

---

#### FG-C3 — Transaction List Sorting

The PRD defines filter but never defines sort. The default is presumably date descending (most recent first), but this is never stated.

**Gap:** Can the user sort the transaction list? Candidate sort fields: date (asc/desc), amount (asc/desc), category (alphabetical). Even confirming that "date descending is the only sort and it is not user-changeable" would close this gap.

---

#### FG-C4 — Combined Search + Filter

Search and filter are defined as separate features (§5.2.5 and §5.2.6). Their interaction is never defined.

**Gap:** Can the user apply a text search AND a filter simultaneously (e.g., search for "coffee" within expense transactions in the last 30 days)? Or are search and filter mutually exclusive modes?

---

#### FG-C5 — Balance History / Mini Chart Per Account

Many personal finance apps show a simple line chart of balance over time for each account. This gives users a quick visual of spending trends without needing full analytics (a v2 feature).

**Gap:** Is a per-account balance history chart in scope for v1? It is derivable purely from the ledger with no new data — the chart data is the account balance at the start of each day, computed from existing entries. If deferred to v2, call it out explicitly.

---

#### FG-C6 — Cash Reconciliation Workflow

For cash accounts, the computed balance (from ledger entries) and the physical cash in hand frequently diverge. Users periodically count their cash and reconcile.

**Gap:** Is there a "reconcile" shortcut for cash accounts? A reconcile flow would: (1) prompt the user to enter the physical cash amount; (2) compute the difference; (3) post a journal adjustment for the discrepancy. This is essentially a faster path to the existing direct balance edit, but optimised for the reconciliation use case. Without it, users must manually calculate the difference and use the journal adjustment flow.

---

#### FG-C7 — Android Home Screen Widget

An Android app widget showing key figures (current balance, today's spending, net worth) is a standard companion feature for finance apps. Users want a glanceable view without opening the app.

**Gap:** Is a home screen widget in scope for v1 or v2? If v2, note it. If never, note why (privacy concern — widget visible on lock screen without PIN?).

---

#### FG-C8 — Budget Period Start Day Configuration *(Deferred to v2 with budgets)*

§5.4.2 has a "week start" setting. There is no analogous "budget month start day" setting.

**Gap:** Many users receive income on a non-1st date (e.g., the 25th of every month). Their natural "spending month" runs from the 25th to the 24th. Should the user be able to configure when a monthly budget period begins? Without this, the budget resets on the 1st regardless of the user's pay cycle, making the budget-to-income comparison less meaningful.

---

#### FG-C9 — Income Categories in Budget Context *(Deferred to v2 with budgets)*

Budgets track expense spending. Income is added to a budget pool via "Add to Budget." But the PRD never addresses whether income categories are relevant to budget reporting.

**Gap:** Should there be an "income budget" or "savings target" — a goal for how much income to earn in a period, separate from the expense budget? This may be v2, but it's a common feature in finance apps and worth explicitly deferring.

---

#### FG-C10 — App Data Wipe / Factory Reset

"Data wipe" is deferred to v2 (§8). In v1, there is no way for the user to clear all their data without uninstalling the app.

**Gap:** This means if a user wants to start over (e.g., they were testing the app, or they want to hand their device to someone else), they must uninstall and reinstall. Is there a "reset all data" option accessible from Settings even in v1? Consider also: what happens to app-private photo storage when the app is uninstalled — is it also deleted (yes, by Android design) or does it persist?

---

#### FG-C11 — Indian Numbering Format (Lakh/Crore)

The default expense categories (Food, Transportation, Household, etc.) and subcategories (IFSC, Splitwise, Auto, Metro, etc.) are clearly designed for an Indian user base. The Indian numbering system groups numbers as `xx,xx,xxx` (lakh/crore format, e.g., ₹10,00,000 = 10 lakh), not the Western `x,xxx,xxx`.

**Gap:** §5.4.2 defines "number format: decimal separator and thousands grouping style" but doesn't explicitly list Indian grouping (2-2-3 from the right) as an option. This must be explicitly supported if the primary audience is Indian.

---

#### FG-C12 — Offline Exchange Rate Freshness in Transaction Entry

§7 defines a staleness indicator in the net worth view when the cached rate is older than 14 days. But exchange rates are also used when displaying multi-currency balances elsewhere.

**Gap:** When recording a transaction against a foreign-currency account, the user may want to know the current approximate exchange rate for context. Is there any exchange rate reference shown during transaction entry? What if the rate is stale or unavailable — is there any indication at the point of entry?

---

#### FG-C13 — Currency Symbol Ambiguity

The ISO 4217 list includes currencies with ambiguous or shared symbols (e.g., multiple countries use "$", "£" is shared by GBP and several others historically, "R" is used by ZAR and BRL).

**Gap:** When displaying amounts for two accounts with the same symbol but different currencies, how are they distinguished in the UI? Is the 3-letter ISO code (USD, SGD, AUD) shown alongside the symbol, or just the symbol?

---

#### FG-C14 — Account Statement Export (Basic, Even Without Full CSV)

The PRD defers all data export to v2. But an "account statement" (a printable or shareable per-account transaction history) is a basic feature even in simple finance apps — used when splitting bills, sharing expense summaries, or providing transaction records.

**Gap:** Is a basic "share account statement as text/PDF" feature entirely out of v1? If so, explicitly note this as a known gap.

---

#### FG-C15 — Undo for Recently Created Transactions

The soft-delete model gives the user a way to "undo" a posted transaction — but only by explicitly deleting it (navigating to it, opening it, soft-deleting it). There is no immediate undo affordance at the moment of creation.

**Gap:** After saving a new transaction, should there be a brief "Undo" snackbar (e.g., 5 seconds) that removes the just-posted transaction? This is a standard mobile UX pattern for irreversible-feeling actions, and a misfired transaction (wrong amount, wrong account) is one of the most common user errors in finance apps.

---

#### FG-C16 — Photo Storage on App Uninstall

§5.2.3 says photos are stored in a "dedicated app-private data folder." Android's app-private storage is automatically deleted when the app is uninstalled.

**Gap:** This interacts with FG-A31 (no backup in v1). The PRD should explicitly state: photos are stored in app-private storage and are permanently lost if the app is uninstalled. This is acceptable given the offline-first constraint, but it should be a documented known limitation — especially since photos may be receipts or important records.

---

#### FG-C17 — Recurring Transaction: "Pause / Disable" Feature

Q57 asks about pausing recurring templates as an open question on the contextual menu. But the underlying product question — whether pause is a feature at all — belongs in the PRD, not just as a menu action question.

**Gap:** Should the app support pausing a recurring template (temporarily suspending auto-post without archiving the template)? Real-world need: a user's monthly gym subscription is suspended for 2 months. They don't want to delete the recurring template (they'd need to recreate it), but they also don't want it to post for 2 months. A pause-with-resume-date or pause-until-manually-resumed would address this.

---

#### FG-C18 — Transaction Amount: Validation Upper Bound

§4.4 requires amount > 0. There is no defined upper bound.

**Gap:** Is there a maximum transaction amount? In theory no, but in practice very large amounts can result from typos (entering 1000000 instead of 10000). Should there be a soft warning for transactions above a configurable threshold (e.g., "This is a large transaction — Rs. 10,00,000. Confirm?")? Or is validation limited to > 0 only?

---

#### FG-C19 — Default Account on Transaction Entry

When the user opens the transaction entry form, is there a default account pre-selected? If yes, what is the default — the most recently used account, the account with the highest balance, the first account created?

**Gap:** A pre-selected default saves taps for users who primarily use one account. The default selection logic is entirely undefined.

---

#### FG-C20 — Keyboard Behavior and Back Navigation During Transaction Entry

When the user is partway through entering a transaction and presses the Android back button, what happens?

**Gap:** Options: (a) the form is discarded immediately with no warning (data loss); (b) a "Discard changes?" confirmation dialog appears; (c) the partial entry is auto-saved as a draft. Finance apps frequently show (b). This is a UX flow topic but the policy (discard vs. draft) is a product decision.

**[Policy]**
