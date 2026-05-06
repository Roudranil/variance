---
title: Ideation Diff
status: current
owner: le
updated: 2026-05-06
---

# Ideation Diff — Session 2026-05-06 (API Contracts)

## 1. Files Modified

| File | Action |
|---|---|
| `docs/02-technical/api-contracts.md` | CREATED |
| `docs/06-helpers/ideation-tracker.md` | UPDATED |
| `docs/06-helpers/ideation-diff.md` | OVERWRITTEN (this file) |

## 2. Changes Made

### `docs/02-technical/api-contracts.md`

- Created from scratch
- 10 domain sections: Accounts, Transactions, Entries, Categories, Currency/FX, Recurring, Installments, Payees/Tags, Settings/Drafts, Home
- Each section: repo interface methods + use cases + notifiers (tables only)
- Cross-cutting types: `Result<T>`, `Failure`, `Money`, `AppSettings`
- Constraints table at bottom (layer rules)

### `docs/06-helpers/ideation-tracker.md`

| Field | Before | After |
|---|---|---|
| Phase 2 status | 🟡 In Progress | ✅ Complete |
| Phase 3 status | ⬜ Not Started | 🟢 Ready to Start |
| API Contracts row | ⏭️ Skipped (2026-04-29) | ✅ PRODUCED (2026-05-06) |
| Execution Plan blocked note | Blocked on Tests + Security | Unblocked |
| Readiness Gate — SDS | `[ ]` | `[x]` |
| Readiness Gate — Tests spec | `[ ]` | `[x]` covered by SDS §2.11 |
| Readiness Gate — Security spec | `[ ]` | `[x]` covered by SDS §4 |
| Status line | UI Spec done, Tests+Security remaining | Phase 2 complete. Ready for execution planning. |

## 3. Decisions

| Decision | Rationale |
|---|---|
| Skip `tests.md` | SDS §2.11: full pyramid, tooling, 5 integration scenarios |
| Skip `security.md` | SDS §4: 10-section threat model — sufficient for v1 single-user |
| API Contracts: high-level only | Developer infers detail from SDS + data model |
