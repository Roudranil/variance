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

| Folder               | Purpose                           | Owner    | Document Types                                          |
|----------------------|-----------------------------------|----------|---------------------------------------------------------|
| `01-product/`        | Product definition                | pm       | PRD, ledger entry cases, product decisions              |
| `02-technical/`      | Technical specifications          | tpm/dev  | SDS, data model, API contracts, UX flows, feature DAG   |
| `03-planning/`       | Execution planning                | tpm      | Task breakdown, sprint plans                            |
| `04-implementation/` | Sprint-scoped delivery artifacts  | dev      | Per-sprint notes, changelogs                            |
| `05-quality/`        | Quality and security              | reviewer | Test specs, security review docs                        |
| `06-helpers/`        | Process and reference aids        | pm       | Ideation tracker, gap analysis, diff logs               |
