---
name: PRD v2 Draft — Deferred Features & Decisions
status: in progress
owner: pm
created: 2026-04-14
last_updated: 2026-04-21
depends_on: [01-product/prd.md]
outputs_to: []
---

# Variance — PRD v2 Draft

> **Purpose:** This document consolidates all features, decisions, questions, and ideas explicitly deferred to v2 from the v1 PRD. It serves as the starting point for v2 product planning. Items are grouped by origin and cross-referenced to their v1 PRD location.
>
> **Status:** Draft collection — not a specification. Items here need full product definition before they become implementable.
>
> **Last Updated:** 2026-04-15

---

## 1. Budgeting (Full Feature — §5.3)

The entire budgeting feature was deferred from v1 to v2 for a ground-up redesign alongside savings goals.

**Preserved v1 specification (starting point):**
- Total budget: single overall spending ceiling per period.
- Per-category budgets: individual limits per expense category. May exceed total budget (passive indicator only, no block).
- Default budget horizon: monthly. Additional: weekly, quarterly, annual. Multiple horizons may coexist.
- Income replenishment: "Add to Budget" action on any income transaction. Pool formula: N_new = min(N + T, M).
- Budget vs. actual: real-time comparison with colour-threshold progress bars.
- Budget alerts: in-app alerts at configurable thresholds (default 80% and 100%). Per-budget, user-configurable.
- Budget rollover: configurable per budget, defaults to off.

**Deferred feature gap items (from v1 FG analysis):**

| ID | Topic | Notes |
|----|-------|-------|
| FG-A17 | Budget creation fields | What fields are collected when creating a budget? Total amount, period, category selection, rollover toggle. |
| FG-A18 | Budget currency | Does a budget inherit the home currency or can it be set per-budget? |
| FG-A19 | Budget period start day | User-configurable "budget month start day" for users whose pay cycle doesn't align with the 1st. |
| FG-A20 | Budget rollover and overspend | When rollover is on, does overspend carry forward as a deficit? |
| FG-A21 | Budget transaction counting | How are transactions counted against a budget — by transaction date or posting date? |
| FG-B3 | In-app alert history | Where do past alerts go? One-time vs. recurring triggers. Notification center / alert history. |
| FG-B6 | Budget and soft-deleted categories | What happens to a per-category budget when the category is soft-deleted? Auto-archive, orphan, or relabel? |
| FG-C8 | Budget period start day configuration | Analogous to "week start" — configurable budget month start day for non-1st pay cycles. |
| FG-C9 | Income categories in budget context | Income budgets / savings targets — goal for income earned per period, separate from expense budgets. |

**Open questions (to be resolved in v2 planning):**
- Q59: Budget entry contextual menu design.
- Q61: "Remove from Budget" action.
- Q68: Budget period auto-creation.
- Q69: Historical budget periods.

---

## 2. Savings Goals

Mentioned in the v1 PRD version roadmap as a v2 feature. To be designed alongside budgets for coherent interaction.

**No v1 specification exists.** This is a greenfield design in v2.

---

## 3. Split Transactions (§8 Deferred)

Recording a single bill/payment split across multiple categories (e.g., one supermarket receipt = Groceries + Toiletries + Snacks).

**Design intent from v1:**
- One transaction per split at the ledger level.
- UI and edit flows to be designed in v2.

---

## 4. Advanced Filter Mode (FG-A13)

Predicate builder with AND/OR/NOT operators, enabling queries like "(Food OR Transportation) AND last 30 days."

**v1 ships with:** Simple filter view — all criteria combined with AND logic.

---

## 5. Saved Filter Profiles (FG-A14)

Naming and persisting a filter configuration for repeated use. In v1, filters clear on navigation.

---

## 6. Local Backup Import / Restore (FG-A31)

Restoring data from a v1 backup zip. v1 is write-only — export exists but no import path.

---

## 7. Cloud Backup and Sync (FG-A31)

Google Drive or similar. Consistent with offline-first — sync is opt-in and explicit.

---

