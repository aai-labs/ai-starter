# Project Documentation for Coding Agents

## Purpose

Coding agents are most effective when they can quickly answer five questions:

1. What does this project call things?
2. Where does a responsibility belong?
3. What must remain true while I change it?
4. Why was a consequential decision made?
5. How do I verify that the change is complete?

The answer is not one large instruction file. Large instruction files consume attention on every task, mix unrelated concerns, and become difficult to maintain. We use a **context router**: a small mandatory entry point that directs the agent to focused documentation for the task at hand.

The goal is the smallest durable context that prevents incorrect assumptions.

---

## Documentation hierarchy

| Artifact | Responsibility | Typical consumer |
| --- | --- | --- |
| `AGENTS.md` | Mandatory work loop, guardrails, context routing, review protocol | Every implementation and review agent |
| `CONTEXT.md` | Canonical domain terminology, relationships, and resolved ambiguities | Anyone naming or discussing product concepts |
| `docs/INDEX.md` | Task-to-document context map | Agents entering an unfamiliar area |
| `docs/guidelines/` | Repeatable API, UI, testing, operations, and collaboration conventions | Agents changing code or process |
| `docs/architecture/` | Current system boundaries, dependency direction, runtime and deployment shape | Cross-domain and infrastructure changes |
| `docs/features/` | Feature invariants, state models, boundaries, source maps, and change impact | Feature implementation and review |
| `docs/adr/` | Why consequential architectural decisions were made | Agents preserving or revisiting a decision |
| Source code, schemas, migrations, and tests | Exact implementation and executable contracts | Agents doing implementation legwork |

Each meaning has one authoritative location. Other files link to it instead of restating it.

---

## `AGENTS.md`: mandatory entry point

`AGENTS.md` stays small. It contains only information that should shape nearly every agent session:

- The project work loop.
- Mandatory guardrails.
- Pointers describing when deeper context must be read.
- Review requirements.
- Rules for keeping documentation synchronized.

A useful context pointer names both the target and the trigger.

Weak:

> See `docs/features/agents.md`.

Strong:

> Before changing agent lifecycle, runtime selection, or Slack/Teams configuration, read `docs/features/agents.md`.

The target tells the agent where to look. The trigger tells it when the document becomes relevant.

---

## `CONTEXT.md`: shared language

`CONTEXT.md` is a glossary, not an architecture guide or implementation specification. It records:

- Canonical project-specific terms.
- Terms that should not be used as synonyms.
- Relationships that sharpen the meaning of those terms.
- Ambiguities that have been resolved or remain visible.

Example:

```markdown
**Runtime**:
The implementation that executes an agent. Agent Farm currently supports
Hermes and OpenClaw.
_Avoid_: platform

**Platform**:
The chat system through which an agent interacts with people.
_Avoid_: runtime
```

Shared language improves prompts, code naming, review findings, and searchability. When terminology is resolved, update the glossary immediately rather than waiting for a documentation pass.

---

## Guidelines versus system context

The documentation separates **how we write software** from **how the current system works**.

### Engineering guidelines

`docs/guidelines/` contains repeatable conventions:

- `code.md` — API layering, HTTP semantics, schemas, migrations, review priorities.
- `webapp.md` — Next.js, React, API boundaries, query behavior, async UX.
- `testing.md` — verification commands and API/UI testing ownership.
- `operations.md` — local setup, migrations, deployment, and versioning.
- `epics.md` — coordination for work spanning multiple tickets or pull requests.

A guideline should apply repeatedly. Product-specific behavior does not belong here.

### Architecture and feature context

Architecture and feature pages describe what is true now:

- Responsibilities and boundaries.
- Dependency direction.
- Invariants.
- State transitions.
- Cross-boundary flows.
- Authoritative source paths.
- Areas affected by a change.

They avoid endpoint inventories and field-by-field narration when the source code exposes those details directly.

---

## Feature context packets

A feature document is a compact map for implementation and review agents.

Recommended shape:

```markdown
# Feature name

## Read when

## Role in the system

## Invariants

## Relationships and boundaries

## State model

## Primary flows

## Source map

## Related decisions

## Change impact
```

Only include sections the feature earns. The most valuable content is usually:

- Rules that must remain true.
- Boundaries that are easy to cross accidentally.
- State transitions spread across several files.
- Exact source locations.
- Dependent areas that must be checked when behavior changes.

---

## Architectural Decision Records

Architecture and feature docs describe **what is true now**. ADRs preserve **why a consequential choice was made**.

Create an ADR only when all three conditions are met:

