---
name: PRD v2 Draft — Deferred Features & Decisions
status: in progress
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md]
outputs_to: []
---

# Variance — PRD v2 Draft

> **Purpose:** This document consolidates all features, decisions, questions, and ideas explicitly deferred to v2 from the v1 PRD. It serves as the starting point for v2 product planning. Items are grouped by origin and cross-referenced to their v1 PRD location.
>
> **Status:** Draft collection — not a specification. Items here need full product definition before they become implementable.
>
> **Last Updated:** 2026-04-14

---

## 1. Budgeting (Full Feature — §5.3)

The entire budgeting feature was deferred from v1 to v2 for a ground-up redesign alongside savings goals.

**Preserved v1 specification (starting point):**
- Total budget: single overall spending ceiling per period.
- Per-category budgets: individual limits per expense category. May exceed total budget (passive indicator only, no block).
- Default budget horizon: monthly. Additional: weekly, quarterly, annual. Multiple horizons may coexist.
- Income replenishment: "Add to Budget" action on any income transaction. Pool formula: N_new = min(N + T, M).
- Budget vs. actual: real-time comparison with colour-threshold progress bars.
- Budget alerts: in-app alerts at configurable thresholds (default 80% and 100%). Per-budget, user-configurable.
- Budget rollover: configurable per budget, defaults to off.

**Deferred feature gap items (from v1 FG analysis):**

| ID | Topic | Notes |
|----|-------|-------|
| FG-A17 | Budget creation fields | What fields are collected when creating a budget? Total amount, period, category selection, rollover toggle. |
| FG-A18 | Budget currency | Does a budget inherit the home currency or can it be set per-budget? |
| FG-A19 | Budget period start day | User-configurable "budget month start day" for users whose pay cycle doesn't align with the 1st. |
| FG-A20 | Budget rollover and overspend | When rollover is on, does overspend carry forward as a deficit? |
| FG-A21 | Budget transaction counting | How are transactions counted against a budget — by transaction date or posting date? |
| FG-B3 | In-app alert history | Where do past alerts go? One-time vs. recurring triggers. Notification center / alert history. |
| FG-B6 | Budget and soft-deleted categories | What happens to a per-category budget when the category is soft-deleted? Auto-archive, orphan, or relabel? |
| FG-C8 | Budget period start day configuration | Analogous to "week start" — configurable budget month start day for non-1st pay cycles. |
| FG-C9 | Income categories in budget context | Income budgets / savings targets — goal for income earned per period, separate from expense budgets. |

**Open questions (to be resolved in v2 planning):**
- Q59: Budget entry contextual menu design.
- Q61: "Remove from Budget" action.
- Q68: Budget period auto-creation.
- Q69: Historical budget periods.

---

## 2. Savings Goals

Mentioned in the v1 PRD version roadmap as a v2 feature. To be designed alongside budgets for coherent interaction.

**No v1 specification exists.** This is a greenfield design in v2.

---

## 3. Split Transactions (§8 Deferred)

Recording a single bill/payment split across multiple categories (e.g., one supermarket receipt = Groceries + Toiletries + Snacks).

**Design intent from v1:**
- One transaction per split at the ledger level.
- UI and edit flows to be designed in v2.

---

## 4. Advanced Filter Mode (FG-A13)

Predicate builder with AND/OR/NOT operators, enabling queries like "(Food OR Transportation) AND last 30 days."

**v1 ships with:** Simple filter view — all criteria combined with AND logic.

---

## 5. Saved Filter Profiles (FG-A14)

Naming and persisting a filter configuration for repeated use. In v1, filters clear on navigation.

---

## 6. Local Backup Import / Restore (FG-A31)

Restoring data from a v1 backup zip. v1 is write-only — export exists but no import path.

---

## 7. Cloud Backup and Sync (FG-A31)

Google Drive or similar. Consistent with offline-first — sync is opt-in and explicit.

---

## 8. Comprehensive TalkBack / Screen Reader Coverage (FG-A30)

Exhaustive a11y labelling for complex custom widgets, financial data tables, chart narration. v1 ships with best-effort labelling of interactive elements.

---

## 9. Account and Category Manual Reordering

Default order in v1 is alphabetical. v2 adds drag-to-reorder for both accounts and categories.

---

## 10. Recurring Template Disable / Enable

v1 has pause/unpause only. v2 adds full disable/enable with backfill option: on re-enable, prompt user to realise only future transactions or also backfill all transactions from the disabled period.

---

## 11. Subcategory Parent Reassignment

