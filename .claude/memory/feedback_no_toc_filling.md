---
name: Never fill in TOC for markdown files
description: Do not write or fill in Tables of Contents in markdown files. Generate with read-md.sh or tell founder to do it.
type: feedback
originSessionId: bb515388-01b3-471b-96d0-b17f67227faf
---
Never write a Table of Contents into any markdown file — not manually, not in prompts to subagents.

**Why:** Founder controls TOC generation. It can be generated on demand via `./scripts/read-md.sh toc <file>` or a VS Code shortcut. Writing it wastes tokens and ignores explicit instruction.

**How to apply:** Do not include TOC instructions in subagent prompts. Do not write TOC content into files. If a doc needs a TOC, tell the founder to generate it themselves.
