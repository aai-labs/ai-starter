# ai-coding-starter

A small starter kit for **bootstrapping AI coding agents with good development guidelines**.

Drop these files into a project and agents that read `AGENTS.md` — Cursor, Claude Code, Codex, and similar tools — get the same working habits, architecture rules, and testing expectations from day one.

## Install in an existing project

Run this from the root of the project you want to configure. Existing files are skipped, not overwritten.

```bash
tmp=$(mktemp -d)
git clone --depth=1 git@bitbucket.org:tdisolutions/ai-coding-starter.git "$tmp"
cp -n "$tmp"/{AGENTS,INIT,CODE_GUIDELINES,WEBAPP_GUIDELINES,TESTING,CHANGELOG}.md .
rm -rf "$tmp"
```

This works on Linux, macOS, WSL, and Git Bash on Windows. For native PowerShell, clone once and run the installer script:

```powershell
git clone --depth=1 git@bitbucket.org:tdisolutions/ai-coding-starter.git
cd ai-coding-starter
.\scripts\install.ps1 C:\path\to\your\project
```

From bash after cloning:

```bash
git clone --depth=1 git@bitbucket.org:tdisolutions/ai-coding-starter.git
cd ai-coding-starter
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

## Philosophy

The goal is to make agents behave like a senior engineer on your team rather than a generic code generator: plan before changing, follow established patterns, push back on bad ideas, and keep documentation honest. The guidelines encode that behavior in plain Markdown so it stays reviewable and easy to evolve.
