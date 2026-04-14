---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 06-helpers/gaps-and-questions.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 2)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Feature gap resolution — FG-A12 through FG-A31 (Part 3, Group A of `gaps-and-questions.md`). PRD bumped to **v0.5.0**.

---

## `docs/01-product/prd.md`

### §5.1.1 — Account CRUD (Delete section)

- **Same-currency account edge case (FG-A29):** When no same-currency account exists for balance transfer on deletion, the transfer offer is skipped entirely. The app goes directly to a net worth warning: "No same-currency account is available to receive this balance. Deleting this account will change your net worth. Are you sure?"

### §5.1.2 — Account Categories

- **Loan account installment suggestion (FG-A28):** Post-save contextual nudge shown when loan opens in liability state (negative initial balance) or EMI amount/EMI date fields are provided. Opens recurring installment template form with pre-filled fields (destination = this loan, amount = EMI amount if set, recurrence = monthly on EMI date if set, start = today). No hard link after creation.
- **Default Financial category:** Added "Fees & Charges" subcategory under the Financial expense category (required for transfer fee feature).

### §5.1.4 — Account Balance View

- **Net worth excluded accounts (FG-A26):** Changed from ambiguous "shown separately or not shown" to **grayed-out inline** below contributing accounts, with an "excluded" visual indicator.

### §5.1.5b — Transfer Fee (new section, FG-A27)

- Optional fees panel on transfer entry form (collapsed by default).
- Fee entered as flat amount (source currency) or percentage of transfer amount.
- Fee posted as a **linked expense transaction** in a compound transaction (shared compound ID with the main transfer).
- Fee category: Financial > Fees & Charges (user-changeable).
- Compound transaction shown as single entry in list; detail view shows both transfer and fee.
- Editing/deleting the compound transaction affects both parts together.
- Cross-currency fee support deferred to v2.
- New ledger Case 1.3a added (see ledger-entry.md changes below).

### §5.2.1 — Transaction Entry (Transaction List Display)

- **Amount colour coding (FG-A24):** Income = green, expense = red, transfer = neutral. Applies uniformly including Balance Adjustment entries (income BA = green, expense BA = red — resolving name collision distinction).
- **Default sort order (FG-A16):** Date descending (most recent first) confirmed as default. Custom sort available via filter window.

### §5.2.2 — Transaction Immutability & Editing

- **Soft-deleted category in edit (FG-A25):** Soft-deleted current category always shown as active selection in edit form. Category picker shows soft-deleted category as special "current" entry at top (re-selectable to cancel accidental edits). Once a new active category is saved, the deleted category is no longer accessible. Deleted categories remain hidden for transactions with active categories.

### §5.2.5 — Transaction Search

- **Fuzzy search redefined (FG-A15):** Now defined as fzf-style model: typo-tolerant (1–2 char errors), substring/contains, nearest-substring ranking, exact string match. Amount fields: exact match only (typing "500" finds ₹500 only, not ₹5,000).

### §5.2.6 — Transaction Filtering

- **Amount range filter (FG-A12):** Added to criteria table. Min amount, max amount, or both (inclusive bounds).
- **Multi-select on category/subcategory (FG-A13):** Noted in criteria table.
- **Simple vs. advanced filter views (FG-A13):** Simple view (v1) = AND logic across all criteria. Advanced view (v2) = predicate builder with AND/OR/NOT.
- **Sort controls (FG-A16):** Filter window now exposes sort controls. Options: date desc (default), date asc, amount desc, amount asc.
- **Filter state persistence (FG-A14):** Filters do NOT persist across navigation. Clear on leaving the transaction list. Saved filter profiles deferred to v2.

### §5.4.3 — Security

- **Lock scope fundamentally clarified (FG-A22):** Security lock applies to **sensitive account detail fields only**. Basic app functionality (transactions, account list, balances) is **never gated**. App-wide lock option removed.
- **PIN recovery (FG-A22):** PIN reset requires authentication via device security. If no device security is configured, user must set it up first.
- **Failed PIN lockout (FG-A23):** 5 consecutive fails → 1-hour timeout on sensitive field view. 15 cumulative consecutive fails → encrypted sensitive field data (card/account numbers) deleted. Financial data never deleted.
- Settings table updated to reflect simplified scope and new lockout policy.

### §5.4.4 — Management

- Added "Backup" entry pointing to new §5.4.6.

### §5.4.5 — Accessibility (new section, FG-A30)