## 8. Comprehensive TalkBack / Screen Reader Coverage (FG-A30)

Exhaustive a11y labelling for complex custom widgets, financial data tables, chart narration. v1 ships with best-effort labelling of interactive elements.

---

## 9. Account and Category Manual Reordering

Default order in v1 is alphabetical. v2 adds drag-to-reorder for both accounts and categories.

---

## 10. Recurring Template Disable / Enable

v1 has pause/unpause only. v2 adds full disable/enable with backfill option: on re-enable, prompt user to realise only future transactions or also backfill all transactions from the disabled period.

---

## 11. Subcategory Parent Reassignment

Reassigning a subcategory to a different parent category. Fixed at creation in v1.

---

## 12. Trends, Dashboards, Charts, Analytics, Visualisations

Full analytics suite. v1 has no charts or visualisation beyond the home screen summary.

**v2 candidates:**
- Net worth graph over time (from §5.8 v2 additions).
- Per-account balance history / mini chart (FG-C5).
- Income vs. expense trends by month/quarter/year.
- Category spending breakdown (pie/bar chart).
- Budget-at-a-glance widget on home screen.

---

## 13. Data Management: CSV Export, CSV Import, Data Wipe

- CSV export: per-account or all-account transaction history.
- CSV import: importing transactions from external sources.
- Data wipe / factory reset (FG-C10): clear all data without uninstalling.

---

## 14. Audit View

Surfaces all transactions including voided entries, journal adjustments (invisible balance edits), reversing/corrected pairs, and system-generated internal transfers. Full ledger transparency.

---

## 15. Tags

Colour, name, icon. Assignable to transactions. Filterable and searchable. Cross-cutting metadata layer.

---

## 16. Cross-Currency Transfers and Fees

Cross-currency transfers are blocked in v1 (§7). v2 must design:
- Exchange rate entry at transfer time.
- DEB handling for multi-currency Dr/Cr (Case 3.3 in ledger-entry.md).
- Transfer fee in cross-currency context (§5.1.5b notes deferral).

---

## 17. Transaction Detail View — v2 Additions (FG-B1)

- **Correction history:** "This transaction was corrected on [date]" with links to original and reversal entries.
- **Recurring template link:** Which template generated this transaction; past and future occurrences of the series.
- **Installment and loan status:** If part of an installment series linked to a loan account — series progress, remaining amount, loan balance.

---

## 18. Home Screen — v2 Additions (FG-B2)

- **Net worth graph over time** (line chart, derivable from ledger).
- **Budget-at-a-glance widget** (current period spend vs. budget — depends on budgeting feature).
- **Analytics summary** (top spending categories, month-over-month trends).

---

## 19. v3+ Items (for reference)

These are v3 or later and not expected in v2, but listed for completeness:
- ML insights and predictions. *(Note: v2 introduces LLM-based insights via BYOK in §24 — a cloud-dependent, user-initiated approach. v3 ML refers to on-device, offline-capable predictive models such as spending forecasts and category auto-classification. These are distinct features.)*
- OCR receipt capture.
- Exchange rate update infrastructure (if not landed in v2).
- Google Drive backup (if not landed in v2).
- ML/rule-based auto-generated transaction titles.
- **Android home screen widget (FG-C7)** — glanceable finance widget showing key figures. Privacy concern: widget visible on lock screen without PIN. Strictly v3.
- TDS / advance tax tracking for income tax computation (if §23 lands in v2 without it).

---

## 20. FG-C Items (Resolved — Decision Log)

All FG-C items were resolved on 2026-04-14. Items are categorized by disposition:

**Baked into v1 PRD:** FG-C2 (duplicate detection), FG-C6 (balance reconciliation — all accounts), FG-C11 (Indian numbering), FG-C12 (exchange rate estimate in entry), FG-C13 (currency symbol disambiguation), FG-C18 (large transaction warning + credit card limit validation), FG-C20 (back button behaviour).

