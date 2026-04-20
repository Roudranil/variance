---
name: Ideation Diff
status: current
owner: architect
created: 2026-04-20
last_updated: 2026-04-20
depends_on: []
outputs_to: []
---

# Ideation Diff — Session 2026-04-20 (Part 3: SDS Review vs Competitive Analysis)

> This file records the exact changes made in this ideation session. It is overwritten each session and used as the basis for commit messages.

---

## 1. Files Modified

### `docs/02-technical/sds.md`

Seven surgical edits made. No sections were rewritten wholesale. All changes are additive or targeted replacements within existing sections.

---

#### Edit 1 — §2.7.1: Replace Frankfurter with fawazahmed0/exchange-api

**Location:** Section 2.7, subsection 2.7.1 (Decision — TC-006)

**What changed:**
- Decision title: `Frankfurter API` → `fawazahmed0 Exchange API`
- Decision: Changed from `api.frankfurter.app` to `cdn.jsdelivr.net/npm/@fawazahmed0/currency-api` served via jsDelivr CDN
- Options table: Added fawazahmed0 as the selected option; demoted Frankfurter to "Rejected — 33-currency ceiling insufficient; no crypto"
- Rationale: Updated to reflect fawazahmed0's 537-currency coverage (vs Frankfurter's ~33), CDN backing, crypto support, and production adoption in open-source finance apps
- Response format: Added concrete URL template and JSON response shape
- Tradeoffs accepted: Added single-maintainer SLA risk; documented 1-URL swap escape hatch via provider abstraction
- §2.7.2 Endpoint: Updated from `api.frankfurter.app/latest?from=...&to=...` to jsDelivr CDN URL pattern (single base-currency fetch returns all rates)
- §2.7.3 Cache schema: Updated `rate_date` comment to remove ECB-specific reference
- §2.7.5: Added explicit note that provider URL is a single named constant; alternative provider swap is a 1-constant + 1-parsing-method change

**Why:** The competitive analysis (Bonus Finding 1) explicitly recommends fawazahmed0 for Variance v1, noting it was verified in production use by the competitor. Frankfurter's ~33-currency ceiling was insufficient given PRD §7.1's currency list and v2 crypto expansion plans.

---

#### Edit 2 — §1.3.4: Add SQLCipher to Infrastructure Cross-Cut table

**Location:** Section 1.3.4 (Infrastructure Cross-Cut)

**What changed:**
- Changed HTTP package reference in the infrastructure table from `dio` to `http` (corrects a stale reference — `dio` was never the chosen package; `http` was already in §2.14.1)
- Added new row: `Database encryption | sqlcipher_flutter_libs | SQLCipher encryption at rest for all financial data`
- Updated `Secure storage` row purpose to explicitly mention SQLCipher key material and Android Keystore backing
- Added a bolded explanatory paragraph: database encryption is a v1 requirement (AP-4); key derived from Android Keystore; no unencrypted migration path; encrypted from first launch

**Why:** Anti-pattern AP-4 from the competitive analysis identifies plain SQLite as the single most exploitable vulnerability in Cashew. All financial data readable by any process with filesystem access. The SDS previously had no SQLCipher requirement anywhere. The competitive analysis's security section (§6.2.1) mandates SQLCipher for v1 launch.

---

#### Edit 3 — §2.3.1: Replace `sqlite3_flutter_libs` with `sqlcipher_flutter_libs`

**Location:** Section 2.3.1 (Drift ORM table)

**What changed:**
- SQLite binding row: `sqlite3_flutter_libs ^0.5.0` → `sqlcipher_flutter_libs ^0.3.0` with encryption description
- Database file row: added annotation that the file is encrypted and the key is stored in Android Keystore via flutter_secure_storage
- Added a new explanatory paragraph: why SQLCipher, AES-256 page-level encryption, ~5–15% overhead is acceptable, key management summary

