---
name: Anonymize competitive research in official docs
description: Never mention Cashew by name in official docs. Frame as "open-source finance tracker" research. Raw recon stays in docs/enemy-recon/ (internal). Sanitized output goes to official docs folders.
type: feedback
---

When moving competitive intelligence into official documentation (docs/02-technical/ or elsewhere):

1. **Never name Cashew** in official docs. Use "existing open-source finance trackers" or "current market implementations."
2. **Raw recon stays in `docs/enemy-recon/`** — internal reference only, can name Cashew freely.
3. **References section** should list Cashew alongside other apps (Money Manager, GnuCash, Firefly III, etc.) to frame as broad competitive research, not a targeted analysis.
4. **Frame patterns as** "observed in production finance apps" or "common patterns in open-source expense trackers."

**Why:** The founder doesn't want official product/technical docs to reveal that Variance is specifically studying Cashew. If someone reads the docs, it should look like standard competitive research across the market.

**How to apply:** Any time competitive findings move from enemy-recon/ into official docs, anonymize all Cashew-specific references. Keep the raw intel intact in enemy-recon/ for internal use.
