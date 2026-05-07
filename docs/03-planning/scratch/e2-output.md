## Stories

## E2-S1 — Account Domain Entities + Repository Interface

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a developer, I want typed domain entities and a repository interface for accounts, so that all account feature work builds on a stable, dependency-free domain layer.

### Objectives

- Define `Account` and `AccountDetail` Freezed entities with all system fields (id, created_at, updated_at, is_deleted, deleted_at, is_protected, is_system, display_order)
- Define `IAccountRepository` abstract interface covering CRUD, watch, and balance-stream methods
- Define `CreateAccountParams` and `UpdateAccountParams` input value objects

### Definition of Done

- `Account` and `AccountDetail` entities compile with no Flutter imports
- `IAccountRepository` interface matches API contracts spec exactly
- All entity fields match Data Model §3.1 and §3.2

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## E2-S2 — Account DAO + Repository Implementation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a developer, I want a Drift DAO and repository implementation for accounts, so that all account use cases can persist and query data correctly.

### Objectives

- Implement `AccountDao` with queries for CRUD, soft-delete, name-uniqueness check, and balance stream
- Implement `AccountRepositoryImpl` backed by `AccountDao`
- Map Drift rows to/from domain `Account` entities via DTOs
- Register `AccountDao` and `AccountRepositoryImpl` providers in Riverpod DI graph

### Definition of Done

- `AccountDao` covers all `IAccountRepository` method shapes
- Name uniqueness check includes soft-deleted rows
- Balance stream emits on every `entries` write for the account within 1 s
- Repository provider wired into Riverpod graph
- Integration tests cover create/read/update/soft-delete on an in-memory DB

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## E2-S3 — Account CRUD Use Cases + Guard Rails

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to create, edit, and soft-delete accounts with all business rules enforced, so that my account data is always valid and consistent.

### Objectives

- Implement `CreateAccountUseCase`: validate input, check name uniqueness (including soft-deleted), post opening balance via `LedgerEngine` if non-zero, offer reinstatement when name+category match a soft-deleted account
- Implement `UpdateAccountUseCase`: validate editable fields, enforce account category immutability
- Implement `SoftDeleteAccountUseCase`: enforce last-account guard, set `is_deleted = true`
- Implement `WatchAccountsUseCase` and `GetAccountUseCase`
- Wire all use cases as Riverpod providers

### Definition of Done

