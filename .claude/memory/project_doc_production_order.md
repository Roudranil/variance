---
name: Variance — Technical Document Production Order
description: Correct order to produce technical docs (SDS → Feature DAG → UX Flows → API Contracts → UI → Tests) and what belongs in each
type: project
---

## Document Production Order

1. **SDS** — architecture foundation; everything else is downstream
2. **Feature DAG** — dependency map and build order across features
3. **UX Flows** — screen inventory, every state and transition, conditional behavior ("if X show Y")
4. **API Contracts** — internal interfaces (repositories, services, ViewModels) that support the flows
5. **UI (Figma)** — visual form for every state defined in UX Flows
6. **Tests** — acceptance criteria derived from UX Flows + API Contracts

**Why:** Each doc depends on the previous. UX Flows and API Contracts have a tight feedback loop — expect one iteration between them before locking.

---

## What the SDS Contains

| Section | Contents |
|---|---|
| Architecture Overview | Layers, how they connect, data flow direction |
| Tech Stack | Every package/library, with rationale |
| Data Model | All entities, fields, types, relationships, constraints — full schema |
| State Management | Which pattern, which classes own which state |
| Navigation Structure | All named routes, GoRouter config shape |
| Storage Strategy | DB schema, table names, indexes, migration plan |
| Error Handling Strategy | How errors propagate through layers — policy level |
| Performance Constraints | Concrete numbers where they exist |
| Security Considerations | Local encryption, backup exposure, biometric lock |
| Cross-cutting Concerns | Logging, analytics, crash reporting |

**SDS does NOT contain:** screen layouts, conditional UI behavior, field-level validation rules, Figma specs.

---

## What UX Flows Contains (not SDS or UI)

"Transaction window must contain X, if Y happens show Z" — this all goes in **UX Flows**.

UX Flows covers:
- What screens/sheets/dialogs exist and what components are on them
- Every conditional state: loading, empty, error, success, partial
- Every transition trigger and validation behavior
- Edge cases and empty states

UI (Figma) then gives visual form to each state UX Flows defines.

**Why:** SDS = how the system is built. UX Flows = how the user interacts. UI = what it looks like.
