# Variance — Ideation Phase Tracker

> **Last Updated:** 2026-04-12 (PRD v0.1.3)

---

## Phase Status

| Phase | Status |
|-------|--------|
| 1 – Problem Definition | ✅ Complete |
| 2 – Specification | 🟡 In Progress |
| 3 – Execution Planning | ⬜ Not Started |
| 4 – Readiness Gate | ⬜ Not Started |

---

## Deliverable Checklist

| # | Deliverable | Status | Notes |
|---|-------------|--------|-------|
| 1 | **PRD v0.1.3** | 🟡 In Review | 12 open questions remain (Q29–Q40) |
| 2 | **System Design Spec (SDS)** | 🔴 Blocked | Blocked on Q29, Q32, Q34, Q35, Q36, Q37, Q40 |
| 3 | **UX Flows** | 🔴 Blocked | Blocked on Q29–Q33, Q38–Q39, PRD sign-off |
| 4 | **API Contracts** | 🔴 Blocked | Blocked on SDS |
| 5 | **Execution Plan (EP)** | 🔴 Blocked | Blocked on all above |

---

## Open Questions (Active)

### Group A — Blocking UX Flows

| ID | Question | Status |
|----|----------|--------|
| Q29 | Installments: sub-type of recurring or separate entity in data model? | ❓ Open |
| Q30 | Installment mismatch reminder: triggered on each edit or only at final installment due? | ❓ Open |
| Q31 | Max photos per transaction: capped (N) or unlimited? | ❓ Open |
| Q33 | "Balance Adjustment" transactions: visually distinct in list or indistinguishable? | ❓ Open |
| Q38 | Social/Stationery/Culture: missing "Other" subcategory — intentional or add for consistency? | ❓ Open |
| Q39 | Gift income and "Other" income: leaf categories — intentional? | ❓ Open |

### Group B — Blocking SDS

| ID | Question | Status |
|----|----------|--------|
| Q32 | Photo compression and max size per photo? | ❓ Open |
| Q34 | Exchange rate staleness threshold (N days before indicator shown)? | ❓ Open |
| Q35 | Opening Balance equity account: visible to user? Included in net worth? | ❓ Open |
| Q36 | Budget pool add: can N+T exceed M, or is M also increased? | ❓ Open |
| Q37 | Archived recurring templates: can user reactivate? Resume or restart? | ❓ Open |
| Q40 | System-provided default categories: can user rename/hide them, or immutable? | ❓ Open |

---

## Resolved Questions Log

