---
name: Product Requirements Document
status: in progress
owner: pm
created: 2026-04-13
last_updated: 2026-04-13
depends_on: []
outputs_to: [02-technical/sds.md, 02-technical/ux-flows.md, 02-technical/api-contracts.md, 03-planning/task-breakdown.md]
---

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
| **v1** | Core: accounts, transactions, categories, recurring transactions, installments, onboarding, settings, home summary |
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
- Correcting a transaction's financial fields — including **amount, account, and category** — posts a **new reversing transaction** (negates the original) followed by a **new corrected transaction**. This is consistent with Cases 1.4 and 1.5 in `docs/01-product/ledger-entry.md`, where the corrected entry already uses EC' and IC' to represent a changed category.
- **In-place edits are limited to: title, description, and photos only.** These fields carry no ledger significance.
- **Soft delete** of a transaction posts an automatic reversing entry to neutralise it. The original transaction record is retained.
- No entity (transaction, account, category) is ever permanently deleted.

### 4.9 Initial Balance & Equity Account

When an account is created with an initial balance, the system implicitly posts a transaction against an internal **Opening Balance equity account** (EQ). This equity account is **never visible to the user under any circumstances** — it does not appear in any user-facing views, account lists, or reports.

**EQ posting direction by account type:**
- Asset account with initial balance B: `Dr A, Cr EQ` -> A balance ↑ B, EQ credit balance ↑ B.
- Liability account with initial balance B: `Dr EQ, Cr L` -> L balance ↑ B, EQ debit balance ↑ B (net EQ credit balance ↓ B).

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

All system events that produce ledger entries are fully enumerated in `docs/01-product/ledger-entry.md`, which is the authoritative posting case reference for SDS design. The compact summary is reproduced here.

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
| 2.3a | Edit Asset Balance ↑ -> record as income | Dr A, Cr BAI | 1 txn, 2 entries |
| 2.3b | Edit Asset Balance ↓ -> record as expense | Dr BAE, Cr A | 1 txn, 2 entries |
| 2.3c | Edit Liability Balance ↑ -> record as expense | Dr BAE, Cr L | 1 txn, 2 entries |
| 2.3d | Edit Liability Balance ↓ -> record as income | Dr L, Cr BAI | 1 txn, 2 entries |
| 2.4a | Edit Asset Balance ↑ -> do NOT record | Dr A, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.4b | Edit Asset Balance ↓ -> do NOT record | Dr EQ, Cr A | 1 txn, 2 entries (invisible) |
| 2.4c | Edit Liability Balance ↑ -> do NOT record | Dr EQ, Cr L | 1 txn, 2 entries (invisible) |
| 2.4d | Edit Liability Balance ↓ -> do NOT record | Dr L, Cr EQ | 1 txn, 2 entries (invisible) |
| 2.5 | Soft-Delete Account | None | 0 |
| 3.1 | Recurring auto-post | Same as 1.1–1.3 | Same as type |
| 3.2 | Installment single post | Same as 1.1 or 1.2 | Same as type |
| 3.3 | Cross-currency Transfer | Disallowed in v1 — deferred to v2 | N/A |
| 3.4 | Correct a Journal Adjustment | Reversing + Corrected | 2 txns, 4 entries |
| 3.5 | Budget Replenishment | None (budget layer) | 0 |
| 3.6 | Category Soft-Delete | None | 0 |

> The posting model for liability accounts is complete. Cross-currency transfers are disallowed in v1. Full enumeration of all posting cases is in `docs/01-product/ledger-entry.md`, which is the authoritative reference for SDS schema design.

---

## 5. Functional Requirements (Feature Graph)

> Only **v1** features are defined here.
> Organized as: **PILLAR -> FEATURE -> SUB-FEATURE**

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

Account names must be unique across all accounts, **including soft-deleted accounts**. A soft-deleted account's name is permanently reserved and cannot be reused by a new account.

