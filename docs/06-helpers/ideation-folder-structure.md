---
name: Ideation Folder Structure
status: approved
owner: pm
created: 2026-04-13
last_updated: 2026-04-13
depends_on: []
outputs_to: []
---

# Variance — Docs Folder Structure

## Tree

```
docs/
├── frontmatter-schema.md           # Schema reference for all doc frontmatter
├── 01-product/                     # Product definition artifacts
│   ├── prd.md
│   ├── prd-v2-draft.md
│   └── ledger-entry.md
├── 02-technical/                   # Technical specifications
│   ├── feature-dag.md
│   ├── sds.md
│   ├── data-model.md
│   ├── api-contracts.md
│   ├── architecture-decision-records.md
│   └── ux-flows.md
├── 03-planning/                    # Execution planning
│   ├── task-breakdown.md
│   └── sprint-plans.md
├── 04-implementation/              # Sprint-scoped delivery artifacts
│   └── sprint{n}/
├── 05-quality/                     # Quality and security
│   ├── tests.md
│   └── security.md
└── 06-helpers/                     # Process and reference aids
    ├── ideation-tracker.md
    ├── ideation-diff.md            # overwritten with exact changes done in a single ideation session
    ├── gaps-and-questions.md
    └── ideation-folder-structure.md
```

## Folder Reference

| Folder               | Purpose                          | Owner     | Document Types                                        |
| -------------------- | -------------------------------- | --------- | ----------------------------------------------------- |
| `01-product/`        | Product definition               | pm        | PRD, ledger entry cases, product decisions            |
| `02-technical/`      | Technical specifications         | architect | SDS, data model, API contracts, UX flows, feature DAG |
| `03-planning/`       | Execution planning               | tpm       | Task breakdown, sprint plans                          |
| `04-implementation/` | Sprint-scoped delivery artifacts | tpm/dev   | Per-sprint notes, changelogs                          |
| `05-quality/`        | Quality and security             | architect | Test specs, security review docs                      |
| `06-helpers/`        | Process and reference aids       | all       | Ideation tracker, gap analysis, diff logs             |

## Document Index

| Document           | Path                                           | Purpose                                  |
| ------------------ | ---------------------------------------------- | ---------------------------------------- |
| PRD                | `docs/01-product/prd.md`                       | What we're building and why              |
| Ledger Entry Cases | `docs/01-product/ledger-entry.md`              | Authoritative posting case reference     |
| PRD v2 Draft       | `docs/01-product/prd-v2-draft.md`              | All deferred v2 features and decisions   |
| Frontmatter Schema | `docs/frontmatter-schema.md`                   | Schema reference for all doc frontmatter |
| Folder Structure   | `docs/06-helpers/ideation-folder-structure.md` | Docs folder taxonomy                     |
| Ideation Tracker   | `docs/06-helpers/ideation-tracker.md`          | Phase status, open questions, decisions  |
| Gaps & Questions   | `docs/06-helpers/gaps-and-questions.md`        | UX pre-work and feature gap analysis     |
| SDS                | `docs/02-technical/sds.md`                     | How we're building it                    |
| Feature DAG        | `docs/02-technical/feature-dag.md`             | Feature dependency graph                 |
| Data Model         | `docs/02-technical/data-model.md`              | Schema and entity design                 |
| API Contracts      | `docs/02-technical/api-contracts.md`           | Internal interfaces                      |
| UX Flows           | `docs/02-technical/ux-flows.md`                | User interaction specification           |
| Task Breakdown     | `docs/03-planning/task-breakdown.md`           | Task breakdown and dependencies          |
| Sprint Plans       | `docs/03-planning/sprint-plans.md`             | Sprint-level delivery plans              |