- **Font scaling:** UI adapts to Android system font scale (up to 200%) — v1 requirement.
- **TalkBack:** Best-effort semantic labelling of interactive elements in v1. Comprehensive coverage deferred to v2/v3.
- **RTL layout:** Right-to-left layout mirroring via Flutter Directionality — v1 requirement.
- Non-English and non-Indian localisation not in scope.

### §5.4.6 — Local Data Backup (new section, FG-A31)

- Export all data (transactions, accounts, categories, templates, photos) as zip archive via Android file picker.
- Manual trigger from Settings > Backup. No auto-backup in v1.
- One-time in-app backup reminder after first month of use or first 50 transactions.
- Import/restore: deferred to v2.
- Cloud backup/sync: deferred to v2.

### §5.4.7 → §5.4.8 — About & Legal

- Renumbered from §5.4.5 to §5.4.8 due to insertion of §5.4.5 Accessibility, §5.4.6 Backup, and §5.4.7 About & Legal.

### §8 — In-Scope vs. Out-of-Scope

- **Added to v1 in-scope:** Transaction amount colour coding; date-desc default sort + custom sort via filter; amount range filter; simple filter view (AND logic); fzf-style fuzzy search with exact amount match; transfer fee feature; loan installment suggestion; PIN security scope + lockout; font scaling; RTL layout; TalkBack best-effort; local backup export; net worth excluded grayed-out inline; soft-deleted category in edit; same-currency deletion edge case.
- **Added to v2 deferred:** Advanced filter mode (FG-A13), saved filter profiles (FG-A14), backup import/restore (FG-A31), cloud backup/sync (FG-A31), comprehensive TalkBack coverage (FG-A30), cross-currency transfer fee, budget gaps FG-A17–A21 (explicitly listed).

### §9 — Success Criteria

- SC-8 updated to reflect that security lock covers sensitive fields only, not the whole app.

### §11 — Open Questions

- Updated to reference FG-A12–A31 resolution (2026-04-14, PRD v0.5.0).

---

## `docs/01-product/ledger-entry.md`

### Case 1.3a — Transfer with Fee (new case)

- Documents the two-transaction compound model for transfers with fees.
- Transaction 1 (transfer): Dr A₂ B, Cr A₁ B.
- Transaction 2 (fee expense): Dr FC F, Cr A₁ F.
- Both satisfy Dr = Cr individually.
- Effect: A₁ decreases by (B+F), A₂ increases by B, fee category balance increases by F.
- Notes compound transaction behaviour and cross-currency fee deferral.

### Complete Summary Table

- **Row 1.3a added:** Transfer with fee (2 linked txns, 4 entries).
- **Row 2.2a updated:** Label changed from "Create Asset Account" to "Create Account, initial balance B > 0 (asset state)".
- **Row 2.2b corrected:** Label changed from "Create Liability Account, balance B > 0" to "Create Account, initial balance B < 0 (liability state)"; posting updated to `Dr EQ, Cr A → balance = −|B|`. Removed incorrect "Cr L" notation.
- **Rows 2.3c, 2.3d removed:** Already removed from body in previous session; now also removed from summary table.
- **Rows 2.4c, 2.4d removed:** Same.
- **Row 3.1 updated:** Note that 1.3a applies when fee is present.
- **Row 3.3 updated:** Changed from "Unresolved — see Q46" to "Disallowed in v1 — deferred to v2".
- **Row 3.5 updated:** Budget replenishment noted as "deferred to v2".
- **Universal formula note added** below the table.

---

## `docs/06-helpers/gaps-and-questions.md`

- Frontmatter `last_updated` updated to 2026-04-14 (v0.5.0).
- Header note updated to reference FG-A12–A31 resolution (PRD v0.5.0).
- **FG-A12 through FG-A31 full text removed.** Replaced with a resolution summary table covering all 20 items.
- **FG-C3 removed.** Superseded by FG-A16's decision on default sort and custom sort via filter window.
- FG-B and FG-C sections otherwise unchanged (remain open).

---

## `docs/06-helpers/ideation-tracker.md`

- Frontmatter and header `last_updated` updated to 2026-04-14 (PRD v0.5.0).
- PRD deliverable row updated to v0.5.0.
- **New 2026-04-14 key decisions entry** added (before the previous v0.4.0 entry) covering all FG-A12–A31 decisions and the FG-C3 supersession.
- Document Index updated: PRD version changed to 0.5.0.
- Readiness gate updated to reference v0.5.0.
