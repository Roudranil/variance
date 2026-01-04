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
*   **Theming Architecture:** Established `lib/core/theme` with `ThemeProvider` and `AppTheme`.
*   **Extensions:**
    *   `SemanticColorsExtension`: Maps business logic (Income/Expense) to Catppuccin colors (Green/Red).
    *   `TextSizesExtension`: Implements proper Tailwind scale as `doubles` (e.g., `textXl`) with adjustable `scaleFactor`.
*   **Integration:** `MultiProvider` + `DynamicColorBuilder` in `main.dart`.
*   **Verification:** Full suite of Unit Tests covering all Extensions, Providers, and Theme Definitions.

### Database & Schema
*   **Schema Design:** Fully defined using Drift. Tables: `Accounts`, `Categories`, `Transactions`, `Tags`, `RecurringPatterns`.
*   **Type Safety:** Replaced raw strings with Dart Enums (`AccountType`, `CategoryKind`, `TransactionType`, `RecurringFrequency`, `RecurringType`).
*   **Features Implemented:**
    *   **Soft Deletes:** `isDeleted` boolean column added to key tables.
    *   **One-way Data Flow:** `includeInTotals` flag for Accounts.
    *   **Cascading Logic:** `TransactionRepository` handles complex updates by reverting old balances and applying new ones.
    *   **Auto-Adjustment:** `AccountRepository` automatically creates `adjustment` transactions when the user manually edits a balance.
    *   **Verification:** Comprehensive Unit Test suite covering CRUD, Double-Entry Logic, and Soft Deletes (100% Pass Rate).

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
*   **Double Entry Enforcement:** NEVER manually update `currentBalance` in `Accounts` without a corresponding `Transaction` record (or use the `updateAccount` method which handles this).
*   **Repository API:** ALWAYS encapsulate `Drift` objects (Companions) inside the Repository. Public methods should accept named parameters with strict types.
*   **Lists:** `flutter_test` `testWidgets` is for Widgets. Use `test` for pure logic (even ChangeNotifier logic if no context is needed).

## 6. Current Status & Next Steps
*   **Status:** Database Layer and UI Foundation are complete and verified.
*   **Immediate Needs:**
    *   Build the Main Dashboard Shell (Bottom Nav, App Bar).
    *   Connect UI to the Repository methods (Accounts List, Add Transaction).
    *   Implement "Recurring Transaction" engine.
