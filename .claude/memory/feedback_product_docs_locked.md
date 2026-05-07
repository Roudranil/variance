---
name: Product docs are locked after PRD sign-off
description: All files in docs/01-product/ are frozen as of 2026-04-14. No edits without formal founder-approved change request.
type: feedback
---
All documents in `docs/01-product/` are **locked** after founder sign-off on 2026-04-14. This includes:
- `prd.md`
- `ledger-entry.md`
- `input-fields.md`
- `prd-v2-draft.md`
- `technical-clarifications.md`

**Why:** The founder explicitly locked these after PRD sign-off. They are the authoritative product specification that downstream work (SDS, UX Flows, API Contracts, implementation) must conform to.

**How to apply:** Never edit files in `docs/01-product/` unless the founder explicitly authorizes a change request. If a conflict is discovered during SDS or implementation, surface it to the founder — do not silently modify the product docs. Read them freely; write to them never.
