---
name: Gaps and Open Questions
status: in progress
owner: pm
created: 2026-04-13
last_updated: 2026-04-14
version: 0.5.0
depends_on: [01-product/prd.md]
outputs_to: [02-technical/ux-flows.md, 02-technical/sds.md]
---

# Variance — Gaps & Open Questions

> **Last Updated:** 2026-04-14 (PRD v0.4.0)
>
> **Last Updated:** 2026-04-14 (PRD v0.5.0)
>
> This document is a comprehensive reference for product gaps and questions. It is organized into three parts:
>
> - **Part 1 — PRD Questions (Q47–Q76):** ✅ **ALL RESOLVED** in PRD v0.3.0. Question text removed from this document — resolutions are baked into the PRD body; the resolved questions log is in `docs/06-helpers/ideation-tracker.md`.
>
> - **Part 2 — UX Flows Pre-Work Topics (UX-1–UX-14):** Interaction design decisions that belong in `docs/02-technical/ux-flows.md`, not the PRD. These do not block the PRD sign-off but must be resolved before the UX Flows document can be completed. Items UX-7 and UX-8 are deferred with budgets to v2.
>
> - **Part 3 — Feature Gap Analysis:** A user-perspective audit of the PRD. FG-A1 through FG-A11 resolved on 2026-04-14 (PRD v0.4.0). FG-A12 through FG-A31 resolved on 2026-04-14 (PRD v0.5.0). FG-B and FG-C remain open.
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

> ✅ **FG-A1 through FG-A11 were resolved on 2026-04-14 and baked into PRD v0.4.0.** See `docs/06-helpers/ideation-tracker.md` for the full decision log.
>
> ✅ **FG-A12 through FG-A31 were resolved on 2026-04-14 and baked into PRD v0.5.0.** Resolutions summary:
> See `docs/06-helpers/ideation-tracker.md` for the full decision log.

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