**Deferred to v2:** FG-C4 (combined search + filter — with advanced filter), FG-C5 (balance history — with analytics), FG-C8 (budget period start day), FG-C9 (income budgets), FG-C10 (app data wipe — with data management), FG-C14 (account statement export — with CSV export), FG-C21 (auto-detect transactions from SMS/email), **TC-050 v2 scope** (navigation search — search across screens/features within the app; settings screen search).

**Deferred to v3:** FG-C7 (Android home screen widget — privacy concerns).

**Rejected:** FG-C1 (quick-entry templates — no value, UI clutter), FG-C15 (undo snackbar — standard delete flow suffices), FG-C19 (default account — no pre-selection).

**No action needed:** FG-C16 (photo storage on uninstall — accept Android default), FG-C17 (recurring pause/disable — already resolved in v1/v2).

---

## 21. Savings Interest Rate Tracking

> **Priority:** Low — quality-of-life enhancement for bank account holders.
>
> **Cross-references:** Account categories (v1 PRD §5.1.2), analytics and visualisations (§12), net worth projections (§18).

Add an optional user-editable field — **annual interest rate (%)** — to Bank Account-type accounts.

**Scope clarification:** Loan accounts already carry interest rate, EMI amount, and EMI date as optional fields (v1 PRD §5.1.2). This feature adds a similar interest rate field to Bank Accounts specifically for savings/deposit interest projection. It does not modify the Loan account model.

**Core capabilities:**
- Optional field on account creation and editable in account settings.
- Projected interest calculation (display-only, not ledger entries). The app computes an estimated annual interest accrual and surfaces it alongside the account balance.
- No automatic interest posting — this is informational, not transactional.

**Design considerations:**
- Applicable to Bank Account category only. FD accounts (Investment type = FD) already have a separate model; if FD interest tracking is desired, it should be handled as part of the investment portfolio feature (§22), not this field.
- The projected interest value could feed into net worth projections (§18) and analytics dashboards (§12).
- Compounding frequency must be configurable or assumed. Indian savings accounts typically use daily compounding with quarterly crediting — this should be the default assumption, with a user-overridable setting if complexity is justified.
- For foreign-currency Bank Accounts, the projected interest is in the account's currency. No home-currency conversion is applied at the projection level.

**Open questions:**
- OQ-V2-01: Where should projected interest be surfaced? Candidates: account detail screen, analytics/trends view, or both.
- OQ-V2-02: Should the compounding frequency be user-configurable, or is a single sensible default (daily compounding, quarterly crediting) sufficient for v2?
- OQ-V2-03: Does this field warrant inclusion in the onboarding flow for Bank Account creation, or is it a settings-only field?

**Design work needed:** Display placement for projected interest, compounding model, interaction with analytics dashboards (§12).

---

## 22. Investment Portfolio Tracking

> **Priority:** Medium — extends Variance from expense tracking into personal finance management.
>
> **Cross-references:** Existing Investment account category (v1 PRD §5.1.2), account balance model (v1 PRD §5.1.3), net worth (§18), analytics (§12), projected income tax (§23).

Extend the existing Investment account category to support portfolio-level tracking: holdings, market prices, cost basis, and unrealised gain/loss.

**Existing v1 model:** The Investment account category already exists (v1 PRD §5.1.2) with types FD, Mutual Fund, Stocks, PPF, NPS, Other. Its balance follows the universal balance model (§5.1.3) — manually maintained via recorded transactions and balance edits. This feature enriches the Investment category with structured holdings data and optional market price feeds.

**Anti-goal conflict — cryptocurrency:** The v1 PRD lists "No cryptocurrency tracking" as a permanent anti-goal. **This feature must not include crypto as a supported asset class unless the founder explicitly revises that anti-goal.** All references to crypto are removed from this section pending founder decision.

> **FOUNDER DECISION REQUIRED:** Does investment portfolio tracking warrant revising the "No cryptocurrency tracking" anti-goal? If yes, the v1 PRD anti-goal must be formally amended. If no, crypto is excluded from this feature.

