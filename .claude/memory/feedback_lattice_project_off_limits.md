---
name: Lattice GitHub project is off-limits
description: Never interact with the Lattice GitHub project (#2) under any circumstances — it belongs to a different repo
type: feedback
---

NEVER touch the GitHub project named `Lattice` (project #2, ID: `PVT_kwHOA51EZs4BOMMG`) on the `Roudranil` account.

**Why:** It belongs to a completely different repo/context. Only the `variance` project (#3, ID: `PVT_kwHOA51EZs4BUfV9`) is in scope for this workspace.

**How to apply:** Any time you interact with GitHub Projects — via MCP tools (`projects_list`, `projects_get`, `projects_write`) or via `gh-cc-var project` CLI — only ever target project number `3` or filter by name `variance`. If you ever see `Lattice` appear in a result, skip it entirely.
