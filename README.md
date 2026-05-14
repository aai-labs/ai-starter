# ai-coding-starter

A starter kit for **bootstrapping AI coding agents with good development guidelines**.

Drop these files into a new (or existing) project and any agent that respects `AGENTS.md` — Cursor, Claude Code, Codex, and similar tools — picks up a consistent set of conventions for architecture, web app patterns, and testing from day one.

## What's inside

The repository is intentionally small. The substance lives in a handful of guideline documents that the agent is instructed to consult on every task:

- [`AGENTS.md`](AGENTS.md) — entry point for agents: work loop (plan → verify → changelog), **what goes where**, guardrails (always / ask / never), collaboration stance, and pointers to the files below.
- [`CODE_GUIDELINES.md`](CODE_GUIDELINES.md) — project-defining backend/API rules, HTTP, layering, design heuristics, review habits, definition of done.
- [`WEBAPP_GUIDELINES.md`](WEBAPP_GUIDELINES.md) — front-end patterns: Next.js defaults, routing, client/server state, API boundary, imports — **no duplicated testing sections** (see `TESTING.md`).
- [`TESTING.md`](TESTING.md) — **single home for tests**: Python (GivenPy + PyHamcrest), TypeScript/Node (direct HTTP integration), browser E2E (Playwright, page objects, pyramid).
- [`CHANGELOG.md`](CHANGELOG.md) — feature-level change log the agent is expected to keep up to date.

Guideline files use **MUST** / **SHOULD** / **MAY** to signal strictness — see `CODE_GUIDELINES.md` for the convention.

## How to use it

1. Drop the guideline files (`AGENTS.md`, `CODE_GUIDELINES.md`, `WEBAPP_GUIDELINES.md`, `TESTING.md`, `CHANGELOG.md`) into your project root — see snippets below.
2. Tailor each file to your stack — remove sections that don't apply, tighten rules that do. Treat these files as a **starting baseline**, not a floor: delete anything your agent already gets right or that burns context without payoff.
3. Start a session with an agent that reads `AGENTS.md` (Cursor, Claude Code, Codex, etc.). It will pick up the conventions automatically.

### Import into an existing project

Run one of the following from your project root. Each snippet pulls only the guideline files and leaves the rest of this repo behind.

**PowerShell (Windows):**

```powershell
$base  = "https://bitbucket.org/tdisolutions/ai-coding-starter/raw/main"
$files = "AGENTS.md","CODE_GUIDELINES.md","WEBAPP_GUIDELINES.md","TESTING.md","CHANGELOG.md"
foreach ($f in $files) {
    if (Test-Path $f) { Write-Host "skip $f (exists)"; continue }
    Invoke-WebRequest "$base/$f" -OutFile $f
    Write-Host "added $f"
}
```

**bash (Linux / macOS / WSL / Git Bash):**

```bash
base="https://bitbucket.org/tdisolutions/ai-coding-starter/raw/main"
for f in AGENTS.md CODE_GUIDELINES.md WEBAPP_GUIDELINES.md TESTING.md CHANGELOG.md; do
  if [ -e "$f" ]; then echo "skip $f (exists)"; continue; fi
  curl -fsSL "$base/$f" -o "$f" && echo "added $f"
done
```

**git clone + copy** (works for private repos that use SSH/HTTPS auth):

```bash
tmp=$(mktemp -d)
git clone --depth=1 git@bitbucket.org:tdisolutions/ai-coding-starter.git "$tmp"
cp -n "$tmp"/{AGENTS,CODE_GUIDELINES,WEBAPP_GUIDELINES,TESTING,CHANGELOG}.md .
rm -rf "$tmp"
```

> The raw-URL snippets require the repo to be reachable without auth. If it's private, use the `git clone` variant.

After importing, review every file and trim or rewrite anything that doesn't fit your project before committing — these are opinions, not law.

## Philosophy

The goal is to make agents behave like a senior engineer on your team rather than a generic code generator: plan before changing, follow established patterns, push back on bad ideas, and keep documentation honest. The guidelines encode that behavior in plain Markdown so it stays reviewable and easy to evolve.
