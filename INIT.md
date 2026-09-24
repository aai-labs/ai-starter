# INIT.md

> **For the user:** open a new agent session at the repo root and say *"Follow `INIT.md`."* Review the resulting diff before committing. This is a one-shot bootstrap, not a recurring task.

---

## Goal

Add a populated `## Project context` block to `AGENTS.md` using the template in **Step 3** below, with every `<...>` replaced by a value discovered from the repository. Then establish the smallest evidence-backed project documentation router described in **Step 5**. Read `docs/DOCUMENTATION_BLUEPRINT.md` before creating project-specific pages.

## Why this is bounded

Independent studies show that LLM-generated context files reduce task success by roughly 3% at +20% inference cost when committed without human review (Gloaguen et al., *Evaluating AGENTS.md*, arXiv:2602.11988; Augment 2026 study). The slots below are the narrow subset suitable for the always-loaded `AGENTS.md`: **non-inferable commands, pinned versions, and counterintuitive patterns**. Keep broader context in task-routed pages only when evidence supports it.

## Pre-flight

- If `AGENTS.md` already contains a `## Project context` section, **stop** and ask the user whether to refresh the existing bootstrap in place or abort. Do not duplicate an existing context block or documentation page.
- If `AGENTS.md` does not exist at the repo root, **stop** and ask the user where the agent guideline file lives.

## Step 1 — Normalize AGENTS.md structure

If `AGENTS.md` currently starts with `# Agent work loop`, restructure the top of the file so the H1 names the document and the work loop is demoted to an H2:

- Change line 1 from `# Agent work loop` to `# AGENTS.md`.
- Insert a blank line, then `## Agent work loop`, then the existing numbered list verbatim.

If `AGENTS.md` already starts with `# AGENTS.md`, skip this step.

## Step 2 — Discover values

Read before writing. Prefer these sources, in order:

1. **Package manifests** — `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pnpm-workspace.yaml`, `pixi.toml` …
2. **Lockfiles** — confirm which package manager is actually in use (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, `poetry.lock`, `uv.lock`, `bun.lockb`).
3. **CI configuration** — `.github/workflows/*`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `Jenkinsfile`. **CI is the source of truth for build/test/lint commands**; copy exact strings, including flags. When CI and `README.md` disagree, CI wins.
4. **Task runners** — `Makefile`, `justfile`, `Taskfile.yml`, `scripts/`, root `*.sh` / `*.ps1`. Promote canonical wrappers when they exist.
5. **`README.md`** — sanity-check human-facing command docs against CI.
6. **Source code** — *only* for the **Non-obvious patterns** slot, and only after the other slots are filled. Skim one or two representative feature folders, the HTTP/API client (if any), the test helpers, and one or two recent PR descriptions.

Stay scoped: use targeted reads on likely paths over wide searches. Inspect additional files only when a candidate documentation claim needs evidence. If evidence remains unavailable, omit the claim or report the ambiguity instead of guessing.

## Step 3 — Insert this populated block

Insert the following section as the **first `##` block** in `AGENTS.md`, immediately after the H1. Replace every `<...>` with a discovered value before writing.

````markdown
## Project context

> Loads on every agent invocation. Keep short.

- **Stack / versions** — `<framework + language + runtime version; pin what is non-negotiable, e.g. "Next.js 15 App Router, TypeScript, Node 22.x">`.
- **Package manager** — `<e.g. pnpm — never npm>`.
- **Commands** — exact strings, including flags:
  - Install: `<...>`
  - Dev: `<...>`
  - Build: `<...>`
  - Typecheck: `<...>`
  - Lint: `<...>`
  - Test (all): `<...>`
  - Test (single file): `<...>`
- **Non-obvious patterns** — 1–5 counterintuitive decisions an outsider would miss (e.g. *"`apiClient` never throws — it returns `ApiResult<T>`, so `try/catch` around it is always wrong"*). Highest-signal block; keep it short and concrete.
````

