# Database Schema & Logic

Variance uses [Drift](https://drift.simonbinder.eu/) (SQLite) for local persistence. The model follows a **Hybrid Double-Entry** system.

## Conceptual Model (ERD)

```
erDiagram
    Account ||--o{ Transaction : "source for"
    Account ||--o{ Transaction : "destination for"
    Category ||--o{ Transaction : "classifies"
    Category ||--o{ Category : "parent of"
    Transaction }o--o{ Tag : "labeled by"

    Account {
        int id PK
        enum type "cash, savings, bankAccount, creditCard, loan, investment, insurance"
        double currentBalance "Cached Sum"
        bool isDeleted "Soft Delete"
    }

    Transaction {
        int id PK
        double amount
        enum type "income, expense, transfer, adjustment"
        int sourceAccountId FK "Nullable"
        int destinationAccountId FK "Nullable"
    }
```

## Double Entry Logic
Strict double-entry accounting is enforced at the Application/Repository layer (`TransactionRepository`).

### The Equation
`Assets = Liabilities + Equity`

In our context:
*   **Expense**: Money leaves an Asset account. `Asset ↓` (Equity ↓).
*   **Income**: Money enters an Asset account. `Asset ↑` (Equity ↑).
*   **Transfer**: Money moves from one Asset to another. `Asset A ↓`, `Asset B ↑` (Net Zero).
*   **Adjustment**: Correction of balance. Can be Inflow or Outflow depending on context.

### Implementation Rules
When a `Transaction` is created, the repository **atomically**:
1.  Inserts the Transaction row.
2.  Updates the `currentBalance` of the `sourceAccountId` (if present) by subtracting the amount.
3.  Updates the `currentBalance` of the `destinationAccountId` (if present) by adding the amount.

## Schema Reference

### 1. Accounts
Represents a physical or digital store of value.

#### User View
*   **What it is:** A place where you keep money (Wallet, Bank Account) or owe money (Credit Card, Loan).
*   **Key Behaviors:**
    *   **Credit Cards:** You set a "Statement Day" and "Due Day". The app uses these to help you track credit cycles (Feature TBD).
    *   **Currency:** Currently fixed to INR, but ready for multi-currency.
    *   **Net Worth:** You can choose to exclude specific accounts (e.g. Shared Account) from your total net worth.

#### Technical Spec (`Accounts`)
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `Int` | PK, AutoInc | Unique ID |
| `name` | `Text` | Max 50 chars | Display Name |
| `type` | `Enum` | `AccountType` | `cash`, `savings`, `bankAccount`, `creditCard`, `loan`, `investment`, `insurance` |
| `initialBalance` | `Real` | Default 0.0 | Balance at creation |
| `currentBalance` | `Real` | Default 0.0 | `initialBalance` + Sum(Transactions) |
| `currencyCode` | `Text` | Default 'INR' | ISO 4217 Code |
| `includeInTotals`| `Bool` | Default `true`| Include in Net Worth calculations |
| `isDeleted` | `Bool` | Default `false` | Soft Delete Flag |
| `statementDay` | `Int` | Nullable, 1-31 | Only for `creditCard` |
| `paymentDueDay` | `Int` | Nullable, 1-31 | Only for `creditCard` |
| `interestRate` | `Real` | Nullable | % for Loans/Savings |

### 2. Categories
Classifies where money comes from or goes to.

#### User View
*   **Structure:** You can have sub-categories (e.g., "Food" -> "Groceries", "Food" -> "Dining Out").
*   **Usage:** Every Expense and Income *must* have a category. Transfers do not.

#### Technical Spec (`Categories`)
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `Int` | PK, AutoInc | Unique ID |
| `name` | `Text` | Max 50 chars | Display Name |
| `kind` | `Enum` | `CategoryKind` | `expense`, `income`. Restricts visibility in UI pickers |
| `parentId` | `Int` | FK -> `Categories.id` | Null implies Top-Level Category |
| `color` | `Int` | Nullable | ARGB Integer for UI styling |
| `iconData` | `Text` | Nullable | Asset path or Icon CodePoint |
| `isDeleted` | `Bool` | Default `false` | Soft Delete Flag |

### 3. Transactions
The central record of a financial event.

#### User View
*   **Expense:** Money leaving an account (e.g., Buying Coffee).
*   **Income:** Money entering an account (e.g., Salary).
*   **Transfer:** Moving money between accounts (e.g., ATM Withdrawal: Bank -> Cash).
*   **Adjustment:** Manual balance correction.
*   **Date:** When it happened. Defaults to Now.

#### Technical Spec (`Transactions`)
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `Int` | PK, AutoInc | Unique ID |
| `amount` | `Real` | > 0 | Magnitude. Polarity determined by Logic. |
| `type` | `Enum` | `TransactionType`| `expense`, `income`, `transfer`, `adjustment` |
| `transactionDate` | `DateTime` | Not Null | Event timestamp |
| `sourceAccountId` | `Int` | FK -> `Accounts` | Required for Expense/Transfer |
| `destinationAccountId` | `Int` | FK -> `Accounts` | Required for Income/Transfer |
| `categoryId` | `Int` | FK -> `Categories` | Required for Expense/Income |
| `description` | `Text` | Nullable | User notes |

### 4. Tags (Groups)
Flexible labels for cross-cutting analysis.

#### User View
*   **Usage:** Tag multiple transactions with "Hawaii Trip" to see total trip cost, regardless of whether it was Food, Travel, or Lodging.
*   **Structure:** Flat list (no hierarchy). One transaction can have multiple tags.

#### Technical Spec (`Tags` & `TransactionTags`)
**Table `Tags`**
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `Int` | PK |
| `name` | `Text` | Unique Label |
| `isDeleted` | `Bool` | Soft Delete Flag |

**Table `TransactionTags` (Join Table)**
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `transactionId` | `Int` | FK -> `Transactions`, PK (Composite) |
| `tagId` | `Int` | FK -> `Tags`, PK (Composite) |

### 5. Recurring Patterns
Automation engine for repeating transactions.

#### User View
*   **Logic:** Set up a rule like "Rent, Monthly, on the 1st".
*   **Behavior:** The app checks daily and creates the actual Transaction entry when due.

#### Technical Spec (`RecurringPatterns`)
| Column | Type | Description |
| :--- | :--- | :--- |
| `frequency` | `Enum` | `RecurringFrequency`: `daily`, `weekly`, `monthly`, `yearly` |
| `interval` | `Int` | Multiplier (e.g., Every *2* weeks) |
| `nextRunDate` | `DateTime` | Optimization field for query speed |
| `type` | `Enum` | `RecurringType`: `automatic`, `manualReminder` |
| `templateData` | `Text` | JSON blob of the transaction to clone |
| `isDeleted` | `Bool` | Soft Delete Flag |
