---
title: Feature DAG — Build Plan
type: helper
status: ready
owner: architect
created: 2026-04-21
---

# Feature DAG — Build Plan

## 0. Important Caveat

This plan is a **starting point only**. The actual DAG will likely be more detailed and complex:
- More nodes (sub-features, edge cases, implicit infrastructure)
- More edges (dependencies not visible without deep PRD/TC reading)
- More domains or finer-grained domain splits

Build-day agents have authority to add nodes, edges, and sections beyond this plan. The plan is a scaffold, not a ceiling.

---

## 1. Output Target

`docs/02-technical/feature-dag.md`

---

## 2. Document Structure

```
# Feature DAG — Variance v1

## 1. Overview
### 1.1 Purpose
### 1.2 How to Read This Document
### 1.3 Node ID Convention
### 1.4 Edge Types

## 2. Infrastructure Foundations
### 2.1 INFRA-1 — Database Schema + Drift Setup
### 2.2 INFRA-2 — Domain Entities + Use Case Scaffolding
### 2.3 INFRA-3 — Riverpod DI Wiring
### 2.4 INFRA-4 — GoRouter Navigation Shell
### 2.5 INFRA-5 — Theme + Token System
### 2.6 INFRA-6 — Currency Bundle
### 2.7 INFRA-7 — Ledger Engine

## 3. DAG Diagram
### 3.1 Full DAG (Mermaid)
### 3.2 Critical Path

## 4. Feature Nodes by Domain
### 4.1 Accounts Domain
### 4.2 Transactions Domain
### 4.3 Categories Domain
### 4.4 Currency Domain
### 4.5 Recurring & Scheduling Domain
### 4.6 Installments Domain
### 4.7 Home / Dashboard Domain
### 4.8 Settings Domain
### 4.9 Onboarding Domain

## 5. Build Order
### 5.1 Critical Path Analysis
### 5.2 Build Phases

## 6. Reference Index
### 6.1 PRD → Node Map
### 6.2 TC → Node Map
### 6.3 DM Table → Node Map
```

---

## 3. Node Body Template

```markdown
#### {NODE-ID} — {Feature Name}

> {One sentence: what the user can do.}
> {One sentence: key domain rule or constraint.}
> {One sentence: infrastructure it relies on or produces.}

**Sources** | PRD {sections} | TC-{NNN}, ... | SDS {sections} | DM: `table1`, `table2`

**Depends on:** {NODE-ID, ...}
**Required by:** {NODE-ID, ...}
```

---

## 4. Edge Types

| Type | Meaning | Mermaid |
|---|---|---|
| HARD | B cannot run without A (schema, interface, entity) | `A -->|HARD| B` |
| SOFT | B easier after A, shippable alone | `A -.->|SOFT| B` |

- INFRA-1..7 = implicit HARD prereq for all features
- In Mermaid: one `subgraph INFRA` block, annotated once — no individual edges per feature

---

## 5. Infrastructure Foundations

| Node | What it is | Key surfaces |
|---|---|---|
| INFRA-1 | Database schema + Drift setup | All 18 tables + FTS virtual table, WAL mode, migrations |
| INFRA-2 | Domain entities + use case scaffolding | Freezed entities, repo interfaces, Result type |
| INFRA-3 | Riverpod DI wiring | Provider graph, app entry point |
| INFRA-4 | GoRouter navigation shell | Bottom nav (3 tabs), route tree |
| INFRA-5 | Theme + token system | ThemeExtension, Material You, dynamic_color |
| INFRA-6 | Currency bundle | Static ISO 4217 JSON, `currencies` table seed |
| INFRA-7 | Ledger engine | LedgerEngine, BalanceCalculator, PostingCaseSelector |

---

## 6. Full Node Inventory (57 nodes)

