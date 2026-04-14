---
name: Ledger Entry Case Analysis
status: approved
owner: pm
created: 2026-04-12
last_updated: 2026-04-14
version: 0.5.0
depends_on: [01-product/prd.md]
outputs_to: [02-technical/sds.md, 02-technical/api-contracts.md]
---

# Variance — Ledger Entry Case Analysis
## Double-Entry Bookkeeping: All Posting Cases

> **Status:** Draft for review — PM analysis, not SDS.
> **Last Updated:** 2026-04-12
> **Purpose:** Enumerate every system event that posts to the ledger, define the exact entries, and verify the DEB invariant holds. This informs §4 of the PRD and blocks SDS schema design.

---

## Notation & Conventions

| Symbol | Meaning |
|--------|---------|
| `A` | Any user-facing account (Cash, Bank, Debit Card, Wallet, Credit Card, Loan, Investment, Other) |
| `IC` | Income category (internal node) |
| `EC` | Expense category (internal node) |
| `EQ` | Internal Opening Balance equity account (invisible to user) |
| `BAI` | Protected "Balance Adjustment" income category |
| `BAE` | Protected "Balance Adjustment" expense category |
| `Dr` | Debit entry |
| `Cr` | Credit entry |
| `B` | Amount > 0 |
| `B'` | New/corrected amount > 0 |
| `ΔB = \|B' − B\|` | Magnitude of balance change (always > 0) |

**Balance conventions (from PRD §4.6):**

| Account/Category type | Balance formula | Sign meaning |
|----------------------|----------------|-------------|
| All user accounts | Σ Dr − Σ Cr | Positive = asset state; Negative = liability state |
| Income category | Σ Cr − Σ Dr | — |
| Expense category | Σ Dr − Σ Cr | — |

> **Universal formula note:** All user-facing accounts use the same formula regardless of category. There is no separate "liability formula." A credit card in normal use has a negative balance (you owe money). A loan you owe also has a negative balance. The sign conveys the economic direction — no explicit `is_liability` field exists on accounts.

**Invariant:** For every posted transaction T: `Σ Dr(T) = Σ Cr(T)`.

---

## Group 1 — Transaction Lifecycle

### Case 1.1 — Create Expense Transaction (amount B, source account A, expense category EC)

> *User records: spent B from account A on category EC.*

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | EC (expense category) | B |
| 2 | Cr | A (asset source account) | B |

**Invariant check:** Dr = B, Cr = B ✅

**Effect:**
- EC expense balance ↑ B (more spent)
- A asset balance ↓ B (money left the account)

> **Note (credit card):** If the source account is a credit card, entry 2 is still `Cr A`. With the universal formula (Σ Dr − Σ Cr), crediting the credit card decreases its balance (makes it more negative), representing more money owed. This is correct — spending on a credit card increases what you owe. ✅

---

### Case 1.2 — Create Income Transaction (amount B, destination account A, income category IC)

> *User records: received B into account A from category IC.*

**Standard T-account treatment (Q41 resolved — PRD §4.5 corrected):**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A (asset destination account) | B |
| 2 | Cr | IC (income category) | B |

**Invariant check:** Dr = B, Cr = B ✅

**Effect:**
- A asset balance ↑ B (money arrived)
- IC income balance ↑ B (income recorded)

---

### Case 1.3 — Create Transfer Transaction (amount B, source A₁, destination A₂)

> *User moves B from A₁ to A₂. No category involved.*

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A₂ (destination) | B |
| 2 | Cr | A₁ (source) | B |

**Invariant check:** Dr = B, Cr = B ✅

**Effect:**
- A₁ balance ↓ B
- A₂ balance ↑ B
- Net worth unchanged ✅

> **Credit card payment:** A₁ = bank account, A₂ = credit card.
> Entries: `Dr A₂ (credit card), Cr A₁ (bank)`. With the universal formula, Dr on the credit card increases its balance (moves toward zero, reducing the negative outstanding — less owed). ✅
>
> ✅ **Q42 Resolved:** Entry confirmed as `Dr CreditCard, Cr Bank` for a credit card payment.

---

### Case 1.3a — Create Transfer Transaction with Fee (amount B, fee F, source A₁, destination A₂, fee category FC)

> *User records: transferred B from A₁ to A₂ with a fee of F charged to A₁.*

The transfer with fee generates **two linked transactions** grouped under a shared compound transaction ID. The UI presents them as a single entry.

**Transaction 1 — Transfer (identical to Case 1.3):**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A₂ (destination) | B |
| 2 | Cr | A₁ (source) | B |

