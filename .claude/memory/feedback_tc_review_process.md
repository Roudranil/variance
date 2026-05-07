---
name: TC Review Process — What Worked and What to Repeat
description: Process learnings from the 58-item PM/LE technical clarification review — format, patterns of ambiguity, division of responsibility
type: feedback
---
## Three-Round Structured Review Format Works Extremely Well
Round 1: LE produces categorized questions (A: vague, B: inconsistent, C: missing). Round 2: PM responds with dispositions (clarified, acknowledged, deferred, escalated, pushback). Round 3: LE gives verdicts (accepted, accepted with note, disagree). This produced 0 disagreements across 58 items and a clean referenceable document.
**How to apply:** Use this exact format for any future PM-LE specification review.

## Most Productive Question Patterns
1. "What happens in multi-currency?" — revealed EQ per-currency, category home-currency aggregation, threshold currency handling
2. "What happens at entity lifecycle boundaries?" — revealed pending-with-deleted-account, stacked remind-and-confirm, template deletion vs. archival
3. "What are the complete entity fields?" — revealed that PRD had no consolidated entity schemas
**How to apply:** Systematically ask these three question types when reviewing any product spec.

## PM Engineering Suggestions Need a Disclaimer
The PM sometimes suggests field names, data types, and schema patterns to communicate product intent. These are advisory only — the LE/SDS author owns all engineering decisions. A disclaimer was added to the TC doc to make this explicit.
**Why:** Prevents PM suggestions from being treated as requirements.

## Largest Spec Gap Category: Missing Specifications (60%)
35 of 58 items were Category C (missing specs), vs. 16 vague and 7 inconsistent. This means future PRD drafts should prioritize completeness (all entity interactions, edge cases, lifecycle transitions) over precision of already-specified features.
**How to apply:** When reviewing a PRD, focus more on "what's not here?" than "is what's here precise enough?"

## "Escalate to Founder" Pattern: Options + Recommendation
All 5 escalations presented 2-3 options with tradeoffs and a PM recommendation. The founder can make a quick decision without analyzing from scratch.
**How to apply:** Standard pattern for any decision crossing the PM's authority boundary.
