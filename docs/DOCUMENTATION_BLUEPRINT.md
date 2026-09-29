# Project documentation blueprint

Keep each meaning in one authoritative place. `AGENTS.md` owns mandatory agent behavior and task-triggered routes. `CONTEXT.md`, when needed, is the project glossary. Root guideline files own repeatable coding, web, and testing conventions. `docs/INDEX.md` routes tasks to focused pages. Code, schemas, migrations, and tests own exact implementation.

| Information | Location |
| --- | --- |
| Canonical project terms, relationships, resolved or open ambiguities | `CONTEXT.md` |
| Current feature invariants, state, boundaries, source map, change impact | `docs/features/` |
| Current system boundaries, dependency direction, runtime and deployment shape | `docs/architecture/` |
| Evidence-backed rationale for consequential decisions | `docs/adr/` |
| Temporary state across tickets or PRs in an active epic | `docs/features/<epic>/CHANGELOG.md` |

## Write only earned context

Create a feature page when rules span files or are easy to misunderstand. Useful sections are **Read when**, **Role**, **Invariants**, **Relationships and boundaries**, **State model**, **Primary flows**, **Source map**, **Related decisions**, and **Change impact**. Omit sections that add no useful context. Architecture pages describe current responsibilities and cross-boundary flow, with source pointers. Avoid inventories that one code search reveals.

Create an ADR only when the decision is hard to reverse, surprising without context, and based on a real trade-off. Use `docs/adr/YYYY-MM-DD-slug.md` unless the project already has a convention. Record the decision, status, date, and confirmed reason; add alternatives or revisit conditions only when useful. Never invent historical rationale. Link the ADR from current feature or architecture context.

For a multi-PR epic, use `docs/features/<epic>/CHANGELOG.md` only while coordination needs a shared transition record. Track delivered, in-transition, next, and blocked work with ticket and PR links. Each participating PR updates it. On closure, move durable facts to their authoritative pages and keep the log only if the history remains useful.

## Keep the router accurate

Each index row must say **when** to read a page and point to an existing file. Update current-behavior pages with code and tests when contracts change. Update the glossary when terminology is resolved. Update the index when pages move. Reviewers should check documented invariants and cite the path behind findings. An intentional change can revise the documentation contract.