**Reinstatement of soft-deleted accounts:** When a user attempts to create a new account whose name and account category both match a soft-deleted account, the app displays a warning: *"It looks like you previously had an account with this name. Would you like to reinstate it instead?"* If the user accepts, the soft-deleted account is reinstated (its `is_deleted` flag is cleared). This is architecturally trivial: since balances are always computed from ledger entries (which are never deleted), the reinstated account's balance, transaction history, and net worth contribution are automatically correct with no recalculation. If the user declines, they must choose a different name.

The same reinstatement logic applies to soft-deleted categories (see §5.2.4).

**Edit**

Editable fields: name, notes, include-in-net-worth flag, and all category-specific fields. Account category itself is not editable after creation.

**Edit balance**: Posts a journal adjustment transaction (see §4.10 and §5.1.3).

**Delete**: Soft delete only. Account becomes hidden from all user-facing views. Ledger entries are retained. A soft-deleted account's balance is excluded from net worth. Hard delete and transaction migration to another account are deferred to a future version.
  - If the account has a non-zero balance at deletion time, the app presents a two-step flow:
    1. "Would you like to transfer the remaining balance to another account?" — if yes, the user selects a destination account and a **system-generated internal transfer** is posted. This transfer is visible in the transaction list but is marked as system-generated and is not user-editable. If the user later attempts to soft-delete this system transfer, the app warns: *"This transfer was created when you deleted [account name]. Voiding it will reduce your net worth because the source account is no longer active."*
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
   - If Yes -> posts a proper income/expense transaction with the protected **"Balance Adjustment"** category. Visible in transaction list. See §4.10 and Cases 2.3a–2.3d in `docs/01-product/ledger-entry.md` for the full posting logic by account type (asset vs. liability) and direction (balance up vs. balance down).
   - If No -> posts an invisible journal adjustment against the internal equity account (EQ). Not visible in normal views. Surfaces in the v2 audit view. See Cases 2.4a–2.4d in `docs/01-product/ledger-entry.md`.
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

**Grouping and ordering:** Transactions are grouped by date (date header per group). Within each date group, transactions are ordered by time (most recent first). The timestamp is not shown in the list row — it is revealed when the user taps the transaction to open the detail view.

**Transaction List Architecture:**
- The default view is a **unified transaction list** showing all transactions across all accounts.
- Soft-deleted (voided) transactions, unrealised future-dated transactions (see §5.7), and superseded versions of corrected transactions are excluded from the default list. Only the final corrected version is shown (see §5.2.2).
- A **per-account transaction list** is accessible from the account detail screen (tapping an account navigates to its detail view, which shows transactions filtered to that account).
- Balance adjustment transactions (§4.10): when the user chose "Yes" (record as income/expense), the transaction appears in the list with the Balance Adjustment category like any other transaction. When the user chose "No" (invisible journal entry), the transaction does **not** appear in the list — it is an internal ledger entry surfaced only in the v2 audit view. This is consistent with §4.10 and §5.1.3.

**Transaction Description Display:**
- Description appears **only in the transaction detail view**, never in the transaction list.
- Character limit is configurable in Settings (§5.4.2) from a predefined set: 500, 1000, or 2000 characters. Default: 1000.

#### 5.2.2 Transaction Immutability & Editing

- All posted transactions are immutable.
- **Editing amount, account, or category**: A reversing entry is posted (negating the original), followed by the corrected transaction. This applies equally to all three financial fields. A category change is treated identically to an account or amount change — it is a financial correction requiring a reversing + corrected pair. This is consistent with §4.8 and with Cases 1.4 and 1.5 in `docs/01-product/ledger-entry.md`, where the corrected entry already models a changed category (EC', IC').
- **Correction visibility:** Only the **final corrected transaction** is visible in the transaction list. The original transaction and its reversing entry are hidden as internal ledger entries — they maintain ledger integrity but are not shown in normal user-facing views. This preserves full DEB abstraction (§2, G2). The original and reversal are surfaced in the v2 audit view.
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

