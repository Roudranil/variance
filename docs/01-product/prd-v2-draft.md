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
- **Android home screen widget (FG-C7)** — glanceable finance widget showing key figures. Privacy concern: widget visible on lock screen without PIN. Strictly v3.

---

## 20. FG-C Items (Resolved — Decision Log)

All FG-C items were resolved on 2026-04-14. Items are categorized by disposition:

**Baked into v1 PRD:** FG-C2 (duplicate detection), FG-C6 (balance reconciliation — all accounts), FG-C11 (Indian numbering), FG-C12 (exchange rate estimate in entry), FG-C13 (currency symbol disambiguation), FG-C18 (large transaction warning + credit card limit validation), FG-C20 (back button behaviour).

**Deferred to v2:** FG-C4 (combined search + filter — with advanced filter), FG-C5 (balance history — with analytics), FG-C8 (budget period start day), FG-C9 (income budgets), FG-C10 (app data wipe — with data management), FG-C14 (account statement export — with CSV export), FG-C21 (auto-detect transactions from SMS/email).

**Deferred to v3:** FG-C7 (Android home screen widget — privacy concerns).

**Rejected:** FG-C1 (quick-entry templates — no value, UI clutter), FG-C15 (undo snackbar — standard delete flow suffices), FG-C19 (default account — no pre-selection).

**No action needed:** FG-C16 (photo storage on uninstall — accept Android default), FG-C17 (recurring pause/disable — already resolved in v1/v2).

---

## 21. Auto-Detect Transactions from SMS & Email Notifications (FG-C21)

> **Priority:** High — this is a primary motivation for the app's target user base.

Automatically detect and record financial transactions from device notifications (SMS and email) without manual entry. This is a major v2 feature requiring significant design, permissions, and pattern-matching infrastructure.

**Core use cases:**
- **UPI payments:** Detect UPI transaction SMS (common in India) — extract merchant name, amount, date/time, and source account.
- **Credit card transactions:** Detect transaction SMS or email notifications — extract merchant, amount, card (last 4 digits → match to account).
- **Bank account debits/credits:** Detect bank SMS — extract amount, type (debit/credit), and account.

**High-level design considerations:**

| Aspect | Notes |
|--------|-------|
| **Permission model** | Requires `READ_SMS` or Notification Listener Service permission. Must be opt-in and clearly explained to the user. Privacy-sensitive — the app reads message content locally, never sends it to any server. |
| **Pattern matching** | Rule-based pattern matching against known SMS/email formats from Indian banks, UPI providers, and credit card issuers. Regex or template-based extraction. Must be extensible — new bank formats should be addable without app updates (consider a local rules file or user-contributed patterns). |
| **Account matching** | Extracted account identifiers (last 4 digits of card, bank name) are matched against the user's configured accounts. Fuzzy matching with user confirmation for ambiguous cases. |
| **Merchant → category mapping** | Optional: map known merchants to transaction categories (e.g., Swiggy → Food > Eating Out). This could use a local lookup table. If no mapping exists, the user assigns the category manually. |
| **User review flow** | Auto-detected transactions should be surfaced as **pending suggestions** — not auto-posted without user review. A dedicated "Review detected transactions" screen (similar to Pending Confirmations for recurring templates) lets the user confirm, edit, or dismiss each detection. |
| **Duplicate handling** | If the user already manually recorded a transaction that matches a detected one, the app should flag it as a probable duplicate (building on FG-C2's detection logic). |
| **Error handling** | Unrecognized SMS formats are silently ignored. False positives (non-financial SMS matched incorrectly) must be dismissible. The user can disable detection for specific senders. |
| **Gmail integration** | If feasible: read credit card statement emails from Gmail via local notification access or an authorized Gmail API scope. This is more complex and may be a v2+ or v3 feature within this feature set. |

**Out of scope for this feature:** Cloud processing of messages, sharing message content with any server, auto-posting without user review.

**Design work needed:** Full UX flow for review screen, permission request flow, pattern library architecture, account matching algorithm, category suggestion model.
