- [Variance -- Technical Clarifications](#variance----technical-clarifications)
  - [Category A -- Vague Product Specifications](#category-a----vague-product-specifications)
    - [TC-001: Transaction `status` field -- complete enumeration of states](#tc-001-transaction-status-field----complete-enumeration-of-states)
    - [TC-002: Compound transaction identity -- how the "shared compound transaction ID" works](#tc-002-compound-transaction-identity----how-the-shared-compound-transaction-id-works)
    - [TC-003: "Manually handled" marking on recurring template occurrences](#tc-003-manually-handled-marking-on-recurring-template-occurrences)
    - [TC-004: Statement balance derivation for credit cards -- billing period boundaries](#tc-004-statement-balance-derivation-for-credit-cards----billing-period-boundaries)
    - [TC-005: "Auto-save as draft" back button behaviour -- draft lifecycle](#tc-005-auto-save-as-draft-back-button-behaviour----draft-lifecycle)
    - [TC-006: Exchange rate fetching model -- trigger, frequency, API, and error handling](#tc-006-exchange-rate-fetching-model----trigger-frequency-api-and-error-handling)
    - [TC-007: Photo compression parameters](#tc-007-photo-compression-parameters)
    - [TC-008: Pending future-dated transaction visibility and interaction](#tc-008-pending-future-dated-transaction-visibility-and-interaction)
    - [TC-009: Fuzzy search implementation -- ranking algorithm specifics](#tc-009-fuzzy-search-implementation----ranking-algorithm-specifics)
    - [TC-010: Installment template -- relationship between "Number of installments" and recurrence rule](#tc-010-installment-template----relationship-between-number-of-installments-and-recurrence-rule)
    - [TC-011: Installment template -- "add new future installments" mechanics](#tc-011-installment-template----add-new-future-installments-mechanics)
    - [TC-012: Account deletion balance transfer -- "same type" constraint on template migration](#tc-012-account-deletion-balance-transfer----same-type-constraint-on-template-migration)
    - [TC-013: Notification reschedule triggers on credit card field edits](#tc-013-notification-reschedule-triggers-on-credit-card-field-edits)
    - [TC-014: "Curated subset" of material\_symbols\_icons -- who defines it and when](#tc-014-curated-subset-of-material_symbols_icons----who-defines-it-and-when)
    - [TC-015: Soft-delete reversing entry -- visible or invisible?](#tc-015-soft-delete-reversing-entry----visible-or-invisible)
    - [TC-016: Balance Adjustment category -- icon and name](#tc-016-balance-adjustment-category----icon-and-name)
  - [Category B -- Inconsistent Product Specifications](#category-b----inconsistent-product-specifications)
    - [TC-017: PRD SS4.5 expense entry sides vs. ledger-entry.md Case 1.1](#tc-017-prd-ss45-expense-entry-sides-vs-ledger-entrymd-case-11)
    - [TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md](#tc-018-prd-ss48-in-place-edits-list-inconsistent-with-input-fieldsmd)
    - [TC-019: Transaction data model -- notes field removal inconsistency](#tc-019-transaction-data-model----notes-field-removal-inconsistency)
    - [TC-020: Account deletion balance transfer -- transaction editability conflict](#tc-020-account-deletion-balance-transfer----transaction-editability-conflict)
    - [TC-021: Installment early close -- "Total configured" immutability exception](#tc-021-installment-early-close----total-configured-immutability-exception)
    - [TC-022: Loan account installment suggestion -- transaction type inconsistency](#tc-022-loan-account-installment-suggestion----transaction-type-inconsistency)
    - [TC-023: Category filter -- multi-select scope unclear across transaction types](#tc-023-category-filter----multi-select-scope-unclear-across-transaction-types)
  - [Category C -- Missing Product Specifications](#category-c----missing-product-specifications)
    - [TC-024: Transaction entity -- complete field enumeration and data types](#tc-024-transaction-entity----complete-field-enumeration-and-data-types)
    - [TC-025: Ledger entry entity -- missing timestamps and metadata](#tc-025-ledger-entry-entity----missing-timestamps-and-metadata)
    - [TC-026: Recurring/installment template entity -- complete schema](#tc-026-recurringinstallment-template-entity----complete-schema)
    - [TC-027: Account entity -- missing system fields](#tc-027-account-entity----missing-system-fields)
    - [TC-028: Category entity -- missing system fields](#tc-028-category-entity----missing-system-fields)
    - [TC-029: How does the app handle home currency changes after transactions exist?](#tc-029-how-does-the-app-handle-home-currency-changes-after-transactions-exist)
    - [TC-030: Recurring "remind and confirm" -- what happens when multiple occurrences stack up?](#tc-030-recurring-remind-and-confirm----what-happens-when-multiple-occurrences-stack-up)
    - [TC-031: Navigation structure -- app-level navigation model](#tc-031-navigation-structure----app-level-navigation-model)
    - [TC-032: Account detail screen -- specification missing](#tc-032-account-detail-screen----specification-missing)
    - [TC-033: Error handling for failed ledger operations](#tc-033-error-handling-for-failed-ledger-operations)
    - [TC-034: Batch category migration -- performance and UX for large N](#tc-034-batch-category-migration----performance-and-ux-for-large-n)
    - [TC-035: Soft-deleted entity reinstatement -- what fields are restored?](#tc-035-soft-deleted-entity-reinstatement----what-fields-are-restored)
    - [TC-036: Transfer destination account currency validation -- enforcement mechanism](#tc-036-transfer-destination-account-currency-validation----enforcement-mechanism)
    - [TC-037: Onboarding wizard -- account creation form field set](#tc-037-onboarding-wizard----account-creation-form-field-set)
    - [TC-038: Installment template -- can transfers be installments?](#tc-038-installment-template----can-transfers-be-installments)
    - [TC-039: What happens to pending (future-dated) transactions when the referenced account is soft-deleted?](#tc-039-what-happens-to-pending-future-dated-transactions-when-the-referenced-account-is-soft-deleted)
    - [TC-040: Category deletion flow -- ordering of template warning vs. transaction migration](#tc-040-category-deletion-flow----ordering-of-template-warning-vs-transaction-migration)
    - [TC-041: Recurring transaction auto-post scheduling mechanism](#tc-041-recurring-transaction-auto-post-scheduling-mechanism)
    - [TC-042: Search scope -- home screen vs. unified transaction list](#tc-042-search-scope----home-screen-vs-unified-transaction-list)
    - [TC-043: Template archival -- is it a soft-delete or a distinct state?](#tc-043-template-archival----is-it-a-soft-delete-or-a-distinct-state)
    - [TC-044: Currency list -- bundling and maintenance](#tc-044-currency-list----bundling-and-maintenance)
    - [TC-045: EQ (Opening Balance equity account) -- balance and auditability](#tc-045-eq-opening-balance-equity-account----balance-and-auditability)
    - [TC-046: BAI and BAE (Balance Adjustment categories) -- per-currency or global?](#tc-046-bai-and-bae-balance-adjustment-categories----per-currency-or-global)
    - [TC-047: Per-account and per-category large transaction thresholds -- currency handling](#tc-047-per-account-and-per-category-large-transaction-thresholds----currency-handling)
    - [TC-048: Minimum API level inconsistency with dynamic color](#tc-048-minimum-api-level-inconsistency-with-dynamic-color)
    - [TC-049: Pending Confirmations -- dismiss action semantics](#tc-049-pending-confirmations----dismiss-action-semantics)
    - [TC-050: Search interaction with month filter on home screen](#tc-050-search-interaction-with-month-filter-on-home-screen)
    - [TC-051: Soft-delete of the last active category in a tree](#tc-051-soft-delete-of-the-last-active-category-in-a-tree)
    - [TC-052: Recurring transfer templates with fees](#tc-052-recurring-transfer-templates-with-fees)
    - [TC-053: Credit card payment due amount -- outstanding vs. statement balance](#tc-053-credit-card-payment-due-amount----outstanding-vs-statement-balance)
    - [TC-054: Data backup format -- versioning and forward compatibility](#tc-054-data-backup-format----versioning-and-forward-compatibility)
    - [TC-055: Installment early close -- "final payment" transaction type](#tc-055-installment-early-close----final-payment-transaction-type)
    - [TC-056: Recurring template deletion vs. archival -- child transaction handling](#tc-056-recurring-template-deletion-vs-archival----child-transaction-handling)
    - [TC-057: Multiple accounts per account category -- display and disambiguation](#tc-057-multiple-accounts-per-account-category----display-and-disambiguation)
    - [TC-058: "Is recurring" filter criterion -- scope and semantics](#tc-058-is-recurring-filter-criterion----scope-and-semantics)
  - [Summary](#summary)
    - [Priority Assessment](#priority-assessment)
  - [PM Response Summary](#pm-response-summary)
    - [Items requiring founder decisions (5 items) — ✅ ALL RESOLVED (2026-04-14)](#items-requiring-founder-decisions-5-items---all-resolved-2026-04-14)
    - [Items requiring PRD text updates (documentation fixes)](#items-requiring-prd-text-updates-documentation-fixes)
  - [LE Review Summary](#le-review-summary)
    - [Verdict Distribution](#verdict-distribution)
    - [Items with DISAGREE Verdict](#items-with-disagree-verdict)
    - [Summary of ACCEPTED WITH NOTE Implementation Considerations](#summary-of-accepted-with-note-implementation-considerations)
    - [Overall Assessment](#overall-assessment)


# Variance -- Technical Clarifications

> **Purpose:** Comprehensive technical review of all product specification documents in `docs/01-product/`, identifying issues that would block or confuse implementation of the System Design Spec, data model, API contracts, and UX flows.
>
> **Reviewer:** Lead Engineer / Architect
>
> **Date:** 2026-04-14
>
> **Documents Reviewed:**
> - `docs/01-product/prd.md` (PRD)
> - `docs/01-product/prd-v2-draft.md` (PRD v2 Draft)
> - `docs/01-product/ledger-entry.md` (Ledger Entry Case Analysis)
> - `docs/01-product/input-fields.md` (Input Fields Reference)

---

> **Disclaimer on engineering-level suggestions in PM responses.**
>
> Throughout this document, PM responses occasionally include engineering-level suggestions such as specific field names (e.g., `compound_group_id`), data types (e.g., "nullable UUID"), schema structures, numeric limits, or implementation approaches. These suggestions are **advisory only** -- they are offered to communicate product intent and make the discussion concrete, not to prescribe implementation. The **Engineering Lead / Architect owns all engineering decisions**. The SDS author should evaluate these suggestions on their merits but is free to choose different field names, data structures, or implementation approaches as long as the product requirements and observable behaviours specified herein are met. In short: product requirements (the "what" and "why") are binding; engineering suggestions (the "how") are not.

## Category A -- Vague Product Specifications

These items are stated in the documents but lack the precision needed to implement without guessing.

---

### TC-001: Transaction `status` field -- complete enumeration of states

**Documents:** PRD SS5.7, SS5.2.2, SS5.2.7, SS4.8

**Issue:** The PRD introduces a `status` field on transactions in SS5.7 with two values: `posted` and `pending`. However, the correction model (SS4.8) creates reversing and corrected transactions, and soft-delete (SS5.2.2) creates voiding reversals. The document says corrected originals and reversals are "hidden as internal ledger entries" and voided transactions are "excluded from all normal views." There is no specification of what `status` values these entities carry. Are reversing entries `posted`? Is a voided transaction's status changed to something like `voided`? Is a superseded original marked differently?

**Why it matters:** The data model needs a complete, enumerated `status` field (or a separate `visibility` / `purpose` field) to correctly filter the transaction list, compute balances, and drive the v2 audit view. Without this, the SDS cannot define which transactions participate in balance computation vs. display vs. audit.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the PRD only explicitly enumerates `posted` and `pending`. The full status/purpose model needed for the data layer is as follows. The transaction entity requires two orthogonal fields:

1. **`status`** with values: `pending`, `posted`, `voided`.
   - `pending`: future-dated, not yet in the ledger (SS5.7).
   - `posted`: active ledger participant, contributes to balances.
   - `voided`: soft-deleted by the user; a reversing entry has been posted to neutralize it. The original record is retained but excluded from normal views and balance computation (SS5.2.2).

2. **`purpose`** with values: `user`, `reversal`, `correction`, `system`.
   - `user`: a normal transaction created by the user.
   - `reversal`: a system-generated reversing entry created during a correction (SS4.8) or soft-delete (SS5.2.2). Always `posted`. Hidden from normal views.
   - `correction`: the corrected replacement transaction created during a correction. Always `posted`. This is the version shown in the transaction list (SS5.2.2: "only the final corrected transaction is visible").
   - `system`: a system-generated transaction such as the account deletion balance transfer (SS5.1.1) or an opening balance posting (SS4.9). Always `posted`.

**Balance computation rule:** All transactions with `status = posted` contribute to balances, regardless of `purpose`. This is correct because reversals and corrections are real ledger entries that maintain DEB integrity.

**Display rule for the default transaction list:** Show transactions where `status = posted` AND `purpose IN (user, correction, system)`. Exclude `purpose = reversal`. Also exclude `voided` transactions. Pending transactions are excluded from the default list but shown when navigating to future months (SS5.8.3).

**Superseded originals:** When a user-created transaction is corrected, the original's `status` changes to `voided` (it has been reversed). This is the same mechanism as soft-delete -- both produce a reversing entry. The distinction between "voided by user" and "voided by correction" can be captured via a nullable `voided_reason` or by the presence of a linked correction, but the `status` value is the same.

This resolution will be added to the PRD as a clarification to SS5.7 and SS4.8 in the next PRD revision.

**LE Verdict: ACCEPTED.**

The two-field model (`status` x `purpose`) is exactly what the SDS needs. The balance computation rule (all `status = posted` regardless of `purpose`) is clean and correct. The display filter rule is well-defined. The treatment of superseded originals as `voided` with the distinction recoverable via linked correction is sound. No further action needed beyond the documented PRD text update.

---

### TC-002: Compound transaction identity -- how the "shared compound transaction ID" works

**Documents:** PRD SS5.1.5b, ledger-entry.md Case 1.3a

**Issue:** Transfer-with-fee creates "two linked transactions grouped under a shared compound transaction ID." This implies a grouping mechanism, but the data model in PRD SS4.3 defines a `Transaction` with only `id` and `type`. There is no specification of how compound grouping works. Is it a `compound_group_id` on each transaction? Is it a parent-child relationship? Can a compound group contain more than two transactions (future-proofing for split transactions in v2)?

**Why it matters:** The schema must support atomic compound operations (edit/delete affects all members). The SDS needs to know the exact relationship model to implement compound creation, compound editing (Case 1.6a), and compound display (single row in list, expanded in detail).

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the grouping mechanism is implied but not formally specified. The product-level definition is:

1. A **compound group** is a set of transactions that were created together as a single logical user action and must be edited/deleted together. In v1, the only compound case is transfer-with-fee (2 transactions).
2. The grouping model is a `compound_group_id` (nullable UUID) on each transaction. Transactions sharing the same `compound_group_id` form a compound group. For non-compound transactions, this field is null.
3. A compound group in v1 contains exactly 2 transactions (the transfer and the fee expense). In v2, split transactions may create groups of N > 2 transactions -- the `compound_group_id` model supports this natively without schema changes.
4. **Atomicity rule (product):** Edit or delete on any member of a compound group applies to all members (PRD SS5.1.5b: "Editing or deleting a transfer-with-fee affects both parts together"). The UI presents the compound group as a single entry in the transaction list and exposes the breakdown in the detail view.

The SDS should define the compound group as a nullable FK or UUID field on the transaction entity. No separate "compound_groups" table is needed -- the shared ID is sufficient.

**LE Verdict: ACCEPTED WITH NOTE.**

The `compound_group_id` approach is the right model. The SDS author should note two implementation considerations: (1) when loading a compound group for display, the query must fetch all transactions sharing the same `compound_group_id` and the UI must designate one as the "primary" (the transfer) and the other as the "secondary" (the fee) -- the ordering/role within the group needs a `compound_role` field or a convention (e.g., the transfer is always the first created). (2) For the v2 split-transaction extension, the group may contain N > 2 members, so the SDS should avoid hardcoding a "exactly 2 members" assumption in the schema or query layer.

---

### TC-003: "Manually handled" marking on recurring template occurrences

**Documents:** PRD SS5.2.7 (Q47 resolution)

**Issue:** When a child transaction of a recurring template is edited or soft-deleted, the occurrence is marked as "manually handled" on the template's schedule. But the specification does not define what the "schedule" data structure looks like. Is it a list of dates with status flags? Is it computed from the recurrence rule? Does the template store an explicit list of exceptions?

**Why it matters:** The scheduler needs to know which future dates to skip. The data model must support either a computed schedule with an exceptions list, or materialized occurrence records with status flags. This fundamentally shapes the recurring engine's architecture.

**PM Response: DEFERRED TO SDS.**

The LE is correct that the schedule data structure is not specified. This is intentionally an architecture decision. The product requirement is:

- When a child transaction is edited or soft-deleted, the scheduler must not re-post that occurrence.
- All future occurrences not marked as "manually handled" continue to fire normally.
- Skipped occurrences during a pause period are permanently skipped.

Whether the SDS implements this as (a) a computed schedule from the recurrence rule with an explicit exceptions/overrides list on the template, or (b) materialized occurrence records with status flags, is an engineering architecture choice. The product does not constrain the approach -- only the observable behaviour. The SDS author should evaluate the tradeoffs (storage vs. computation, complexity of the scheduler, ease of querying "next occurrence") and document the decision in the Architecture Decision Records.

**LE Verdict: DEFERRAL ACCEPTED.**

This is squarely an engineering architecture decision. The product requirements (skip manually-handled, skip paused, fire normally otherwise) are clear. The SDS will evaluate materialized vs. computed schedules and document the trade-offs in an ADR. Note that TC-011 already resolves installments as materialized; the SDS should consider whether unifying both recurring and installment scheduling under the same storage model (materialized) simplifies the codebase, even if recurring templates do not strictly require it.

---

### TC-004: Statement balance derivation for credit cards -- billing period boundaries

**Documents:** PRD SS5.1.6

**Issue:** Statement balance is defined as "net change to the credit card account between the last billing date and the current date." But the exact boundary semantics are unspecified. Is the billing period [billing_date, billing_date + 1 month)? Is it inclusive or exclusive of the billing date itself? What about the first billing cycle when the account is newly created? What if the billing date has not yet occurred this month (e.g., billing date is the 25th but today is the 10th -- does "current billing period" mean from the 25th of last month to today)?

**Why it matters:** The statement balance query must have precise date boundaries. Off-by-one errors in billing period computation would produce incorrect statement balances and incorrect payment reminder amounts.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid point. PRD SS5.1.6 defines statement balance as "net change to the credit card account between the last billing date and the current date" but does not specify boundary semantics. The product-level clarification is:

1. **Billing period definition:** The billing period is a half-open interval `(previous_billing_date, current_billing_date]`. That is, the period includes transactions on the billing date itself but excludes transactions on the previous billing date (which belonged to the prior period).
2. **"Previous billing date"** is computed by subtracting one month from the current billing date (applying the same end-of-month clamping rule as recurring transactions in SS5.2.7).
3. **First billing cycle:** When the account is newly created and no full billing cycle has elapsed yet, the statement balance covers all transactions from account creation through the first billing date: `(account_creation_date, first_billing_date]`.
4. **Current date before billing date:** If today is the 10th and the billing date is the 25th, the "current billing period" runs from the 25th of last month through today. The statement balance shown is the running total for the current open period. This is not yet a "statement" in the formal sense -- it is a projection. The notification that fires "1 day after billing date" (SS5.1.7) reports the finalized statement balance for the just-closed period.
5. **Boundary type:** Inclusive of the billing date, exclusive of the previous billing date. Transactions are matched by their user-specified date (not creation timestamp).

This will be added to SS5.1.6 in the next PRD revision.

**LE Verdict: ACCEPTED.**

The half-open interval `(previous_billing_date, current_billing_date]` with end-of-month clamping is precise and implementable. The first billing cycle boundary (account creation date) and the mid-cycle projection semantics are well-defined. The use of user-specified date (not creation timestamp) for matching is correct. No further clarification needed.

---

### TC-005: "Auto-save as draft" back button behaviour -- draft lifecycle

**Documents:** PRD SS5.4.3

**Issue:** The back button behaviour setting includes "Auto-save as draft -- saves partial entry as a draft (accessible from a Drafts section)." But there is no specification of drafts anywhere else in the PRD. Where does the "Drafts section" live in the UI? How many drafts can exist? Do drafts expire? Can drafts be explicitly deleted? What fields are persisted in a draft? Is a draft a partial transaction entity or a separate data structure?

**Why it matters:** Drafts require schema support (a `drafts` table or a `draft` status on transactions), a UI surface to list/resume/delete them, and defined lifecycle rules. Without this, the feature cannot be implemented.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that drafts are mentioned only in the back button behaviour setting (SS5.4.3) without a supporting specification. The product-level resolution:

1. **Drafts are a lightweight persistence mechanism, not a first-class entity.** A draft is a serialized snapshot of the transaction entry form's current state (all filled fields, including partial data). It is stored as a single blob/JSON record -- not as a transaction entity.
2. **Storage:** A separate `drafts` table (or key-value store) with fields: `id`, `created_at`, `form_state_json`, `transaction_type`. Not part of the transaction or ledger schema.
3. **Lifecycle rules:**
   - Maximum **5 drafts** at any time. If the limit is reached and a new draft is auto-saved, the oldest draft is silently discarded.
   - Drafts have **no expiration** -- they persist until explicitly deleted or resumed.
   - Resuming a draft populates the transaction entry form and deletes the draft record.
   - Drafts can be explicitly deleted from the Drafts section.
4. **UI surface:** A "Drafts" entry point is accessible from the quick-entry FAB menu (or transaction entry screen). It shows a simple list of saved drafts with date, transaction type, and partial amount/title (if available). Tapping a draft resumes it.
5. **Scope note:** This is the simplest viable implementation. Drafts do not participate in the ledger, do not have a `status`, and are not transactions.

This will be added to SS5.4.3 in the next PRD revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The draft specification is clean and lightweight. The SDS author should note: (1) the `form_state_json` blob should include the schema version of the form at the time of draft creation, so that if the form fields change between app updates, stale drafts can be detected and handled (e.g., discarded with a message). (2) The 5-draft limit with FIFO eviction of the oldest is simple to implement but should be communicated to the user (a brief toast: "Oldest draft was removed to make room").

---

### TC-006: Exchange rate fetching model -- trigger, frequency, API, and error handling

**Documents:** PRD SS7, SS7.1, NF-1, NF-2

**Issue:** Exchange rates are described as "fetched opportunistically in the background (once daily when internet is available)" with a "cached exchange rate" stored locally. However, this is the only internet-requiring feature in v1, and the specification does not define: (a) what exchange rate API/source is used, (b) how the background fetch is triggered (WorkManager? app foreground check?), (c) what happens if the API fails, (d) whether rates are fetched for all currencies or only those the user has accounts in, (e) the exact cache schema.

**Why it matters:** This is an internet-touching feature in an otherwise fully offline app. The SDS needs a concrete fetching strategy, retry policy, and cache invalidation model. NF-1 says "the app never initiates a network call for any core functionality" -- the boundary between "core" and "exchange rate" must be architecturally clear (e.g., a separate isolate or service that can be completely disabled).

**PM Response: DEFERRED TO SDS.**

The LE is correct that the exchange rate fetching model needs concrete specification. However, the specifics (API source, scheduling mechanism, retry policy, cache schema, isolate architecture) are engineering decisions. The product-level requirements are already stated:

- Fetch is **opportunistic and background-only** (SS7, NF-2).
- Frequency: **at most once daily** when internet is available.
- Scope: rates for **only currencies the user has accounts in** (relative to home currency). Not the full ISO 4217 set.
- Failure behaviour: **silent failure**. No error shown to user. Most recent cached rate is used. If no rate exists, home currency equivalent is omitted with a disclaimer (SS7).
- The staleness threshold is **14 days** (SS7).
- The exchange rate service must be **architecturally isolated** from core functionality so that NF-1 is not violated -- core functionality must work identically whether the rate service is active or disabled.

The SDS should select a free, permissively-usable exchange rate API (e.g., frankfurter.app, exchangerate.host), define the cache schema, and specify the scheduling mechanism (WorkManager is the natural choice for background Android work). This is squarely an SDS deliverable.

**LE Verdict: DEFERRAL ACCEPTED.**

The product-level requirements (opportunistic, daily max, scoped to user currencies, silent failure, 14-day staleness, architecturally isolated) are sufficient for the SDS to design the fetching service. The SDS will select the API, define the cache schema, and specify the scheduling mechanism. The architectural isolation requirement (NF-1 compliance) is well-articulated.

---

### TC-007: Photo compression parameters

**Documents:** PRD SS5.2.3

**Issue:** "Photos are compressed before storage. Compression algorithm, target resolution, and quality threshold are deferred to SDS." This is explicitly deferred but there is no product guidance on acceptable quality bounds. For example: is it acceptable to compress a receipt photo to the point of illegibility? What is the target file size or resolution range? Should the original be preserved?

**Why it matters:** The SDS will need to choose concrete compression parameters. Without a quality floor from the product side (e.g., "must remain legible for receipt text"), the engineering team is guessing at user expectations.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a fair point. The PRD correctly defers the algorithm and parameters to SDS, but should provide a product-level quality floor. The resolution:

1. **Quality floor:** Compressed photos must remain **legible for receipt text** at normal zoom. This is the primary use case -- users attach receipt photos as proof of purchase.
2. **Target resolution:** Maximum dimension (width or height) capped at **1920 pixels**. Photos smaller than this are not upscaled.
3. **Target file size:** No hard cap, but the SDS should aim for **under 500 KB per photo** after compression.
4. **Original preservation:** The original is **not preserved**. Only the compressed version is stored. This is acceptable because photo attachments are a convenience feature, not an archival system.
5. **Format:** The SDS should use JPEG compression. The quality parameter is an SDS decision within the constraint of the legibility floor.

This will be added to SS5.2.3 in the next PRD revision.

**LE Verdict: ACCEPTED.**

The quality floor ("legible for receipt text"), max dimension (1920px), target file size (~500KB), and no-original-preservation policy are sufficient product guidance. The SDS will select the JPEG quality parameter within these constraints.

---

### TC-008: Pending future-dated transaction visibility and interaction

**Documents:** PRD SS5.7

**Issue:** Future-dated transactions are "held as pending" and excluded from the default transaction list. But the specification does not define: (a) where pending transactions are visible (is there a "Pending" section, similar to "Pending Confirmations"?), (b) can a pending transaction be edited or deleted before its posting date? (c) how does a pending transaction interact with the month selector on the home screen (SS5.8.3 says "navigation to future months shows pending transactions if any exist" -- are they visually distinguished?).

**Why it matters:** Without a defined surface for pending transactions, users have no way to view, edit, or cancel a future-dated transaction they created. The UX flow and the data layer need to know how pending transactions participate in the UI.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that pending transaction visibility and interaction are underspecified. PRD SS5.7 says they are excluded from the default list, and SS5.8.3 says future months show them. The complete product rules:

1. **Visibility:** Pending transactions appear in the transaction list **only when the user navigates to a future month** via the month selector (SS5.8.3). They are visually distinguished with a "Pending" badge or muted styling (exact treatment deferred to UX Flows).
2. **No separate "Pending" section for future-dated transactions.** The "Pending Confirmations" screen (SS5.8.5) is exclusively for "remind and confirm" recurring templates. Future-dated transactions are accessed by navigating to the relevant future month.
3. **Editability:** A pending transaction can be **edited** (all fields are in-place editable since it has not been posted to the ledger yet -- no correction model applies). Amount, account, category, date, title, description, and photos can all be changed freely.
4. **Deletion:** A pending transaction can be **deleted permanently** (not soft-deleted, since it was never posted and has no ledger entries). This is the one exception to universal soft-delete -- a pending transaction has no ledger footprint to preserve. Alternatively, if the SDS prefers consistency, it can be soft-deleted with `status = voided` without needing a reversing entry.
5. **Contextual menu:** Pending transactions in the future month view have: Edit, Delete (with confirmation: "This transaction has not been posted yet. Delete it?").

**Escalation note:** Item 4 (permanent delete vs. soft-delete for pending transactions) is a product decision. Proposed resolution: soft-delete for consistency with the universal soft-delete rule (C8), even though no reversing entry is needed. This avoids creating an exception to the "no entity is ever permanently deleted" principle. Escalating to founder for confirmation.

**LE Verdict: ACCEPTED WITH NOTE.**

The visibility, editability, and deletion rules for pending transactions are well-defined. The PM's proposed resolution for item 4 (soft-delete for consistency) is the correct call from an engineering perspective -- it avoids a special code path for permanent deletion. The SDS author should note: (1) pending transactions that are "soft-deleted" (status = voided) without a reversing entry represent a unique state (voided with no reversal) -- the audit view logic in v2 should account for this. (2) The "all fields freely editable" rule for pending transactions means the edit flow bypasses the correction model entirely, which is a distinct code path the SDS must handle.

---

### TC-009: Fuzzy search implementation -- ranking algorithm specifics

**Documents:** PRD SS5.2.5

**Issue:** The search model is described as "fzf-style" with four matching modes (typo-tolerant, substring, nearest-substring, exact). However, the ranking algorithm is not specified. Which matching mode has higher rank? How is the score computed across multiple fields (e.g., a match in title vs. a match in description)? The PRD says "whether title and description are searched with equal or different ranking weight is deferred to UX Flows" but this is actually an engine-level decision, not a UX decision.

**Why it matters:** The search engine's ranking function must be defined to produce deterministic, useful results. Different ranking strategies require different index structures (e.g., trigram index for typo tolerance, prefix tree for substring). This affects the database schema and query approach.

**PM Response: DEFERRED TO SDS.**

The LE is correct that the ranking algorithm is an engine-level decision, and the PRD's deferral to "UX Flows" was a mis-categorization. The product requirements for search are:

1. **Matching modes** are defined in SS5.2.5: exact > prefix > substring > typo-tolerant (in descending rank priority).
2. **Field ranking:** Title and account name should rank higher than description and category name. The exact weights are an SDS tuning decision.
3. **Determinism:** Results with equal scores should be ordered by date descending (most recent first) as a tiebreaker.
4. **Performance target:** Search must return results within NF-3's 500ms target for 10,000 records.

The specific index structures (trigram, prefix tree, FTS5, or in-memory fuzzy matching) and the numeric scoring function are SDS decisions. The PRD will be corrected to remove the "deferred to UX Flows" note and instead state "deferred to SDS."

**LE Verdict: DEFERRAL ACCEPTED.**

The product requirements (matching mode rank order, field ranking priority, determinism via date tiebreaker, 500ms performance target) are sufficient for the SDS to design the search engine. The re-categorization from "UX Flows" to "SDS" is correct. The SDS will select the indexing strategy and scoring function.

---

### TC-010: Installment template -- relationship between "Number of installments" and recurrence rule

**Documents:** PRD SS5.2.8, input-fields.md SS5.1

**Issue:** Installments share the recurrence definition from recurring templates (N, unit, constraints, start date, end date). They also have "number of installments" as a separate field. The PRD says this is "derived from total / recurrence, or manually set." But the interaction between "number of installments" and "end date" is unclear. If the user sets both, which takes precedence? If the user sets number of installments = 12 with monthly recurrence but also sets an end date that is only 10 months away, what happens? Can an installment template have an end date at all, or is the end implicitly determined by the installment count?

**Why it matters:** The scheduler must know which signal terminates the series. Conflicting termination conditions create ambiguous runtime behaviour.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the interaction between "number of installments" and "end date" is ambiguous. The product-level resolution:

1. **Installments do NOT have an independent end date.** The end date of an installment template is **always derived** from: `start_date + (number_of_installments * recurrence_period)`. The `end_date` field from the recurring template base (SS5.2.7) is **not user-settable** on installment templates -- it is computed and displayed as read-only.
2. **Number of installments is the primary termination signal.** It can be set explicitly by the user or derived from `total_amount / per_installment_amount`.
3. **Conflict scenario is eliminated by design:** Since the user cannot independently set both `number_of_installments` and `end_date`, there is no conflict case.
4. **Template archival:** The template archives when all installments have been posted (the computed end date is reached), or via early close (SS5.2.8).

This will be clarified in SS5.2.8 and input-fields.md SS5.1 in the next revision. The `end_date` field on installment templates should be marked as **computed/read-only**, not user-settable.

**LE Verdict: ACCEPTED.**

Clean resolution. Number of installments as the sole termination signal, with end date derived and read-only, eliminates the conflict by design. The input-fields.md update to mark end_date as computed/read-only for installment templates is the right fix.

---

### TC-011: Installment template -- "add new future installments" mechanics

**Documents:** PRD SS5.2.8, input-fields.md SS5.1

**Issue:** "The user may add new future installments or remove unposted future installments after creation." This implies installments are materialized as individual records, not just computed from a recurrence rule + count. But the installment creation flow suggests they start as a computed series (total / count). When exactly are individual installment records materialized? At template creation? On demand? Are they stored as separate entities or as a list within the template?

**Why it matters:** The data model for installments depends on whether they are "virtual" (computed from rule) or "materialized" (stored individually). The ability to add/remove/adjust individual future installments strongly suggests materialization, but the creation flow suggests computation. The SDS needs a clear answer.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE correctly identifies the tension. The product intent resolves unambiguously to **materialization**:

1. **At template creation time:** Individual installment records are **materialized** (created as individual scheduled records) based on the computed series: `total_amount / number_of_installments`, distributed across the recurrence dates.
2. **After creation:** The user can add, remove, and adjust amounts on individual future (unposted) installment records. This is only possible if they are materialized as distinct records.
3. **Data model implication:** Each installment is a **scheduled occurrence record** with fields: `id`, `template_id`, `scheduled_date`, `amount`, `status` (scheduled / posted / cancelled / manually_handled), and a link to the child transaction once posted.
4. **Relationship to parent template:** The template stores the configuration (total, recurrence rule, accounts, category). The materialized installment records store the per-period schedule and amounts.
5. **Recurring templates (non-installment):** May use either materialized or computed schedules (per TC-003, deferred to SDS). The key difference is that installments require materialization because of per-period amount editability; recurring templates do not have this requirement.

This will be clarified in SS5.2.8 in the next PRD revision.

**LE Verdict: ACCEPTED.**

Materialization at creation time is the correct approach for installments given the per-period editability requirement. The occurrence record schema (`id`, `template_id`, `scheduled_date`, `amount`, `status`, child transaction link) is complete. The distinction from recurring templates (which may use computed schedules) is well-articulated.

---

### TC-012: Account deletion balance transfer -- "same type" constraint on template migration

**Documents:** PRD SS5.1.1, input-fields.md SS2.6

**Issue:** When deleting an account that has recurring/installment templates, the user can "Migrate templates -- select a replacement account." The input-fields.md says the replacement account "Must be same type (for account field) or compatible." The PRD does not define "compatible." Does "same type" mean same account category (e.g., Bank Account -> Bank Account only)? Or same currency? Or any account? The phrase "or compatible" is undefined.

**Why it matters:** The account picker for template migration needs a concrete filter. "Compatible" is not a defined term in the PRD and could mean multiple things.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that "compatible" is undefined. The product-level resolution:

1. **"Same type" means same account category** (e.g., Bank Account can only be replaced by another Bank Account; Credit Card by another Credit Card). This ensures that category-specific fields (billing date, credit limit, etc.) remain semantically valid on the template.
2. **Additionally, same currency is required.** Since cross-currency transfers are blocked in v1 (SS7), migrating a template to an account in a different currency would produce invalid transactions.
3. **The replacement account picker is filtered to:** accounts that are (a) active (not soft-deleted), (b) same account category as the one being deleted, and (c) same currency.
4. **If no valid replacement account exists:** The "Migrate templates" option is disabled (greyed out). Only "Stop templates" is available.
5. **The phrase "or compatible" in input-fields.md should be removed.** The rule is strictly "same account category AND same currency."

This will be corrected in input-fields.md SS2.6 and SS5.1.1 in the next revision.

**LE Verdict: ACCEPTED.**

The strict rule (same account category AND same currency) with the "Migrate templates" option disabled when no valid replacement exists is clear and implementable. Removing "or compatible" eliminates the ambiguity.

---

### TC-013: Notification reschedule triggers on credit card field edits

**Documents:** PRD SS5.1.7, input-fields.md SS2.2 (Credit Card)

**Issue:** Input-fields.md states that editing billing date, payment due date, or linked bank account "triggers notification reschedule." But the PRD notification schedule (SS5.1.7) is defined in terms of billing date and payment due date. Changing the linked bank account should not affect notification timing (only the pre-filled source account). Is the "notification reschedule" on linked bank account edit actually needed, or is it a documentation error?

**Why it matters:** Unnecessary notification reschedules add implementation complexity. The SDS needs to know the exact set of fields that trigger a reschedule.

**PM Response: CLARIFIED.**

The LE is correct that changing the linked bank account does not affect notification timing. The notification schedule (SS5.1.7) is driven solely by billing date and payment due date. However, the linked bank account affects the **content** of the payment entry form (pre-filled source account). The word "notification reschedule" in input-fields.md SS2.2 is imprecise -- it should read "notification content update" for the linked bank account field.

**Corrected specification:**
- **Billing date change** -> reschedule all notifications (timing changes).
- **Payment due date change** -> reschedule all notifications (timing changes).
- **Linked bank account change** -> no notification reschedule needed. The payment form reads the linked bank account at the time the user taps "Pay," not at notification schedule time.

This will be corrected in input-fields.md SS2.2 (Credit Card) in the next revision. The "triggers notification reschedule" annotation on the linked bank account field should be removed.

**LE Verdict: ACCEPTED.**

The clarification is precise: billing date and payment due date trigger reschedule; linked bank account does not. The correction from "notification reschedule" to "notification content update" (and then the further clarification that even that is unnecessary since the form reads the linked bank account at tap time) is thorough.

---

### TC-014: "Curated subset" of material_symbols_icons -- who defines it and when

**Documents:** PRD SS5.2.4

**Issue:** Category icons are "selected from the `material_symbols_icons` Flutter package" with a "curated subset" for the picker. The PRD says "the exact subset and bundling strategy (tree-shaking, selective import) are deferred to SDS for efficiency analysis." However, this is partly a product decision (which icons are available to the user) and partly a technical decision (how to bundle them). The product owner needs to provide or approve the icon subset before the SDS can finalize the bundling strategy.

**Why it matters:** The icon set directly affects the category creation UX. If the curated subset is too small, users cannot find appropriate icons. If too large, the picker is overwhelming and the app binary bloats. This is blocked on a product-level decision, not just SDS.

**PM Response: ACKNOWLEDGED -- Escalate to founder.**

The LE is correct that this is partly a product decision. The two decisions needed are:

1. **Approximate target count for the curated subset:** The PM proposes **200-300 icons** as a starting range -- enough to cover all reasonable personal finance categories (food, transport, health, entertainment, utilities, etc.) plus general-purpose icons (star, heart, tag, etc.) without overwhelming the picker. The founder should confirm or adjust this range.
2. **Curation ownership:** The PM will produce a candidate icon list (organized by theme/domain) for the founder to review and approve. This can happen in parallel with SDS work -- the SDS can proceed with the architecture for icon bundling (tree-shaking, selective import) using a placeholder count of ~250 icons.
3. **The icons for default categories** must be defined as part of the curation since they are pre-loaded at first install (SS5.6.1).

This requires a founder decision on the acceptable range and final approval of the curated list. The SDS can proceed with bundling strategy independently.

**LE Verdict: ESCALATION CONFIRMED.**

The escalation is warranted. The 200-300 icon range is reasonable for a finance app. The decoupling of curation (founder approval) from bundling architecture (SDS) is correct -- the SDS can proceed with the ~250 placeholder count. The note that default category icons must be part of the curated set is an important dependency to track.

**Founder Resolution (2026-04-14): RESOLVED — Option A.**

Option A confirmed (~200-300 icons). The founder notes that the curation pass requires additional work and should be tracked as a separate task. The SDS proceeds with ~250 placeholder count. The icon curation task is a dependency for category seeding (SS5.6.1) and the category picker (UX-11) but does not block schema or business logic work.

---

### TC-015: Soft-delete reversing entry -- visible or invisible?

**Documents:** PRD SS4.8, SS5.1.3, SS5.2.2

**Issue:** There is ambiguity about the visibility of soft-delete reversing entries. PRD SS4.8 says "soft delete posts an automatic reversing entry." PRD SS5.1.3 says deletion "posts an invisible reversing entry." PRD SS5.2.2 says "a reversing entry is posted automatically. The original record is retained but excluded from all normal views." The word "invisible" in SS5.1.3 suggests the reversal itself is hidden, while SS5.2.2 says the "original record" is excluded (but does not explicitly say the reversal is hidden). Are both the original and the reversing entry excluded from normal views?

**Why it matters:** The transaction list filter logic must know exactly which transaction records to exclude. If the reversing entry is visible, it would appear as a confusing duplicate-looking entry in the list.

**PM Response: CLARIFIED.**

Both the original transaction and the reversing entry are excluded from normal views. The specification is consistent when read together:

- SS5.1.3 says deletion "posts an invisible reversing entry" -- the word "invisible" applies to the reversing entry.
- SS5.2.2 says "The original record is retained but excluded from all normal views" -- the original is also excluded.
- SS4.8 says "soft delete posts an automatic reversing entry to neutralise it. The original transaction record is retained" -- retained in the DB but excluded from views.

**Complete rule:** On soft-delete, **both** the original transaction and its reversing entry are excluded from the default transaction list. Using the status/purpose model from TC-001:
- The original transaction's status becomes `voided`.
- The reversing entry has `purpose = reversal` and `status = posted`.
- The default transaction list excludes `status = voided` and `purpose = reversal`.

Both participate in balance computation (the reversal cancels the original), but neither is shown in normal views. The v2 audit view will surface them. The word "invisible" in SS5.1.3 is correct and applies to the reversal. SS5.2.2's "excluded from all normal views" refers to the original. No inconsistency exists -- just scattered phrasing that will be consolidated in the next revision.

**LE Verdict: ACCEPTED.**

The complete rule (both original and reversing entry excluded from the default list; both participate in balance computation) is clear and consistent with the TC-001 status/purpose model. The display filter (`status = posted AND purpose IN (user, correction, system)`) correctly excludes both `voided` originals and `reversal` entries.

---

### TC-016: Balance Adjustment category -- icon and name

**Documents:** PRD SS5.2.4

**Issue:** The "Balance Adjustment" category is protected and "completely hidden from the category management screen." However, it is visible in the transaction list when Balance Adjustment transactions exist. The PRD does not specify what icon this category has. Since it is system-managed and cannot be edited, the icon must be defined at the product level.

**Why it matters:** The default category seeding (SS5.6.1) must include the Balance Adjustment category with a defined icon. Without a product decision on the icon, the SDS/UX cannot render it.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The Balance Adjustment category needs a defined icon since it is system-managed and cannot be changed by the user. The PM proposes:

- **Icon:** `balance` from the `material_symbols_icons` package (the balance/scale icon). If unavailable, `tune` or `swap_vert` as alternatives.
- **Name:** "Balance Adjustment" (already defined in SS5.2.4).
- **Applies to both the income and expense tree instances** of this protected category.

This will be added to SS5.2.4 (default category tables) and SS5.6.1 (seeding) in the next revision. The founder may override the icon choice during the icon curation pass (TC-014).

**LE Verdict: ACCEPTED.**

The `balance` icon proposal is sensible for a Balance Adjustment category. The note that it applies to both income and expense tree instances is important for the seeding logic. The founder can override during the icon curation pass.

---

---

## Category B -- Inconsistent Product Specifications

These items contradict each other across or within documents.

---

### TC-017: PRD SS4.5 expense entry sides vs. ledger-entry.md Case 1.1

**Documents:** PRD SS4.5, ledger-entry.md Case 1.1

**Issue:** PRD SS4.5 states for expenses: "At least one expense category entry (debit side -- expense category balance increases)" and "At least one account entry (credit side -- the source of funds; account balance decreases)." This is correct and consistent with ledger-entry.md Case 1.1 (`Dr EC, Cr A`). However, the memory file (project_variance_deb_model.md) still contains the pre-Q41 conflicting formulation: "Expense: category entry on CREDIT side; account entry on DEBIT side" which is the exact opposite. While the memory file is not a product spec, it will be consumed by subagents and will produce incorrect implementations.

**Why it matters:** The stale memory file will mislead any subagent implementing the ledger engine. It should be corrected to match the resolved specification. (Note: this is included here as a documentation consistency issue rather than a pure spec issue, because it will directly cause implementation bugs.)

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The memory file `project_variance_deb_model.md` contains pre-Q41 language that directly contradicts the resolved specification. Specifically:

- **Memory file says:** "Expense: category entry on CREDIT side; account entry on DEBIT side" -- this is **reversed** from the correct spec.
- **PRD SS4.5 says:** "At least one expense category entry (debit side)... At least one account entry (credit side)" -- this is correct.
- **Memory file says:** "Income: category entry on DEBIT side; account entry on CREDIT side" -- this is also **reversed**.
- **PRD SS4.5 says:** Income: account entry on debit side, category entry on credit side -- correct.

Additionally, the memory file still lists Q41 as "OPEN" and shows separate asset/liability balance formulas, which were unified under the universal formula (SS4.6). The memory file also references Q35 as open, which has been resolved (EQ is invisible, excluded from net worth).

**Action:** The memory file must be updated to match the resolved PRD. This is a documentation fix, not a product change. I will update it as part of this review cycle.

**LE Verdict: ACCEPTED.**

This is a critical documentation fix. The stale memory file would directly produce incorrect implementations in any subagent consuming it. The PM's commitment to update it as part of this review cycle is the right action.

---

### TC-018: PRD SS4.8 "in-place edits" list inconsistent with input-fields.md

**Documents:** PRD SS4.8, SS5.2.2, input-fields.md SS1.1

**Issue:** PRD SS4.8 states: "In-place edits are limited to: title, description, and photos only." But SS5.2.2 adds: "In-place edits (no ledger posting): Title, description, photos, and date/time." Input-fields.md SS1.1 marks date/time as **IP** (in-place edit). So SS4.8 omits date/time from the in-place edit list, while SS5.2.2 and input-fields.md correctly include it. SS4.8 should be updated to include date/time.

**Why it matters:** A developer reading SS4.8 in isolation would implement date/time changes as ledger corrections (reversing + corrected entries), which would be wrong per the rest of the specification.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. SS4.8 states "In-place edits are limited to: title, description, and photos only" but omits date/time, which is marked as IP (in-place) in SS5.2.2 and input-fields.md SS1.1. This is an inconsistency in SS4.8. The correct and authoritative list of in-place editable fields is:

- Title
- Description
- Photo(s)
- Date/time

SS4.8 will be updated to include date/time in the in-place edit list in the next PRD revision. The authoritative field editability reference remains input-fields.md (which is correct).

**LE Verdict: ACCEPTED.**

Straightforward documentation fix. The authoritative source (input-fields.md) is correct; SS4.8 is the one that needs updating. The SDS will treat input-fields.md as the canonical editability reference.

---

### TC-019: Transaction data model -- notes field removal inconsistency

**Documents:** PRD SS5.2.1, SS4.3

**Issue:** PRD SS5.2.1 states "Notes has been removed from transactions and replaced by two separate optional fields: Title and Description." However, the data model in SS4.3 does not list Title or Description as transaction fields -- it only shows `id` and `type`. While SS4.3 is clearly a minimal schema sketch, it is the only formal data model definition in the PRD. The disconnect between the minimal model and the full field set (spread across SS5.2.1 and input-fields.md) creates ambiguity about which document is authoritative for the transaction schema.

**Why it matters:** The SDS needs a single authoritative source for the transaction entity schema. Currently, the full field set must be assembled from three locations (SS4.3 + SS5.2.1 + input-fields.md), with SS4.3 being misleadingly minimal.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. SS4.3 is intentionally minimal (it defines the DEB model, not the full entity schema), and SS5.2.1 replaced "notes" with "title" and "description" without updating SS4.3. The authoritative source for user-facing transaction fields is **input-fields.md SS1.1**. SS4.3 defines the ledger entry structure, not the transaction entity.

To resolve: the PRD will add a note to SS4.3 stating that it defines the **ledger entry model** only, and that the full transaction entity schema (including all user-facing and system fields) is defined in input-fields.md and will be consolidated in the SDS data model. The PRD is not the right place for a full typed schema -- that belongs in the SDS data model document (`docs/02-technical/data-model.md`). See also TC-024 for the full field enumeration.

**LE Verdict: ACCEPTED.**

Correct resolution. The PRD's SS4.3 defines the DEB model, not the full application schema. Adding a scoping note to SS4.3 and pointing to input-fields.md as the authoritative field reference (with the SDS data model as the final consolidated schema) is the right approach. The SDS will be the single source of truth for the typed schema.

---

### TC-020: Account deletion balance transfer -- transaction editability conflict

**Documents:** PRD SS5.1.1, ledger-entry.md Case 2.5a

**Issue:** PRD SS5.1.1 says the system-generated balance transfer on account deletion is "not user-editable." Ledger-entry.md Case 2.5a says it is "visible in the transaction list but is not user-editable." However, PRD SS5.1.1 also says: "If the user later attempts to soft-delete this system transfer, the app warns..." -- this implies the user can initiate a delete on it, receiving a warning. If the transaction is truly "not user-editable," can it be soft-deleted? Is soft-delete considered an "edit"? The specification conflates editability (changing fields) with deletability (voiding).

**Why it matters:** The contextual menu for system-generated transfers must know which actions to expose. If "not editable" means "cannot change any fields but can be soft-deleted with a warning," that needs to be explicit. If it means "cannot be touched at all," the soft-delete warning scenario is unreachable.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE correctly identifies that "not user-editable" conflates field editing with deletion. The product intent is:

1. **"Not user-editable"** means: the user cannot modify any fields (amount, account, title, description, date, photos) on the system-generated transfer. The Edit action is **not available** in the contextual menu.
2. **Soft-deletable with warning:** The user CAN initiate a soft-delete on the system-generated transfer. The Delete action IS available in the contextual menu, but it triggers the warning described in SS5.1.1: "This transfer was created when you deleted [account name]. Voiding it will reduce your net worth because the source account is no longer active."
3. **Contextual menu for system-generated transfers:** Delete (with warning). No Edit. No other actions.

The distinction is: **editability** (changing fields) and **deletability** (voiding) are separate concepts. System-generated transfers are non-editable but deletable-with-warning. This will be clarified in SS5.1.1 and ledger-entry.md Case 2.5a in the next revision.

**LE Verdict: ACCEPTED.**

The editability vs. deletability distinction is the correct resolution. The contextual menu specification (Delete with warning, no Edit) is concrete enough to implement. The warning text is well-crafted for the user impact.

---

### TC-021: Installment early close -- "Total configured" immutability exception

**Documents:** PRD SS5.2.8, input-fields.md SS5.1, SS5.2

**Issue:** Throughout SS5.2.8 and input-fields.md SS5.1, "Total configured" is defined as "immutable after creation." However, the installment early close flow (SS5.2.8, input-fields.md SS5.2) includes the option: "Update target: Total configured is updated to match Running total. The mismatch is resolved." This directly contradicts the immutability rule. If the user can update Total configured during early close, it is not truly immutable.

**Why it matters:** The data model and business logic must know whether `total_configured` can ever change. If it can change only during early close, that exception must be modeled. If it is truly immutable, the early close flow needs redesign.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE correctly identifies the contradiction. The resolution is:

1. `total_configured` is **immutable during normal operation** -- the user cannot change it through the template edit flow.
2. `total_configured` **can be updated during the early close flow only**, as an explicit user choice in response to the mismatch warning (SS5.2.8 step 4: "Update target: Total configured is updated to match Running total").
3. This is a **controlled exception**, not a general editability rule. The early close flow is the only code path that writes to `total_configured` after creation.

**Data model implication:** `total_configured` does not need an `IM` (immutable) constraint at the DB level -- the immutability is enforced at the application/business logic layer. The DB column is a normal mutable field. The business rule is: "only the early close flow may modify this field after creation."

The PRD will be updated to clarify SS5.2.8 and input-fields.md SS5.1: `total_configured` is "immutable after creation **except during early close**, where the user may choose to update it to match the running total." The editability legend should note this exception.

**LE Verdict: ACCEPTED WITH NOTE.**

The controlled exception model (application-layer enforcement, not DB-level constraint) is correct and practical. The SDS author should note: the early close flow is the only write path for `total_configured` after creation. The business logic layer should enforce this invariant with a clear guard clause (e.g., an assertion or a dedicated method like `updateTotalOnEarlyClose()`) rather than exposing a generic setter. This makes the exception auditable in code review.

---

### TC-022: Loan account installment suggestion -- transaction type inconsistency

**Documents:** PRD SS5.1.2

**Issue:** The loan installment setup suggestion pre-fills "Destination account: This loan account (fixed)." This implies the installment transactions are transfers (money moving from a source account to the loan account). However, the table does not specify the transaction type, and SS5.2.8 says installments generate entries "identical to Case 1.1 (expense) or 1.2 (income)." A loan repayment is economically a transfer (bank -> loan), not an expense. But if installments only support expense and income types, how does a loan repayment installment work?

**Why it matters:** The installment template creation form for a loan must produce the correct transaction type. If installments cannot be transfers, the loan repayment use case is broken. If they can, then SS5.2.8's restriction to Cases 1.1/1.2 is incomplete.

**PM Response: ACKNOWLEDGED -- Escalate to founder.**

The LE has identified a genuine inconsistency that requires a product decision. The conflict:

- **SS5.2.8 and ledger-entry.md Case 3.2** restrict installments to expense (Case 1.1) or income (Case 1.2) types.
- **SS5.1.2** describes a loan repayment installment that pre-fills a destination account (the loan), implying a transfer.
- **SS5.2.7** (recurring templates) supports all three types: income, expense, transfer.

The options for the founder:

**Option A -- Installments support all three types (income, expense, transfer).** This is the simplest resolution. Installments inherit the full transaction type support from recurring templates. Case 3.2 in ledger-entry.md would be updated to: "same as 1.1, 1.2, or 1.3 (or 1.3a if fee applies)." The loan installment suggestion works as designed. The installment tracking (4 amounts) works identically for transfers.

**Option B -- Loan repayments are modeled as expenses, not transfers.** The installment remains expense-only. The loan account is treated as the category, not the destination account. This is conceptually wrong from a DEB perspective (a loan repayment is a transfer of funds, not an expense) and would require rethinking the loan installment suggestion.

**PM recommendation:** Option A. Installments should support all three transaction types. The restriction in Case 3.2 was likely an oversight. This is the only way the loan repayment use case works correctly.

Escalating to founder for confirmation.

**LE Verdict: ESCALATION CONFIRMED.**

The escalation is warranted. Option A (installments support all three types) is the only correct resolution from a DEB perspective. A loan repayment is unambiguously a transfer (funds move from a source account to the loan account), not an expense. Option B would produce incorrect ledger entries. The PM's recommendation is correct. The SDS should plan for transfer-type installments (including the Case 1.3a variant for transfer-with-fee installments) in the schema and scheduler.

**Founder Resolution (2026-04-14): RESOLVED — Option A (all three types).**

Installments support income, expense, and transfer transaction types. Case 3.2 in `ledger-entry.md` updated to reference Cases 1.1, 1.2, 1.3, and 1.3a. The loan repayment use case (bank → loan transfer installment) is confirmed working under the universal formula. The installment 4-amount tracking is type-agnostic and requires no special casing. Transfer-type installment templates expose source + destination account fields; transfer-with-fee installments additionally expose the fee panel (fee mode, fee amount/percentage, fee category). TC-038 (duplicate) is also resolved by this decision.

---

### TC-023: Category filter -- multi-select scope unclear across transaction types

**Documents:** PRD SS5.2.6

**Issue:** The filter says categories are "Contextual -- only shows income categories for income filter." But categories and transaction type are separate filter criteria, both with multi-select. If the user selects both Income and Expense in the transaction type filter, which categories are shown? All income + all expense? Does changing the transaction type filter dynamically update the category picker? What if the user has already selected income categories and then adds Expense to the type filter?

**Why it matters:** The filter UI must handle the cross-product of type and category selections. The interaction model between these two filters is undefined and has multiple valid implementations with different UX implications.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid UX interaction question. The product-level rules:

1. **Category picker is dynamically filtered by the current transaction type selection.** If the user selects "Income" only, the category picker shows income categories. If "Expense" only, expense categories. If both "Income" and "Expense" are selected, the picker shows both income and expense categories (grouped by tree with a visual separator). If "Transfer" is selected (alone or with others), transfers have no category, so the category criterion is disabled for transfer results but still applies to income/expense results.
2. **Adding a type to the type filter does NOT clear already-selected categories.** If the user selected income categories and then adds "Expense" to the type filter, the income category selections are preserved and expense categories become additionally available in the picker.
3. **Removing a type from the type filter removes its categories from the selection.** If the user had income and expense types selected with categories from both, then deselects "Income," all selected income categories are automatically deselected.
4. **If no transaction type is selected** (all cleared), the category picker shows all categories from both trees.

This will be added to SS5.2.6 in the next revision.

**LE Verdict: ACCEPTED.**

The dynamic category picker behavior (filtered by current type selection, additive when types are added, subtractive when types are removed) is well-specified and covers the interaction edge cases. The rule for "no transaction type selected" (show all categories) is a sensible default. This is implementable as stated.

---

---

## Category C -- Missing Product Specifications

These items are needed for implementation but not specified anywhere in the documents.

---

### TC-024: Transaction entity -- complete field enumeration and data types

**Documents:** PRD SS4.3

**Issue:** The formal data model in SS4.3 defines a Transaction as only `id` and `type`. The full field set is scattered across SS5.2.1, SS5.2.2, SS5.7, SS7.1, and input-fields.md. No single location provides a definitive, typed schema for the transaction entity including all system fields. Missing system-level fields include: `status` (posted/pending/voided?), `created_at`, `updated_at`, `compound_group_id`, `parent_template_id`, `is_system_generated`, `exchange_rate_to_home`, `is_manually_handled`, and potentially `correction_chain_id` (linking original -> reversing -> corrected).

**Why it matters:** The SDS data model cannot be designed without a complete entity definition. The current specification requires the architect to infer and assemble the full schema from 5+ locations, risking omissions.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that no single location provides the complete transaction entity schema. The PRD intentionally keeps SS4.3 minimal (it defines the DEB ledger model, not the full application entity). The full transaction entity, assembled from all product documents, is:

**User-facing fields** (from input-fields.md SS1.1, SS1.2, SS1.3):
- `date_time` (DateTime, required)
- `amount` (Decimal > 0, required)
- `type` (Enum: income/expense/transfer, required, immutable)
- `account_source_id` (Account ref, required for expense/transfer)
- `account_destination_id` (Account ref, required for income/transfer)
- `category_id` (Category ref, required for income/expense, null for transfer)
- `subcategory_id` (Category ref, optional for income/expense, null for transfer)
- `title` (Text, optional)
- `description` (Text, optional, max length per SS5.4.3)
- `photos` (Image[], optional, max 2)

**System fields** (inferred from SS5.7, SS4.8, SS5.2.2, SS5.1.5b, SS7.1, SS5.2.7):
- `id` (UUID, primary key)
- `status` (Enum: pending/posted/voided -- per TC-001)
- `purpose` (Enum: user/reversal/correction/system -- per TC-001)
- `compound_group_id` (UUID, nullable -- per TC-002)
- `parent_template_id` (Template ref, nullable -- links to recurring/installment template)
- `is_system_generated` (Boolean -- true for account deletion transfers, opening balance postings)
- `exchange_rate_to_home` (Decimal, nullable -- SS7.1)
- `correction_chain_id` (UUID, nullable -- links original -> reversal -> correction chain)
- `created_at` (DateTime, UTC)
- `updated_at` (DateTime, UTC)

This consolidated list will be added to the PRD as a new subsection of SS4.3 or as an appendix, and will serve as the authoritative input to the SDS data model document.

**LE Verdict: ACCEPTED WITH NOTE.**

The consolidated field list is comprehensive. The SDS author should note two considerations: (1) The `correction_chain_id` needs a clear definition of its semantics -- does it link the original to the reversal, or the original to the correction, or all three? A linked-list model (each transaction has a `corrects_transaction_id` pointing to its predecessor) may be simpler and more flexible than a shared group ID, especially for chains of corrections (original -> correction1 -> correction2). The SDS should evaluate both approaches. (2) The `is_system_generated` boolean may be redundant with `purpose = system` from TC-001. The SDS should unify these into a single field to avoid dual-source-of-truth issues.

---

### TC-025: Ledger entry entity -- missing timestamps and metadata

**Documents:** PRD SS4.3, ledger-entry.md

**Issue:** The Entry (ledger line) entity in SS4.3 has: `transaction_id`, `account_id` or `category_id`, `amount`, and `side`. There is no `created_at` timestamp on entries. While entries inherit their transaction's date for display, the system needs to know when the entry was actually created (for audit, debugging, and the v2 audit view which shows correction history). Additionally, there is no entry-level ID defined.

**Why it matters:** Every database entity needs a primary key and creation timestamp for basic operational needs (ordering, debugging, migration). The entry entity specification is too minimal.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The Entry (ledger line) entity in SS4.3 is minimal. The complete entry entity should include:

- `id` (UUID, primary key)
- `transaction_id` (Transaction ref, required)
- `account_id` OR `category_id` (mutually exclusive, as defined in SS4.3)
- `amount` (Decimal > 0, required)
- `side` (Enum: debit/credit, required)
- `created_at` (DateTime, UTC -- when this entry was written to the ledger)

The `created_at` on entries is distinct from the transaction's `date_time` (which is the user-specified business date). For normal transactions they will be close in time, but for corrections and reversals, the entry `created_at` will be later than the original transaction's `date_time`. This is necessary for the v2 audit view's correction history display.

This will be added to the consolidated entity definitions in the next PRD revision.

**LE Verdict: ACCEPTED.**

The entry entity fields (`id`, `transaction_id`, `account_id`/`category_id`, `amount`, `side`, `created_at`) are complete for v1. The distinction between entry `created_at` (system timestamp) and transaction `date_time` (user-specified business date) is correctly articulated and essential for the audit trail.

---

### TC-026: Recurring/installment template entity -- complete schema

**Documents:** PRD SS5.2.7, SS5.2.8, input-fields.md SS4, SS5

**Issue:** There is no formal entity definition for recurring or installment templates. The fields are enumerated in input-fields.md SS4 and SS5, but system-level fields are missing: `id`, `status` (active/paused/archived), `created_at`, `next_occurrence_date`, `pause_until_date`, `is_installment` (or a type discriminator), and the relationship to child transactions. SS5.2.8 also mentions "4 tracked amounts" -- are these stored columns or computed?

**Why it matters:** The scheduler, template management screens, and child transaction linking all depend on the template entity schema. Without it, the SDS must guess at state management fields.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The complete recurring/installment template entity, assembled from SS5.2.7, SS5.2.8, and input-fields.md SS4/SS5:

**User-facing fields** (from input-fields.md SS4.1, SS5.1):
- `transaction_type` (Enum: income/expense/transfer, immutable)
- `amount` (Decimal > 0)
- `account_source_id` / `account_destination_id` (Account refs, as applicable)
- `category_id` / `subcategory_id` (Category refs, as applicable)
- `title` (Text, optional)
- `description` (Text, optional)
- `recurrence_n` (Integer > 0, immutable)
- `recurrence_unit` (Enum: day/week/month/year, immutable)
- `recurrence_constraints` (Enum set, optional, immutable)
- `start_date` (Date, immutable)
- `end_date` (Date, nullable, immutable -- for recurring; computed for installments per TC-010)
- `posting_behaviour` (Enum: auto_post/remind_and_confirm)

**Installment-specific fields** (from input-fields.md SS5.1, SS5.2.8):
- `is_installment` (Boolean -- type discriminator)
- `total_configured` (Decimal > 0, immutable except during early close per TC-021)
- `number_of_installments` (Integer > 0)

**System fields** (inferred from SS5.2.7, SS5.5.1):
- `id` (UUID, primary key)
- `status` (Enum: active/paused/archived)
- `created_at` (DateTime, UTC)
- `updated_at` (DateTime, UTC)
- `pause_until` (DateTime, nullable -- set when paused with a duration)
- `archived_at` (DateTime, nullable -- set when archived)
- `archived_reason` (Enum: end_date_reached/installments_exhausted/early_close/user_stopped, nullable)

**Tracked amounts for installments** (from SS5.2.8): `running_total`, `total_remaining`, and `projected_final_total` are **computed values**, not stored columns. They are derived from the materialized installment records (per TC-011). Only `total_configured` is stored on the template.

This will be added to the consolidated entity definitions in the next PRD revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The template entity schema is comprehensive and the decision to compute `running_total`, `total_remaining`, and `projected_final_total` rather than store them is correct (avoids stale data). The SDS author should note: (1) the `archived_reason` enum is a useful diagnostic field -- the SDS should ensure it is populated consistently across all archival code paths. (2) The `pause_until` field on a paused template must be checked on every app launch and scheduler tick to auto-resume expired pauses. The SDS should define whether auto-resume is eager (checked on launch) or lazy (checked when the next occurrence would fire).

---

### TC-027: Account entity -- missing system fields

**Documents:** PRD SS5.1.1, SS5.1.2, input-fields.md SS2

**Issue:** The account entity has user-facing fields defined in input-fields.md SS2, but system fields are not enumerated: `id`, `created_at`, `updated_at`, `is_deleted`, `deleted_at`, `is_protected` (for EQ), `currency_code`. The PRD mentions these concepts but does not consolidate them into a single entity definition.

**Why it matters:** Same as TC-024 -- the SDS needs complete entity schemas.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The complete account entity, assembled from SS5.1.1, SS5.1.2, and input-fields.md SS2:

**User-facing fields** (from input-fields.md SS2.1, SS2.2):
- `name` (Text, required, unique including soft-deleted)
- `account_category` (Enum: 8 fixed types, immutable)
- `initial_balance` (Decimal, immutable after creation -- one-time field)
- `currency` (ISO 4217, immutable)
- `include_in_net_worth` (Boolean, default true)
- `notes` (Text, optional)
- Category-specific fields per SS2.2 (all in-place editable)

**System fields:**
- `id` (UUID, primary key)
- `created_at` (DateTime, UTC)
- `updated_at` (DateTime, UTC)
- `is_deleted` (Boolean, default false)
- `deleted_at` (DateTime, nullable)
- `is_protected` (Boolean, default false -- true for EQ account, per SS5.2.4 protected entity pattern)

Note: `currency_code` is the same as the user-facing `currency` field -- it is not a separate system field. The balance is always computed from ledger entries (never stored).

This will be added to the consolidated entity definitions in the next PRD revision.

**LE Verdict: ACCEPTED.**

The account entity schema is complete. The `is_protected` flag for the EQ account follows the protected entity pattern from SS5.2.4. The note that balance is always computed (never stored) is critical and consistent with the PRD.

---

### TC-028: Category entity -- missing system fields

**Documents:** PRD SS5.2.4, input-fields.md SS3

**Issue:** Similar to TC-027. Categories have `icon` and `name` defined, but system fields are missing: `id`, `parent_id` (null for top-level), `tree_type` (income/expense), `is_deleted`, `is_protected`, `created_at`, `sort_order` (for future reordering in v2). The `is_protected` flag is mentioned in SS5.2.4 but not formally defined on the entity.

**Why it matters:** The category hierarchy, soft-delete filtering, and protected entity pattern all require these fields.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct. The complete category entity:

**User-facing fields** (from input-fields.md SS3.1, SS3.2):
- `icon` (Icon ref, required)
- `name` (Text, required, unique within parent for children, unique within tree for parents)

**System fields:**
- `id` (UUID, primary key)
- `parent_id` (Category ref, nullable -- null for top-level parents)
- `tree_type` (Enum: income/expense -- which tree this category belongs to)
- `is_deleted` (Boolean, default false)
- `deleted_at` (DateTime, nullable)
- `is_protected` (Boolean, default false -- true for Balance Adjustment categories)
- `created_at` (DateTime, UTC)
- `updated_at` (DateTime, UTC)
- `sort_order` (Integer, nullable -- for v2 manual reordering; null in v1, default display order is alphabetical per SS5.2.4)

This will be added to the consolidated entity definitions in the next PRD revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The category entity schema is complete. The SDS author should note: the `sort_order` field is nullable in v1 (alphabetical default), but the schema should include it from v1 to avoid a migration in v2. Including the column with null values costs nothing at the storage level but saves a potentially disruptive schema migration later. Also, the uniqueness constraint on category names (case-insensitive, within tree/parent, including soft-deleted) needs a composite unique index -- the SDS should define this index explicitly in the schema.

---

### TC-029: How does the app handle home currency changes after transactions exist?

**Documents:** PRD SS5.4.2, SS7

**Issue:** The home currency is "changeable at any time in Settings." But the specification does not address what happens to existing transactions that have a stored `exchange_rate_to_home` when the home currency changes. Are those rates invalidated? Are they preserved as historical? Does the app re-fetch rates for all foreign-currency accounts relative to the new home currency? What happens to the net worth display?

**Why it matters:** Changing the home currency is a significant system event that potentially invalidates all cached exchange rates and all stored transaction-level rates. Without a defined migration/recalculation strategy, the feature could produce incorrect financial data.

**PM Response: ACKNOWLEDGED -- Escalate to founder.**

The LE raises a critical point. Changing the home currency has cascading effects that are not specified. The options:

**Option A -- Stored transaction-level rates are preserved as historical; new rates are fetched for the new home currency.**
- Existing `exchange_rate_to_home` values on transactions become "rate to the old home currency." They are no longer directly usable for displaying the new home currency equivalent.
- The app would need to either (a) refetch/recompute rates for all historical transactions (expensive, may be impossible for historical dates), or (b) chain-convert through the old rate (transaction_amount * old_rate_to_old_home / new_rate_old_home_to_new_home -- imprecise).
- Net worth display immediately switches to new home currency using newly fetched rates.
- The cached rate table is invalidated; new rates (all user currencies relative to new home currency) are fetched.

**Option B -- Restrict home currency changes when foreign-currency accounts exist.**
- If the user has only home-currency accounts, the change is trivial (no rates involved).
- If foreign-currency accounts exist, warn: "Changing your home currency will affect how foreign-currency amounts are displayed. Historical transaction exchange rates were captured relative to [old currency] and cannot be automatically converted."
- Proceed anyway: old `exchange_rate_to_home` values are marked stale (or a `home_currency_at_capture` field is stored alongside to enable future conversion).

**PM recommendation:** Option B with a warning. The stored `exchange_rate_to_home` should additionally store `home_currency_at_capture` (the home currency ISO code at the time the rate was captured). This allows future display logic to detect stale rates and potentially chain-convert. The warning makes the user aware that historical display amounts may be approximate after a home currency change.

Escalating to founder: this is a product decision about acceptable data fidelity after a home currency change.

**LE Verdict: ESCALATION CONFIRMED.**

This is a critical product decision with deep data model implications. The PM's analysis of both options is thorough. Option B with `home_currency_at_capture` is the correct engineering approach -- it preserves data lineage without requiring expensive recalculation. The SDS author should note: the `exchange_rate_to_home` field on transactions becomes semantically ambiguous after a home currency change (it refers to the old home currency). Storing `home_currency_at_capture` alongside every rate makes this unambiguous and supports future chain-conversion if needed. The warning text should make clear that historical home-currency equivalents may be approximate.

**Founder Resolution (2026-04-14): RESOLVED — simpler than anticipated.**

The founder's key insight: account currencies are immutable at creation. Transaction currencies are derived from accounts (not independent). Therefore, at the **data level**, changing the home currency affects nothing retroactively. The only product-level implication of changing home currency is that the **default currency for new account creation** changes to the new home currency.

The display/aggregation concern (net worth, category balances, home-currency equivalents on transaction cards) is an **engineering decision**, delegated to the LE. The LE will define exchange rate storage and display recalculation strategy in the SDS. The proposed approach: two-field model (`exchange_rate_to_home` + `home_currency_at_capture`) with chain-conversion in the display layer for stale rates. No warning dialog is required — this is a straightforward settings change. No transaction records are modified on home currency change.

---

### TC-030: Recurring "remind and confirm" -- what happens when multiple occurrences stack up?

**Documents:** PRD SS5.2.7

**Issue:** If a "remind and confirm" template fires daily and the user does not open the app for a week, SS5.2.7 says "if the 24-hour confirmation window has already elapsed, the missed occurrence is auto-approved and posted at launch." This means 7 transactions would be auto-posted simultaneously. But: (a) are they posted in chronological order with their original scheduled dates? (b) do duplicate detection checks fire for each? (c) do overdraft warnings fire for each? (d) is there a UI flow showing the user what was auto-posted?

**Why it matters:** Bulk auto-posting could produce unexpected account states (deep overdraft) without the user understanding why. The interaction with warnings and detection systems needs definition.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid operational concern. The product rules for stacked "remind and confirm" occurrences:

1. **Posting order:** Missed occurrences are posted in **chronological order** with their original scheduled dates. The posting date (when the ledger write actually happens) is the current launch time, but the transaction `date_time` is the original scheduled date.
2. **Duplicate detection:** Does **not** fire for auto-approved missed occurrences. These are expected recurring transactions, not user-initiated entries. Triggering duplicate detection for each would produce a cascade of false warnings.
3. **Overdraft warnings:** Do **not** fire for auto-approved missed occurrences. Since the user was not present to respond, the warnings would be unactionable noise. The overdraft state is visible in the account balance after launch.
4. **UI notification at launch:** When missed occurrences are auto-posted, the app displays a **one-time summary notification** (in-app banner or alert card on the home screen): "[N] recurring transactions were auto-posted while you were away. [View details]." Tapping "View details" navigates to the relevant transactions in the list.
5. **This applies only to "remind and confirm" templates where the 24-hour window elapsed.** "Auto-post" templates would have been posted by the scheduler on time (or on next launch if the scheduler was unable to run) -- they do not stack in the same way.

This will be added as a clarification to SS5.2.7 in the next revision.

**LE Verdict: ACCEPTED.**

The stacked occurrence rules are well-defined. Posting in chronological order with original scheduled dates, suppression of duplicate detection and overdraft warnings for auto-approved occurrences, and the one-time summary notification are all correct product decisions. The distinction from "auto-post" templates (which the scheduler handles on time) is clear.

---

### TC-031: Navigation structure -- app-level navigation model

**Documents:** PRD SS5.8, SS5.4, SS5.5

**Issue:** The PRD defines the home screen (SS5.8), settings (SS5.4), and contextual menus (SS5.5), but there is no specification of the app's primary navigation structure. Is there a bottom navigation bar? A drawer? How does the user move between home, accounts, settings, and Pending Confirmations? The PRD mentions "Pending Confirmations" is "accessible from the app's navigation overflow menu" and "Color scheme preview" is also in the "navigation options menu" -- but the navigation container itself is not defined.

**Why it matters:** The entire UI architecture depends on the navigation model. The SDS and UX flows cannot be designed without knowing whether the app uses bottom nav, drawer, or single-screen-with-modals.

**PM Response: ACKNOWLEDGED -- Escalate to founder.**

The LE is correct that the app-level navigation model is not defined. The PRD describes individual screens (home, settings, account detail, pending confirmations) but does not specify how the user moves between them. This is a foundational UX decision.

The options:

**Option A -- Bottom navigation bar.** Tabs: Home, Accounts, [Add/+], Settings. Clean, always-visible, standard Material 3 pattern. "Pending Confirmations" and "Color scheme preview" accessible from an overflow menu on the top app bar.

**Option B -- Single primary screen (Home) with drawer navigation.** Home is the central hub. Drawer contains: Accounts, Settings, Pending Confirmations, Color scheme preview. The home screen hosts the transaction list, summary, and quick-entry FAB. Simpler architecture but less discoverable.

**Option C -- Bottom navigation with 3 tabs.** Home (transaction list + summary), Accounts (account list + net worth), Settings. FAB for quick entry floats over the active tab. Pending Confirmations accessible from overflow.

**PM recommendation:** Option A or C. Bottom navigation is the standard Android/Material 3 pattern for apps with 3-5 primary destinations. The exact tab set requires founder input.

Escalating to founder: this is a core UX architecture decision that must be resolved before UX Flows can be designed.

**LE Verdict: ESCALATION CONFIRMED.**

This is the highest-priority founder decision. The entire UX flow document, GoRouter route structure, and scaffold architecture depend on this. The PM's options are well-framed. Option C (3 tabs: Home, Accounts, Settings) is the cleanest from an engineering perspective -- it maps to 3 top-level routes and avoids a drawer. The SDS is blocked on this decision for the navigation/routing architecture but can proceed with most other schema and business logic work.

**Founder Resolution (2026-04-14): RESOLVED — Option A (bottom navigation bar).**

Bottom navigation bar confirmed. The founder notes this should have been an LE decision, not a founder escalation — going forward, the LE owns navigation structure decisions unless the feature map is affected. The LE proposes 3 tabs: Home (transaction list + summary + FAB), Accounts (account list + net worth), Settings. Pending Confirmations is accessible from Settings rather than a top-bar overflow menu. The GoRouter route hierarchy maps to a `StatefulShellRoute` with 3 branches. This unblocks the UX Flows document and GoRouter architecture.

---

### TC-032: Account detail screen -- specification missing

**Documents:** PRD SS5.1.4, SS5.8.4

**Issue:** The PRD references an "account detail screen" multiple times (SS5.1.4, SS5.1.6 for credit card, SS5.8.4 "tapping an account navigates to its detail view") but never defines its contents. What does the account detail screen show? Account metadata fields? Balance? A per-account transaction list? The reconcile action? The edit/delete actions? The Pay FAB for credit cards?

**Why it matters:** The account detail screen is a primary navigation destination (tapping any account goes there) but has no specification. The UX flow cannot be designed.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the account detail screen is referenced but never defined. The product specification for the account detail screen:

**Account Detail Screen -- Contents:**

| Section | Content | Notes |
|---------|---------|-------|
| **Header** | Account name, account category badge, currency | |
| **Balance** | Current computed balance (from ledger). For credit cards: outstanding balance AND statement balance (SS5.1.6) | Negative balance styled per SS5.1.4 |
| **Account metadata** | All category-specific fields (SS5.1.2) displayed as read-only. Sensitive fields (card numbers, account numbers) masked with reveal-on-auth (SS5.4.6) | |
| **Net worth inclusion** | "Included in net worth" / "Excluded from net worth" indicator | |
| **Per-account transaction list** | Transactions filtered to this account. Same display rules as the unified list (SS5.2.1). Search and filter available, scoped to this account. | |
| **Contextual actions** | Edit Account, Delete Account, Reconcile (SS5.1.3a) | Via app bar or contextual menu |
| **Credit card only: Pay FAB** | Floating action button for credit card payment (SS5.1.7) | Only on credit card accounts |

This will be added as a new subsection (SS5.1.4a or similar) in the next PRD revision.

**LE Verdict: ACCEPTED.**

The account detail screen specification is complete and covers all necessary sections: header, balance (with CC dual-balance), metadata (with masked sensitive fields), net worth indicator, per-account transaction list (with scoped search/filter), contextual actions, and CC-specific Pay FAB. This provides sufficient detail for the UX Flows document and the SDS screen architecture.

---

### TC-033: Error handling for failed ledger operations

**Documents:** PRD SS4, ledger-entry.md

**Issue:** The PRD and ledger-entry.md define all the posting cases but never specify what happens when a ledger operation fails. For example: what if the database write for a reversing + corrected pair partially fails (reversal posted but correction fails)? NF-8 says "all writes are ACID-compliant" but the application-level error recovery is unspecified. Does the app show an error dialog? Retry? Roll back? What is the user's recourse?

**Why it matters:** ACID at the DB level prevents data corruption, but the application must still handle failure cases gracefully in the UI. The user needs to know their action failed and what to do next.

**PM Response: DEFERRED TO SDS.**

The LE is correct that application-level error recovery is unspecified. However, this is an engineering concern, not a product specification gap. The product-level requirements are:

1. **ACID compliance (NF-8):** All ledger operations (including multi-entry corrections and compound transactions) must be atomic. If any part fails, the entire operation rolls back. The user never sees a partial state.
2. **Error UX (product-level):** If a ledger write fails, the app must show a clear error message: "Unable to save this transaction. Please try again." The user's form data must be preserved so they can retry without re-entering fields.
3. **No silent failures:** The user must always be informed if their action did not succeed.
4. **No manual recovery needed:** Since ACID guarantees atomicity, there is no "partial failure" state for the user to recover from. The operation either succeeds completely or fails completely.

The specific error handling patterns (try/catch structure, DB transaction wrapping, retry logic) are SDS decisions. The product requirement is simply: atomic success or atomic failure with a user-facing error message and preserved form state.

**LE Verdict: DEFERRAL ACCEPTED.**

The product-level error handling requirements (ACID atomicity, user-facing error message, preserved form state, no silent failures) are sufficient. The SDS will define the technical error handling patterns. The "preserved form state" requirement is an important UX consideration that the SDS should enforce in the presentation layer (e.g., form data survives a failed save attempt).

---

### TC-034: Batch category migration -- performance and UX for large N

**Documents:** Ledger-entry.md Case 3.7, PRD SS5.2.4

**Issue:** Ledger-entry.md notes: "If N transactions are migrated, this produces 2N transactions and 4N ledger entries... For large N, consider performance implications (batched writes, progress indicator)." The PRD does not specify: (a) is there a progress indicator during batch migration? (b) is there a transaction count threshold above which a warning is shown? (c) can the user cancel a migration in progress? (d) what happens if the app is killed mid-migration (given atomicity requirement)?

**Why it matters:** A user with 500 transactions in a category would trigger 1000 transactions and 2000 ledger entries in a single operation. Without UX guidance on progress, cancellation, and error recovery, this could appear as a frozen app.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid UX concern for large batch operations. The product rules:

1. **Progress indicator:** Yes. For batch migrations of **more than 10 transactions**, a progress dialog is shown: "Migrating transactions... [X of N]". For 10 or fewer, the operation completes fast enough that no progress indicator is needed.
2. **Cancellation:** **Not supported.** The batch migration is atomic (NF-8). Either all transactions are migrated or none are. Allowing cancellation mid-batch would leave the ledger in an inconsistent state. The user commits to the full migration when they confirm the prompt.
3. **App killed mid-migration:** The ACID guarantee (NF-8) handles this. If the app is killed, the DB transaction rolls back and no migrations are applied. On next launch, the category is still in its pre-deletion state. The user would need to re-initiate the deletion flow.
4. **Warning threshold:** For migrations of **more than 50 transactions**, an additional confirmation is shown: "This will migrate [N] transactions. This may take a moment and cannot be undone. Continue?"
5. **Performance:** The SDS should implement the batch as a single DB transaction with batched writes (not N individual transactions). Target: complete within 5 seconds for N = 500.

This will be added to SS5.2.4 (category deletion flow) in the next revision.

**LE Verdict: ACCEPTED.**

The progress indicator threshold (10+), the no-cancellation rule (atomicity), the ACID recovery on kill, the extra confirmation threshold (50+), and the performance target (5s for N=500) are all concrete and implementable. The SDS should implement this as a single DB transaction with batched writes as specified.

---

### TC-035: Soft-deleted entity reinstatement -- what fields are restored?

**Documents:** PRD SS5.1.1, SS5.2.4

**Issue:** When reinstating a soft-deleted account or category, the specification says the `is_deleted` flag is cleared and balances are "automatically correct." But what about metadata fields that may have been edited before deletion? Is the entity restored to its state at the time of deletion? What if the user wants to reinstate an account but change its name? Can they edit it immediately after reinstatement? Is there any UI for reviewing the reinstated entity's state before confirming?

**Why it matters:** The reinstatement flow needs to define whether the user reviews the entity state, or if it is blindly restored. For accounts with many category-specific fields, the restored state may no longer be accurate.

**PM Response: PUSHBACK.**

The current specification is sufficient for implementation. PRD SS5.1.1 defines reinstatement as clearing the `is_deleted` flag. The restored entity returns to its state at the time of deletion -- all metadata fields are preserved exactly as they were.

1. **"What fields are restored?"** -- All fields. The entity was soft-deleted, not modified. Soft-delete only sets `is_deleted = true` and `deleted_at`. All other fields are untouched in the DB.
2. **"Can they edit it immediately after reinstatement?"** -- Yes. Once reinstated, the entity is a normal active entity. The user can immediately access it via the standard edit flow (account edit form, category edit form). No special "review reinstated entity" screen is needed.
3. **"Is there a UI for reviewing the reinstated entity's state?"** -- No. The reinstatement prompt (SS5.1.1) offers a binary choice: reinstate or choose a different name. If the user reinstates, the entity becomes active and they can inspect/edit it normally. Adding a review step would over-complicate a simple operation.

The reinstated entity's financial data (balance, transactions) is automatically correct because balances are always computed from ledger entries (which are never deleted). The metadata fields are the same as when the entity was deleted. If the user wants to change metadata (e.g., rename the account), they can do so via the normal edit flow after reinstatement.

**LE Verdict: ACCEPTED.**

The PM's pushback is justified. Soft-delete preserves all fields; reinstatement clears `is_deleted`. The entity is immediately editable through normal flows. No special review screen is needed. The ledger-derived balances are automatically correct. This is simple, correct, and complete.

---

### TC-036: Transfer destination account currency validation -- enforcement mechanism

**Documents:** PRD SS7

**Issue:** "The UI must prevent the user from selecting a destination account whose currency differs from the source account during a transfer." But the specification does not define the enforcement mechanism. Is the destination picker filtered to same-currency accounts only? Or are all accounts shown with mismatched ones greyed out? What if the user has only one account in that currency (making a transfer impossible)?

**Why it matters:** The account picker UX for transfers needs a defined filtering strategy. The edge case of "no valid destination" also needs handling (disable transfer type? show empty picker with explanation?).

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises valid UX questions. The product rules:

1. **Enforcement mechanism:** The destination account picker for transfers is **filtered to show only accounts with the same currency as the selected source account**. Mismatched accounts are not shown at all (not greyed out). This is the simplest and cleanest approach.
2. **Source account selection first:** The transfer form requires the source account to be selected before the destination account picker becomes available. Once the source is selected, the destination picker is populated with same-currency active accounts (excluding the source itself).
3. **No valid destination:** If after selecting a source account, no other active account in the same currency exists, the destination picker shows an empty state with explanation: "No other account in [currency] is available. Create another account to make transfers." The Save button is disabled.
4. **Transfer type availability:** The Transfer option in the transaction type selector is **always available** regardless of account count. The validation failure occurs at the destination picker level, not at the type selection level. This avoids confusing users who may not understand why Transfer is greyed out.

This will be added to SS7 and the transfer entry form specification in the next revision.

**LE Verdict: ACCEPTED.**

The filtering strategy (show only same-currency accounts, source-first selection, empty state with explanation, Transfer type always available) is clean and covers the edge cases. The "source first, then filtered destination" flow is a good UX pattern that simplifies the implementation.

---

### TC-037: Onboarding wizard -- account creation form field set

**Documents:** PRD SS5.6.2, input-fields.md SS7

**Issue:** The onboarding wizard step 3 collects "name, account category, initial balance" -- a simplified subset. Input-fields.md SS7 confirms this. But the PRD SS5.1.1 says account currency is required and defaults to home currency. Is currency collected in the onboarding simplified form, or is it silently defaulted to home currency? If defaulted, the user cannot create a foreign-currency account during onboarding.

**Why it matters:** If currency is omitted from the onboarding form, the first account is always in the home currency. This is probably fine but should be explicitly stated. If not, a developer might include the currency field in the onboarding form, adding unnecessary complexity.

**PM Response: CLARIFIED.**

The onboarding form (SS5.6.2 step 3, input-fields.md SS7) intentionally collects only name, account category, and initial balance. Currency is **silently defaulted to the home currency** (which was set in step 2 of the onboarding wizard). The currency field is NOT shown in the simplified onboarding form.

This is by design: the onboarding wizard prioritizes minimal friction. The user can create foreign-currency accounts later through the full account creation form (SS5.1.1), which includes the currency field with the immutability confirmation dialog.

The PRD and input-fields.md SS7 are correct as-is. The implicit rule is: "fields not listed in the onboarding form use their default values." For currency, the default is the home currency (SS5.1.1).

**LE Verdict: ACCEPTED.**

The clarification is sufficient. Currency is silently defaulted to home currency during onboarding. The implicit rule ("fields not listed use defaults") is a sensible convention. No documentation change needed since the spec is already correct.

---

### TC-038: Installment template -- can transfers be installments?

**Documents:** PRD SS5.2.8, SS5.1.2, ledger-entry.md Case 3.2

**Issue:** Ledger-entry.md Case 3.2 says "Installment single post: same as 1.1 or 1.2" -- limiting installments to expense or income types. But the loan installment suggestion (PRD SS5.1.2) pre-fills a destination account (the loan), which implies a transfer. Recurring templates (SS5.2.7) support all three types (income, expense, transfer). If installments are a sub-type of recurring templates, they should inherit transfer support. But Case 3.2 explicitly excludes it.

**Why it matters:** This directly affects whether loan repayment installments (the primary use case for installments) can be implemented. If installments cannot be transfers, the loan repayment feature in SS5.1.2 is architecturally broken.

**PM Response: CLARIFIED -- see TC-022.**

This is the same issue as TC-022. The resolution proposed in TC-022 applies here: installments should support all three transaction types (income, expense, transfer) to enable the loan repayment use case. Ledger-entry.md Case 3.2 has been updated to: "same as 1.1, 1.2, or 1.3 (or 1.3a if fee applies)." ✅ Resolved by founder on 2026-04-14 (see TC-022).

**LE Verdict: ACCEPTED.**

Correctly identified as a duplicate of TC-022. The resolution (installments support all three types, Case 3.2 updated) is the same. ✅ Resolved by founder on 2026-04-14 (see TC-022).

---

### TC-039: What happens to pending (future-dated) transactions when the referenced account is soft-deleted?

**Documents:** PRD SS5.7, SS5.1.1

**Issue:** If a user creates a future-dated transaction for account A, then soft-deletes account A before the transaction's posting date arrives, what happens? The transaction is pending (not yet posted to the ledger). The account is now frozen (no new transactions). Should the pending transaction be: (a) auto-voided? (b) left in limbo? (c) posted anyway despite the deletion? None of this is specified.

**Why it matters:** The scheduler that converts pending transactions to posted must check account validity. Without a defined behaviour, the scheduler could crash or produce invalid ledger entries.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE identifies a valid edge case. The product rule:

1. When the scheduler attempts to post a pending transaction and finds that **any referenced account is soft-deleted**, the pending transaction is **automatically voided** (status set to `voided`, no reversing entry needed since it was never posted to the ledger).
2. A notification is shown to the user at the next app launch: "A pending transaction for [title/amount] on [date] was cancelled because [account name] has been deleted."
3. **Same rule applies to soft-deleted categories:** If the pending transaction references a category that has been soft-deleted, the transaction is still posted (soft-deleted categories remain valid on existing transactions per SS5.2.4). No voiding needed for category deletion.
4. **Compound pending transactions (transfer-with-fee):** If either the source or destination account is soft-deleted, the entire compound group is voided.

This will be added to SS5.7 in the next revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The auto-voiding rule for pending transactions referencing soft-deleted accounts is correct. The SDS author should note: (1) the "next app launch" notification must be persistent (stored in DB, not just in-memory) to survive app restarts. A `pending_notifications` or `launch_alerts` table/queue is needed. (2) The asymmetry between soft-deleted accounts (void the pending transaction) and soft-deleted categories (still post) is correct but should be prominently documented in the scheduler code since it is a non-obvious behavior difference.

---

### TC-040: Category deletion flow -- ordering of template warning vs. transaction migration

**Documents:** PRD SS5.2.4

**Issue:** When deleting a category, both template migration and transaction migration may apply. PRD SS5.2.4 says "This warning fires in addition to the existing transaction-migration prompt -- both flows may be active." But the order is not specified. Does the template warning come first (as implied by "before the category soft-delete proceeds"), followed by the transaction migration prompt? Or vice versa? What if the user migrates templates to category X but then migrates transactions to category Y -- is that valid?

**Why it matters:** The deletion flow is a multi-step wizard. The step ordering affects the UX and the implementation. Inconsistent ordering between account deletion (templates first, then balance transfer) and category deletion (unclear) would confuse users.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the ordering is not explicit. The product-level flow for category deletion, in order:

1. **Step 1 -- Template handling** (if templates reference this category): "Migrate templates" or "Stop templates" prompt. This fires first because it is a blocking prerequisite -- templates with future occurrences must be resolved before the category can be deleted.
2. **Step 2 -- Usage count display** (if N > 0 active transactions reference the category): Informational count shown.
3. **Step 3 -- Transaction migration prompt**: "No migration" / "Migrate all" / "Choose specific" prompt.
4. **Step 4 -- Soft-delete proceeds** after all prompts are resolved.

This mirrors the account deletion flow: templates first, then balance/data handling. The ordering is consistent.

**Cross-migration validity:** Yes, the user can migrate templates to category X and transactions to category Y. These are independent operations. Templates define future behaviour; transactions are historical records. There is no constraint requiring them to use the same replacement category.

This step ordering will be explicitly documented in SS5.2.4 in the next revision.

**LE Verdict: ACCEPTED.**

The step ordering (templates first, then usage count, then transaction migration, then soft-delete) is consistent with the account deletion flow and logical (templates are a blocking prerequisite). The cross-migration validity point (templates to X, transactions to Y) is correct and important for the implementation -- the two migration pickers are independent.

---

### TC-041: Recurring transaction auto-post scheduling mechanism

**Documents:** PRD SS5.2.7, SS5.7

**Issue:** The PRD defines two scheduling needs: (a) recurring templates auto-post on their scheduled date, and (b) future-dated transactions post on their scheduled date. Both rely on some kind of scheduler, but the scheduling mechanism is not specified. Is it Android WorkManager? AlarmManager? A check on app launch only? The PRD says "missed transactions on app launch" are handled, suggesting app-launch-based scheduling, but also references "SCHEDULE_EXACT_ALARM" permissions, suggesting alarm-based scheduling. Are both mechanisms used (alarms for on-time, app-launch for catch-up)?

**Why it matters:** The scheduler architecture is fundamental to recurring transactions and future-dated transactions. The choice between alarm-based and app-launch-based scheduling affects reliability, battery usage, and OS permission requirements.

**PM Response: DEFERRED TO SDS.**

The LE is correct that the scheduling mechanism is not specified. The product requirements are:

1. **On-time posting:** Recurring auto-post and future-dated transactions should post on their scheduled date as close to the scheduled time as possible.
2. **"Remind and confirm" notifications:** Must be delivered at the scheduled time (requires `SCHEDULE_EXACT_ALARM`).
3. **Catch-up on app launch:** All missed transactions (due to device off, force stop, or scheduler failure) are posted on next app launch (SS5.2.7).
4. **Permissions:** `SCHEDULE_EXACT_ALARM` and `POST_NOTIFICATIONS` are already required (SS5.2.7, NF-1).

The scheduling architecture -- whether to use Android WorkManager for background execution, AlarmManager/ExactAlarm for time-critical notifications, or a hybrid approach (alarms for notifications + app-launch sweep for catch-up) -- is an SDS decision. The PRD references `SCHEDULE_EXACT_ALARM` because it is a permission requirement, not a mandate to use AlarmManager specifically. The SDS should evaluate the reliability-battery-permission tradeoffs and document the choice.

**LE Verdict: DEFERRAL ACCEPTED.**

The product requirements (on-time posting, exact-alarm notifications, app-launch catch-up, required permissions) are clear. The scheduling architecture is an SDS decision with significant Android-specific trade-offs (WorkManager vs. AlarmManager vs. hybrid). The clarification that `SCHEDULE_EXACT_ALARM` is a permission requirement, not an architecture mandate, is helpful.

---

### TC-042: Search scope -- home screen vs. unified transaction list

**Documents:** PRD SS5.2.5, SS5.8.4

**Issue:** SS5.8.4 says search and filter on the home screen "operate on the currently displayed (month-filtered) set." SS5.2.5 defines search for "the transaction list" without specifying scope. Is there a separate "unified transaction list" screen beyond the home screen's month-filtered list? If so, does search on that screen operate on all transactions across all months? The PRD mentions both a "unified transaction list" and a "home screen transaction list" but does not clarify whether they are the same surface or different screens.

**Why it matters:** If there are two different transaction list contexts (home = month-filtered, and a separate all-transactions list), the search engine needs to support scoped queries. The navigation model (TC-031) compounds this ambiguity.

**PM Response: CLARIFIED.**

The PRD defines **one transaction list surface** on the home screen, which is always month-filtered (SS5.8.4). There is no separate "all-transactions" screen in v1. The term "unified transaction list" in SS5.2.1 refers to the fact that this list shows transactions across all accounts (as opposed to the per-account transaction list on the account detail screen). It does not imply a separate screen.

In v1, the transaction list contexts are:
1. **Home screen transaction list** -- month-filtered, all accounts. Search and filter operate within the selected month (SS5.8.4).
2. **Account detail transaction list** -- all months, single account. Search and filter operate on all transactions for that account.

Search on the home screen is scoped to the selected month (SS5.8.4 is explicit about this). The user can search across all months by navigating to individual months, or by using the account detail screen (which is not month-filtered). A global all-time search is a v2 feature (combined search + filter, FG-C4). See also TC-050.

**LE Verdict: ACCEPTED.**

The clarification that there is one transaction list surface (home screen, month-filtered) and one per-account list (account detail, all months) is clear. The two search scopes are well-defined. The relationship to TC-050 (whether home search should override the month filter) is correctly identified as a separate founder decision.

---

### TC-043: Template archival -- is it a soft-delete or a distinct state?

**Documents:** PRD SS5.2.7, SS5.5.1

**Issue:** Templates can be "archived" (when end date passes, installments exhausted, or early close). The PRD says "archived templates cannot be reactivated." The contextual menu includes "Delete template" for active/paused templates. But: (a) what does "Delete template" do -- is it a soft-delete (like transactions and accounts)? (b) is "archived" different from "deleted"? (c) can an archived template be deleted? (d) do archived templates appear in Settings > Recurring and Installments?

**Why it matters:** The template lifecycle (active -> paused -> archived, or active -> deleted) needs a clear state machine. Without it, the management screens and contextual menus cannot be implemented correctly.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE correctly identifies that template archival vs. deletion is ambiguous. The product-level state machine:

**Template states:** `active`, `paused`, `archived`, `deleted`.

**Transitions:**
- `active` -> `paused` (user pauses with duration)
- `paused` -> `active` (user unpauses, or pause duration expires)
- `active` -> `archived` (end date reached, installments exhausted, or early close)
- `paused` -> `archived` (end date reached while paused)
- `active` -> `deleted` (user selects "Delete template" from contextual menu)
- `paused` -> `deleted` (user selects "Delete template" from contextual menu)
- `archived` -> (terminal state, cannot transition)
- `deleted` -> (terminal state, cannot transition)

**Distinction between archived and deleted:**
1. **Archived:** The template completed its lifecycle naturally (or via early close). It appears in Settings > Recurring & Installments under an "Archived" section. Its child transactions are fully visible. Cannot be reactivated (SS5.2.7).
2. **Deleted:** The user explicitly chose to remove the template. This is a **soft-delete** (consistent with C8). All future scheduled occurrences are cancelled. Already-posted child transactions are retained. The template is hidden from the management list (same as soft-deleted accounts/categories). It can potentially be reinstated in v2 (though v1 does not offer reinstatement for templates).

**"Delete template" semantics:** Cancel all future occurrences, soft-delete the template entity. Child transactions already posted to the ledger are unaffected.

**Can an archived template be deleted?** No. Archived templates have no future occurrences to cancel, and they serve as historical records. They remain in the "Archived" section. If the user wants to hide them, that is a v2 UX concern (e.g., "hide archived templates" toggle).

This will be added to SS5.2.7 in the next revision.

**LE Verdict: ACCEPTED.**

The four-state template lifecycle (active, paused, archived, deleted) with clearly defined transitions is exactly what the SDS needs. The distinction between archived (natural lifecycle completion, visible in management list) and deleted (user-initiated removal, soft-deleted and hidden) is clean. The rule that archived templates cannot transition further (terminal state) avoids complex reactivation logic. The child transaction independence (deleting a template does not void its children) is correct from a ledger perspective.

---

### TC-044: Currency list -- bundling and maintenance

**Documents:** PRD SS5.1.1, SS5.4.2, NF-11

**Issue:** The app bundles an ISO 4217 currency list (NF-11: "all assets bundled"). But: (a) how many currencies are included (the full ISO 4217 list has 180+ active currencies)? (b) are obsolete currencies excluded? (c) does the list include currency symbols, names, and decimal precision (e.g., JPY has 0 decimals, BHD has 3)? (d) how is decimal precision used in amount validation and display? The PRD assumes "Decimal > 0" for amounts but does not address per-currency precision.

**Why it matters:** Currency precision directly affects the amount input field (how many decimal places to allow/display), the ledger (storage precision), and the display formatting. JPY amounts should not show decimal places; BHD amounts need 3. Without per-currency precision rules, the app may display or accept incorrect values.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid and important point. The product rules:

1. **Currency list scope:** The app bundles the **full active ISO 4217 currency list** (currently ~180 currencies). Obsolete currencies are excluded. The list includes currency code, name, symbol, and **decimal precision** (minor units).
2. **Per-currency decimal precision:** Each currency in the bundled list carries its ISO 4217 minor unit count: 0 (JPY, KRW), 2 (USD, EUR, INR -- most currencies), or 3 (BHD, KWD, OMR). This precision is used for:
   - **Amount input field:** The decimal input keyboard restricts input to the currency's precision. For JPY, no decimal point is accepted. For BHD, up to 3 decimal places.
   - **Amount display:** Balances and transaction amounts are formatted to the currency's precision. JPY: "500". USD: "500.00". BHD: "500.000".
   - **Ledger storage:** Amounts are stored with sufficient precision to accommodate all currencies (minimum 3 decimal places internally, or as integers in minor units -- this is an SDS decision).
3. **Exchange rate precision:** Exchange rates are stored with higher precision (6-8 decimal places) regardless of currency precision. Only the final displayed amount is rounded to the display currency's precision.
4. **The bundled currency data file** should be a static JSON/CSV asset derived from the ISO 4217 standard. The SDS should define the exact format and bundling.

This will be added to SS5.4.2 and SS5.1.1 in the next revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The per-currency decimal precision model is critical and well-specified. The SDS author should note: (1) the decision between storing amounts as integers in minor units (e.g., 50000 for $500.00) vs. as fixed-precision decimals (e.g., Decimal with 3 places) is a consequential SDS schema decision. Integer-in-minor-units avoids floating-point errors entirely and is the industry standard for financial systems -- the SDS should strongly prefer this approach. (2) The exchange rate precision (6-8 decimal places) must be consistently applied across all computation paths (storage, display, category balance aggregation per TC-046). (3) The static currency data file should be versioned and updatable via app updates (e.g., if a currency is retired or a new one is introduced by the ISO).

---

### TC-045: EQ (Opening Balance equity account) -- balance and auditability

**Documents:** PRD SS4.9, ledger-entry.md Cases 2.2, 2.4

**Issue:** EQ is used for opening balances (Cases 2.2a/2.2b) and invisible journal adjustments (Cases 2.4a/2.4b). It is "never visible to the user under any circumstances." But EQ accumulates a running balance from all these operations. In v2, the audit view should presumably show EQ's balance for integrity verification. The PRD does not specify: (a) whether EQ's balance is tracked, (b) whether any automated integrity check validates that EQ's balance equals the expected sum of all opening balance + invisible adjustment postings, (c) whether multiple EQ accounts exist (one global, or one per currency?).

**Why it matters:** If accounts are multi-currency but EQ is a single account, EQ would accumulate entries in multiple currencies, breaking the balance formula (which is single-currency). Either EQ needs to be per-currency, or EQ's balance must be tracked per-currency. This has schema implications.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a critical multi-currency consistency point. The resolution:

1. **EQ must be per-currency.** When an account with currency X is created with a non-zero initial balance, the system uses (or creates) an EQ account for currency X. Each EQ account accumulates entries only in its own currency.
2. **EQ account naming:** `EQ_USD`, `EQ_INR`, `EQ_EUR`, etc. (or a single EQ entity with a currency field -- SDS design choice).
3. **Lazy creation:** EQ accounts are created on demand. When the first account in currency X is created with a non-zero initial balance, `EQ_X` is created. If no account in currency Y ever has an initial balance, `EQ_Y` is never created.
4. **All EQ accounts are invisible** (SS4.9). They are never surfaced to the user and are excluded from net worth.
5. **Balance tracking:** Each EQ account's balance is internally tracked (for integrity verification) but never displayed. In v2, the audit view may surface EQ balances for integrity verification.

The same per-currency principle applies to invisible journal adjustments (Cases 2.4a/2.4b) -- the EQ account used for the adjustment must match the currency of the account being adjusted.

This will be added to SS4.9 in the next revision.

**LE Verdict: ACCEPTED.**

The per-currency EQ model is the correct resolution. A single EQ account with multi-currency entries would break the balance formula. Lazy creation (on-demand when the first non-zero initial balance in that currency appears) avoids unnecessary EQ proliferation. The invisible + excluded-from-net-worth rules carry forward from the original SS4.9 spec. The SDS should implement EQ creation as an atomic part of the account creation transaction.

---

### TC-046: BAI and BAE (Balance Adjustment categories) -- per-currency or global?

**Documents:** PRD SS5.2.4, SS4.10, ledger-entry.md Cases 2.3

**Issue:** Similar to TC-045. Balance Adjustment income (BAI) and expense (BAE) categories accumulate entries from journal adjustments across potentially multiple currencies. Category balances use a single formula (Cr - Dr for income, Dr - Cr for expense). If a BAI entry is posted for a USD account and another for an INR account, the BAI balance would be a nonsensical sum of USD and INR amounts. Are category balances computed per-currency? Or is there one BAI/BAE per currency?

**Why it matters:** Category balances are used for reporting (e.g., home screen income/expense summary). If categories can accumulate multi-currency entries without conversion, the balances are meaningless. The SDS needs a clear currency model for categories.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises the same multi-currency consistency issue for categories that TC-045 raised for EQ. The resolution:

1. **Categories are currency-agnostic containers.** Unlike accounts, categories do not have a currency. A "Food" expense category can receive entries from a USD account and an INR account.
2. **Category balances are meaningful only in the home currency.** When computing a category's balance for display (e.g., the home screen monthly expense summary), entries in foreign currencies are converted to the home currency using the transaction's stored `exchange_rate_to_home` (SS7.1).
3. **BAI and BAE are not special in this regard.** They follow the same rule as all categories: balances are computed in home currency via exchange rate conversion.
4. **Home screen income/expense summary (SS5.8.2)** already implicitly requires home-currency aggregation (it shows a single total for income and expenses). All transaction amounts are converted to the home currency using their stored exchange rate for aggregation.
5. **Per-currency category breakdowns** are not a v1 feature. If needed, this would be part of the v2 analytics/trends feature.

The formula for a category's home-currency balance is: `Σ (entry_amount * exchange_rate_to_home)` for all entries in that category, respecting the debit/credit side per SS4.6.

This will be clarified in SS4.6 and SS5.8.2 in the next revision.

**LE Verdict: ACCEPTED WITH NOTE.**

The resolution that categories are currency-agnostic with balances computed in home currency via exchange rate conversion is correct and the only viable approach for multi-currency. The SDS author should note two important implications: (1) The home-currency category balance formula `Σ (entry_amount * exchange_rate_to_home)` requires that every transaction has a non-null `exchange_rate_to_home` -- even for transactions in the home currency (where the rate is 1.0). The transaction creation logic must ensure this field is always populated. (2) If the home currency changes (TC-029), all category balance computations are affected because the stored rates reference the old home currency. The `home_currency_at_capture` field from TC-029 becomes essential for correct category balance computation after a home currency change. The SDS should define whether category balances are recomputed on-the-fly or cached with invalidation.

---

### TC-047: Per-account and per-category large transaction thresholds -- currency handling

**Documents:** PRD SS5.4.4

**Issue:** Large transaction warning thresholds are "per-account" and "per-category." Per-account thresholds are straightforward (each account has one currency). But per-category thresholds span multiple accounts potentially in different currencies. If I set a "Food" category threshold of 500, is that 500 in the home currency? 500 in whatever currency the transaction uses? What if I have a USD and an INR account and set a Food threshold -- does a 500 INR food expense trigger the same threshold as a 500 USD one?

**Why it matters:** The threshold comparison logic needs to know whether to compare amounts in the transaction's native currency or after conversion to the home currency. This affects the warning trigger logic.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid ambiguity. The product rules:

1. **Per-account thresholds:** Compared against the transaction amount in the **account's native currency**. Since each account has one currency, this is unambiguous. A threshold of 500 on a USD account triggers when a USD transaction exceeds 500.
2. **Per-category thresholds:** Compared against the transaction amount in the **home currency**. Since categories span multiple currencies, the threshold must be in a consistent unit. The threshold value is implicitly in the home currency. When a transaction is entered against a foreign-currency account, the amount is converted to the home currency using the current cached exchange rate (same rate shown in the exchange rate estimate, SS7.1) and compared against the category threshold.
3. **Per-category threshold display:** In Settings > Warnings & Limits > Per-Category Limits, the threshold amount is shown with the home currency symbol to make the unit clear.
4. **If no exchange rate is available** (no cached rate for the foreign currency), the per-category threshold check is **skipped** for that transaction. The per-account threshold check still applies.

This will be added to SS5.4.4 in the next revision.

**LE Verdict: ACCEPTED.**

The currency handling rules for thresholds (per-account in native currency, per-category in home currency with exchange rate conversion, skip if no rate available) are clear and implementable. The UI display of home currency symbol on per-category thresholds is important for user understanding.

---

### TC-048: Minimum API level inconsistency with dynamic color

**Documents:** PRD NF-9, SS5.4.1

**Issue:** NF-9 says "Minimum API 31 (Android 12)." SS5.4.1 says "Dynamic color requires API 31+. On lower API levels, falls back to custom seed color." If the minimum is API 31, there are no "lower API levels" in the supported range -- every user has dynamic color available. The fallback language suggests the minimum might have been lower at one point, or the fallback is for devices that have API 31 but have disabled dynamic color via OEM customization.

**Why it matters:** This is minor but could confuse a developer into implementing API-level checks that are unnecessary given the stated minimum. If the minimum is truly 31, the fallback to custom seed color is only for user preference (choosing not to use dynamic color), not for API compatibility.

**PM Response: CLARIFIED.**

The LE's analysis is correct. Since the minimum API is 31 (NF-9), all users have dynamic color available at the OS level. The "fallback to custom seed color" in SS5.4.1 is for **user preference**, not API compatibility. Specifically:

1. The user can **choose** between "Material You dynamic color (from wallpaper)" and "Custom seed color" in Settings > Appearance (SS5.4.1). This is a user choice, not a fallback.
2. Additionally, some OEM Android skins on API 31+ may not fully support `DynamicColorTheme`. In those rare cases, the app falls back to custom seed color. This is a defensive engineering measure, not a primary use case.

The language "On lower API levels, falls back to custom seed color" in SS5.4.1 is misleading given the API 31 minimum. It will be reworded to: "Users may choose dynamic color (from wallpaper) or a custom seed color. If dynamic color is unavailable on the device (e.g., OEM restriction), custom seed color is used automatically." No API-level check is needed.

**LE Verdict: ACCEPTED.**

The reworded text is accurate. With API 31 as the minimum, the only fallback scenario is OEM restrictions on dynamic color, not API level. The implementation can use a runtime check for `DynamicColorTheme` availability without an API-level guard.

---

### TC-049: Pending Confirmations -- dismiss action semantics

**Documents:** PRD SS5.8.5

**Issue:** The Pending Confirmations alert for recurring templates supports "Dismiss (skips this occurrence)." But SS5.2.7 says "if the user does not respond within 24 hours of the scheduled time, the transaction is auto-approved and posted." Does "Dismiss" permanently skip the occurrence (it is never posted), or does "Dismiss" just dismiss the alert and the 24-hour auto-post still applies? If Dismiss permanently skips, this is the only way in v1 to skip a single occurrence of a recurring series.

**Why it matters:** "Dismiss" having permanent skip semantics is a significant user action with financial impact (an expected transaction is never recorded). If it merely dismisses the notification while auto-post proceeds, it is low-impact. The two interpretations produce completely different implementations and user expectations.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE correctly identifies the ambiguity. The product intent:

1. **"Dismiss" permanently skips the occurrence.** The transaction is NOT posted. The occurrence is marked as "manually handled" on the template schedule (same mechanism as editing/deleting a child transaction, per SS5.2.7 Q47 resolution). The 24-hour auto-post timer is cancelled for this occurrence.
2. **This is intentional.** "Dismiss" is the v1 mechanism for skipping a single occurrence. The user explicitly chose not to record this occurrence. Examples: "I didn't actually make this payment this month" or "I'll handle this one differently."
3. **The 24-hour auto-post (SS5.2.7)** applies only when the user **does not interact** with the confirmation at all (no Confirm, no Edit, no Dismiss). If the user takes any action, the auto-post timer is irrelevant.
4. **Confirmation dialog on Dismiss:** Because this is a significant action, Dismiss shows a brief confirmation: "Skip this occurrence? It will not be posted." with Confirm/Cancel options. This prevents accidental dismissals.

This will be clarified in SS5.8.5 and SS5.2.7 in the next revision.

**LE Verdict: ACCEPTED.**

"Dismiss" as permanent skip with a confirmation dialog is the correct product decision. The three-way interaction (Confirm = post, Edit = modify and post, Dismiss = skip) gives the user clear control. The 24-hour auto-post applying only when the user does not interact at all is an important clarification. The confirmation dialog on Dismiss prevents accidental skips.

---

### TC-050: Search interaction with month filter on home screen

**Documents:** PRD SS5.8.4, SS5.2.5

**Issue:** SS5.8.4 says search on the home screen operates on the "currently displayed (month-filtered) set." But SS5.2.5 defines search fields including "date." If the user searches while viewing March 2026, can they search for a transaction date in February? The month filter already constrains the visible set, so searching by date within a month-filtered view seems redundant or conflicting. More broadly: is there ever a way for the user to search across ALL transactions (all months)?

**Why it matters:** Users may expect search to be global. If it is always scoped to the selected month, they must manually navigate to each month to find a transaction they cannot remember the date of. This is a significant UX limitation that may need explicit product confirmation.

**PM Response: ACKNOWLEDGED -- Escalate to founder.**

The LE raises a legitimate UX concern. The current spec (SS5.8.4) explicitly scopes home screen search to the selected month. The implications:

1. **Searching by date within a month-filtered view:** Redundant, as the LE notes. The date search field would only match dates within the already-selected month.
2. **Finding a transaction when you do not remember the month:** The user must either (a) navigate month by month and search in each, or (b) go to a specific account's detail screen (which is not month-filtered per TC-042) and search there.
3. **The account detail screen provides an escape hatch:** Since the per-account transaction list is NOT month-filtered, searching there covers all time for that account. This partially mitigates the limitation.

The options for the founder:

**Option A -- Keep current spec.** Home screen search is month-scoped. The account detail screen provides all-time search per account. Global all-time cross-account search is a v2 feature (FG-C4).

**Option B -- Home screen search ignores the month filter.** When search is active, the month filter is temporarily suspended and search runs across all transactions. When search is cleared, the month filter re-engages. This is more useful but increases query scope and may have performance implications.

**PM recommendation:** Option B is significantly better UX. The v1 search should override the month filter when active. The performance impact is manageable within NF-3 targets (500ms for 10,000 records). Escalating to founder for the decision.

**LE Verdict: ESCALATION CONFIRMED.**

The escalation is warranted. From an engineering perspective, Option B (search overrides month filter) is straightforward to implement -- the search query simply omits the month predicate when search is active. The performance impact is minimal within NF-3 targets. Option A (month-scoped search) is a significant UX limitation that would generate user friction. The PM's recommendation for Option B is correct. The account detail screen provides all-time per-account search as a partial mitigation if Option A is chosen, but Option B is clearly superior.

**Founder Resolution (2026-04-14): RESOLVED — global search (neither Option A nor B as framed).**

The founder corrects the framing: search was never intended to be month-scoped. Transaction search is a **global search across all transactions to date**. The user taps the search action and performs a fuzzy search across the entire transaction history. Engineering owns the performance/efficiency strategy. The SS5.8.4 text stating search operates on "currently displayed (month-filtered) set" is **incorrect** and must be corrected.

**v2 scope note:** Navigation search (search bar that navigates to screens/features within the app) and Settings screen search are deferred to v2.

---

### TC-051: Soft-delete of the last active category in a tree

**Documents:** PRD SS5.2.4

**Issue:** The specification defines soft-delete rules for categories but does not address the edge case where the user tries to soft-delete the last remaining active category in a tree (e.g., the last expense parent category). If all expense categories are deleted, the user cannot create any new expense transactions (since category is required). Is this allowed? Is there a minimum category constraint analogous to the minimum account constraint ("cannot delete your only account")?

**Why it matters:** Without a guard, a user could soft-delete all categories and be unable to record transactions, requiring them to create a new category before they can do anything. This may be acceptable (they can always create a new one), but it should be an explicit product decision.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid edge case. The product rule:

1. **No minimum category constraint.** The user is allowed to soft-delete all categories in a tree (all expense categories or all income categories).
2. **If all categories in a tree are deleted:** The transaction entry form for that type (income or expense) will have an empty category picker. The Save button is disabled with a message: "No categories available. Create a category in Settings to record [income/expense] transactions."
3. **This is acceptable** because: (a) the user can always create a new category from Settings > Categories, (b) transfers (which have no category) remain fully functional, and (c) the protected "Balance Adjustment" categories are undeletable and will always exist -- but they are not user-selectable, so they do not count as "available categories" for this purpose.
4. **Rationale for not adding a guard:** Unlike accounts (where a minimum of one is required for basic functionality), categories can be created instantly with minimal effort (icon + name). Forcing a minimum category would prevent users from fully customizing their taxonomy.

This is an explicit product decision and does not need PRD text changes -- the absence of a minimum category constraint is intentional.

**LE Verdict: ACCEPTED.**

No minimum category constraint is acceptable. The mitigation (disabled Save button with explanatory message, categories are trivially created, transfers remain functional, protected Balance Adjustment categories are always present but not user-selectable) is sufficient. The explicit confirmation that this is intentional eliminates ambiguity for the implementation.

---

### TC-052: Recurring transfer templates with fees

**Documents:** PRD SS5.2.7, SS5.1.5b, ledger-entry.md Case 3.1

**Issue:** Ledger-entry.md Case 3.1 says recurring auto-post produces entries "same as 1.1-1.3 (or 1.3a if fee applies)." The parenthetical "if fee applies" suggests recurring transfer templates can include fees. But the input-fields.md SS4.1 for template creation does not include fee fields, and the PRD's template field list (SS5.2.7) does not mention fees. Can a recurring transfer template include a fee? If so, where are the fee fields defined for templates?

**Why it matters:** If a user sets up a monthly transfer with a consistent bank fee, they would expect the fee to be part of the template. If fees are not supported on templates, every auto-posted transfer would lack the fee, requiring manual editing of each occurrence.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that fee fields are not explicitly included in the template creation fields. The product resolution:

1. **Recurring transfer templates CAN include a fee.** This is implied by ledger-entry.md Case 3.1 ("or 1.3a if fee applies") but the template creation form in input-fields.md SS4.1 does not list fee fields.
2. **Template fee fields** (to be added to input-fields.md SS4.1 for transfer-type templates): Fee mode (Flat/Percentage/None), Fee amount or percentage, Fee category (default: Financial > Fees & Charges). Same fields as the transfer fee panel (input-fields.md SS1.3).
3. **Editability:** Fee fields on templates are **IP** (in-place editable, future occurrences only), consistent with other template fields like amount and account.
4. **Auto-posted transfers with fees** produce compound transactions (Case 1.3a) exactly as they would for manually created transfers with fees.

This will be added to input-fields.md SS4.1 in the next revision.

**LE Verdict: ACCEPTED.**

Recurring transfer templates supporting fees is logically correct and consistent with ledger-entry.md Case 3.1. The fee fields (mode, amount/percentage, category) reuse the same definition from SS1.3 with the same IP editability as other template fields. The auto-posted compound transaction generation follows Case 1.3a. The input-fields.md update to SS4.1 should explicitly list these fields.

---

### TC-053: Credit card payment due amount -- outstanding vs. statement balance

**Documents:** PRD SS5.1.7

**Issue:** The notification content references "Amount due: [statement balance]" consistently. But the credit card has two balance figures: outstanding balance and statement balance. In practice, the "amount due" on a credit card is the statement balance (the bill for the current cycle), not the total outstanding. However, the payment entry form pre-fills "Amount: Statement balance." What if the statement balance is zero but the outstanding balance is not (e.g., new charges after the billing date)? Does the payment still trigger?

**Why it matters:** The notification trigger condition is "billing date and payment due date are configured" but does not include a condition on the statement balance being non-zero. The user would receive a "payment due" notification with amount 0, which is confusing.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid UX concern. The product rules:

1. **Notification suppression:** Payment reminder notifications (SS5.1.7) are **suppressed when the statement balance is zero** (no amount due for the current billing cycle). The notification schedule still runs internally, but no notification is delivered to the user.
2. **Outstanding balance is not relevant for payment reminders.** The "amount due" in the notification is always the statement balance (the billed amount for the cycle). New charges after the billing date are part of the next cycle and are not yet "due."
3. **The Pay FAB on the credit card detail screen** remains always visible (it is a convenience shortcut, not a notification). If the user taps it with a zero statement balance, the payment form opens with amount pre-filled as 0. The user can enter any amount they wish to pay (e.g., paying ahead).
4. **The home screen alert card** for credit card payment is also suppressed when the statement balance is zero.

This will be added to SS5.1.7 as a notification suppression rule in the next revision.

**LE Verdict: ACCEPTED.**

The notification suppression when statement balance is zero is correct and prevents confusing "amount due: 0" notifications. The distinction between outstanding balance (not relevant for reminders) and statement balance (the trigger) is clear. The Pay FAB remaining always visible (with amount pre-filled as 0) handles the "pay ahead" edge case gracefully.

---

### TC-054: Data backup format -- versioning and forward compatibility

**Documents:** PRD SS5.4.10

**Issue:** The backup exports "all data as a zip archive." The exact format is deferred to SDS, but there is no product-level requirement for backup versioning. When v2 adds import/restore, the restore function must be able to read v1 backups. If the v1 backup format does not include a version identifier, the v2 importer cannot detect the format version.

**Why it matters:** Including a version identifier in the backup format is a v1 decision (it must be present in the v1 export), even though import is v2. This is a forward-compatibility requirement that the SDS must address now.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is absolutely correct. This is a forward-compatibility requirement that must be addressed in v1. The product requirement:

1. **The backup zip MUST include a version manifest file** (e.g., `manifest.json` or `backup_meta.json`) at the root of the archive containing at minimum:
   - `backup_format_version`: integer (starting at 1 for v1).
   - `app_version`: the semantic version of the app that created the backup.
   - `created_at`: UTC timestamp of the backup.
   - `schema_version`: the database schema version at the time of backup.
2. **The v2 import/restore feature** will read this manifest to determine the backup format and apply any necessary migrations.
3. **No backward compatibility is required in v1** (there is no import). But the manifest ensures forward compatibility.

The exact manifest schema is an SDS decision, but the **requirement to include a version identifier** is a product-level decision made now. This will be added to SS5.4.10 in the next revision.

**LE Verdict: ACCEPTED.**

This is an excellent forward-compatibility decision. The manifest fields (`backup_format_version`, `app_version`, `created_at`, `schema_version`) are the minimum viable set for v2 import to detect and handle v1 backups. The SDS will define the exact manifest schema and file format.

---

### TC-055: Installment early close -- "final payment" transaction type

**Documents:** PRD SS5.2.8

**Issue:** When the user records a "final lump-sum payment" during installment early close, a "new transaction is posted and linked to the installment series (same as a regular installment child transaction)." But the transaction type (income/expense/transfer) is not specified for this final payment. Is it the same type as the template? What if the template is a transfer-type installment (per TC-038)? What are the fields collected for this final payment -- full transaction form or just amount?

**Why it matters:** The final payment creation needs a defined field set and transaction type. Without it, the UX flow and posting logic cannot be implemented.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE is correct that the final payment details are underspecified. The product rules:

1. **Transaction type:** The final payment uses the **same transaction type as the installment template**. If the template is an expense installment, the final payment is an expense. If it is a transfer installment (per TC-022/TC-038 resolution), the final payment is a transfer. Same accounts, same category.
2. **Field set:** The final payment opens the **standard transaction entry form pre-filled** with the template's configuration (accounts, category, title, description) and the user-entered final payment amount. The user can modify any field before saving, just like editing a regular transaction.
3. **Posting:** The final payment is posted as a child transaction linked to the installment series (`parent_template_id` set). It follows the same ledger cases as any other installment posting (Case 3.2 in ledger-entry.md, or Case 1.3/1.3a for transfer installments per the TC-022 resolution).
4. **After posting:** The template updates its `running_total` and then proceeds to the mismatch check (SS5.2.8 step 4).

This will be clarified in SS5.2.8 (early close flow, step 2) in the next revision.

**LE Verdict: ACCEPTED.**

The final payment specification is complete: same transaction type as the template, standard entry form pre-filled with template configuration, user-editable before save, posted as a child transaction linked to the series, followed by the mismatch check. This covers all the cases (expense, income, and transfer installments — TC-022 resolved by founder on 2026-04-14).

---

### TC-056: Recurring template deletion vs. archival -- child transaction handling

**Documents:** PRD SS5.2.7, SS5.5.1

**Issue:** The contextual menu for recurring templates includes "Delete template." The PRD extensively covers archival (end date reached, installments exhausted, early close) but does not define what "Delete template" does to: (a) future scheduled occurrences (cancelled?), (b) already-posted child transactions (retained?), (c) the template's state (soft-deleted? archived?). Is deleting a template the same as archiving it, or is it a distinct operation?

**Why it matters:** The delete operation's semantics must be clearly defined. If deletion cancels future occurrences but retains history, it is functionally equivalent to archival. If it also hides the template from the management list, it is a soft-delete of the template entity. The implementation differs significantly.

**PM Response: CLARIFIED -- see TC-043.**

This is the same question addressed in TC-043. The full template lifecycle (including the distinction between archived and deleted) is defined there:

- **"Delete template"** = cancel all future scheduled occurrences + soft-delete the template entity. Already-posted child transactions are retained and fully visible.
- **Archived** = template completed its lifecycle naturally. Remains visible in the management list under "Archived."
- **Deleted** = template removed by user. Hidden from the management list (soft-deleted).

Child transaction handling: (a) future scheduled occurrences are cancelled (not posted), (b) already-posted child transactions are retained unaffected -- they are independent ledger entries that happen to have a `parent_template_id`. Deleting the template does not void its children.

**LE Verdict: ACCEPTED.**

Correctly resolved by reference to TC-043. The delete semantics (cancel future occurrences, soft-delete template, retain children) are clear and consistent with the template lifecycle state machine.

---

### TC-057: Multiple accounts per account category -- display and disambiguation

**Documents:** PRD SS5.1.2

**Issue:** The user can create multiple accounts of the same category (e.g., two Bank Accounts, three Credit Cards). The PRD does not specify how these are distinguished in the account picker during transaction entry. Account names are unique, but when the picker shows a list, is the account category also displayed alongside the name? How are accounts sorted in the picker -- alphabetically by name, grouped by category, or by creation date?

**Why it matters:** The account picker UX (for transaction entry, transfer source/destination, template creation, etc.) is used constantly and needs a defined sort and display model. Without it, users with many accounts will struggle to find the right one.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid UX question. The product rules for the account picker:

1. **Display:** Each account row shows: **account name** (primary text) and **account category** (secondary text/badge, e.g., "Bank Account", "Credit Card"). Currency symbol is shown if the user has accounts in multiple currencies.
2. **Sort order:** Accounts are **grouped by account category** (in the fixed order: Cash, Bank Account, Credit Card, Debit Card, Top-Up Wallet, Loan, Investment, Other) and **sorted alphabetically by name within each group**.
3. **Account category headers:** Each group has a visible section header (e.g., "Bank Accounts", "Credit Cards") if there are multiple groups. If all accounts are the same category, no header is shown.
4. **This applies to all account pickers** (transaction entry, transfer source/destination, template creation, account deletion balance transfer, etc.).
5. **v2 enhancement:** Manual reordering (already noted as deferred to v2) will allow the user to override this default sort.

This will be added to the account picker specification in the next revision (either SS5.2.1 or as a shared UI component definition).

**LE Verdict: ACCEPTED.**

The account picker specification (name + category badge, grouped by category in fixed order, alphabetical within group, section headers, currency symbol when multi-currency, applies to all pickers) is complete and implementable. This should be defined as a shared UI component in the UX Flows document since it is reused across many screens.

---

### TC-058: "Is recurring" filter criterion -- scope and semantics

**Documents:** PRD SS5.2.6

**Issue:** The filter includes an "Is recurring" boolean criterion. But the semantics are undefined. Does "Is recurring = true" filter for: (a) transactions that were generated by any recurring or installment template? (b) only transactions from recurring templates (excluding installments)? (c) transactions that are linked to a currently active template, or also to archived ones? If a child transaction was "manually handled" (edited/deleted), does it still count as "recurring"?

**Why it matters:** The filter needs a concrete definition to query the database correctly. The template-child transaction linkage model (TC-003, TC-026) directly affects how this filter is implemented.

**PM Response: ACKNOWLEDGED -- PM can resolve.**

The LE raises a valid definition question. The product-level semantics:

1. **"Is recurring = true"** matches any transaction that has a non-null `parent_template_id`. This includes transactions generated by both recurring templates AND installment templates. It includes transactions from active, paused, archived, and deleted templates. It includes manually handled (edited/deleted) child transactions.
2. **"Is recurring = false"** matches transactions with a null `parent_template_id` (manually created transactions, system-generated transactions like balance transfers and opening balance postings, and journal adjustment transactions).
3. **Rationale:** The filter's purpose is to help the user distinguish "transactions I set up to happen automatically" from "transactions I entered manually." All template-generated transactions, regardless of template type or current template state, fall into the first bucket.
4. **Naming:** "Is recurring" is the user-facing label. Internally it filters on `parent_template_id IS NOT NULL`. A more precise internal name would be "Is template-generated."

This will be clarified in SS5.2.6 in the next revision.

**LE Verdict: ACCEPTED.**

The "Is recurring" semantics (any transaction with non-null `parent_template_id`, regardless of template type or state) are clear and correct. The inclusive definition (covers both recurring and installment templates, all template states, including manually handled children) matches the user's mental model. The internal name suggestion ("Is template-generated") is a useful implementation note.

---

---

## Summary

| Category | Count |
|----------|-------|
| **A -- Vague Specifications** | 16 items (TC-001 through TC-016) |
| **B -- Inconsistent Specifications** | 7 items (TC-017 through TC-023) |
| **C -- Missing Specifications** | 35 items (TC-024 through TC-058) |
| **Total** | 58 items |

### Priority Assessment

**Blocking for SDS / data model design (must resolve before SDS):**
TC-001, TC-002, TC-003, TC-005, TC-010, TC-011, TC-022, TC-024, TC-025, TC-026, TC-027, TC-028, TC-038, TC-043, TC-045, TC-046

**Blocking for UX flows design:**
TC-004, TC-008, TC-012, TC-023, TC-031, TC-032, TC-034, TC-040, TC-042, TC-049, TC-050, TC-057

**Blocking for implementation (can be resolved during SDS but before coding):**
TC-006, TC-009, TC-014, TC-029, TC-030, TC-033, TC-036, TC-037, TC-039, TC-041, TC-044, TC-047, TC-052, TC-053, TC-055, TC-056, TC-058

**Should be fixed now (documentation inconsistencies):**
TC-017, TC-018, TC-019, TC-020, TC-021

**Low priority (minor or cosmetic):**
TC-007, TC-013, TC-015, TC-016, TC-035, TC-048, TC-051, TC-054

---

## PM Response Summary

| Response Category | Count | Items |
|---|---|---|
| **CLARIFIED** | 7 | TC-013, TC-015, TC-037, TC-038, TC-042, TC-048, TC-056 |
| **ACKNOWLEDGED -- PM can resolve** | 40 | TC-001, TC-002, TC-004, TC-005, TC-007, TC-008, TC-010, TC-011, TC-012, TC-016, TC-017, TC-018, TC-019, TC-020, TC-021, TC-023, TC-024, TC-025, TC-026, TC-027, TC-028, TC-030, TC-032, TC-034, TC-036, TC-039, TC-040, TC-043, TC-044, TC-045, TC-046, TC-047, TC-049, TC-051, TC-052, TC-053, TC-054, TC-055, TC-057, TC-058 |
| **ACKNOWLEDGED -- Escalate to founder** | 5 | TC-014, TC-022, TC-029, TC-031, TC-050 — **all 5 resolved by founder (2026-04-14)** |
| **DEFERRED TO SDS** | 5 | TC-003, TC-006, TC-009, TC-033, TC-041 |
| **PUSHBACK** | 1 | TC-035 |
| **Total** | 58 | |

> *Note: TC-038 is resolved by reference to TC-022. TC-056 is resolved by reference to TC-043. TC-008 has a sub-item (pending transaction deletion semantics) noted as needing founder confirmation but the overall item is PM-resolvable. Some items in ACKNOWLEDGED -- PM can resolve have sub-items that touch on founder decisions noted inline but are not classified as full escalations because the PM proposed a concrete resolution.*

### Items requiring founder decisions (5 items) — ✅ ALL RESOLVED (2026-04-14)

| TC | Decision needed | Founder Decision |
|---|---|---|
| TC-014 | Icon subset count for category picker | ✅ Option A (~200-300 icons). Curation is a separate task. |
| TC-022 | Should installments support transfer transaction type? | ✅ Yes — all three types (income, expense, transfer). |
| TC-029 | What happens to stored exchange rates when home currency changes? | ✅ Home currency change only affects default for new account creation. Exchange rate storage is LE-owned (SDS decision). |
| TC-031 | App navigation model? | ✅ Bottom navigation bar. LE owns this decision going forward. |
| TC-050 | Search scope on home screen? | ✅ Global search across all transactions. Not month-scoped. Navigation/settings search deferred to v2. |

### Items requiring PRD text updates (documentation fixes)

The following items identified text that needs correction or addition in the product documents. These will be batched into the next PRD revision:

- **SS4.3**: Add note that this defines the ledger model, not the full entity schema (TC-019)
- **SS4.8**: Add date/time to in-place edit list (TC-018)
- **SS4.9**: Specify EQ is per-currency (TC-045)
- **SS4.6 / SS5.8.2**: Clarify category balances are computed in home currency (TC-046)
- **SS5.1.1 / ledger-entry.md Case 2.5a**: Clarify "not editable" vs. "deletable with warning" (TC-020)
- **SS5.1.6**: Add billing period boundary semantics (TC-004)
- **SS5.1.7**: Add notification suppression when statement balance is zero (TC-053)
- **SS5.2.4**: Add step ordering for category deletion flow (TC-040); add batch migration UX rules (TC-034)
- **SS5.2.5**: Correct "deferred to UX Flows" to "deferred to SDS" for search ranking (TC-009)
- **SS5.2.6**: Add type/category filter interaction rules (TC-023); clarify "Is recurring" semantics (TC-058)
- **SS5.2.7**: Add template state machine (TC-043); add missed occurrence handling rules (TC-030); clarify Dismiss semantics (TC-049)
- **SS5.2.8**: Clarify installment end date is computed (TC-010); clarify installment materialization (TC-011); clarify total_configured immutability exception (TC-021); clarify final payment type and fields (TC-055)
- **SS5.4.1**: Reword dynamic color fallback language (TC-048)
- **SS5.4.3**: Add draft lifecycle specification (TC-005)
- **SS5.4.4**: Add currency handling for per-category thresholds (TC-047)
- **SS5.4.10**: Add backup version manifest requirement (TC-054)
- **SS5.7**: Add pending transaction visibility and interaction rules (TC-008); add behaviour when referenced account is deleted (TC-039)
- **SS7**: Add transfer destination currency filtering rules (TC-036)
- **input-fields.md SS2.2**: Remove "triggers notification reschedule" from linked bank account (TC-013)
- **input-fields.md SS2.6**: Remove "or compatible" -- replace with "same account category AND same currency" (TC-012)
- **input-fields.md SS4.1**: Add fee fields for transfer-type templates (TC-052)
- **New subsection**: Account detail screen specification (TC-032)
- **New subsection**: Consolidated entity definitions for Transaction, Entry, Account, Category, Template (TC-024 through TC-028)
- **Memory file**: Update `project_variance_deb_model.md` to match resolved Q41 (TC-017)

---

## LE Review Summary

### Verdict Distribution

| LE Verdict | Count | Items |
|---|---|---|
| **ACCEPTED** | 38 | TC-001, TC-004, TC-007, TC-010, TC-011, TC-012, TC-013, TC-015, TC-016, TC-017, TC-018, TC-019, TC-020, TC-023, TC-025, TC-027, TC-030, TC-032, TC-034, TC-035, TC-036, TC-037, TC-038, TC-040, TC-042, TC-043, TC-045, TC-047, TC-048, TC-049, TC-051, TC-052, TC-053, TC-054, TC-055, TC-056, TC-057, TC-058 |
| **ACCEPTED WITH NOTE** | 10 | TC-002, TC-005, TC-008, TC-021, TC-024, TC-026, TC-028, TC-039, TC-044, TC-046 |
| **DISAGREE -- needs further discussion** | 0 | *(none)* |
| **ESCALATION CONFIRMED** | 5 | TC-014, TC-022, TC-029, TC-031, TC-050 — **all 5 resolved by founder (2026-04-14)** |
| **DEFERRAL ACCEPTED** | 5 | TC-003, TC-006, TC-009, TC-033, TC-041 |
| **Total** | 58 | |

### Items with DISAGREE Verdict

None. All 58 PM responses are satisfactory.

### Summary of ACCEPTED WITH NOTE Implementation Considerations

These are flagged for the SDS author's attention during system design:

| TC | Implementation Consideration |
|---|---|
| TC-002 | Compound group needs a `compound_role` field (or ordering convention) to distinguish the primary transaction from secondaries. Avoid hardcoding "exactly 2 members" in schema/queries for v2 extensibility. |
| TC-005 | Draft `form_state_json` should include a `schema_version` to handle stale drafts after app updates. Silent FIFO eviction of the oldest draft when the 5-draft limit is reached should show a brief toast notification. |
| TC-008 | Pending transactions voided without a reversing entry represent a unique audit state. The "all fields freely editable" rule for pending transactions bypasses the correction model -- this is a distinct code path. |
| TC-021 | The `total_configured` immutability exception should be enforced via a dedicated method (e.g., `updateTotalOnEarlyClose()`) rather than a generic setter, making the exception auditable in code review. |
| TC-024 | The `correction_chain_id` may be better modeled as a `corrects_transaction_id` (linked-list) rather than a shared group ID, for chains of corrections. The `is_system_generated` boolean may be redundant with `purpose = system` from TC-001 -- unify to avoid dual source of truth. |
| TC-026 | The `pause_until` field on paused templates must be checked on every app launch and scheduler tick. SDS should define whether auto-resume is eager (on launch) or lazy (on next occurrence fire). The `archived_reason` enum should be populated consistently across all archival code paths. |
| TC-028 | Include `sort_order` column in v1 schema (nullable) to avoid a disruptive migration in v2. Category name uniqueness (case-insensitive, within tree/parent, including soft-deleted) requires a composite unique index. |
| TC-039 | The "next app launch" notification for voided pending transactions must be persistent (stored in DB). The asymmetry between soft-deleted accounts (void pending) and soft-deleted categories (still post) should be prominently documented in the scheduler code. |
| TC-044 | Per-currency decimal precision: strongly prefer storing amounts as integers in minor units (avoids floating-point errors). Exchange rate precision (6-8 decimal places) must be consistent across all computation paths. Static currency data file should be versioned. |
| TC-046 | Category balance formula requires `exchange_rate_to_home` to be non-null on every transaction (1.0 for home currency). After a home currency change (TC-029), `home_currency_at_capture` is essential for correct category balance computation. SDS should define whether category balances are computed on-the-fly or cached with invalidation. |

### Overall Assessment

**The product documents will be implementable once the PM's proposed text updates and the 5 founder decisions are resolved.** The PM's responses are thorough, precise, and demonstrate strong product thinking. Specific observations:

1. **Schema readiness:** The consolidated entity definitions (TC-024 through TC-028) provide a complete foundation for the SDS data model. No entity is missing fields that would block schema design.

2. **DEB model integrity:** The multi-currency clarifications (TC-045 per-currency EQ, TC-046 category balances in home currency, TC-047 threshold currency handling) resolve the most architecturally significant concerns. The DEB invariant is preserved correctly across all specified cases.

3. **Template lifecycle:** The four-state template machine (TC-043), installment materialization model (TC-011), and the scheduler edge cases (TC-030, TC-039, TC-041) provide a complete specification for the recurring/installment engine.

4. **Founder decisions are well-framed:** All 5 escalations (TC-014, TC-022, TC-029, TC-031, TC-050) present clear options with PM recommendations. None of these block core schema design -- only TC-031 (navigation model) blocks the UX Flows document structure.

5. **No blocking disagreements:** All 58 items are resolved to the LE's satisfaction. The 10 "ACCEPTED WITH NOTE" items flag implementation nuances for the SDS author but do not require further PM action.

**Recommendation:** Proceed with (a) the PM's proposed PRD text updates, (b) founder decision collection on the 5 escalated items, and (c) SDS drafting in parallel (the SDS can begin with schema design, DEB engine, and business logic while the founder decisions and UX Flows are finalized).
