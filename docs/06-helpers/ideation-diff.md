---
title: Ideation Diff
status: current
owner: tpm
updated: 2026-05-07
---

# Ideation Diff — Session 2026-05-07 (Sprint Roadmap)

## 1. Files Modified

| File | Action |
|---|---|
| `docs/04-implementation/roadmap.md` | CREATED — Sprint roadmap, 10 sprints, 208 tasks |
| `docs/06-helpers/ideation-tracker.md` | UPDATED — Phase 3 marked complete; Execution Plan row finalised |
| `docs/06-helpers/ideation-diff.md` | OVERWRITTEN (this file) |

## 2. Changes Made

### `docs/04-implementation/roadmap.md`

- Sprint plan derived from Feature DAG build phases (Phase 0–9) + Onboarding
- 10 sprints; each sprint table lists task ID, story ID, and explicit `Blocked By` column
- Phase → Sprint mapping:

| DAG Phase | Nodes | Sprint |
|---|---|---|
| 0 (partial) | INFRA-1, INFRA-2 | Sprint 1 |
| 0 (remaining) | INFRA-3..7 | Sprint 2 |
| 1 | ACC-01, CAT-01, CURR-01, SCHED-01, SET-01 | Sprint 3 |
| 2 | ACC-02, TXN-01, CAT-02/4, CURR-02, SCHED-02, SET-02/5/6 | Sprint 4 |
| 3 | ACC-03/5/7/9, TXN-02/3/4/6/10, CURR-03, RECUR-01, SET-03/4/7/8, OB-01, HOME-03 | Sprint 5 |
| 4 | ACC-04/6/8/10/11/12, TXN-07, CAT-03, RECUR-02/3, INST-01, DRAFT-01 | Sprint 6 |
| 5 | TXN-05/11, INST-02, SET-09/10 | Sprint 7 |
| 6 | TXN-08/9/12, INST-03, HOME-01 | Sprint 8 |
| 7–9 | SCHED-03, HOME-02/4/5 | Sprint 9 |
| — | OB-01 sub-tasks (onboarding wizard) | Sprint 10 |

### `docs/06-helpers/ideation-tracker.md`

| Field | Before | After |
|---|---|---|
| Phase 3 status | 🟡 In Progress | ✅ Complete |
| Execution Plan row | 🟡 In Progress | ✅ Complete — roadmap produced |

## 3. Decisions

| Decision | Rationale |
|---|---|
| Phase 0 split across 2 sprints | INFRA is dense (28 tasks); DB schema + domain must land before DI/nav/theme can wire |
| Onboarding in its own Sprint 10 | OB-01 gated on T-195/196 (Sprint 5) + T-33 (Sprint 3) + T-83 (Sprint 4) — earns its own slot |
| Blocking column per task | Makes dependency chains visible without needing to re-derive from DAG at execution time |
| Critical path annotated in overview | 12-hop path surfaced so executor knows which tasks to protect |