Categories and subcategories form a two-level tree — category -> subcategory. No deeper nesting.

Separate trees exist for **Income** and **Expense**. Transfers have no category.

**Category fields:**
Each category (both parent and child) has exactly two fields:
- **Icon**: Selected from the `material_symbols_icons` Flutter package (^4.2928.1 from pub.dev). The full icon set is large; a curated subset will be bundled for the category picker. The exact subset and bundling strategy (tree-shaking, selective import) are deferred to SDS for efficiency analysis.
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
- All categories and subcategories (default and user-created) may be: renamed, icon-changed, and soft-deleted. Manual reordering is deferred to v2; the default display order is alphabetical.
- A subcategory cannot be reassigned to a different parent category. The parent is fixed at creation.
- A parent category **cannot be deleted if it has any child subcategories**. The user must first soft-delete all children before the parent becomes deletable. Bulk "delete parent and all children" is not supported.
- **A leaf parent category** (a parent with no children) **can be soft-deleted at any time.**
- **A child category (subcategory) can be soft-deleted at any time**, regardless of whether active (non-voided) transactions reference it. This supersedes any prior constraint to the contrary.
- **Transaction migration on category deletion:** When a user initiates a category soft-delete, the app prompts: *"Would you like to migrate transactions from this category to another category?"*
  - **No migration (default):** Existing transactions retain the soft-deleted category label. The category is hidden from pickers and filters but the label persists on historical transactions.
  - **Yes — migrate all:** The user selects a destination category. All transactions referencing the deleted category are re-categorised to the destination (this is a financial edit — reversing + corrected entry pairs are posted per §4.8).
  - **Yes — choose specific transactions:** The user is presented with the list of transactions referencing the category and selects which ones to migrate. Selected transactions are re-categorised; unselected transactions retain the old category (same as "no migration" for those).
- Soft-deleted categories are hidden from: filter dropdowns, and the category picker in new transaction entry. They are not available for selection when creating or editing a transaction.
- Existing (non-voided) transactions that reference a soft-deleted category continue to display that category's name exactly as it was at the time of the transaction. The soft-deleted category label is shown as-is in the transaction detail view.
- **Reinstatement of soft-deleted categories:** The same reinstatement logic described in §5.1.1 for accounts applies to categories. When creating a new category whose name matches a soft-deleted category within the same tree and parent, the app offers to reinstate the deleted category instead. Category names must be unique including across soft-deleted categories.

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

- Fuzzy search across all fields: date, amount, account name, category name, subcategory name, title, description, and any searchable metadata. Whether title and description are searched identically or with different weighting is deferred to UX Flows. Title and description display behaviour is defined in §5.2.1 (transaction list display and description display sections).

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
  - **Remind and confirm**: An **OS-level local notification** prompts the user to review and confirm before posting. This requires `POST_NOTIFICATIONS` (Android 13+) and `SCHEDULE_EXACT_ALARM` permissions. No network call is involved — notifications are entirely on-device. If the user does not respond within **24 hours** of the scheduled time, the transaction is **auto-approved and posted**. The user can disable "remind and confirm" mode for all future occurrences of a template via the template's contextual menu (switching it to auto-post).
- **Pause / Unpause** (v1):
  - A recurring template can be **paused** for a specified duration: either M units of the template's time unit (e.g., "pause for 2 months" on a monthly template), or until a custom date and time.
  - While paused, no transactions are realised. Skipped occurrences **remain skipped** — they are not retroactively posted when the template resumes.
  - A paused template can be **unpaused** at any time (resumes from the next scheduled occurrence after the current date).
  - A template **cannot be paused indefinitely** — that is functionally equivalent to disabling, which is deferred to v2. The pause duration must have a defined end.
  - **Disable / Enable** (permanently stop and restart a template) is deferred to v2. In v2, re-enabling will prompt the user: realise only future transactions, or also backfill all transactions that would have been realised during the disabled period.
