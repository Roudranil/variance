---
name: Variance — Double-Entry Bookkeeping Model
description: Core financial model: universal balance formula, entry sides, immutability rules, EQ per-currency, correction model — all Q41-Q46 resolved
type: project
---
## Core Invariant
For every transaction T: Σ debit(T) = Σ credit(T)

## Universal Balance Formula (§4.6 — Q41 RESOLVED)
**All user accounts use ONE formula:** balance = Σ debit − Σ credit
- Positive = asset state (you hold this value)
- Negative = liability state (you owe this value)
- No explicit asset/liability designation. Sign infers nature.

**Categories:**
- Income: balance = Σ credit − Σ debit
- Expense: balance = Σ debit − Σ credit

## Transaction Rules by Type (§4.5 — CORRECTED)
- **Expense:** Dr EC (category), Cr A (account) — expense balance ↑, account balance ↓
- **Income:** Dr A (account), Cr IC (category) — account balance ↑, income balance ↑
- **Transfer:** Dr A₂ (destination), Cr A₁ (source) — no category involved

## Transaction Two-Field Model (TC-001)
Transactions carry two orthogonal fields:
- **status:** pending / posted / voided
- **purpose:** user / reversal / correction / system

Balance computation: all `status = posted` regardless of `purpose`.
Default list display: `status = posted AND purpose IN (user, correction, system)`.

## Entry Structure
Each ledger entry: transaction_id, account_id OR category_id (mutually exclusive), amount > 0, side ∈ {debit, credit}, id (UUID), created_at (UTC).

## Immutability & Correction
- Posted transactions are permanently immutable
- Financial field edits (amount, account, category): reversing + corrected transaction pair
- In-place edits (no ledger posting): title, description, photos, date/time
- Soft delete: reversing entry posted; original retained as `voided`
- No entity ever permanently deleted

## Special Accounts
- **EQ (Opening Balance Equity):** Per-currency with lazy creation (TC-045). EQ_USD, EQ_INR, etc. Created on demand. All invisible, excluded from net worth. Supports bidirectional postings.
- **BAI/BAE (Balance Adjustment):** Protected system categories. Currency-agnostic — balances computed in home currency via exchange rate conversion (TC-046).

## Multi-Currency Category Balances (TC-046)
Categories aggregate entries across currencies. Category balance formula: Σ (entry_amount × exchange_rate_to_home). Every transaction must have a non-null `exchange_rate_to_home` (1.0 for home currency).

## Compound Transactions (TC-002)
Transfer-with-fee uses `compound_group_id` (nullable UUID) on each transaction. Edit/delete affects all members atomically. V2 split transactions extend to N > 2.

**How to apply:** All SDS schema design and ledger engine code must be consistent with these rules. The universal balance formula eliminates separate asset/liability logic. EQ per-currency preserves single-currency balance invariant.
