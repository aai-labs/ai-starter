#!/usr/bin/env bash
set -euo pipefail

REQUESTED_BASE="${1:-}"

if [ -n "$REQUESTED_BASE" ]; then
  BASE="$REQUESTED_BASE"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  BASE="origin/main"
elif git rev-parse --verify origin/master >/dev/null 2>&1; then
  BASE="origin/master"
else
  DEFAULT_BRANCH="$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}' || true)"
  BASE="${DEFAULT_BRANCH:+origin/$DEFAULT_BRANCH}"
fi

if [ -z "${BASE:-}" ]; then
  echo "Could not determine base branch."
  echo "Pass a base branch explicitly, for example:"
  echo "  bash .agents/skills/review-branch-diff/scripts/collect-review-context.sh origin/main"
  exit 1
fi

if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  echo "Base branch '$BASE' is not a valid ref in this repository."
  echo "Pass an existing base branch explicitly."
  exit 1
fi

echo "## Current branch"
git branch --show-current

echo
echo "## Base branch"
echo "$BASE"

echo
echo "## Working tree status"
git status --short

echo
echo "## Merge base"
git merge-base HEAD "$BASE"

echo
echo "## Diff stat"
git diff --stat "$BASE"...HEAD

echo
echo "## Changed files"
git diff --name-status "$BASE"...HEAD

echo
echo "## Recent commits on this branch"
git log --oneline "$BASE"..HEAD

echo
echo "## Full diff"
git diff --find-renames "$BASE"...HEAD