---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 01-product/ledger-entry.md, 01-product/input-fields.md, 01-product/technical-clarifications.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 8)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Founder decisions on 5 escalated TC items (TC-014, TC-022, TC-029, TC-031, TC-050). PM/LE discussion, PRD updates, ledger-entry updates, input-fields updates. Final blocker check — no remaining blockers for SDS or UX Flows.

---

## `docs/01-product/technical-clarifications.md`

- **TC-014:** Added founder resolution — Option A (~200-300 icons), curation is separate task.
- **TC-022:** Added founder resolution — installments support all three transaction types. TC-038 and TC-055 stale references updated to reflect resolution.
- **TC-029:** Added founder resolution — home currency change only affects default for new accounts. Exchange rate storage delegated to LE (SDS decision).
- **TC-031:** Added founder resolution — bottom navigation bar, 3 tabs. LE owns navigation decisions going forward.
- **TC-050:** Added founder resolution — global search across all transactions. SS5.8.4 month-scoped text corrected.
- **Summary tables updated:** PM Response Summary and LE Review Summary tables annotated with "all 5 resolved by founder (2026-04-14)".
- **Items requiring founder decisions table:** Replaced PM recommendations with actual founder decisions.

---

## `docs/01-product/prd.md`

### §5.2.4 — Transaction Categories
- Updated icon description: curated subset size locked at ~200-300 icons (TC-014). Added curation task dependency note and reference to SDS bundling architecture.

### §5.2.8 — Installments
- Added **transaction type** parameter: installments support income, expense, and transfer (including transfer-with-fee). References Cases 1.1, 1.2, 1.3, 1.3a in ledger-entry.md.
- Added **transfer-type installment form** note: source/destination accounts + optional fee panel.
- Updated compact summary table row for Case 3.2 to include all four ledger cases.

### §5.4.1 — Theme & Appearance
- Updated "Color scheme preview" reference: now points to Settings > Appearance (§5.7a) instead of "navigation options menu."

### §5.4.2 — Locale & Format
- Rewrote Home currency notes: primary effect is changing default currency for new account creation. Account/transaction currencies are immutable. Display/aggregation recalculation is an SDS concern.

### §5.7a — App Navigation Model (NEW SECTION)
- New section defining bottom navigation bar with 3 tabs: Home, Accounts, Settings.
- Defines tab content, navigation stack behaviour, FAB placement, Pending Confirmations access (Settings), and color scheme preview access.
- Notes LE owns navigation structure decisions going forward.

### §5.8.4 — Transaction List
- **Search scope corrected:** replaced month-filtered search with global search across all transactions. When search is active, month filter is suspended. When cleared, month filter re-engages. v2 scope: navigation search + settings search.
- Separated search and filter into distinct paragraphs for clarity.

### §5.8.5 — Alerts
- Updated Pending Confirmations screen reference: now points to Settings tab (§5.7a) instead of "navigation overflow menu."

### Features list
- Updated "Home screen alerts" entry: "nav overflow" → "Settings tab."

---

## `docs/01-product/ledger-entry.md`

### Case 3.2 — Installment Single-Period Post
- Replaced single-line description with a **4-row table** covering all transaction types (expense → Case 1.1, income → Case 1.2, transfer → Case 1.3, transfer-with-fee → Case 1.3a).
- Added TC-022 resolution note with loan repayment verification (Dr A_loan, Cr A_bank under universal formula).
- Updated summary table row to reference all four cases.

---

## `docs/01-product/input-fields.md`

### §5.1 — Installment Template Creation
- Added blockquote note: installment templates support all three transaction types (TC-022). Transfer-type installments expose source/destination account fields and fee panel.

---

## `docs/01-product/prd-v2-draft.md`

### §20 — FG-C Items
- Added TC-050 v2 scope note: navigation search and settings screen search deferred to v2.

---

## `docs/06-helpers/gaps-and-questions.md`

### Part 4 — Founder Decisions
- Header updated: all 5 items marked as resolved (2026-04-14).
- Replaced full problem/options/blocks tables with concise resolution summaries for each item.

---

## Files NOT changed

- `docs/01-product/prd-v2-draft.md` — only the FG-C items section (minor addition).
- `docs/06-helpers/ideation-folder-structure.md` — no new files created.
- `docs/06-helpers/ideation-tracker.md` — updated separately (see below).
