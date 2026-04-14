---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 06-helpers/gaps-and-questions.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Feature gap resolution — FG-A1 through FG-A11 (Part 3, Group A of `gaps-and-questions.md`). PRD bumped to **v0.4.0**.

---

## `docs/01-product/prd.md`

### Bug fix

- **§4.5 Expense entry sides corrected (ERR-1):** The expense rule previously listed the expense category on the "credit side" and the source account on the "debit side" — the reverse of the correct DEB posting. Fixed to: expense category on **debit side**, source account on **credit side**. Consistent with §4.11 Case 1.1 (`Dr EC, Cr A`).

### §4.6 — Universal Balance Formula (replaces asset/liability split)

- Removed separate asset and liability balance formulas.
- All user-facing accounts now use a single formula: `balance = Σdebit − Σcredit`.
- Positive balance = asset state; negative balance = liability state.
- No explicit asset/liability designation field on accounts.
- UI communicates sign via colour and labelling, not raw sign characters.
- Income/expense category formulas unchanged (internal only).

### §4.9 — EQ Posting Direction

- Replaced "by account type" with **"by initial balance sign"**:
  - B > 0: `Dr A, Cr EQ` → balance = +B.
  - B < 0: `Dr EQ, Cr A` → balance = −|B|.
  - B = 0: no posting.
- Updated net-worth exclusion proof to use universal-formula framing.

### §4.10 — Balance Adjustment Direction

- Replaced the separate liability-specific income/expense direction rules with a single universal rule:
  - Balance ↑ (toward +∞) = income (`Dr A, Cr BAI`).
  - Balance ↓ (toward −∞) = expense (`Dr BAE, Cr A`).
  - Applies uniformly to all account types including credit cards.

### §4.11 — Ledger Posting Table

- Renamed cases 2.2a/2.2b from "Asset/Liability Account" to **"initial balance B > 0 / B < 0"**.
- Removed cases 2.3c, 2.3d, 2.4c, 2.4d (former liability-specific cases — subsumed by 2.3a/2.3b and 2.4a/2.4b under universal formula).
- Updated trailing note to explain the collapse.

### §5.1.1 — Account CRUD

- **Currency field:** Default changed to home currency. Added immutability note in table.
- **Currency Immutability section added:** info tooltip + visual change indicator + confirmation dialog before save.
- **Delete last account:** "Cannot delete" statement expanded to specify that the **delete action is disabled (greyed out)**, not a runtime error, with tooltip text.
- **New section — Recurring/installment template handling on account deletion:** Blocking warning with "Migrate templates" or "Stop templates" options; default is Stop; fires before the existing balance-transfer flow.

### §5.1.2 — Account Categories

- **Credit Card:** Removed CVV field. Card number changed from "hashed/masked" to "encrypted; masked display". Linked bank account marked optional.
- **Debit Card:** Removed CVV field. Card number changed from "hashed/masked" to "encrypted; masked display". Linked bank account marked optional with "metadata only" qualifier.
- **Loan:** Removed "loan direction (asset — owed to me / liability — owed by me)" field.
- **New notes block added** after table:
  - Field encryption: card numbers and bank account numbers encrypted at rest. **CVV never stored in any form in any version.**
  - Loan account direction: inferred from balance sign (positive = owed to you, negative = you owe).
  - Linked bank account behaviour by category (Debit Card = metadata only; Credit Card = functional — payment reminders + pre-fill).

### §5.1.3 — Account Balance Model

- Updated case references from `2.3a–2.3d` to `2.3a–2.3b` and `2.4a–2.4d` to `2.4a–2.4b`.
- Removed "by account type (asset vs. liability)" qualifier — universal formula applies.

### §5.1.4 — Account Balance View

- **New: Negative balance visual treatment** — warning colour for liability-state accounts; no minus sign in primary display; accessibility labelling deferred to UX Flows.
- **New: Overdraft warning** — non-blocking inline warning when a transaction would push balance below zero. User may dismiss and proceed.

### §5.1.5 — Internal Transfer

- Updated credit card payment note to use universal-formula language: "Dr CreditCard, Cr SourceAccount" increases credit card balance toward zero (reduces negative outstanding).

### §5.1.6 — Credit Card Balance Model (new section)

