# Product Requirements Document (PRD)
## Variance — Personal Finance & Expense Tracker

| Field        | Value          |
|-------------|----------------|
| Version      | 0.1.3          |
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
- At least one income category entry (debit side)
- At least one account entry (credit side, where funds land)

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
- Correcting a transaction's financial fields posts a **new reversing transaction** (negates the original) followed by a **new corrected transaction**.
- Non-financial fields (notes, photo, category assignment) may be edited in-place.
- **Soft delete** of a transaction posts an automatic reversing entry to neutralise it. The original transaction record is retained.
- No entity (transaction, account, category) is ever permanently deleted.

### 4.9 Initial Balance & Equity Account

When an account is created with an initial balance, the system implicitly posts a transaction against an internal **Opening Balance equity account**. This equity account is not visible to the user and does not appear in any user-facing views. Mathematical treatment to be finalised in SDS.

### 4.10 Journal Adjustments

When a user directly edits an account's balance, the system posts a **journal adjustment transaction**. The user is prompted: *"Record this balance change as income/expense?"*

- If **Yes**: The adjustment is categorised under the protected **"Balance Adjustment"** system category and is visible in the transaction list.
- If **No**: The adjustment is an invisible internal entry retained for ledger integrity. It is not visible in normal views but surfaces in the v2 audit view.

---

## 5. Functional Requirements (Feature Graph)

> Only **v1** features are defined here.
> Organized as: **PILLAR → FEATURE → SUB-FEATURE**

---

### 5.1 Account Management (CORE) — UC-1

#### 5.1.1 Account CRUD

- **Create** with: name, account category, initial balance, currency, include-in-net-worth flag (defaults to true), optional notes. Category-specific fields (see §5.1.2) are also collected at creation.
- **Edit**: name, notes, include-in-net-worth flag, and all category-specific fields.
- **Edit balance**: Posts a journal adjustment transaction (see §4.10).
- **Delete**: Soft delete only. Account becomes hidden from all user-facing views. Ledger entries are retained. A soft-deleted account's balance is excluded from net worth. Hard delete and transaction migration to another account are deferred to a future version.
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
| **Investment** | Investment type (FD, Mutual Fund, Stocks, PPF, NPS, Other), institution name, current value (manually entered — see §5.1.3) |
| **Other** | None — generic miscellaneous account |

#### 5.1.3 Investment Account Balance Model

An Investment account's balance changes in exactly three ways:

1. **Direct balance edit** (via edit account menu): System prompts — *"Record this change as a real transaction?"*
   - If Yes → posts a proper income/expense transaction with the **"Balance Adjustment"** category. Visible in transaction list.
   - If No → posts an invisible journal adjustment. Not visible in normal views.
2. **Recorded transaction against this account**: A normal income/expense/transfer entry referencing this account. Displayed in the transaction list.
3. **Deletion of an existing transaction**: Posts an invisible reversing entry. Not displayed.

#### 5.1.4 Account Balance View

- Real-time computed balance per account (derived from ledger).
- Net worth view: sum of all balances for accounts where "include in net worth" is true and the account is not soft-deleted. Accounts flagged as excluded are shown separately or not shown.
- Balances respect the locale, number format, and currency settings.

#### 5.1.5 Internal Transfer

- A Transfer transaction atomically debits the destination account and credits the source account.
- Both entries post together or neither does.
- Transfers carry no transaction category.

### 5.2 Transaction Management (CORE) — UC-2

#### 5.2.1 Transaction Entry

User selects transaction type. Fields collected:

| Field | Income | Expense | Transfer |
|-------|--------|---------|----------|
| Date and time | ✅ | ✅ | ✅ |
| Amount | ✅ | ✅ | ✅ |
| Account (destination) | ✅ | — | ✅ (from + to) |
| Account (source) | — | ✅ | — |
| Transaction category | ✅ | ✅ | ❌ (not applicable) |
| Subcategory | ✅ | ✅ | ❌ |
| Notes | ✅ | ✅ | ✅ |
| Photo(s) (optional) | ✅ | ✅ | ✅ |

#### 5.2.2 Transaction Immutability & Editing

- All posted transactions are immutable.
- **Editing amount or account**: A reversing entry is posted (negating the original), followed by the corrected transaction.
- **Editing notes, photos, category**: In-place edit only; no new entry is posted.
- **Soft delete**: The transaction is voided. A reversing entry is posted automatically. The original record is retained but excluded from all normal views and calculations. Voided transactions are surfaced in the v2 audit view.
- No transaction is ever permanently deleted.

#### 5.2.3 Photo Attachments

- Multiple photos may be attached per transaction (maximum count TBD — see Q31).
- Photos are stored in a dedicated app-private data folder on the device.
- Photos are not accessible from the OS gallery.
- When a transaction is soft-deleted (voided), all its attached photos are permanently deleted from storage.
- Photo compression and size limits TBD in SDS (see Q32).

#### 5.2.4 Transaction Categories (Two-Level Hierarchy)

Categories and subcategories form a two-level tree — category → subcategory. No deeper nesting.

Separate trees exist for **Income** and **Expense**. Transfers have no category.

The user can create, rename, and soft-delete custom categories and subcategories within each tree. System default categories can be hidden (soft-deleted) but not permanently removed.

**Deletion rules:**
- A parent category cannot be deleted if any child subcategories exist.
- A subcategory cannot be soft-deleted if active (non-voided) transactions reference it.
- Soft-deleting a subcategory hides it from selection but retains its data.
- Any transaction referencing an entity that no longer matches an active category is treated as referencing a soft-deleted generic fallback of that type.

