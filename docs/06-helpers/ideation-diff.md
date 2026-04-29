---
title: Ideation Diff
status: current
owner: le
updated: 2026-04-28
---

# Ideation Diff — Session 2026-04-28 (Theming — Catppuccin + Typography)

## 1. Files Modified

| File | Change type |
|------|-------------|
| `docs/02-technical/sds.md` | Targeted edits — §2.14.1, §2.18.1, new §2.18.2, new §2.18.3 |
| `docs/06-helpers/ideation-tracker.md` | Key decisions row added |
| `docs/06-helpers/ideation-diff.md` | Overwritten (this file) |

## 2. Changes Made

### `docs/02-technical/sds.md`

- **§2.14.1** — Added `catppuccin_flutter ^1.0.0` to production dependency table
- **§2.18.1** — Updated `app_settings.color_scheme_mode` valid values: `dynamic | custom | catppuccin`
- **§2.18.2** (new) — Catppuccin color scheme mode spec:
  - `catppuccin` is a third first-class `color_scheme_mode` value
  - Light → Latte; Dark → Mocha; Frappé/Macchiato deferred to v2
  - `ColorScheme` seeded from `flavour.mauve`
  - `VarianceColors` token mapping: `incomeAmount→green`, `expenseAmount→red`, `warningAmount→peach`, `accentPastel→lavender`
  - Activation logic table (all three modes side-by-side)
- **§2.18.3** (new) — `ThemeExtension<VarianceTypography>` spec:
  - 3 font family fields (`displayFont`, `bodyFont`, `numericFont`) as `String` placeholders
  - 13 named `double` font size constants covering all app use cases
  - Constraint: no raw numeric font size literals in widgets
  - Always registered in `ThemeData.extensions` regardless of color scheme mode

## 3. Open Questions Status

| ID | Status | Notes |
|----|--------|-------|
| OQ-SDS-SC-001 | Still open | `flutter_secure_storage` backup exclusion on Android API 31+ |
| OQ-SDS-SC-003 | Still open | CAMERA permission for photo attachments (TXN-04) |
| OQ-DAG-001 | Still open | SDS §2.8.4 contradicts TC-050; search scope must be corrected before TXN-08/HOME-02 |
