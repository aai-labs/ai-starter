---
name: task-delivery
description: Behavior-first delivery workflow for big, ambitious changes. Use for major new functionality, significant flow changes, and architecture-sensitive refactors that warrant explicit planning, approval gates, and verification. Not for small or routine work.
---

# Task Delivery

Drives big, ambitious work through three approval gates, then a fixed implementation and verification sequence.

## When to use

Use this skill **only for large, ambitious tasks** — major new functionality, significant flow or interface changes, or architecture-sensitive refactors where a mistake is expensive and the design is worth aligning on first.

Skip it for everything else:

- **Routine or small changes** — implement directly.
- **Bug fixes** — add a failing regression test, implement, verify. No gates needed.

When a task is genuinely substantial and you're unsure, lean toward using the skill.

## Read first

Read `AGENTS.md` (or the project's equivalent conventions doc) and any existing task/architecture docs before starting. When relevant, also read the existing tests and modules closest to the change so specs and plans match real patterns.

When writing any code, follow `AGENTS.md` and the conventions of the surrounding codebase for style, naming, structure, and patterns. Match what's already there rather than introducing new conventions.

## Workflow

Create a planning folder for the task (e.g. `docs/planning/<task-slug>/`), then move through three gates. **Stop and request explicit approval at each gate before continuing.** Do not start implementation until all three are approved.

**Gate 1 — Backend spec.** Capture the problem, scope, risks, and status in `README.md`. Draft backend behavior scenarios in `backend-spec.md`.
> "Backend behavior spec is ready in `<planning>/backend-spec.md`. Please review before I draft the frontend spec."

**Gate 2 — Frontend spec.** Draft frontend behavior scenarios (expected user-visible behavior) in `frontend-spec.md`.
> "Frontend behavior spec is ready in `<planning>/frontend-spec.md`. Please review before I draft the implementation plan."

**Gate 3 — Plan.** Write the implementation plan and architecture notes in `notes.md`, with concrete files, API contracts, and data-flow notes — not vague bullets.
> "Implementation plan is ready in `<planning>/notes.md`. Please review before implementation."

Keep planning files lightweight and decision-oriented. For draft specs, default to one high-value happy path; add scenarios only when explicitly requested or clearly required by risk.

If a task touches only one side (backend-only or frontend-only), skip the gate that doesn't apply and say so.

## Implementation sequence

After approval, implement in this order. Complete backend fully before frontend for cross-stack work.

**Backend** (when backend changes): add/update tests (confirm the intended failing case when applicable) → implement → rerun affected tests until green.

**Frontend** (when frontend changes): implement → run the project's lint → run the project's build.

## Verification

- **Backend:** run the targeted test suite for the changed area; run the broader suite for major changes. Match existing test style and helpers.
- **Frontend:** run lint and build. If there's no automated test suite, rely on the behavior captured in `frontend-spec.md`; add automated tests only when existing tooling supports them and they add clear value.
- Manual integration checks add confidence for user-visible flows but do not replace automated checks.
- Before resetting a shared/local service stack, confirm whether overlapping services are already running.

## Closeout

- Scope matches the approved plan.
- Backend tests updated and passing (if backend changed); frontend lint/build passing (if frontend changed).
- Cross-stack manual verification done when the flow is user-visible.
- Diff reviewed for debug code and unplanned leftovers.
- Planning notes reflect any deviations from plan.
- Update project conventions, environment/setup docs, and any docs the feature touched.
