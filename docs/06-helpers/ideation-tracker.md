---
name: Ideation Phase Tracker
status: in progress
owner: pm
created: 2026-04-13
last_updated: 2026-04-13
depends_on: [01-product/prd.md]
outputs_to: []
---

# Variance — Ideation Phase Tracker

> **Last Updated:** 2026-04-13 (PRD v0.3.0)

---

## Phase Status

| Phase | Status |
|-------|--------|
| 1 – Problem Definition | ✅ Complete |
| 2 – Specification | 🟡 In Progress — PRD all questions resolved; SDS, UX Flows, API Contracts next |
| 3 – Execution Planning | ⬜ Not Started |
| 4 – Readiness Gate | ⬜ Not Started |

---

## Deliverable Checklist

| # | Deliverable | Status | Notes |
|---|-------------|--------|-------|
| 1 | **PRD v0.3.0** | 🟢 All Questions Resolved | All 76 questions resolved. Pending founder sign-off on v0.3.0 changes (budget deferral, onboarding, app lock redesign, etc.). |
| 2 | **System Design Spec (SDS)** | ⬜ Ready to Start | All PRD blockers resolved. Can proceed after PRD sign-off. |
| 3 | **UX Flows** | ⬜ Ready to Start | All PRD blockers resolved. UX pre-work topics (UX-1 through UX-14) remain as design decisions for UX Flows authoring. |
| 4 | **API Contracts** | 🔴 Blocked | Blocked on SDS |
| 5 | **Execution Plan (EP)** | 🔴 Blocked | Blocked on all above |

---

## Open Questions (Active)

