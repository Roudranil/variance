---
title: Ideation Diff
status: current
owner: le
updated: 2026-04-22
---

# Ideation Diff — Session 2026-04-22 (Feature DAG)

## 1. Files Modified

| File | Change type |
|------|-------------|
| `docs/02-technical/feature-dag.md` | Completed — §3 (Mermaid DAG + critical path), §5 (build phases), §6 (reference index), §7 (open questions), TOC filled |
| `docs/06-helpers/ideation-tracker.md` | Updated — Feature DAG row (2b) added |
| `docs/06-helpers/ideation-diff.md` | Overwritten (this file) |
| `docs/06-helpers/dag-parts/` | Deleted (staging files) |

## 2. Changes Made

- Feature DAG v1 completed: 57 nodes across 11 domains
- §3 Mermaid dependency diagram generated from all node dependency fields; HARD edges as solid arrows, SOFT as dashed
- §3.2 Critical path identified: 11-hop chain INFRA-1 → INFRA-7 → ACC-01/CAT-01 → TXN-01 → ACC-04 → TXN-05 → TXN-08 → HOME-01 → HOME-02
- §5 Build phases derived from dependency graph (Phase 0 through Phase 9); parallel execution within each phase documented
- §5.1 Critical path analysis table: top 10 nodes by downstream block count
- §6 Reference index: PRD section → node, TC → node, DM table → node
- §7 3 open questions/flags logged
- TOC placeholder filled with full section hierarchy
- Staging files (`docs/06-helpers/dag-parts/`) deleted

## 3. Open Questions Status

| ID | Status | Notes |
|----|--------|-------|
| OQ-SDS-SC-001 | Still open | `flutter_secure_storage` backup exclusion on Android API 31+; blocks SET-06 ship |
| OQ-SDS-SC-003 | Still open | CAMERA permission for photo attachments (TXN-04) |
| OQ-DAG-001 | New — needs SDS fix | SDS §2.8.4 contradicts TC-050; search scope must be corrected before TXN-08 or HOME-02 implementation starts |
