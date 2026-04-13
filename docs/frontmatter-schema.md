---
name: Frontmatter Schema
status: approved
owner: pm
created: 2026-04-13
last_updated: 2026-04-13
depends_on: []
outputs_to: []
---

# Variance — Frontmatter Schema

Every document in the `docs/` hierarchy must include a YAML frontmatter block at the top of the file. This document defines the schema for that block.

---

## Schema

```yaml
---
name: <string>
version: <semver>
status: <enum>
owner: <enum>
created: <date>
last_updated: <date>
depends_on: [<relative-path>, ...]   # upstream documents
outputs_to: [<relative-path>, ...]   # downstream documents
---
```

---

## Field Reference

| Field          | Type       | Required | Description |
|----------------|------------|----------|-------------|
| `name`         | string     | yes      | Human-readable document title. Should match the document's H1 heading. |
| `status`       | enum       | yes      | Current lifecycle state. See allowed values below. |
| `owner`        | enum       | yes      | Role responsible for authoring and maintaining this document. See allowed values below. |
| `created`      | date       | yes      | ISO 8601 date (`YYYY-MM-DD`) when the document was first created. Never changes after creation. |
| `last_updated` | date       | yes      | ISO 8601 date (`YYYY-MM-DD`) of the most recent substantive change. Update on every meaningful edit. |
| `depends_on`   | string[]   | yes      | Relative paths (from `docs/`) to upstream documents that must be complete before this document can be authored. Use `[]` if there are no dependencies. |
| `outputs_to`   | string[]   | yes      | Relative paths (from `docs/`) to downstream documents that are unblocked or directly informed by this document. Use `[]` if no downstream. |

---

## Allowed Values

### `status`

| Value          | Meaning |
|----------------|---------|
| `not started`  | Document has not been begun. Placeholder only. |
| `blocked`      | Cannot proceed — upstream dependency is incomplete. |
| `in progress`  | Actively being authored or revised. |
| `under review` | Content complete; awaiting stakeholder sign-off. |
| `approved`     | Signed off. Content is authoritative and stable. |
| `deprecated`   | Superseded by a newer document or decision. Retained for reference only. |

### `owner`

| Value      | Responsible Role |
|------------|------------------|
| `founder`  | Final decision-maker; owns product vision and sign-off. |
| `pm`       | Product manager; owns product definitions, PRD, gap analysis, ideation artifacts. |
| `tpm`      | Technical program manager; owns execution planning, sprint planning, issue hierarchy. |
| `dev`      | Software engineer; owns implementation artifacts, per-sprint notes. |
| `reviewer` | Code or design reviewer; owns quality and security review documents. |

---

## Path Convention for `depends_on` / `outputs_to`

Paths are relative to the `docs/` root directory. Examples:

```yaml
depends_on: [01-product/prd.md, 01-product/ledger-entry.md]
outputs_to: [02-technical/sds.md, 02-technical/ux-flows.md]
```

---

## Example

```yaml
---
name: System Design Spec
status: not started
owner: tpm
created: 2026-04-13
last_updated: 2026-04-13
depends_on: [01-product/prd.md, 01-product/ledger-entry.md]
outputs_to: [02-technical/api-contracts.md, 03-planning/task-breakdown.md]
---
```