**Core capabilities:**
- **Symbol watchlist:** Add stock/MF symbols to a watchlist. Display current price, daily change, and basic chart. Watchlist is display-only — no ledger interaction.
- **Purchase recording:** Record buy/sell transactions for Investment accounts. Track quantity, purchase price, date, and fees. Buy/sell transactions create ledger entries (Dr Investment Account, Cr Bank Account for a purchase; reverse for a sale).
- **Holdings tracking:** Aggregate holdings per Investment account. Track current value vs. cost basis. Show unrealised gain/loss per holding and per account.
- **Market data feed:** Fetch current prices from a market data API. This is an **opt-in, user-initiated network call** — consistent with the offline-first constraint (v1 C1) and the uninstructed network call failure criterion (v1 FC-1). The user explicitly triggers a price refresh or enables a background refresh interval.
- **Country-aware:** Support Indian markets (NSE/BSE, AMFI MF codes for mutual funds) and global markets. Currency-aware pricing — each holding's price is in its native currency; portfolio value is converted to the account's currency.

**Design considerations:**
- **Not a new account type.** This extends the existing Investment account category. The investment type enum (FD, Mutual Fund, Stocks, PPF, NPS, Other) may need expansion or restructuring to support per-holding granularity.
- **Market data API:** Free-tier options include Yahoo Finance API, Alpha Vantage, and AMFI NAV data (publicly available, no API key required for Indian MFs). API selection must account for rate limits, reliability, and data coverage. The chosen API is a design-time decision, not a user-facing choice.
- **Unrealised gains are display-only** — not ledger entries. Only realised gains (sell transactions) create ledger entries. This preserves the DEB invariant for informational-vs-transactional data.
- **Portfolio value feeds into net worth calculation** (§18). When market data is available, net worth reflects current market value. When offline or stale, net worth uses the last-known cached price with a staleness indicator.
- **Offline-first:** Cache last-known prices locally. Display a staleness indicator (timestamp of last successful fetch) when data is not current.
- **Cost basis method:** Must be defined — FIFO, weighted average cost, or specific identification. Indian tax rules (relevant to §23) typically use FIFO for equities and average cost for mutual funds. The default should align with Indian norms.

**Open questions:**
- OQ-V2-04: Should the watchlist be a standalone feature (symbols the user watches but does not hold) or limited to held positions?
- OQ-V2-05: What is the cost basis method — FIFO, weighted average, or configurable per account/type? Consider alignment with Indian capital gains tax rules (§23).
- OQ-V2-06: How should dividend income be recorded — as a standard income transaction against the Investment account, or with a dedicated dividend sub-type?
- OQ-V2-07: Does the user configure the market data refresh interval, or is there a single sensible default (e.g., daily)?

**Design work needed:** Holdings data model (extending Investment account), market data API selection and abstraction layer, cost basis computation, portfolio valuation display, buy/sell transaction entry flow, interaction with DEB model for buy/sell/dividend, watchlist UX, net worth integration with live prices.

---

## 23. Projected Income Tax Computation (Indian Locale)

> **Priority:** Medium — high-value feature for Indian salaried users.
>
> **Cross-references:** Investment portfolio tracking (§22 — capital gains feed), analytics (§12), transaction categories (v1 PRD §5.2.4).
>
> **Dependency:** Partially depends on §22 (investment portfolio tracking) for capital gains computation. Core income tax projection can ship without §22, but capital gains estimation requires it.

Use transaction data, income category mapping, and Indian tax rules to compute a projected annual income tax liability.

**Disclaimer requirement (mandatory):** This feature provides estimates only. It is not tax-filing software and does not replace professional tax advice. A persistent, non-dismissible disclaimer must be visible on every screen that displays tax projections: *"This is an estimate based on your recorded transactions and configured deductions. It is not tax advice. Consult a tax professional for filing."*

