# Bugs

## B-1 — Initial-balance ledger entry fails with FK constraint on category_id

**Affected Epic:** E-2 — Accounts Domain
**Severity:** high

**Symptom:** Creating an account with a non-zero initial balance surfaces a raw `SqliteException(787)` FK constraint failure on `entries.category_id`, yet the account row persists with balance 0.

**Expected:** Account creation with an initial balance posts ledger entries atomically; if the entries insert fails the entire operation rolls back and the account does not appear.

### Repro Steps

1. Open the New Account form.
2. Fill in: name "icici", category "Bank Account", currency "INR", initial balance 1000, include in net worth = true, notes empty, bank name "icici".
3. Tap Save.
4. Observe: `SqliteException(787): FOREIGN KEY constraint failed` is shown to the user.
5. Dismiss the error and navigate back to the Accounts list.
6. Observe: account "icici" is visible with balance 0 instead of 1000 INR.

### Root Cause

Two defects identified from the failing INSERT:

1. `category_id` is `null` in the entries row for an initial-balance posting. The `entries` table enforces a FK on `category_id`; initial-balance postings must either use a reserved system category ID or the column must be nullable for system-generated entries — the correct approach must be confirmed against the data model.
2. The account insert and entries insert are not wrapped in a single Drift transaction, so the account row commits even when the entries insert fails.

### Todo

- [ ] Write a failing test: create account with non-zero initial balance, assert that after failure neither the account row nor any entries row exist
- [ ] Confirm approach with data model: nullable `category_id` for system-generated entries vs. reserved system category — implement accordingly
- [ ] Wrap `CreateAccountUseCase` (account insert + ledger entries insert) in a single Drift transaction so both commit or roll back together
- [ ] Catch `SqliteException` in the repository/use-case layer and translate to a domain `Failure` before it reaches the UI
- [ ] Confirm the failing test now passes
- [ ] Regression-check: create account with 0 balance, positive balance, negative balance — all must succeed or fail atomically with no partial writes

### Notes

- Raw `SqliteException` was surfaced directly to the user — error translation is missing at the repository or use-case boundary.

### References

- `3.4 entries` (`docs/02-technical/data-model.md`)
- `2.1.2 Use Cases` (`docs/02-technical/api-contracts.md`)
