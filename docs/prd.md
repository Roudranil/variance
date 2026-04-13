# Product Requirements Document (PRD)
## Variance — Personal Finance & Expense Tracker

| Field        | Value          |
|-------------|----------------|
| Version      | 0.2.3          |
| Status       | 🟡 In Review   |
| Phase        | Ideation       |
| Author       | PM Agent       |
| Last Updated | 2026-04-12     |

---

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
| **v1** | Core: accounts, transactions, categories, budgets, recurring transactions, installments, settings, home summary |
| **v2** | Advanced: trends, dashboards, analytics, data management (backup/restore, CSV), savings goals, tags, audit view |
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

The user records transactions as income, expense, or transfer. All transactions are immutable — edits to financial fields post correcting entries. The user manages a two-level taxonomy of transaction categories (category → subcategory) separately for income and expense. All deletions are soft deletes.

### UC-3: View and Manage Budgets

The user defines a total budget and per-category budgets across multiple time horizons. Budget pools track remaining amounts in real time. Income transactions can manually replenish a budget pool. In-app alerts fire at configurable thresholds.

---

## 4. Core Model: Double-Entry Bookkeeping

> This section defines the financial model. It informs the SDS. The UI never exposes this model directly.

### 4.1 Core Invariant

For every transaction $T$:

$$\sum \text{debit}(T) = \sum \text{credit}(T)$$

### 4.2 Accounting Equation

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

$$\text{Assets} = \text{Liabilities} + \text{Income} - \text{Expenses}$$

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
- At least one expense category entry (credit side)
- At least one account entry (debit side, the source of funds)

**Income:**
- At least one account entry (debit side, where funds land)
- At least one income category entry (credit side)

**Transfer:**
- Only account entries (no category entries)
- Source account is credited; destination account is debited

### 4.6 Balance Calculation by Account Type

**Asset accounts** (Cash, Bank Account, Debit Card, Top-Up Wallet, Loan-as-asset, Investment):
$$\text{balance} = \sum \text{debit} - \sum \text{credit}$$

**Liability accounts** (Credit Card, Loan-as-liability):
$$\text{balance} = \sum \text{credit} - \sum \text{debit}$$

**Income/Expense categories** (internal, not user-visible as "accounts"):
- Income: $\text{balance} = \sum \text{credit} - \sum \text{debit}$
- Expense: $\text{balance} = \sum \text{debit} - \sum \text{credit}$

### 4.7 Transaction Validity

A transaction is valid if and only if:
- It is balanced ($\sum \text{debit} = \sum \text{credit}$)
- All amounts > 0
- Exclusivity constraint holds for every entry
- Type rules are satisfied

### 4.8 Immutability & Correction Model

- All posted transactions are **permanently immutable**.
- Correcting a transaction's financial fields — including **amount, account, and category** — posts a **new reversing transaction** (negates the original) followed by a **new corrected transaction**. This is consistent with Cases 1.4 and 1.5 in `docs/ledger-entry.md`, where the corrected entry already uses EC' and IC' to represent a changed category.
- **In-place edits are limited to: title, description, and photos only.** These fields carry no ledger significance.
- **Soft delete** of a transaction posts an automatic reversing entry to neutralise it. The original transaction record is retained.
- No entity (transaction, account, category) is ever permanently deleted.

### 4.9 Initial Balance & Equity Account

When an account is created with an initial balance, the system implicitly posts a transaction against an internal **Opening Balance equity account** (EQ). This equity account is **never visible to the user under any circumstances** — it does not appear in any user-facing views, account lists, or reports.

**EQ posting direction by account type:**
- Asset account with initial balance B: `Dr A, Cr EQ` → A balance ↑ B, EQ credit balance ↑ B.
- Liability account with initial balance B: `Dr EQ, Cr L` → L balance ↑ B, EQ debit balance ↑ B (net EQ credit balance ↓ B).

EQ supports bidirectional postings: credited for asset openings, debited for liability openings.

**EQ and net worth — mathematical treatment:**

The DEB accounting equation is:

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

EQ tracks the net equity injected to establish opening balances. If EQ were included in the net worth calculation:

$$\text{Net Worth (wrong)} = \text{Assets} - \text{Liabilities} + \text{EQ}$$

Since $\text{EQ} = \text{Assets} - \text{Liabilities}$ (from the accounting equation):

