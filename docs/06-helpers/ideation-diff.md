---
title: Ideation Diff
status: current
owner: lead-engineer
updated: 2026-04-20
---

# Ideation Diff — Session 2026-04-20 (Data Model Production)

## 1. Files Created

### `docs/02-technical/data-model.md`

New file. First production of the canonical schema reference.

**Contents:**
- ER diagram (Mermaid `erDiagram`) covering all 18 persisted tables + FTS virtual table + search view
- Design principles: UUID PKs, integer minor units for money, integer micro-units for rates, soft-delete universal
- Schema migration policy: Drift `migrationSteps()`, schema snapshot JSON files, additive-only policy
- 18 table definitions with full column tables (type, nullability, default, constraints, purpose)
- FTS5 virtual table (`transactions_fts`) and `transactions_search_view` DDL
- Drift type mappings and 12 custom type converters documented
- `Money` value object specification (integer minor units, never `double`)
- 33-entry index catalogue with rationale
- Soft-delete policy table with cascade behaviour per entity
- Void/reversal/correction chain policy
- Autoincrement vs UUID PK policy
- 5 open questions (DM-001 through DM-005)

**Key decisions made:**
- Amount storage: `INTEGER` in minor units (follows TC-044 LE note; industry standard for financial systems)
- Exchange rate storage: `INTEGER` as `rate × 1,000,000` (6 decimal places, no floating-point)
- `account_details` normalization: category-specific account fields in a separate KV table — avoids 30+ nullable columns on `accounts`
- Correction chain model: single `corrects_transaction_id` linked-list pointer (not a shared group ID) — follows TC-024 LE note
- `compound_group_id` + `compound_role` for transfer-with-fee compound groups (follows TC-002)
- `home_currency_at_capture` alongside `exchange_rate_micro` on transactions (follows TC-029 founder resolution)
- `is_system` flag on accounts (distinct from `is_protected`) for EQ accounts — never surfaced in any user view
- Budget tables (`budgets`, `budget_periods`) created in v1 as empty placeholders — avoids v2 migration
- Tags tables (`tags`, `transaction_tags`) created in v1 as empty placeholders — avoids v2 migration
- Payees table schema-ready but not surfaced in v1 UI
- Recurring and installment schedules both use materialized occurrence records (unified model from TC-003 LE note)
- `scheduled_occurrences` uses 90-day lookahead window; `installment_occurrences` materialized eagerly at template creation
- `app_settings` is a typed KV table (not a JSON blob) — avoids competitor AP-1 anti-pattern
- `drafts` table max 5 rows enforced at app layer (FIFO eviction per PRD §5.4.3)

---

## 2. Files Modified

### `docs/02-technical/sds.md`

**Edit — §2.3 Database and Persistence:** Added cross-reference to `data-model.md` immediately after the section heading.

### `docs/06-helpers/ideation-tracker.md`

**Edit — Deliverable Checklist:** Added row `2a — Data Model` with status `PRODUCED (2026-04-20)` and summary of what was resolved. Updated SDS row to remove "Data Model" from the remaining sections list.

---

## 3. Files Unchanged This Session

- `docs/01-product/` — all locked, no edits
- `docs/06-helpers/gaps-and-questions.md` — DM-001 through DM-005 are recorded in data-model.md §14; will be migrated to gaps-and-questions in next session if they require PM/founder input

---

## DM Questions Resolution

| ID | Decision | Status | Source |
|----|----------|--------|--------|
| DM-001 | Keep `'primary'/'secondary'` named roles for v1. `sequence_number` deferred to v2 — v1 compound groups are always exactly 2 members. | RESOLVED | TC-002 LE Verdict |
| DM-002 | SQL-level CHECK constraint enumerating valid `detail_key` values is already implemented in §3.2 schema definition. | RESOLVED (already in schema) | §3.2 data-model.md |
| DM-003 | JSON-in-column retained for `recurrence_constraints`. Field is immutable (TC-026); no filtering by value needed at v1; normalization adds complexity with no query benefit. | RESOLVED | TC-026 PM + LE |
| DM-004 | FK enforcement on `transactions.payee_id` active from day one. `payee_id` is nullable; FK costs nothing and preserves integrity for v2 payees UI. | RESOLVED | §3.3 schema + PRD §5 |
| DM-005 | Chain-conversion formula for stale `home_currency_at_capture` rates not yet specifiable — API contracts doc does not exist. | DEPRIORITIZED — not blocking v1; spec when api-contracts.md is produced | TC-029 founder resolution |