**None.** All 76 questions (Q1–Q76) are resolved. See the Resolved Questions Log below.

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
| Q16 | Income replenishment mechanics? | More-options → "Add to Budget". Pool remaining N becomes min(N+T, M). | 2026-04-12 |
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
| Q27 | Initial balance DEB offset? | Internal equity account. Math finalised in §4.9 of PRD. | 2026-04-12 |
| Q28 | Biometric fallback? | PIN. Set within the app. | 2026-04-12 |
| Q29 | Installments vs. recurring relation in data model? | Architecture intent confirmed: separate templates table generates child transactions. Whether installments are a sub-type or separate entity within the templates table is deferred to SDS schema design. | 2026-04-12 |
| Q30 | Installment mismatch reminder timing? | Warning fires at save time of the payment plan. Non-blocking. | 2026-04-12 |
| Q31 | Max photos per transaction? | Capped at 2. | 2026-04-12 |
| Q32 | Photo compression/size limit? | Compression confirmed. Algorithm and target size deferred to SDS. | 2026-04-12 |
| Q33 | "Balance Adjustment" transactions: visually distinct in list? | Indistinguishable from normal transactions. UI treatment in UX Flows. | 2026-04-12 |
| Q34 | Exchange rate staleness threshold? | 14 days. Staleness indicator shown in net worth view. | 2026-04-12 |
| Q35 | Opening Balance equity account: visible to user? In net worth? | Never visible under any circumstances. Excluded from net worth (double-counting proof in §4.9). | 2026-04-12 |
| Q36 | Budget pool add: can N+T exceed M? | No. Formula: N_new = min(N + T, M). Pool capped at M. | 2026-04-12 |
| Q37 | Reactivating archived recurring templates? | No reactivation. User must create a new template. | 2026-04-12 |
| Q38 | Social/Stationery/Culture missing "Other"? | "Other" added to all three. Category tables updated. | 2026-04-12 |
| Q39 | Gift income and "Other" income as leaf categories — intentional? | Yes. Intentional by design. Users can add subcategories later. | 2026-04-12 |
| Q40 | System categories mutability? | All categories (default + user-created) are fully mutable: rename, icon-change, reorder, soft-delete. One constraint: subcategory cannot be reassigned to a different parent. | 2026-04-12 |
| Q41 | PRD §4.5/§4.6 inconsistency on income entry sides. | Corrected to `Dr A, Cr IC`. §4.5 updated in PRD v0.2.0. Reversal cases 1.5 and 1.8 fixed in `docs/ledger-entry.md`. | 2026-04-12 |
| Q42 | Transfer to liability account (pay credit card): confirm `Dr L, Cr A`. | Confirmed. Reduces liability balance. | 2026-04-12 |
| Q43 | Opening balance for liability accounts: EQ debited, bidirectional postings. | Confirmed. EQ supports debit (liability opening) and credit (asset opening). | 2026-04-12 |
| Q44 | Liability journal adjustment direction. | Confirmed: balance ↑ = expense (Dr BAE, Cr L); balance ↓ = income (Dr L, Cr BAI). Cases 2.3c/2.3d/2.4c/2.4d added to ledger-entry.md. | 2026-04-12 |
| Q45 | Soft-delete account with non-zero balance: prompt to transfer? | Two-step flow: (1) offer balance transfer to another account; (2) if declined, second confirmation warning net worth change. Transfer transaction type tracked in Q49. | 2026-04-12 |
| Q46 | Cross-currency transfers in v1? | Disallowed in v1. UI prevents cross-currency transfer selection. Deferred to v2. | 2026-04-12 |
| Q47 | Child transaction edit/delete — effect on recurring template? | Occurrence marked as "manually handled"; template continues unchanged for remaining occurrences. | 2026-04-13 |
| Q48 | Child transaction edit/delete — effect on installment running total? | 4-way tracking: total configured, running total (reflects deletions/corrections), total remaining, projected final total. | 2026-04-13 |
| Q49 | Account soft-delete balance transfer transaction type? | System-generated internal transfer. Warning shown if user later deletes it (net worth loss since source account inactive). | 2026-04-13 |
| Q50 | Category icon system? | `material_symbols_icons` Flutter package (^4.2928.1). Curated subset bundled. Efficiency strategy deferred to SDS. | 2026-04-13 |
| Q51 | "Balance Adjustment" protected category — exempt from mutability? | Completely immutable. Hidden from category management. Protected entity pattern (`is_protected` flag) introduced for DB schema. | 2026-04-13 |
| Q52 | Account name uniqueness — extends to soft-deleted? | Yes, names unique across all including soft-deleted. Reinstatement offered when name+type match deleted account. Same logic for categories. | 2026-04-13 |
| Q53 | Transaction title — display behaviour? | 3-column list layout: C1 category (parent/child), C2 title + account info (expense: source; income: destination; transfer: source→dest), C3 amount + currency. Grouped by date, ordered by time. Time shown on tap. | 2026-04-13 |
| Q54 | Transaction description — display behaviour? | Detail view only. Max character limit configurable in Settings: 500/1000/2000, default 1000. | 2026-04-13 |
| Q55 | Parent category with children — soft-delete en masse? | No bulk delete. Transaction migration offered on deletion: migrate all, select specific, or none. | 2026-04-13 |
| Q56 | Subcategory contextual menu? | Edit, Delete. No "Add Child" (max depth 2). Change parent deferred to v2. | 2026-04-13 |
| Q57 | Recurring template contextual menu? | Edit, Delete, Pause, Unpause, View child transactions. Pause with duration or custom date. Disable/Enable deferred to v2. | 2026-04-13 |
| Q58 | Child transaction of recurring series — contextual menu? | Edit, Delete (same as normal). "Add to Budget" deferred with budgets. | 2026-04-13 |
| Q59 | Budget entry contextual menu? | **Deferred** — entire budgeting feature moved to v2 (to be redesigned with savings goals). | 2026-04-13 |
| Q60 | Photo attachment contextual menu? | Delete photo only. Tap opens full-screen directly (no contextual menu for viewing). | 2026-04-13 |
| Q61 | "Remove from Budget" action? | **Deferred** with budgets to v2. | 2026-04-13 |
| Q62 | Voided transaction actions in audit view? | No restoring voided transactions. Audit view action design deferred to v2. | 2026-04-13 |
| Q63 | Installment series template contextual menu? | Edit, Delete, Pause, Unpause, View child transactions, View payment progress (4-way totals), Mark series as complete (early archive). | 2026-04-13 |
| Q64 | Unified vs. per-account transaction list? | Both. Unified all-account list is default. Per-account list via account detail. Voided, unrealised, and superseded transactions excluded from default list. | 2026-04-13 |
| Q65 | Onboarding flow scope? | Yes — 5-step wizard: Welcome, Currency selection (locale-derived, INR fallback), Create first account, Quick highlights, Done. Skippable. | 2026-04-13 |
| Q66 | Default category seeding? | Silent seeding. All default categories pre-loaded on first install. Zero friction. | 2026-04-13 |
| Q67 | Currency selection on first launch? | Locale-derived default with INR fallback. Shown in onboarding for confirmation. Editable later in Settings. | 2026-04-13 |
| Q68 | Budget period auto-creation? | **Deferred** with budgets to v2. | 2026-04-13 |
| Q69 | Historical budget periods? | **Deferred** with budgets to v2. | 2026-04-13 |
| Q70 | Recurring "remind and confirm" delivery? | OS-level local notifications. Auto-approve after 24h. Requires POST_NOTIFICATIONS + SCHEDULE_EXACT_ALARM permissions. No network call (NF-1 preserved). | 2026-04-13 |
| Q71 | Unacknowledged recurring confirmation queue? | No queuing — auto-approve after 24h. User can switch template from remind-and-confirm to auto-post via contextual menu. | 2026-04-13 |
| Q72 | Reversal/correction entry visibility? | Only final corrected version visible in list. Original + reversal are hidden internal entries. Surfaced in v2 audit view. | 2026-04-13 |
| Q73 | App lock activation timing? | Hierarchical lock mechanism (device → app-specific → in-app PIN). User-configurable scope (app-wide or sensitive details only) and timeout (immediate/30s/1m/5m on backgrounding). Sensitive fields always require auth but stay unlocked within session. | 2026-04-13 |
| Q74 | Timezone and future-dating policy? | UTC storage, local display. Back-dating allowed (immediate post). Future-dating allowed (held as pending, auto-posts on date). Info popup shown. Schema needs `status` field (posted/pending). | 2026-04-13 |
| Q75 | Account reordering? | Default alphabetical. Manual reordering for both accounts and categories deferred to v2. | 2026-04-13 |
| Q76 | Multi-currency display in transaction list? | Both currencies shown. Exchange rate locked at transaction creation time (stored per-transaction). Net worth uses current/cached rate. Detail view shows stored rate. Schema needs `exchange_rate_to_home` field. | 2026-04-13 |

