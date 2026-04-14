---
name: Ideation Session Diff
status: current
owner: pm
created: 2026-04-14
last_updated: 2026-04-14
depends_on: [01-product/prd.md, 06-helpers/ideation-tracker.md]
outputs_to: []
---

# Ideation Session Diff — 2026-04-14 (Session 6)

> This file records the exact set of changes made to product documents in the current ideation session. It is used as the basis for commit messages. It overwrites the previous session's contents on each new session.

**Session scope:** Settings & Configuration audit — full PRD scan for all user-configurable settings, cross-referenced against §5.4, and complete restructure of §5.4 from a flat grab-bag into a hierarchical Settings screen spec with 12 properly grouped sub-sections.

---

## `docs/01-product/prd.md`

### TOC

- Updated §5.4 sub-entries from 7 items (5.4.1–5.4.8, skipping 5.4.7) to 12 items (5.4.1–5.4.12) reflecting the new structure.

### §5.4 — Settings & Customisation (CORE) — Full Restructure

**Old structure (replaced):**
- §5.4.1 Appearance
- §5.4.2 Primary Configuration (flat grab-bag of 10 unrelated settings)
- §5.4.3 Security
- §5.4.4 Management (mixed entity management + backup)
- §5.4.5 Accessibility
- §5.4.6 Local Data Backup
- §5.4.7 *(missing — numbering gap)*
- §5.4.8 About & Legal

**New structure:**
- §5.4.1 **Appearance** — Theme, Color scheme, Font, Animations. Now with Type/Default/Options columns.
- §5.4.2 **Locale & Format** — Home currency, Number format (decimal separator + thousands grouping split into separate rows), Currency formatting (symbol placement + spacing split into separate rows), Week start, Time format, Percentage precision. Each with explicit Type/Default/Options.
- §5.4.3 **Transaction Entry** — Description max length, Back button behaviour. Note: duplicate detection is always-on (no toggle).
- §5.4.4 **Warnings & Limits** — Large transaction warning thresholds (per-account and per-category as separate settings with sub-screen navigation). Precedence rule added: account threshold takes precedence over category when both apply. Note: overdraft and CC limit warnings are not configurable settings.
- §5.4.5 **Profile** — Display name (single field, own section).
- §5.4.6 **Security** — Lock timeout (the only configurable setting). Lock mechanism, PIN recovery, and failed lockout unchanged from old §5.4.3.
- §5.4.7 **Accounts** — Entity management (was part of old §5.4.4). Cross-refs to §5.1.1.
- §5.4.8 **Transaction Categories** — Entity management (was part of old §5.4.4). Cross-refs to §5.2.4.
- §5.4.9 **Recurring & Installments** — Entity management (was part of old §5.4.4). Cross-refs to §5.2.7, §5.2.8.
- §5.4.10 **Data** — Local Data Backup (was old §5.4.6). Path changed to "Settings > Data > Backup".
- §5.4.11 **Accessibility** — Unchanged from old §5.4.5. Added note that these are system-level, not in-app toggles.
- §5.4.12 **About & Legal** — Unchanged from old §5.4.8.

**Introductory note added** at the top of §5.4 explaining the section's purpose and that per-entity settings are delegated to entity edit forms.

### Cross-reference updates

All internal §5.4.X references throughout the PRD updated to match new numbering:
- §5.4.2 (currency) — unchanged, still §5.4.2
- §5.4.2 (description max) → §5.4.3
- §5.4.2 (display name) → §5.4.5
- §5.4.3 (security) → §5.4.6
- §5.4.4 (categories) → §5.4.8
- §5.4.6 (backup) → §5.4.10

### New content added

- **§5.4.4 Warnings & Limits:** Precedence rule — when both account and category thresholds are exceeded for a single transaction, only one warning is shown (account threshold takes precedence).
- **§5.4.4 Warnings & Limits:** Explicit note that overdraft and CC limit warnings are not configurable settings.
- **§5.4.3 Transaction Entry:** Explicit note that duplicate detection (FG-C2) is always active with no toggle.

---

## Files NOT changed

- `docs/01-product/ledger-entry.md` — no ledger changes in this session.
- `docs/01-product/prd-v2-draft.md` — no v2 changes.
- `docs/06-helpers/gaps-and-questions.md` — no new gaps found. All settings are accounted for.
- `docs/06-helpers/ideation-folder-structure.md` — no new files created.
- `docs/06-helpers/ideation-tracker.md` — historical key decisions log entries retain old §5.4.X references (correct — they are historical records).