| Node | Feature | Domain | Depends On | PRD | TC | SDS | DM |
|---|---|---|---|---|---|---|---|
| ACC-01 | Account CRUD | Accounts | INFRA-1,2,3,7 | §5.1.1 | TC-012,020,027,035 | §1.5.1 | `accounts`, `account_details` |
| ACC-02 | Account category-specific fields | Accounts | ACC-01 | §5.1.2 | TC-013 | — | `account_details` |
| ACC-03 | Account balance view + net worth | Accounts | ACC-01,ACC-02,CURR-01 | §5.1.4 | TC-045 | §1.4.4 | `accounts`, `entries` |
| ACC-04 | Account detail screen | Accounts | ACC-03,TXN-01 | §5.1.4a | TC-032 | — | — |
| ACC-05 | Account balance edit (journal adjustment) | Accounts | ACC-01,TXN-01,INFRA-7 | §5.1.3,§4.10 | TC-045,046 | §1.4.1 | `transactions`, `entries` |
| ACC-06 | Balance reconciliation | Accounts | ACC-05 | §5.1.3a | — | — | `transactions`, `entries` |
| ACC-07 | Internal transfer | Accounts | ACC-01,TXN-01,INFRA-7 | §5.1.5 | TC-036 | §1.4.1 | `transactions`, `entries` |
| ACC-08 | Transfer with fee | Accounts | ACC-07,CAT-01 | §5.1.5b | TC-052 | — | `transactions`, `entries` |
| ACC-09 | Credit card balance model | Accounts | ACC-01,ACC-02 | §5.1.6 | TC-004 | — | `accounts`, `entries` |
| ACC-10 | Credit card payment reminder | Accounts | ACC-09,ACC-02,SCHED-02,TXN-01 | §5.1.7 | TC-013,053 | §2.6 | `accounts` |
| ACC-11 | Account soft-delete lifecycle | Accounts | ACC-07,RECUR-01 | §5.1.1.5,5.1.1.6 | TC-012,020,039 | §1.6.6 | `accounts`, `recurring_templates` |
| ACC-12 | Negative balance + overdraft warning | Accounts | ACC-03,TXN-01 | §5.1.4.1,5.1.4.2 | — | — | — |
| TXN-01 | Transaction entry (income/expense) | Transactions | ACC-01,CAT-01,INFRA-7,CURR-01 | §5.2.1 | TC-001,024,025 | §1.4.1 | `transactions`, `entries` |
| TXN-02 | Transaction immutability + correction model | Transactions | TXN-01,INFRA-7 | §5.2.2 | TC-017,018 | §1.6.7 | `transactions`, `entries` |
| TXN-03 | Transaction detail view | Transactions | TXN-01 | §5.2.1.5,5.2.1.6 | TC-032 | — | — |
| TXN-04 | Photo attachments | Transactions | TXN-01 | §5.2.3 | TC-007 | §2.15 | `attachments` |
| TXN-05 | Transaction list (unified + per-account) | Transactions | TXN-01,ACC-04 | §5.2.1.1,5.2.1.3 | — | §1.4.2 | `transactions`, `entries` |
| TXN-06 | Duplicate transaction detection | Transactions | TXN-01 | §5.2.1.8 | — | — | `transactions` |
| TXN-07 | Large transaction warning | Transactions | TXN-01,SET-04 | §5.4.4,5.4.4.1 | TC-047 | — | `app_settings` |
| TXN-08 | Transaction search (FTS5 + Dart scoring) | Transactions | TXN-05 | §5.2.5 | TC-009,042,050 | §2.8 | `transactions_fts`, `transactions_search_view` |
| TXN-09 | Transaction filter | Transactions | TXN-05 | §5.2.6 | TC-023,058 | — | — |
| TXN-10 | Future-dated / pending transactions | Transactions | TXN-01,SCHED-01 | §5.7,5.7.1 | TC-008,039 | §1.6.8 | `transactions` |
| TXN-11 | Pending tx auto-void on account delete | Transactions | TXN-10,ACC-11 | §5.7.1 | TC-039 | — | `transactions` |
| TXN-12 | Transaction amount colour coding + list layout | Transactions | TXN-05 | §5.2.1,5.2.1.1 | — | — | — |
| DRAFT-01 | Drafts (auto-save, resume, delete) | Transactions | SET-03,TXN-01 | §5.4.3.1 | TC-005 | — | `drafts` |
| CAT-01 | Category CRUD (two-level, income/expense) | Categories | INFRA-1,2,3 | §5.2.4 | TC-028,040,051 | — | `categories` |
| CAT-02 | Default category seeding | Categories | CAT-01 | §5.6.1 | TC-014,016 | — | `categories` |
| CAT-03 | Category soft-delete + migration flow | Categories | CAT-01,TXN-02 | §5.2.4.4,5.2.4.5 | TC-034,040 | — | `categories`, `transactions` |
| CAT-04 | Protected "Balance Adjustment" system category | Categories | CAT-01 | §5.2.4.6 | TC-016,046 | — | `categories` |
| CURR-01 | Multi-currency display + exchange rate cache | Currency | INFRA-6,INFRA-1 | §7,7.1 | TC-006,029,044 | §2.7,2.16 | `currencies`, `exchange_rates` |
| CURR-02 | Currency symbol disambiguation | Currency | CURR-01 | §7.0.1 | TC-013 | — | — |
| CURR-03 | Exchange rate estimate during entry + staleness warning | Currency | CURR-01,TXN-01 | §7.1.3 | TC-006 | §2.7.4 | `exchange_rates` |
| RECUR-01 | Recurring transaction templates | Recurring | TXN-01,SCHED-01 | §5.2.7 | TC-003,026,030,041 | §2.6 | `recurring_templates`, `scheduled_occurrences` |
| RECUR-02 | Recurring template editing + child tx handling | Recurring | RECUR-01,TXN-02 | §5.2.7.1,5.2.7.2 | TC-056 | — | `recurring_templates` |
| RECUR-03 | Recurring template pause/unpause | Recurring | RECUR-01 | §5.2.7 | — | — | `recurring_templates` |
| INST-01 | Installment template | Installments | RECUR-01 | §5.2.8 | TC-010,011,021,022,038 | — | `installment_plans`, `installment_occurrences` |
| INST-02 | Installment running total tracking | Installments | INST-01 | §5.2.8.1 | — | — | `installment_occurrences` |
| INST-03 | Installment early close | Installments | INST-01,INST-02,TXN-01 | §5.2.8.3 | TC-021,055 | — | `installment_plans`, `installment_occurrences` |
| SCHED-01 | Scheduling infrastructure (WorkManager + app-launch sweep) | Scheduling | INFRA-1 | §5.2.7 | TC-041 | §2.6 | `recurring_templates`, `scheduled_occurrences` |
| SCHED-02 | Remind-and-confirm exact alarm + notifications | Scheduling | SCHED-01 | §5.2.7 | TC-041 | §2.6 | `recurring_templates` |
| SCHED-03 | Pending confirmations screen + home alert cards | Scheduling | SCHED-02,HOME-01 | §5.8.5,5.7a | TC-003,030,049 | — | — |
| HOME-01 | Home screen dashboard | Home | ACC-03,TXN-05,SET-01 | §5.8 | — | — | `transactions`, `accounts` |
| HOME-02 | Home screen search + filter | Home | HOME-01,TXN-08,TXN-09 | §5.8.4 | TC-042,050 | — | — |
| HOME-03 | Quick-entry FAB | Home | TXN-01 | §5.8.6 | — | — | — |
| HOME-04 | Alerts section | Home | SCHED-03,ACC-10 | §5.8.5 | — | — | — |
| HOME-05 | Backup reminder alert | Home | HOME-04,SET-07 | §5.8.5.1 | — | — | `app_settings` |
| SET-01 | Settings hub + appearance | Settings | INFRA-1,3,4,5 | §5.4.1 | TC-048 | §2.18 | `app_settings` |
| SET-02 | Locale + format settings | Settings | SET-01,CURR-01 | §5.4.2 | TC-029,044 | — | `app_settings` |
| SET-03 | Transaction entry settings | Settings | SET-01,TXN-01 | §5.4.3 | TC-005 | — | `app_settings`, `drafts` |
| SET-04 | Warnings + limits settings | Settings | SET-01,TXN-07 | §5.4.4 | TC-047 | — | `app_settings` |
| SET-05 | Profile settings (display name) | Settings | SET-01 | §5.4.5 | — | — | `app_settings` |
| SET-06 | Security settings (lock, PIN) | Settings | SET-01 | §5.4.6 | — | §4.3 | `app_settings` |
| SET-07 | Data backup (export zip) | Settings | SET-01,INFRA-1 | §5.4.10 | TC-054 | §2.17 | all tables |
| SET-08 | Account management screen | Settings | ACC-01,SET-01 | §5.4.7 | TC-057 | — | `accounts` |
| SET-09 | Category management screen | Settings | CAT-01,CAT-03,SET-01 | §5.4.8 | TC-014 | — | `categories` |
| SET-10 | Recurring + installment management screen | Settings | RECUR-01,INST-01,SET-01 | §5.4.9 | — | — | `recurring_templates` |
| OB-01 | Onboarding wizard | Onboarding | CAT-02,CURR-01,SET-02 | §5.6.2 | TC-037 | — | `app_settings` |

