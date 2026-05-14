# Review Principles

## Goal

The goal of code review is to decide whether the change is safe, correct, maintainable, and ready to merge.

## Portability

This skill is designed to work across many repositories and agent tools.

Always respect the host repository's existing instructions, including:

- `AGENTS.md`
- Cursor rules
- Codex instructions
- README guidance
- Contributing guides
- Existing test and lint commands
- Existing review conventions

Do not overwrite or replace repository-specific guidance.

## Priorities

Review in this order:

1. Correctness
2. Security
3. Data safety
4. Backward compatibility
5. Test coverage
6. Maintainability
7. Performance, only when material
8. Style, only when it affects readability or maintainability

## Evidence-based review

Every finding should be based on evidence in the diff or surrounding code.

For each finding, explain:

- What is wrong
- Where it happens
- Why it matters
- How to fix it

Avoid vague comments such as:

- "This might be bad"
- "Consider improving this"
- "This seems risky"

Prefer concrete comments such as:

- "This returns success even when the database update fails."
- "This authorization check uses the account ID from the request body instead of the authenticated user."
- "This migration drops a column without a backfill or rollback path."

## Severity guidance

Use `P0` through `P3` for bug findings.

- `P0`: App-breaking bug. Release blocker.
- `P1`: High-severity bug or risk with major impact.
- `P2`: Moderate bug or reliability/maintainability issue.
- `P3`: Minor bug with low impact.

Reserve `P0` and `P1` for issues that can cause incorrect behavior, security vulnerabilities, data loss, broken builds, failed tests, significant regressions, or unsafe migrations.

## Avoid nitpicks

Do not comment on formatting, import order, or style preferences unless:

- The repository has an explicit convention
- The issue makes the code harder to understand
- The issue hides a correctness problem
- The issue is not handled by automated tooling

## Questions

Use questions when risk depends on missing context.

Good questions:

- "Is this endpoint only reachable by admins? I do not see an authorization check in this diff."
- "Is this migration safe for existing rows with null values?"
- "Should this preserve the old API response shape for existing clients?"

Bad questions:

- "Why did you write it this way?"
- "Could this be cleaner?"
- "Are you sure this works?"

## Tone

Be direct and respectful.
Do not bury important problems under many minor comments.
Prefer concise, actionable feedback.