---

## Key Decisions Log

| Date | Decision |
|------|----------|
| 2026-04-12 | DEB formal mathematical specification added to PRD (core invariant, accounting equation, entry model, constraints, validity). |
| 2026-04-12 | Recurring transactions expanded: recurrence = N units of day/week/month/year; optional weekday/weekend/month-boundary constraints. |
| 2026-04-12 | Installments defined as a recurring sub-type: total amount ÷ periods, manual per-period adjustment, mismatch warning at save time. |
| 2026-04-12 | Filter view is a dedicated UI (not inline). Full filter criteria set resolved. |
| 2026-04-12 | Transaction categories are two-level. Complete default taxonomy provided for expense (15 parents) and income (4 parents). |
| 2026-04-12 | "Balance Adjustment" is a protected system category (income + expense). Not user-selectable. Assigned by system on journal adjustment. |
| 2026-04-12 | All deletes are soft. No entity is ever permanently deleted (transactions, accounts, categories). |
| 2026-04-12 | Multi-currency net worth uses opportunistic background exchange rate fetch (once daily if online), cached locally. |
| 2026-04-12 | Initial balance offset goes to internal equity account (invisible to user). |
| 2026-04-12 | Investment account has a 3-way balance change model. |
| 2026-04-12 | Budget "Add to Budget" via more-options: N_new = min(N + T, M). Pool capped at M (resolved Q36). |
| 2026-04-12 | Tags deferred to v2 (color, name, icon; filterable and searchable). |
| 2026-04-12 | Audit view (all transactions including voided + journal adjustments) deferred to v2. |
| 2026-04-12 | C1 (internet constraint) formalised as offline-first; exchange rate fetch + Drive backup are opt-in future online features. |
| 2026-04-12 | Ledger entry case analysis completed. All 19 posting cases enumerated (Groups 1–3). Q41–Q46 resolved. Liability journal adjustment cases (2.3c/2.3d/2.4c/2.4d) added. |
| 2026-04-12 | PRD §4.5 corrected: income transaction entry direction fixed to `Dr A, Cr IC`. Reversal cases 1.5 and 1.8 in ledger-entry.md corrected. PRD bumped to v0.2.0. |
| 2026-04-12 | Photo cap set to 2 per transaction. Photo compression confirmed (specifics SDS). Exchange rate staleness threshold set to 14 days. Cross-currency transfers disallowed in v1. Archived recurring templates cannot be reactivated. All default categories fully mutable (no parent reassignment for subcategories). "Other" added to Social, Stationery, Culture expense categories. Net worth cap formula updated to min(N+T, M). Soft-delete of account with non-zero balance uses two-step transfer prompt flow. EQ excluded from net worth (mathematical proof in §4.9). PRD bumped to v0.2.1. |
| 2026-04-12 | **PRD v0.2.3 changes:** (1) Account name uniqueness constraint added (§5.1.1). (2) Create Account fields table added (§5.1.1). (3) Account balance model generalised to all account types — Investment is no longer special; §5.1.3 renamed "Account Balance Model" and applies universally. (4) Transaction "notes" replaced by separate optional "title" and "description" fields across §5.2.1, §5.2.5, §5.2.6, §5.2.7; account notes retained. (5) Category edit now posts reversing + corrected entry pair (same as account/amount edit); in-place edits restricted to title, description, photos — §4.8 and §5.2.2 updated. (6) Category management UX defined: parent list → tap for children → + button at each level (§5.2.4). (7) Categories have exactly two fields: icon and name. (8) Category name uniqueness constraint added within parent scope. (9) Child category soft-delete restriction removed — subcategories can be soft-deleted at any time. (10) §5.5 Contextual Action Menus added with confirmed actions and 8 open questions (Q56–Q63). (11) New open questions: Q52–Q63 (12 new questions). Q50 partially addressed. |
| 2026-04-13 | **PRD v0.2.4 changes:** User-perspective gap analysis conducted across the full PRD. 13 new PRD questions added (Q64–Q76) across 7 new groups (G–M) covering: transaction list architecture, onboarding and first launch, budget lifecycle, alert and notification delivery, transaction correction visibility, app lock timing, and cross-cutting policy (timezone, account reordering, multi-currency list display). 14 UX Flows pre-work topics (UX-1–UX-14) catalogued in tracker. New comprehensive reference document created at `docs/gaps-and-questions.md`. |
| 2026-04-13 | **PRD v0.3.0 — ALL QUESTIONS RESOLVED (Q47–Q76).** Major decisions: |
| | (1) **Budget deferred to v2**: Entire budgeting feature (§5.3) moved to v2 for ground-up redesign alongside savings goals. Removes Q59, Q61, Q68, Q69 and "Add to Budget" from v1 scope. |
| | (2) **Recurring templates: pause/unpause** added to v1 (disable/enable deferred to v2). OS-level local notifications for remind-and-confirm with 24h auto-approve. |
| | (3) **Transaction list architecture**: 3-column layout (category, title+account, amount+currency). Unified all-account list as default + per-account via detail screen. Only final corrected version visible. |
| | (4) **Onboarding wizard** added to v1: Welcome → Currency (locale-derived, INR fallback) → First account → Highlights → Home. Silent category seeding. |
| | (5) **App lock redesigned**: Hierarchical mechanism (device lock → app-specific → in-app PIN). User-configurable scope (app-wide or sensitive details only) and timeout. |
| | (6) **Timezone/future-dating**: UTC storage, local display. Future-dated transactions held as pending. New `status` field (posted/pending). |
| | (7) **Account/category reinstatement**: Names unique including soft-deleted. Reinstatement offered when creating an entity that matches a deleted one. |
| | (8) **Category deletion with migration**: Users can migrate transactions from deleted category to another. |
| | (9) **Protected entity pattern**: `is_protected` flag for Balance Adjustment category and equity account. Hidden from user management. |
| | (10) **Transaction-level exchange rate**: Captured at creation, locked. Both currencies shown in list. Net worth uses current rate. |
| | (11) **Account/category reordering** deferred to v2. Default order: alphabetical. |
| | (12) **Installment 4-way tracking**: total configured, running total, remaining, projected final. |

