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