**Core capabilities:**
- **Income-to-tax-head mapping:** The user maps their income transaction categories (v1 PRD §5.2.4) to Indian tax heads: Salary, Business/Profession, House Property, Capital Gains (short-term and long-term), Other Sources (interest, dividends, etc.). This mapping is configured once in Settings and editable at any time.
- **Tax slab application:** Apply Indian income tax slabs for both the Old Regime and the New Regime to the mapped gross income. The app projects the annual tax liability based on income recorded year-to-date, annualised.
- **Regime comparison:** Side-by-side comparison of projected tax under Old Regime vs. New Regime, showing which regime results in lower tax for the user's income profile.
- **Deduction configuration:** User-configurable deductions for Old Regime: Section 80C (investments — PPF, ELSS, etc.), Section 80D (health insurance), HRA exemption, standard deduction. New Regime: standard deduction only (per current rules). Deduction amounts are user-entered, not auto-derived from transactions.
- **Summary display:** Monthly projected tax, annual projected tax, effective tax rate, and marginal tax rate. Displayed in the analytics section (§12) or a dedicated tax projection screen.

**Design considerations:**
- **Tax rules change annually.** Slab rates and deduction limits must be updateable without an app update. Options: (a) bundled JSON/YAML config file per financial year, shipped with app updates but also downloadable as a standalone file; (b) user-editable slab table for maximum flexibility. Option (a) is recommended for v2 — simpler UX, lower error risk.
- **Indian locale only in v2.** The architecture should use a locale-abstracted tax engine interface so that future locales (US, UK, etc.) can be added by implementing the same interface with different rules. v2 ships with only the Indian implementation.
- **Financial year alignment:** Indian financial year runs April 1 to March 31. All tax projections must use the financial year, not the calendar year. The "year-to-date" income must be computed from April 1 of the current FY.
- **Capital gains (conditional on §22):** If investment portfolio tracking (§22) is available, realised capital gains from sell transactions feed into the capital gains tax head. If §22 is not available, the user can manually enter capital gains amounts as a deduction/income override.
- **Surcharge and cess:** The computation must include surcharge (income-dependent) and health & education cess (currently 4%) to produce accurate total tax liability figures.
- **No TDS tracking in v2.** Tax deducted at source (advance tax, TDS from salary) is not tracked. The projection shows gross tax liability, not tax payable after TDS. TDS tracking is a potential v3 addition.

**Open questions:**
- OQ-V2-08: Should the income-to-tax-head mapping be per-category or per-transaction? Per-category is simpler but less flexible (e.g., a "Freelance" category might span Business and Other Sources). Per-transaction adds entry friction.
- OQ-V2-09: How should the app handle mid-year regime switches? Under current Indian tax law, the regime choice is made at filing time. Should the app allow toggling the projection regime at any time, or lock it per financial year?
- OQ-V2-10: Where does the tax projection live in the app navigation — as a sub-section of analytics (§12), a dedicated top-level screen, or a settings-adjacent tool?

**Design work needed:** Tax slab data model and storage format, financial year date handling, deduction configuration UI, income-to-tax-head mapping flow, regime comparison logic, surcharge/cess computation, disclaimer placement, integration with analytics (§12), capital gains handoff from §22.

---

## 24. LLM-Based Insights (BYOK — Bring Your Own Key)

> **Priority:** Low — experimental, power-user feature.
>
> **Cross-references:** Analytics and visualisations (§12), privacy constraints (v1 PRD C1, FC-1, anti-goals).
>
> **Dependency:** Logically ships after or alongside analytics (§12). Insights are most useful when there is already a structured analytics foundation to summarise from.

Optional AI-powered financial insights using the user's own API key for an LLM provider. This is a strictly opt-in feature — the app is fully functional without it.

**Privacy and constraint alignment:** This feature introduces **user-initiated, explicit network calls** to external LLM APIs. This is consistent with the offline-first constraint (v1 C1) and the uninstructed network call failure criterion (v1 FC-1) because: (a) the feature is entirely opt-in — disabled by default, (b) every network call is user-initiated (the user explicitly requests an insight or query), and (c) no data is sent without the user's action. The app never phones home, auto-syncs, or transmits data in the background.

