## Stories

## E3-S1 — Transaction Domain Entities + Repository Interface

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a developer, I want typed domain entities and a repository interface for transactions, so that all transaction feature work builds on a stable domain layer.

### Objectives

- Define `Transaction`, `Entry`, `Tag`, `CompoundGroup` Freezed entities with all fields from Data Model §3.3–§3.4
- Define `ITransactionRepository` abstract interface covering CRUD, watch, paginated list, and FTS5 search
- Define `CreateTransactionParams`, `UpdateTransactionParams` input value objects

### Definition of Done

- All entities compile with no Flutter imports
- `ITransactionRepository` matches API contracts exactly
- `type` field defined as immutable sealed enum (income/expense/transfer)

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## E3-S2 — Transaction DAO + Repository Implementation

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a developer, I want a Drift DAO and repository implementation for transactions, so that all transaction use cases can persist and query data correctly.

### Objectives

- Implement `TransactionDao` with queries for insert, soft-delete, paginated watch, per-account list, and FTS5 search
- Implement `TransactionRepositoryImpl` backed by `TransactionDao`
- Map Drift rows to/from domain entities via DTOs
- Register providers in Riverpod DI graph

### Definition of Done

- `TransactionDao` covers all `ITransactionRepository` shapes
- Paginated query uses cursor (last `date_time` + `id`) not OFFSET
- FTS5 insert trigger keeps `transactions_fts` in sync on every insert
- Integration tests cover create/read/soft-delete on in-memory DB

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)

---

## E3-S3 — Transaction Entry Form — Income + Expense

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to create income and expense transactions via a form, so that my account balances stay accurate.

### Objectives

- Form fields: type toggle (income/expense), amount, account picker, category + subcategory picker, date/time, title, description, tags
- On submit: call `LedgerEngine.post` → `TransactionRepository.save` in single ACID transaction; invalidate `transactionsProvider` and `accountBalanceProvider`
- Duplicate detection: non-blocking warning on matching type + amount + account + category on same calendar day
- Amount stored as minor units; `currency_code` derived from account (immutable after save)

### Definition of Done

- Saving income or expense produces balanced `entries` rows with `status = 'posted'`, `purpose = 'user'`
- Account balance updates reactively after save
- Duplicate detection warning appears but does not block save
- `description` max length enforced per `app_settings.description_max_length`
- Widget tests cover field validation, duplicate warning, and successful save state

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-S4 — Transaction Entry Form — Transfer with Fee

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to record transfers between accounts including optional fees, so that my ledger correctly reflects cross-account movements.

### Objectives

- Transfer form fields: source account, destination account, amount, exchange rate (cross-currency), date/time, title, description, tags; optional fee leg
- Cross-currency transfer: capture `exchange_rate_micro` on transaction row
- Transfer-with-fee: create compound group (`compound_group_id`, `compound_role`) — primary leg + fee leg in same DB transaction
- `type` immutable after save; no `category_id` on transfers

### Definition of Done

- Transfer creates balanced entries for both source and destination accounts
- Cross-currency transfer stores `exchange_rate_micro`; both account balances update correctly
- Fee leg creates a second transaction row with `compound_role = 'fee'` in same `compound_group_id`
- Widget tests cover same-currency, cross-currency, and with-fee variants

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## E3-S5 — Transaction Immutability + Correction Model

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want edits to financial fields on posted transactions to produce a correction chain, so that my ledger history is always auditable and immutable.

### Objectives

- Financial-field edit: void original (`status → voided`), post reversal row (`purpose = 'reversal'`), post correction row (`purpose = 'correction'`)
- In-place edit fields (no correction): `title`, `description`, `photos`, `date_time`
- Soft-delete: void original, post reversal; no correction row
- Correction chain: `corrects_transaction_id` points to immediately preceding transaction

### Definition of Done

- Editing `amount_minor`, `account_source_id`, `category_id` on a posted transaction produces void + reversal + correction
- Editing `title` or `description` updates the row directly; no new entries written
- Voided transactions excluded from default list and balance computation
- No transaction ever permanently deleted
- Unit tests cover all correction-chain branches including correcting a correction

