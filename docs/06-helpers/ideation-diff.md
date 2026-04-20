---
name: Ideation Diff
status: current
owner: architect
created: 2026-04-20
last_updated: 2026-04-20
depends_on: []
outputs_to: []
---

# Ideation Diff — Session 2026-04-20

> This file records the exact changes made in this ideation session. It is overwritten each session and used as the basis for commit messages.

---

## 1. Files Created

### `docs/02-technical/sds.md` (new file)

System Design Spec created with the Architecture Overview section (Section 1). This is the first section of the SDS. All subsequent SDS sections are future work.

#### Content produced

- **Section 1.1 — Architectural Style:** Three-layer Clean Architecture (Presentation, Domain, Data) with Infrastructure cross-cut. Rationale: DEB engine isolation, presentation independence, testability.
- **Section 1.1.3 — State Management Choice:** Riverpod selected. Decision table comparing Riverpod vs BLoC/Cubit vs ValueNotifier across testability, compile-time safety, reactivity granularity, boilerplate, and DI integration.
- **Section 1.2 — Layer Diagram:** ASCII diagram showing all four layers with allowed dependency directions. Dependency direction rule stated explicitly: `Presentation → Domain ← Data`.
- **Section 1.3 — Layer Definitions:** Full specification for each layer — responsibilities, allowed imports, prohibited imports, key rules. Includes navigation route table (GoRouter + ShellRoute) and domain service inventory (LedgerEngine, BalanceCalculator, PostingCaseSelector). ORM choice (Drift) documented with rationale. Infrastructure service table with package names.
- **Section 1.4 — Data Flow:** Four end-to-end flow traces: (1) user-initiated transaction write, (2) reactive read via drift Stream → Riverpod → widget, (3) background recurring auto-post via WorkManager, (4) account balance read as DB aggregate.
- **Section 1.5 — Module and Feature Boundaries:** Full folder structure for `lib/` across domain, data, presentation, and infrastructure. Feature boundary rules and domain boundary rules stated.
- **Section 1.6 — Key Architectural Constraints:** Eight constraints with architectural implications: offline-first, ACID atomicity, domain zero-Flutter dependency, Android-only Material 3, zero telemetry, universal soft-delete, transaction immutability/correction model, hybrid scheduling.
- **Section 1.7 — Explicit Out-of-Scope:** Twelve explicitly excluded concerns (cloud sync, auth server, REST API, iOS/desktop, CRDT, bank APIs, telemetry, IAP, remote push, etc.).

#### TC items resolved in this section

- **TC-033** (error handling for failed ledger operations): Resolved — ACID atomicity at DB layer (drift transaction), domain-typed exception thrown on failure, UI preserves form state, no silent failures.
- **TC-041** (recurring transaction scheduling mechanism): Resolved — Hybrid model: WorkManager for catch-up sweep + flutter_local_notifications with exact alarms for time-critical notification delivery.

---

## 2. Files Modified

### `docs/06-helpers/ideation-tracker.md`

- `last_updated` updated from `2026-04-14` to `2026-04-20`.
- `> **Last Updated:**` header updated to `2026-04-20`.
- Deliverable Checklist row 2 (SDS) updated from "Ready to Start" to "In Progress — Architecture Overview drafted".
- Key Decisions Log: new row added (2026-04-20) capturing 8 architectural decisions made this session.
- Readiness Gate: PRD item marked complete (was pending); SDS item updated to reflect in-progress state with Architecture Overview complete.
- Document Index: SDS row updated from "Ready to Start" to "In Progress — Architecture Overview complete".

---

## 3. Architectural Decisions Made This Session

| Decision | Rationale |
|----------|-----------|
| Clean Architecture (3-layer) | Isolate DEB engine from Flutter and SQLite; enforce testable layer boundaries |
| Riverpod for state management | Provider graph doubles as DI root; fine-grained select watchers for 10k-transaction render target |
| Drift for SQLite ORM | Reactive Stream queries, type-safe Dart, compile-time schema, built-in migrations |
| GoRouter + ShellRoute for navigation | Three-tab bottom nav with per-tab stack; deep modals hide shell |
| Domain layer: zero Flutter dependency | DEB rules tested as pure Dart; CI-enforced structural constraint |
| Balance as DB aggregate (not cached column) | Eliminates balance-drift bugs; meets <500ms target via indexing |
| Hybrid scheduling (WorkManager + exact alarms) | WorkManager for catch-up; exact alarms only for user-visible notification events per Android OS guidelines |
| ACID + domain-typed exception error model | Atomicity at DB; typed failures surfaced to UI; form state preserved on failure |

---

## 4. TC Items Resolved

| TC ID | Resolution |
|-------|-----------|
| TC-033 | Error handling: ACID atomicity in drift transaction; domain-typed exception on failure; UI form state preserved; no silent failures. |
| TC-041 | Scheduling: hybrid WorkManager (catch-up sweep) + flutter_local_notifications with exact alarms (notification delivery). |
