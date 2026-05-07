---
name: Always use the dedicated lead-engineer agent
description: When spinning up an LE agent, ALWAYS use subagent_type lead-engineer from .claude/agents/lead-engineer.md — never a generic agent with LE-like instructions.
type: feedback
---

When the founder says "LE" or "Lead Engineer" or asks for engineering analysis/consolidation, ALWAYS use the dedicated `lead-engineer` agent defined in `.claude/agents/lead-engineer.md` with `subagent_type: "lead-engineer"`.

**Why:** The founder explicitly created this agent with mandatory skills (engineering-lead, dart-flutter-patterns) and mandatory rules (dart/ coding-style, patterns, testing, security, hooks). A generic agent prompted to "act like an LE" does NOT load these skills and rules, producing inferior and inconsistent output. The founder was upset when this happened during the Cashew recon consolidation.

**How to apply:** Every time an LE agent is needed — whether for SDS authoring, architecture review, recon consolidation, or any engineering analysis — set `subagent_type: "lead-engineer"` in the Agent tool call. Never substitute a general-purpose agent with LE-flavored instructions. This applies to all future sessions, not just this one.