- When the end date passes or all installments are exhausted, the template is **automatically archived**.
- Archived templates **cannot be reactivated**. If the user wishes to resume a recurring pattern, they must create a new template.

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
| Description max length | Configurable character limit for transaction descriptions. Options: 500, 1000, 2000. Default: 1000. |

#### 5.4.3 Security

**Lock mechanism (hierarchical):**
1. **Device lock** (if set by the user at the OS level) — preferred. The app delegates authentication to the Android Keyguard.
2. **Device-set app-specific lock** (if the device supports per-app biometric lock) — secondary.
3. **In-app PIN** — fallback. If neither of the above is available, the app prompts the user to set a PIN within the app on first launch.

**Lock scope (user-configurable):**
- The user can choose between two modes:
  - **App-wide lock**: The entire app is locked. The user must authenticate to access any screen.
  - **Sensitive details only**: The app is freely accessible, but viewing sensitive account details (card numbers, CVV, account numbers, balances in account detail) requires authentication.

**Lock timing:**
- The lock activates on **app close or app minimisation** (backgrounding). The timeout before the lock engages is **user-configurable** (options: immediately, 30 seconds, 1 minute, 5 minutes).
- **Sensitive field authentication** is required regardless of the timeout setting. However, once the user authenticates to view sensitive details in a session, the details remain visible until the app is closed or minimised (the lock timeout resets the sensitive-details unlock as well).

| Setting | Notes |
|---------|-------|
| Lock mechanism | Device lock / device app-specific lock / in-app PIN (hierarchical fallback) |
| Lock scope | App-wide or sensitive details only (user-configurable) |
| Lock timeout | Immediately / 30s / 1m / 5m after app backgrounding (user-configurable) |
| Sensitive field reveal | Viewing masked card fields (CVV, full card number, account number) requires authentication within the current session |

#### 5.4.4 Management

| Section | Contents |
|---------|----------|
| Accounts | View and manage all accounts, including soft-deleted (with reinstatement option); per-account settings |
| Transaction categories | Manage income and expense category and subcategory trees (excluding protected system categories, which are hidden) |
| Recurring / Installments | Manage active, paused, and archived recurring transaction and installment templates |

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

| Entity | Contextual Actions | Notes |
|--------|-------------------|-------|
| **Transaction (normal)** | Edit, Delete | "Add to Budget" removed — budgets deferred to v2 |
| **Account** | Edit, Delete | |
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
- Basic home summary (account balances, net worth)
- First-launch onboarding wizard (currency selection, first account creation, feature highlights)
- Default category seeding on first install
- Settings: appearance (Material You), primary config, security (device lock / PIN with configurable scope and timeout), management, about
- Multi-currency accounts with cached exchange rates (opportunistic background fetch)
- Multi-currency display: both original and home currency amounts in transaction list
- Universal soft-delete: no entity is ever permanently deleted
- Internal equity account for initial balance (invisible to user)
- System-generated internal transfer on account soft-delete (with warning on deletion)

### 🔄 Deferred — v2

- **Budgeting** (total + per-category budgets, multi-horizon, configurable rollover, alerts, income replenishment) — to be redesigned alongside savings goals
- Savings goals
- Account and category manual reordering
- Recurring template disable/enable (with backfill option)
- Subcategory parent reassignment
- Trends, dashboards, charts, analytics, visualisations
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
| SC-4 | *(Deferred to v2 — budget views)* |
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

> **All questions Q1–Q76 are resolved.** All resolutions are baked into the document body. The full resolved questions log with original question text and decisions is maintained in `docs/06-helpers/ideation-tracker.md`. Open UX design decisions (UX-1 through UX-14) and feature gap items (Parts 2–3) are tracked in `docs/06-helpers/gaps-and-questions.md`.
>
> No open questions remain. The PRD is ready for sign-off.
