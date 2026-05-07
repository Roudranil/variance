---
name: Visual testing is a first-class testing strategy
description: Founder requires visual testing pipeline (golden tests, Widgetbook, integration screenshots, design tokens) as part of the test strategy. Not optional.
type: project
---

The founder is the visual reviewer — dev agents can't "see" the app. Visual testing is the bridge.

**Decided (2026-04-15):**
- Golden tests are mandatory for all widgets and screens (Flutter-native `matchesGoldenFile()`)
- Design tokens file (animation durations, spacing, colors, curves) to be created during SDS
- Integration test screenshots at each step of user flows
- Widgetbook or equivalent for widget state catalog (all states: empty, loading, error, populated, dark/light)
- Founder workflow: screenshots + annotations in repo → translated to code guidance

**Why:** The founder sees the app visually; AI agents see code. Without visual testing, there's no way to validate "look and feel" programmatically. Cashew has zero visual tests — we treat this as a competitive advantage in quality control.

**How to apply:** The LE must include visual testing in the test strategy document. Golden tests should be part of the CI pipeline. Design tokens should be a first-class SDS deliverable. Every PR that touches UI must include updated golden files.