1. The choice is hard to reverse.
2. It would be surprising without context.
3. It resulted from a real trade-off.

Agent Farm uses merge-friendly date-based filenames:

```text
docs/adr/YYYY-MM-DD-descriptive-slug.md
```

Example:

```text
docs/adr/2026-07-17-push-based-runtime-telemetry.md
```

An ADR can be short:

```markdown
# Use push-based runtime telemetry

Status: Accepted
Date: 2026-07-17
Origin: AF-122

Conversation and tool-call history was previously collected by executing into
live agent pods. We replaced this with runtime plugins that push events to an
internal Ingest API because the pull model depended on pod availability, added
read latency, and coupled the API to runtime-specific filesystem formats.
```

Add alternatives, consequences, or revisit conditions only when they help a future engineer or agent reason about the decision.

Never invent retrospective rationale from code shape. Use maintainers, tickets, plans, commits, or other historical evidence.

---

## Multi-ticket and multi-PR epics

A large epic needs a cross-PR coordination artifact because no single ticket or diff contains the complete transition.

Create:

```text
docs/features/<epic-slug>/CHANGELOG.md
```

The epic change log records:

- What slices have landed.
- What behavior is temporarily in transition.
- What the next pull request may safely assume.
- Current blockers and dependencies.
- Links to the relevant tickets and pull requests.

Required shape:

```markdown
# Epic name — change log

Status: Active
Epic: <ticket or project link>
Related context: <feature, architecture, and ADR links>

## Current state

- Delivered:
- In transition:
- Next:
- Blockers:

## Changes

### YYYY-MM-DD — TICKET — PR

- Delivered:
- Changed:
- Follow-up:
```

Every PR belonging to the epic updates the log. Reviewers should flag a missing or inaccurate update.

The log does not replace other sources:

- Feature and architecture docs remain authoritative for current behavior.
- ADRs remain authoritative for decision rationale.
- The issue tracker remains authoritative for ownership, acceptance criteria, and backlog state.

When the epic closes, move durable facts into their authoritative documents. Keep the log only when the staged migration history remains useful; otherwise rely on Git and PR history.

---

## Review-agent behavior

Review agents treat routed documentation as review input, not optional background.

Before reviewing a diff they should:

1. Map changed files and behaviors through `docs/INDEX.md`.
2. Read applicable guidelines, feature pages, architecture pages, glossary terms, and ADRs.
3. Review implementation correctness against documented invariants and boundaries.
4. Check that documentation changes with the contract.
5. Cite the documentation path and rule behind documentation-based findings.
6. Verify the epic change log when the PR belongs to an active multi-PR epic.

Documentation is the current contract, not an immutable one. An intentional behavior change is valid when code, tests, and authoritative docs move together.

---

## What belongs where

| Information | Authoritative location |
| --- | --- |
| Mandatory cross-project agent behavior | `AGENTS.md` |
| Domain vocabulary | `CONTEXT.md` |
| Repeatable coding and workflow conventions | `docs/guidelines/` |
| Current feature behavior and invariants | `docs/features/` |
| Current system boundaries | `docs/architecture/` |
| Architectural rationale | `docs/adr/` |
| Multi-PR transition state | Epic `CHANGELOG.md` |
| Acceptance criteria and ownership | Issue tracker |
| Exact implementation | Code, schemas, migrations, and tests |

---

## Maintenance rules

Update documentation in the same change when:

- A domain, feature, runtime, or responsibility is added, removed, renamed, or moved.
- An invariant, boundary, state model, or operational contract changes.
- A repeatable engineering convention is introduced.
- A consequential architectural decision is accepted or superseded.
- A pull request advances an active multi-PR epic.

Avoid documentation that merely repeats code. Prefer context that is costly to rediscover, easy to misunderstand, or necessary for evaluating change impact.


---

## Something More ..

The below is my `docs-writer` skill, not perfect but works!

### Usage

Usage Copy the below files in the following style to your project or global skills folder

```
~/.agents/skills
├── docs-writer
│   ├── references
│   │   ├── adrs.md
│   │   ├── context-routing.md
│   │   └── feature-docs.md
│   └── SKILL.md
```


### `SKILL.MD`

