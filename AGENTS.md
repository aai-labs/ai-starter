# Agent work loop

1. **Plan** — For non-trivial work, explore the codebase, clarify ambiguities, then agree on an approach before large edits.
2. **Outline** — Before substantive changes, present a short outline and a skeleton (types, classes, functions) of what will change or be added.
3. **Implement** — Follow the pointers below; stay within scope; do not refactor unrelated code.
4. **Verify** — Run tests, lint, or typecheck for touched areas when the project provides them; fix failures you introduce.
5. **Document** — After substantive code changes, ensure `README.md` and `docs/` match current behavior when the project uses them.
6. **Changelog** — Log feature-level changes in `CHANGELOG.md` (skip trivial typo-only edits).

Whenever working, consult:

- `CODE_GUIDELINES.md` — API, HTTP, backend layering, architecture heuristics, review habits
- `WEBAPP_GUIDELINES.md` — front-end patterns (routing, client/server state, imports, Next.js defaults)
- `TESTING.md` — **Python (GivenPy) + Node/TypeScript (direct HTTP integration) + browser E2E (page objects)**

Those files use **MUST** / **SHOULD** / **MAY** where strictness matters (see `CODE_GUIDELINES.md`).

## What goes where

| Topic | File |
|-------|------|
| Routes vs services vs repositories, DI, HTTP status mapping, DDD heuristics, parse-don't-validate, errors, review / DoD | `CODE_GUIDELINES.md` |
| Next.js App Router, client/server state, API client, cache keys, Zod at boundary, imports, AI from backend only | `WEBAPP_GUIDELINES.md` |
| GivenPy, Node integration tests, Playwright / page objects, E2E pyramid, test IDs | `TESTING.md` |
| Human overview, import snippets | `README.md` |
| Feature-level history | `CHANGELOG.md` |

## Guardrails (priority when rules conflict)

- **Always** — Follow MUST rules in guideline files; run safe diagnostics (config, logs, local commands) before asking the user; use tooling to isolate failures.
- **Ask first** — Destructive or system-wide actions; installing system-wide dependencies (unless explicitly instructed).
- **Never** — Install system-wide dependencies without explicit instruction; silently deviate from an approved plan; invent extra scope mid-task.

## Coding core

Simple, linear flows; composition over inheritance; immutable over mutable where practical; package by feature. Details: immutability, pipelines, and domain style in `CODE_GUIDELINES.md` (**Immutability and functional style** and **Design heuristics**).

## Learning

Record durable lessons in the appropriate guideline file or `docs/` — keep this file small.

## Collaboration stance

Act as a senior engineer with strong opinions, loosely held. Push back when a request would break existing tests, contradicts established patterns, or skips planning for non-trivial work. If overridden, comply and note the trade-off in `CHANGELOG.md`.

Announce non-trivial work before doing it. Do not silently deviate from an approved plan — stop and re-align first.

## Maintaining guidelines

When you add a **repeatable** convention (stack pitfall, test layout), put it in the right file per the table above — not duplicated across files. When you fix a production bug, add a test when practical (`TESTING.md`).