---

## 7. Pre-Resolved Open Questions

| # | Question | Resolution |
|---|---|---|
| Q1 | DRAFT-01: separate node or sub-bullet of TXN-01? | Separate — own `drafts` table, distinct lifecycle |
| Q2 | CURR-02: node or display rule inside TXN-12? | Separate — independently testable, distinct PRD ref |
| Q3 | HOME-05: separate node or collapse into SET-07? | Separate — distinct trigger logic from backup action |
| Q4 | INFRA-7 over-connects diagram if drawn as individual edges | Treat as `subgraph INFRA` — annotate once, no per-feature edges |
| Q5 | Credit card fields in ACC-02 or ACC-09? | Fields in ACC-02; reminder logic in ACC-10; ACC-10 HARD-depends ACC-02 |

---

## 8. Parallelisation Strategy (for build day)

The DAG document can be built by **4 parallel agents + 1 sequential assembler**.

### Phase 1 — Parallel (4 agents, each writes a staging file)

Each agent writes to a dedicated staging file in `docs/06-helpers/dag-parts/`. No shared file writes.

| Agent | Staging file | Sections to write |
|---|---|---|
| **DAG-A** | `dag-parts/part-a-infra-accounts.md` | §2 Infrastructure (INFRA-1..7) + §4.1 Accounts (ACC-01..12) |
| **DAG-B** | `dag-parts/part-b-transactions.md` | §4.2 Transactions (TXN-01..12, DRAFT-01) |
| **DAG-C** | `dag-parts/part-c-categories-currency-recurring.md` | §4.3 Categories + §4.4 Currency + §4.5 Recurring & Scheduling + §4.6 Installments |
| **DAG-D** | `dag-parts/part-d-home-settings-onboarding.md` | §4.7 Home + §4.8 Settings + §4.9 Onboarding |

### Phase 2 — Sequential (1 assembler agent)

Reads all 4 staging files + node inventory, then writes the final `feature-dag.md`:
- §1 Overview
- §2..§4 (assembled from staging files)
- §3 Mermaid diagram (derived from full node inventory)
- §5 Build phases (derived from dependency graph)
- §6 Reference index (reverse lookup tables: PRD→node, TC→node, DM table→node)
- Cleans up `dag-parts/` staging dir
- Updates ideation-tracker, ideation-diff, ideation-folder-structure

### Why this split is safe

- Phase 1 agents write to non-overlapping files → zero conflict risk
- Mermaid diagram and reference index require ALL nodes → must be sequential in Phase 2
- Each Phase 1 agent only needs: this plan + their domain's source doc sections (PRD, TCs, SDS for their nodes)
