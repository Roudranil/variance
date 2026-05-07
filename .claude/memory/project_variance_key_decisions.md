---
name: Variance — Key Design Decisions (All Resolved)
description: Locked design decisions from PRD v0.3.0 — all Q1–Q76 resolved
type: project
originSessionId: cb59043d-7022-4258-8e2f-b57bf0d6bbaf
---
All Q1–Q76 are resolved and baked into PRD v0.3.0. Cumulative key decisions:

## Core Architecture
- **Platform:** Android only, min API 31 (Android 12)
- **DEB abstraction:** Fully abstracted — income/expense/transfer UI only
- **License:** MIT
- **All deletes:** Soft only — no entity ever permanently deleted
- **Timestamps:** UTC storage, local timezone display
- **Future-dated transactions:** Held as pending until date; auto-post on arrival. Schema needs `status` field.

## Accounts
- **Account names:** Unique across ALL accounts including soft-deleted
- **Reinstatement:** Offered when creating an account matching a deleted one (name+type match). Architecturally trivial — just flips is_deleted flag.
- **Soft-delete transfer:** System-generated internal transfer (not user-editable). Warning on deletion of this transfer.
- **Default order:** Alphabetical. Manual reordering deferred to v2.

## Transactions
- **3-column list layout:** C1 category, C2 title+account info, C3 amount+currency
- **Grouped by date, ordered by time.** Time shown on tap.
- **Unified all-account list** is default. Per-account list via account detail.
- **Correction visibility:** Only final corrected version visible. Original+reversal hidden (DEB abstraction). Audit view in v2.
- **Description:** Detail view only. Max chars configurable (500/1000/2000, default 1000).
- **Exchange rate:** Locked at transaction creation time. Both currencies shown in list. Detail view shows rate.

## Categories
- **Icons:** `material_symbols_icons` package (^4.2928.1). Curated subset bundled.
- **Balance Adjustment:** Completely immutable, hidden from management. Protected entity pattern (`is_protected` flag).
- **Deletion with migration:** Users can migrate transactions to another category on delete.
- **Reinstatement:** Same as accounts — offered when name matches a deleted category.
- **Reordering:** Deferred to v2. Default: alphabetical.

## Recurring & Installments
- **Child edit/delete:** Occurrence marked "manually handled"; template continues unchanged.
- **Pause/Unpause:** v1 feature. Duration in template's time unit or custom date. Skipped items stay skipped.
- **Disable/Enable:** Deferred to v2.
- **Notifications:** OS-level local notifications for remind-and-confirm. 24h auto-approve. No network call.
- **Installment 4-way tracking:** total configured, running total, remaining, projected final.
- **Installment contextual menu:** Edit, Delete, Pause, Unpause, View children, View payment progress, Mark complete.

## Budget
- **ENTIRELY DEFERRED TO v2.** To be redesigned alongside savings goals from the ground up.

## App Lock & Security
- **Hierarchical mechanism:** Device lock → app-specific lock → in-app PIN (fallback)
- **Configurable scope:** App-wide OR sensitive details only
- **Configurable timeout:** Immediate/30s/1m/5m on backgrounding
- **Session unlock:** Once authenticated for sensitive fields, stays unlocked until app close/minimize

## Onboarding
- **5-step wizard:** Welcome, Currency (locale-derived, INR fallback), First account, Highlights, Done
- **Skippable.** Categories silently seeded regardless.

## Multi-Currency
- **Transaction-level rate capture:** Stored per-transaction. Schema needs `exchange_rate_to_home` (nullable).
- **List display:** Both original and home currency amounts.
- **Net worth:** Uses current/cached rate (not historical).

**How to apply:** These are settled. Don't re-open or re-debate them unless the user raises it.