$$= (\text{Assets} - \text{Liabilities}) + (\text{Assets} - \text{Liabilities}) = 2 \times (\text{Assets} - \text{Liabilities})$$

This double-counts. **EQ must therefore be excluded from net worth.**

The correct net worth formula is:

$$\text{Net Worth} = \text{Assets} - \text{Liabilities}$$

EQ exists solely to balance opening-balance transactions. It has no economic meaning in a personal finance context and is never surfaced to the user.

### 4.10 Journal Adjustments

When a user directly edits an account's balance, the system posts a **journal adjustment transaction**. The user is prompted: *"Record this balance change as income/expense?"*

- If **Yes**: The adjustment is categorised under the protected **"Balance Adjustment"** system category and is visible in the transaction list.
- If **No**: The adjustment is an invisible internal entry retained for ledger integrity. It is not visible in normal views but surfaces in the v2 audit view.

**Income/expense direction for liability account adjustments:**
- Liability balance **increases** (more owed — e.g., interest charged, fee levied): classified as **expense** (`Dr BAE, Cr L`).
- Liability balance **decreases** (less owed without a transfer — e.g., debt forgiven or written off): classified as **income** (`Dr L, Cr BAI`).

### 4.11 Ledger Posting Cases (Reference)

All system events that produce ledger entries are fully enumerated in `docs/ledger-entry.md`, which is the authoritative posting case reference for SDS design. The compact summary is reproduced here.

**Notation:** A = asset account · L = liability account · IC = income category · EC = expense category · EQ = internal equity account · BAI/BAE = Balance Adjustment income/expense category.

| # | Event | Ledger Entries | Entries Posted |
|---|-------|----------------|----------------|
| 1.1 | Create Expense | Dr EC, Cr A | 1 txn, 2 entries |
| 1.2 | Create Income | Dr A, Cr IC | 1 txn, 2 entries |
| 1.3 | Create Transfer | Dr A₂, Cr A₁ | 1 txn, 2 entries |
| 1.4 | Modify Expense (financial) | Reversing (Cr EC, Dr A) + Corrected (Dr EC', Cr A') | 2 txns, 4 entries |
| 1.5 | Modify Income (financial) | Reversing (Cr A, Dr IC) + Corrected (Dr A', Cr IC') | 2 txns, 4 entries |
| 1.6 | Modify Transfer (financial) | Reversing (Cr A₂, Dr A₁) + Corrected (Dr A₂', Cr A₁') | 2 txns, 4 entries |
| 1.7 | Soft-Delete Expense | Cr EC, Dr A | 1 txn, 2 entries |
| 1.8 | Soft-Delete Income | Cr A, Dr IC | 1 txn, 2 entries |
| 1.9 | Soft-Delete Transfer | Cr A₂, Dr A₁ | 1 txn, 2 entries |
| 2.1 | Create Account, balance = 0 | None | 0 |
| 2.2a | Create Asset Account, balance B > 0 | Dr A, Cr EQ | 1 txn, 2 entries |
| 2.2b | Create Liability Account, balance B > 0 | Dr EQ, Cr L | 1 txn, 2 entries |
| 2.3a | Edit Asset Balance ↑ → record as income | Dr A, Cr BAI | 1 txn, 2 entries |
| 2.3b | Edit Asset Balance ↓ → record as expense | Dr BAE, Cr A | 1 txn, 2 entries |
| 2.3c | Edit Liability Balance ↑ → record as expense | Dr BAE, Cr L | 1 txn, 2 entries |
| 2.3d | Edit Liability Balance ↓ → record as income | Dr L, Cr BAI | 1 txn, 2 entries |
| 2.4a | Edit Asset Balance ↑ → do NOT record | Dr A, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.4b | Edit Asset Balance ↓ → do NOT record | Dr EQ, Cr A | 1 txn, 2 entries (invisible) |
| 2.4c | Edit Liability Balance ↑ → do NOT record | Dr EQ, Cr L | 1 txn, 2 entries (invisible) |
| 2.4d | Edit Liability Balance ↓ → do NOT record | Dr L, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.5 | Soft-Delete Account | None | 0 |
| 3.1 | Recurring auto-post | Same as 1.1–1.3 | Same as type |
| 3.2 | Installment single post | Same as 1.1 or 1.2 | Same as type |
| 3.3 | Cross-currency Transfer | Disallowed in v1 — deferred to v2 | N/A |
| 3.4 | Correct a Journal Adjustment | Reversing + Corrected | 2 txns, 4 entries |
| 3.5 | Budget Replenishment | None (budget layer) | 0 |
| 3.6 | Category Soft-Delete | None | 0 |

