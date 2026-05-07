---
name: Versioning is founder-controlled
description: Never assign or decide version numbers — all versioning is controlled by the founder via the `version` file at the repo root
type: feedback
---

Never assign, bump, or decide version numbers on any document or artifact. All files follow a single uniform version controlled by the `version` file at the repo root.

**Why:** The PM took liberty in bumping PRD versions (e.g., v0.5.0 → v0.6.0) and assigning versions to new files (e.g., v0.1.0 for the v2 draft) without founder approval. This was explicitly not granted and the founder was displeased.

**How to apply:**
- To know the current version: read the `version` file.
- To know the next version: ask the founder. They will update the `version` file.
- Remove `version` from all document frontmatter — it does not belong there.
- Never reference version bumps in commit messages, tracker entries, or diff logs without the founder having set it first.
- If you wrote "PRD bumped to vX.Y.Z" in a session, you overstepped — the founder decides when versions change.
