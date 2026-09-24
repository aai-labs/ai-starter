# Agent context map

Use this index to find project-specific context. Add a row only when its target exists; replace these instructions with task-specific routes during bootstrap. Keep exact implementation details in code, schemas, migrations, and tests.

| When working on | Read first | Then inspect |
| --- | --- | --- |
| Repository-wide coding, web, or testing conventions | `CODE_GUIDELINES.md`, `WEBAPP_GUIDELINES.md`, `TESTING.md` | Applicable source and tests |
| Creating or restructuring agent-facing documentation | `docs/DOCUMENTATION_BLUEPRINT.md` | Existing `AGENTS.md`, `CONTEXT.md`, routed docs, implementation, and tests |

When a project glossary exists, add a terminology row pointing to `CONTEXT.md`. For current feature behavior, system boundaries, decision rationale, and active multi-PR transitions, add rows pointing to maintained pages under `docs/features/`, `docs/architecture/`, and `docs/adr/`. Name the trigger in the first column. Link an ADR from the feature or architecture page it explains. Update this index in the same change whenever a routed page is added, moved, renamed, or removed.
