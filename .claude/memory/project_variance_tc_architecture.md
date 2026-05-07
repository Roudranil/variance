---
name: Variance — Key Architecture Decisions from TC Review
description: All architecture decisions locked from TC-001–TC-058 review + 5 founder decisions — entity schemas, template lifecycle, multi-currency, navigation, search, installments
type: project
---
**Source:** `docs/01-product/technical-clarifications.md` (2026-04-14)

## Data Model Decisions
- **Transaction:** Two-field model — `status` (pending/posted/voided) × `purpose` (user/reversal/correction/system) [TC-001]
- **Compound groups:** `compound_group_id` nullable UUID on transactions [TC-002]
- **Correction chain:** `correction_chain_id` or `corrects_transaction_id` linking original → reversal → correction [TC-024]
- **EQ per-currency:** Lazy-created per currency to preserve single-currency balance invariant [TC-045]
- **Category balances:** Home-currency aggregation via `exchange_rate_to_home` [TC-046]
- **Per-category thresholds:** Compared in home currency; per-account thresholds in native currency [TC-047]
- **All 5 entity schemas enumerated:** Transaction, Entry, Account, Category, Template — see TC-024 through TC-028

## Template & Scheduling Decisions
- **Template lifecycle:** 4-state machine: active ↔ paused → archived (natural) or deleted (user) [TC-043]
- **Installment materialization:** Occurrences materialized at creation as individual records [TC-011]
- **Installment end date:** Computed from count × recurrence, NOT user-settable [TC-010]
- **Installment transaction types:** All three supported — income, expense, transfer (including transfer-with-fee) [TC-022, FOUNDER RESOLVED]
- **Total configured:** Immutable except during early close [TC-021]
- **Recurring transfer templates support fees** [TC-052]
- **Template migration on deletion:** Same account category AND same currency required [TC-012]

## Founder Decisions (5 items, all resolved 2026-04-14)
- **TC-014:** Icon subset ~200-300 icons. Curation is separate task. SDS uses ~250 placeholder.
- **TC-022:** Installments support income, expense, transfer. Case 3.2 updated in ledger-entry.md.
- **TC-029:** Home currency change only affects default for new accounts. Account/transaction currencies are immutable. Exchange rate storage is LE-owned SDS decision. LE proposes two-field model (`exchange_rate_to_home` + `home_currency_at_capture`) with chain-conversion for display.
- **TC-031:** Bottom navigation bar, 3 tabs: Home, Accounts, Settings. LE owns navigation decisions going forward. PRD §5.7a added.
- **TC-050:** Transaction search is global (all transactions, all time). Not month-scoped. Navigation search + settings search deferred to v2.

## SDS-Owned Decisions (5 items)
- TC-003: Recurring schedule storage (materialized vs. computed)
- TC-006: Exchange rate API, scheduler, cache schema
- TC-009: Search ranking algorithm and index strategy
- TC-033: Error handling patterns for failed ledger operations
- TC-041: Scheduling mechanism (WorkManager vs. AlarmManager vs. hybrid)

## 10 Implementation Notes for SDS Author
See TC-002 (compound roles), TC-005 (draft schema version), TC-008 (pending edit path), TC-021 (early close method), TC-024 (correction chain design), TC-026 (pause_until auto-resume), TC-028 (sort_order in v1), TC-039 (persistent void notifications), TC-044 (minor units storage), TC-046 (exchange rate non-null)

**How to apply:** These decisions are locked. The SDS must be consistent with them. The 5 SDS-owned items are the first decisions to make during SDS authoring.