**Why:** Consequential change from Edit 2. §2.3.1 is the authoritative package declaration for the database layer. Using plain `sqlite3_flutter_libs` would contradict the security requirement added in §1.3.4.

---

#### Edit 4 — §2.14.1 and §2.14.3: Update dependency table and notes

**Location:** Section 2.14.1 (Production Dependencies table) and §2.14.3 (Dependency Notes)

**What changed:**
- §2.14.1: Replaced `sqlite3_flutter_libs ^0.5.0` row with `sqlcipher_flutter_libs ^0.3.0` row
- §2.14.3: Added two new dependency notes:
  - `sqlcipher_flutter_libs replaces sqlite3_flutter_libs`: explains drop-in substitution, version sync requirement
  - SQLCipher key management: first-launch key generation, Keystore storage, irrecoverability by design

**Why:** §2.14 is the canonical dependency table. It must be consistent with §1.3.4 and §2.3.1. The Dependency Notes section is where rationale for non-obvious package choices is documented.

---

#### Edit 5 — §1.4.2: Add cursor-based pagination requirement

**Location:** Section 1.4.2 (Reactive Read — Transaction List data flow)

**What changed:**
- Replaced the simple data flow diagram (no pagination) with an augmented version specifying:
  - Cursor-based query pattern: `WHERE date < :cursor ORDER BY date DESC LIMIT :pageSize+1`
  - `+1` trick for `hasNextPage` without a separate COUNT query
  - `Stream<PagedResult<Transaction>>` return type (instead of `Stream<List<Transaction>>`)
  - Presentation layer manages cursor, loading state, and hasNextPage flag
  - `SliverList.builder` is the required widget pattern (no full-dataset `ListView`)
  - Grouping by date performed in the query layer, not the widget layer
- Added a bold explanatory paragraph naming AP-5 (competitive analysis), the Cashew `DEFAULT_LIMIT = 100000` anti-pattern, page size of 50, and the `Isolate.run()` / `compute()` requirement for aggregation over 500+ rows on the main thread

**Why:** Anti-pattern AP-5 from the competitive analysis (infinite scroll/large list rendering) is rated "Poor" in Cashew. The SDS's previous data flow diagram implied loading the full result set into a stream with no size bound — the same time bomb that degrades at 3,000+ transactions. This is a functional gap that must be in the SDS before the data layer is designed.

---

#### Edit 6 — §1.6.9 and §1.6.10: Add two new Key Architectural Constraints

**Location:** Section 1.6 (Key Architectural Constraints) — after existing §1.6.8