- Creating an account with non-zero opening balance produces balanced `entries` rows; EQ account created atomically if it does not exist
- Name uniqueness rejects names matching soft-deleted accounts; reinstatement offer fires on name+category match
- Last-account guard prevents deletion when exactly one account exists
- All use cases return typed `Result<T, Failure>`
- Unit tests with mock repository cover all guard rails

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1 Account CRUD` (`docs/01-product/prd.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `TC-035: Soft-deleted entity reinstatement` (`docs/01-product/technical-clarifications.md`)
- `TC-045: EQ (Opening Balance equity account)` (`docs/01-product/technical-clarifications.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## E2-S4 — Account Category-Specific Fields (account_details)

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to enter and view category-specific fields for my accounts, so that I can track bank names, card numbers, billing dates, and other per-category metadata.

### Objectives

- Persist all 23 `detail_key` values to `account_details` via DAO
- Encrypt `card_number` and `account_number` fields at rest; reveal requires biometric/PIN auth
- Never store CVV
- Show loan installment suggestion post-save when `initial_balance < 0` or EMI fields provided

### Definition of Done

- All 23 detail keys save and reload correctly per their account category
- `card_number` and `account_number` stored in `detail_value_encrypted`; plain-text read requires auth
- CVV field is absent from all forms
- Loan installment suggestion bottom sheet fires on negative initial balance
- Widget tests verify encrypted field reveal flow

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2 Account Categories (Fixed Set — No Custom Categories)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `TC-013: Notification reschedule triggers on credit card field edits` (`docs/01-product/technical-clarifications.md`)

---

## E2-S5 — Account Balance Stream + Net Worth Aggregation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see real-time account balances and aggregate net worth, so that I always know my current financial position.

### Objectives

- Compute balance as `Σdebit − Σcredit` over non-void entries via Drift stream
- Aggregate net worth in home currency using `exchange_rate_to_home`; exclude soft-deleted and `include_in_net_worth = 0` accounts
- Show negative balances in warning color; show excluded-account balances grayed-out inline below net worth total
- Surface staleness indicator when exchange rate is >14 days old

### Definition of Done

- Balance stream emits updated value within 1 s of a new entry insert
- Net worth correctly excludes soft-deleted and excluded-flag accounts
- Negative balance renders in warning color token in widget test
- Performance: balance query completes in <500 ms for 10,000 entries (index on `entries(account_id, side)`)

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.4 Account Balance View` (`docs/01-product/prd.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `TC-045: EQ (Opening Balance equity account) — balance and auditability` (`docs/01-product/technical-clarifications.md`)

---

## E2-S6 — Account List Screen + Create/Edit Form

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see all my accounts grouped by category with balances, and create or edit accounts via a form, so that I can manage my financial accounts.

### Objectives

- Render account list grouped by account category with per-account balance and net worth summary card
- Show excluded-account section below net worth; empty state CTA when no accounts exist
- Account create form: name, account_category (9 values), initial_balance, currency, include_in_net_worth, notes, category-specific fields
- Account edit form: pre-populate all editable fields; disable account_category field; show currency immutability info tooltip

### Definition of Done

- Account list groups and balances update reactively via Riverpod stream provider
- FAB navigates to create form; row tap navigates to account detail
- Reinstatement dialog fires when name+category match a soft-deleted account
- All form validations fire inline; successful create/edit returns to list with updated state
- Widget tests cover empty state, grouped list render, and form validation errors

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.1.1 Create Account — Fields` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E2-S7 — Account Detail Screen

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to see all information about a single account — including balance, metadata, and transaction history — so that I can review and manage it in one place.

### Objectives

- Display account name, category, currency, current balance, notes, and category-specific fields
- Render per-account paginated transaction list (all months, cursor-based, 50 rows)
- Credit card accounts: show outstanding balance, statement balance, and Pay FAB
- Contextual menu: Edit, Soft-delete (with last-account guard), Reconcile

### Definition of Done

- Balance and transaction list update reactively
- Per-account transaction list is not month-filtered; paginates at 50 rows
- Pay FAB appears only on credit_card category accounts
- Soft-delete action shows confirmation dialog; blocked with tooltip when last account
- Widget tests cover credit card variant and empty transaction list

### References

- `ACC-04 — Account Detail Screen` (`docs/02-technical/feature-dag.md`)
- `5.1.3 Account Detail Screen` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)

---

## E2-S8 — Credit Card Payment Flow + Balance Reconciliation

**Parent Epic:** E-2 — Accounts Domain

**Story:** As a user, I want to pay my credit card balance and reconcile account balances, so that I can keep my accounts accurate.

### Objectives

- Pay FAB on credit card detail screen: pre-fill transfer form (source = linked bank account or picker, destination = credit card, amount = outstanding balance)
- Balance reconciliation: user enters actual balance; app computes delta; posts a Balance Adjustment income or expense transaction
- Overdraft warning: non-blocking inline warning when transaction would push asset balance below zero
- Credit limit warning: non-blocking inline warning when expense/transfer would exceed `credit_limit_minor`

### Definition of Done

- Pay FAB creates a transfer transaction with correct source/destination pre-filled
- Reconciliation delta posted as Balance Adjustment using `BAI`/`BAE` protected categories
- Overdraft and credit limit warnings render correctly in widget tests; they are non-blocking (user can proceed)

### References

- `ACC-05 — Credit Card Payment Flow` (`docs/02-technical/feature-dag.md`)
- `ACC-06 — Balance Reconciliation` (`docs/02-technical/feature-dag.md`)
- `5.1.5 Credit Card Payment` (`docs/01-product/prd.md`)
- `5.1.6 Balance Reconciliation` (`docs/01-product/prd.md`)
- `5.1.4.2 Overdraft warning` (`docs/01-product/prd.md`)
- `5.1.4.3 Credit card limit warning (FG-C18)` (`docs/01-product/prd.md`)

---

## Tasks

## E2-T1 — Define Account and AccountDetail Freezed domain entities

**Parent Epic:** E-2
**Parent Story:** E2-S1

### Todo

- [ ] Create `lib/domain/entities/account.dart` with all fields from Data Model §3.1: `id`, `name`, `account_category`, `currency_code`, `include_in_net_worth`, `notes`, `is_deleted`, `deleted_at`, `is_protected`, `is_system`, `display_order`, `created_at`, `updated_at`
- [ ] Create `lib/domain/entities/account_detail.dart` with fields: `id`, `account_id`, `detail_key`, `detail_value`, `detail_value_encrypted`, `created_at`, `updated_at`
- [ ] Annotate both with `@freezed`; run `build_runner`
- [ ] Confirm no Flutter or Drift imports in entity files

### References

- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## E2-T2 — Define IAccountRepository interface

**Parent Epic:** E-2
**Parent Story:** E2-S1

### Todo

- [ ] Create `lib/domain/repositories/i_account_repository.dart`
- [ ] Declare: `create`, `getById`, `update`, `softDelete`, `watchAll`, `watchById`, `watchBalance`, `isNameTaken`, `findSoftDeletedByNameAndCategory`
- [ ] All return types use `Result<T, Failure>` or `Stream<T>`; no Drift or Flutter imports

### References

- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## E2-T3 — Implement AccountDao

**Parent Epic:** E-2
**Parent Story:** E2-S2

### Todo

- [ ] Create `lib/data/daos/account_dao.dart` extending `DatabaseAccessor`
- [ ] Implement: `insertAccount`, `updateAccount`, `softDeleteAccount`, `findById`, `watchAll`, `watchById`, `isNameTaken` (includes soft-deleted), `findSoftDeletedByNameAndCategory`
- [ ] Implement `watchBalance(accountId)` as a Drift query: `SELECT SUM(debit_minor) - SUM(credit_minor) FROM entries WHERE account_id = ? AND status != 'voided'`
- [ ] Add index on `entries(account_id)` if not already present (Data Model §13)
- [ ] Implement `AccountDetailDao` for `account_details` key-value operations

### References

- `3.1 accounts` (`docs/02-technical/data-model.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## E2-T4 — Implement AccountRepositoryImpl and DTOs

**Parent Epic:** E-2
**Parent Story:** E2-S2

### Todo

- [ ] Create `lib/data/repositories/account_repository_impl.dart`
- [ ] Implement all `IAccountRepository` methods delegating to `AccountDao`
- [ ] Create `AccountDto` and `AccountDetailDto` to map Drift rows ↔ domain entities
- [ ] Register `accountRepositoryProvider` in Riverpod DI graph
- [ ] Integration tests: create/read/update/soft-delete against in-memory DB

### References

- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.2 Data Layer` (`docs/02-technical/sds.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)

---

## E2-T5 — Implement CreateAccountUseCase

**Parent Epic:** E-2
**Parent Story:** E2-S3

### Todo

- [ ] Create `lib/domain/usecases/accounts/create_account_use_case.dart`
- [ ] Validate: name non-empty, account_category valid enum, currency_code valid ISO 4217
- [ ] Call `isNameTaken`; if soft-deleted match found via `findSoftDeletedByNameAndCategory` return `ReinstateOfferFailure` with the soft-deleted account
- [ ] If `initial_balance ≠ 0`: call `LedgerEngine.post` with opening balance posting case (Cases 2.2a/2.2b from `ledger-entry.md`)
- [ ] Wrap account insert + entry post in single `database.transaction()`
- [ ] Return typed `Result<Account, Failure>`

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1 Account CRUD` (`docs/01-product/prd.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `TC-045: EQ (Opening Balance equity account) — balance and auditability` (`docs/01-product/technical-clarifications.md`)
- `Double-Entry Bookkeeping: All Posting Cases` (`docs/01-product/ledger-entry.md`)

---

## E2-T6 — Implement UpdateAccountUseCase and SoftDeleteAccountUseCase

**Parent Epic:** E-2
**Parent Story:** E2-S3

### Todo

- [ ] Create `lib/domain/usecases/accounts/update_account_use_case.dart`
  - [ ] Validate editable fields only (name, notes, include_in_net_worth, category-specific fields)
  - [ ] Enforce: account_category immutable; currency_code immutable
  - [ ] Run name uniqueness check if name changed
- [ ] Create `lib/domain/usecases/accounts/soft_delete_account_use_case.dart`
  - [ ] Count active accounts; return `LastAccountFailure` if count == 1
  - [ ] Set `is_deleted = true`, `deleted_at = now`
- [ ] Unit tests with mock repository for all guard-rail branches

### References

- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)
- `5.1.1.4 Edit` (`docs/01-product/prd.md`)
- `TC-035: Soft-deleted entity reinstatement` (`docs/01-product/technical-clarifications.md`)
- `2.1 IAccountRepository` (`docs/02-technical/api-contracts.md`)

---

## E2-T7 — Implement WatchAccountsUseCase and Riverpod account providers

**Parent Epic:** E-2
**Parent Story:** E2-S3

### Todo

- [ ] Create `WatchAccountsUseCase` (returns `Stream<List<Account>>` excluding system accounts)
- [ ] Create `GetAccountUseCase` (returns `Result<Account, Failure>`)
- [ ] Define `accountsProvider` as `StreamProvider<List<Account>>`
- [ ] Define `accountBalanceProvider(accountId)` as `StreamProvider<int>` (minor units)
- [ ] Define `netWorthProvider` as `Provider` that sums `accountBalanceProvider` × exchange rates for `include_in_net_worth` accounts

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `2.3 Riverpod Provider Graph` (`docs/02-technical/sds.md`)

---

## E2-T8 — Implement account_details persistence + encryption

**Parent Epic:** E-2
**Parent Story:** E2-S4

### Todo

- [ ] Implement `saveAccountDetails(accountId, List<AccountDetail>)` in `AccountDetailDao`
- [ ] For `detail_key` in `{'card_number', 'account_number'}`: write to `detail_value_encrypted` using `flutter_secure_storage` AES; leave `detail_value` null
- [ ] Implement `revealEncryptedDetail(accountId, detailKey)` — triggers biometric/PIN auth before returning plaintext
- [ ] Ensure CVV field is never written to either column
- [ ] Unit tests: write encrypted field → read without auth returns masked value; read with auth returns plaintext

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2 Account Categories (Fixed Set — No Custom Categories)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
- `2.3.3 Encryption` (`docs/02-technical/sds.md`)

---

## E2-T9 — Implement loan installment suggestion

**Parent Epic:** E-2
**Parent Story:** E2-S4

### Todo

- [ ] After successful account create, if `initial_balance < 0` OR (`emi_amount_minor` present AND `emi_date` present): show `LoanInstallmentSuggestionSheet`
- [ ] Bottom sheet pre-fills recurring template form: destination = this loan account, amount = emi_amount, recurrence = monthly on emi_date, start = today
- [ ] "Set up installment" CTA navigates to recurring template create flow; "Not now" dismisses
- [ ] Widget test: negative-balance account create → suggestion sheet appears; positive-balance → no sheet

### References

- `ACC-02 — Account Category-Specific Fields` (`docs/02-technical/feature-dag.md`)
- `5.1.2.1 Linked bank account — behaviour by account category` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)

---

## E2-T10 — Implement balance stream + net worth aggregation logic

**Parent Epic:** E-2
**Parent Story:** E2-S5

### Todo

- [ ] Verify `watchBalance` Drift query uses index on `entries(account_id, side)` — add if missing
- [ ] Implement `NetWorthCalculator` domain service: sums balances × `exchange_rate_to_home` for `include_in_net_worth = 1 AND is_deleted = 0` accounts
- [ ] Handle missing exchange rate: exclude from sum; return `hasStaleRates` flag
- [ ] Performance test: balance query < 500 ms with 10,000 entry rows on in-memory DB

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `1.4.4 Account Balance Read` (`docs/02-technical/sds.md`)
- `5.1.4 Account Balance View` (`docs/01-product/prd.md`)
- `13. Index Definitions` (`docs/02-technical/data-model.md`)

---

## E2-T11 — Build AccountListScreen and net worth card

**Parent Epic:** E-2
**Parent Story:** E2-S6

### Todo

- [ ] Create `lib/presentation/accounts/account_list_screen.dart`
- [ ] Net worth summary card at top: total in home currency, staleness indicator if `hasStaleRates`
- [ ] Accounts grouped by account_category with section headers; each row: name, balance, currency symbol (disambiguated)
- [ ] Excluded accounts section below net worth: grayed-out, "excluded" chip
- [ ] FAB → `/accounts/new`; row tap → `/accounts/:id`
- [ ] Empty state CTA when no accounts
- [ ] Widget tests: grouped render, empty state, negative balance color

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5.1.4.1 Negative balance visual treatment` (`docs/01-product/prd.md`)

---

## E2-T12 — Build AccountFormScreen (create + edit modes)

**Parent Epic:** E-2
**Parent Story:** E2-S6

### Todo

- [ ] Create `lib/presentation/accounts/account_form_screen.dart`; accepts optional `Account` for edit mode
- [ ] Fields: name, account_category (dropdown, disabled in edit), currency (searchable, with immutability info tooltip in edit), initial_balance (hidden in edit), include_in_net_worth toggle, notes
- [ ] Render category-specific fields section below common fields based on selected `account_category`
- [ ] Inline validation for all required fields
- [ ] On submit: call `CreateAccountUseCase` or `UpdateAccountUseCase`; handle `ReinstateOfferFailure` → show reinstatement dialog
- [ ] Widget tests: edit mode disables category field; reinstatement dialog fires on name conflict

### References

- `5.1.1.1 Create Account — Fields` (`docs/01-product/prd.md`)
- `5.1.1.2 Currency Immutability` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `ACC-01 — Account CRUD` (`docs/02-technical/feature-dag.md`)

---

## E2-T13 — Build AccountDetailScreen

**Parent Epic:** E-2
**Parent Story:** E2-S7

### Todo

- [ ] Create `lib/presentation/accounts/account_detail_screen.dart`
- [ ] Header: name, category badge, currency, current balance (warning color if negative)
- [ ] Category-specific fields section (encrypted fields show masked value with "Reveal" button)
- [ ] Per-account transaction list: cursor-paginated, 50 rows, all months, reverse chronological; stub with empty list until TXN epic lands
- [ ] Toolbar: Edit action → AccountFormScreen in edit mode
- [ ] Overflow menu: Soft-delete (with last-account guard tooltip), Reconcile
- [ ] Credit card variant: outstanding balance chip, statement balance chip, Pay FAB
- [ ] Widget tests: credit card variant shows Pay FAB; non-credit-card does not; empty list empty state

### References

- `ACC-04 — Account Detail Screen` (`docs/02-technical/feature-dag.md`)
- `5.1.3 Account Detail Screen` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)

---

## E2-T14 — Implement credit card payment flow

**Parent Epic:** E-2
**Parent Story:** E2-S8

### Todo

- [ ] Pay FAB on credit card detail screen: pre-fill transfer entry form with destination = this credit card, amount = outstanding balance, source = linked bank account (from `account_details`) or account picker if not set
- [ ] Navigate to transaction entry form pre-filled; user can adjust before submitting
- [ ] Widget test: Pay FAB appears on credit_card accounts only; tapping opens pre-filled transfer form

### References

- `ACC-05 — Credit Card Payment Flow` (`docs/02-technical/feature-dag.md`)
- `5.1.5 Credit Card Payment` (`docs/01-product/prd.md`)
- `3. Accounts` (`docs/02-technical/ux-flows.md`)

---

## E2-T15 — Implement balance reconciliation

**Parent Epic:** E-2
**Parent Story:** E2-S8

### Todo

- [ ] Reconcile action on account detail overflow menu → `ReconcileScreen`
- [ ] `ReconcileScreen`: show current computed balance; user enters actual balance; app computes delta
- [ ] If delta > 0: post Balance Adjustment income (BAI category, `is_protected = 1`); if delta < 0: post BAE expense
- [ ] Post via `LedgerEngine`; navigate back on success
- [ ] Widget test: positive delta posts BAI; negative delta posts BAE

### References

- `ACC-06 — Balance Reconciliation` (`docs/02-technical/feature-dag.md`)
- `5.1.6 Balance Reconciliation` (`docs/01-product/prd.md`)
- `TC-046: BAI and BAE (Balance Adjustment categories)` (`docs/01-product/technical-clarifications.md`)

---

## E2-T16 — Implement overdraft and credit limit warnings

**Parent Epic:** E-2
**Parent Story:** E2-S8

### Todo

- [ ] In transaction entry form ViewModel: after amount + account are filled, compute projected balance
- [ ] If asset account and projected balance < 0: show inline `OverdraftWarningBanner` (non-blocking — user can still submit)
- [ ] If credit card account and projected balance (outstanding) would exceed `credit_limit_minor`: show inline `CreditLimitWarningBanner` (non-blocking)
- [ ] Widget tests: overdraft banner appears on asset account with insufficient balance; credit limit banner appears on credit card over limit; both allow submission

### References

- `ACC-03 — Account Balance View + Net Worth` (`docs/02-technical/feature-dag.md`)
- `5.1.4.2 Overdraft warning` (`docs/01-product/prd.md`)
- `5.1.4.3 Credit card limit warning (FG-C18)` (`docs/01-product/prd.md`)
- `3.2 account_details` (`docs/02-technical/data-model.md`)
