---
name: Variance — Project Overview
description: What Variance is, its core thesis, tech stack, and version roadmap
type: project
originSessionId: d4b861ae-35f3-4099-b916-ebbe4819ba4c
---
Variance is a personal finance & expense tracker for Android. The core differentiator: no existing Android app combines all three of (1) local/offline storage, (2) double-entry bookkeeping, and (3) modern Material You (Material Design 3) UI. Variance fills that gap.

**Core architecture:** Double-entry bookkeeping (DEB) runs internally as the financial engine. The UI abstracts it entirely — users only see income / expense / transfer. No "debit" or "credit" language exposed.

**Tech stack:** Flutter/Dart (inferred from project conventions, to be confirmed in SDS).

**License:** MIT. All dependencies must be permissively licensed (MIT, Apache 2.0, MPL 2.0).

**Platform:** Android only. Minimum API 31 (Android 12). Offline-first — zero internet required for any core v1 feature.

**Version roadmap:**
- v1: Core — accounts, transactions, categories, budgets, recurring, installments, settings, home summary
- v2: Advanced — trends/dashboards/analytics, data management (backup/restore, CSV), savings goals, tags, audit view
- v3: Predictive — ML insights, OCR, advanced analytics, Drive backup

**Why:** To be fully local, open-source, free, with no telemetry, no ads, no cloud sync — ever.

**How to apply:** Frame all suggestions around offline-first, DEB correctness, Material 3 UX, and Flutter/Dart conventions.
