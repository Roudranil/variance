---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 01-product/input-fields.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 7)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Input fields audit — comprehensive inventory of all user input fields across every entity type (transactions, accounts, categories, templates, installments), with editability rules (in-place / ledger entry / immutable). 4 previously unspecified decisions resolved. New `input-fields.md` reference document created. PRD updated with new field requirements.

---

## `docs/01-product/input-fields.md` (NEW)

- **New authoritative reference document** created for SDS schema design, UX Flows form layouts, and API contract validation.
- Covers 7 major entity groups: Transaction Entry (with fee and validation sub-sections), Account Creation & Edit (with balance edit, reconciliation, CC payment, and deletion flow), Categories (with deletion flow), Recurring Templates (with pause), Installment Templates (with early close), Settings, and Onboarding.
- Editability legend: IP (in-place), LE (ledger entry), IM (immutable).
- Complete editability matrix at the end summarising all fields across posted transactions, accounts, templates, and categories.

---

## `docs/01-product/prd.md`

### §5.1.2 — Account Categories

- **Category-specific fields table restructured** from single "Additional Fields" column to two columns: "Required Fields" and "Optional Fields".
- **New required/optional decisions baked in:**
  - Bank Account: bank name required; account number, branch, IFSC optional.
  - Credit Card: billing date and payment due date required (enables payment reminders and statement balance); card name, number, expiry, credit limit, linked bank optional.
  - Investment: investment type required (FD, MF, Stocks, PPF, NPS, Other); institution name, current value optional.
  - All other categories: all category-specific fields optional.
- **Editability note added** below the table: all category-specific fields are in-place editable. Cross-reference to `input-fields.md`.

### §5.2.7 — Recurring Transactions

- **New "Template editability" block added** before "Child transaction editing and deletion".
- Editable fields (in-place, future occurrences only): amount, account(s), category, subcategory, title, description, posting behaviour.
- Immutable fields: transaction type, recurrence definition (N, unit, constraints), start date, end date.
- Rule: to change the schedule structure, user must archive and create a new template.

### §5.2.8 — Installments

- **New "Installment editability" block added** before "Installment early close".
- Total configured: immutable after creation.
- User can add new future installments or remove unposted future installments (changes Projected final total, not Total configured).
- Per-installment amounts for future installments: adjustable. Mismatch warning applies.
- Cross-reference to §5.2.7 for general template editability rules.

---

## `docs/06-helpers/ideation-folder-structure.md`

- **Tree updated:** Added `input-fields.md` to `01-product/` folder.
- **Document index updated:** New row for Input Fields document.

---

## Files NOT changed

- `docs/01-product/ledger-entry.md` — no ledger changes.
- `docs/01-product/prd-v2-draft.md` — no v2 changes.
- `docs/06-helpers/gaps-and-questions.md` — all gaps resolved in this session (no new open items).