**Transaction 2 — Fee Expense:**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | FC (fee expense category, e.g. Financial > Fees & Charges) | F |
| 2 | Cr | A₁ (source — fee debited from the same source account) | F |

**Invariant check:** Each transaction individually: Dr = Cr ✅

**Effect:**
- A₁ balance ↓ (B + F) — the full amount leaves the source account (transfer + fee)
- A₂ balance ↑ B — destination receives only the transfer amount
- FC expense balance ↑ F — fee recorded as an expense

**Compound behaviour:** Editing or deleting this compound transaction affects both the transfer and the fee transactions together. The fee component is not independently editable in the transaction list — it is surfaced in the detail view only.

> **Note:** Available on all transfer types in v1. Cross-currency transfer fee support deferred to v2 (cross-currency transfers are blocked in v1).

---

### Case 1.4 — Modify Expense Transaction (B -> B', same A, same EC)

> *Financial fields changed. Posts reversing entry + corrected entry.*

**Step 1: Reversing transaction (negates Case 1.1)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | EC | B |
| R2 | Dr | A | B |

**Step 2: Corrected transaction**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| C1 | Dr | EC' | B' |
| C2 | Cr | A' | B' |

**Invariant check:** Each transaction individually: Dr = Cr ✅

> Variants: change of account (A -> A'), change of category (EC -> EC'), or both.

---

### Case 1.5 — Modify Income Transaction (B -> B', same A, same IC)

**Step 1: Reversing (negates Case 1.2)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | A | B |
| R2 | Dr | IC | B |

**Step 2: Corrected**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| C1 | Dr | A' | B' |
| C2 | Cr | IC' | B' |

**Invariant check:** Each transaction: Dr = Cr ✅

---

### Case 1.6 — Modify Transfer Transaction (B -> B', same A₁ -> A₂)

**Step 1: Reversing (negates Case 1.3)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | A₂ | B |
| R2 | Dr | A₁ | B |

**Step 2: Corrected**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| C1 | Dr | A₂' | B' |
| C2 | Cr | A₁' | B' |

**Invariant check:** Each transaction: Dr = Cr ✅

---

### Case 1.7 — Soft-Delete Expense Transaction (amount B, account A, category EC)

> *Void the transaction. Posts reversing entry only. Original retained.*

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | EC | B |
| R2 | Dr | A | B |

**Invariant check:** Dr = B, Cr = B ✅

**Effect:** EC and A revert to pre-transaction state.

---

### Case 1.8 — Soft-Delete Income Transaction (amount B, account A, category IC)

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | A | B |
| R2 | Dr | IC | B |

**Invariant check:** Dr = B, Cr = B ✅

---

### Case 1.9 — Soft-Delete Transfer Transaction (amount B, source A₁, destination A₂)

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| R1 | Cr | A₂ | B |
| R2 | Dr | A₁ | B |

**Invariant check:** Dr = B, Cr = B ✅

---

## Group 2 — Account Lifecycle

### Case 2.1 — Create Account with Zero Initial Balance

**Ledger entries:** None.

No transaction has occurred. Account balance = 0 by virtue of zero ledger activity. ✅

---

### Case 2.2 — Create Account with Non-Zero Initial Balance

**Sub-case 2.2a — Initial balance B > 0 (asset state)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A | B |
| 2 | Cr | EQ (Opening Balance equity, internal) | B |

**Effect:** A balance = +B ✅. EQ is a system account, invisible to user.

**Sub-case 2.2b — Initial balance B < 0 (liability state)** (e.g., existing credit card debt; user enters the outstanding amount as a negative value or the UI converts it)

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | EQ | \|B\| |
| 2 | Cr | A | \|B\| |

**Effect:** A balance = Σ Dr − Σ Cr = 0 − \|B\| = **−\|B\|** (negative) ✅. EQ debited.

> ✅ **Q43 Resolved:** EQ is debited when an account opens in liability state. EQ supports bidirectional postings (credited for positive-balance openings, debited for negative-balance openings). Valid under the universal formula.

---

### Case 2.3 — Edit Account Balance (B -> B') — Recorded as Transaction (Visible Journal Adjustment)

> *User says "Yes" to "Record as income/expense?"*
> *Uses protected BAI (income) or BAE (expense) category. Visible in transaction list.*

`ΔB = |B' − B| > 0`

**Sub-case 2.3a — Balance increases (moves toward +∞): recorded as income**

> *e.g., cash received, debt partially forgiven, refund credited.*

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A | ΔB |
| 2 | Cr | BAI (Balance Adjustment income) | ΔB |

