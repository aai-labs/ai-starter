---
name: review-branch-diff
description: Cross-platform review skill for Codex and Cursor. Review a Git branch, pull request, merge request, or local diff for correctness, security, regressions, tests, maintainability, and merge risk. Use when asked to review a branch, PR, MR, code changes, or diff.
---

# Review branch diff

Review the current branch against the requested base branch.

Follow repository-specific instructions from the host project, such as `AGENTS.md`, Cursor rules, Codex instructions, or other local agent guidance.

## Inputs

The user may provide:

- A task description
- A base branch, such as `origin/main`
- A branch name
- A pull request or merge request description
- Or no argument, meaning infer the base branch

If no base branch is provided, use this order:

1. `origin/main`
2. `origin/master`
3. The repository default branch, if detectable

## Procedure

1. Determine the base branch.
2. Run the review context script from the repository root.

Use the command that matches your shell:

```powershell
powershell -ExecutionPolicy Bypass -File .agents/skills/review-branch-diff/scripts/collect-review-context.ps1
```

```bash
bash .agents/skills/review-branch-diff/scripts/collect-review-context.sh
```

If a base branch was provided, pass it as the first argument.

3. Inspect the diff and surrounding code where needed.
4. Read relevant files when the diff alone is insufficient.
5. Apply the host repository's existing standards and validation commands.
6. Check for correctness, security, data safety, tests, error handling, maintainability, and material performance issues.
7. Avoid comments that automated tooling should handle.

## What to focus on

Look for:

- Logic bugs
- Broken edge cases
- Security or authorization issues
- Data validation problems
- Data loss or migration risk
- Backward compatibility issues
- Error handling gaps
- Race conditions
- Missing or weak tests
- Risky dependency or configuration changes
- Material performance problems
- API contract changes
- Unexpected user-facing behavior changes

## What not to focus on

Do not comment on:

- Formatting
- Import ordering
- Lint-only problems
- Simple typos
- Pure style preferences
- Naming preferences with no maintainability impact

Only mention these if they reveal a deeper correctness, readability, or maintainability issue.

## Severity labels

Always label each bug finding as `P0`, `P1`, `P2`, or `P3`.

- `P0`: App-breaking bug. Release blocker.
- `P1`: High-severity bug or risk with major impact.
- `P2`: Moderate bug or reliability/maintainability issue.
- `P3`: Minor bug with low impact.

## Output format

Return the review in this format:

```md
## Findings

- [P0|P1|P2|P3] file:line - concise issue
  - Why it matters
  - Suggested fix

## Merge recommendation

Approve, Comment, or Request changes with one-sentence rationale.

## Missing validation

Mention tests, lint, typecheck, migrations, or manual checks that should be run.

## Questions

Ask only questions that affect whether the branch is safe to merge.

## Strengths

List 1-3 concrete positives.
```

If no meaningful issues are found, say so clearly.

## Additional references

Use these references when relevant:

- For review principles and tone, read [Review Principles](reference/review-principles.md).
- For security-sensitive changes, read [Security Checklist](reference/security-checklist.md).
- For testing expectations, read [Testing Checklist](reference/testing-checklist.md).

## Standards

Be specific and evidence-based.

Do not invent issues.

If something is uncertain, say what evidence would confirm it.

Prefer fewer, higher-quality findings over many speculative comments.