```
---
name: docs-writer
description: Context-router discipline for agent-facing project documentation. Use when documenting project features or architecture for coding agents, organizing AGENTS.md and agent-doc indexes, sharpening CONTEXT.md terminology, or capturing architectural decisions in ADRs.
---

# Agent Docs Writer

Write the smallest durable context that prevents coding agents from making incorrect assumptions. Treat the documentation set as a **context router**: mandatory rules stay close to entry, while focused context sits behind precise pointers.

## Information hierarchy

- `AGENTS.md` owns mandatory cross-cutting rules and routes agents to conditional context.
- `CONTEXT.md` owns canonical domain language, relationships, and resolved ambiguities.
- Agent-facing feature and architecture docs own current invariants, boundaries, and source maps.
- ADRs own the rationale for consequential decisions that current code cannot explain.
- Code, schemas, migrations, tests, and generated specifications own implementation detail.

Keep each meaning in one authoritative place. Link to that place from other artifacts instead of restating it.

## Process

### 1. Select the documentation branch

Classify the requested artifact before writing:

- For `AGENTS.md`, a documentation index, context pointers, or domain terminology, read [context routing](references/context-routing.md).
- For a feature context packet, system map, or architecture boundary, read [feature and architecture docs](references/feature-docs.md).
- For a proposed or existing architectural decision, read [ADRs](references/adrs.md).

For work spanning branches, read every applicable reference.

**Complete when:** every requested artifact has a branch, an authoritative location, and an identified consumer task.

### 2. Establish evidence

Read the repository instructions, existing glossary, documentation index, nearby docs, and related ADRs. Inspect the implementation and tests for the area being documented. Use history, issues, plans, or the user for decision rationale.

Separate two claim types:

- **Current behavior** — supported by current code, tests, configuration, or schemas.
- **Decision rationale** — supported by an ADR, issue, commit history, plan, or explicit maintainer confirmation.

When rationale is unavailable, record the uncertainty or ask the user; defer the ADR until the trade-off is known.

**Complete when:** every substantive claim has an evidence source, and existing authoritative text that would be duplicated has been identified.

### 3. Write the smallest sufficient artifact

Use the selected branch template as a starting shape, then keep only sections earned by the subject. Prefer invariants, relationships, state transitions, ownership boundaries, change impact, and precise source paths over narrative descriptions.

Write context pointers with both target and trigger:

```markdown
Before changing agent lifecycle, runtime selection, or Slack/Teams setup,
read `docs/agents/features/agents.md`.
```

Co-locate each concept's definition, rules, and caveats. Keep exact endpoint inventories, field lists, and command implementations in their executable sources unless an agent-facing constraint depends on them.

**Complete when:** the artifact gives its target agent enough context to act correctly without reproducing discoverable implementation detail.

### 4. Wire the context router

Make the artifact discoverable from the nearest entry point:

- Global conditional context is routed from `AGENTS.md`.
- Feature and architecture context is routed from the agent-doc index and any relevant parent document.
- ADRs are linked from the feature or architecture document whose rationale they explain.
- Glossary terms are referenced by their canonical names throughout the docs.

Add a synchronization trigger when future structural or behavioral changes would otherwise leave the route stale. State the exact event that requires an update.

**Complete when:** an agent starting from the repository instructions can reach the artifact through a specific task-triggered pointer.

### 5. Prune and verify

Review the documentation diff against these checks:

- Every meaning has one source of truth.
- Every pointer says when to follow it.
- Every current-behavior claim agrees with code or tests.
- Every rationale claim has historical or maintainer evidence.
- Every relative path and Markdown link resolves.
- Every heading and sentence changes agent behavior or navigation.
- The change contains no unrelated documentation reshaping.

Remove duplication, no-op prose, speculative rationale, stale sections, and decorative structure. Report unresolved ambiguities rather than smoothing them over.

**Complete when:** all checks pass, the diff is scoped, and unresolved claims are explicitly surfaced to the user.
```


## `references/adrs.md`

```

# Architectural decision records

Use an ADR only when all three gates pass:

1. **Hard to reverse** — changing the choice later has meaningful cost.
2. **Surprising without context** — a future agent could reasonably “fix” or replace it.
3. **Real trade-off** — viable alternatives existed and were rejected for specific reasons.

When a gate fails, place any still-useful current constraint in the relevant feature or architecture document instead.

## Evidence gate

An ADR records a decision and its rationale, not a rationale reconstructed from code shape. Establish the reason from the user, issue, plan, commit history, or prior artifact. If only the resulting implementation is known, ask for the missing rationale or defer the ADR.

For retrospective ADRs, label them as retrospective when the original discussion is unavailable and record only confirmed rationale.

## Default format

```markdown
# Short decision title

One to three sentences stating the context, decision, and reason.
```

That is a complete ADR when it preserves the decision adequately.

## Optional sections

Add a section only when it carries information a future agent needs:

```markdown
## Status

