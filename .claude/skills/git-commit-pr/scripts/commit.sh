#!/usr/bin/env bash
# Commit staged changes with a Conventional Commits header (+ optional body file).
# Usage: commit.sh "<type>(<scope>): <subject>" [body-file]
set -euo pipefail

header="${1:?usage: commit.sh '<type>(<scope>): <subject>' [body-file]}"
body_file="${2:-}"

pattern='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?: .{1,72}$'
if [[ ! "$header" =~ $pattern ]]; then
  echo "error: header does not follow Conventional Commits: $header" >&2
  exit 1
fi

if git diff --cached --quiet; then
  echo "error: nothing staged to commit" >&2
  exit 1
fi

if [[ -n "$body_file" ]]; then
  if [[ ! -f "$body_file" ]]; then
    echo "error: body file not found: $body_file" >&2
    exit 1
  fi
  msg_file="$(mktemp)"
  trap 'rm -f "$msg_file"' EXIT
  printf '%s\n\n' "$header" > "$msg_file"
  cat "$body_file" >> "$msg_file"
  git commit -F "$msg_file"
else
  git commit -m "$header"
fi
