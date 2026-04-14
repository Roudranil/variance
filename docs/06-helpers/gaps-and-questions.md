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
> This document is a comprehensive reference for product gaps and questions. It is organized into three parts:
>
> - **Part 1 — PRD Questions (Q47–Q76):** ✅ **ALL RESOLVED** in the PRD. Question text removed from this document — resolutions are baked into the PRD body; the resolved questions log is in `docs/06-helpers/ideation-tracker.md`.
>
> - **Part 2 — UX Flows Pre-Work Topics (UX-1–UX-14):** Interaction design decisions that belong in `docs/02-technical/ux-flows.md`, not the PRD. These do not block the PRD sign-off but must be resolved before the UX Flows document can be completed. Items UX-7 and UX-8 are deferred with budgets to v2.
>
> - **Part 3 — Feature Gap Analysis:** ✅ **ALL RESOLVED.** FG-A1 through FG-A31 resolved on 2026-04-14. FG-B1 through FG-B9 resolved on 2026-04-14; FG-B3 and FG-B6 deferred with budgets to v2. FG-C1 through FG-C21 resolved on 2026-04-14; 7 baked into v1, 7 deferred to v2, 1 deferred to v3, 3 rejected, 2 no action needed.
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