Reassigning a subcategory to a different parent category. Fixed at creation in v1.

---

## 12. Trends, Dashboards, Charts, Analytics, Visualisations

Full analytics suite. v1 has no charts or visualisation beyond the home screen summary.

**v2 candidates:**
- Net worth graph over time (from §5.8 v2 additions).
- Per-account balance history / mini chart (FG-C5).
- Income vs. expense trends by month/quarter/year.
- Category spending breakdown (pie/bar chart).
- Budget-at-a-glance widget on home screen.

---

## 13. Data Management: CSV Export, CSV Import, Data Wipe

- CSV export: per-account or all-account transaction history.
- CSV import: importing transactions from external sources.
- Data wipe / factory reset (FG-C10): clear all data without uninstalling.

---

## 14. Audit View

Surfaces all transactions including voided entries, journal adjustments (invisible balance edits), reversing/corrected pairs, and system-generated internal transfers. Full ledger transparency.

---

## 15. Tags

Colour, name, icon. Assignable to transactions. Filterable and searchable. Cross-cutting metadata layer.

---

## 16. Cross-Currency Transfers and Fees

Cross-currency transfers are blocked in v1 (§7). v2 must design:
- Exchange rate entry at transfer time.
- DEB handling for multi-currency Dr/Cr (Case 3.3 in ledger-entry.md).
- Transfer fee in cross-currency context (§5.1.5b notes deferral).

---

## 17. Transaction Detail View — v2 Additions (FG-B1)

- **Correction history:** "This transaction was corrected on [date]" with links to original and reversal entries.
- **Recurring template link:** Which template generated this transaction; past and future occurrences of the series.
- **Installment and loan status:** If part of an installment series linked to a loan account — series progress, remaining amount, loan balance.

---

## 18. Home Screen — v2 Additions (FG-B2)

- **Net worth graph over time** (line chart, derivable from ledger).
- **Budget-at-a-glance widget** (current period spend vs. budget — depends on budgeting feature).
- **Analytics summary** (top spending categories, month-over-month trends).

---

## 19. v3+ Items (for reference)

These are v3 or later and not expected in v2, but listed for completeness:
- ML insights and predictions.
- OCR receipt capture.
- Exchange rate update infrastructure (if not landed in v2).
- Google Drive backup (if not landed in v2).
- ML/rule-based auto-generated transaction titles.

---

## 20. FG-C Items (Unresolved — Pending Product Decisions)

These feature gap items from the v1 gap analysis remain open. Some may land in v2; others may be deferred further or rejected. Product decisions needed.

| ID | Topic | v1 PRD Reference |
|----|-------|-----------------|
| FG-C1 | Transaction quick-entry templates (not recurring) | No v1 spec. "Save as template" for manual reuse. |
| FG-C2 | Duplicate transaction detection | No v1 spec. Soft warning on probable duplicates. |
| FG-C4 | Combined search + filter | No v1 spec. Can user apply text search AND filter simultaneously? |
| FG-C5 | Balance history / mini chart per account | Derivable from ledger. Deferred to v2 analytics. |
| FG-C6 | Cash reconciliation workflow | Faster path to direct balance edit for cash accounts. |
| FG-C7 | Android home screen widget | Glanceable finance widget. Privacy concern (lock screen visibility). |
| FG-C10 | App data wipe / factory reset | No v1 "reset all data" option. Uninstall required. |
| FG-C11 | Indian numbering format (lakh/crore) | 2-2-3 grouping from right. Must be explicitly supported. |
| FG-C12 | Offline exchange rate freshness in transaction entry | Any rate reference shown during foreign-currency transaction entry? |
| FG-C13 | Currency symbol ambiguity | Multiple currencies share symbols. Show ISO code alongside? |
| FG-C14 | Account statement export | Basic share-as-text/PDF. Deferred with CSV export. |
| FG-C15 | Undo for recently created transactions | Post-save "Undo" snackbar (5s). Standard mobile UX pattern. |
| FG-C16 | Photo storage on app uninstall | Photos in app-private storage = lost on uninstall. Document as known limitation. |
| FG-C17 | Recurring transaction pause/disable | Resolved in v1 (pause/unpause exists). Disable/enable with backfill = v2. |
| FG-C18 | Transaction amount validation upper bound | Soft warning for large amounts above configurable threshold? |
| FG-C19 | Default account on transaction entry | Pre-selected default account logic (most recent, highest balance, first created?). |
| FG-C20 | Keyboard behaviour and back navigation during transaction entry | Discard vs. draft policy on back press during transaction entry. |
