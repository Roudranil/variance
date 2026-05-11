---
name: work-items
description: Defines the four-level work-item hierarchy (Epic → Story → Task, plus Bug) used in docs/03-planning/. Covers ID conventions, heading format, body templates, and reference URL rules enforced by read-work-item.sh and read-references.sh. Load this skill whenever creating, reading, or referencing planning work items.
---

# Work Items Skill

## 1. Hierarchy Overview

Three planning levels plus one defect tracking level.

| Level | File                          | ID Format | Heading Pattern      | Definition                                                                                                                                  |
| ----- | ----------------------------- | --------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Epic  | `docs/03-planning/epics.md`   | `E-{N}`   | `## E-{N} — {Title}` | A broad, shippable vertical slice of the product. Corresponds to one or more feature-dag nodes or a full domain. Contains multiple Stories. |
| Story | `docs/03-planning/stories.md` | `S-{N}`   | `## S-{N} — {Title}` | One deliverable capability within an Epic. Framed as a user story ("as a … I want … so that …"). Maps to one PR.                            |
| Task  | `docs/03-planning/tasks.md`   | `T-{N}`   | `## T-{N} — {Title}` | An atomic unit of work (≤ 4 hours). Independently testable. Maps to one commit-level unit within a Story.                                   |
| Bug   | `docs/03-planning/bugs.md`    | `B-{N}`   | `## B-{N} — {Title}` | An observed defect against a shipped or in-progress feature. Standalone — not required to have a parent Story or Epic.                      |

- IDs are sequential integers starting at 1 (`E-1`, `E-2`, …)
- IDs are globally unique within each file
- IDs are never reused, renumbered, or resequenced

### 1.1 Relationship Rules

- Every Story must have exactly one parent Epic
- Every Task must have exactly one parent Epic and exactly one parent Story
- Orphan Stories and Tasks are not allowed
- Bugs are standalone; they MAY reference an Affected Epic or Affected Story but are not required to

---

## 2. Heading Convention

**This is a hard constraint required by `read-work-item.sh` and `read-references.sh`.**

### 2.1 Work Item Heading Format

```
## {ID} — {Title}
```

- Level: exactly `##` (H2)
- Separator: em dash `—` (U+2014) with one space on each side
- Example: `## E-3 — Currency Domain`

### 2.2 Subsection Heading Format

All subsections within a work item use `###` (H3). No deeper nesting is allowed within a work item body.

### 2.3 File Root Heading

Each planning file opens with exactly one H1:

```markdown
# Epics
```

```markdown
# Stories
```

```markdown
# Tasks
```

```markdown
# Bugs
```

No other H1 headings appear in these files.

---

## 3. Body Templates

### 3.1 Epic Template

```markdown
## E-N — Title

### Objectives

- broad, high-level bullet describing what this epic delivers

### Notes

- optional context, constraints, or flags

### Definition of Done

- measurable, observable completion condition

### References

- `Exact Heading Text As It Appears In TOC` (`docs/path/to/file.md`)
```

**Epic scope:** broad. Corresponds to one or more feature-dag nodes or a full domain.

### 3.2 Story Template

```markdown
## S-N — Title

**Parent Epic:** E-N — Epic Title

**Story:** As a {role}, I want to {action} so that {benefit}.

### Objectives

- detailed, precise bullet list of what this story delivers

### Notes

- optional

### Definition of Done

- testable, binary pass/fail conditions

### References

- `Exact Heading Text As It Appears In TOC` (`docs/path/to/file.md`)
```

**Story scope:** one deliverable capability within an epic. Maps to one PR.

### 3.3 Task Template

```markdown
## T-N — Title

**Parent Epic:** E-N
**Parent Story:** S-N

### Todo

- [ ] concrete, executable action item
- [ ] another action item

### Notes

- optional

### References

- `Exact Heading Text As It Appears In TOC` (`docs/path/to/file.md`)
```

**Task scope:** atomic (≤ 4 hours). Independently testable. Maps to one commit-level unit.

### 3.4 Bug Template

```markdown
## B-N — Short symptom description

**Affected Epic:** E-N *(optional — omit if cross-cutting or unknown)*
**Affected Story:** S-N *(optional — omit if unknown)*
**Severity:** critical | high | medium | low

**Symptom:** One sentence — what the user or system observes going wrong.

**Expected:** One sentence — what should happen instead.

### Repro Steps

1. Step one
2. Step two
3. Observe: …

### Root Cause

TBD *(fill in once diagnosed)*

### Todo

- [ ] Write a failing test that reproduces the bug
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Confirm test passes
- [ ] Regression-check adjacent behaviour

### Notes

*(optional)*

### References

- `Exact Heading Text As It Appears In TOC` (`docs/path/to/file.md`)
```