**Effect:** A balance ↑ ΔB. BAI income balance ↑ ΔB. ✅

**Sub-case 2.3b — Balance decreases (moves toward −∞): recorded as expense**

> *e.g., cash spent, credit card fee charged, account balance goes more negative.*

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | BAE (Balance Adjustment expense) | ΔB |
| 2 | Cr | A | ΔB |

**Effect:** A balance ↓ ΔB. BAE expense balance ↑ ΔB. ✅

> **Universal coverage note:** The former sub-cases 2.3c (liability balance ↑ → expense) and 2.3d (liability balance ↓ → income) are subsumed by 2.3b and 2.3a respectively under the universal formula. The ledger entries are identical — only the semantic framing changed. A credit card balance moving from −5,000 to −6,000 is a balance decrease (↓ = toward −∞) → case 2.3b. A credit card balance moving from −5,000 to −3,000 (debt forgiven) is a balance increase (↑ = toward +∞) → case 2.3a.

**Invariant check:** Dr = Cr = ΔB ✅ for all sub-cases.

---

### Case 2.4 — Edit Account Balance (B -> B') — NOT Recorded as Transaction (Invisible Journal Adjustment)

> *User says "No" to the prompt. System posts an internal entry against EQ. Invisible in normal views.*

**Sub-case 2.4a — Balance increases (moves toward +∞)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | A | ΔB |
| 2 | Cr | EQ | ΔB |

**Sub-case 2.4b — Balance decreases (moves toward −∞)**

| Entry | Side | Account/Category | Amount |
|-------|------|-----------------|--------|
| 1 | Dr | EQ | ΔB |
| 2 | Cr | A | ΔB |

> **Universal coverage note:** The former sub-cases 2.4c and 2.4d (liability-specific invisible adjustments) are subsumed by 2.4b and 2.4a respectively under the universal formula. The entries are identical.

**Invariant check:** Dr = Cr = ΔB ✅ for all sub-cases.

---

### Case 2.5 — Soft-Delete Account

**Ledger entries:** None posted at time of deletion.

All prior ledger history retained. Account flagged as deleted. Excluded from net worth and all user-facing views going forward.

> ✅ **Q45 Resolved:** Two-step flow: (1) Prompt user to transfer remaining balance to another account. (2) If declined, second confirmation warns net worth will change. If confirmed, soft-delete proceeds. Balance transfer transaction type tracked in Q49.

---

## Group 3 — Additional Cases (Beyond User's Initial List)

### Case 3.1 — Recurring Transaction Auto-Post or Confirm-Post

**Ledger entries:** Identical to Cases 1.1, 1.2, or 1.3 per transaction type.

The recurring mechanism is a scheduling layer. No new ledger pattern. ✅

---

### Case 3.2 — Installment Single-Period Post

**Ledger entries:** Identical to Case 1.1 (expense) or 1.2 (income).

No new ledger pattern. ✅

---

### Case 3.3 — Cross-Currency Transfer (A₁ in C₁ -> A₂ in C₂, exchange rate R)

> *User transfers B₁ units of C₁. A₂ receives B₂ = B₁ × R units of C₂.*

| Entry | Side | Account/Category | Amount | Currency |
|-------|------|-----------------|--------|----------|
| 1 | Dr | A₂ | B₂ | C₂ |
| 2 | Cr | A₁ | B₁ | C₁ |

**Invariant challenge:** The DEB invariant `Σ Dr = Σ Cr` holds only in a single currency. Multi-currency entries break nominal balance.

> ✅ **Q46 Resolved:** Cross-currency transfers are **disallowed in v1**. The UI must prevent selecting a destination account with a different currency than the source. This case will not occur in v1. Deferred to v2.

---

### Case 3.4 — Correction of a Journal Adjustment

> *A prior journal adjustment (Case 2.3 or 2.4) is subsequently corrected by a further balance edit.*

The new balance edit computes ΔB from the *current* balance (which already includes the prior adjustment). A new reversing + corrected pair is posted. No new ledger pattern — same correction model as Cases 1.4–1.6. ✅

---

### Case 3.5 — Budget Replenishment ("Add to Budget" on Income Transaction)

**Ledger entries:** None. This is a budget-layer operation. The underlying income transaction was already posted. The budget pool balance is updated in application state, not the ledger. ✅

---

### Case 3.6 — Category Soft-Delete

**Ledger entries:** None. No transaction posted. Existing ledger entries referencing the category are retained and unaffected. The category is flagged deleted. ✅

