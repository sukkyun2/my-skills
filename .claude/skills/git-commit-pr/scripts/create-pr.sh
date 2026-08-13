#!/usr/bin/env bash
# Push the current branch and open a PR with gh, using a filled-in copy of templates/pr-template.md.
# Assigns the PR to the authenticated user and applies a change-type label (behavior/structure/bug).
# Usage: create-pr.sh "<title>" <body-file> [base-branch] [label]
set -euo pipefail

title="${1:?usage: create-pr.sh '<title>' <body-file> [base-branch] [label]}"
body_file="${2:?usage: create-pr.sh '<title>' <body-file> [base-branch] [label]}"
base="${3:-}"
label="${4:-}"

if [[ ! -f "$body_file" ]]; then
  echo "error: body file not found: $body_file" >&2
  exit 1
fi

if [[ -z "$base" ]]; then
  base="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "$base" ]]; then
  echo "error: currently on base branch '$base', switch to a feature branch first" >&2
  exit 1
fi

git push -u origin "$branch"

args=(--title "$title" --body-file "$body_file" --base "$base" --assignee "@me")
if [[ -n "$label" ]]; then
  args+=(--label "$label")
fi
gh pr create "${args[@]}"
