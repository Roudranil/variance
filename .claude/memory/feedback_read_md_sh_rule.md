---
name: Always use read-md.sh for markdown files
description: Lead-engineer and all subagents must use read-md.sh, never Read tool or cat, for any .md file
type: feedback
---

Always use `./scripts/read-md.sh` to read markdown files — never the `Read` tool, `cat`, `head`, or any shell equivalent.

**Why:** Markdown docs are thousands of lines / tens of thousands of tokens. Reading them directly bloats context. The `read-md.sh` script lets you read only the TOC or a targeted section.

**How to apply:**
- First call: `./scripts/read-md.sh toc <file.md>` to get the heading structure
- Then: `./scripts/read-md.sh section <file.md> "<heading>" --with-subsections` for specific content
- This applies to ALL agents (lead-engineer, technical-program-manager, software-engineer, etc.) and to the orchestrator itself
- When briefing subagents, explicitly include this instruction in the prompt
