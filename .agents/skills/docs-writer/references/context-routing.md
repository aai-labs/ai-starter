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
