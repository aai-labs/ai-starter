# Changelog

## [Unreleased]

### Added

- **`INIT.md`** — one-shot bootstrap prompt the user runs once per repo (*"Follow `INIT.md`."*) so the agent discovers and inserts a populated `## Project context` block (stack/versions, package manager, commands, non-obvious patterns) into `AGENTS.md`. Scoped to evidence-backed values from manifests, lockfiles, CI, and task runners; explicitly forbids speculation, architecture overviews, and edits outside the new block. Includes a **Step 4 — Monorepo handling** that detects workspace declarations (`pnpm-workspace.yaml`, `nx.json`, Cargo `[workspace]`, uv/poetry workspaces, …) and proposes per-module sub-`AGENTS.md` files only for modules whose stack/commands/patterns diverge from the root, with each sub-file scoped to overrides only (target ≤ 30 lines) per the Codex deeper-file-wins precedence rule. References the studies that motivate the scope: Gloaguen et al. (arXiv:2602.11988) and the Augment 2026 AGENTS.md study (the latter found module-level files outperform monolithic root files for mid-size modules).

### Changed

- Restructured guidelines for agent-first use: **AGENTS.md** now leads with a work loop, a **what goes where** table, and explicit **Always / Ask first / Never** guardrails.
- **CODE_GUIDELINES.md**: added **Project-defining rules** at the top; compressed generic design content into **Design heuristics**; removed duplicate testing prose, meta “working with AI” / interview sections, and advanced distributed-state notes; tests fully delegated to **TESTING.md**.
- **WEBAPP_GUIDELINES.md**: added **Project-defining frontend rules** at the top; merged principles and stack notes; removed duplicate E2E and HTTP integration sections (now only in **TESTING.md**).
- **TESTING.md**: single source for core principles, Python (GivenPy), Node/TS HTTP integration, and browser E2E (page objects, pyramid, selectors) with per-stack **DO / DON'T** checklists.
- **README.md**: updated file descriptions and import guidance to match the split.
- Added `scripts/install.ps1` and `scripts/install.sh` for copying agent guideline files into an existing project after cloning, plus a shell-script LF line-ending rule.
- **`README.md`** + **install scripts**: included `INIT.md` in the file listing, the inline `cp` brace expansion, and both `install.sh` / `install.ps1` `files` arrays; expanded the **After importing** section into a three-step workflow (review → run `INIT.md` → start working) so the bootstrap path is the first thing a new user sees.
