---
name: Product Requirements Document
status: in progress
owner: pm
created: 2026-04-13
last_updated: 2026-04-14
depends_on: []
outputs_to: [02-technical/sds.md, 02-technical/ux-flows.md, 02-technical/api-contracts.md, 03-planning/task-breakdown.md]
---

- [Product Requirements Document (PRD)](#product-requirements-document-prd)
  - [Variance — Personal Finance \& Expense Tracker](#variance--personal-finance--expense-tracker)
  - [1. Problem Statement](#1-problem-statement)
  - [2. Goals](#2-goals)
    - [Primary Goals](#primary-goals)
    - [Version Roadmap](#version-roadmap)
    - [Anti-Goals (Permanent — Never)](#anti-goals-permanent--never)
  - [3. Use Cases](#3-use-cases)
    - [UC-1: Manage Accounts and Account Categories](#uc-1-manage-accounts-and-account-categories)
    - [UC-2: Manage Transactions and Transaction Categories](#uc-2-manage-transactions-and-transaction-categories)
    - [UC-3: View and Manage Budgets *(Deferred to v2)*](#uc-3-view-and-manage-budgets-deferred-to-v2)
  - [4. Core Model: Double-Entry Bookkeeping](#4-core-model-double-entry-bookkeeping)
    - [4.1 Core Invariant](#41-core-invariant)
    - [4.2 Accounting Equation](#42-accounting-equation)
    - [4.3 Data Model](#43-data-model)
    - [4.4 Constraints](#44-constraints)
    - [4.5 Transaction Rules by Type](#45-transaction-rules-by-type)
    - [4.6 Balance Calculation](#46-balance-calculation)
    - [4.7 Transaction Validity](#47-transaction-validity)
    - [4.8 Immutability \& Correction Model](#48-immutability--correction-model)
    - [4.9 Initial Balance \& Equity Account](#49-initial-balance--equity-account)
    - [4.10 Journal Adjustments](#410-journal-adjustments)
    - [4.11 Ledger Posting Cases (Reference)](#411-ledger-posting-cases-reference)
  - [5. Functional Requirements (Feature Graph)](#5-functional-requirements-feature-graph)
    - [5.1 Account Management (CORE) — UC-1](#51-account-management-core--uc-1)
      - [5.1.1 Account CRUD](#511-account-crud)
        - [Create Account — Fields](#create-account--fields)
      - [5.1.2 Account Categories (Fixed Set — No Custom Categories)](#512-account-categories-fixed-set--no-custom-categories)
      - [5.1.3 Account Balance Model](#513-account-balance-model)
      - [5.1.3a Balance Reconciliation (FG-C6)](#513a-balance-reconciliation-fg-c6)
      - [5.1.4 Account Balance View](#514-account-balance-view)
      - [5.1.5 Internal Transfer](#515-internal-transfer)
      - [5.1.5b Transfer Fee (Optional)](#515b-transfer-fee-optional)
      - [5.1.6 Credit Card Balance Model](#516-credit-card-balance-model)
      - [5.1.7 Credit Card Payment Reminders](#517-credit-card-payment-reminders)
    - [5.2 Transaction Management (CORE) — UC-2](#52-transaction-management-core--uc-2)
      - [5.2.1 Transaction Entry](#521-transaction-entry)
      - [5.2.2 Transaction Immutability \& Editing](#522-transaction-immutability--editing)
      - [5.2.3 Photo Attachments](#523-photo-attachments)
      - [5.2.4 Transaction Categories (Two-Level Hierarchy)](#524-transaction-categories-two-level-hierarchy)
        - [Default Expense Categories](#default-expense-categories)
        - [Default Income Categories](#default-income-categories)
      - [5.2.5 Transaction Search](#525-transaction-search)
      - [5.2.6 Transaction Filtering](#526-transaction-filtering)
      - [5.2.7 Recurring Transactions](#527-recurring-transactions)
      - [5.2.8 Installments](#528-installments)
    - [5.3 Budgeting *(Deferred to v2)*](#53-budgeting-deferred-to-v2)
      - [5.3.1 Budget Model](#531-budget-model)
      - [5.3.2 Income Replenishment](#532-income-replenishment)
      - [5.3.3 Budget vs. Actual](#533-budget-vs-actual)
      - [5.3.4 Budget Alerts](#534-budget-alerts)
      - [5.3.5 Budget Rollover](#535-budget-rollover)
    - [5.4 Settings \& Customisation (CORE)](#54-settings--customisation-core)
      - [5.4.1 Appearance](#541-appearance)
      - [5.4.2 Locale \& Format](#542-locale--format)
      - [5.4.3 Transaction Entry](#543-transaction-entry)
      - [5.4.4 Warnings \& Limits](#544-warnings--limits)
      - [5.4.5 Profile](#545-profile)
      - [5.4.6 Security](#546-security)
      - [5.4.7 Accounts](#547-accounts)
      - [5.4.8 Transaction Categories](#548-transaction-categories)
      - [5.4.9 Recurring \& Installments](#549-recurring--installments)
      - [5.4.10 Data](#5410-data)
      - [5.4.11 Accessibility](#5411-accessibility)
      - [5.4.12 About \& Legal](#5412-about--legal)
    - [5.5 Contextual Action Menus](#55-contextual-action-menus)
      - [5.5.1 Confirmed Contextual Menu Actions](#551-confirmed-contextual-menu-actions)
      - [5.5.2 Deferred Contextual Menu Cases (v2)](#552-deferred-contextual-menu-cases-v2)
    - [5.6 Onboarding \& First Launch](#56-onboarding--first-launch)
      - [5.6.1 Default Category Seeding](#561-default-category-seeding)
      - [5.6.2 Onboarding Wizard](#562-onboarding-wizard)
    - [5.7 Timezone \& Date Policy](#57-timezone--date-policy)
    - [5.8 Home Screen \& Dashboard](#58-home-screen--dashboard)
      - [5.8.1 Greeting](#581-greeting)
      - [5.8.2 Financial Summary](#582-financial-summary)
      - [5.8.3 Month Selector](#583-month-selector)
      - [5.8.4 Transaction List](#584-transaction-list)
      - [5.8.5 Alerts](#585-alerts)
      - [5.8.6 Quick Entry](#586-quick-entry)
  - [6. Non-Functional Requirements](#6-non-functional-requirements)
  - [7. Multi-Currency Model (v1)](#7-multi-currency-model-v1)
    - [7.1 Transaction-Level Exchange Rate Capture](#71-transaction-level-exchange-rate-capture)
  - [8. In-Scope vs. Out-of-Scope](#8-in-scope-vs-out-of-scope)
    - [✅ In Scope — v1](#-in-scope--v1)
    - [🔄 Deferred — v2](#-deferred--v2)
    - [🔄 Deferred — v3 (or later)](#-deferred--v3-or-later)
    - [❌ Permanently Out of Scope](#-permanently-out-of-scope)
  - [9. Success and Failure Criteria](#9-success-and-failure-criteria)
    - [Success Criteria](#success-criteria)
    - [Failure Criteria](#failure-criteria)
  - [10. Assumptions and Constraints](#10-assumptions-and-constraints)
    - [Assumptions](#assumptions)
    - [Constraints](#constraints)
  - [11. Open Questions](#11-open-questions)


# Product Requirements Document (PRD)
## Variance — Personal Finance & Expense Tracker

## 1. Problem Statement

Existing personal finance apps on Android fall into one of two camps:

- **Local + Modern UI** (e.g., Cashew): Fully offline, beautiful Material 3 design, but no double-entry bookkeeping. The financial model cannot guarantee ledger integrity.
- **Local + Double-Entry** (e.g., Money Manager): Offline with double-entry bookkeeping, but the UI is dated and complex.

**No Android app combines all three: local storage, double-entry bookkeeping, and a modern Material 3 design.** Variance fills this gap — a fully local, open-source Android app that uses double-entry bookkeeping as its financial backbone, presented through a clean income / expense / transfer interface accessible to any user, with no accounting background required.

---

## 2. Goals

### Primary Goals

- G1: Apply double-entry bookkeeping internally. Every transaction affects exactly two accounts, ensuring the ledger always balances.
- G2: Abstract the double-entry model entirely behind an income / expense / transfer UI. The user never encounters "debit" or "credit" language.
- G3: Allow users to create, manage, search, and filter accounts, transactions, and their categories with full CRUD support.
- G4: Support flexible budgeting across multiple time horizons with alerts, configurable rollover, and income replenishment.
- G5: Be 100% open-source (MIT), free, and fully functional offline.
- G6: Deliver a premium Material You (Material Design 3) Android experience.

### Version Roadmap

| Version | Scope |
|---------|-------|
| **v1** | Core: accounts, transactions, categories, recurring transactions, installments, onboarding, settings, home screen dashboard (greeting, net worth, monthly summary, alerts, search/filter) |
| **v2** | Advanced: budgeting (total + per-category, multi-horizon, rollover, alerts, income replenishment), trends, dashboards, analytics, data management (backup/restore, CSV), savings goals, tags, audit view, account & category reordering |
| **v3** | Predictive: ML insights, OCR receipt capture, advanced analytics, exchange rate updates (online-optional), Drive backup |

### Anti-Goals (Permanent — Never)

- No cloud sync or multi-device access.
- No bank API or Open Banking integration.
- No ads, telemetry, crash reporting, or any form of analytics.
- No cryptocurrency tracking.
- No multi-user or household mode.

---

## 3. Use Cases

### UC-1: Manage Accounts and Account Categories

The user can create, view, edit, and soft-delete **accounts** across a fixed set of **account categories**. Each account category has specific additional fields. The user controls whether each account is included in the net worth calculation. Account balances are always computed from the ledger — never stored directly.

### UC-2: Manage Transactions and Transaction Categories

The user records transactions as income, expense, or transfer. All transactions are immutable — edits to financial fields post correcting entries. The user manages a two-level taxonomy of transaction categories (category -> subcategory) separately for income and expense. All deletions are soft deletes.

### UC-3: View and Manage Budgets *(Deferred to v2)*

> **Deferred:** Budgeting has been moved to v2 to allow a ground-up rethink of how budgets interact with savings goals (also v2). The full budget model — total + per-category budgets, multi-horizon, rollover, alerts, income replenishment — will be designed holistically alongside savings goals in v2.

~~The user defines a total budget and per-category budgets across multiple time horizons. Budget pools track remaining amounts in real time. Income transactions can manually replenish a budget pool. In-app alerts fire at configurable thresholds.~~

---

## 4. Core Model: Double-Entry Bookkeeping

> This section defines the financial model. It informs the SDS. The UI never exposes this model directly.

### 4.1 Core Invariant

For every transaction $T$:

$$\sum \text{debit}(T) = \sum \text{credit}(T)$$

### 4.2 Accounting Equation

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

$$\text{Assets} = \text{Liabilities} + \text{Equity} + \text{Income} - \text{Expenses}$$

> **Variance-specific note:** The internal Opening Balance equity account (EQ, §4.9) carries a non-zero balance whenever accounts have initial balances. EQ is excluded from all user-facing computation — the practical formula used throughout the app is `Net Worth = Σ account balances` (§4.9). The accounting equation above is stated for formal DEB completeness; it is never evaluated directly by the app.

### 4.3 Data Model

**Transaction:**
- `id`
- `type` ∈ { income, expense, transfer }

**Entry (ledger line):**
- `transaction_id`
- `account_id` OR `category_id` (mutually exclusive — exactly one must be set)
- `amount` > 0
- `side` ∈ { debit, credit }

### 4.4 Constraints

**Balance constraint:**
$$\sum \text{debit}(T) = \sum \text{credit}(T)$$

**Exclusivity:** Exactly one of `account_id` or `category_id` must be set per entry.

**Minimum entries:** $|\text{entries}(T)| \geq 2$

### 4.5 Transaction Rules by Type

**Expense:**
- At least one expense category entry (**debit side** — expense category balance increases)
- At least one account entry (**credit side** — the source of funds; account balance decreases)

**Income:**
- At least one account entry (debit side, where funds land)
- At least one income category entry (credit side)

**Transfer:**
- Only account entries (no category entries)
- Source account is credited; destination account is debited

### 4.6 Balance Calculation

**Universal Balance Formula — all account types:**

$$\text{balance} = \sum \text{debit} - \sum \text{credit}$$

This formula applies to every user-facing account regardless of category. The sign of the balance conveys the account's economic state:

- **Positive balance** → account is in an **asset state**: you hold this value or it is owed to you.
- **Negative balance** → account is in a **liability state**: you owe this value.
- **Zero balance** → account is settled or empty.

There is no explicit asset/liability designation field on any account. The direction is inferred entirely from the balance sign at any point in time. The UI never exposes raw signs — balance direction is communicated through **colour and labelling** (see §5.1.4).

**Examples of sign-based inference:**
- Bank account balance +₹10,000 → asset state (you hold ₹10,000).
- Credit card balance −₹5,000 → liability state (you owe ₹5,000).
- Loan account balance +₹50,000 → asset state (someone owes you ₹50,000).
- Loan account balance −₹1,50,000 → liability state (you owe ₹1,50,000).

**Income/Expense category accounts** (internal, not user-visible):
- Income category: $\text{balance} = \sum \text{credit} - \sum \text{debit}$
- Expense category: $\text{balance} = \sum \text{debit} - \sum \text{credit}$

### 4.7 Transaction Validity

A transaction is valid if and only if:
- It is balanced ($\sum \text{debit} = \sum \text{credit}$)
- All amounts > 0
- Exclusivity constraint holds for every entry
- Type rules are satisfied

### 4.8 Immutability & Correction Model

- All posted transactions are **permanently immutable**.
- Correcting a transaction's financial fields — including **amount, account, and category** — posts a **new reversing transaction** (negates the original) followed by a **new corrected transaction**. This is consistent with Cases 1.4 and 1.5 in `docs/01-product/ledger-entry.md`, where the corrected entry already uses EC' and IC' to represent a changed category.
- **In-place edits are limited to: title, description, and photos only.** These fields carry no ledger significance.
- **Soft delete** of a transaction posts an automatic reversing entry to neutralise it. The original transaction record is retained.
- No entity (transaction, account, category) is ever permanently deleted.

### 4.9 Initial Balance & Equity Account

When an account is created with an initial balance, the system implicitly posts a transaction against an internal **Opening Balance equity account** (EQ). This equity account is **never visible to the user under any circumstances** — it does not appear in any user-facing views, account lists, or reports.

**EQ posting direction by initial balance sign:**
- Initial balance B > 0 (asset state): `Dr A, Cr EQ` → account balance = +B.
- Initial balance B < 0 (liability state): `Dr EQ, Cr A` → account balance = −|B|.
- Initial balance B = 0: No posting (see case 2.1 in §4.11).

EQ supports bidirectional postings and is valid for any account type.

**EQ and net worth:**

EQ is a technical balancing account used solely to satisfy the DEB invariant for opening-balance entries. Its balance is exactly the algebraic negative of the net sum of all opening balance postings. If EQ were included in net worth, it would offset every opening balance, causing net worth to understate (or overstate) the user's actual financial position.

**EQ must therefore be excluded from net worth.**

The correct net worth formula is:

$$\text{Net Worth} = \sum_{\text{included accounts}} \text{balance}_i = \sum_{\text{included accounts}} \left(\sum \text{debit}_i - \sum \text{credit}_i\right)$$

EQ exists solely to balance opening-balance transactions. It has no economic meaning in a personal finance context and is never surfaced to the user.

### 4.10 Journal Adjustments

When a user directly edits an account's balance, the system posts a **journal adjustment transaction**. The user is prompted: *"Record this balance change as income/expense?"*

- If **Yes**: The adjustment is categorised under the protected **"Balance Adjustment"** system category and is visible in the transaction list.
- If **No**: The adjustment is an invisible internal entry retained for ledger integrity. It is not visible in normal views but surfaces in the v2 audit view.

**Income/expense direction for balance adjustments (universal — all account types):**

Since all accounts use the same formula (§4.6), the direction of the income/expense classification follows the change in balance value:
- Balance **increases** (moves toward +∞, e.g., debt forgiven, refund credited, cash received): classified as **income** (`Dr A, Cr BAI`).
- Balance **decreases** (moves toward −∞, e.g., fee charged, overdraft, spending recorded): classified as **expense** (`Dr BAE, Cr A`).

This applies uniformly whether the account is currently in asset state or liability state. For example: a credit card balance moving from −₹5,000 to −₹6,000 is a balance decrease → expense. A credit card balance moving from −₹5,000 to −₹3,000 (partial forgiveness or correction) is a balance increase → income.

### 4.11 Ledger Posting Cases (Reference)

All system events that produce ledger entries are fully enumerated in `docs/01-product/ledger-entry.md`, which is the authoritative posting case reference for SDS design. The compact summary is reproduced here.

**Notation:** A = any user-facing account (all types use the universal balance formula, §4.6) · IC = income category · EC = expense category · EQ = internal equity account · BAI/BAE = Balance Adjustment income/expense category · FC = fee expense category.

| # | Event | Ledger Entries | Entries Posted |
|---|-------|----------------|----------------|
| 1.1 | Create Expense | Dr EC, Cr A | 1 txn, 2 entries |
| 1.2 | Create Income | Dr A, Cr IC | 1 txn, 2 entries |
| 1.3 | Create Transfer | Dr A₂, Cr A₁ | 1 txn, 2 entries |
| 1.3a | Create Transfer with Fee (fee F, category FC) | Transfer: Dr A₂ B, Cr A₁ B + Fee: Dr FC F, Cr A₁ F | 2 linked txns, 4 entries |
| 1.4 | Modify Expense (financial) | Reversing (Cr EC, Dr A) + Corrected (Dr EC', Cr A') | 2 txns, 4 entries |
| 1.5 | Modify Income (financial) | Reversing (Cr A, Dr IC) + Corrected (Dr A', Cr IC') | 2 txns, 4 entries |
| 1.6 | Modify Transfer (financial) | Reversing (Cr A₂, Dr A₁) + Corrected (Dr A₂', Cr A₁') | 2 txns, 4 entries |
| 1.6a | Modify Transfer with Fee (financial) | Reverse both (transfer + fee) + Correct both | 4 txns, 8 entries |
| 1.7 | Soft-Delete Expense | Cr EC, Dr A | 1 txn, 2 entries |
| 1.8 | Soft-Delete Income | Cr A, Dr IC | 1 txn, 2 entries |
| 1.9 | Soft-Delete Transfer | Cr A₂, Dr A₁ | 1 txn, 2 entries |
| 1.9a | Soft-Delete Transfer with Fee | Reverse both (transfer + fee) | 2 linked txns, 4 entries |
| 2.1 | Create Account, balance = 0 | None | 0 |
| 2.2a | Create Account, initial balance B > 0 | Dr A, Cr EQ | 1 txn, 2 entries |
| 2.2b | Create Account, initial balance B < 0 | Dr EQ, Cr A | 1 txn, 2 entries |
| 2.3a | Edit Balance ↑ (toward +∞) → record as income | Dr A, Cr BAI | 1 txn, 2 entries |
| 2.3b | Edit Balance ↓ (toward −∞) → record as expense | Dr BAE, Cr A | 1 txn, 2 entries |
| 2.4a | Edit Balance ↑ → do NOT record | Dr A, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.4b | Edit Balance ↓ → do NOT record | Dr EQ, Cr A | 1 txn, 2 entries (invisible) |
| 2.5 | Soft-Delete Account | None | 0 |
| 2.5a | Account Deletion Balance Transfer | Dr A₂ B₁, Cr A₁ B₁ (positive) or Dr A₁ \|B₁\|, Cr A₂ \|B₁\| (negative) | 1 txn, 2 entries (system-generated) |
| 3.1 | Recurring auto-post | Same as 1.1–1.3 (or 1.3a if fee applies) | Same as type |
| 3.2 | Installment single post | Same as 1.1 or 1.2 | Same as type |
| 3.3 | Cross-currency Transfer | Disallowed in v1 — deferred to v2 | N/A |
| 3.4 | Correct a Journal Adjustment | Reversing + Corrected | 2 txns, 4 entries |
| 3.5 | Budget Replenishment | None (budget layer) | 0 |
| 3.6 | Category Soft-Delete | None | 0 |
| 3.7 | Batch Category Migration | Per txn: Reversing + Corrected (same as 1.4/1.5 with category changed) | 2N txns, 4N entries |

> All accounts use the universal balance formula (§4.6). The former separate liability cases (2.3c/d, 2.4c/d) are subsumed by 2.3a/b and 2.4a/b under the universal formula — the ledger entries are identical; only the interpretation of "balance ↑ vs ↓" changes. Cross-currency transfers are disallowed in v1. Full enumeration of all posting cases is in `docs/01-product/ledger-entry.md`, which is the authoritative reference for SDS schema design.

---

## 5. Functional Requirements (Feature Graph)

> Only **v1** features are defined here.
> Organized as: **PILLAR -> FEATURE -> SUB-FEATURE**

---

### 5.1 Account Management (CORE) — UC-1

#### 5.1.1 Account CRUD

##### Create Account — Fields

The Create Account form collects the following fields. Category-specific fields (see §5.1.2) are additionally displayed once the account category is selected.

| Field | Required | Default | Notes |
|-------|----------|---------|-------|
| Name | Yes | — | Must be unique across all accounts (see uniqueness constraint below). Free-form text. |
| Account category | Yes | — | Selected from the fixed set in §5.1.2. Determines which category-specific fields are shown. |
| Initial balance | Yes | 0 | Numeric amount. If > 0, an opening-balance ledger transaction is posted (see §4.9). |
| Currency | Yes | Home currency | Selected from the bundled ISO 4217 list (see §5.4.2). **Immutable after creation** — cannot be changed once the account is saved (see currency immutability below). |
| Include in net worth | Yes (boolean) | true | Controls whether this account's balance contributes to the net worth total (see §5.1.4). |
| Notes | No | — | Optional free-form text. Retained on accounts even though notes has been removed from transactions. |
| Category-specific fields | Varies | — | Additional fields per the selected account category (see §5.1.2). |

**Currency Immutability**

Account currency is permanently fixed at the time of creation. To ensure an informed choice:
1. The currency field defaults to the **home currency** (§5.4.2). An info tooltip accompanies the field: *"Account currency cannot be changed after creation. Select carefully."*
2. If the user changes the currency away from the default, a **visual change indicator** (e.g., a highlighted field border or inline confirmation label) is shown to confirm the selection has been intentionally changed.
3. Before the account is saved, a **confirmation dialog** is presented: *"Your account will be created in [Currency]. This cannot be changed later. Continue?"*

---

**Account Name Uniqueness Constraint**

Account names must be unique across all accounts, **including soft-deleted accounts**. A soft-deleted account's name is permanently reserved and cannot be reused by a new account.

**Reinstatement of soft-deleted accounts:** When a user attempts to create a new account whose name and account category both match a soft-deleted account, the app displays a warning: *"It looks like you previously had an account with this name. Would you like to reinstate it instead?"* If the user accepts, the soft-deleted account is reinstated (its `is_deleted` flag is cleared). This is architecturally trivial: since balances are always computed from ledger entries (which are never deleted), the reinstated account's balance, transaction history, and net worth contribution are automatically correct with no recalculation. If the user declines, they must choose a different name.

The same reinstatement logic applies to soft-deleted categories (see §5.2.4).

**Edit**

Editable fields: name, notes, include-in-net-worth flag, and all category-specific fields. Account category itself is not editable after creation.

**Edit balance**: Posts a journal adjustment transaction (see §4.10 and §5.1.3).

**Delete**: Soft delete only. Ledger entries are retained. A soft-deleted account's balance is excluded from net worth. Hard delete and transaction migration to another account are deferred to a future version.

**Soft-deleted account behaviour (FG-B9):**
- A soft-deleted account is **frozen**: no new transactions can be posted against it, and no existing transactions can be edited to reference it (the account is excluded from the account picker in transaction edit forms).
- The account is **hidden from the account list** on the home screen and the account picker in new transaction forms.
- The account **remains visible** in Settings > Accounts (with reinstatement option, per §5.1.1) and is shown grayed-out in the net worth view (per §5.1.4) if it was previously included.
- **Historical transactions** that reference the soft-deleted account retain the account name and remain fully visible in all transaction views. The account name is displayed as-is — no "(deleted)" suffix is shown.
- **Search (§5.2.5):** Transactions from soft-deleted accounts appear in search results. The deleted account's name is a searchable field.
- **Filter (§5.2.6):** Soft-deleted accounts are included in the account filter picker, so users can filter to see historical transactions from a deleted account. This mirrors the treatment of soft-deleted categories in filter dropdowns.
- **This does not extend to soft-deleted transactions.** Voided transactions are excluded from the default list and search results. The existing "Is voided" boolean filter (§5.2.6) is the only way to surface them.
  - If the account has a non-zero balance at deletion time, the app presents a two-step flow:
    1. "Would you like to transfer the remaining balance to another account?" — if yes, the user selects a destination account and a **system-generated internal transfer** is posted. This transfer is visible in the transaction list but is marked as system-generated and is not user-editable. If the user later attempts to soft-delete this system transfer, the app warns: *"This transfer was created when you deleted [account name]. Voiding it will reduce your net worth because the source account is no longer active."*
    2. If the user declines: "Deleting this account without transferring the balance will change your net worth. Are you sure?" — if confirmed, the soft-delete proceeds.
- Cannot delete the last remaining account. When exactly one account exists, the **delete action is disabled** (greyed out and non-interactive) on that account, with a tooltip: *"You cannot delete your only account."* This applies regardless of whether the last account has a zero or non-zero balance.
- **No same-currency account for balance transfer:** When the user initiates deletion of an account with a non-zero balance and no other account in the same currency exists, the balance transfer offer is **skipped entirely**. The app goes directly to the net worth warning: *"No same-currency account is available to receive this balance. Deleting this account will change your net worth. Are you sure?"* If confirmed, the soft-delete proceeds without posting a transfer.

**Recurring and installment template handling on account deletion:**

Before soft-deleting an account, the app checks whether any recurring or installment template with **future-scheduled occurrences** references that account. If such templates exist, a blocking warning is shown before the normal balance-transfer / net-worth-change flow:

> *"[N] recurring/installment template(s) are scheduled to use this account. What would you like to do?"*

The user must choose one of:
- **Migrate templates** — select a replacement account; all future-scheduled occurrences of the affected templates switch to the replacement account. This is treated as a template edit (account field change) effective from the next unposted occurrence.
- **Stop templates** — all affected templates are immediately archived; future-scheduled occurrences are cancelled.

The **default pre-selected option is Stop templates**. Deletion does not proceed until the user confirms a choice. Templates with no future-scheduled occurrences are unaffected — their historical child transactions are retained.

---

#### 5.1.2 Account Categories (Fixed Set — No Custom Categories)

Account categories are a fixed, predefined set. Users cannot create, rename, or delete account categories.

| Category | Required Fields | Optional Fields |
|----------|----------------|-----------------|
| **Cash** | *(none)* | *(none)* |
| **Bank Account** | Bank name | Account number (masked display), branch, IFSC |
| **Credit Card** | Billing date, payment due date | Card name, card number (encrypted; masked display), expiry date, credit limit, linked bank account |
| **Debit Card** | *(none)* | Card name, card number (encrypted; masked display), expiry date, linked bank account (metadata only) |
| **Top-Up Wallet** | *(none)* | Wallet provider name, linked phone number |
| **Loan** | *(none)* | Lender/borrower name, principal amount, interest rate, EMI amount, EMI date, due date |
| **Investment** | Investment type (FD, Mutual Fund, Stocks, PPF, NPS, Other) | Institution name, current value (manually entered — see §5.1.3 for balance model) |
| **Other** | *(none)* | *(none — generic miscellaneous account)* |

> **Field editability:** All category-specific fields (both required and optional) are in-place editable after account creation. The complete field inventory with types, defaults, and editability rules is in `docs/01-product/input-fields.md`.

**Field encryption:** Sensitive account fields — card numbers (Credit Card, Debit Card) and bank account numbers (Bank Account) — are **encrypted at rest** on the device. Authentication is required to reveal the unmasked value in the UI (§5.4.6 sensitive field reveal). **CVV is never stored in any form in any version of the app.**

**Loan account direction:** The loan direction (asset vs. liability) is not a stored field. The balance sign conveys direction: a positive loan balance means the loan is owed **to you** (asset state); a negative balance means **you owe** (liability state). Set the initial balance to a positive value if you lent money out; set it to a negative value if you borrowed. See §4.6.

**Linked bank account — behaviour by account category:**
- *Debit Card*: Metadata only. Linking a bank account has no functional effect on either account. Deleting either does not affect the other.
- *Credit Card*: Triggers automatic payment reminders and pre-fills the payment source in the payment entry form. See §5.1.7.

**Loan account — installment setup suggestion:** When saving a loan account, if either condition is met — (1) the initial balance is negative (liability state), or (2) EMI amount / EMI date fields are provided — the app displays a post-save contextual suggestion: *"Would you like to set up a recurring installment payment for this loan?"* If the user accepts, the recurring installment template creation form opens with the following fields pre-filled where available:

| Field | Pre-filled value |
|-------|-----------------|
| Destination account | This loan account (fixed) |
| Amount | EMI amount (if provided) |
| Recurrence | Monthly on EMI date (if provided) |
| Start date | Today |
| Source account | Blank — user selects |

The user may modify any field before saving the template. Dismissing the suggestion has no effect on the loan account. This is a convenience nudge only — the loan and installment template are not hard-linked after creation.

---

#### 5.1.3 Account Balance Model

This model applies to **all account types** — there is no functional difference between an Investment account and any other account type. The Investment category is distinct only in its name and its category-specific metadata fields (investment type, institution name, current value). All balance change mechanics described here are universal.

An account's balance changes in exactly three ways:

1. **Direct balance edit** (via edit account menu): System prompts — *"Record this change as a real transaction?"*
   - If Yes -> posts a proper income/expense transaction with the protected **"Balance Adjustment"** category. Visible in transaction list. See §4.10 and Cases 2.3a–2.3b in `docs/01-product/ledger-entry.md` for the posting logic by balance direction (balance ↑ = income, balance ↓ = expense). This applies uniformly to all account types.
   - If No -> posts an invisible journal adjustment against the internal equity account (EQ). Not visible in normal views. Surfaces in the v2 audit view. See Cases 2.4a–2.4b in `docs/01-product/ledger-entry.md`.
2. **Recorded transaction against this account**: A normal income/expense/transfer entry referencing this account. Displayed in the transaction list.
3. **Deletion (soft-delete) of an existing transaction**: Posts an invisible reversing entry to neutralise the original transaction's effect on the account balance. The reversal is not displayed in normal transaction views.

#### 5.1.3a Balance Reconciliation (FG-C6)

A **Reconcile** action is available on every account (not just cash). It provides a streamlined flow for correcting balance drift — when the user's actual balance (e.g., from their bank app or physical cash count) diverges from the computed ledger balance.

**Reconciliation flow:**

1. The app displays the current **computed balance** (from the ledger).
2. The user enters the **actual balance** (the real-world figure they have verified).
3. The app computes the **discrepancy**: `actual − computed`.
4. If the discrepancy is zero, the app shows "Balance is already correct" and exits.
5. If non-zero, the standard journal adjustment prompt (§4.10) fires: *"Record this balance change as income/expense?"*
   - If **Yes**: A visible Balance Adjustment transaction is posted (Cases 2.3a/2.3b in `docs/01-product/ledger-entry.md`).
   - If **No**: An invisible journal entry against EQ is posted (Cases 2.4a/2.4b).

This is functionally identical to a direct balance edit (§5.1.3) but optimized for the reconciliation use case — the user enters the target balance rather than computing the difference manually.

**Access:** The Reconcile action is available from the account contextual menu (§5.5.1) and from the account detail screen.

#### 5.1.4 Account Balance View

- Real-time computed balance per account (derived from ledger).
- Net worth view: sum of all balances for accounts where "include in net worth" is true and the account is not soft-deleted. **Accounts flagged as excluded from net worth are shown grayed-out inline** within the account list on the net worth screen, below the accounts that contribute to the total. They carry a visual "excluded" indicator and their balances are not included in the net worth figure.
- Balances respect the locale, number format, and currency settings.

**Negative balance visual treatment:**
When an account balance is negative (liability state per §4.6), it is displayed using a **distinct warning colour** (exact Material You colour token deferred to UX Flows). No minus sign or "−" prefix is shown in the primary balance display — colour alone signals the liability state. Accessibility labelling (for screen readers) must convey the liability state; exact semantics deferred to UX Flows.

**Overdraft warning:**
When recording a transaction that would push an account balance below zero, or deepen an existing negative balance, a **non-blocking inline warning** is shown at the point of entry: *"This transaction will result in a negative balance of [amount] for [Account Name]."* The user may dismiss and proceed — there is no hard block.

**Credit card limit warning (FG-C18):**
When recording an expense or transfer against a credit card account, if the transaction would cause the outstanding balance to exceed the configured **credit limit** (§5.1.2), a **non-blocking inline warning** is shown: *"This transaction will exceed the credit limit of [limit] for [Card Name]. Outstanding will be [projected amount]."* The user may dismiss and proceed — there is no hard block. This warning is only shown when a credit limit is configured on the account.

#### 5.1.5 Internal Transfer

- A Transfer transaction atomically debits the destination account and credits the source account.
- Both entries post together or neither does.
- Transfers carry no transaction category.
- **Credit card payment**: When transferring to a credit card account (paying the outstanding balance), the posting is `Dr CreditCard, Cr SourceAccount`. With the universal asset formula (§4.6), debiting the credit card account increases its balance (moves it toward zero, reducing the amount owed). This is consistent with the standard DEB transfer treatment for all accounts.

#### 5.1.5b Transfer Fee (Optional)

When recording a transfer transaction, the user may optionally specify a fee charged by the bank, card network, or payment service.

- A **fees panel** is exposed alongside the account and amount entry fields on the transfer entry form. The panel is **collapsed by default** (no fee).
- The fee may be entered as a **flat amount** (in the source account's currency) or as a **percentage** of the transfer amount. These are mutually exclusive — the user picks one mode.
- **Fee posting:** When a fee is specified, the system posts it as a **linked expense transaction** within the same compound transaction. The transfer and the fee are separate ledger records grouped under a shared compound transaction ID. The transfer's ledger entries are unchanged (`Dr A₂ B, Cr A₁ B`); the fee posts as `Dr FeeCategory F, Cr A₁ F` separately. Both are presented as a **single entry in the transaction list**. The transaction detail view shows both the transfer amount and the fee breakdown.
- **Fee category:** The fee expense defaults to the **Financial > Fees & Charges** subcategory (see default category list in §5.2.4). The user may change the category before saving.
- **Compound transaction behaviour:** Editing or deleting a transfer-with-fee affects both parts together. The fee expense component is not independently editable or deletable from the transaction list — it is surfaced only in the detail view.
- **Scope:** Available on all transfer transactions in v1. Cross-currency transfer fee support is deferred to v2 (cross-currency transfers are blocked in v1 per §7).

#### 5.1.6 Credit Card Balance Model

A credit card account's ledger balance is computed using the universal formula (§4.6): **balance = Σdebit − Σcredit**. In normal use the balance is negative, representing the total amount owed.

Two balance figures are meaningful for credit cards:

| Balance | Definition | Source |
|---------|------------|--------|
| **Outstanding balance** | Current total ledger balance — the total amount owed across all billing cycles. | Live ledger computation |
| **Statement balance** | Net change to the credit card account between the last billing date and the current date — the amount due by the payment due date. | Derived on demand from the ledger filtered by billing period. Not stored separately. |

**Balance edit screen for credit cards:**

The balance edit screen for a credit card presents **two distinct actions** (replacing the single "edit balance" used for other account types):

1. **Adjust statement balance** — corrects the amount owed for the current billing cycle. The resulting journal adjustment is dated to the billing date.
2. **Adjust outstanding balance** — corrects the total currently owed. The journal adjustment is dated to today.

Both actions follow the standard journal adjustment flow (§4.10): the user is prompted *"Record this change as income/expense?"* and cases 2.3a/2.3b (visible) or 2.4a/2.4b (invisible) apply.

#### 5.1.7 Credit Card Payment Reminders

When a credit card account has a **billing date** and **payment due date** configured, the app automatically schedules OS-level local notifications to prompt payment. These reminders fire regardless of whether a linked bank account is set.

**Notification schedule (recurring each billing cycle):**

| Trigger | Notification content |
|---------|---------------------|
| 1 day after billing date | "Your [Card Name] statement is ready. Statement balance: [amount]." |
| 7 days before payment due date | "[Card Name] payment due in 7 days. Amount due: [statement balance]." |
| 1 day before payment due date | "[Card Name] payment is due tomorrow. Amount due: [statement balance]." |
| On payment due date | "[Card Name] payment is due today." |

Each notification exposes a **Pay** action that opens the credit card payment entry form. The same form is accessible from the persistent **Pay FAB** on the credit card account detail screen.

**Credit card payment entry form:**

| Field | Value |
|-------|-------|
| Transaction type | Transfer (fixed — not editable) |
| Destination account | This credit card (pre-filled, not editable) |
| Source account | Linked bank account if set (pre-filled); empty otherwise |
| Amount | Statement balance (pre-filled; user may edit before confirming) |

**Notification lifecycle:** Notifications are re-scheduled whenever the billing date, payment due date, or linked bank account field is updated. This feature reuses the same `SCHEDULE_EXACT_ALARM` and `POST_NOTIFICATIONS` permissions already required by recurring transaction reminders (§5.2.7).

---

### 5.2 Transaction Management (CORE) — UC-2

#### 5.2.1 Transaction Entry

User selects transaction type. Fields collected:

| Field | Income | Expense | Transfer | Notes |
|-------|--------|---------|----------|-------|
| Date and time | ✅ | ✅ | ✅ | |
| Amount | ✅ | ✅ | ✅ | |
| Account (destination) | ✅ | — | ✅ (from + to) | |
| Account (source) | — | ✅ | — | |
| Transaction category | ✅ | ✅ | ❌ (not applicable) | |
| Subcategory | ✅ | ✅ | ❌ | |
| Title | ✅ | ✅ | ✅ | Optional. Short label for the transaction. See display rules below. |
| Description | ✅ | ✅ | ✅ | Optional. Long-form text. Max character limit configurable in Settings (default: 1000; options: 500, 1000, 2000). See display rules below. |
| Photo(s) | ✅ | ✅ | ✅ | Optional. Max 2 photos per transaction (see §5.2.3). |

> **Note:** "Notes" has been removed from transactions and replaced by two separate optional fields: **Title** and **Description**. Notes remains on **accounts** (see §5.1.1) — it was only removed from transactions.

**Transaction List Display (3-Column Layout)**

Each row in the transaction list displays three columns:

| Column | Content |
|--------|---------|
| **C1 — Category** | If the transaction has only a parent category: the parent category icon and name. If the transaction has a parent + subcategory: parent name on the first row, subcategory name on the second row. For transfers: no category (display "Transfer" label). |
| **C2 — Title & Account** | **Row 1:** Title (blank if not provided; v3 idea: ML/rule-based auto-generated titles). **Row 2:** Account info — for expense: source account name; for income: destination account name; for transfer: source account -> destination account. |
| **C3 — Amount & Currency** | The transaction amount with currency symbol. For accounts in a foreign currency, both the original currency amount and the home currency equivalent are shown (see §7.1). |

**Amount colour coding:** Transaction amounts in the list are colour-coded by transaction type:
- **Income**: Amount displayed in **green**.
- **Expense**: Amount displayed in **red**.
- **Transfer**: Amount displayed in the **default neutral colour** (no accent).

This applies uniformly to all transactions, including Balance Adjustment entries — a Balance Adjustment recorded as income (balance ↑) appears green; one recorded as an expense (balance ↓) appears red. This is the primary way users distinguish the direction of Balance Adjustment transactions in the transaction list.

**Grouping and ordering:** Transactions are grouped by date (date header per group). Within each date group, transactions are ordered by time (most recent first). The **default sort order is date descending** (most recent at top, oldest at the bottom). Custom sort options are available via the filter window (§5.2.6). The timestamp is not shown in the list row — it is revealed when the user taps the transaction to open the detail view.

**Transaction List Architecture:**
- The default view is a **unified transaction list** showing all transactions across all accounts.
- Soft-deleted (voided) transactions, unrealised future-dated transactions (see §5.7), and superseded versions of corrected transactions are excluded from the default list. Only the final corrected version is shown (see §5.2.2).
- A **per-account transaction list** is accessible from the account detail screen (tapping an account navigates to its detail view, which shows transactions filtered to that account).
- Balance adjustment transactions (§4.10): when the user chose "Yes" (record as income/expense), the transaction appears in the list with the Balance Adjustment category like any other transaction. When the user chose "No" (invisible journal entry), the transaction does **not** appear in the list — it is an internal ledger entry surfaced only in the v2 audit view. This is consistent with §4.10 and §5.1.3.

**Transaction Description Display:**
- Description appears **only in the transaction detail view**, never in the transaction list.
- Character limit is configurable in Settings (§5.4.3) from a predefined set: 500, 1000, or 2000 characters. Default: 1000.

**Transaction Detail View**

Tapping a transaction in the list opens its detail view. The detail view surfaces all information about a single transaction that is not visible in the list row. Exact layout is deferred to UX Flows.

**v1 contents:**

| Section | Content | Notes |
|---------|---------|-------|
| **Header** | Transaction type badge (Income / Expense / Transfer) | Colour-coded per §5.2.1 amount colour coding |
| **Amount** | Full amount with currency symbol; home currency equivalent if foreign-currency account (§7.1); stored exchange rate | Exchange rate shown here only, not in list row |
| **Date & time** | Full date and timestamp | Timestamp is hidden in the list row — revealed here |
| **Title** | Title text (if provided) | |
| **Description** | Full description text | Only place description is shown (not in list) |
| **Account info** | Expense: source account name. Income: destination account name. Transfer: source → destination account names. | Account names are shown even if the account has been soft-deleted (see §5.1.1 soft-delete behaviour) |
| **Category info** | Parent category (icon + name) and subcategory name (if any). Transfers: not shown. | |
| **Fee breakdown** | Transfer amount and fee amount shown separately (if compound transfer-with-fee per §5.1.5b). Fee category displayed. | Only for compound transactions |
| **Photo carousel** | Attached photos displayed as a horizontally scrollable carousel. Tap opens full-screen. | Max 2 photos (§5.2.3). Contextual menu on photo: Delete photo (§5.5.1). |
| **Contextual menu** | Edit, Delete (per §5.5.1) | Accessible via 3-dot menu or similar affordance |

**v2 additions (not in v1 scope):**
- **Correction history:** "This transaction was corrected on [date]" with link to original and reversal entries (surfaces in v2 audit view).
- **Recurring template link:** Which template generated this transaction; past and future occurrences of the series.
- **Installment and loan status:** If part of an installment series linked to a loan account — series progress, remaining amount, loan balance.

**Duplicate Transaction Detection (FG-C2)**

When saving a new transaction, the app checks for a **probable duplicate**: an existing posted (non-voided) transaction with the same **type, amount, account, and category** on the **same calendar day**. If a match is found, a non-blocking warning is shown:

> *"A similar transaction already exists today ([amount], [category], [account]). Add anyway?"*

- The user may **confirm** (the transaction is saved normally) or **cancel** (returns to the entry form).
- The check is informational only — there is no auto-delete, no merge, and no block.
- If the user confirms, the duplicate is treated as intentional and no further warnings are surfaced for that pair.
- The detection applies to income and expense transactions. Transfers are checked by type, amount, source account, and destination account on the same day.

#### 5.2.2 Transaction Immutability & Editing

- All posted transactions are immutable.
- **Editing amount, account, or category**: A reversing entry is posted (negating the original), followed by the corrected transaction. This applies equally to all three financial fields. A category change is treated identically to an account or amount change — it is a financial correction requiring a reversing + corrected pair. This is consistent with §4.8 and with Cases 1.4 and 1.5 in `docs/01-product/ledger-entry.md`, where the corrected entry already models a changed category (EC', IC').
- **Editing a transaction whose current category has been soft-deleted:** The soft-deleted category is always shown as the active selection in the edit form — the transaction still belongs to it and no forced re-categorisation is required. If the user opens the category picker, the soft-deleted category appears as a special **"current" entry** at the top of the picker (even though it would otherwise be hidden), allowing the user to re-select it and close without making a change. If the user selects a different (active) category and saves, the change is treated as a standard financial correction (reversing + corrected entries per §4.8). Once saved with a new category, the soft-deleted category is no longer accessible via the category picker for this transaction. **For transactions whose current category is active (non-deleted):** soft-deleted categories are never shown in the category picker, consistent with §5.2.4.
- **Correction visibility:** Only the **final corrected transaction** is visible in the transaction list. The original transaction and its reversing entry are hidden as internal ledger entries — they maintain ledger integrity but are not shown in normal user-facing views. This preserves full DEB abstraction (§2, G2). The original and reversal are surfaced in the v2 audit view.
- **In-place edits (no ledger posting)**: Title, description, photos, and **date/time**. None of these fields trigger correcting ledger entries when changed. Changing the transaction date may shift which reporting period the transaction falls in (affecting period-based summaries), but no reversing/corrected entries are posted. The user is responsible for date accuracy.
- **Soft delete**: The transaction is voided. A reversing entry is posted automatically. The original record is retained but excluded from all normal views and calculations. Voided transactions are surfaced in the v2 audit view.
- No transaction is ever permanently deleted.

#### 5.2.3 Photo Attachments

- A maximum of **2 photos** may be attached per transaction.
- Photos are stored in a dedicated app-private data folder on the device.
- Photos are not accessible from the OS gallery.
- When a transaction is soft-deleted (voided), all its attached photos are permanently deleted from storage.
- Photos are compressed before storage. Compression algorithm, target resolution, and quality threshold are deferred to SDS.

#### 5.2.4 Transaction Categories (Two-Level Hierarchy)

Categories and subcategories form a two-level tree — category -> subcategory. No deeper nesting.

Separate trees exist for **Income** and **Expense**. Transfers have no category.

**Category fields:**
Each category (both parent and child) has exactly two fields:
- **Icon**: Selected from the `material_symbols_icons` Flutter package (^4.2928.1 from pub.dev). The full icon set is large; a curated subset will be bundled for the category picker. The exact subset and bundling strategy (tree-shaking, selective import) are deferred to SDS for efficiency analysis.
- **Name**: Free-form text label.
No other fields (colour, description, etc.) exist on categories.

**Category management UX:**
Category management is accessed from Settings (§5.4.8). The flow is:
1. The category management screen displays a list of **parent categories only** (separately for Income and Expense trees).
2. A **+ button** at the parent list level allows the user to add a new parent category (providing icon and name).
3. Tapping a parent category navigates to a child list view showing all subcategories under that parent.
4. A **+ button** within the child list view allows the user to add a new child category (providing icon and name) under that parent.
5. Edit and delete actions on any category entry are accessed via the contextual action menu (§5.5).

**Category name uniqueness constraint:**
- Within a given parent category, no two child categories may share the same name.
- At the top level, no two parent categories may share the same name within the same tree (i.e., no two income parent categories with the same name; same rule for expense parent categories).
- Name uniqueness is case-insensitive (exact case-sensitivity behaviour deferred to SDS).

**Category mutability rules (all categories — default and user-created):**
- All categories and subcategories (default and user-created) may be: renamed, icon-changed, and soft-deleted. Manual reordering is deferred to v2; the default display order is alphabetical.
- A subcategory cannot be reassigned to a different parent category. The parent is fixed at creation.
- A parent category **cannot be deleted if it has any child subcategories**. The user must first soft-delete all children before the parent becomes deletable. Bulk "delete parent and all children" is not supported.
- **A leaf parent category** (a parent with no children) **can be soft-deleted at any time.**
- **A child category (subcategory) can be soft-deleted at any time**, regardless of whether active (non-voided) transactions reference it. This supersedes any prior constraint to the contrary.
- **Category usage count on deletion (FG-B5):** When a user initiates a category soft-delete, the app first displays the number of active (non-voided) transactions referencing this category: *"This category is used by [N] transaction(s). Deleting it will not affect those transactions, but the category will be removed from the filter and category picker for new entries."* This count must be computed efficiently (single aggregate query). If N = 0, this informational step is skipped and the flow proceeds directly to the migration prompt.
- **Transaction migration on category deletion:** After the usage count is shown, the app prompts: *"Would you like to migrate transactions from this category to another category?"*
  - **No migration (default):** Existing transactions retain the soft-deleted category label. The category is hidden from pickers and filters but the label persists on historical transactions.
  - **Yes — migrate all:** The user selects a destination category. All transactions referencing the deleted category are re-categorised to the destination (this is a financial edit — reversing + corrected entry pairs are posted per §4.8).
  - **Yes — choose specific transactions:** The user is presented with the list of transactions referencing the category and selects which ones to migrate. Selected transactions are re-categorised; unselected transactions retain the old category (same as "no migration" for those).
- Soft-deleted categories are **hidden from the category picker** in new transaction entry and are not available for selection when creating a new transaction. However, soft-deleted categories **remain visible in filter dropdowns** (§5.2.6) so users can filter to historical transactions that reference a deleted category. This mirrors the treatment of soft-deleted accounts in the account filter (see §5.1.1 soft-deleted account behaviour).
- Existing (non-voided) transactions that reference a soft-deleted category continue to display that category's name exactly as it was at the time of the transaction. The soft-deleted category label is shown as-is in the transaction detail view.
- **Reinstatement of soft-deleted categories:** The same reinstatement logic described in §5.1.1 for accounts applies to categories. When creating a new category whose name matches a soft-deleted category within the same tree and parent, the app offers to reinstate the deleted category instead. Category names must be unique including across soft-deleted categories.

**Recurring and installment template handling on category deletion:**

The same template warning and migration flow described in §5.1.1 applies when a transaction category is soft-deleted and it is referenced by future-scheduled recurring or installment templates. Before the category soft-delete proceeds, the user is shown a blocking warning:

> *"[N] recurring/installment template(s) are scheduled to use this category. What would you like to do?"*

Options: **Migrate templates** (select a replacement category) or **Stop templates** (archive all affected templates). The **default is Stop templates**. This warning fires in addition to the existing transaction-migration prompt (§5.2.4 category mutability rules) — both flows may be active if the category has both historical transactions and future template occurrences.

---

**Protected system category — "Balance Adjustment":**
- Exists in both income and expense trees.
- Cannot be selected by the user when creating a transaction.
- Assigned automatically when a journal adjustment is recorded as income/expense.
- Visible in the transaction list when such transactions exist. Balance Adjustment transactions are **visually indistinguishable** from normal transactions in the list. Full UI treatment is deferred to UX Flows.
- **Completely hidden from the category management screen.** The user cannot see, rename, change the icon of, or soft-delete this category. It is fully immutable and system-managed.
- **Protected entity pattern:** The "Balance Adjustment" category and the internal equity account (§4.9) are both protected system entities. The DB schema must support a `is_protected` flag (or equivalent) on categories and accounts to distinguish system-managed entities from user-managed ones. This pattern may expand in future versions as additional protected entities are introduced.

##### Default Expense Categories

| Category | Subcategories |
|----------|---------------|
| Food | Lunch, Dinner, Breakfast, Snacks, Water, Eating Out, Groceries, Sweets, Drinks, Other |
| Transportation | Bike, Auto, Cab, Bus, Metro, Fuel, Parking, Tolls, Other |
| Household | Rent, Appliances, Toiletries, Repairs, Marketing, Water, Cleaning, Furniture, Cook/Maid, Kitchen, Accessories, Other |
| Travels | Train, Flight, Hotel, Entry Fee, Travels Food, Travels Transport, Gifts & Souvenirs, Other |
| Apparel | Clothing, Fashion, Shoes, Laundry, Jewellery, Accessories, Other |
| Health | Doctor, Hospital, Medicine, Gym, Hospital Transport, Hospital Food, Ambulance, Tests, Other |
| Self | Haircut, Electronic Accessories, Repair, Subscriptions, Trip, Party, Books, Toys, Glasses, Games, Other |
| Social | Movie, Treat, Outing, Gift, Other |
| Stationery | Books, Art, Craft, Other |
| Culture | Music, Concert, Museum, Festival, Pujo, Other |
| Financial | Mobile Bill, WiFi Bill, Electricity Bill, Insurance, Tax, Investments, Fees & Charges, Other |
| Education | Application Fees, Textbooks, Supplies, Tuition Fees, Other |
| Loan | Education Loan, Home Loan, Personal Loan, Splitwise, Other |
| Friends & Family | Friends, Parents, Other |
| Other | Home, Charity, Other |
| *(System)* Balance Adjustment | *(Protected — not user-selectable)* |

##### Default Income Categories

| Category | Subcategories |
|----------|---------------|
| Standard | Salary, Bonus, Allowance, Reimbursement, Scholarship, EPF, Pension |
| Gift | *(leaf — no subcategories)* |
| Repayment | Loans, Splitwise, Refund |
| Other | *(leaf — no subcategories)* |
| *(System)* Balance Adjustment | *(Protected — not user-selectable)* |

> **Note:** "Gift" and "Other" income categories are intentionally leaf categories with no default subcategories. This is by design for v1. Users may add their own subcategories to them at any time through the normal category management flow.

#### 5.2.5 Transaction Search

Search is accessible from the transaction list. The search engine uses an **fzf-style matching model** (inspired by the `fzf` CLI tool):

- **Typo-tolerant**: Minor spelling errors (1–2 character transpositions or substitutions) are matched. Typing "grociries" returns "Groceries".
- **Substring / contains**: A query appearing anywhere within a field value matches. Typing "groc" returns "Groceries".
- **Nearest-substring ranking**: Results are ranked by closeness of match. Exact matches rank highest, prefix matches rank above mid-string matches.
- **Exact string match**: Typing an exact value matches it with the highest rank.

**Searchable fields:** date, account name, category name, subcategory name, title, and description. Whether title and description are searched with equal or different ranking weight is deferred to UX Flows. Transactions referencing **soft-deleted accounts or soft-deleted categories** are included in search results — the deleted entity's name remains searchable (see §5.1.1 soft-deleted account behaviour and §5.2.4 soft-deleted category behaviour).

**Amount search:** Amount fields are matched by **exact value only**. Typing "500" returns transactions with an amount of exactly ₹500 — it does not return ₹5,000 or ₹50.

#### 5.2.6 Transaction Filtering

A dedicated filter view (separate from the main transaction list) provides filter and sort controls. Supported filter criteria:

| Criterion | Notes |
|-----------|-------|
| Transaction type | Income / Expense / Transfer |
| Category | Contextual — only shows income categories for income filter, etc. Multi-select: one or more categories may be selected. |
| Subcategory | Contextual — filtered by the selected category. Multi-select. |
| Account | One or more accounts. **Includes soft-deleted accounts** so users can filter to historical transactions from a deleted account (see §5.1.1 soft-deleted account behaviour). |
| Date range | Absolute range or relative presets (this month, last 7 days, etc.) |
| Amount range | Min amount, max amount, or both (inclusive bounds). Optional. |
| Has photo | Boolean |
| Has title | Boolean |
| Has description | Boolean |
| Is recurring | Boolean |
| Is voided | Boolean — shows soft-deleted transactions |

**Filter logic — simple view (v1):** All active filter criteria are combined with **AND logic** — a transaction must satisfy every active criterion to appear in results. This is the only filter mode in v1.

**Filter logic — advanced view (v2 deferred):** Will support a predicate builder allowing the user to compose conditions with AND, OR, and NOT operators, enabling queries like "(Food OR Transportation) AND last 30 days."

**Sort controls:** The filter window also exposes sort controls for the transaction list. The **default sort order is date descending** (most recent first).

| Sort field | Available orders |
|------------|-----------------|
| Date | Descending (recent first — **default**) / Ascending (oldest first) |
| Amount | Descending (largest first) / Ascending (smallest first) |

**Filter state — no persistence:** Applied filters do **not** persist across navigation. When the user navigates away from the transaction list and returns, all filter criteria and sort overrides are **cleared**. The transaction list resets to the unfiltered, default-sorted (date descending) view.

**Saved filter profiles** — storing a named filter configuration for repeated use — is a **v2 feature**.

Full UX specification (filter panel layout, chip display, preset interactions) deferred to UX Flows.

#### 5.2.7 Recurring Transactions

Users can define recurring transaction templates. Parameters:

- Transaction type, amount, account(s), category, title (optional), description (optional)
- **Recurrence definition**: $N$ units of a time unit, where unit ∈ { day, week, month, year }. E.g., "every 2 weeks", "every 3 months".
- **Optional recurrence constraints**: repeat on weekdays only / weekends only / start of month / end of month / start of year / end of year.
- Start date, optional end date.
- **End-of-month day handling:** If a recurring transaction is scheduled for a calendar day that does not exist in a given month (e.g., the 29th, 30th, or 31st in February; the 31st in April, June, September, or November), it is posted on the **last valid day of that month** (e.g., 28 February in non-leap years; 30 April). This applies to all month- and year-unit recurrences.

- **Missed transactions on app launch:** If the device was powered off, the app was force-stopped, or the scheduler was otherwise unable to run on a scheduled date, all missed recurring auto-post transactions are **posted automatically the next time the app launches**. For "remind and confirm" templates, if the 24-hour confirmation window has already elapsed, the missed occurrence is auto-approved and posted at launch. Occurrences skipped during a pause period are **not** retroactively posted when the template resumes.

- **Posting behaviour** (configurable per template):
  - **Auto-post**: Transaction is posted automatically on the scheduled date.
  - **Remind and confirm**: An **OS-level local notification** prompts the user to review and confirm before posting. This requires `POST_NOTIFICATIONS` (Android 13+) and `SCHEDULE_EXACT_ALARM` permissions. No network call is involved — notifications are entirely on-device. If the user does not respond within **24 hours** of the scheduled time, the transaction is **auto-approved and posted**. The user can disable "remind and confirm" mode for all future occurrences of a template via the template's contextual menu (switching it to auto-post).
- **Pause / Unpause** (v1):
  - A recurring template can be **paused** for a specified duration: either M units of the template's time unit (e.g., "pause for 2 months" on a monthly template), or until a custom date and time.
  - While paused, no transactions are realised. Skipped occurrences **remain skipped** — they are not retroactively posted when the template resumes.
  - A paused template can be **unpaused** at any time (resumes from the next scheduled occurrence after the current date).
  - A template **cannot be paused indefinitely** — that is functionally equivalent to disabling, which is deferred to v2. The pause duration must have a defined end.
  - **Disable / Enable** (permanently stop and restart a template) is deferred to v2. In v2, re-enabling will prompt the user: realise only future transactions, or also backfill all transactions that would have been realised during the disabled period.
- When the end date passes or all installments are exhausted, the template is **automatically archived**.
- Archived templates **cannot be reactivated**. If the user wishes to resume a recurring pattern, they must create a new template.

**Template editability:**

When editing a recurring template via the "Edit template" contextual action (§5.5.1), the following rules apply:

- **Editable (in-place, future occurrences only):** Amount, account(s), category, subcategory, title, description, posting behaviour. Changes take effect from the next unposted occurrence. Already-posted child transactions are unaffected.
- **Immutable (cannot be changed after creation):** Transaction type, recurrence definition (N, unit, constraints), start date, end date. To change the schedule structure, the user must archive the current template and create a new one.

**Child transaction editing and deletion:**
- Individual child transactions generated by a recurring or installment template are editable and soft-deletable like any other transaction.
- The existing correction model (reversing + corrected entries, Cases 1.4–1.9 in `docs/01-product/ledger-entry.md`) applies in full.
- **Effect on the parent template (Q47):** When a child transaction is edited or soft-deleted, the specific occurrence is marked as **"manually handled"** on the template's schedule. The template's overall configuration (amount, recurrence, account, category) is **not affected**. All remaining future occurrences continue to be scheduled and realised normally. The scheduler skips any occurrence already marked as manually handled.

#### 5.2.8 Installments

Installments are a sub-type of recurring transaction representing a fixed total amount split across a defined set of periods.

Parameters:
- Total amount, recurrence definition (same as 5.2.7), number of installments (derived from total / recurrence, or manually set).
- The system auto-calculates the per-installment amount (total ÷ number of installments).
- The user may manually adjust individual installment amounts after the auto-calculation stage.
- If the sum of manually adjusted amounts does not equal the total amount, the app surfaces a **non-blocking warning at save time** of the payment plan. The user may still save and proceed.
- Whether installments are implemented as a tagged sub-type within the templates table or as a separate entity within that table is deferred to SDS schema design. The PRD treats installments as a distinct concept under the same template generation mechanism as recurring transactions.

**Installment running total tracking (Q48):**

The installment template maintains four tracked amounts:

| Amount | Definition |
|--------|-----------|
| **Total configured** | The target total amount set when the installment was created. Immutable after creation. |
| **Running total** | Sum of all posted (non-voided) child transaction amounts to date. If a child is soft-deleted, its amount is subtracted from the running total. If a child's amount is edited (corrected), the running total reflects the corrected amount. |
| **Total remaining** | Sum of all future scheduled installment amounts (not yet posted). |
| **Projected final total** | Running total + Total remaining. May differ from Total configured if individual installments have been manually adjusted, deleted, or corrected. |

The non-blocking mismatch warning (at save time) applies when Projected final total ≠ Total configured.

**Installment editability:**

- **Total configured** is immutable after creation.
- The user may **add new future installments** or **remove unposted future installments** after creation. This changes the Projected final total and Total remaining but not Total configured. Mismatch warning surfaces if Projected final total ≠ Total configured.
- **Per-installment amounts** for future (unposted) installments may be manually adjusted at any time. Same mismatch warning applies.
- All other template editability rules from §5.2.7 apply (amount, account, category, title, description, posting behaviour are editable; recurrence structure and schedule boundaries are immutable).

**Installment early close (FG-B7):**

The user may close an installment series early before all scheduled installments have been posted. This is accessed via the **"Mark series as complete"** action in the installment template's contextual menu (§5.5.1).

The early close flow:

1. The app displays the current payment progress (the 4 tracked amounts above) and asks: *"Would you like to record a final payment before closing this series?"*
2. **If yes — final lump-sum payment:** The user enters a final payment amount. A new transaction is posted and linked to the installment series (same as a regular installment child transaction). All remaining future scheduled installments are cancelled and the template is archived.
3. **If no — close without final payment:** All remaining future scheduled installments are cancelled and the template is archived. No new transaction is posted.
4. **Mismatch warning:** After the early close (with or without a final payment), if the resulting Running total ≠ Total configured, the app warns: *"The total paid ([running total]) differs from the original target ([total configured]). Would you like to update the target total to match the actual paid amount?"*
   - **Update target:** Total configured is updated to match Running total. The mismatch is resolved.
   - **Keep original:** Total configured remains unchanged. The series is archived with the mismatch noted.

Once archived via early close, the template follows the standard archive rules — it **cannot be reactivated** (§5.2.7).

---

### 5.3 Budgeting *(Deferred to v2)*

> **Deferred:** The entire budgeting feature has been moved to v2. Budgets will be redesigned from the ground up alongside savings goals (also v2) to ensure the two features interact coherently. The previous specification (total + per-category budgets, multi-horizon, rollover, alerts, income replenishment) is preserved below as a v2 starting point but is **not in scope for v1**.
>
> All budget-related open questions (Q59, Q61, Q68, Q69) and feature gap items (FG-A17 through FG-A21, FG-B3, FG-B6, FG-C8, FG-C9) are deferred with this decision.

<details>
<summary>v2 Budget Specification (preserved for reference — not in v1 scope)</summary>

#### 5.3.1 Budget Model

- **Total budget**: A single overall spending ceiling for a given period.
- **Per-category budgets**: Individual spending limits per expense transaction category.
  - Per-category budgets need not sum to the total budget.
  - If their sum exceeds the total budget, a small passive visual indicator is shown. No popup or hard block.
- **Default budget horizon**: Monthly.
- **Additional horizons**: Weekly, quarterly, annual.
- Multiple horizon-scoped budgets may coexist (e.g., monthly Food budget and an annual Travel budget).

#### 5.3.2 Income Replenishment

Any transaction (of any income category or account) has a **"More Options"** menu exposing an **"Add to Budget"** action.

- The user selects a target budget pool (total or a specific category budget).
- If the budget pool has $N$ remaining out of $M$, and the transaction amount is $T$:

$$N_{\text{new}} = \min(N + T, \, M)$$

- The pool is capped at the original budget ceiling $M$. Adding income cannot cause the remaining amount to exceed the total budgeted amount. Any portion of $T$ beyond $M - N$ is silently discarded.

#### 5.3.3 Budget vs. Actual

- Real-time comparison of budgeted amount vs. actual spending per category and in aggregate.
- Visual indicators: progress bar with colour thresholds.

#### 5.3.4 Budget Alerts

- In-app alerts fire when spending crosses configurable thresholds (default: 80% and 100%).
- Alert thresholds are per-budget and user-configurable.
- Alerts appear within the app only.

#### 5.3.5 Budget Rollover

- Configurable per budget: whether unused remaining budget ($N$ at period end) carries forward to the next period.
- Defaults to off.

</details>

---

### 5.4 Settings & Customisation (CORE)

> The Settings screen is the central hub for app-level configuration, entity management, and data operations. This section defines every settings group, its contents, and the configurable fields within each. The groups are listed in the order they appear on the Settings screen.
>
> **Per-entity settings** (per-account fields, per-template fields) are managed through their respective edit forms, accessed from the entity management screens below (§5.4.7, §5.4.9). They are not duplicated here.

#### 5.4.1 Appearance

| Setting | Type | Default | Options | Notes |
|---------|------|---------|---------|-------|
| Theme | Enum | System default | Light, Dark, System default | |
| Color scheme | Enum | Material You dynamic | Material You dynamic color (from wallpaper, API 31+), Custom seed color | Dynamic color requires API 31+. On lower API levels, falls back to custom seed color. |
| Animations | Boolean | Enabled | Enable, Disable | Disabling animations removes transitions and micro-interactions app-wide. |

**Font:** The app uses a curated combination of fonts for different UI elements (headings, body, numeric displays, etc.). This is a design-level decision, not user-configurable. The exact font pairing is deferred to UX Flows.

**Color scheme preview:** A **"Preview color scheme"** action is accessible from the app's navigation options menu (alongside Pending Confirmations). It renders a preview screen showing the active Material You 3 color palette — primary, secondary, tertiary, surface, and on-surface tokens — as generated from the device wallpaper (dynamic color) or the user's selected custom seed color. This allows the user to see the full palette at a glance before committing to a seed color change.

#### 5.4.2 Locale & Format

| Setting | Type | Default | Options | Notes |
|---------|------|---------|---------|-------|
| Home currency | ISO 4217 | Inferred from device locale (fallback: INR) | Bundled ISO 4217 list | Set during onboarding (§5.6.2). Changeable at any time. Affects net worth display, exchange rate reference, and new account default currency. |
| Number format — decimal separator | Enum | Inferred from locale | Comma (,) or Period (.) | |
| Number format — thousands grouping | Enum | Inferred from locale | Standard 3-digit grouping, **Indian numbering (lakh/crore)** — 2-2-3 grouping (e.g., ₹10,00,000 = 10 lakh) | Indian locale → Indian grouping by default. Western locales → standard grouping. User may override. (FG-C11) |
| Currency formatting — symbol placement | Enum | Inferred from home currency locale | Prefix (e.g., $100), Suffix (e.g., 100€) | |
| Currency formatting — symbol spacing | Enum | Inferred from home currency locale | No space (e.g., $100), Space (e.g., $ 100) | |
| Week start | Enum | Monday | Monday, Sunday | Affects date grouping headers and any period-based displays. |
| Time format | Enum | Inferred from device | 12-hour, 24-hour | Affects all time displays (transaction detail, template schedules). |
| Percentage precision | Enum | 0 | 0, 1, or 2 decimal places | Controls decimal places for percentage displays (e.g., fee percentage entry, future budget %). |

#### 5.4.3 Transaction Entry

| Setting | Type | Default | Options | Notes |
|---------|------|---------|---------|-------|
| Description max length | Enum | 1000 | 500, 1000, 2000 | Maximum character limit for the transaction description field (§5.2.1). Applies to new and edited transactions. |
| Back button behaviour | Enum | Ask before discarding | **Ask before discarding** — confirmation dialog *"Discard changes?"*; **Auto-save as draft** — saves partial entry as a draft (accessible from a Drafts section); **Discard immediately** — discards without confirmation | Controls behaviour when the Android back button is pressed while a transaction entry form has unsaved data. (FG-C20) |

> **Duplicate transaction detection** (FG-C2, §5.2.1) is always active — there is no user toggle. The non-blocking duplicate warning fires whenever the detection criteria are met.

#### 5.4.4 Warnings & Limits

This section contains configurable warning thresholds that trigger non-blocking confirmations during transaction entry.

**Large transaction warning (FG-C18):**

Per-account and per-category configurable warning thresholds. When a transaction amount exceeds the threshold set for the relevant account or category, a non-blocking warning is shown: *"This is a large transaction — [amount]. Confirm?"*

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Per-account threshold | Amount (nullable) | Disabled (no threshold) | Set individually for each account. Accessed via Settings > Warnings & Limits > Per-Account Limits. Each account row shows its current threshold (or "Not set"). |
| Per-category threshold | Amount (nullable) | Disabled (no threshold) | Set individually for each expense category. Accessed via Settings > Warnings & Limits > Per-Category Limits. Each category row shows its current threshold (or "Not set"). |

**Behaviour:** If both an account threshold and a category threshold apply to a single transaction, and both are exceeded, only **one warning** is shown (the more specific — account threshold takes precedence). The user confirms once.

> **Overdraft warning** (§5.1.4) and **credit card limit warning** (§5.1.4, FG-C18) are not configurable — they are always active when the relevant conditions are met (negative balance or credit limit exceeded). They are not settings.

#### 5.4.5 Profile

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Display name | Text (optional) | Empty | Used in the home screen greeting (§5.8.1): *"Hi, [display name]!"*. If empty, greeting shows *"Hi!"* with no name. |

#### 5.4.6 Security

**Fundamental scope of the lock:**

The security lock in Variance protects **sensitive account detail fields only** (card numbers, bank account numbers, and masked account metadata). **Basic app functionality — recording transactions, viewing the transaction list, browsing account balances, and all core finance features — is always accessible without authentication.** The lock is never applied to the whole app.

**Lock mechanism (hierarchical):**
1. **Device lock** (if set by the user at the OS level) — preferred. The app delegates authentication to the Android Keyguard (biometrics, device PIN/pattern/password).
2. **Device-set app-specific lock** (if the device supports per-app biometric lock) — secondary.
3. **In-app PIN** — fallback. Used only if neither device lock nor device app-specific lock is available. The user is prompted to set a PIN on first launch in this case.

| Setting | Type | Default | Options | Notes |
|---------|------|---------|---------|-------|
| Lock timeout | Enum | Immediately | Immediately, 30 seconds, 1 minute, 5 minutes | Time after app backgrounding before the lock re-engages. |

**Lock timing:** The lock activates on **app close or app minimisation** (backgrounding). Once authenticated to view sensitive details, those details remain visible until the app is closed or minimised (the lock re-engages on backgrounding per the configured timeout).

**PIN recovery:**
If the user forgets the in-app PIN:
1. The user is locked out of the **sensitive account details view** only. All other app functionality remains accessible.
2. To reset the PIN, the user must authenticate via their **device security** (device lock, biometrics, or device PIN). If device security is set up, the device credential verifies the user and unlocks the PIN reset flow.
3. If the user has no device security configured, they must first set up device security (OS settings), then return to reset the in-app PIN.
4. The in-app PIN can only be reset through this device-credential path — there is no recovery email or cloud-based recovery (consistent with the local-only design).

**Failed PIN lockout:**
Applies only to the **sensitive account details view** — not to the rest of the app.

- After **5 consecutive failed PIN attempts**: the sensitive details view is locked out for a **fixed 1-hour timeout**. No further attempts are accepted during the timeout.
- After the timeout expires, the user gets another 5 attempts.
- After **15 total consecutive failed attempts** (3 cycles × 5 failures × 1-hour timeouts = accumulating across approximately 3 hours): the app **deletes the stored encrypted sensitive field data** (card numbers, bank account numbers). Transaction history, account balances, and all financial data are **never deleted** — only the encrypted account-critical fields (card/account numbers) are wiped.
- The 15-failure count resets to zero on any successful authentication.

#### 5.4.7 Accounts

View and manage all accounts, including soft-deleted accounts (with reinstatement option per §5.1.1).

"Per-account settings" is the account edit form (§5.1.1 Edit) — accessible from both Settings > Accounts and from the account contextual menu in the account list. There are no additional per-account settings beyond the edit form. Per-account fields include: name, notes, include-in-net-worth flag, and all category-specific fields (§5.1.2).

#### 5.4.8 Transaction Categories

Manage income and expense category and subcategory trees. The category management UX is defined in §5.2.4: parent list → tap for children → + button at each level. Protected system categories ("Balance Adjustment") are hidden from this screen.

#### 5.4.9 Recurring & Installments

Manage active, paused, and archived recurring transaction and installment templates. Per-template configuration (posting behaviour, pause duration, recurrence definition) is managed through the template edit form (§5.2.7, §5.2.8).

#### 5.4.10 Data

**Local Data Backup**

A local backup action is accessible from Settings > Data > Backup.

**Export:** The app exports all data — transaction ledger, accounts, categories, recurring and installment templates, and attached photos — as a **zip archive** saved to the user-selected location via the Android system file picker (or the device's Downloads folder as default).

- **Contents:** The exact structure of the zip archive (database dump format, file/folder naming, photo inclusion strategy) is deferred to SDS.
- **Photos:** Attached transaction photos are included in the backup zip.
- **Trigger:** The user initiates backup manually from Settings > Data > Backup. The app does **not** auto-backup on a schedule in v1.
- **Reminder:** After the first month of use (or first 50 transactions, whichever comes first), the app surfaces a **one-time in-app prompt** reminding the user to take a backup, given that data is not otherwise protected against device loss.

**Import / Restore:** Restoring from a backup zip is **deferred to v2**. In v1, backup is write-only — no import path exists.

**Cloud backup / sync:** Deferred to v2 (and potentially v3 via Google Drive). Consistent with the offline-first and local-only constraints.

#### 5.4.11 Accessibility

| Dimension | v1 Behaviour |
|-----------|--------------|
| **Font scaling** | The app UI adapts to the Android system font scale (up to 200%). All text elements scale, and layouts reflow to avoid overflow or clipping. This is a v1 requirement. |
| **TalkBack (screen reader)** | Interactive elements are labelled to the best extent practical in v1 — all buttons, icons, and form fields receive semantic content descriptions. Comprehensive and exhaustive TalkBack coverage (complex custom widgets, financial data tables, chart narration) may extend into v2 or v3. |
| **RTL layout** | Right-to-left layout mirroring is supported in v1. Flutter's built-in `Directionality` system is used so the UI mirrors correctly for RTL locales. Non-English and non-Indian localisation is out of scope for all foreseeable versions. |

NF-5 (WCAG 2.1 AA baseline) continues to apply as the overall accessibility standard.

> **Note:** Accessibility settings are system-level (Android Settings). Variance does not expose in-app accessibility toggles in v1 — it respects the system configuration.

#### 5.4.12 About & Legal

| Section | Contents |
|---------|----------|
| Open-source licenses | Bundled OSS license acknowledgements |
| App version | Semantic version string |
| Acknowledgements | Credits and attributions |

---

### 5.5 Contextual Action Menus

Contextual action menus are accessible via long-tap, hamburger menu, or 3-dot menu on any list item (depending on the screen). They expose entity-specific actions that are not visible on the primary surface.

#### 5.5.1 Confirmed Contextual Menu Actions

| Entity | Contextual Actions | Notes |
|--------|-------------------|-------|
| **Transaction (normal)** | Edit, Delete | "Add to Budget" removed — budgets deferred to v2 |
| **Account** | Edit, Delete, Reconcile | Reconcile opens the balance reconciliation flow (§5.1.3a) |
| **Parent category** (in category management) | Edit, Delete, Add Child Category | Delete triggers migration prompt (§5.2.4) |
| **Child/subcategory** (in category management) | Edit, Delete | No "Add Child" (max depth is 2). Change parent deferred to v2. |
| **Recurring transaction template** (active) | Edit template, Delete template, Pause, Unpause, View child transactions | View shows both past and future child transactions. Pause accepts duration in template's time unit or custom date. See §5.2.7. |
| **Recurring transaction template** (paused) | Edit template, Delete template, Unpause, View child transactions | |
| **Child transaction of recurring series** | Edit, Delete | Same as normal transaction. |
| **Photo attachment** (in transaction detail) | Delete photo | No "View full-screen" contextual action — tapping a photo opens it full-screen directly. |
| **Installment series template** | Edit template, Delete template, Pause, Unpause, View child transactions, View payment progress, Mark series as complete | View payment progress shows the 4 tracked amounts (§5.2.8). Mark as complete archives the template early (for lump-sum payoffs or negligible remaining amounts). |
| **Soft-deleted account** (in Settings > Accounts) | Reinstate | See §5.1.1 reinstatement. |
| **Soft-deleted category** (in Settings > Categories) | Reinstate | See §5.2.4 reinstatement. |

#### 5.5.2 Deferred Contextual Menu Cases (v2)

| Entity | Notes |
|--------|-------|
| Budget entry | Entire budgeting feature deferred to v2. |
| Transaction "Add to Budget" / "Remove from Budget" | Deferred with budgets. |
| Voided transaction (audit view) | No restoring voided transactions. Audit view actions to be designed in v2. |
| Recurring template "Disable / Enable" | Only Pause / Unpause in v1. Full disable/enable with backfill option in v2. |
| Subcategory "Change parent" | Reassigning a subcategory to a different parent deferred to v2. |

---

### 5.6 Onboarding & First Launch

#### 5.6.1 Default Category Seeding

On first install, all default income and expense categories listed in §5.2.4 are **silently pre-loaded** into the database. The user starts with a fully populated category taxonomy with zero friction. No user action is required.

#### 5.6.2 Onboarding Wizard

A first-launch onboarding wizard guides the user through initial setup. The wizard consists of the following steps:

| Step | Screen | Content | Skippable? |
|------|--------|---------|------------|
| 1 | **Welcome** | App name, tagline, brief value proposition (local-first, private, no sign-up required). | No (entry screen) |
| 2 | **Currency selection** | The app derives the home currency from the device locale and displays it prominently: *"We think your currency is ₹ INR."* The user can confirm or change it. **Fallback:** INR (this is an Indian-audience app). If the user skips the entire onboarding, the locale-derived currency (or INR fallback) is set as the default. Currency can be changed at any time in Settings (§5.4.2). | Yes |
| 3 | **Create first account** | Simplified account creation form: name, account category (from the 8 fixed types in §5.1.2), initial balance. Gets the user to a usable state immediately. | Yes (home screen shows empty state CTA) |
| 4 | **Quick highlights** | 2–3 swipeable cards showing key capabilities (track expenses, recurring transactions, multiple accounts). Brief, visual, skippable. | Yes |
| 5 | **Done** | Transition to the home screen. If the user created an account in step 3, it appears immediately. If skipped, the home screen shows an empty state with a CTA to create their first account. | N/A (auto-transition) |

A **Skip** button is available on steps 2–4. Skipping bypasses remaining wizard steps and lands the user on the home screen with locale-derived defaults applied. Categories are always seeded regardless of whether the user completes or skips the wizard.

> **Note:** The exact onboarding screen designs, illustrations, copy, and transitions are deferred to UX Flows (UX-5, UX-6). This section defines the functional scope and step sequence.

---

### 5.7 Timezone & Date Policy

**Storage:** All transaction timestamps are stored in **UTC**. Display is always in the device's local timezone.

**Back-dating:** Users may set a transaction date in the past. Back-dated transactions are posted to the ledger immediately on save. They affect the account balance and appear in the transaction list at their specified date.

**Future-dating:** Users may set a transaction date in the future. Future-dated transactions are **held as pending** until the scheduled date arrives. Pending transactions:
- Are **not** posted to the ledger and do **not** affect account balances until the date is reached.
- Do **not** appear in the default transaction list (they are excluded alongside voided and superseded transactions).
- Are automatically posted on the scheduled date (or on the next app open after the date passes).
- An **info popup** is shown at save time when the user selects a future date: *"This transaction is dated in the future. It will be held as pending and posted on [date]."*

> **Schema implication:** Transactions require a `status` field with at least two values: `posted` and `pending`. The transition from `pending` to `posted` is handled by the same scheduler that processes recurring auto-posts.

---

### 5.8 Home Screen & Dashboard

The home screen is the primary surface the user sees on every app open. It provides an at-a-glance summary of the user's finances and quick access to the most frequent actions.

#### 5.8.1 Greeting

The home screen displays a personalised greeting: **"Hi, [display name]!"** where the display name is the optional text field configured in Settings (§5.4.5). If no display name is set, the greeting shows **"Hi!"** with no name.

#### 5.8.2 Financial Summary

The following summary figures are shown prominently:

| Element | Content | Notes |
|---------|---------|-------|
| **Net worth** | Sum of all included account balances (per §5.1.4) | Always reflects the current (latest) state. Currency formatting per locale. |
| **Current month income** | Sum of all income transactions posted in the currently selected month | Green-tinted or income-styled |
| **Current month expenses** | Sum of all expense transactions posted in the currently selected month | Red-tinted or expense-styled |
| **Current month net** | Income − Expenses for the selected month | Positive = surplus, negative = deficit |

Net worth is **not** affected by the month selector — it always shows the current total. The income, expense, and net figures shift when the user changes the selected month.

**v2 additions:** Net worth graph over time; budget-at-a-glance widget; analytics summary.

#### 5.8.3 Month Selector

A **left/right arrow selector** allows the user to navigate between months. The selected month controls:
- The income / expense / net summary figures (§5.8.2).
- The transaction list shown on the home screen (§5.8.4).

The selector does **not** affect the net worth figure. The default selected month is the **current calendar month**. Navigation to future months is allowed (will show pending transactions if any exist).

#### 5.8.4 Transaction List

The home screen includes a **transaction list filtered to the selected month**. This list follows the same display rules as the unified transaction list (§5.2.1): 3-column layout, date-grouped, date-descending, amount colour coding.

**Search and filter** controls are accessible from this list — they operate on the currently displayed (month-filtered) set. The search and filter behaviour is identical to §5.2.5 and §5.2.6, applied on top of the month filter.

#### 5.8.5 Alerts

The home screen includes an **alerts section** that surfaces actionable in-app notifications. Alerts are displayed as a compact list or card strip above the transaction list.

**v1 alert types:**

| Alert type | Trigger | Content | Action |
|------------|---------|---------|--------|
| **Pending recurring confirmation** | A "remind and confirm" recurring template (§5.2.7) has a scheduled occurrence awaiting user confirmation | Template name, scheduled date, amount, account, category | Confirm (post), Edit before confirming, Dismiss (skips this occurrence) |
| **Credit card payment due** | A credit card payment reminder fires per the notification schedule in §5.1.7 | Card name, amount due, due date | Opens the credit card payment entry form (§5.1.7) |
| **Backup reminder** | First month of use or first 50 transactions reached, and no backup has been taken (§5.4.10) | One-time reminder to back up data | Navigate to Settings > Backup |

Alerts are **also delivered as OS-level local notifications** (for recurring confirmations per §5.2.7 and credit card reminders per §5.1.7). The home screen alerts section mirrors these in-app so the user sees them even if they dismissed the OS notification.

**Alert dismissal:** Pending recurring confirmations remain in the alerts section until acted upon (confirmed, edited, or dismissed) or auto-approved after 24 hours. Credit card payment alerts clear once the due date passes or a payment is recorded. The backup reminder clears once a backup is taken or the user explicitly dismisses it (shown only once).

**Pending Confirmations screen:** A dedicated **Pending Confirmations** view showing all unconfirmed recurring occurrences is accessible from the app's navigation overflow menu (e.g., "More options" in the nav bar). This screen shows the same information as the home screen alert cards but as a full list, allowing bulk review. Each item supports: Confirm, Edit before confirming, and Dismiss.

#### 5.8.6 Quick Entry

A **quick-entry FAB** (Floating Action Button) is present on the home screen for creating new transactions. Exact design (single FAB, speed dial with income/expense/transfer split, etc.) is deferred to UX Flows (UX-2).

---

## 6. Non-Functional Requirements

| ID    | Category | Requirement |
|-------|----------|-------------|
| NF-1  | Privacy | Zero telemetry. The app never initiates a network call for any core functionality. OS-level **local** notifications are used for recurring "remind and confirm" prompts (§5.2.7) — these are entirely on-device and require `POST_NOTIFICATIONS` (Android 13+) and `SCHEDULE_EXACT_ALARM` permissions. No cloud push infrastructure is involved. |
| NF-2  | Offline-first | All core v1 functionality operates with zero internet. Internet will be used only for future opt-in features (exchange rate sync, Drive backup), fetched opportunistically in the background. |
| NF-3  | Performance | Cold start < 2 seconds on mid-range hardware. Transaction list render (10,000 records) < 500ms. |
| NF-4  | Data portability | Data stored in a portable, standard format. Format decision deferred to SDS. |
| NF-5  | Accessibility | Material 3 accessibility conventions; WCAG 2.1 AA baseline. |
| NF-6  | Licensing | MIT License. All third-party dependencies must be permissively licensed (MIT, Apache 2.0, MPL 2.0). |
| NF-7  | Installability | Distributed as APK and/or Google Play. No account required to install or use. |
| NF-8  | Data durability | All writes are ACID-compliant. No data loss on crash or force-close. |
| NF-9  | Platform | Android only. Minimum API 31 (Android 12). Target: latest stable release. |
| NF-10 | Design system | Material You (Material Design 3). Dynamic color on API 31+; seed color fallback. |
| NF-11 | Self-contained | All assets (fonts, icons, category data, ISO currency list) bundled. No external asset calls. |

---

## 7. Multi-Currency Model (v1)

In v1, each account holds a currency. The app maintains a home currency (set in settings). When displaying net worth across accounts of different currencies:

- Conversion uses a **cached exchange rate** fetched opportunistically in the background (once daily when internet is available).
- The cached rate is stored locally. If no fresh rate is available, the most recent cached rate is used.
- A **staleness indicator** is shown when the cached rate is older than **14 days**. The indicator text reads: "This value may be inaccurate as the exchange rate has not been updated recently." The indicator appears in the net worth view.
- In the absence of any cached rate (e.g., first launch, no internet ever), the app falls back to displaying each currency balance separately or shows a disclaimer.
- Exchange rate updates are entirely optional and non-blocking — the app functions without them.

**Currency symbol disambiguation (FG-C13):**
When the user has accounts in two or more currencies that share the same display symbol (e.g., "$" for USD, SGD, AUD; "£" for GBP and others), the app displays the **3-letter ISO 4217 code** alongside the symbol in all views where both currencies appear in context — including the account list, net worth view, transaction list, and transaction detail view. If only one currency with that symbol is in use, the symbol alone is sufficient. The disambiguation is automatic and requires no user action.

**Cross-currency transfers:**
- In v1, **transfers between accounts of different currencies are disallowed**. The UI must prevent the user from selecting a destination account whose currency differs from the source account during a transfer. This constraint is deferred for resolution in v2.

### 7.1 Transaction-Level Exchange Rate Capture

When a transaction is created against an account whose currency differs from the home currency, the app captures the current cached exchange rate at the time of creation and **stores it with the transaction**. This rate is locked — it does not change with subsequent rate updates.

**Display in the unified transaction list (Q76):**
- Amounts are shown in **both** the original account currency and the home currency equivalent.
- The home currency equivalent is computed from the stored transaction-level exchange rate (not the current cached rate).
- The exchange rate itself is shown in the **transaction detail view** (not in the list row).

**Net worth vs. transaction display:**
- **Net worth** uses the **current/cached rate** (§7 above) because net worth should reflect current market value.
- **Individual transaction amounts** use the **historical stored rate** because the economic value at the time of the transaction is fixed.

**Exchange rate estimate during transaction entry (FG-C12):**
When recording a transaction against an account whose currency differs from the home currency, the app displays a **real-time home currency estimate** below the amount field: *"≈ [home currency symbol][estimated amount]"*. The estimate is computed from the current cached exchange rate. If the cached rate is **stale** (older than 14 days, per the staleness threshold defined in §7), a warning icon and label are shown alongside the estimate: *"⚠ Rate may be outdated"*. If no cached rate is available at all, the estimate is omitted and a note is shown: *"Exchange rate unavailable."* This is purely informational — the estimate does not affect the posted transaction amount.

**Schema implication:** Transactions require an `exchange_rate_to_home` field (nullable — only set when account currency ≠ home currency). When set, the home currency equivalent is `amount × exchange_rate_to_home`.

> Full exchange rate fetching model will be specified in SDS. This is an internet-optional feature even in v1.

---

## 8. In-Scope vs. Out-of-Scope

### ✅ In Scope — v1

- Double-entry ledger engine (internal)
- Account CRUD (soft delete, reinstatement) with 8 fixed account category types and per-type fields; account name uniqueness enforced across active and soft-deleted accounts
- Per-account net-worth inclusion flag
- Transaction entry: income, expense, transfer (abstract DEB UI); title and description replace notes on transactions
- Transaction immutability: correcting entries for amount, account, and category edits; reversing entries on delete; only final corrected version visible in list
- Two-level transaction category taxonomy (income and expense), user-manageable; icon (from `material_symbols_icons` curated subset) + name fields only; two-level management UX; name uniqueness within parent; alphabetical display order
- Protected "Balance Adjustment" system category (fully immutable, hidden from management)
- Protected entity pattern (`is_protected` flag) for system-managed categories and accounts
- Transaction category migration on soft-delete (move transactions to another category)
- Universal account balance model (direct balance edit, recorded transaction, delete reversal) — applies to all account types
- Unified transaction list (all accounts, 3-column layout) + per-account transaction list via account detail
- Fuzzy search across all transaction fields
- Dedicated filter view with defined filter criteria
- Recurring transactions with configurable N-unit recurrence, posting behaviour, pause/unpause
- OS-level local notifications for "remind and confirm" recurring transactions (auto-approve after 24h)
- Installments as a recurring sub-type with total/per-period amount, adjustment, and 4-way running total tracking
- Child transaction "manually handled" marking on templates
- Multiple photo attachments per transaction (local private storage)
- Future-dated transactions held as pending until scheduled date
- Transaction timestamps stored in UTC, displayed in local timezone
- Transaction-level exchange rate capture (locked at creation time) for foreign-currency accounts
- Home screen dashboard: greeting, net worth, monthly income/expense/net summary, month-filtered transaction list, search and filter, alerts, quick-entry FAB (§5.8)
- First-launch onboarding wizard (currency selection, first account creation, feature highlights)
- Default category seeding on first install
- Settings: appearance (Material You), primary config, security (device lock / PIN with configurable scope and timeout), management, about
- Multi-currency accounts with cached exchange rates (opportunistic background fetch)
- Multi-currency display: both original and home currency amounts in transaction list
- Universal soft-delete: no entity is ever permanently deleted
- Internal equity account for initial balance (invisible to user)
- System-generated internal transfer on account soft-delete (with warning on deletion)
- **Universal balance formula**: all accounts use `balance = Σdebit − Σcredit`; asset/liability state inferred from sign (positive = asset, negative = liability); no explicit direction field
- **Account currency immutability** with confirmation UX at account creation; defaults to home currency
- **Negative balance visual treatment** (colour-coded) and non-blocking overdraft warning
- **Credit card two-balance model**: outstanding balance (live ledger) and statement balance (derived from billing period); two distinct balance-edit actions
- **Credit card payment reminder system**: automatic local notifications on billing/payment cycle; Pay FAB on credit card detail screen; payment entry form with pre-filled source account if linked
- **Recurring/installment template handling on account or category soft-delete**: blocking warning with migrate or stop options; default stop
- **Date/time as in-place editable field** on transactions (no correcting entries)
- **Transaction amount colour coding** — green for income, red for expense, neutral for transfer; distinguishes Balance Adjustment income vs. expense entries (FG-A24)
- **Transaction list default sort** — date descending (most recent first); custom sort (date asc, amount asc/desc) via filter window (FG-A16)
- **Transaction filter** — amount range criterion (min/max, inclusive bounds); all criteria combined with AND logic; multi-select on category and subcategory; simple filter view (FG-A12, FG-A13)
- **Filter state** — does not persist across navigation; clears on leaving the transaction list (FG-A14)
- **fzf-style fuzzy search** — typo-tolerant, substring, nearest-substring, exact string match; amount search = exact value only (FG-A15)
- **Transfer fee** — optional flat amount or percentage fee on any transfer transaction; fee posted as linked expense (Financial > Fees & Charges); compound transaction shown as single entry in list; fee detail in detail view (FG-A27)
- **Loan account installment suggestion** — contextual post-save nudge to create recurring installment template when loan opens in liability state or EMI fields are provided (FG-A28)
- **Security scope** — lock applies to sensitive account detail fields only; basic app functionality never gated; PIN recovery via device security; 5-consecutive-fail lockout (1 hour); 15-cumulative-fail encrypted field deletion (FG-A22, FG-A23)
- **Font scaling** — UI adapts to Android system font scale (FG-A30)
- **RTL layout** — right-to-left layout mirroring via Flutter Directionality (FG-A30)
- **TalkBack labelling** — best-effort semantic labelling of interactive elements (FG-A30)
- **Local data backup** — export all data (transactions, accounts, categories, templates, photos) as zip archive via system file picker; one-time backup reminder after first month / 50 transactions (FG-A31)
- **Net worth excluded accounts** — shown grayed-out inline below the net worth contributors (FG-A26)
- **Soft-deleted category in transaction edit** — current selection always shown even if deleted; re-selectable to cancel accidental edits; hidden from picker for transactions with active categories (FG-A25)
- **Account deletion — no same-currency account** — skips transfer offer if no same-currency account exists; goes directly to net worth warning (FG-A29)
- **Transaction detail view** — full detail screen on tap: amount, date/time, type, account, category, description, fee breakdown, photo carousel, contextual menu; v2 additions (correction history, recurring link, installment status) noted (FG-B1)
- **Home screen dashboard** — personalised greeting (display name from Settings), net worth, current month income/expense/net, month selector for transaction list, search and filter, alerts section, quick-entry FAB (FG-B2)
- **Home screen alerts** — pending recurring confirmations, credit card payment due reminders, one-time backup reminder; alerts section + dedicated Pending Confirmations screen via nav overflow (FG-B4)
- **Category usage count on deletion** — informational count of active transactions shown before soft-delete proceeds; must be efficient (single aggregate query) (FG-B5)
- **Installment early close** — "Mark series as complete" with optional final lump-sum payment; mismatch warning with option to update target total (FG-B7)
- **Per-account settings clarified** — "per-account settings" = account edit form, accessible from Settings > Accounts and from account contextual menu; no additional settings (FG-B8)
- **Soft-deleted account behaviour** — frozen state (no new/edited transactions); hidden from pickers; historical transactions remain visible and searchable; included in filter account picker; does not extend to voided transactions (FG-B9)
- **Soft-deleted categories in filter** — soft-deleted categories visible in filter dropdowns for historical transaction lookup (updated alongside FG-B9)
- **Duplicate transaction detection** — non-blocking warning when a transaction with the same type, amount, account, and category exists on the same day (FG-C2)
- **Balance reconciliation** — "Reconcile" action on all accounts: enter actual balance, app computes discrepancy, posts journal adjustment via standard flow (FG-C6)
- **Indian numbering format (lakh/crore)** — 2-2-3 grouping explicitly supported; default inferred from device locale; currency formatting configurable in Settings (FG-C11)
- **Exchange rate estimate during transaction entry** — home currency estimate shown below amount field for foreign-currency accounts; staleness warning if rate is older than 14 days (FG-C12)
- **Currency symbol disambiguation** — 3-letter ISO code shown alongside symbol when multiple accounts share the same currency symbol (FG-C13)
- **Large transaction warning** — per-account and per-category configurable warning thresholds; non-blocking confirmation when exceeded. Credit card limit warning when expense exceeds configured credit limit (FG-C18)
- **Back button behaviour** — configurable: ask before discarding (default), auto-save as draft, or discard immediately (FG-C20)

### 🔄 Deferred — v2

- **Split transactions** — recording a single bill/payment split across multiple categories (e.g., one supermarket receipt split as Groceries + Toiletries + Snacks). One transaction per split at the ledger level; UI and edit flows to be designed in v2.
- **Budgeting** (total + per-category budgets, multi-horizon, configurable rollover, alerts, income replenishment) — to be redesigned alongside savings goals. Also covers: FG-A17 (budget creation fields), FG-A18 (budget currency), FG-A19 (budget period start day), FG-A20 (budget rollover and overspend), FG-A21 (budget transaction counting).
- Savings goals
- **Advanced filter mode** — predicate builder with AND/OR/NOT operators (FG-A13)
- **Saved filter profiles** — naming and persisting a filter configuration for repeated use (FG-A14)
- **Local backup import / restore** — restoring data from a v1 backup zip (FG-A31)
- **Cloud backup and sync** (Google Drive or similar) (FG-A31)
- **Comprehensive TalkBack / screen reader coverage** — exhaustive a11y labelling for complex widgets (FG-A30)
- Account and category manual reordering
- Recurring template disable/enable (with backfill option)
- Subcategory parent reassignment
- Trends, dashboards, charts, analytics, visualisations
- Data management: CSV export, CSV import, data wipe
- Audit view (surfaces all transactions including voided and journal adjustments)
- Tags (color, name, icon; assignable to transactions; filterable and searchable)
- Cross-currency transfer fee handling (deferred with cross-currency transfers to v2)
- **Transaction detail view v2 additions** — correction history, recurring template link, installment/loan status (FG-B1)
- **Home screen v2 additions** — net worth graph over time, budget-at-a-glance widget, analytics summary (FG-B2)
- **Combined search + filter** — search and filter operating simultaneously; deferred with advanced filter mode (FG-C4)
- **Balance history / mini chart per account** — per-account balance over time visualisation; deferred with analytics (FG-C5)
- **Budget period start day configuration** — user-configurable budget month start day for non-1st pay cycles; deferred with budgets (FG-C8)
- **Income categories in budget context** — income budgets / savings targets; deferred with budgets (FG-C9)
- **App data wipe / factory reset** — clear all data without uninstalling; deferred with data management (FG-C10)
- **Account statement export** — basic share-as-text/PDF per-account transaction history; deferred with CSV export (FG-C14)
- **Auto-detect transactions from SMS and email notifications** — automatically detect and record transactions from UPI/credit card SMS and email notifications; pattern matching, merchant detection, permission management; major v2 feature (FG-C21)

### 🔄 Deferred — v3 (or later)

- ML insights and predictions
- OCR receipt capture
- Exchange rate update infrastructure (if not landed in v2)
- Google Drive backup
- **Android home screen widget** — glanceable finance widget showing key figures; privacy concern (widget visible on lock screen without PIN) to be resolved (FG-C7)

### ❌ Permanently Out of Scope

| Feature | Rationale |
|---------|-----------|
| Cloud sync / multi-device | Privacy. Never. |
| Bank API / Open Banking | Privacy and security. Never. |
| Cryptocurrency tracking | Out of scope. Never. |
| Multi-user / household | Out of scope. Never. |
| Ads, telemetry, analytics | Fundamental constraint. Never. |
| Desktop / Web / iOS | Android only. Never. |

---

## 9. Success and Failure Criteria

### Success Criteria

| ID | Criterion |
|----|-----------|
| SC-1 | User can record an expense transaction in < 30 seconds from cold app open. |
| SC-2 | Ledger invariant holds: $\sum \text{debit}(T) = \sum \text{credit}(T)$ for every posted transaction, verifiable by automated test. |
| SC-3 | Account balances are always consistent with ledger — no stale stored balance. |
| SC-4 | *(Deferred to v2 — budget views)* |
| SC-5 | No uninstructed network call is made during normal app use (verifiable via Android network profiler). |
| SC-6 | App cold-starts in < 2 seconds on mid-range Android 12+ hardware. |
| SC-7 | Data survives forced-kill: no transaction is lost after force-closing the app. |
| SC-8 | Security lock prevents access to sensitive account detail fields without correct PIN or biometric; basic app functionality remains accessible at all times. |

### Failure Criteria

| ID | Criterion |
|----|-----------|
| FC-1 | Any uninstructed network call at runtime. |
| FC-2 | Data loss on crash or force-close. |
| FC-3 | Any posted transaction leaves the ledger imbalanced. |
| FC-4 | Permanent deletion of any transaction, account, or category. |
| FC-5 | Any proprietary or non-permissive dependency introduced. |
| FC-6 | Any core feature requires internet to function. |

---

## 10. Assumptions and Constraints

### Assumptions

- A1: The primary user is an individual managing personal finances, not a business entity.
- A2: No accounting knowledge is required. DEB is fully abstracted from the user.
- A3: All data lives on one Android device permanently. No sync mechanism.
- A4: The user manages exchange rates passively — the app handles caching opportunistically.
- A5: Tech stack is Flutter/Dart (inferred from project conventions). To be confirmed in SDS.
- A6: Distributed via GitHub (open source) and optionally via Google Play.

### Constraints

- C1: **Offline-first** — All core functionality works with zero internet. Internet used only for future opt-in features.
- C2: **Zero Cost** — No paid dependencies, services, or tooling.
- C3: **Open Source Only** — All dependencies permissively licensed.
- C4: **No Ads / Monetization** — No advertising, paywalls, or freemium gating. Ever.
- C5: **Self-contained** — All assets, fonts, icons, and seed data bundled.
- C6: **Android Only** — No other platform in scope.
- C7: **MIT License** — Project and all produced code are MIT licensed.
- C8: **Universal Soft-Delete** — No entity (transaction, account, category) is ever permanently deleted. All deletes are soft.

---

## 11. Open Questions

> **All questions Q1–Q76 are resolved.** All resolutions are baked into the document body. The full resolved questions log is in `docs/06-helpers/ideation-tracker.md`. Open UX design decisions (UX-1 through UX-14) are tracked in `docs/06-helpers/gaps-and-questions.md`.
>
> Feature gaps FG-A1 through FG-A31, FG-B1 through FG-B9, and FG-C1 through FG-C21 are all resolved. FG-B3 and FG-B6 deferred with budgets to v2. FG-C1, C15, C19 rejected. FG-C7 deferred to v3. FG-C4, C5, C8, C9, C10, C14, C21 deferred to v2. Remaining FG-C items baked into the PRD as v1 features. All v2-deferred decisions are consolidated in `docs/01-product/prd-v2-draft.md`. The PRD feature gap analysis is complete. UX design decisions (UX-1 through UX-14) and ERR-1 remain open.
