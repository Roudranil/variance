# Agent Notes: Variance Project

> **CRITICAL META-INSTRUCTION**: This file acts as the persistent memory for the AI agent working on the Variance project. It MUST be read at the start of every session and UPDATED at the end of every meaningful interaction to reflect new knowledge, completed work, and refined rules.

---

## 1. Project Overview
*   **Name:** Variance
*   **Goal:** A high-quality personal finance/expense tracking application for Android.
*   **Inspiration:** "Money Manager by Realbyte", but better (Predictive Analysis, SMS Detection).
*   **Core Philosophy:**
    *   **Double-Entry Bookkeeping:** Every transaction affects two accounts (Asset/Liability). The app strictly enforces this integrity.
    *   **Privacy First:** Local-first data (SQLite/Drift).
    *   **Premium UX:** Material 3 Expressive Design. Must feel "alive" and polished.

## 2. Technology Stack
*   **Framework:** Flutter (Dart).
*   **Database:** Drift (SQLite) with strictly typed Enums.
*   **Architecture:** Repository Pattern (Data) + Provider (UI State).
*   **Theming:** Dynamic Material 3 + Catppuccin (Latte/Mocha) fallback.
*   **Dependencies:** `drift`, `provider`, `dynamic_color`, `catppuccin_flutter`.

## 3. Work Completed
### UI Foundation (New - 2026-01-04)
*   **App Shell**: Implemented `HomeScreen` with 4-tab `NavigationBar` (`IndexedStack` navigation).
*   **Screens**: Created placeholder screens for Transactions, Dashboard, Accounts, Settings.
*   **Entry Point**: Refactored into `main.dart` (entry) and `app.dart` (configuration).
*   **Theming**:
    *   Font set to `lmsans`.
    *   Configured `AppBarTheme` (centered, flat) and `NavigationBarTheme` (tertiary selected icon).
    *   Extensions: `SemanticColorsExtension` & `TextSizesExtension` fully integrated.
*   **Verification**: 100% Test Coverage for new UI components.

### UI Foundation (Previous)
*   **Theming Architecture:** Established `lib/core/theme` with `ThemeProvider` and `AppTheme`.
*   **Extensions:**
    *   `SemanticColorsExtension`: Maps business logic (Income/Expense) to Catppuccin colors (Green/Red).
    *   `TextSizesExtension`: Implements proper Tailwind scale as `doubles` (e.g., `textXl`) with adjustable `scaleFactor`.
*   **Integration:** `MultiProvider` + `DynamicColorBuilder` in `main.dart`.
*   **Verification:** Full suite of Unit Tests covering all Extensions, Providers, and Theme Definitions.

### Database & Schema (DEB Migration - 2026-01-06)
*   **True Double-Entry Bookkeeping:** Migrated from hybrid source/destination pattern to proper ledger-based DEB.
*   **Schema Design:** Tables: `Accounts`, `Categories`, `Transactions`, `LedgerEntries`, `Tags`, `TransactionTags`, `RecurringPatterns`.
*   **New Enums:** `AccountNature` (asset/liability/equity/income/expense), `LedgerSide` (debit/credit), retained `AccountType` for UI grouping.
*   **Key Changes:**
    *   **Immutable Ledger:** Transactions are never deleted; voided via `isVoid` flag.
    *   **LedgerEntries Table:** Each transaction creates 2+ entries where sum(debits) = sum(credits).
    *   **Balance Computation:** Derived from ledger entries, not cached on accounts.
    *   **Category Linking:** Each category has a `linkedAccountId` to a hidden nominal account.
    *   **Opening Balances:** Equity account created automatically for initial balances.
*   **Repository API:**
    *   `createExpense()`, `createIncome()`, `createTransfer()`, `createAdjustment()`
    *   `voidTransaction()` instead of delete
    *   `editTransaction()` = void + recreate
