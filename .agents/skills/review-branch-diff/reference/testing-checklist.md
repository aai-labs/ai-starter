# Testing Checklist

Use this checklist when reviewing whether the branch has enough validation.

## General test expectations

Look for tests that cover:

- The main success path
- Important failure paths
- Edge cases
- Authorization or permission behavior
- Backward compatibility
- Data migrations or transformations
- Bug regressions

## Missing tests may be high severity when

Missing validation should be treated as `P0` or `P1` when the change:

- Modifies authentication or authorization
- Changes payment or billing behavior
- Alters database migrations or data transformations
- Changes public API behavior
- Fixes a bug but does not include a regression test
- Changes complex business logic
- Changes concurrency, caching, or async behavior
- Has a high risk of data loss
- Affects many users or core workflows

## Missing tests may be lower severity when

Missing tests are usually `P2` or `P3` when the change:

- Only changes copy or documentation
- Only changes visual styling
- Refactors code without behavior changes
- Is already covered by nearby integration tests
- Is low-risk and hard to test meaningfully

## What to check

Check whether:

- Existing tests were updated when behavior changed.
- New code is covered by unit or integration tests.
- Error paths are tested.
- Authorization failures are tested.
- Boundary conditions are tested.
- Migrations are tested or validated.
- Snapshots were updated intentionally.
- Flaky or brittle tests were not introduced.

## Validation commands

Prefer repository-specific commands from the host project.

Common examples:

```bash
npm test
npm run lint
npm run typecheck
pnpm test
pnpm lint
pnpm typecheck
pytest
ruff check .
mypy .
go test ./...
cargo test
```