Proposed | Accepted | Deprecated | Superseded by ADR-YYYY-MM-DD-description

## Considered alternatives

Include alternatives whose rejection is worth remembering.

## Consequences

Include non-obvious costs, constraints, or follow-up effects.

## Revisit when

Include concrete conditions that would invalidate the decision drivers.
```

## Placement and numbering

Follow the repository's existing ADR convention. When none exists, use `docs/adr/YYYY-MM-DD-slug.md`, scan for the highest number, and increment it. Create the directory only when the first qualified decision is ready.

Link an ADR from the feature or architecture document it explains. Keep current operational behavior in that document; keep historical rationale in the ADR.
```


## `references/context-routing.md`

```
# Context routing and domain language

Use this branch for `AGENTS.md`, agent-doc indexes, context pointers, and `CONTEXT.md`.

## `AGENTS.md`

`AGENTS.md` is the mandatory entry point, not the full knowledge base. Keep:

- Rules that apply to most tasks.
- Repository-wide invariants.
- Required verification commands.
- Conditional pointers describing when deeper context must be read.
- Synchronization triggers for keeping routes accurate.

Pointer shape:

```markdown
Before changing <specific concerns>, read `<path>`.
```

A pointer that names only a file is incomplete because it leaves the loading condition implicit.

## Agent-doc index

The index is a task router. Prefer a table over a prose catalog:

```markdown
# Agent Context Map

| When working on | Read first | Then inspect |
|---|---|---|
| Agent lifecycle | `features/agents.md` | `api/domains/agents/` |
| Database schema | `workflows/schema-changes.md` | `api/migrations/` |
```

Include only maintained routes. Adding, moving, renaming, or deleting a routed document requires updating the index in the same change.

## `CONTEXT.md`

`CONTEXT.md` is a glossary, not an architecture guide or specification.

```markdown
# Context name

One or two sentences defining the domain boundary.

## Language

**Canonical term**:
One or two sentences defining what the concept is.
_Avoid_: overloaded synonym, misleading synonym

## Relationships

- A **Canonical term** belongs to one **Related term**.

## Flagged ambiguities

- “Old term” meant X and Y — resolved: use **X term** and **Y term**.
```

Rules:

- Choose one canonical term and name misleading alternatives under `_Avoid_`.
- Define what a concept is, not its implementation.
- Include project-specific domain concepts rather than general programming vocabulary.
- Capture relationships only when they sharpen meaning.
- Preserve unresolved ambiguity explicitly until the user or domain evidence resolves it.
- Update a resolved term when it crystallizes rather than batching glossary work later.
```


## `references/feature-docs.md`

```
# Feature and architecture docs

Use this branch for feature context packets, architecture boundaries, and system maps written for coding agents.

## Feature context packet

Start with this shape and remove sections that the feature does not earn:

```markdown
# Feature name

## Read when

Read before changing <specific behaviors, boundaries, or integrations>.

## Role in the system

One short paragraph explaining where the feature fits and its defining constraint.

## Canonical terms

Only terms needed to understand this feature. Link shared terms to `CONTEXT.md`.

## Invariants

- Rules that must remain true across implementations.

## Relationships and boundaries

- Ownership, direction of dependencies, and cross-domain contracts.

## State model

Include only when lifecycle or transitions constrain changes.

## Primary flows

Describe cross-boundary flow, not line-by-line implementation.

## Source map

| Concern | Authoritative source |
|---|---|
| Business rules | `path/to/service` |
| Persistence | `path/to/repository` |
| API contract | `path/to/models-or-routes` |
| Tests | `path/to/tests` |

## Change impact

When changing <area>, also inspect:
- <dependent area>
- <contract or verification surface>

## Related decisions

- `docs/adr/YYYY-MM-DD-decision.md`

## Open ambiguities

- Questions whose answer cannot be established from current evidence.
```

## Architecture document

Architecture docs explain current system shape rather than historical rationale. Focus on:

- Module or bounded-context responsibilities.
- Dependency direction.
- Data and control flow across boundaries.
- Runtime and deployment boundaries.
- Invariants shared by several features.
- Pointers to authoritative implementation and related ADRs.

Use diagrams only when they communicate relationships more compactly than text. Keep labels canonical and accompany the diagram with source pointers.

## Selection rules

Document a fact when it is costly for an agent to rediscover, easy to misunderstand, or needed to assess change impact. Leave a fact in code when one local inspection reveals it reliably.

Feature and architecture docs describe **what is true now**. ADRs explain **why a consequential choice was made**. Link the two rather than mixing their responsibilities.
```
