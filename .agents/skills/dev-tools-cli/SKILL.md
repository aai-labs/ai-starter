---
name: dev-tools-cli
description: Reference for interacting with GitHub (gh CLI), and the Atlassian stack — Jira, Confluence, Bitbucket, JSM — via atlassian-cli. Use when reading/writing issues, PRs, pages, or comments in any of these tools.
metadata:
  short-description: CLI reference for GitHub, Jira, Bitbucket, and Confluence
---

# Dev Tools CLI Reference

Two primary tools:
- **`gh`** — GitHub CLI (official, mature)
- **`atlassian-cli`** — Unified Rust binary for Jira + Confluence + Bitbucket + JSM (community, Cloud-only)

Always use `--format json` or `--json` with field selectors to keep output minimal. Never dump raw full-list responses into context.

**⚠️ atlassian-cli is Cloud-only.** For Data Center/Server, fall back to `curl` against the REST API.

---

## Authentication

### atlassian-cli — Jira & Confluence

```bash
atlassian-cli auth login \
  --profile work \
  --base-url https://your-domain.atlassian.net \
  --email you@company.com \
  --token $ATLASSIAN_API_TOKEN \
  --default
```

Config stored in `~/.atlassian-cli/config.yaml` (AES-256-GCM encrypted). Supports multiple profiles.

### atlassian-cli — Bitbucket (separate token required)

Bitbucket needs a **scoped token** — not the same as the Jira/Confluence API token.
Create at: `id.atlassian.com → Security → API tokens → Create API token with scopes → Bitbucket app`

Required scopes: `read:repository:bitbucket`, `write:repository:bitbucket`, `read:pullrequest:bitbucket`
Note: `admin:*` does NOT include `read:*` — add both explicitly.

```bash
export ATLASSIAN_CLI_BITBUCKET_TOKEN_WORK=your-scoped-token   # profile-aware, highest priority
# or
export ATLASSIAN_BITBUCKET_TOKEN=your-scoped-token
```

**⚠️ App passwords (the old kind) stop working June 2026.** Use scoped tokens instead.

### GitHub CLI

```bash
export GH_TOKEN=your-github-token
# or: gh auth login
```

---

## GitHub (`gh`)

### PRs

```bash
# List open PRs (minimal fields)
gh pr list --state open -L 10 --json number,title,author,updatedAt

# View a PR
gh pr view 123 --json number,title,state,author,body,url

# View with reviews and CI status
gh pr view 123 --json number,title,reviews,state,statusCheckRollup

# Comment
gh pr comment 123 --body "LGTM"
gh pr comment 123 --body-file ./review.md

# Approve / request changes
gh pr review 123 --approve
gh pr review 123 --request-changes --body "Please fix X"

# Create
gh pr create --title "Feature X" --body "Description" --base main
```

### Issues

```bash
# List open issues assigned to me
gh issue list --state open --assignee @me -L 10 --json number,title,labels,updatedAt

# View an issue
gh issue view 42 --json number,title,body,state,labels,url

# Comment
gh issue comment 42 --body "Investigating..."

# Search across org
gh search issues --owner myorg --label "bug" --state open -L 10 --json number,title,url
```

### Raw API (when gh commands aren't enough)

```bash
# GraphQL — fetch PR + inline comments in one call
gh api graphql -f query='{ repository(owner:"org",name:"repo") { pullRequest(number:123) { title comments(first:10) { nodes { body author { login } } } } } }'

# REST
gh api repos/org/repo/pulls/123/reviews
```

---

## Jira (`atlassian-cli jira`)

### Search & read

```bash
# Search with JQL (most powerful)
atlassian-cli jira search --jql "project = PROJ AND status = 'To Do' AND assignee = currentUser()" --limit 10 --format json

# Get single issue
atlassian-cli jira get PROJ-123 --format json

# List fields (to find custom field IDs)
atlassian-cli jira fields list --format json
```

### Create & update

```bash
# Create issue
atlassian-cli jira create --project PROJ --issue-type Bug --summary "Title here" --format json

# Create with custom fields
atlassian-cli jira create --project PROJ --issue-type Task --summary "Title" \
  --field 'customfield_10010={"value":"Internal"}'

# Update
atlassian-cli jira update PROJ-123 --summary "New title"

# Transition status
atlassian-cli jira transition PROJ-123 --transition "In Progress"

# Assign
atlassian-cli jira assign PROJ-123 --assignee user@company.com
```

**⚠️ Known bug:** Mutating commands (update, transition) may report an error even on success (HTTP 204 parsing issue). Verify with a follow-up `get` if exit code matters.

### Bulk operations

```bash
# Bulk transition (dry-run first)
atlassian-cli jira bulk transition --jql "project = PROJ AND status = Open" --transition "In Progress" --dry-run
atlassian-cli jira bulk transition --jql "project = PROJ AND status = Open" --transition "In Progress"

# Bulk assign
atlassian-cli jira bulk assign --jql "project = PROJ AND assignee is EMPTY" --assignee admin@company.com

# Export to file
atlassian-cli jira bulk export --jql "project = PROJ" --output issues.json --format json
```

