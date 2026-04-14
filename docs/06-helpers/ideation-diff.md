---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 06-helpers/gaps-and-questions.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 4)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Feature gap resolution — FG-C1 through FG-C21 (Part 3, Group C of `gaps-and-questions.md`). 7 items baked into v1 PRD, 7 deferred to v2, 1 deferred to v3, 3 rejected, 2 no action needed. FG-C21 (auto-detect transactions from SMS/email) is a new item added during this session. v2 draft PRD updated with new §21 and resolved FG-C table.

---

## `docs/01-product/prd.md`

### TOC

- Added §5.1.3a Balance Reconciliation entry.

### §5.1.3a — Balance Reconciliation (new sub-section, FG-C6)

- **New "Balance Reconciliation" sub-section** added after §5.1.3.
- Reconcile action available on all accounts (not just cash).
- Flow: display computed balance → user enters actual balance → app computes discrepancy → standard journal adjustment prompt (§4.10).
- Access from account contextual menu and account detail screen.

### §5.1.4 — Account Balance View (Credit Card Limit Warning, FG-C18)

- **New "Credit card limit warning" paragraph** added after overdraft warning.
- Non-blocking inline warning when expense/transfer would exceed configured credit limit.

### §5.2.1 — Transaction Entry (Duplicate Detection, FG-C2)

- **New "Duplicate Transaction Detection" block** added before §5.2.2.
- Same type + amount + account + category on the same calendar day triggers non-blocking warning.
- User confirms or cancels. No auto-delete.

### §5.4.2 — Primary Configuration (FG-C11, FG-C18, FG-C20)

- **Number format row updated:** Indian numbering (lakh/crore, 2-2-3 grouping) explicitly supported. Default inferred from device locale.
- **New "Currency formatting" row** added. Configurable symbol placement, spacing, grouping. Defaults from home currency locale.
- **New "Large transaction warning" row** added. Per-account and per-category configurable thresholds. Non-blocking confirmation when exceeded.
- **New "Back button behaviour" row** added. Configurable: ask before discarding (default), auto-save as draft, discard immediately.

### §5.5.1 — Confirmed Contextual Menu Actions

- **Account row updated:** Added "Reconcile" action (opens §5.1.3a flow).

### §7 — Multi-Currency Model (Currency Symbol Disambiguation, FG-C13)

- **New "Currency symbol disambiguation" paragraph** added before cross-currency transfers.
- 3-letter ISO code shown alongside symbol when multiple accounts share the same currency symbol.

### §7.1 — Transaction-Level Exchange Rate Capture (FG-C12)

- **New "Exchange rate estimate during transaction entry" paragraph** added.
- Home currency estimate shown below amount field for foreign-currency accounts.
- Staleness warning if cached rate > 14 days old. "Exchange rate unavailable" if no cached rate.

### §8 — In-Scope vs. Out-of-Scope

- **v1 in-scope updated:** Eight new FG-C bullets added: duplicate transaction detection, balance reconciliation, Indian numbering format, exchange rate estimate in entry, currency symbol disambiguation, large transaction warning, back button behaviour.
- **v2 deferred updated:** Seven new bullets: combined search + filter, balance history, budget period start day, income categories in budget context, app data wipe, account statement export, auto-detect transactions from SMS/email.
- **v3 deferred updated:** One new bullet: Android home screen widget.

### §11 — Open Questions

- Updated to reference full FG-C resolution. Feature gap analysis marked as complete. UX design decisions (UX-1 through UX-14) and ERR-1 noted as remaining open items.

---

## `docs/01-product/prd-v2-draft.md`

### §19 — v3+ Items

- Added Android home screen widget (FG-C7) as v3 item.

### §20 — FG-C Items (table replaced)

- Former "Unresolved — Pending Product Decisions" table replaced with **"Resolved — Decision Log"** summary.
- All 21 FG-C items categorized by disposition (v1, v2, v3, rejected, no action needed).

### §21 — Auto-Detect Transactions from SMS & Email Notifications (new section, FG-C21)

- **New major section** added as §21.
- Core use cases: UPI payments, credit card transactions, bank debits/credits.
- Design considerations table: permission model, pattern matching, account matching, merchant-to-category mapping, user review flow, duplicate handling, error handling, Gmail integration.
- Marked as high-priority v2 feature.

---

## `docs/06-helpers/gaps-and-questions.md`

- Header updated: Part 3 marked as fully resolved.
- Part 3 description replaced with resolution summary.
- **FG-C1 through FG-C20 full text removed.** Replaced with categorized resolution summary note.
- FG-C21 (new item) included in resolution summary.
- Part 0 (ERR-1) marked as resolved — §4.5 was already fixed in a prior session.

---

## `docs/06-helpers/ideation-tracker.md`

- PRD deliverable row updated: FG-C1–FG-C21 resolution noted. Feature gap analysis marked complete.
- **New 2026-04-14 key decisions entry** added (before the FG-B entry) covering all FG-C1–FG-C21 decisions with per-item summaries. Feature gap analysis marked as complete.

---

## Files NOT changed

- `docs/01-product/ledger-entry.md` — no ledger posting changes in this session.
- `docs/06-helpers/ideation-folder-structure.md` — no new files created (v2 draft already existed).