### References

- `TXN-02 — Transaction Immutability + Correction Model` (`docs/02-technical/feature-dag.md`)
- `5.2.2 Transaction Immutability & Editing` (`docs/01-product/prd.md`)
- `1.6.7 Transaction Immutability and Correction Model` (`docs/02-technical/sds.md`)
- `3.3.1 Correction Chain` (`docs/02-technical/data-model.md`)
- `TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md` (`docs/01-product/technical-clarifications.md`)

---

## E3-S6 — Transaction Detail View

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to tap a transaction and see all its details, so that I can review and act on it.

### Objectives

- Show all §5.2.1.6 fields: type, amount, account(s), category, date/time, title, description, exchange rate, fee breakdown, tags, photos
- Photo carousel: up to 2 photos, full-screen tap, per-photo delete action
- Contextual menu: Edit (opens entry form), Soft-delete (confirmation dialog)
- Pending transactions: all fields freely editable in-place (correction model does NOT apply)

### Definition of Done

- All v1 fields from §5.2.1.6 present and correctly populated
- Compound transfer-with-fee shows fee breakdown section
- Photo carousel shows up to 2 photos; deleting a photo removes both `attachments` row and physical file
- Edit action opens pre-filled entry form; soft-delete triggers confirmation then voids transaction
- Widget tests cover compound transfer detail and empty photo carousel

### References

- `TXN-03 — Transaction Detail View` (`docs/02-technical/feature-dag.md`)
- `5.2.1.5 Transaction Detail View` (`docs/01-product/prd.md`)
- `5.2.1.6 v1 contents` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-S7 — Photo Attachments

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to attach photos to transactions, so that I can keep receipts alongside my records.

### Objectives

- Attach up to 2 photos per transaction (camera or gallery)
- Compress: JPEG, max 1920px, target < 500KB (quality 85 → iterative 5-point reduction, floor 60)
- Store in app-private directory; `attachments` row records relative path + metadata
- Delete physical file when transaction voided

### Definition of Done

- Up to 2 photos attachable; 3rd photo blocked with message
- Compressed output is JPEG ≤ 500KB in all widget test scenarios
- `attachments` rows and physical files deleted on transaction soft-delete
- Missing file on delete is handled idempotently (no crash)

### References

- `TXN-04 — Photo Attachments` (`docs/02-technical/feature-dag.md`)
- `5.2.3 Photo Attachments` (`docs/01-product/prd.md`)
- `2.15 Photo Compression` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `TC-007: Photo compression parameters` (`docs/01-product/technical-clarifications.md`)

---

## E3-S8 — Transaction List — Unified + Per-Account

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to browse all my transactions in a paginated list grouped by date, so that I can quickly review my recent financial activity.

### Objectives

- Unified list (home screen): month-filtered, cursor-paginated at 50 rows, grouped by date, excludes voided and reversal rows by default
- Per-account list (account detail screen): all months, same pagination and grouping
- Each row: type icon, title, category, amount, account name
- Swipe-to-delete and long-press contextual menu

### Definition of Done

- Both lists paginate correctly at 50 rows using cursor (not OFFSET)
- Date-group headers re-render correctly when month changes
- Voided and reversal rows excluded from default filter
- Swipe-to-delete fires confirmation; long-press opens contextual menu
- Widget tests cover empty month, multi-page scroll, and voided exclusion

### References

