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
