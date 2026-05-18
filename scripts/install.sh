#!/usr/bin/env bash
set -euo pipefail

target_path="${1:-.}"
source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$(cd "$target_path" && pwd)"
files=(AGENTS.md INIT.md CODE_GUIDELINES.md WEBAPP_GUIDELINES.md TESTING.md CHANGELOG.md)

for file in "${files[@]}"; do
  source="$source_root/$file"
  target="$target_root/$file"

  if [ -e "$target" ]; then
    echo "skip $file (already exists)"
    continue
  fi

  cp "$source" "$target"
  echo "added $file"
done
