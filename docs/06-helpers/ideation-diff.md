---
title: Ideation Diff
status: current
owner: tpm
updated: 2026-05-07
---

# Ideation Diff — Session 2026-05-07 (Execution Planning — Stories + Tasks)

## 1. Files Modified

| File | Action |
|---|---|
| `docs/03-planning/stories.md` | PENDING — Wave 2 collation not yet run |
| `docs/03-planning/tasks.md` | PENDING — Wave 2 collation not yet run |
| `docs/03-planning/scratch/e2-output.md` | CREATED — E-2 Accounts Domain scratch |
| `docs/03-planning/scratch/e3-output.md` | CREATED — E-3 Transactions Domain scratch |
| `docs/03-planning/scratch/e4-output.md` | CREATED — E-4 Categories Domain scratch |
| `docs/03-planning/scratch/e5-output.md` | CREATED — E-5 Currency Domain scratch |
| `docs/03-planning/scratch/e6-output.md` | CREATED — E-6 Recurring & Scheduling Domain scratch |
| `docs/03-planning/scratch/e7-output.md` | CREATED — E-7 Installments Domain scratch |
| `docs/03-planning/scratch/e8-output.md` | CREATED — E-8 Home / Dashboard Domain scratch |
| `docs/03-planning/scratch/e9-output.md` | CREATED — E-9 Settings Domain scratch |
| `docs/03-planning/scratch/e10-output.md` | CREATED — E-10 Onboarding Domain scratch |
| `docs/06-helpers/ideation-tracker.md` | UPDATED |
| `docs/06-helpers/ideation-diff.md` | OVERWRITTEN (this file) |

## 2. Changes Made

### `docs/03-planning/scratch/e*-output.md` (9 files)

- 9 scratch files produced via parallel TPM agent wave (one agent per epic)
- Each file uses epic-scoped placeholder IDs (`E{N}-S{i}`, `E{N}-T{i}`) pending collation renumbering
- Collation (Wave 2) will renumber to global sequential IDs and append to `stories.md` / `tasks.md`

| Epic | Stories | Tasks |
|---|---|---|
| E-2 Accounts Domain | 8 | 16 |
| E-3 Transactions Domain | 13 | 17 |
| E-4 Categories Domain | 7 | 18 |
| E-5 Currency Domain | 5 | 19 |
| E-6 Recurring & Scheduling | 7 | 25 |
| E-7 Installments Domain | 8 | 22 |
| E-8 Home / Dashboard | 8 | 26 |
| E-9 Settings Domain | 10 | 22 |
| E-10 Onboarding Domain | 9 | 15 |
| **Total (new)** | **75** | **180** |
| E-1 (already in files) | 7 | 28 |
| **Grand total** | **82** | **208** |

### `docs/06-helpers/ideation-tracker.md`

| Field | Before | After |
|---|---|---|
| Phase 3 status | 🟢 Ready to Start | 🟡 In Progress |
| Execution Plan row | 🟢 Ready to Start | 🟡 In Progress — scratch files complete, collation pending |

## 3. Decisions

| Decision | Rationale |
|---|---|
| Two-wave parallel decomposition | 9 agents run in parallel (one per epic) to avoid serial bottleneck |
| Epic-scoped placeholder IDs in scratch | Prevents ID races between parallel agents |
| Wave 2 collation via bash | `awk`/`sed` renumbering is faster and safer than an agent write |
| Story plan pre-decided for E-2/E-3 | Agents kept stalling on research; injecting story list directly unblocked them |
| Sprint planning deferred | Will follow collation; sprints will map strictly to feature DAG build phases |