**Core capabilities:**
- **Spending insights:** Summary observations derived from transaction data. Examples: "You spent 40% more on Food this month than last month." "Your top 3 spending categories this quarter are X, Y, Z."
- **Anomaly flagging:** Highlight unusual transactions relative to the user's spending patterns. Example: "Unusual transaction: Rs 15,000 at [merchant] — this is significantly above your average for this category."
- **Savings suggestions:** Pattern-based recommendations. Example: "Based on your income and spending over the past 3 months, you could save approximately Rs X/month by reducing discretionary spending."
- **Natural language queries:** The user types a question in plain language and receives a data-backed answer. Example: "How much did I spend on transport in March?" The app constructs a data summary, sends it to the LLM, and displays the response.

**Design considerations:**
- **BYOK model:** The user provides their own API key for a supported LLM provider. Supported providers in v2: OpenAI, Anthropic, Google (Gemini). No Variance-hosted LLM service — ever.
- **API key storage:** Keys are stored in platform-secure storage (Android Keystore / flutter_secure_storage), never in SharedPreferences or plain-text files. Keys are never logged, cached in memory beyond the active request, or included in backup exports.
- **Data minimisation:** The app constructs a summarised data payload before sending to the LLM. By default, only aggregated figures are sent (category totals, monthly summaries, trends). Raw transaction details (titles, descriptions, merchant names) are never sent unless the user explicitly enables a "detailed mode" toggle. The data sharing level is configurable in Settings with a clear explanation of what each level sends.
- **No background calls.** Every LLM request is triggered by an explicit user action (tapping "Get Insight" or submitting a query). There is no scheduled, periodic, or background insight generation.
- **Offline behaviour:** When offline, the insights feature is disabled with a clear message: "Insights require an internet connection. Your data remains on-device." No cached insights are shown from previous sessions (to avoid stale advice).
- **Cost transparency:** Before each query, display an estimated token count and approximate cost (based on the provider's published pricing). After each query, display actual tokens used.
- **Scope for v2:** Basic insights and natural language queries only. This is not a conversational assistant, not a chatbot, and not a financial advisor. No multi-turn conversations. One question, one answer.

**Open questions:**
- OQ-V2-11: What are the exact data summarisation tiers? Proposed: (a) aggregates only — category totals, monthly income/expense, net worth; (b) aggregates + category names; (c) aggregates + transaction titles (opt-in, with warning). Need to define what each tier sends.
- OQ-V2-12: Should the app include pre-built prompt templates (e.g., "Monthly spending review", "Savings opportunity scan") or only support free-form queries?
- OQ-V2-13: Where does this feature live in the app — as a tab within analytics (§12), a standalone screen accessible from the home screen, or a floating action accessible from multiple screens?
- OQ-V2-14: How should the app handle LLM API errors (rate limits, invalid key, network failures)? Proposed: clear error message with retry option; no fallback to a different provider.

**Design work needed:** Data summarisation pipeline and tier definitions, prompt engineering for financial insights, provider abstraction layer (to support multiple LLM APIs behind a common interface), API key lifecycle (entry, validation, rotation, deletion), cost estimation model, privacy controls UI, response display format, placement within app navigation.

---

## 25. Auto-Detect Transactions from SMS & Email Notifications (FG-C21)

> **Priority:** High — this is a primary motivation for the app's target user base.

Automatically detect and record financial transactions from device notifications (SMS and email) without manual entry. This is a major v2 feature requiring significant design, permissions, and pattern-matching infrastructure.

**Core use cases:**
- **UPI payments:** Detect UPI transaction SMS (common in India) — extract merchant name, amount, date/time, and source account.
- **Credit card transactions:** Detect transaction SMS or email notifications — extract merchant, amount, card (last 4 digits → match to account).
- **Bank account debits/credits:** Detect bank SMS — extract amount, type (debit/credit), and account.

**High-level design considerations:**

| Aspect | Notes |
|--------|-------|
| **Permission model** | Requires `READ_SMS` or Notification Listener Service permission. Must be opt-in and clearly explained to the user. Privacy-sensitive — the app reads message content locally, never sends it to any server. |
| **Pattern matching** | Rule-based pattern matching against known SMS/email formats from Indian banks, UPI providers, and credit card issuers. Regex or template-based extraction. Must be extensible — new bank formats should be addable without app updates (consider a local rules file or user-contributed patterns). |
| **Account matching** | Extracted account identifiers (last 4 digits of card, bank name) are matched against the user's configured accounts. Fuzzy matching with user confirmation for ambiguous cases. |
| **Merchant → category mapping** | Optional: map known merchants to transaction categories (e.g., Swiggy → Food > Eating Out). This could use a local lookup table. If no mapping exists, the user assigns the category manually. |
| **User review flow** | Auto-detected transactions should be surfaced as **pending suggestions** — not auto-posted without user review. A dedicated "Review detected transactions" screen (similar to Pending Confirmations for recurring templates) lets the user confirm, edit, or dismiss each detection. |
| **Duplicate handling** | If the user already manually recorded a transaction that matches a detected one, the app should flag it as a probable duplicate (building on FG-C2's detection logic). |
| **Error handling** | Unrecognized SMS formats are silently ignored. False positives (non-financial SMS matched incorrectly) must be dismissible. The user can disable detection for specific senders. |
| **Gmail integration** | If feasible: read credit card statement emails from Gmail via local notification access or an authorized Gmail API scope. This is more complex and may be a v2+ or v3 feature within this feature set. |

**Out of scope for this feature:** Cloud processing of messages, sharing message content with any server, auto-posting without user review.

**Design work needed:** Full UX flow for review screen, permission request flow, pattern library architecture, account matching algorithm, category suggestion model.

---

## 26. Core UX and Visualization Enhancements

> **Priority:** Medium — power-user ergonomics and engagement features.
>
> **Cross-references:** §12 (Trends, Dashboards, Charts), §18 (Home Screen v2).

### 26.1 Calendar View

- Display transactions on a monthly calendar grid.
- Each day cell shows a summary indicator (e.g. net spend, dot, or count badge).
- Tapping a day opens that day's transaction list.
- **OQ-V2-15:** Indicator style — numeric amount vs. colour-coded dot vs. count badge?

### 26.2 Tap Date to Enter Transaction

- From the calendar view, tapping a date pre-fills the transaction date field and opens the Add Transaction flow.
- Dependency: §26.1 (Calendar View).

### 26.3 GitHub-Style Activity Heatmap

- Full-year heatmap grid (52 columns × 7 rows) showing transaction activity intensity per day.
- Colour intensity = transaction count or total absolute amount (configurable).
- Lives within the analytics / trends screen (§12).
- **OQ-V2-16:** Metric for intensity — count vs. absolute amount vs. net amount?

### 26.4 Periodic Reports (Yearly / Quarterly / Monthly / Weekly)

- Pre-built summary reports scoped to a time period.
- Report content: income total, expense total, net, top categories, account balances.
- Exportable (PDF or CSV — depends on §13 Data Management).
- Relates to §12 analytics suite.
- **OQ-V2-17:** Should reports be a separate screen or a time-scope filter on the analytics screen?

### 26.5 Daily / Monthly / Annual Passbook / Statement View

- Per-account chronological statement view (passbook style).
- Shows each posting with running balance.
- Scoped by period: day / month / year (user selects).
- Distinct from the main transaction list — account-centric, running balance column.
- **OQ-V2-18:** Separate screen per account or a mode within the existing account detail view?

### 26.6 Transaction Title Templates by Category

- Per-category list of pre-defined title strings (e.g. "Lunch", "Coffee", "Monthly rent" under Food/Housing).
- User can add, edit, and delete templates per category.
- Templates surface as quick-pick chips when the category is selected during transaction entry.
- Distinct from AI-powered suggestions (§27.5) — these are static, user-curated strings.

### 26.7 Copying Transactions

- Two copy modes:
  - **Copy with today's date** — duplicates the transaction, sets date to today, opens it in edit mode.
  - **Copy with original date** — duplicates the transaction preserving the original date, opens it in edit mode.
- Available from the transaction detail view (long-press or action menu).
- The duplicate opens pre-filled for review before saving; it is not auto-posted.

### 26.8 Swap From/To in Transfers

- One-tap swap button on the transfer entry form.
- Swaps the debit account and credit account fields.
- Applies only to Transfer-type transactions.

### 26.9 Collapse and Expand Account Groups

- Account list (accounts screen and account pickers) supports collapsible groups.
- Groups correspond to account types or user-defined groups (depends on grouping model in data model).
- Collapsed state is persisted per session or permanently (configurable).
- **OQ-V2-19:** Is collapse state per-session or persisted to storage?

---

## 27. AI Features

> **Priority:** Low — opt-in power-user features. All items in this section require the global AI flag (§27.2) to be enabled.
>
> **Cross-references:** §24 (LLM-Based Insights BYOK), §26.6 (Title Templates by Category).
>
> **Privacy constraint:** Consistent with §24 privacy model — all network calls are user-initiated, opt-in, and data-minimised.

### 27.1 HuggingFace as a BYOK Provider

- Add HuggingFace Inference API as a supported LLM provider alongside OpenAI, Anthropic, and Google (Gemini) listed in §24.
- Motivation: free-tier models available; reduces cost barrier for personal use.
- HuggingFace keys follow the same secure storage model as §24 (flutter_secure_storage, never logged).
- **OQ-V2-20:** Which HuggingFace models are supported? Proposed: user specifies model ID; app validates the endpoint responds before saving.
- **OQ-V2-21:** HuggingFace Inference API has different request/response shapes than OpenAI-compatible APIs — provider abstraction layer in §24 must be extended.

### 27.2 Global AI Feature Flag

- Single toggle in Settings: **Enable AI Features** (default: off).
- When off: all AI surfaces (insights, title suggestions, usage tracking) are hidden from the UI entirely.
- When on: individual AI features may have their own sub-toggles.
- Disabling the flag mid-session clears any in-memory state; no queued or background calls are made.
- Relates to §24 opt-in model; this is the master switch above all individual AI feature toggles.

### 27.3 AI Usage Tracking In-App

- Settings screen (AI section) shows a usage summary: requests made, estimated tokens consumed, estimated cost (per provider, based on published pricing).
- Data stored locally only — no telemetry or usage reporting to Variance.
- Reset option: user can clear usage history.
- **OQ-V2-22:** Granularity — per-day breakdown vs. cumulative total only?

### 27.4 Pre-Defined AI Analysis Options

- A set of canned prompt templates surfaced in the Insights screen (§24).
- Examples:
  - "Analyze my spending this month"
  - "Where am I overspending compared to last month?"
  - "What are my top 3 spending categories this quarter?"
  - "Show savings opportunities based on recent spending"
- User taps a template → app constructs the data payload → sends to LLM → displays result.
- Resolves OQ-V2-12 from §24 partially: pre-defined prompts coexist with free-form queries.
- User can extend the list with custom templates (v2+ scope).
- **OQ-V2-23:** Can users edit or delete the built-in templates, or only add custom ones?

### 27.5 AI-Powered Title Suggestion (On the Fly)

- During transaction entry, after the user selects a category, the app suggests a title in real time using the LLM.
- Suggestion appears as a pre-fill or chip below the title field; user can accept, ignore, or type their own.
- Context sent to LLM: category, amount, account, date — no raw transaction history unless user opts in.
- Requires global AI flag enabled (§27.2) and a configured provider (§24).
- Distinct from static title templates (§26.6) — AI suggestions are generated, not user-curated.
- **OQ-V2-24:** Should AI suggestions be shown inline (pre-fill) or as a chip/button below the field?
- **OQ-V2-25:** Latency concern — suggestion must not block the user. Show a loading indicator or defer until the user pauses typing?
