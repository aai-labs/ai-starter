# ai-starter

A small starter kit for **bootstrapping AI coding agents with good development guidelines**.

Drop these files into a project and agents that read `AGENTS.md` — Claude Code, Codex, Cursor, and similar tools — get the same working habits, architecture rules, and testing expectations from day one.

## Install in an existing project

Run this from the root of the project you want to configure. Existing files are skipped, not overwritten.

```bash
tmp=$(mktemp -d)
git clone --depth=1 git@github.com:aai-labs/ai-starter.git "$tmp"
cp -n "$tmp"/{AGENTS,INIT,CODE_GUIDELINES,WEBAPP_GUIDELINES,TESTING,CHANGELOG}.md .
rm -rf "$tmp"
```

This works on Linux, macOS, WSL, and Git Bash on Windows. For native PowerShell, clone once and run the installer script:

```powershell
git clone --depth=1 git@github.com:aai-labs/ai-starter.git
cd ai-starter
.\scripts\install.ps1 C:\path\to\your\project
```

From bash after cloning:

```bash
git clone --depth=1 git@github.com:aai-labs/ai-starter.git
cd ai-starter
bash scripts/install.sh /path/to/your/project
```

## What you get

- [`AGENTS.md`](AGENTS.md) — the agent entry point: work loop, guardrails, and where to find deeper guidance.
- [`INIT.md`](INIT.md) — one-shot bootstrap prompt the agent follows once per repo to populate `AGENTS.md` with project-specific context (stack, commands, non-obvious patterns) and propose per-module sub-files for monorepos.
- [`CODE_GUIDELINES.md`](CODE_GUIDELINES.md) — backend/API, architecture, review, and definition-of-done rules.
- [`WEBAPP_GUIDELINES.md`](WEBAPP_GUIDELINES.md) — front-end structure, state, routing, imports, and API boundary rules.
- [`TESTING.md`](TESTING.md) — the single home for Python, Node/TypeScript, and browser test conventions.
- [`CHANGELOG.md`](CHANGELOG.md) — feature-level history agents should keep current.

## After importing

1. **Review the files** before committing. Delete anything that does not fit your stack, tighten anything that matters. Treat these guidelines as a baseline, not as permanent boilerplate.
2. **Bootstrap project context.** Open an agent session at the repo root and say *"Follow `INIT.md`."* The agent will discover your stack, commands, and non-obvious patterns from manifests and CI, then insert a populated `## Project context` block into `AGENTS.md`. For monorepos, it will propose per-module sub-`AGENTS.md` files only where modules actually diverge from the root. Review the resulting diff before committing.
3. **Start working.** From this point on, agent sessions read `AGENTS.md` (and any per-module sub-files) automatically; you don't need to re-run `INIT.md` unless the stack or commands change substantially.

## Optional: [Superpowers](https://github.com/obra/superpowers)

[Superpowers](https://github.com/obra/superpowers) is a separate, MIT-licensed **agent methodology** (brainstorm → plan → TDD → subagent execution → review). It ships as composable **skills** that agents load automatically when a task matches.

Use it **alongside** this starter, not instead of it:

| Layer | What it gives you |
|-------|-------------------|
| **ai-starter** (`AGENTS.md`, guidelines) | Project-specific rules: stack, commands, architecture, testing layout, review habits |
| **Superpowers** (skills plugin) | Cross-project process: design refinement, bite-sized plans, red/green TDD, worktrees, subagent-driven execution |

After you import the guideline files and run `INIT.md`, install Superpowers in **Claude Code** or **Codex** so the agent gets both **how this repo works** and **how to run a feature from idea to merge**.

### Install

Install Superpowers separately in each harness you use (Claude Code and Codex each have their own plugin UI).

#### Claude Code

From the [official Claude plugin marketplace](https://claude.com/plugins/superpowers):

```text
/plugin install superpowers@claude-plugins-official
```

Alternatively, register the Superpowers marketplace and install from there:

```text
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

#### Codex CLI

From the [official Codex plugin marketplace](https://github.com/openai/plugins):

1. Open plugin search: `/plugins`
2. Search for `superpowers`
3. Select **Install Plugin**

#### Codex App

1. Open **Plugins** in the sidebar.
2. Find **Superpowers** under **Coding**.
3. Click **+** next to Superpowers and complete the prompts.

**Other harnesses** (Cursor, Gemini CLI, OpenCode, GitHub Copilot CLI, …) — see [obra/superpowers — Installation](https://github.com/obra/superpowers#installation).

Updates are usually handled by the plugin/marketplace for your harness; check [Superpowers releases](https://github.com/obra/superpowers/releases) if you pin versions manually.

### Use

You do not invoke skills by name for normal work. Once installed, the agent **checks for relevant skills before each task** and follows them as mandatory workflows.

Typical flow for a non-trivial feature:

1. **brainstorming** — Clarify goals and trade-offs; present design in short sections for your approval; save a design doc.
2. **using-git-worktrees** — After design sign-off, create an isolated branch/worktree, run setup, confirm tests are green.
3. **writing-plans** — Turn the approved design into small tasks (roughly 2–5 minutes each) with file paths, code sketches, and verification steps.
4. **subagent-driven-development** or **executing-plans** — Execute the plan (subagent per task with spec + quality review, or batched steps with checkpoints).
5. **test-driven-development** — During implementation: failing test → minimal code → pass → refactor (no code before tests).
6. **requesting-code-review** — Between tasks, review against the plan; critical issues block further work.
7. **finishing-a-development-branch** — When done: verify tests, then merge, open a PR, keep the branch, or discard.

Skills also cover **systematic-debugging**, **verification-before-completion**, parallel subagents, and responding to review feedback. Full list: [What's inside](https://github.com/obra/superpowers#whats-inside).

**With this starter:** keep following `AGENTS.md` and the guideline files for *project* constraints (e.g. `TESTING.md` stack choices). Superpowers adds the *process* (planning depth, TDD discipline, worktree hygiene). If both mention planning or tests, treat project guidelines as the source of truth for *what* to test and *how*; use Superpowers for *when* to plan, branch, and verify.

To learn the skill system itself, ask the agent to follow the **using-superpowers** skill after install. Community and issues: [obra/superpowers](https://github.com/obra/superpowers).

## Philosophy

The goal is to make agents behave like a senior engineer on your team rather than a generic code generator: plan before changing, follow established patterns, push back on bad ideas, and keep documentation honest. The guidelines encode that behavior in plain Markdown so it stays reviewable and easy to evolve.