**Bug scope:** one observed defect. Fix maps to one `fix(<scope>):` commit. Severity and Repro Steps are mandatory. Root Cause may be `TBD` at creation time.

---

## 4. Reference Rules

### 4.1 Format

References appear in a `### References` subsection as a markdown unordered list using this exact format:

```markdown
### References

- `Exact Heading Text` (`docs/path/to/file.md`)
```

- The heading text inside backticks must be **copied verbatim** from the output of `./scripts/read-md.sh toc <file>`
- The file path inside the second pair of backticks is relative to the repository root
- Every work item MUST have a `### References` section with at least one entry
- No anchors, no GFM slugs, no invented titles — exact heading text only
- References can be to any file/section in a file in `01-product` or `02-technical`.

### 4.2 Allowed Heading Depth by Level

| Work Item | Allowed Heading Depth                                                      | Rationale                                                       |
| --------- | -------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Epic      | Top-level sections only (e.g. `1. Overview`, `4. Feature Nodes by Domain`) | Epics are broad; deep links are noise                           |
| Story     | Any heading level                                                          | Stories are targeted                                            |
| Task      | Deepest available heading                                                  | Tasks are maximally scoped; developer reads only what is needed |

### 4.3 How to Find the Exact Heading Text

1. Run `./scripts/read-md.sh toc <file>` to get the table of contents
2. Copy the heading text **exactly as it appears** in the TOC output — including numbers, punctuation, and capitalisation
3. Paste it verbatim between backticks in the reference entry

**Never invent or paraphrase a heading.** If the heading does not appear in the TOC, do not reference it.

### 4.4 Reference Examples by Level

**Epic reference (top-level section only):**

```markdown
- `1. Overview` (`docs/01-product/prd.md`)
- `4. Feature Nodes by Domain` (`docs/02-technical/feature-dag.md`)
```

**Story reference (any depth):**

```markdown
- `2.3 Database and Persistence` (`docs/02-technical/sds.md`)
- `3.2 Account Creation Flow` (`docs/02-technical/ux-flows.md`)
```

**Task reference (deepest available):**

```markdown
- `3.2.1 accounts table` (`docs/02-technical/data-model.md`)
- `INFRA-1 — Database Schema + Drift Setup` (`docs/02-technical/feature-dag.md`)
```

### 4.5 Reference rigor by work item

- Epics have a small list of high level references. This is because epics have a broad coverage.
- Stories have a slightly longer list of slightly lower level references contained within their parent epic's references. This is because a story is concerned with a specific area within the project.
- Tasks have a longer list of deepest level references within their parent story's references. Tasks must contain as many references as needed to give the developer a clear picture of what background information it needs to complete its task. It should be self sufficient, and the developer must not have to read some other source to understand something else.

---

## 5. Planning File Structure

### 5.1 File Layout

Each file must follow this exact structure:

```
# {Epics|Stories|Tasks}

## {ID} — {Title}

### {Subsection}
...

### References
- ...

---

## {ID} — {Title}
...
```

- A `---` horizontal rule separates consecutive work items (aids readability and script parsing)
- No content appears between the H1 and the first work item `##`
- No content appears after the last `---` except a trailing newline

### 5.2 ID Assignment

When adding new work items to an existing file:

1. Run `./scripts/read-md.sh toc docs/03-planning/{epics|stories|tasks|bugs}.md`
2. Find the highest existing ID number in the file
3. Assign the next sequential integer

Never skip numbers, never reuse numbers, never assign IDs out of order.

---

## 6. Helper Scripts

### 6.1 `read-work-item.sh`

Reads a single work item by ID from the appropriate planning file.

```bash
./scripts/read-work-item.sh --epic  E-1
./scripts/read-work-item.sh --story S-3
./scripts/read-work-item.sh --task  T-7
./scripts/read-work-item.sh --bug   B-1
```

Exit codes: `0` success, `1` invalid args, `2` file not found, `4` ID not found.

### 6.2 `read-references.sh`

Reads a Story, Task, or Bug work item, extracts its `### References` list, and returns the full text of each referenced section concatenated with annotations. No character or line limit is applied.

```bash
./scripts/read-references.sh --story S-3
./scripts/read-references.sh --task  T-7
./scripts/read-references.sh --bug   B-1
```

**Epics are not supported** by this script. Use `read-work-item.sh` to read an epic body directly.

Exit codes: `0` success, `1` invalid args or `--epic` used, `2` file not found, `4` ID not found, `5` referenced file not found.
