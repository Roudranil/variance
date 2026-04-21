---
title: Ideation Diff
status: current
owner: le
updated: 2026-04-21
---

# Ideation Diff — Session 2026-04-21 (SDS §5 Cross-cutting Concerns)

## 1. Files Modified

### `docs/02-technical/sds.md`

- Appended **§5 Cross-cutting Concerns** (new top-level section)

#### §5 — Subsections added

| Subsection | Content |
|---|---|
| 5.1 Logging | Three-subsystem model: dev logs (transient), user action log (persistent), error/crash log (persistent) |
| 5.1.1 Dev Logs | `dart:developer log()` only; 4 tags; release-silent via R8/assert |
| 5.1.2 User Action Log | Append-only audit trail; `filesDir/logs/actions/`; 4-field format; 2 MB/5 files/10 MB rotation; excluded from Android auto-backup |
| 5.1.3 Error / Crash Log | Unhandled error capture; `filesDir/logs/errors/`; timestamp+type+stack+version; same rotation; user-export only; no remote TX |
| 5.2 Analytics | Zero analytics — prohibited (PRD NF-1, §1.6.5) |
| 5.3 Crash Reporting | No remote crash reporting; local error log is sole mechanism |
| 5.4 i18n / l10n | English-only v1; `NumberFormat` + `intl` for currency/date; RTL via `Directionality` |
| 5.5 Accessibility | WCAG 2.1 AA; font scaling to 200%; semantic labels; TalkBack best-effort v1; complex widget audit deferred v2 |
| 5.6 Theme and Dark Mode | Material 3 light+dark; dynamic color API 31+ with OEM fallback (TC-048); centralized `ThemeData` |

### `docs/06-helpers/ideation-tracker.md`

- SDS deliverable row updated: Sections 1–5 complete as of 2026-04-21.

## 2. Files Unchanged This Session

- `docs/01-product/prd.md` — LOCKED, not touched
- `docs/01-product/technical-clarifications.md` — not touched
- `docs/02-technical/data-model.md` — not touched

## 3. New Open Questions Introduced

None this session.
