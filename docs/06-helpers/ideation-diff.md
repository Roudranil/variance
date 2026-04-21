---
title: Ideation Diff
status: current
owner: le
updated: 2026-04-21
---

# Ideation Diff — Session 2026-04-21 (SDS §4 + §5 Verification)

## 1. Files Modified

| File | Change type |
|------|-------------|
| `docs/02-technical/sds.md` | Targeted edits to §4 and §5 only |
| `docs/06-helpers/ideation-diff.md` | Overwritten (this file) |

## 2. Changes Made

### §4.3.4 PIN Recovery

- Added: "If no device security configured: user directed to OS Settings to set it up before PIN reset is permitted."
- Source: PRD §5.4.6.3 step 3 (previously omitted).

### §4.6 Dev Log Hygiene

- Removed: `firebase_crashlytics (opt-in flavour)` line — Crashlytics is explicitly prohibited by PRD NF-1 and §5.3. Inconsistency removed.
- Replaced with: reference to §5.3 prohibition.

### §4.7 Persistent Log Files

- Resolved OQ-SDS-SC-002: user action log is in v1 scope (§5.1.2 fully specifies it). OQ removed.
- Updated table: "if implemented" → confirmed v1 scope with §5.1.2/§5.1.3 references.
- Updated paths: `filesDir/logs/` → `filesDir/logs/actions/` and `filesDir/logs/errors/` (consistent with §5.1.2/§5.1.3).
- Replaced stale OQ bullet with cross-reference to §5.1 specs.

### §5.7 Dependency Licensing (new)

- Added §5.7 to cover PRD NF-6 (MIT license; permissive deps only).
- Gap: NF-6 had no coverage in §4 or §5.

### §5.8 Self-Contained Assets (new)

- Added §5.8 to cover PRD NF-11 (all assets bundled; zero runtime asset calls).
- Gap: NF-11 had no coverage in §4 or §5.

## 3. Sources Verified

| Source | Sections checked |
|--------|-----------------|
| PRD | §5.4.6, §5.4.11, §6 (NF-1–NF-11) |
| Technical Clarifications | TC-007, TC-048, TC-054 |
| Competitive Analysis | §6.1–§6.3 (threat model, v1 must-haves) |
| Ledger Entry Cases | §11.2–§11.3 (void/reversal, photo deletion) |
| Input Fields | §2.2 (encrypted fields), §1.4 (validation) |
| Data Model | §3.2 (account_details), §5.1 (attachments), §11 (audit) |

## 4. Open Questions Status

| ID | Status | Notes |
|----|--------|-------|
| OQ-SDS-SC-001 | Still open | `flutter_secure_storage` backup exclusion on API 31+ |
| OQ-SDS-SC-002 | **Resolved** | User action log confirmed v1 scope in §5.1.2; removed from §4.7 |
| OQ-SDS-SC-003 | Still open | CAMERA permission for photo attachments |