Rules per slot:

- **Stack / versions** — Single line. Use versions actually pinned (in `engines`, `requires-python`, `rust-version`, `go.mod`, a Dockerfile `FROM`, or a CI matrix). Write `<unpinned>` rather than guess.
- **Package manager** — Whichever lockfile is present and CI uses. State it as a **do**, not only a **don't**.
- **Commands** — Copy exact strings (including flags) from CI or the `scripts` block of the manifest. Do not invent commands. Write `<not configured>` if a command genuinely does not exist in the repo.
- **Non-obvious patterns** — 1–5 entries, each one sentence. Each entry **MUST** be:
  - **Counterintuitive** — an outsider would assume the opposite.
  - **Evidence-backed** — you can point to the file or pattern that demonstrates it.
  - **Paired do/don't** — state what to do, not only what to avoid.

  Three real patterns beat seven speculative ones. If you cannot find any counterintuitive pattern, write fewer; an empty list is acceptable. **Speculative rules measurably hurt agent performance.**

## Step 4 — Monorepo handling (if applicable)

Run this step only when Step 2 surfaced **monorepo signals**:

- A workspaces declaration: `pnpm-workspace.yaml`, `package.json` with `"workspaces"`, `lerna.json`, `nx.json`, `turbo.json`, `rush.json`, a `[workspace]` block in root `Cargo.toml`, or a uv/poetry workspace in root `pyproject.toml`.
- Multiple `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` files outside `node_modules/` and similar vendored paths.
- A top-level layout like `apps/* + packages/*`, `services/*`, `libs/*`, or mixed-stack (e.g., `backend/` Python + `frontend/` TypeScript).

### Decide which modules need their own AGENTS.md

A module needs a per-module `AGENTS.md` **only when at least one** of these differs meaningfully from the root:

- Stack or runtime version (e.g., backend Python 3.12 vs. frontend Node 22.x).
- Package manager (e.g., `uv` in backend, `pnpm` in frontend).
- Build / dev / test / lint / typecheck commands.
- A non-obvious pattern that applies *only* inside that module.

If a module shares stack, commands, and patterns with the root, **do not** create a per-module file. Duplication is the failure mode here, not under-coverage — the Augment 2026 study found that AGENTS.md files sitting on top of duplicated surrounding documentation underperformed having no per-module file at all.

### Propose before writing

Surface a short plan in chat covering:

- The detected monorepo signal(s).
- A list of candidate modules with their paths.
- For each candidate, which slots actually differ from the root.
- Your recommendation per module: **create sub-`AGENTS.md`** / **skip — same as root**.

Wait for the user to confirm before writing any sub-files.

### Per-module AGENTS.md shape

Each per-module `AGENTS.md` **MUST** be small (target ≤ 30 lines). Contain only:

1. A one-line note that this file overrides or extends the root, e.g. *"Overrides apply within this module; everything else inherits from `../AGENTS.md`."*
2. A `## Project context` block containing **only the slots that differ** from the root. Omit identical slots — do not restate them.
3. Optional: 1–3 module-specific non-obvious patterns under the same evidence rules as Step 3.

Do not duplicate the root's work loop, scope discipline, guardrails, or reference pointers — those inherit. Per the Codex spec, the deeper file wins on conflict, so explicit overrides at the module level are sufficient.

### Example layout

```text
repo/
├── AGENTS.md                  # root: shared standards + root commands
├── apps/
│   ├── web/
│   │   └── AGENTS.md          # overrides: Node 22.x, pnpm, vitest
│   └── api/
│       └── AGENTS.md          # overrides: Python 3.12, uv, pytest
└── packages/
    └── shared/                # no AGENTS.md — same stack/commands as root
```

### Monorepo-specific constraints

