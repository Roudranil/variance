---
title: Ideation Diff
status: current
owner: pm
updated: 2026-04-21
---

# Ideation Diff — Session 2026-04-21 (v2 Feature Batch: UX + AI)

## 1. Files Modified

### `docs/01-product/prd-v2-draft.md`

- `last_updated` frontmatter bumped: `2026-04-15` → `2026-04-21`
- Appended **§26 Core UX and Visualization Enhancements** (new top-level section)
- Appended **§27 AI Features** (new top-level section)

#### §26 — Subsections added

| Subsection | Feature | New OQs |
|---|---|---|
| 26.1 | Calendar View | OQ-V2-15 |
| 26.2 | Tap Date to Enter Transaction | — |
| 26.3 | GitHub-Style Activity Heatmap | OQ-V2-16 |
| 26.4 | Periodic Reports (Yearly / Quarterly / Monthly / Weekly) | OQ-V2-17 |
| 26.5 | Daily / Monthly / Annual Passbook / Statement View | OQ-V2-18 |
| 26.6 | Transaction Title Templates by Category | — |
| 26.7 | Copying Transactions (two modes: today's date / original date) | — |
| 26.8 | Swap From/To in Transfers | — |
| 26.9 | Collapse and Expand Account Groups | OQ-V2-19 |

#### §27 — Subsections added

| Subsection | Feature | New OQs |
|---|---|---|
| 27.1 | HuggingFace as a BYOK Provider | OQ-V2-20, OQ-V2-21 |
| 27.2 | Global AI Feature Flag | — |
| 27.3 | AI Usage Tracking In-App | OQ-V2-22 |
| 27.4 | Pre-Defined AI Analysis Options | OQ-V2-23 |
| 27.5 | AI-Powered Title Suggestion (On the Fly) | OQ-V2-24, OQ-V2-25 |

#### Cross-references updated (within new sections only)

| Reference | Direction |
|---|---|
| §26.1 ← §26.2 | Calendar view is dependency for tap-to-enter |
| §24 ← §27.1 | HuggingFace extends §24 provider list |
| §24 ← §27.2 | Global flag is master switch over §24 opt-in |
| §24 ← §27.4 | Resolves OQ-V2-12 partially (pre-defined + free-form coexist) |
| §26.6 ← §27.5 | Static templates vs. AI-generated suggestions distinguished |

## 2. Files Unchanged This Session

- `docs/01-product/prd.md` — LOCKED, not touched
- `docs/01-product/ledger-entry.md` — not touched
- `docs/01-product/input-fields.md` — not touched
- `docs/01-product/technical-clarifications.md` — not touched
- `docs/02-technical/sds.md` — not touched
- `docs/02-technical/data-model.md` — not touched

## 3. New Open Questions Introduced

| ID | Section | Question |
|---|---|---|
| OQ-V2-15 | §26.1 | Calendar day cell indicator style: numeric amount vs. dot vs. count badge? |
| OQ-V2-16 | §26.3 | Heatmap intensity metric: count vs. absolute amount vs. net amount? |
| OQ-V2-17 | §26.4 | Reports: separate screen or time-scope filter on analytics screen? |
| OQ-V2-18 | §26.5 | Passbook: separate screen per account or mode within account detail? |
| OQ-V2-19 | §26.9 | Account group collapse state: per-session or persisted to storage? |
| OQ-V2-20 | §27.1 | HuggingFace: which models supported? Proposed: user specifies model ID. |
| OQ-V2-21 | §27.1 | HuggingFace API shape differs from OpenAI-compatible — provider abstraction impact? |
| OQ-V2-22 | §27.3 | AI usage tracking granularity: per-day vs. cumulative total only? |
| OQ-V2-23 | §27.4 | Can users edit/delete built-in AI prompt templates or only add custom ones? |
| OQ-V2-24 | §27.5 | AI title suggestion placement: inline pre-fill vs. chip below field? |
| OQ-V2-25 | §27.5 | Latency handling for AI title suggestion: loading indicator or defer on pause? |