### Project metadata

```bash
atlassian-cli jira project list --format json
atlassian-cli jira workflows list --format json
atlassian-cli jira versions list --project PROJ --format json
atlassian-cli jira components list --project PROJ --format json
```

**JQL quick reference:**
- `assignee = currentUser()` — my issues
- `sprint in openSprints()` — current sprint
- `created >= -7d` — last 7 days
- `ORDER BY updated DESC` — freshest first

---

## Confluence (`atlassian-cli confluence`)

### Search

```bash
# CQL search
atlassian-cli confluence search cql --cql "space = DOCS and type = page and text ~ \"keyword\"" --limit 10 --format json

# Text search
atlassian-cli confluence search text --query "meeting notes" --limit 10 --format json

# Within a space
atlassian-cli confluence search in-space --space DOCS --query "api docs" --format json
```

### Pages

```bash
# List pages in a space
atlassian-cli confluence page list --space DOCS --limit 25 --format json

# Get a page
atlassian-cli confluence page get --id 12345 --format json

# Create
atlassian-cli confluence page create --space DOCS --title "New Page" --body "<p>Content</p>"

# Update
atlassian-cli confluence page update --id 12345 --title "Updated Title" --body "<p>New content</p>"

# Comments
atlassian-cli confluence page comments --id 12345 --format json
atlassian-cli confluence page add-comment --id 12345 --body "Great work!"

# Labels
atlassian-cli confluence page add-label --id 12345 --label documentation

# Page versions
atlassian-cli confluence page versions --id 12345 --format json
```

**Note:** Body content is HTML (Storage Format), not Markdown. Use `<p>`, `<h1>`, `<ul>`, etc.
Unlike raw API, atlassian-cli handles the version bump automatically on update.

### Spaces

```bash
atlassian-cli confluence space list --limit 10 --format json
atlassian-cli confluence space create --key DOCS --name "Documentation" --description "Team docs"
atlassian-cli confluence space permissions DOCS --format json
atlassian-cli confluence space add-permission DOCS --principal user@company.com --operation read
```

### Bulk operations

```bash
# Bulk add labels (dry-run first)
atlassian-cli confluence bulk add-labels --cql "space = DOCS" --labels docs,reviewed --dry-run
atlassian-cli confluence bulk add-labels --cql "space = DOCS" --labels docs,reviewed

# Export space
atlassian-cli confluence bulk export --space DOCS --output backup.json --format json
```

**CQL quick reference:**
- `space = KEY` — filter by space
- `type = page` or `type = blogpost`
- `creator = "user@company.com"`
- `created >= "2025-01-01"`
- `text ~ "keyword"` — full-text search

---

## Bitbucket (`atlassian-cli bitbucket --workspace WORKSPACE`)

```bash
# Repos
atlassian-cli bitbucket --workspace myteam repo list --format json
atlassian-cli bitbucket --workspace myteam repo get api-service --format json

# Pull requests
atlassian-cli bitbucket --workspace myteam pr list api-service --state OPEN --limit 10 --format json
atlassian-cli bitbucket --workspace myteam pr create api-service \
  --title "Feature X" --source feature/x --destination main
atlassian-cli bitbucket --workspace myteam pr approve api-service 123
atlassian-cli bitbucket --workspace myteam pr merge api-service 123 --strategy merge_commit

# Branches
atlassian-cli bitbucket --workspace myteam branch list api-service --format json
atlassian-cli bitbucket --workspace myteam branch protect api-service \
  --pattern "main" --kind restrict_merges --approvals 2

# Pipelines (CI)
atlassian-cli bitbucket --workspace myteam pipeline list api-service --format json
atlassian-cli bitbucket --workspace myteam pipeline trigger api-service --ref-name main
atlassian-cli bitbucket --workspace myteam pipeline stop api-service {uuid}
```

**PR states:** `OPEN`, `MERGED`, `DECLINED`, `SUPERSEDED`

---

## Context discipline rules

- Always pass `--format json` and pipe through `jq` with field selectors — never read full table output
- Use `--limit` on every list command — defaults can be large
- Use `--dry-run` before any bulk operation
- Fetch issue comments separately from the issue — only pull when you need them
- Write JQL/CQL before fetching — filter server-side, not in shell
- For Jira mutations, verify success with a follow-up `get` due to the HTTP 204 bug

---

## Fallback: Data Center / Server

atlassian-cli is Cloud-only. For DC/Server use `curl` with basic auth:

```bash
# Jira DC search
curl -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "https://jira.yourcompany.com/rest/api/2/search?jql=project=PROJ&maxResults=10" \
  | jq '.issues[] | {key, summary: .fields.summary, status: .fields.status.name}'

# Confluence DC page list
curl -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "https://confluence.yourcompany.com/rest/api/content?type=page&spaceKey=DOCS&limit=10" \
  | jq '.results[] | {id, title}'
```
