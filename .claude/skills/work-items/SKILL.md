---
name: work-items
description: Defines the three-level work-item hierarchy (Epic → Story → Task) used in docs/03-planning/. Covers ID conventions, heading format, body templates, and reference URL rules enforced by read-work-item.sh and read-references.sh. Load this skill whenever creating, reading, or referencing planning work items.
---

# Work Items Skill

## 1. Hierarchy Overview

Three levels only. No other levels exist.

| Level | File                          | ID Format | Heading Pattern      |
| ----- | ----------------------------- | --------- | -------------------- |
| Epic  | `docs/03-planning/epics.md`   | `E-{N}`   | `## E-{N} — {Title}` |
| Story | `docs/03-planning/stories.md` | `S-{N}`   | `## S-{N} — {Title}` |
| Task  | `docs/03-planning/tasks.md`   | `T-{N}`   | `## T-{N} — {Title}` |

- IDs are sequential integers starting at 1 (`E-1`, `E-2`, …)
- IDs are globally unique within each file
- IDs are never reused, renumbered, or resequenced

### 1.1 Relationship Rules

- Every Story must have exactly one parent Epic
- Every Task must have exactly one parent Epic and exactly one parent Story
- Orphan Stories and Tasks are not allowed

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

- [Section Title](docs/path/to/file.md#anchor)
```

**Epic scope:** broad. Corresponds to one or more feature-dag nodes or a full domain.

### 3.2 Story Template

```markdown
## S-N — Title

**Parent Epic:** E-N — Epic Title

### Objectives

- detailed, precise bullet list of what this story delivers

### Notes

- optional

### Definition of Done

- testable, binary pass/fail conditions

### References

- [Section Title](docs/path/to/file.md#heading-anchor)
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

- [Section Title](docs/path/to/file.md#deepest-available-anchor)
```

**Task scope:** atomic (≤ 4 hours). Independently testable. Maps to one commit-level unit.

---

## 4. Reference URL Rules

### 4.1 Structure

References appear in a `### References` subsection as a markdown unordered list of URLs:

```markdown
### References

- [Display Title](relative/path/to/file.md)
- [Display Title](relative/path/to/file.md#heading-anchor)
```

- Paths are relative to the repository root (not the document location)
- Every work item MUST have a `### References` section with at least one entry
- Display title must match or closely describe the heading or file being referenced

### 4.2 Allowed Heading Depth by Level

| Work Item | Allowed Anchor Depth                                                                                           | Rationale                                                       |
| --------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Epic      | Top-level section only — anchors with a single path segment (e.g. `#1-overview`, `#4-feature-nodes-by-domain`) | Epics are broad; deep links are noise                           |
| Story     | Any heading level (`##` and below)                                                                             | Stories are targeted                                            |
| Task      | Deepest available heading level                                                                                | Tasks are maximally scoped; developer reads only what is needed |

### 4.3 Anchor Slug Convention

Anchors follow GitHub-Flavoured Markdown (GFM) rules:

- All characters lowercased
- Spaces replaced with hyphens
- All non-alphanumeric characters **except hyphens** are stripped
- Leading and trailing hyphens trimmed

**Examples:**

| Heading text                  | Anchor                     |
| ----------------------------- | -------------------------- |
| `## 2. Infrastructure`        | `#2-infrastructure`        |
| `### 3.2.1 Accounts Table`    | `#321-accounts-table`      |
| `## INFRA-1 — Database Setup` | `#infra-1--database-setup` |
| `### 4.1 Accounts Domain`     | `#41-accounts-domain`      |

> **Note:** The `read-references.sh` script derives a search pattern from the anchor by replacing hyphens with spaces and passing the result to `read-md.sh --grep`. Anchors must be deterministic. Avoid Unicode punctuation inside headings; use ASCII hyphens or numbered prefixes.

### 4.4 Reference Examples by Level

**Epic reference (top-level section only):**

```markdown
- [PRD — Overview](docs/01-product/prd.md#1-overview)
- [SDS — Feature Domains](docs/02-technical/sds.md#4-feature-domains)
```

**Story reference (any depth):**

```markdown
- [SDS § 2.1 Database Layer](docs/02-technical/sds.md#21-database-layer)
- [UX Flows § 3.2 Account Creation](docs/02-technical/ux-flows.md#32-account-creation)
```

**Task reference (deepest available):**

```markdown
- [Data Model § 3.2.1 accounts table](docs/02-technical/data-model.md#321-accounts-table)
- [API Contracts § 4.1.2 createAccount](docs/02-technical/api-contracts.md#412-createaccount)
```

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

1. Run `./scripts/read-md.sh toc docs/03-planning/{epics|stories|tasks}.md`
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
```

Exit codes: `0` success, `1` invalid args, `2` file not found, `4` ID not found.

### 6.2 `read-references.sh`

Reads a Story or Task work item, extracts its `### References` list, and returns the full text of each referenced section concatenated with annotations. No character or line limit is applied.

```bash
./scripts/read-references.sh --story S-3
./scripts/read-references.sh --task  T-7
```

**Epics are not supported** by this script. Use `read-work-item.sh` to read an epic body directly.

Exit codes: `0` success, `1` invalid args or `--epic` used, `2` file not found, `4` ID not found, `5` referenced file not found.