**What changed (§1.6.9 — File Size Constraint):**
- New constraint: no source file in `lib/` may exceed 800 lines; target is 200–400 lines
- Enforcement: code review rejection; TPM rejects any PR with a file over 800 lines
- Rationale: cites AP-2 (Cashew's 7,667-line tables.dart and 5,207-line addTransactionPage.dart)
- Architectural implication: Drift `@DriftDatabase` class is a thin shell under 100 lines; queries live in DAO files

**What changed (§1.6.10 — O(1) Date Arithmetic):**
- New constraint: all date-range/period calculations must be O(1) arithmetic — no forward-iteration loops
- Algorithm: `periodIndex = (today - startDate) ~/ periodLength`; Dart `DateTime` constructor handles month/year overflow
- Rationale: cites AP-9 (Cashew's `getBudgetDate()` up to 10,000-iteration loop, 3,650 iterations per home screen rebuild at five 2-year-old daily budgets)
- Architectural implication: `PeriodCalculator` domain service in `domain/services/period_calculator.dart`; exhaustively unit-tested with edge cases

**Why:** Both constraints are necessary to prevent known debt patterns from being introduced by an implementer following the letter of the SDS but not the competitive analysis. The SDS is the developer's primary reference; constraints that live only in the competitive analysis are invisible to implementation.

---

#### Edit 7 — §1.3.2.1 and §1.5.1: Register PeriodCalculator as a domain service

**Location:** Section 1.3.2.1 (Domain Services list) and §1.5.1 (Folder Structure)

**What changed (§1.3.2.1):**
- Changed "Three domain services" to "Four domain services"
- Added new bullet: `PeriodCalculator` — O(1) computation of current period window for recurring templates and budgets; no iteration; handles month-boundary and leap-year edge cases via Dart `DateTime` arithmetic; see §1.6.10

**What changed (§1.5.1):**
- Added `period_calculator.dart` to the `domain/services/` listing alongside the existing three services

**Why:** §1.6.10 references `domain/services/period_calculator.dart` by path. The domain services list and folder structure must be consistent with the new constraint. Leaving PeriodCalculator only in §1.6.10 would create a gap in the authoritative service inventory.

---

#### Edit 8 — TOC: Update to reflect new sections and renamed section

**Location:** Table of Contents (lines 83–88, 54–55)

**What changed:**
- §2.7.1 TOC link text: `Frankfurter API` → `fawazahmed0 Exchange API`
- Added §1.6.9 entry: `File Size Constraint — 800-Line Maximum`
- Added §1.6.10 entry: `O(1) Date Arithmetic — No Iteration Loops for Period Calculations`

---

## 2. Anti-Pattern / LE Note Disposition Table

| Source | Finding | SDS gap before this session | Resolution |
|--------|---------|----------------------------|------------|
| AP-1 | Global mutable settings map | None — Riverpod + freezed already specified | No change needed |
| AP-2 | God file (7,667-line tables.dart) | Folder structure implied discipline; no explicit size limit | Added §1.6.9 (800-line constraint) |
| AP-3 | Zero test coverage | SDS §2.11 testing stack fully specified | No change needed |
| **AP-4** | **No database encryption (plain SQLite)** | **Critical gap — `sqlite3_flutter_libs` used throughout** | **Edits 2, 3, 4: Added SQLCipher requirement** |
| AP-5 | GlobalKey-based state refresh | Riverpod reactive architecture already specified | No change needed |
| AP-6 | Module-level `late` singletons | Riverpod DI graph + constructor injection already specified | No change needed |
| AP-7 | Silent error swallowing | `Result<T>` pattern already specified in §2.9 | No change needed |
| AP-8 | JSON-in-columns | Domain model uses proper entities; data-model.md owns junction tables | No change needed (data-model.md scope) |
| **AP-9** | **O(n) period iteration** | **Not mentioned anywhere in SDS** | **Edit 6: Added §1.6.10 + PeriodCalculator service** |
| AP-10 | Full-database sync upload | Sync is v2 scope; §1.6.1 + §1.7 cover it | No change needed |
| LE note: large list pagination | No cursor-based pagination in SDS data flow | Stream emitted full result set — unbounded | Edit 5: Added cursor-based pagination in §1.4.2 |
| LE note: isolate offloading | No mention of background isolates for aggregation | Missing — main thread at risk for large datasets | Added to §1.4.2 pagination note |
| LE note: file size guardrail | No explicit constraint in SDS | Missing — only implied by folder structure | Edit 6: Added §1.6.9 |
| **Exchange rate API** | **fawazahmed0 vs Frankfurter** | **SDS used Frankfurter; competitive analysis recommends fawazahmed0** | **Edit 1: Full §2.7.1 replacement** |

---

## 3. Files Unchanged This Session

- All `docs/01-product/` files (product docs locked — never modified without explicit founder change request).
- `docs/06-helpers/ideation-tracker.md` — no tracker update this session (changes are targeted SDS fixes, not phase transitions).
- `docs/06-helpers/gaps-and-questions.md` — no new gaps surfaced; no existing gaps resolved.
- `docs/06-helpers/ideation-folder-structure.md` — no new files created.
- All other `docs/02-technical/` files — `data-model.md`, `api-contracts.md`, `ux-flows.md`, `feature-dag.md` — unmodified.