> The posting model for liability accounts is complete. Cross-currency transfers are disallowed in v1. Full enumeration of all posting cases is in `docs/ledger-entry.md`, which is the authoritative reference for SDS schema design.

---

## 5. Functional Requirements (Feature Graph)

> Only **v1** features are defined here.
> Organized as: **PILLAR → FEATURE → SUB-FEATURE**

---

### 5.1 Account Management (CORE) — UC-1

#### 5.1.1 Account CRUD

**Create Account — Fields**

The Create Account form collects the following fields. Category-specific fields (see §5.1.2) are additionally displayed once the account category is selected.

| Field | Required | Default | Notes |
|-------|----------|---------|-------|
| Name | Yes | — | Must be unique across all accounts (see uniqueness constraint below). Free-form text. |
| Account category | Yes | — | Selected from the fixed set in §5.1.2. Determines which category-specific fields are shown. |
| Initial balance | Yes | 0 | Numeric amount. If > 0, an opening-balance ledger transaction is posted (see §4.9). |
| Currency | Yes | — | Selected from the bundled ISO 4217 list (see §5.4.2). |
| Include in net worth | Yes (boolean) | true | Controls whether this account's balance contributes to the net worth total (see §5.1.4). |
| Notes | No | — | Optional free-form text. Retained on accounts even though notes has been removed from transactions. |
| Category-specific fields | Varies | — | Additional fields per the selected account category (see §5.1.2). |

**Account Name Uniqueness Constraint**