---

## UX Flows Pre-Work Topics

> These topics are **not PRD questions** — they are interaction design decisions that belong in `docs/02-technical/ux-flows.md`. They do not block the PRD, but they must be resolved before UX Flows can be completed. Listed here so nothing falls through the gap between documents.

| # | Topic | Scope |
|---|-------|-------|
| UX-1 | **Primary navigation model** — Bottom nav bar? Navigation drawer? What are the top-level destinations and their labels? | App skeleton |
| UX-2 | **Transaction creation entry point** — FAB? Speed dial (income / expense / transfer split)? Where does it live — home screen only or persistent across all screens? | Entry point |
| UX-3 | **Account detail screen** — Does tapping an account navigate to a detail view? If so, what does it show (balance history, filtered transaction list, account metadata)? | Screen definition |
| UX-4 | **Transaction list row design and grouping** — What does each row display? How are transactions grouped (by day, by week)? Is there a running balance per group? | List screen |
| UX-5 | **Onboarding wizard design** — If Q65 resolves to "yes, there is an onboarding flow", what are the steps, screens, and transitions? | Onboarding flow |
| UX-6 | **Currency selection flow** — If Q67 resolves to "mandatory", what does the currency picker screen look like and where does it appear in the first-launch sequence? | Onboarding flow |
| UX-7 | ~~**Budget home period display**~~ | ~~Home screen~~ — Deferred with budgets to v2 |
| UX-8 | ~~**In-app alert visual treatment** (budget alerts)~~ | ~~Alert UX~~ — Deferred with budgets to v2 |
| UX-9 | **Soft-delete UX pattern** — When the user deletes a transaction, is there a confirmation dialog, an undo snackbar (timer-based), or an immediate soft-delete with no affordance? | Destructive action pattern |
| UX-10 | **App lock screen design** — Full-screen overlay? Does it fully obscure app content (privacy requirement)? What does the PIN entry and biometric prompt look like? | Security screen |
| UX-11 | **Category picker** — When recording a transaction, how does the user select a category and subcategory? Bottom sheet? Full-screen modal? Is there inline search? Are recently used categories surfaced at the top? | Transaction entry |
| UX-12 | **Amount entry** — System keyboard or custom numeric keyboard? Does the input support calculator-style expressions (e.g., "50 + 30")? | Transaction entry |
| UX-13 | **Empty states** — What does each major screen show when it has no data (no accounts, no transactions, no budgets)? Illustration, instructional copy, and a primary CTA per screen. | All major screens |
| UX-14 | **Photo capture source** — When attaching photos to a transaction, does the app present camera, device gallery, or a chooser for both? | Transaction entry |

---

## Readiness Gate

- [ ] PRD signed off ← **pending founder review of v0.3.0** (all questions resolved, no blockers)
- [ ] System Design Spec complete
- [ ] UX Flows complete
- [ ] API Contracts defined
- [ ] Execution Plan complete

**Status: 🟡 PRD ready for sign-off — 0 open questions. SDS and UX Flows can begin after sign-off.**

---

## Document Index

| Document | Repo Path | Version | Status |
|----------|-----------|---------|--------|
| PRD | `docs/01-product/prd.md` | 0.3.0 | 🟢 All Questions Resolved |
| Gaps & Questions | `docs/06-helpers/gaps-and-questions.md` | – | 📋 Reference (Part 1 resolved; Parts 2–3 tracked) |
| Ledger Entry Cases | `docs/01-product/ledger-entry.md` | – | ✅ Updated |
| SDS | `docs/02-technical/sds.md` | – | ⬜ Ready to Start |
| UX Flows | `docs/02-technical/ux-flows.md` | – | ⬜ Ready to Start |
| API Contracts | `docs/02-technical/api-contracts.md` | – | ⬜ Not Started |
| Execution Plan | `docs/03-planning/task-breakdown.md` | – | ⬜ Not Started |