---

## Complete Summary Table

| # | Event | Ledger Entries | New Entries Posted |
|---|-------|----------------|-------------------|
| 1.1 | Create Expense | Dr EC, Cr A | 1 txn, 2 entries |
| 1.2 | Create Income | Dr A, Cr IC | 1 txn, 2 entries |
| 1.3 | Create Transfer | Dr A₂, Cr A₁ | 1 txn, 2 entries |
| 1.3a | Create Transfer with Fee (fee F, category FC) | Transfer: Dr A₂ B, Cr A₁ B + Fee: Dr FC F, Cr A₁ F | 2 linked txns, 4 entries |
| 1.4 | Modify Expense (financial) | Reversing (Cr EC, Dr A) + Corrected (Dr EC', Cr A') | 2 txns, 4 entries |
| 1.5 | Modify Income (financial) | Reversing (Cr A, Dr IC) + Corrected (Dr A', Cr IC') | 2 txns, 4 entries |
| 1.6 | Modify Transfer (financial) | Reversing (Cr A₂, Dr A₁) + Corrected (Dr A₂', Cr A₁') | 2 txns, 4 entries |
| 1.7 | Soft-Delete Expense | Cr EC, Dr A | 1 txn, 2 entries |
| 1.8 | Soft-Delete Income | Cr A, Dr IC | 1 txn, 2 entries |
| 1.9 | Soft-Delete Transfer | Cr A₂, Dr A₁ | 1 txn, 2 entries |
| 2.1 | Create Account, balance = 0 | None | 0 |
| 2.2a | Create Account, initial balance B > 0 (asset state) | Dr A, Cr EQ | 1 txn, 2 entries |
| 2.2b | Create Account, initial balance B < 0 (liability state) | Dr EQ, Cr A → balance = −\|B\| | 1 txn, 2 entries |
| 2.3a | Edit Balance ↑ (toward +∞) → record as income | Dr A, Cr BAI | 1 txn, 2 entries |
| 2.3b | Edit Balance ↓ (toward −∞) → record as expense | Dr BAE, Cr A | 1 txn, 2 entries |
| 2.4a | Edit Balance ↑ (toward +∞) → do NOT record | Dr A, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.4b | Edit Balance ↓ (toward −∞) → do NOT record | Dr EQ, Cr A | 1 txn, 2 entries (invisible) |
| 2.5 | Soft-Delete Account | None | 0 |
| 3.1 | Recurring auto-post | Same as 1.1–1.3 (or 1.3a if fee applies) | Same as type |
| 3.2 | Installment single post | Same as 1.1 or 1.2 | Same as type |
| 3.3 | Cross-currency Transfer | **Disallowed in v1** — deferred to v2 | N/A |
| 3.4 | Correct a Journal Adjustment | Reversing + Corrected | 2 txns, 4 entries |
| 3.5 | Budget Replenishment | None (budget layer — deferred to v2) | 0 |
| 3.6 | Category Soft-Delete | None | 0 |

> **Universal formula note:** All user-facing accounts use `balance = Σ Dr − Σ Cr` regardless of account type. The former separate liability cases (2.3c/d, 2.4c/d) are subsumed by 2.3a/b and 2.4a/b — the ledger entries are identical under the universal formula. The old `L` symbol is retired; `A` denotes any user-facing account.

---

## Questions Surfaced by This Analysis — Resolution Status

| ID | Question | Status | Decision |
|----|----------|--------|----------|
| Q41 | PRD §4.5 and §4.6 conflict on income transaction entry sides. | ✅ Resolved (v0.2.0) | Corrected to `Dr A, Cr IC`. |
| Q42 | Confirm entry `Dr L, Cr A` for credit card payment. | ✅ Resolved (v0.2.1) | Confirmed. Reduces liability balance. |
| Q43 | EQ debited for liability opening balance. Confirm bidirectional postings. | ✅ Resolved (v0.2.1) | Confirmed. EQ supports debit and credit. |
| Q44 | Liability journal adjustment income/expense direction. | ✅ Resolved (v0.2.1) | Balance ↑ = expense (2.3c/2.4c). Balance ↓ = income (2.3d/2.4d). Cases added. |
| Q45 | Soft-delete account with non-zero balance: prompt to transfer? | ✅ Resolved (v0.2.1) | Two-step flow with transfer prompt and net-worth warning. Q49 tracks transfer type. |
| Q46 | Cross-currency transfers ledger handling. | ✅ Resolved (v0.2.1) | Disallowed in v1. Deferred to v2. |