Account names must be unique. No two accounts may share the same name. Whether this uniqueness constraint extends to soft-deleted accounts (i.e., whether a deleted account's name is still reserved) is an open question — see Q52.

**Edit**

Editable fields: name, notes, include-in-net-worth flag, and all category-specific fields. Account category itself is not editable after creation.

**Edit balance**: Posts a journal adjustment transaction (see §4.10 and §5.1.3).

**Delete**: Soft delete only. Account becomes hidden from all user-facing views. Ledger entries are retained. A soft-deleted account's balance is excluded from net worth. Hard delete and transaction migration to another account are deferred to a future version.
  - If the account has a non-zero balance at deletion time, the app presents a two-step flow:
    1. "Would you like to transfer the remaining balance to another account?" — if yes, a transfer transaction is posted (transaction type TBD — see Q49).
    2. If the user declines: "Deleting this account without transferring the balance will change your net worth. Are you sure?" — if confirmed, the soft-delete proceeds.
- Cannot delete the last remaining account.

#### 5.1.2 Account Categories (Fixed Set — No Custom Categories)

Account categories are a fixed, predefined set. Users cannot create, rename, or delete account categories.

| Category | Additional Fields |
|----------|-------------------|
| **Cash** | None |
| **Bank Account** | Bank name, account number (masked display), branch, IFSC |
| **Credit Card** | Card name, card number (hashed/masked), expiry date, CVV (hashed; security unlock required to reveal), billing date, payment due date, credit limit, linked bank account |
| **Debit Card** | Card name, card number (hashed/masked), expiry date, CVV (hashed; security unlock required to reveal), linked bank account |
| **Top-Up Wallet** | Wallet provider name, linked phone number |
| **Loan** | Lender/borrower name, principal amount, interest rate, EMI amount, EMI date, loan direction (asset — owed to me / liability — owed by me), due date |
| **Investment** | Investment type (FD, Mutual Fund, Stocks, PPF, NPS, Other), institution name, current value (manually entered — see §5.1.3 for balance model) |
| **Other** | None — generic miscellaneous account |

#### 5.1.3 Account Balance Model

This model applies to **all account types** — there is no functional difference between an Investment account and any other account type. The Investment category is distinct only in its name and its category-specific metadata fields (investment type, institution name, current value). All balance change mechanics described here are universal.

An account's balance changes in exactly three ways:

1. **Direct balance edit** (via edit account menu): System prompts — *"Record this change as a real transaction?"*
   - If Yes → posts a proper income/expense transaction with the protected **"Balance Adjustment"** category. Visible in transaction list. See §4.10 and Cases 2.3a–2.3d in `docs/ledger-entry.md` for the full posting logic by account type (asset vs. liability) and direction (balance up vs. balance down).
   - If No → posts an invisible journal adjustment against the internal equity account (EQ). Not visible in normal views. Surfaces in the v2 audit view. See Cases 2.4a–2.4d in `docs/ledger-entry.md`.
2. **Recorded transaction against this account**: A normal income/expense/transfer entry referencing this account. Displayed in the transaction list.
3. **Deletion (soft-delete) of an existing transaction**: Posts an invisible reversing entry to neutralise the original transaction's effect on the account balance. The reversal is not displayed in normal transaction views.

#### 5.1.4 Account Balance View

- Real-time computed balance per account (derived from ledger).
- Net worth view: sum of all balances for accounts where "include in net worth" is true and the account is not soft-deleted. Accounts flagged as excluded are shown separately or not shown.
- Balances respect the locale, number format, and currency settings.

#### 5.1.5 Internal Transfer

- A Transfer transaction atomically debits the destination account and credits the source account.
- Both entries post together or neither does.
- Transfers carry no transaction category.
- **Credit card payment**: When the destination account is a liability (e.g., paying a credit card bill), the posting is `Dr L, Cr A`. Debiting the liability account decreases the outstanding balance (less owed). This is the standard ledger treatment for liability account transfers.

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
| Title | ✅ | ✅ | ✅ | Optional. Short label for the transaction. See Q53 for display behaviour. |
| Description | ✅ | ✅ | ✅ | Optional. Long-form text. See Q54 for display behaviour. |
| Photo(s) | ✅ | ✅ | ✅ | Optional. Max 2 photos per transaction (see §5.2.3). |

> **Note:** "Notes" has been removed from transactions and replaced by two separate optional fields: **Title** and **Description**. Notes remains on **accounts** (see §5.1.1) — it was only removed from transactions.

#### 5.2.2 Transaction Immutability & Editing

- All posted transactions are immutable.
- **Editing amount, account, or category**: A reversing entry is posted (negating the original), followed by the corrected transaction. This applies equally to all three financial fields. A category change is treated identically to an account or amount change — it is a financial correction requiring a reversing + corrected pair. This is consistent with §4.8 and with Cases 1.4 and 1.5 in `docs/ledger-entry.md`, where the corrected entry already models a changed category (EC', IC').
- **In-place edits (no ledger posting)**: Title, description, and photos only. These fields carry no ledger significance and may be updated without generating new entries.
- **Soft delete**: The transaction is voided. A reversing entry is posted automatically. The original record is retained but excluded from all normal views and calculations. Voided transactions are surfaced in the v2 audit view.
- No transaction is ever permanently deleted.

#### 5.2.3 Photo Attachments

- A maximum of **2 photos** may be attached per transaction.
- Photos are stored in a dedicated app-private data folder on the device.
- Photos are not accessible from the OS gallery.
- When a transaction is soft-deleted (voided), all its attached photos are permanently deleted from storage.
- Photos are compressed before storage. Compression algorithm, target resolution, and quality threshold are deferred to SDS.

#### 5.2.4 Transaction Categories (Two-Level Hierarchy)

Categories and subcategories form a two-level tree — category → subcategory. No deeper nesting.

Separate trees exist for **Income** and **Expense**. Transfers have no category.

**Category fields:**
Each category (both parent and child) has exactly two fields:
- **Icon**: Selected from a bundled icon set. Source of icons TBD — see Q50 (partially addressed).
- **Name**: Free-form text label.
No other fields (colour, description, etc.) exist on categories.

**Category management UX:**
Category management is accessed from Settings (§5.4.4). The flow is:
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
- All categories and subcategories (default and user-created) may be: renamed, icon-changed (see Q50), reordered, and soft-deleted.
- A subcategory cannot be reassigned to a different parent category. The parent is fixed at creation.
- A parent category **cannot be deleted if it has any child subcategories**. The user must first soft-delete all children before the parent becomes deletable.
- **A leaf parent category** (a parent with no children) **can be soft-deleted at any time.**
- **A child category (subcategory) can be soft-deleted at any time**, regardless of whether active (non-voided) transactions reference it. This supersedes any prior constraint to the contrary.
- Soft-deleted categories are hidden from: filter dropdowns, and the category picker in new transaction entry. They are not available for selection when creating or editing a transaction.
- Existing (non-voided) transactions that reference a soft-deleted category continue to display that category's name exactly as it was at the time of the transaction. The soft-deleted category label is shown as-is in the transaction detail view.
- Whether a parent category with children can be soft-deleted (forcing all children to also be deleted) is an open question — see Q55. The current rule is: parent cannot be deleted if children exist.

**Protected system category — "Balance Adjustment":**
- Exists in both income and expense trees.
- Cannot be selected by the user when creating a transaction.
- Assigned automatically when a journal adjustment is recorded as income/expense.
- Visible in the transaction list when such transactions exist. Balance Adjustment transactions are **visually indistinguishable** from normal transactions in the list. Full UI treatment is deferred to UX Flows.
- Whether this category is exempt from the general mutability rules (rename, icon-change, soft-delete) is an open question — see Q51.

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
| Financial | Mobile Bill, WiFi Bill, Electricity Bill, Insurance, Tax, Investments, Other |
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

- Fuzzy search across all fields: date, amount, account name, category name, subcategory name, title, description, and any searchable metadata. Whether title and description are searched identically or with different weighting is deferred to UX Flows. See Q53 and Q54 for open questions on how title and description surface in the transaction list and detail views.

#### 5.2.6 Transaction Filtering

A dedicated filter view (separate from the main transaction list) provides filter controls. Supported filter criteria:

| Criterion | Notes |
|-----------|-------|
| Transaction type | Income / Expense / Transfer |
| Category | Contextual — only shows income categories for income filter, etc. |
| Subcategory | Contextual — filtered by the selected category |
| Account | One or more accounts |
| Date range | Absolute range or relative presets (this month, last 7 days, etc.) |
| Has photo | Boolean |
| Has title | Boolean |
| Has description | Boolean |
| Is recurring | Boolean |
| Is voided | Boolean — shows soft-deleted transactions |

Full UX specification deferred to UX Flows.

#### 5.2.7 Recurring Transactions

Users can define recurring transaction templates. Parameters:

- Transaction type, amount, account(s), category, title (optional), description (optional)
- **Recurrence definition**: $N$ units of a time unit, where unit ∈ { day, week, month, year }. E.g., "every 2 weeks", "every 3 months".
- **Optional recurrence constraints**: repeat on weekdays only / weekends only / start of month / end of month / start of year / end of year.
- Start date, optional end date.
- **Posting behaviour** (configurable per template):
  - **Auto-post**: Transaction is posted automatically on the scheduled date.
  - **Remind and confirm**: An in-app notification prompts the user to review and confirm before posting.
- When the end date passes or all installments are exhausted, the template is **automatically archived**.
- Archived templates **cannot be reactivated**. If the user wishes to resume a recurring pattern, they must create a new template.

**Child transaction editing and deletion:**
- Individual child transactions generated by a recurring or installment template are editable and soft-deletable like any other transaction.
- The existing correction model (reversing + corrected entries, Cases 1.4–1.9 in `docs/ledger-entry.md`) applies in full.
- Whether editing or soft-deleting a child transaction affects the parent template's state is an open question — see Q47 and Q48.

#### 5.2.8 Installments

Installments are a sub-type of recurring transaction representing a fixed total amount split across a defined set of periods.

Parameters:
- Total amount, recurrence definition (same as 5.2.7), number of installments (derived from total / recurrence, or manually set).
- The system auto-calculates the per-installment amount (total ÷ number of installments).
- The user may manually adjust individual installment amounts after the auto-calculation stage.
- If the sum of manually adjusted amounts does not equal the total amount, the app surfaces a **non-blocking warning at save time** of the payment plan. The user may still save and proceed.
- Whether installments are implemented as a tagged sub-type within the templates table or as a separate entity within that table is deferred to SDS schema design. The PRD treats installments as a distinct concept under the same template generation mechanism as recurring transactions.
- Whether editing or soft-deleting an individual installment child transaction affects the installment's running total tracking is an open question — see Q48.

---

### 5.3 Budgeting (CORE) — UC-3

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
- Alerts appear within the app only. No OS-level push notifications in v1.

#### 5.3.5 Budget Rollover

- Configurable per budget: whether unused remaining budget ($N$ at period end) carries forward to the next period.
- Defaults to off.

---

### 5.4 Settings & Customisation (CORE)

#### 5.4.1 Appearance

| Setting | Options |
|---------|---------|
| Theme | Light / Dark / System default |
| Color scheme | Material You dynamic color (from wallpaper, API 31+), or custom seed color |
| Font | Bundled curated font OR system default |
| Animations | Enable / Disable |

#### 5.4.2 Primary Configuration

| Setting | Notes |
|---------|-------|
| Currency | Selected from a bundled ISO 4217 list; sets symbol and locale format |
| Week start | Monday / Sunday |
| Time format | 12-hour / 24-hour |
| Number format | Decimal separator (comma or period), thousands grouping style |
| Percentage precision | 0, 1, or 2 decimal places for percentage display |

#### 5.4.3 Security

| Setting | Notes |
|---------|-------|
| App lock | PIN (set within the app) or biometric (fingerprint / face unlock) |
| Biometric fallback | If biometric fails: falls back to PIN |
| Sensitive field reveal | Viewing masked card fields (CVV, full card number) requires successful security authentication |

#### 5.4.4 Management

| Section | Contents |
|---------|----------|
| Accounts | View and manage all accounts, including soft-deleted; per-account settings |
| Transaction categories | Manage income and expense category and subcategory trees |
| Budgets | View, create, edit, and delete budget definitions |
| Recurring / Installments | Manage active and archived recurring transaction templates |

#### 5.4.5 About & Legal

| Section | Contents |
|---------|----------|
| Open-source licenses | Bundled OSS license acknowledgements |
| App version | Semantic version string |
| Acknowledgements | Credits and attributions |

---

### 5.5 Contextual Action Menus

Contextual action menus are accessible via long-tap, hamburger menu, or 3-dot menu on any list item (depending on the screen). They expose entity-specific actions that are not visible on the primary surface.

#### 5.5.1 Confirmed Contextual Menu Actions

The following contextual menus and their actions are confirmed by the founder:

| Entity | Contextual Actions |
|--------|-------------------|
| Transaction (normal) | Edit, Delete, Add to Budget |
| Account | Edit, Delete |
| Parent category (in category management) | Edit, Delete, Add Child Category |

#### 5.5.2 Unresolved Contextual Menu Cases

The following entities may also need contextual action menus. Each is an open question. The founder identified that he felt he was missing cases — the full list is surfaced here for resolution.

| Entity | Open Question ID | Candidate Actions (unconfirmed) |
|--------|-----------------|--------------------------------|
| Child/subcategory entry | Q56 | Edit, Delete — but no "Add Child" since max depth is 2. Confirm? |
| Recurring transaction template (active) | Q57 | Edit template, Delete template, Pause/Disable template (is pause a feature?), View generated child transactions? |
| Individual child transaction in a recurring series | Q58 | Same as normal transaction (Edit, Delete, Add to Budget)? Can "Add to Budget" be applied to a recurring child? |
| Budget entry | Q59 | Edit budget, Delete budget — is there a contextual menu or are these only accessible from the budget detail screen? |
| Photo attachment on a transaction | Q60 | View full screen, Delete photo — is there a contextual menu on individual photos? |
| Transaction already added to a budget | Q61 | Once a transaction has been added to a budget, can it be removed? Is there a "Remove from Budget" action? |
| Voided transaction (visible in v2 audit view) | Q62 | What actions are available on a voided transaction? Can the user un-void a transaction? |
| Installment series template | Q63 | Edit template, Delete template — same questions as recurring template (Q57). Any installment-specific actions? |

---

## 6. Non-Functional Requirements

| ID    | Category | Requirement |
|-------|----------|-------------|
| NF-1  | Privacy | Zero telemetry. The app never initiates a network call for any core functionality. |
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

**Cross-currency transfers:**
- In v1, **transfers between accounts of different currencies are disallowed**. The UI must prevent the user from selecting a destination account whose currency differs from the source account during a transfer. This constraint is deferred for resolution in v2.

> Full exchange rate fetching model will be specified in SDS. This is an internet-optional feature even in v1.

---

## 8. In-Scope vs. Out-of-Scope

### ✅ In Scope — v1

- Double-entry ledger engine (internal)
- Account CRUD (soft delete) with 8 fixed account category types and per-type fields; account name uniqueness enforced
- Per-account net-worth inclusion flag
- Transaction entry: income, expense, transfer (abstract DEB UI); title and description replace notes on transactions
- Transaction immutability: correcting entries for amount, account, and category edits; reversing entries on delete
- Two-level transaction category taxonomy (income and expense), user-manageable; icon + name fields only; two-level management UX; name uniqueness within parent
- Protected "Balance Adjustment" system category
- Universal account balance model (direct balance edit, recorded transaction, delete reversal) — applies to all account types
- Fuzzy search across all transaction fields
- Dedicated filter view with defined filter criteria
- Recurring transactions with configurable N-unit recurrence and posting behaviour
- Installments as a recurring sub-type with total/per-period amount and adjustment
- Multiple photo attachments per transaction (local private storage)
- Budgeting: total + per-category budgets, multi-horizon, configurable rollover, alerts
- Income replenishment of budget pools via more-options
- Basic home summary (account balances, net worth)
- Settings: appearance (Material You), primary config, security (PIN + biometric), management, about
- Multi-currency accounts with cached exchange rates (opportunistic background fetch)
- Universal soft-delete: no entity is ever permanently deleted
- Internal equity account for initial balance (invisible to user)

### 🔄 Deferred — v2

- Trends, dashboards, charts, analytics, visualisations
- Savings goals
- Data management: backup/restore (portable file), CSV export, CSV import, data wipe
- Audit view (surfaces all transactions including voided and journal adjustments)
- Tags (color, name, icon; assignable to transactions; filterable and searchable)

### 🔄 Deferred — v3 (or later)

- ML insights and predictions
- OCR receipt capture
- Exchange rate update infrastructure (if not landed in v2)
- Google Drive backup

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
| SC-4 | Budget views render correctly across all four supported horizons (weekly, monthly, quarterly, annual). |
| SC-5 | No uninstructed network call is made during normal app use (verifiable via Android network profiler). |
| SC-6 | App cold-starts in < 2 seconds on mid-range Android 12+ hardware. |
| SC-7 | Data survives forced-kill: no transaction is lost after force-closing the app. |
| SC-8 | Security lock prevents access to app and sensitive fields without correct PIN or biometric. |

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

> All questions Q1–Q46 are resolved and baked into the document above. The resolved questions log is maintained in `docs/ideation-tracker.md`. The following questions (Q47–Q63) remain open and block downstream deliverables.

### Open Questions (Active)

#### Group A — Blocking UX Flows

| ID | Question | Blocks |
|----|----------|--------|
| Q47 | **Child transaction edit/delete — effect on recurring template**: When the user edits or soft-deletes an individual child transaction that was generated by a recurring template, does this affect the template in any way? For example: (a) mark that occurrence as "manually handled" so the scheduler skips it, (b) update the template's "last posted" pointer, or (c) no effect — the template is entirely unaware. This affects the scheduler design and UX affordances on the child transaction. | SDS, UX |
| Q48 | **Child transaction edit/delete — effect on installment running total**: An installment template tracks a running total of amounts posted across child transactions (Σ posted = target total). If a child transaction is soft-deleted (voided), should the voided amount be subtracted from the running total? If a child transaction's amount is edited (corrected), should the running total update to reflect the corrected amount? If not updated, the installment may never reach the target total via the tracker even though it was economically settled. | SDS, UX |
| Q49 | **Account soft-delete balance transfer transaction type**: When the user accepts the prompt to transfer their remaining account balance to another account as part of the soft-delete flow (resolved in Q45), what type of transaction is posted? Options: (a) a standard Transfer transaction between the two accounts (visible, user-owned), (b) a special system-generated transfer (internal, not user-editable), or (c) the user is dropped into the normal Transfer entry screen pre-populated. This affects both the UX flow and the ledger entry case. | SDS, UX |

#### Group B — Blocking SDS

| ID | Question | Blocks |
|----|----------|--------|
| Q50 | **Category icon system** (partially addressed): Q40 confirmed users can change the icon of any category. The founder confirmed in v0.2.3 that categories have an icon field. The source of icons is still unresolved. Options: (a) a bundled finite icon set (user picks from a predefined palette, e.g., Material Symbols subset), (b) any icon from the full Material Symbols / Material Icons library (large but bounded set), (c) user-provided images from device storage (unbounded, complex). This decision affects storage model, asset bundling strategy, and SDS. | SDS |
| Q51 | **"Balance Adjustment" protected category — exempt from mutability?**: Q40 confirmed all default categories are fully mutable (rename, icon-change, reorder, soft-delete). The "Balance Adjustment" category is a system-managed protected category (not user-selectable, assigned automatically). Is it exempt from the mutability rules? Specifically: can the user rename it, change its icon, or soft-delete it? Soft-deleting it would leave the system with no valid target for journal adjustment income/expense classification. | SDS, product policy |

#### Group C — Account Management (New — v0.2.3)

| ID | Question | Blocks |
|----|----------|--------|
| Q52 | **Account name uniqueness — does it extend to soft-deleted accounts?**: Account names must be unique (§5.1.1). Does this uniqueness constraint apply across soft-deleted accounts as well? That is, if an account named "HDFC Savings" is soft-deleted, can the user create a new account also named "HDFC Savings"? Options: (a) uniqueness applies to all accounts including soft-deleted — the name is permanently reserved; (b) uniqueness applies only to non-deleted (active) accounts — soft-deleted names are recyclable. | SDS, UX |

#### Group D — Transaction Fields (New — v0.2.3)

| ID | Question | Blocks |
|----|----------|--------|
| Q53 | **Transaction title — display behaviour**: The title field is optional. When present, does it appear as the primary label in the transaction list (replacing or supplementing the category name)? When absent, what label is shown in the list? Does title appear in search results as a primary or secondary field? | UX |
| Q54 | **Transaction description — display behaviour**: The description field is optional and may be long-form. Does description appear in the transaction list view, or only in the transaction detail view? Is there a character limit? If it appears in the list, is it truncated? | UX |

#### Group E — Category Management (New — v0.2.3)

| ID | Question | Blocks |
|----|----------|--------|
| Q55 | **Parent category with children — can it be soft-deleted en masse?**: The current rule is: a parent category cannot be soft-deleted if it has child subcategories. The user must soft-delete all children first, at which point the now-leaf parent can be deleted. Is this the final rule, or should the app offer a bulk "delete parent and all its children" action? | SDS, UX |

#### Group F — Contextual Action Menus (New — v0.2.3)

| ID | Question | Blocks |
|----|----------|--------|
| Q56 | **Subcategory contextual menu**: Does a child/subcategory entry in the category management screen have a contextual action menu? If yes, what are the actions? Expected: Edit, Delete. Confirm that "Add Child" is absent (max depth is 2 — subcategories cannot have their own children). | UX |
| Q57 | **Recurring template contextual menu**: What contextual actions are available on a recurring transaction template entry (in the Recurring / Installments management screen)? Confirmed candidates: Edit template, Delete template. Open sub-questions: (a) Is "Pause/Disable template" a feature (pauses auto-posting without deleting the template)? (b) Is there a "View generated child transactions" action? (c) Can a paused template be resumed? | SDS, UX |
| Q58 | **Child transaction of a recurring series — contextual menu**: Does an individual child transaction generated by a recurring template have the same contextual menu as a normal transaction (Edit, Delete, Add to Budget)? Specifically: is "Add to Budget" valid on a recurring child transaction? | UX |
| Q59 | **Budget entry contextual menu**: Is there a contextual action menu on a budget entry (in the budget list or budget detail screen)? If yes, what actions? Candidates: Edit budget, Delete budget. Or are these actions only accessible via a dedicated budget settings/detail screen? | UX |
| Q60 | **Photo attachment contextual menu**: When a user views photos attached to a transaction (in the transaction detail view), is there a contextual menu per photo? If yes, what actions? Candidates: View full-screen, Delete photo. | UX |
| Q61 | **"Remove from Budget" action**: Once a transaction has been added to a budget pool via "Add to Budget", can that association be reversed? Is there a "Remove from Budget" contextual action on the transaction? What happens to the budget pool's remaining balance if the transaction is removed? | SDS, UX |
| Q62 | **Voided transaction actions (v2 audit view)**: When voided transactions are surfaced in the v2 audit view, what contextual actions are available? Can the user un-void (restore) a transaction? If un-voiding is allowed, does the system simply remove the reversing entry, or does it post a new correcting pair? | SDS, UX |
| Q63 | **Installment series template contextual menu**: Same as Q57 but for installment templates. What contextual actions are available on an installment series template? Do installment templates have any actions unique to their nature (e.g., "View remaining installments", "Mark series as complete")? | SDS, UX |
