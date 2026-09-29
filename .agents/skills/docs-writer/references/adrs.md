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

Follow the repository's existing ADR convention. When none exists, use `docs/adr/YYYY-MM-DD-slug.md`. Create the directory only when the first qualified decision is ready.

Link an ADR from the feature or architecture document it explains. Keep current operational behavior in that document; keep historical rationale in the ADR.