- Do not generate a sub-file speculatively. The trigger is **divergence from the root**, confirmed by the user.
- A monorepo with N modules does **not** mean N sub-files. Aim for fewer than N — ideally only the modules that truly diverge.
- Sub-files contain **overrides only** — never restate root content.
- The same evidence-over-inference rule from Step 2 applies per module: read that module's manifest, lockfile, and CI job(s) before writing anything.

## Step 5 — Establish task-routed documentation

Read `docs/DOCUMENTATION_BLUEPRINT.md` and inspect existing `docs/`, source, schemas, tests, and relevant history or issues. Treat the imported `docs/INDEX.md` as a starter route, not as proof that project-specific pages exist. Inventory existing authoritative pages before adding anything.

- Keep `docs/INDEX.md` as a task-to-document table. Add a row for each maintained feature, architecture, decision, or active epic page with a specific **when working on** trigger and a source path to inspect. Remove placeholder guidance once real routes exist; never link a nonexistent page.
- Create or update `CONTEXT.md` only when project-specific terms, misleading synonyms, or resolved ambiguities are supported by code, tests, existing docs, or maintainer evidence. Keep it a glossary, not an architecture overview. If no terms are evidenced, leave `CONTEXT.md` absent and do not add a glossary row to the index.
- Create feature or architecture pages only for cross-file invariants, boundaries, state transitions, or change impact that an agent could misunderstand. Link authoritative source and test paths. Do not narrate every endpoint or field.
- Create an ADR only when a hard-to-reverse, surprising choice and its real trade-off are supported by a prior decision, issue, commit, plan, or maintainer statement. Do not reconstruct rationale from code shape. Report missing rationale and defer the ADR.
- Create a feature epic change log only for an active multi-ticket or multi-PR transition with evidenced coordination needs. Do not create empty directories or template pages for unused categories.

Use the nearest existing document instead of duplicating a fact. Preserve project-owned pages and conventions. If a new route should be mandatory for nearly every task, add a concise trigger-and-target pointer to `AGENTS.md`; otherwise keep it in the index. After writing, verify that all links resolve and every substantive current-behavior claim has code, test, or schema support.

## Constraints

- Edit `AGENTS.md` only for the H1 normalization, the `## Project context` block, and a concise project-specific route if Step 5 identifies one that applies to nearly every task. Preserve all other root guidance. (Per-module sub-files created in Step 4 are new files.)
- Do not add an architecture overview to `AGENTS.md`; create a focused architecture page only when Step 5 finds an evidenced need.
- Do not grow the populated block beyond ~20 lines.
- Put evidenced knowledge outside the four context slots in its authoritative task-routed location; surface unresolved ambiguities in the summary rather than guessing.
- Do not commit on the user's behalf — leave the diff staged or unstaged for review.

## Done when

- Root `AGENTS.md` has `# AGENTS.md` as its H1 and `## Project context` as its first H2 section.
- Every `<...>` in the root block is replaced with a discovered value, `<unpinned>`, or `<not configured>`.
- The root populated block is **≤ ~20 lines**. If it grew, the extra content belongs in a reference file.
- If monorepo signals were present (Step 4): the sub-file plan was reviewed by the user, each created sub-`AGENTS.md` is ≤ ~30 lines and contains overrides only, and modules skipped on purpose were named in the chat summary with the reason (*"same stack and commands as root"*).
- You have posted a short summary in chat covering: which sources you read, where each value came from, which modules got sub-files (and which were skipped), and any slot you left empty and why.
- No other section of any existing `AGENTS.md` has changed except a justified project-specific route from Step 5.
- `docs/INDEX.md` contains only routes to existing files, and any added project-specific pages contain evidence-backed claims.

## Re-running

`INIT.md` is one-shot per scope: once for the root, once for each module that gets a sub-file. After the first run, update context blocks and task-routed documentation directly when their contracts change. Re-run only after a substantial restructure (new stack, monorepo split, module added or removed) and only with explicit user request.