- `TXN-05 — Transaction List (Unified)` (`docs/02-technical/feature-dag.md`)
- `TXN-12 — Per-Account Transaction List` (`docs/02-technical/feature-dag.md`)
- `5.2.4 Transaction List` (`docs/01-product/prd.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## E3-S9 — Duplicate Detection + Warning

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want a warning when I try to save a transaction that looks like a duplicate, so that I avoid accidentally recording the same transaction twice.

### Objectives

- Detect: same type + amount + account + category on same calendar day (transfers: type + amount + source + destination)
- Non-blocking: warning shown but save is not blocked
- Warning includes matched transaction details; user can dismiss and proceed

### Definition of Done

- Duplicate check fires on every save attempt before calling `LedgerEngine.post`
- Warning bottom sheet shows matched transaction title, date, amount
- Dismissing warning proceeds with save normally
- Unit tests cover all detection combinations (income, expense, transfer)

### References

- `TXN-06 — Duplicate Detection` (`docs/02-technical/feature-dag.md`)
- `5.2.1.8 Duplicate detection` (`docs/01-product/prd.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## E3-S10 — Transaction Search — FTS5

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to search my transactions by title and description, so that I can quickly find specific transactions.

### Objectives

- Global FTS5 search (not month-scoped) over `title` and `description`
- Results ranked by relevance; partial matches supported
- Clearing search re-engages the active month filter
- Search results use same list row widget as transaction list

### Definition of Done

- FTS5 query returns results within 500 ms for 10,000 transactions
- Partial title and description matches return results
- Clearing search input returns to month-filtered list
- Widget tests cover empty results state and partial match rendering

### References

- `TXN-08 — Transaction Search` (`docs/02-technical/feature-dag.md`)
- `5.2.5 Search` (`docs/01-product/prd.md`)
- `1.4.3 FTS5 Search` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## E3-S11 — Transaction Filter Sheet

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to filter my transaction list by date range, account, category, and type, so that I can focus on specific subsets of my transactions.

### Objectives

- Filter criteria: date range, account (multi-select), category (multi-select), transaction type, amount range
- Filter sheet applied on top of month-filtered or search-results list
- Active filter chip strip below search bar; each chip dismissible
- Filter state persisted in `FilterNotifier` (Riverpod); cleared on month change

### Definition of Done

- All filter criteria apply correctly and compose with each other
- Filter chip strip reflects active filters; tapping chip removes that criterion
- Filter sheet dismissal without change leaves existing filter intact
- Widget tests cover multi-criterion filter and chip dismissal

### References

- `TXN-09 — Transaction Filter` (`docs/02-technical/feature-dag.md`)
- `5.2.6 Filter` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-S12 — Future-Dated + Pending Transactions

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want to record future-dated transactions that stay pending until their date, so that I can plan ahead without affecting current balances.

### Objectives

- Transaction with `date_time > now` saved with `status = 'pending'`; excluded from balance computation until posted
- App-launch sweep (SCHED-01) posts pending transactions when `date_time <= now`
- Pending transactions shown in future-month lists; "Pending" badge on list row
- All fields freely editable on pending transactions (correction model does not apply)

### Definition of Done

- Pending transaction excluded from `watchBalance` result until `status = 'posted'`
- Sweep posts pending transactions in chronological order; balance updates reactively after each post
- "Pending" badge renders on list row in widget test
- Edit form for pending transaction has all fields unlocked

### References

- `TXN-10 — Future-Dated Transactions` (`docs/02-technical/feature-dag.md`)
- `TXN-11 — Pending Transaction Management` (`docs/02-technical/feature-dag.md`)
- `5.2.7 Pending Transactions` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## E3-S13 — Transaction Drafts

**Parent Epic:** E-3 — Transactions Domain

**Story:** As a user, I want my half-filled transaction form to be saved as a draft when I navigate away, so that I don't lose my work.

### Objectives

- Auto-save draft when back button pressed (if `back_button_behaviour = auto_save_draft`)
- 5-slot FIFO draft queue stored in `app_settings`
- Draft resume entry point from FAB (when draft exists) and home screen alert
- Explicit discard clears the draft slot

### Definition of Done

- Draft saved on back navigation when setting enabled
- 6th draft evicts the oldest; FIFO order preserved
- FAB shows "Resume draft" option when draft exists
- Discarding draft clears slot; resuming draft pre-populates form
- Widget tests cover FIFO eviction and resume pre-population

### References

- `DRAFT-01 — Transaction Drafts` (`docs/02-technical/feature-dag.md`)
- `5.2.8 Drafts` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## Tasks

## E3-T1 — Define Transaction, Entry, Tag Freezed domain entities

**Parent Epic:** E-3
**Parent Story:** E3-S1

### Todo

- [ ] Create `lib/domain/entities/transaction.dart` with all fields from Data Model §3.3: `id`, `type`, `amount_minor`, `currency_code`, `account_source_id`, `account_destination_id`, `category_id`, `subcategory_id`, `title`, `description`, `date_time`, `status`, `purpose`, `corrects_transaction_id`, `compound_group_id`, `compound_role`, `exchange_rate_micro`, `created_at`, `updated_at`
- [ ] Create `lib/domain/entities/entry.dart` with fields from Data Model §3.4
- [ ] Create `lib/domain/entities/tag.dart`
- [ ] Annotate all with `@freezed`; run `build_runner`
- [ ] Confirm `type` is a sealed enum (`income`, `expense`, `transfer`); no Flutter imports

### References

- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `TC-024: Transaction entity — complete field enumeration and data types` (`docs/01-product/technical-clarifications.md`)
- `1.3.1 Domain Layer` (`docs/02-technical/sds.md`)

---

## E3-T2 — Define ITransactionRepository interface

**Parent Epic:** E-3
**Parent Story:** E3-S1

### Todo

- [ ] Create `lib/domain/repositories/i_transaction_repository.dart`
- [ ] Declare: `save`, `getById`, `softDelete`, `watchPaginated`, `watchByAccount`, `search`, `findDuplicates`, `saveDraft`, `getDrafts`, `deleteDraft`
- [ ] All return types use `Result<T, Failure>` or `Stream<T>`; no Drift imports

### References

- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## E3-T3 — Implement TransactionDao

**Parent Epic:** E-3
**Parent Story:** E3-S2

### Todo

- [ ] Create `lib/data/daos/transaction_dao.dart`
- [ ] Implement: `insertTransaction`, `softDeleteTransaction`, `watchPaginated(month, cursor)`, `watchByAccount(accountId, cursor)`, `getById`
- [ ] Cursor pagination: `WHERE (date_time, id) < (cursor_date, cursor_id) ORDER BY date_time DESC, id DESC LIMIT 50`
- [ ] Implement `EntryDao` for `entries` table inserts (entries are never updated)
- [ ] Confirm FTS5 insert trigger exists in schema; test that `transactions_fts` is updated on insert

### References

- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `3.4 entries` (`docs/02-technical/data-model.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## E3-T4 — Implement TransactionRepositoryImpl and DTOs

**Parent Epic:** E-3
**Parent Story:** E3-S2

### Todo

- [ ] Create `lib/data/repositories/transaction_repository_impl.dart`
- [ ] Implement all `ITransactionRepository` methods delegating to `TransactionDao`
- [ ] `TransactionDto` maps Drift row ↔ `Transaction` entity; `EntryDto` maps row ↔ `Entry`
- [ ] Register `transactionRepositoryProvider` in Riverpod DI graph
- [ ] Integration tests: create income, expense, transfer on in-memory DB; verify `entries` rows created correctly

### References

- `2.2 ITransactionRepository` (`docs/02-technical/api-contracts.md`)
- `1.3.2 Data Layer` (`docs/02-technical/sds.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## E3-T5 — Implement CreateTransactionUseCase (income + expense)

**Parent Epic:** E-3
**Parent Story:** E3-S3

### Todo

- [ ] Create `lib/domain/usecases/transactions/create_transaction_use_case.dart`
- [ ] Validate: amount > 0, account exists, category exists (income/expense require category_id), `date_time` not null
- [ ] Call `LedgerEngine.post(CreateTransactionInput)` → get balanced entry set
- [ ] Call `TransactionRepository.save(transaction, entries)` in single `database.transaction()`
- [ ] Invalidate `transactionsProvider` and `accountBalanceProvider` after commit
- [ ] Return typed `Result<Transaction, Failure>`

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `1.4.1 User-Initiated Write — Transaction Creation` (`docs/02-technical/sds.md`)
- `1.6.2 ACID Atomicity for All Ledger Operations` (`docs/02-technical/sds.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)

---

## E3-T6 — Implement CreateTransactionUseCase (transfer + cross-currency + fee leg)

**Parent Epic:** E-3
**Parent Story:** E3-S4

### Todo

- [ ] Extend `CreateTransactionUseCase` for transfer type: require `account_source_id`, `account_destination_id`; no `category_id`
- [ ] Cross-currency: require `exchange_rate_micro` when source and destination currencies differ; store on transaction row
- [ ] Transfer-with-fee: generate `compound_group_id` (UUID v4); create primary leg with `compound_role = 'primary'`; create fee leg with `compound_role = 'fee'` in same DB transaction
- [ ] Unit tests: same-currency transfer, cross-currency transfer, transfer with fee

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `4.5 Transaction Rules by Type` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
- `TC-024: Transaction entity — complete field enumeration and data types` (`docs/01-product/technical-clarifications.md`)

---

## E3-T7 — Build transaction entry form (income/expense)

**Parent Epic:** E-3
**Parent Story:** E3-S3

### Todo

- [ ] Create `lib/presentation/transactions/transaction_form_screen.dart`
- [ ] Fields: type toggle, amount (minor units), account picker (grouped by category), category + subcategory picker (excludes protected categories), date/time picker, title, description (max length from settings), tags
- [ ] Inline validation for required fields; submit button disabled until valid
- [ ] On submit: call `CreateTransactionUseCase`; show `DuplicateWarningSheet` if duplicate detected (non-blocking); navigate back on success
- [ ] Widget tests: field validation, duplicate warning dismissal, successful submit state

### References

- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## E3-T8 — Build transaction entry form (transfer variant)

**Parent Epic:** E-3
**Parent Story:** E3-S4

### Todo

- [ ] Extend `TransactionFormScreen` for transfer type: show source + destination account pickers; hide category picker; show exchange rate field when currencies differ; show optional fee row
- [ ] Fee row: toggle to add fee; fee amount + account fields appear when enabled
- [ ] Widget tests: same-currency hides exchange rate; cross-currency shows rate field; fee toggle shows fee fields

### References

- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)
- `5.2.1 Transaction Entry` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)

---

## E3-T9 — Implement CorrectTransactionUseCase

**Parent Epic:** E-3
**Parent Story:** E3-S5

### Todo

- [ ] Create `lib/domain/usecases/transactions/correct_transaction_use_case.dart`
- [ ] Determine if changed fields are financial (trigger correction) or in-place (direct update)
- [ ] Financial edit path: set original `status = 'voided'`; post reversal (same fields, entries flipped); post correction (new financial values); link via `corrects_transaction_id`
- [ ] In-place path: `UPDATE transactions SET title/description/date_time/... WHERE id = ?`; no new entries
- [ ] Soft-delete path: void + reversal; no correction row
- [ ] All paths wrapped in single `database.transaction()`
- [ ] Unit tests for all 3 paths; correction-of-correction chain test

### References

- `TXN-02 — Transaction Immutability + Correction Model` (`docs/02-technical/feature-dag.md`)
- `1.6.7 Transaction Immutability and Correction Model` (`docs/02-technical/sds.md`)
- `3.3.1 Correction Chain` (`docs/02-technical/data-model.md`)
- `11.3 Void/Reversal Chain Policy` (`docs/02-technical/data-model.md`)
- `TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md` (`docs/01-product/technical-clarifications.md`)

---

## E3-T10 — Build TransactionDetailScreen

**Parent Epic:** E-3
**Parent Story:** E3-S6

### Todo

- [ ] Create `lib/presentation/transactions/transaction_detail_screen.dart`
- [ ] Render all §5.2.1.6 fields: type, amount + currency, account(s), category, date/time, title, description, exchange rate (cross-currency only), fee breakdown (compound group), tags
- [ ] Photo carousel: `PageView` with max 2 photos; full-screen tap opens `PhotoViewScreen`; per-photo delete button (confirmation → deletes `attachments` row + physical file)
- [ ] Top-right overflow menu: Edit → `TransactionFormScreen` pre-filled; Soft-delete → confirmation dialog
- [ ] Pending transaction: all overflow menu fields available for in-place edit
- [ ] Widget tests: compound transfer detail, empty photo carousel, pending transaction edit mode

### References

- `TXN-03 — Transaction Detail View` (`docs/02-technical/feature-dag.md`)
- `5.2.1.6 v1 contents` (`docs/01-product/prd.md`)
- `3. Transaction Entry` (`docs/02-technical/ux-flows.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-T11 — Implement photo attach, compress, and delete

**Parent Epic:** E-3
**Parent Story:** E3-S7

### Todo

- [ ] `PhotoService`: pick from camera or gallery via `image_picker`
- [ ] Compress pipeline: `flutter_image_compress` → JPEG quality 85; if > 500KB, reduce by 5 points per iteration; floor = 60; max dimension 1920px; no upscaling
- [ ] Save to `getApplicationDocumentsDirectory()/attachments/{txn_id}/{uuid}.jpg`
- [ ] Insert `attachments` row with relative path, `mime_type = 'image/jpeg'`, file size
- [ ] `deletePhoto(attachmentId)`: delete `attachments` row first; then delete file (missing file = no error)
- [ ] `deleteAllPhotosForTransaction(txnId)`: called on transaction void
- [ ] Unit tests: compression output ≤ 500KB; 3rd photo add blocked; missing file idempotent delete

### References

- `TXN-04 — Photo Attachments` (`docs/02-technical/feature-dag.md`)
- `2.15 Photo Compression` (`docs/02-technical/sds.md`)
- `5.1 attachments` (`docs/02-technical/data-model.md`)
- `TC-007: Photo compression parameters` (`docs/01-product/technical-clarifications.md`)

---

## E3-T12 — Build TransactionListScreen (unified + per-account)

**Parent Epic:** E-3
**Parent Story:** E3-S8

### Todo

- [ ] Create `lib/presentation/transactions/transaction_list_screen.dart` (unified, month-filtered)
- [ ] `TransactionListNotifier`: cursor-paginated `StreamProvider`; loads next page on scroll-to-bottom; default filter excludes `status = 'voided'` and `purpose = 'reversal'`
- [ ] Row widget: type icon, title, category, amount (warning color for expense/debit), account name
- [ ] Date-group headers render inline; pending badge on `status = 'pending'` rows
- [ ] Swipe-to-delete: confirmation → `SoftDeleteTransactionUseCase`
- [ ] Long-press contextual menu: Edit, Delete, Duplicate
- [ ] Per-account variant: same widget with `accountId` filter; no month scope
- [ ] Widget tests: empty month, pagination trigger, voided exclusion, pending badge

### References

- `TXN-05 — Transaction List (Unified)` (`docs/02-technical/feature-dag.md`)
- `TXN-12 — Per-Account Transaction List` (`docs/02-technical/feature-dag.md`)
- `1.4.2 Cursor-Based Pagination` (`docs/02-technical/sds.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-T13 — Implement duplicate detection

**Parent Epic:** E-3
**Parent Story:** E3-S9

### Todo

- [ ] Add `findDuplicates(type, amountMinor, accountId, categoryId, date)` to `TransactionDao`
- [ ] Query: `SELECT * FROM transactions WHERE type = ? AND amount_minor = ? AND account_source_id = ? AND category_id = ? AND DATE(date_time) = DATE(?) AND status = 'posted' LIMIT 1`
- [ ] Transfer variant: match on `account_source_id` + `account_destination_id` instead of category
- [ ] In `CreateTransactionUseCase`: call before `LedgerEngine.post`; if match found, return `DuplicateWarningResult(matchedTransaction)` — caller decides to proceed or abort
- [ ] Build `DuplicateWarningSheet`: show matched transaction; "Save anyway" proceeds; "Cancel" returns to form
- [ ] Unit tests: all type variants; no false positive when fields differ

### References

- `TXN-06 — Duplicate Detection` (`docs/02-technical/feature-dag.md`)
- `5.2.1.8 Duplicate detection` (`docs/01-product/prd.md`)
- `TXN-01 — Transaction Entry (Income / Expense / Transfer)` (`docs/02-technical/feature-dag.md`)

---

## E3-T14 — Implement FTS5 search

**Parent Epic:** E-3
**Parent Story:** E3-S10

### Todo

- [ ] Add `search(query, cursor)` to `TransactionDao`: `SELECT * FROM transactions JOIN transactions_fts ON transactions.id = transactions_fts.rowid WHERE transactions_fts MATCH ? ORDER BY rank LIMIT 50`
- [ ] Implement `SearchNotifier` in Riverpod: debounce 300 ms; on query change triggers FTS search; on clear reverts to month-filtered `transactionsProvider`
- [ ] Build search bar overlay in home screen using `SearchAnchor` M3 widget
- [ ] Performance test: FTS query < 500 ms for 10,000 rows on test device

### References

- `TXN-08 — Transaction Search` (`docs/02-technical/feature-dag.md`)
- `1.4.3 FTS5 Search` (`docs/02-technical/sds.md`)
- `5.2.5 Search` (`docs/01-product/prd.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)

---

## E3-T15 — Build transaction filter sheet

**Parent Epic:** E-3
**Parent Story:** E3-S11

### Todo

- [ ] Create `FilterState` Freezed class: `dateRange`, `accountIds`, `categoryIds`, `types`, `amountRange`
- [ ] Create `FilterNotifier` (Riverpod `StateNotifier`); clear on month change
- [ ] Build `FilterSheet` bottom sheet: date range picker, account multi-select, category multi-select, type chips, amount range slider
- [ ] Build `ActiveFilterChipStrip` widget below search bar; each chip has × dismiss
- [ ] Update `TransactionListNotifier` to apply `FilterState` to its query

### References

- `TXN-09 — Transaction Filter` (`docs/02-technical/feature-dag.md`)
- `5.2.6 Filter` (`docs/01-product/prd.md`)
- `5. Screens` (`docs/02-technical/ui-spec.md`)

---

## E3-T16 — Implement future-dated + pending transaction flow

**Parent Epic:** E-3
**Parent Story:** E3-S12

### Todo

- [ ] In `CreateTransactionUseCase`: if `date_time > now`, save with `status = 'pending'`; entries NOT written at save time
- [ ] `watchBalance` Drift query must exclude `status = 'pending'` rows
- [ ] Future-month list shows pending transactions with "Pending" badge
- [ ] App-launch sweep integration (SCHED-01 dependency): `PostPendingTransactionsUseCase` posts entries for `status = 'pending' AND date_time <= now`; sets `status = 'posted'`
- [ ] Edit form for pending transaction: all fields unlocked; submit updates in-place (no correction model)

### References

- `TXN-10 — Future-Dated Transactions` (`docs/02-technical/feature-dag.md`)
- `TXN-11 — Pending Transaction Management` (`docs/02-technical/feature-dag.md`)
- `5.2.7 Pending Transactions` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)

---

## E3-T17 — Implement transaction drafts

**Parent Epic:** E-3
**Parent Story:** E3-S13

### Todo

- [ ] `DraftRepository`: serialise form state to JSON; store up to 5 slots in `app_settings.draft_slots` (FIFO — evict oldest on 6th)
- [ ] `TransactionFormScreen`: on `WillPopScope` / back button, if form has content and `back_button_behaviour = 'auto_save_draft'`, call `DraftRepository.save`
- [ ] FAB in home screen: if draft exists, show "Resume draft" option; tapping opens form pre-populated
- [ ] Explicit discard action in form toolbar clears draft slot
- [ ] Widget tests: FIFO eviction on 6th draft; resume pre-populates all fields; discard clears slot

### References

- `DRAFT-01 — Transaction Drafts` (`docs/02-technical/feature-dag.md`)
- `5.2.8 Drafts` (`docs/01-product/prd.md`)
- `3.3 transactions` (`docs/02-technical/data-model.md`)