| ID | Question | Decision | Resolved |
|----|----------|----------|----------|
| Q1 | Target platform? | Android only. | 2026-04-12 |
| Q2 | Primary OS? | Android. | 2026-04-12 |
| Q3 | Data portability format? | Deferred to SDS. | 2026-04-12 |
| Q4 | Savings Goals in v1? | Moved to v2. | 2026-04-12 |
| Q5 | PDF export in v1? | No. CSV only in v2. | 2026-04-12 |
| Q6 | License? | MIT. | 2026-04-12 |
| Q7 | Minimum Android API level? | API 31 (Android 12), targeting latest. | 2026-04-12 |
| Q8 | DEB abstraction level? | Fully abstracted. Income/expense/transfer UI only. | 2026-04-12 |
| Q9 | CSV import in v1? | Deferred to v2. | 2026-04-12 |
| Q10 | Recurring posting: auto or remind? | Configurable per template. | 2026-04-12 |
| Q11 | Transfer categories? | Transfers have no categories. Not supported by DEB. | 2026-04-12 |
| Q12 | Photo limit? | Multiple allowed. Stored in app-private folder. Deleted with voided transaction. | 2026-04-12 |
| Q13 | Category list? | Full list provided (15 expense categories, 4 income categories + Balance Adjustment protected). | 2026-04-12 |
| Q14 | Filter criteria? | Type, category, subcategory, account, date range, has photo, has description, is recurring, is voided. | 2026-04-12 |
| Q15 | Budget over-limit behaviour? | No block. Small passive visual indicator only. | 2026-04-12 |
| Q16 | Income replenishment mechanics? | More-options → "Add to Budget". Pool remaining N becomes N+T. | 2026-04-12 |
| Q17 | Font selection? | One bundled curated font + system default. | 2026-04-12 |
| Q18 | Journal adjustments visibility? | Audit view in v2. All transactions surfaced there. | 2026-04-12 |
| Q19 | Voided transactions? | Visible only in v2 audit view. No permanent deletion. Ever. | 2026-04-12 |
| Q20 | Soft-deleted account in net worth? | Excluded from net worth. | 2026-04-12 |
| Q21 | Investment value tracking? | 3-way model: direct edit (prompted), recorded transaction, reversed delete. | 2026-04-12 |
| Q22 | Net worth sign convention? | Per-account option: "include in net worth" flag (true by default). | 2026-04-12 |
| Q23 | Photo on voided transaction? | Photos permanently deleted. | 2026-04-12 |
| Q24 | Recurring template expiry? | Template automatically archived. | 2026-04-12 |
| Q25 | Category deletion flow? | Parent cannot be deleted if children exist. All deletes are soft. | 2026-04-12 |
| Q26 | Multi-currency net worth? | Cached exchange rate (daily background fetch when online); fallback to stale or per-currency display. | 2026-04-12 |
| Q27 | Initial balance DEB offset? | Internal equity account. Math to be finalised in SDS. | 2026-04-12 |
| Q28 | Biometric fallback? | PIN. Set within the app. | 2026-04-12 |

---

## Key Decisions Log

| Date | Decision |
|------|----------|
| 2026-04-12 | DEB formal mathematical specification added to PRD (core invariant, accounting equation, entry model, constraints, validity). |
| 2026-04-12 | Recurring transactions expanded: recurrence = N units of day/week/month/year; optional weekday/weekend/month-boundary constraints. |
| 2026-04-12 | Installments defined as a recurring sub-type: total amount ÷ periods, manual per-period adjustment, mismatch warning. |
| 2026-04-12 | Filter view is a dedicated UI (not inline). Full filter criteria set resolved. |
| 2026-04-12 | Transaction categories are two-level. Complete default taxonomy provided for expense (15 parents) and income (4 parents). |
| 2026-04-12 | "Balance Adjustment" is a protected system category (income + expense). Not user-selectable. Assigned by system on journal adjustment. |
| 2026-04-12 | All deletes are soft. No entity is ever permanently deleted (transactions, accounts, categories). |
| 2026-04-12 | Multi-currency net worth uses opportunistic background exchange rate fetch (once daily if online), cached locally. |
| 2026-04-12 | Initial balance offset goes to internal equity account (invisible to user). |
| 2026-04-12 | Investment account has a 3-way balance change model. |
| 2026-04-12 | Budget "Add to Budget" via more-options: N_new = N + T. |
| 2026-04-12 | Tags deferred to v2 (color, name, icon; filterable and searchable). |
| 2026-04-12 | Audit view (all transactions including voided + journal adjustments) deferred to v2. |
| 2026-04-12 | C1 (internet constraint) formalised as offline-first; exchange rate fetch + Drive backup are opt-in future online features. |

---

## Readiness Gate

- [ ] PRD signed off
- [ ] System Design Spec complete
- [ ] UX Flows complete
- [ ] API Contracts defined
- [ ] Execution Plan complete

**Status: 🔴 BLOCKED — 5/5 incomplete**

---

## Document Index

| Document | Repo Path | Version | Status |
|----------|-----------|---------|--------|
| PRD | `docs/prd.md` | 0.1.3 | 🟡 In Review |
| SDS | `docs/sds.md` | – | ⬜ Not Started |
| UX Flows | `docs/ux-flows.md` | – | ⬜ Not Started |
| API Contracts | `docs/api-contracts.md` | – | ⬜ Not Started |
| Execution Plan | `docs/execution-plan.md` | – | ⬜ Not Started |
