---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 06-helpers/gaps-and-questions.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 3)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Feature gap resolution — FG-B1 through FG-B9 (Part 3, Group B of `gaps-and-questions.md`). PRD bumped to **the current version**. v2 draft PRD created.

---

## `docs/01-product/prd.md`

### Frontmatter & Version

- Version bumped from 0.5.0 to **0.6.0**.

### §2 — Version Roadmap

- v1 scope updated: "home summary" replaced with "home screen dashboard (greeting, net worth, monthly summary, alerts, search/filter)".

### §5.2.1 — Transaction Entry (Transaction Detail View, FG-B1)

- **New "Transaction Detail View" block** added after the "Transaction Description Display" paragraph.
- v1 contents defined: header (type badge, colour-coded), amount (with exchange rate for foreign currency), date & time, title, description, account info (source/destination, including soft-deleted accounts), category info, fee breakdown (compound transfer-with-fee), photo carousel (horizontally scrollable, tap for full-screen), contextual menu (edit, delete).
- v2 additions noted: correction history, recurring template link, installment/loan status.

### §5.2.4 — Transaction Categories (Soft-Deleted Categories in Filter, FG-B9 consistency)

- **Soft-deleted categories in filter dropdowns:** Changed from "hidden from filter dropdowns" to "visible in filter dropdowns for historical transaction lookup." Mirrors soft-deleted account treatment in §5.1.1.

### §5.2.4 — Transaction Categories (Category Usage Count, FG-B5)

- **New "Category usage count on deletion" bullet** added before the transaction migration prompt.
- Shows count of active (non-voided) transactions referencing the category before soft-delete proceeds.
- Must be efficient (single aggregate query). Skipped if count is zero.

### §5.2.5 — Transaction Search (FG-B9)

- **Searchable fields note updated:** Explicitly states that transactions referencing soft-deleted accounts or soft-deleted categories are included in search results.

### §5.2.6 — Transaction Filtering (FG-B9)

- **Account filter criterion updated:** Explicitly states that soft-deleted accounts are included in the account filter picker.

### §5.2.8 — Installments (Installment Early Close, FG-B7)

- **New "Installment early close" block** added after the running total tracking section.
- Flow: "Mark series as complete" → optional final lump-sum payment → cancel future installments → archive template → mismatch warning with option to update target total or keep original.

### §5.1.1 — Account CRUD (Soft-Deleted Account Behaviour, FG-B9)

- **New "Soft-deleted account behaviour" block** added to the Delete section.
- Frozen state: no new transactions, excluded from account pickers in transaction forms.
- Hidden from account list on home screen and new transaction pickers.
- Visible in Settings > Accounts and grayed-out in net worth view.
- Historical transactions remain visible, searchable, and filterable.
- Soft-deleted accounts included in filter account picker.
- Does not extend to soft-deleted (voided) transactions.

### §5.4.2 — Primary Configuration (Display Name, FG-B2)

- **New "Display name" setting** added. Optional text field. Used in home screen greeting (§5.8). If empty, greeting shows "Hi!" with no name.

### §5.4.4 — Management (Per-Account Settings, FG-B8)

- **Accounts row clarified:** "Per-account settings" is the account edit form (§5.1.1 Edit). Accessible from both Settings > Accounts and from the account contextual menu. No additional per-account settings.

### §5.8 — Home Screen & Dashboard (new section, FG-B2, FG-B4)

- **§5.8.1 Greeting:** "Hi, [display name]!" or "Hi!" if no display name set.
- **§5.8.2 Financial Summary:** Net worth (always current, not affected by month selector), current month income, expense, and net.
- **§5.8.3 Month Selector:** Left/right arrows. Controls income/expense/net summary and transaction list. Does not affect net worth. Default: current calendar month.
- **§5.8.4 Transaction List:** Month-filtered transaction list following unified list display rules. Search and filter accessible, operating on the month-filtered set.
- **§5.8.5 Alerts:** Three v1 alert types — pending recurring confirmations, credit card payment due, backup reminder. Alerts section on home screen + dedicated Pending Confirmations screen via nav overflow. Alert dismissal rules defined per type.
- **§5.8.6 Quick Entry:** FAB on home screen. Exact design deferred to UX Flows (UX-2).

### §8 — In-Scope vs. Out-of-Scope

- **v1 in-scope updated:** "Basic home summary" replaced with full §5.8 reference. Nine new FG-B bullets added: transaction detail view, home screen dashboard, home screen alerts, category usage count, installment early close, per-account settings, soft-deleted account behaviour, soft-deleted categories in filter.
- **v2 deferred updated:** Two new bullets: transaction detail view v2 additions (FG-B1), home screen v2 additions (FG-B2).

### §11 — Open Questions

- Updated to reference FG-B1–B9 resolution (PRD the current version). Notes FG-B3 and FG-B6 deferred with budgets. References new v2 draft PRD. FG-C items remain open.

### Table of Contents

- Added §5.8 Home Screen & Dashboard with subsections (§5.8.1–§5.8.6).

---

## `docs/01-product/prd-v2-draft.md` (new file)

- **Created** as a consolidation of all v2-deferred features, decisions, questions, and ideas.
- 20 sections covering: budgeting (full feature + FG items), savings goals, split transactions, advanced filter, saved filter profiles, backup import/restore, cloud backup, comprehensive TalkBack, reordering, recurring disable/enable, subcategory reassignment, analytics/charts, data management, audit view, tags, cross-currency transfers, transaction detail v2 additions, home screen v2 additions, v3+ items, FG-C items.

---

## `docs/06-helpers/gaps-and-questions.md`

- Frontmatter version updated to 0.6.0.
- Header updated to reference FG-B1–B9 resolution (PRD the current version).
- Part 3 description updated: FG-B resolved, FG-C remains open.
- **FG-B1 through FG-B9 full text removed.** Replaced with a resolution summary note. FG-B3 and FG-B6 noted as deferred with budgets to v2.

---

## `docs/06-helpers/ideation-tracker.md`

- Frontmatter version updated to 0.6.0.
- Header updated to PRD the current version.
- PRD deliverable row updated to the current version with FG-B complete note.
- **New 2026-04-14 key decisions entry** added (before the previous session's entry) covering all FG-B1–B9 decisions, display name setting, and v2 draft PRD creation.
- Readiness gate updated to reference the current version.
- Document Index updated: PRD version 0.6.0, new PRD v2 Draft row added.

---

## `docs/06-helpers/ideation-folder-structure.md`

- Tree updated: `prd-v2-draft.md` added under `01-product/`.
- Document Index: new row for PRD v2 Draft.
