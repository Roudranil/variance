---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 01-product/ledger-entry.md, 06-helpers/gaps-and-questions.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 5)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** DEB & ledger entry audit — comprehensive mathematical verification of all double-entry bookkeeping postings, balance formulas, and equation consistency across the PRD and ledger-entry.md. 2 equation errors fixed (ERR-2, ERR-3). 4 missing ledger cases added (LC-1 through LC-4). Sign-based asset/liability inference stress-tested across 11 scenarios — all hold.

---

## `docs/01-product/prd.md`

### §4.2 — Accounting Equation (ERR-2 fix)

- **Added Equity term** to the expanded accounting equation: `Assets = Liabilities + Equity + Income − Expenses` (was missing Equity).
- **Added Variance-specific note** explaining that EQ is excluded from user-facing computation; the practical formula is `Net Worth = Σ account balances` (§4.9). The accounting equation is stated for formal DEB completeness.

### §4.11 — Ledger Posting Cases (ERR-3 fix + new cases)

- **Notation line fixed:** Replaced `A = asset account · L = liability account` with `A = any user-facing account (all types use the universal balance formula, §4.6)`. Added `FC = fee expense category`.
- **4 new rows added to compact summary table:**
  - 1.3a — Create Transfer with Fee
  - 1.6a — Modify Transfer with Fee (financial)
  - 1.9a — Soft-Delete Transfer with Fee
  - 2.5a — Account Deletion Balance Transfer (with positive/negative sub-cases)
  - 3.7 — Batch Category Migration
- **Row 3.1 updated:** "Same as 1.1–1.3" → "Same as 1.1–1.3 (or 1.3a if fee applies)"

---

## `docs/01-product/ledger-entry.md`

### Notation & Conventions

- **Added `FC` symbol** to notation table: `FC = Fee expense category (e.g., Financial > Fees & Charges)`.

### Case 1.6a — Modify Transfer with Fee (NEW, LC-1)

- **New case** added after Case 1.6. Reversing entries negate both the transfer and the fee (4 entries); corrected entries re-post both (4 entries). Total: 4 transactions, 8 entries.

### Case 1.9a — Soft-Delete Transfer with Fee (NEW, LC-2)

- **New case** added after Case 1.9. Reversing entries for both components. 2 linked transactions, 4 entries.

### Case 2.5a — Account Deletion Balance Transfer (NEW, LC-3)

- **New case** added after Case 2.5, with two sub-cases:
  - 2.5a-i: Positive balance (asset state) — `Dr A₂ B₁, Cr A₁ B₁`.
  - 2.5a-ii: Negative balance (liability state) — `Dr A₁ |B₁|, Cr A₂ |B₁|` (reversed direction to zero out liability).
- System-generated, non-editable, with special soft-delete warning.
- Same-currency constraint noted.

### Case 3.7 — Batch Category Migration (NEW, LC-4)

- **New case** added after Case 3.6. Per migrated transaction: reversing + corrected pair (same as 1.4/1.5 with category changed). Produces 2N transactions and 4N entries for N migrated transactions. Atomicity note for SDS.

### Complete Summary Table

- **6 new rows added:** 1.6a, 1.9a, 2.5a-i, 2.5a-ii, 3.7.

### Questions Table

- **Q42 updated:** Replaced retired `Dr L, Cr A` with `Dr CreditCard, Cr Bank`; updated decision text.
- **Q44 updated:** Replaced reference to retired cases 2.3c/2.4c and 2.3d/2.4d with universal rule (2.3a/2.4a and 2.3b/2.4b).

### Metadata

- `Last Updated` in header changed from 2026-04-12 to 2026-04-14.

---

## `docs/06-helpers/gaps-and-questions.md`

### Part 0 — Internal Errors & Inconsistencies

- **ERR-2 added and resolved:** §4.2 missing Equity term.
- **ERR-3 added and resolved:** §4.11 notation used retired `L` symbol.
- Header updated from "All errors resolved" to reflect new items, then back to "All errors resolved" after fixes applied.

### LC — Ledger Case Coverage Gaps (new section)

- **New section added** after Part 0.
- LC-1 through LC-4 added and resolved: modify/delete transfer-with-fee, account deletion balance transfer, batch category migration.

---

## Files NOT changed

- `docs/01-product/prd-v2-draft.md` — no v2 changes in this session.
- `docs/01-product/ledger-entry.md` notation for `EQ`, `BAI`, `BAE` — unchanged (already correct).
- `docs/06-helpers/ideation-folder-structure.md` — no new files created.
