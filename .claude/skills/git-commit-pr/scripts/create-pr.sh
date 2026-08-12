#!/usr/bin/env bash
# Push the current branch and open a PR with gh, using a filled-in copy of templates/pr-template.md.
# Usage: create-pr.sh "<title>" <body-file> [base-branch]
set -euo pipefail

title="${1:?usage: create-pr.sh '<title>' <body-file> [base-branch]}"
body_file="${2:?usage: create-pr.sh '<title>' <body-file> [base-branch]}"
base="${3:-main}"

if [[ ! -f "$body_file" ]]; then
  echo "error: body file not found: $body_file" >&2
  exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "$base" ]]; then
  echo "error: currently on base branch '$base', switch to a feature branch first" >&2
  exit 1
fi

git push -u origin "$branch"
gh pr create --title "$title" --body-file "$body_file" --base "$base"