**Protected system category — "Balance Adjustment":**
- Exists in both income and expense trees.
- Cannot be selected by the user when creating a transaction.
- Assigned automatically when a journal adjustment is recorded as income/expense.
- Visible in the transaction list when such transactions exist.

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
| Social | Movie, Treat, Outing, Gift |
| Stationery | Books, Art, Craft |
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

#### 5.2.5 Transaction Search

- Fuzzy search across all fields: date, amount, account name, category name, subcategory name, notes, and any searchable metadata.

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
| Has description/notes | Boolean |
| Is recurring | Boolean |
| Is voided | Boolean — shows soft-deleted transactions |

Full UX specification deferred to UX Flows.

#### 5.2.7 Recurring Transactions

Users can define recurring transaction templates. Parameters:

- Transaction type, amount, account(s), category, notes
- **Recurrence definition**: $N$ units of a time unit, where unit ∈ { day, week, month, year }. E.g., "every 2 weeks", "every 3 months".
- **Optional recurrence constraints**: repeat on weekdays only / weekends only / start of month / end of month / start of year / end of year.
- Start date, optional end date.
- **Posting behaviour** (configurable per template):
  - **Auto-post**: Transaction is posted automatically on the scheduled date.
  - **Remind and confirm**: An in-app notification prompts the user to review and confirm before posting.
- When the end date passes or all installments are exhausted, the template is **automatically archived**.
- Archived templates can be reactivated (see Q37).

#### 5.2.8 Installments

Installments are a sub-type of recurring transaction representing a fixed total amount split across a defined set of periods.

Parameters:
- Total amount, recurrence definition (same as 5.2.7), number of installments (derived from total / recurrence, or manually set).
- The system auto-calculates the per-installment amount (total ÷ number of installments).
- The user may manually adjust individual installment amounts after the auto-calculation stage.
- If the sum of manually adjusted amounts does not equal the total, the app surfaces an in-context warning (non-blocking).
- A reminder is shown when the final installment is due and the running total does not yet match the target total (see Q30 for exact trigger timing).

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

$$N_{\text{new}} = N + T$$

- $N_{\text{new}}$ may exceed $M$. This is not blocked (see Q36 for cap behaviour).

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
| Font | Bundled curated font OR system default (see Q40 for further options) |
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
- A staleness indicator is shown when the cached rate is older than a defined threshold (see Q34).
- In the absence of any cached rate (e.g., first launch, no internet ever), the app falls back to displaying each currency balance separately or shows a disclaimer.
- Exchange rate updates are entirely optional and non-blocking — the app functions without them.

> Full exchange rate fetching model will be specified in SDS. This is an internet-optional feature even in v1.

---

## 8. In-Scope vs. Out-of-Scope

### ✅ In Scope — v1

- Double-entry ledger engine (internal)
- Account CRUD (soft delete) with 8 fixed account category types and per-type fields
- Per-account net-worth inclusion flag
- Transaction entry: income, expense, transfer (abstract DEB UI)
- Transaction immutability: correcting entries, reversing entries on delete
- Two-level transaction category taxonomy (income and expense), user-manageable
- Protected "Balance Adjustment" system category
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

> All Q11–Q28 from v0.1.2 are resolved and baked into the document above.
> New questions surfaced from deeper design analysis.

### Group A — Blocking UX Flows

| ID | Question | Blocks |
|----|----------|--------|
| Q29 | **Installments vs. recurring relation**: In the data model, is an installment a tagged sub-type of a recurring transaction template, or a completely separate entity? | SDS, UX |
| Q30 | **Installment mismatch reminder timing**: If manually adjusted installment amounts don't total the target, when exactly is the warning/reminder triggered? At the time of each edit? Only when the final installment is due? | UX |
| Q31 | **Maximum photos per transaction**: Is there a cap (e.g., 5, 10), or effectively unlimited (constrained only by device storage)? | UX, SDS |
| Q33 | **"Balance Adjustment" visibility in transaction list**: When a journal adjustment IS recorded as income/expense (user said yes to the prompt), does it appear visually distinct in the transaction list, or is it indistinguishable from a normal transaction? | UX |
| Q38 | **Social, Stationery, Culture — missing "Other"**: These expense categories were provided without an "Other" subcategory. Is that intentional, or should "Other" be added as a default subcategory to all categories for consistency? | Data model |
| Q39 | **Gift income and "Other" income**: These are listed as leaf categories (no subcategories). Is this intentional? Or are subcategories to be added later? | Data model |

### Group B — Blocking SDS

| ID | Question | Blocks |
|----|----------|--------|
| Q32 | **Photo compression/size limit**: Are photos compressed before storage? Is there a maximum file size or resolution per photo? | SDS |
| Q34 | **Exchange rate staleness threshold**: When cached rate is older than N days and internet is unavailable, when does the staleness indicator appear? What is N? | SDS, UX |
| Q35 | **Opening Balance equity account**: Is the internal equity account ever surfaced to the user (e.g., as a system account in account list)? Does its balance factor into net worth? | SDS, financial model |
| Q36 | **Budget pool add: can N+T exceed M?** If adding income T to a budget pool where N+T > M (original budget ceiling), does the pool show N+T remaining out of M (over-budget is fine), or is M also increased? | SDS, UX |
| Q37 | **Reactivating archived recurring templates**: Can a user un-archive a recurring transaction template? If so, does it resume from where it stopped or restart fresh? | SDS, UX |
| Q40 | **System categories immutability**: Can the user rename, reorder, or hide (soft-delete) system-provided default categories? Or are they completely immutable? | SDS |