*   **IntegrityService (`lib/database/integrity.dart`):**
    *   `checkTransactionBalance(txId)` - verify single transaction
    *   `checkAllTransactionsBalance()` - find unbalanced transactions
    *   `checkGlobalEquation()` - verify Assets = Liab + Equity + Net Income
    *   `canSoftDeleteAccount(id)` - check zero balance before delete
    *   **Usage:** App startup health check, Settings "Verify Data", unit tests, delete account flow
    *   **NEVER** call on every transaction - expensive! Use `accountRepo.getAccountBalance()` for display.
*   **Verification:** 32 unit tests passing.

## 4. User Rules & Guidelines
*   **Persona:** Expert Android Mentor pair-programming with a Data Scientist.
*   **Explanation Style:** Explain *WHY*. Use analogies (e.g., comparing database normalization to dataframe operations if applicable). Avoid jargon without definition.
*   **Code Quality:**
    *   **STRICT ADHERENCE:** You MUST strictly follow the `code-style-guide.md` and `docstring-style-guide.md` at all times. No exceptions.
    *   **Docstrings:** Mandatory for all public methods/classes. Must follow the templates and style guide (3rd person present tense, no bold headers).
    *   **Comments:** Explain *intent*, not just potential.
    *   **Simplicity:** Avoid overengineering (e.g., complex Clean Architecture overkill) unless necessary. Keep it extendable but simple.
*   **Design:** "Wow" the user. Avoid generic flat designs. Use gradients, animations, and depth.
*   **UI Conventions**:
    *   **NEVER** hardcode colors. Always use `Theme.of(context).extension<SemanticColorsExtension>()` or `ColorScheme`.
    *   **NEVER** hardcode font sizes. Always use `Theme.of(context).extension<TextSizesExtension>()`.
    *   **Logging:** STRICTLY usage of `VarianceLogger` from `lib/core/utils/logger.dart` is enforced across the entire codebase. Do not use `print` or other logging packages.


## 5. Conventions & "Gotchas"
*   **Enums in Drift:** We use `textEnum<T>()` in `schema.dart`. This maps to the Enum in Dart but Text in SQLite.
*   **Testing Database:** ALWAYS use `AppDatabase.forTesting(NativeDatabase.memory())` in unit tests to ensure isolation.
*   **DEB Invariant:** NEVER create a transaction manually. ALWAYS use `TransactionRepository` which creates balanced ledger entries.
*   **Balance Computation:** NEVER assume balance is stored. ALWAYS call `AccountRepository.getAccountBalance()` which computes from ledger.
*   **Void, Don't Delete:** NEVER delete transactions. Call `voidTransaction()` to mark as void.
*   **Category Accounts:** Every category has a linked hidden account. ALWAYS use `CategoryRepository.createCategory()` which creates both.
*   **Repository API:** ALWAYS encapsulate `Drift` objects (Companions) inside the Repository. Public methods should accept named parameters with strict types.
*   **Lists:** `flutter_test` `testWidgets` is for Widgets. Use `test` for pure logic (even ChangeNotifier logic if no context is needed).
*   **User Preferences:** Use `SettingsProvider` (not ThemeProvider). It persists to `shared_preferences`. Access via `Provider.of<SettingsProvider>(context)`.
*   **Async Init:** `main()` is async. Preferences are loaded BEFORE `runApp()`. Never create `SettingsProvider` inside widget tree.
*   **SharedPreferences Testing:** ALWAYS set `SharedPreferences.setMockInitialValues({})` in `setUp()` for tests involving `SettingsProvider`.

## 6. Current Status & Next Steps
*   **Status:** Database Layer (DEB), UI Foundation, Settings Persistence (Phase 1), and Settings UI (Phase 2) are complete and verified.
*   **Immediate Needs:**
    *   **Entity Management (Phase 3):** Build CRUD screens for Accounts and Categories.
    *   Connect UI to the new Repository methods (Accounts List, Add Transaction forms).
    *   Implement "Recurring Transaction" engine to use new DEB template fields.
    *   Update `doc/database.md` to reflect new schema.

