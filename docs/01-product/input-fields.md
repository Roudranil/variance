---
name: Input Fields Reference
status: in progress
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 01-product/ledger-entry.md]
outputs_to: [02-technical/sds.md, 02-technical/ux-flows.md, 02-technical/data-model.md]
---

- [Variance — Input Fields Reference](#variance--input-fields-reference)
  - [Editability Legend](#editability-legend)
  - [1. Transaction Entry](#1-transaction-entry)
    - [1.1 Common Fields (all transaction types)](#11-common-fields-all-transaction-types)
    - [1.2 Type-Specific Fields](#12-type-specific-fields)
    - [1.3 Transfer Fee Fields (§5.1.5b)](#13-transfer-fee-fields-515b)
    - [1.4 Validation \& Warnings at Entry Time](#14-validation--warnings-at-entry-time)
  - [2. Account Creation \& Edit](#2-account-creation--edit)
    - [2.1 Common Fields (all account types)](#21-common-fields-all-account-types)
    - [2.2 Category-Specific Fields](#22-category-specific-fields)
      - [Cash](#cash)
      - [Bank Account](#bank-account)
      - [Credit Card](#credit-card)
      - [Debit Card](#debit-card)
      - [Top-Up Wallet](#top-up-wallet)
      - [Loan](#loan)
      - [Investment](#investment)
      - [Other](#other)
    - [2.3 Balance Edit (§5.1.3)](#23-balance-edit-513)
    - [2.4 Balance Reconciliation (§5.1.3a)](#24-balance-reconciliation-513a)
    - [2.5 Credit Card Payment (§5.1.7)](#25-credit-card-payment-517)
    - [2.6 Account Deletion Flow (§5.1.1)](#26-account-deletion-flow-511)
  - [3. Transaction Categories](#3-transaction-categories)
    - [3.1 Parent Category Creation (Income or Expense tree)](#31-parent-category-creation-income-or-expense-tree)
    - [3.2 Child Category (Subcategory) Creation](#32-child-category-subcategory-creation)
    - [3.3 Category Deletion Flow (§5.2.4)](#33-category-deletion-flow-524)
  - [4. Recurring Transaction Templates](#4-recurring-transaction-templates)
    - [4.1 Template Creation](#41-template-creation)
    - [4.2 Pause Template](#42-pause-template)
  - [5. Installment Templates](#5-installment-templates)
    - [5.1 Template Creation](#51-template-creation)
    - [5.2 Installment Early Close (§5.2.8, FG-B7)](#52-installment-early-close-528-fg-b7)
  - [6. Settings Fields](#6-settings-fields)
  - [7. Onboarding Wizard (§5.6.2)](#7-onboarding-wizard-562)
  - [Complete Editability Matrix](#complete-editability-matrix)
    - [Posted Transaction Fields](#posted-transaction-fields)
    - [Account Fields](#account-fields)
    - [Template Fields (Recurring / Installment)](#template-fields-recurring--installment)
    - [Category Fields](#category-fields)


# Variance — Input Fields Reference

> **Purpose:** Authoritative inventory of every user input field across all entity creation and edit forms. Defines field type, required/optional, default value, and editability. This document informs SDS schema design, UX Flows form layouts, and API contract validation.
>
> **Last Updated:** 2026-04-14

---

## Editability Legend

| Code | Meaning | Mechanism |
|------|---------|-----------|
| **IP** | **In-place edit** | Field is directly mutable. No ledger impact. Change takes effect immediately. |
| **LE** | **Edit with ledger entry** | Change triggers a reversing + corrected transaction pair (§4.8). Applies to financial fields on posted transactions. |
| **IM** | **Immutable** | Cannot be changed after creation. User must create a new entity to use a different value. |
| **NA** | **Not applicable** | Field does not exist on this entity or in this context. |

---

## 1. Transaction Entry

### 1.1 Common Fields (all transaction types)

| Field | Type | Req? | Default | Income | Expense | Transfer | Edit Rule | Notes |
|-------|------|------|---------|--------|---------|----------|-----------|-------|
| Date and time | DateTime | Yes | Now | ✅ | ✅ | ✅ | **IP** | Changing the date may shift which reporting period the transaction falls in but does not trigger ledger entries. User is responsible for date accuracy. (§5.2.2) |
| Amount | Decimal > 0 | Yes | — | ✅ | ✅ | ✅ | **LE** | Must be > 0. Triggers reversing + corrected pair on edit. |
| Title | Text (short) | No | Empty | ✅ | ✅ | ✅ | **IP** | Optional label. v3 idea: ML/rule-based auto-generation. |
| Description | Text (long) | No | Empty | ✅ | ✅ | ✅ | **IP** | Max length configurable in Settings (§5.4.3): 500 / 1000 / 2000 chars. Default: 1000. |
| Photo(s) | Image[] | No | [] | ✅ | ✅ | ✅ | **IP** | Max 2 per transaction (§5.2.3). Add/remove is in-place. Photos permanently deleted on transaction soft-delete. |

### 1.2 Type-Specific Fields

| Field | Type | Req? | Default | Income | Expense | Transfer | Edit Rule | Notes |
|-------|------|------|---------|--------|---------|----------|-----------|-------|
| Account (destination) | Account ref | Yes | — | ✅ | NA | ✅ | **LE** | Income: where funds land. Transfer: destination. |
| Account (source) | Account ref | Yes | — | NA | ✅ | ✅ | **LE** | Expense: source of funds. Transfer: source. |
| Transaction category | Category ref | Yes | — | ✅ | ✅ | NA | **LE** | Selected from income tree (income) or expense tree (expense). Transfers have no category. |
| Subcategory | Category ref | No | None | ✅ | ✅ | NA | **LE** | Optional child of selected parent category. |

### 1.3 Transfer Fee Fields (§5.1.5b)

These fields appear in a **collapsible fees panel** on the transfer entry form. The panel is collapsed by default (no fee).

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Fee mode | Enum: Flat / Percentage | No | None (panel collapsed) | **LE** | Mutually exclusive. Selecting one clears the other. |
| Fee amount | Decimal > 0 | Conditional (if Flat) | — | **LE** | In the source account's currency. |
| Fee percentage | Decimal > 0 | Conditional (if Percentage) | — | **LE** | Computed fee = amount × percentage ÷ 100. |
| Fee category | Category ref | No | Financial > Fees & Charges | **LE** | User may change before saving. Defaults to the protected subcategory. |

> **Compound edit rule:** Editing or deleting a transfer-with-fee affects both the transfer and fee parts together (Case 1.6a / 1.9a in `ledger-entry.md`).

### 1.4 Validation & Warnings at Entry Time

These are not input fields but are triggered by field values during entry:

| Check | Trigger | Behaviour |
|-------|---------|-----------|
| Duplicate transaction detection (FG-C2) | Same type + amount + account + category on same calendar day | Non-blocking warning. User confirms or cancels. Always active — no toggle. |
| Overdraft warning (§5.1.4) | Transaction would push account balance below zero or deepen negative balance | Non-blocking inline warning. |
| Credit card limit warning (FG-C18, §5.1.4) | Expense/transfer on CC would exceed configured credit limit | Non-blocking inline warning. Only when credit limit is configured. |
| Large transaction warning (§5.4.4) | Amount exceeds per-account or per-category threshold | Non-blocking confirmation. Account threshold takes precedence if both triggered. |
| Exchange rate estimate (FG-C12, §7.1) | Account currency ≠ home currency | Informational: shows home currency estimate below amount field. Staleness warning if rate > 14 days. |
| Future date info (§5.7) | Date is in the future | Info popup: transaction will be held as pending until the date. |

---

## 2. Account Creation & Edit

### 2.1 Common Fields (all account types)

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Name | Text | Yes | — | **IP** | Must be unique across all accounts including soft-deleted. Free-form text. |
| Account category | Enum (8 fixed types) | Yes | — | **IM** | Selected from: Cash, Bank Account, Credit Card, Debit Card, Top-Up Wallet, Loan, Investment, Other. Determines which category-specific fields are shown. Cannot be changed after creation. |
| Initial balance | Decimal | Yes | 0 | **IM** | Posts an opening-balance ledger entry (§4.9) if ≠ 0. Positive = asset state, negative = liability state. This is a one-time field — subsequent balance changes happen through transactions or balance edits (§5.1.3). |
| Currency | ISO 4217 | Yes | Home currency | **IM** | Selected from bundled ISO 4217 list. Permanently fixed at creation. Confirmation dialog before save if changed from default. (§5.1.1) |
| Include in net worth | Boolean | Yes | true | **IP** | Controls whether this account contributes to the net worth total. |
| Notes | Text | No | Empty | **IP** | Optional free-form text. |

### 2.2 Category-Specific Fields

#### Cash

No additional fields.

#### Bank Account

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Bank name | Text | **Yes** | — | **IP** | |
| Account number | Text (encrypted) | No | — | **IP** | Encrypted at rest. Masked display. Authentication required to reveal (§5.4.6). |
| Branch | Text | No | — | **IP** | |
| IFSC | Text | No | — | **IP** | |

#### Credit Card

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Card name | Text | No | — | **IP** | |
| Card number | Text (encrypted) | No | — | **IP** | Encrypted at rest. Masked display. Authentication required to reveal. CVV is never stored. |
| Expiry date | Date (MM/YY) | No | — | **IP** | |
| Billing date | Day of month (1–28) | **Yes** | — | **IP** | Required — enables payment reminders (§5.1.7) and statement balance computation (§5.1.6). Editing triggers notification reschedule. |
| Payment due date | Day of month (1–28) | **Yes** | — | **IP** | Required — enables payment reminders. Editing triggers notification reschedule. |
| Credit limit | Decimal ≥ 0 | No | — | **IP** | Enables credit card limit warning (§5.1.4, FG-C18) when configured. |
| Linked bank account | Account ref | No | None | **IP** | Optional. Links to a bank account for payment source pre-fill. Editing triggers notification reschedule. Only bank accounts shown in picker. |

#### Debit Card

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Card name | Text | No | — | **IP** | |
| Card number | Text (encrypted) | No | — | **IP** | Encrypted at rest. Masked display. |
| Expiry date | Date (MM/YY) | No | — | **IP** | |
| Linked bank account | Account ref | No | None | **IP** | Metadata only. No functional coupling (§5.1.2). |

#### Top-Up Wallet

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Wallet provider name | Text | No | — | **IP** | |
| Linked phone number | Text | No | — | **IP** | |

#### Loan

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Lender/borrower name | Text | No | — | **IP** | |
| Principal amount | Decimal | No | — | **IP** | Informational. Not linked to initial balance or ledger. |
| Interest rate | Decimal (%) | No | — | **IP** | Informational. |
| EMI amount | Decimal | No | — | **IP** | Used for installment setup suggestion pre-fill (§5.1.2). |
| EMI date | Day of month (1–28) | No | — | **IP** | Used for installment setup suggestion pre-fill. |
| Due date | Date | No | — | **IP** | Overall loan due date. Informational. |

> **Post-save suggestion (§5.1.2):** When initial balance is negative (liability) OR EMI amount/date are provided, the app offers to create a recurring installment template with pre-filled fields.

#### Investment

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Investment type | Enum | **Yes** | — | **IP** | FD, Mutual Fund, Stocks, PPF, NPS, Other. |
| Institution name | Text | No | — | **IP** | |
| Current value | Decimal | No | — | **IP** | Manually entered. This is informational metadata — the authoritative balance comes from the ledger (§5.1.3). |

#### Other

No additional fields.

### 2.3 Balance Edit (§5.1.3)

This is not a creation form but an edit action on an existing account. The "Edit Balance" flow:

| Field | Type | Req? | Notes |
|-------|------|------|-------|
| New balance | Decimal | Yes | The target balance. The system computes ΔB = new − current. |
| Record as income/expense? | Boolean (Yes/No prompt) | Yes | If Yes → visible Balance Adjustment transaction (Cases 2.3a/2.3b). If No → invisible journal entry against EQ (Cases 2.4a/2.4b). |

> **Credit card variant (§5.1.6):** Credit cards present two balance edit actions — "Adjust statement balance" (dated to billing date) and "Adjust outstanding balance" (dated to today). Same fields, different dating.

### 2.4 Balance Reconciliation (§5.1.3a)

Accessed from account contextual menu or account detail screen. Functionally identical to balance edit but user enters the target rather than the delta.

| Field | Type | Req? | Notes |
|-------|------|------|-------|
| Actual balance | Decimal | Yes | The real-world figure the user has verified. System computes discrepancy = actual − computed. |
| Record as income/expense? | Boolean (Yes/No prompt) | Conditional | Only shown if discrepancy ≠ 0. Same behaviour as balance edit. |

### 2.5 Credit Card Payment (§5.1.7)

This is a pre-filled transfer form, not a separate entity. It opens from payment reminder notifications or the Pay FAB on the CC detail screen.

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Transaction type | Enum | Yes | Transfer | **IM** (fixed) | Always "Transfer" — not user-changeable. |
| Destination account | Account ref | Yes | This credit card | **IM** (fixed) | Pre-filled and locked. |
| Source account | Account ref | Yes | Linked bank (if set) | **IP** (editable) | Pre-filled with linked bank. User may change before saving. Empty if no linked bank. |
| Amount | Decimal > 0 | Yes | Statement balance | **IP** (editable) | Pre-filled with statement balance. User may edit before confirming. |

> Once saved, this becomes a normal transfer transaction subject to standard editability rules (§1 above).

### 2.6 Account Deletion Flow (§5.1.1)

Not a form per se, but a multi-step flow with user inputs:

| Step | Input | Type | Notes |
|------|-------|------|-------|
| 1 (if templates exist) | Template handling | Enum: Migrate / Stop | **Migrate:** select replacement account. **Stop:** archive all. Default: Stop. |
| 1a (if Migrate) | Replacement account | Account ref | Must be same type (for account field) or compatible. |
| 2 (if balance ≠ 0 and same-currency account exists) | Transfer balance? | Boolean: Yes / No | If Yes: select destination account. If No: net worth warning + confirm. |
| 2a (if Yes) | Destination account | Account ref | Must be same currency. |
| 3 (if declined transfer or no same-currency account) | Confirm deletion | Boolean | Final confirmation with net worth impact warning. |

---

## 3. Transaction Categories

### 3.1 Parent Category Creation (Income or Expense tree)

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Icon | Icon ref | Yes | — | **IP** | Selected from curated subset of `material_symbols_icons`. |
| Name | Text | Yes | — | **IP** | Must be unique within the tree (case-insensitive). Unique including across soft-deleted categories. |

### 3.2 Child Category (Subcategory) Creation

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Icon | Icon ref | Yes | — | **IP** | |
| Name | Text | Yes | — | **IP** | Must be unique within the parent category (case-insensitive). |
| Parent category | Category ref | Yes | — | **IM** | Set at creation. Reassignment to a different parent deferred to v2. |

### 3.3 Category Deletion Flow (§5.2.4)

| Step | Input | Type | Notes |
|------|-------|------|-------|
| 1 (if templates reference this category) | Template handling | Enum: Migrate / Stop | Same pattern as account deletion. Default: Stop. |
| 1a (if Migrate) | Replacement category | Category ref | Must be in same tree (income/expense). |
| 2 (if N > 0 transactions reference category) | Usage count acknowledgement | — | Informational display of transaction count. |
| 3 | Migration choice | Enum: No migration / Migrate all / Choose specific | Default: No migration. |
| 3a (if Migrate all) | Destination category | Category ref | All transactions re-categorised (ledger correction per §4.8). |
| 3b (if Choose specific) | Transaction multi-select | Transaction ref[] | Selected transactions migrated; unselected retain old category. |

---

## 4. Recurring Transaction Templates

### 4.1 Template Creation

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Transaction type | Enum: Income / Expense / Transfer | Yes | — | **IM** | Cannot be changed after creation. |
| Amount | Decimal > 0 | Yes | — | **IP** | Editable. Changes apply to future occurrences only. |
| Account (destination) | Account ref | Yes (Income, Transfer) | — | **IP** | Editable. Future occurrences use the new account. |
| Account (source) | Account ref | Yes (Expense, Transfer) | — | **IP** | Editable. |
| Transaction category | Category ref | Yes (Income, Expense) | — | **IP** | Editable. Transfers: NA. |
| Subcategory | Category ref | No | None | **IP** | Editable. |
| Title | Text | No | Empty | **IP** | |
| Description | Text | No | Empty | **IP** | |
| Recurrence — N | Integer > 0 | Yes | 1 | **IM** | e.g., the "2" in "every 2 weeks". Cannot be changed after creation. |
| Recurrence — unit | Enum: day / week / month / year | Yes | — | **IM** | Cannot be changed after creation. |
| Recurrence — constraints | Enum set (optional) | No | None | **IM** | Weekdays only / Weekends only / Start of month / End of month / Start of year / End of year. Cannot be changed after creation. |
| Start date | Date | Yes | Today | **IM** | Cannot be changed after creation. |
| End date | Date | No | None (indefinite) | **IM** | Cannot be changed after creation. No end date = runs until paused/archived. |
| Posting behaviour | Enum: Auto-post / Remind and confirm | Yes | Auto-post | **IP** | Editable. "Remind and confirm" can be switched to "Auto-post" via contextual menu (§5.2.7). |

> **Edit rule summary:** Amount, accounts, category, title, description, and posting behaviour are editable (**IP**). Recurrence structure (N, unit, constraints) and schedule boundaries (start date, end date) are immutable (**IM**). Transaction type is immutable (**IM**). To change the schedule, the user must archive the current template and create a new one.

### 4.2 Pause Template

| Field | Type | Req? | Notes |
|-------|------|------|-------|
| Pause duration — mode | Enum: N units / Custom date | Yes | N units uses the template's time unit (e.g., "pause for 3 months" on a monthly template). |
| Pause duration — N | Integer > 0 | Conditional (if N units) | |
| Pause duration — until date | DateTime | Conditional (if Custom date) | Must be in the future. Cannot be indefinite. |

---

## 5. Installment Templates

### 5.1 Template Creation

Installments share all fields from §4.1 (Recurring Template Creation) plus:

| Field | Type | Req? | Default | Edit Rule | Notes |
|-------|------|------|---------|-----------|-------|
| Total amount | Decimal > 0 | Yes | — | **IM** | The target total. Immutable after creation (§5.2.8). |
| Number of installments | Integer > 0 | Yes | Derived (total ÷ per-period, or manual) | **IP** (future only) | User can add or remove future (unposted) installments after creation. Total configured remains immutable. |
| Per-installment amounts | Decimal[] | Yes | Auto-calculated (total ÷ count) | **IP** (future only) | User may manually adjust individual future installment amounts. Mismatch warning at save if Projected final total ≠ Total configured. |

> **Editable future installments:** The user can add new future installments or remove unposted ones. This changes the Projected final total but not Total configured. The 4 tracked amounts (§5.2.8) update accordingly.

### 5.2 Installment Early Close (§5.2.8, FG-B7)

| Step | Input | Type | Notes |
|------|-------|------|-------|
| 1 | Record final payment? | Boolean: Yes / No | |
| 1a (if Yes) | Final payment amount | Decimal > 0 | Posted as a child transaction linked to the series. |
| 2 (if Running total ≠ Total configured) | Update target total? | Boolean: Yes / No | Yes: Total configured = Running total. No: archived with mismatch noted. |

---

## 6. Settings Fields

All settings fields are fully specified in PRD §5.4. See §5.4.1–§5.4.12 for the complete inventory with Type / Default / Options for each setting. Settings fields are all in-place editable (**IP**) — none require ledger entries or are immutable after first set.

---

## 7. Onboarding Wizard (§5.6.2)

The onboarding wizard collects a subset of fields that are also available in their respective full forms:

| Step | Field | Full Form Location | Notes |
|------|-------|--------------------|-------|
| 2 | Home currency | Settings > Locale & Format (§5.4.2) | Pre-filled from device locale. Fallback: INR. |
| 3 | Account name | Account Creation (§2.1) | Simplified: name + category + initial balance only. |
| 3 | Account category | Account Creation (§2.1) | From the 8 fixed types. |
| 3 | Initial balance | Account Creation (§2.1) | Default: 0. |

> Steps 2–4 are skippable. Locale-derived defaults are applied if skipped.

---

## Complete Editability Matrix

This matrix summarises the editability of every field on a **posted transaction** (the most complex case). For templates and accounts, see the individual sections above.

### Posted Transaction Fields

| Field | Create | Edit | Soft-Delete |
|-------|--------|------|-------------|
| Date and time | ✅ User enters | **IP** — in-place, no ledger entry | N/A (transaction voided) |
| Amount | ✅ User enters | **LE** — reversing + corrected pair | Reversing entry posted |
| Account(s) | ✅ User selects | **LE** — reversing + corrected pair | Reversing entry posted |
| Category / Subcategory | ✅ User selects | **LE** — reversing + corrected pair | Reversing entry posted |
| Title | ✅ User enters (optional) | **IP** — in-place, no ledger entry | N/A |
| Description | ✅ User enters (optional) | **IP** — in-place, no ledger entry | N/A |
| Photo(s) | ✅ User attaches (optional) | **IP** — add/remove, no ledger entry | Photos permanently deleted |
| Transaction type | ✅ User selects | **IM** — cannot be changed | N/A |
| Fee (transfer) | ✅ User enters (optional) | **LE** — compound correction (Case 1.6a) | Compound reversal (Case 1.9a) |

### Account Fields

| Field | Create | Edit |
|-------|--------|------|
| Name | ✅ | **IP** |
| Account category | ✅ | **IM** |
| Initial balance | ✅ | **IM** (subsequent changes via balance edit / transactions) |
| Currency | ✅ | **IM** |
| Include in net worth | ✅ | **IP** |
| Notes | ✅ | **IP** |
| Category-specific fields | ✅ | **IP** (all) |

### Template Fields (Recurring / Installment)

| Field | Create | Edit |
|-------|--------|------|
| Transaction type | ✅ | **IM** |
| Amount | ✅ | **IP** (future occurrences only) |
| Account(s) | ✅ | **IP** (future occurrences only) |
| Category / Subcategory | ✅ | **IP** (future occurrences only) |
| Title / Description | ✅ | **IP** |
| Recurrence (N, unit, constraints) | ✅ | **IM** |
| Start date / End date | ✅ | **IM** |
| Posting behaviour | ✅ | **IP** |
| Total configured (installment) | ✅ | **IM** |
| Number of installments | ✅ | **IP** (add/remove future only) |
| Per-installment amounts | ✅ (auto-calc, then adjustable) | **IP** (future only) |

### Category Fields

| Field | Create | Edit |
|-------|--------|------|
| Icon | ✅ | **IP** |
| Name | ✅ | **IP** |
| Parent (subcategory only) | ✅ | **IM** (reassignment deferred to v2) |