- Defines **outstanding balance** (live ledger) and **statement balance** (derived from billing period; not stored separately).
- Specifies **two-action balance edit screen**: (1) adjust statement balance (dated to billing date), (2) adjust outstanding balance (dated today). Both use standard journal adjustment flow.

### §5.1.7 — Credit Card Payment Reminders (new section)

- Automatic local notification schedule: 1 day after billing date; 7/1/0 days before payment due date.
- Each notification includes a **Pay** action.
- **Pay FAB** on credit card detail screen.
- **Payment entry form**: transfer type, destination = this credit card (fixed), source = linked bank account (pre-filled if set), amount = statement balance (pre-filled; editable).
- Notifications re-schedule on any billing/payment date edit. Reuses `SCHEDULE_EXACT_ALARM` + `POST_NOTIFICATIONS` permissions.

### §5.2.2 — Transaction Editing

- **Date/time added to the in-place editable fields list** (alongside title, description, photos). No correcting ledger entries posted for date changes. User responsible for date accuracy.

### §5.2.4 — Transaction Categories

- **New: Recurring/installment template handling on category deletion** — blocking warning (same flow as account deletion) with migrate or stop options; default stop. Fires in addition to the existing transaction-migration prompt.

### §5.2.7 — Recurring Transactions

- **New: End-of-month day handling** — if scheduled day doesn't exist in a month, post on the last valid day of that month.
- **New: Missed transactions on app launch** — all missed auto-post occurrences posted on next launch; remind-and-confirm occurrences past the 24h window are auto-approved and posted; paused-period skips are not retroactively posted.

### §8 — In-Scope vs. Out-of-Scope

- **Added to v1 in-scope:** Universal balance formula; account currency immutability; negative balance visual treatment + overdraft warning; credit card two-balance model; credit card payment reminder system; recurring/installment template handling on account/category deletion; date/time as in-place editable field.
- **Added to v2 deferred:** Split transactions (single payment split across multiple categories/accounts).

### §11 — Open Questions

- Updated note to reference FG-A1–A11 resolution (2026-04-14, PRD v0.4.0) and point to remaining open gap items (FG-A12+, FG-B, FG-C).

---

## `docs/01-product/ledger-entry.md`

- **Notation table updated:** Removed distinct `L` (liability account) symbol. `A` now represents any user-facing account. Added "Sign meaning" column to balance conventions table. Added universal formula note.
- **Case 1.1 note:** Updated credit card language to use universal formula ("crediting the credit card decreases its balance — makes it more negative — more owed").
- **Case 1.2:** Removed obsolete Q41 inconsistency flag (resolved).
- **Case 1.3 note:** Updated credit card payment language to use universal formula.
- **Case 2.2b:** Updated from "Liability Account (L), balance B > 0" to **"Account with initial balance B < 0"**. Posting `Dr EQ, Cr A` now explicitly produces a negative balance (−|B|).
- **Cases 2.3a/2.3b:** Re-framed as "balance ↑ toward +∞" and "balance ↓ toward −∞" (universal, not asset-specific). Examples added covering credit card scenarios.
- **Cases 2.3c/2.3d removed:** Collapsed into 2.3a/2.3b with a universal coverage note.
- **Cases 2.4c/2.4d removed:** Collapsed into 2.4a/2.4b with a universal coverage note.
- **Case 2.5:** Removed "B ≥ 0" qualifier (accounts can now be deleted in liability state).

---

## `docs/06-helpers/gaps-and-questions.md`

- Frontmatter `last_updated` updated to 2026-04-14.
- Header note updated to reference PRD v0.4.0 and FG-A1–A11 resolution.
- **New Part 0 — Internal Errors & Inconsistencies** added: documents ERR-1 (§4.5 expense entry sides bug, identified and fixed in this session).
- **FG-A1 through FG-A11 removed** from Part 3 FG-A section. Replaced with a single resolved-notice block referencing PRD v0.4.0 and the ideation-tracker.

---

## `docs/06-helpers/ideation-tracker.md`

- Frontmatter and header `last_updated` updated to 2026-04-14 (PRD v0.4.0).
- PRD deliverable status updated to v0.4.0.
- **Key Decisions Log:** 2026-04-14 entry added covering all FG-A1–A11 decisions, the ERR-1 fix, and the ledger-entry.md updates.
