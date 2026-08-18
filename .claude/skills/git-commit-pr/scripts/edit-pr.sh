#!/usr/bin/env bash
# Update an existing PR's body (and optionally title) with gh.
# Assigns the PR to the authenticated user only if it currently has no assignee.
# Usage: edit-pr.sh <pr-number-or-url> <body-file> [title]
set -euo pipefail

pr="${1:?usage: edit-pr.sh <pr-number-or-url> <body-file> [title]}"
body_file="${2:?usage: edit-pr.sh <pr-number-or-url> <body-file> [title]}"
title="${3:-}"

if [[ ! -f "$body_file" ]]; then
  echo "error: body file not found: $body_file" >&2
  exit 1
fi

args=(--body-file "$body_file")
if [[ -n "$title" ]]; then
  args+=(--title "$title")
fi
gh pr edit "$pr" "${args[@]}"

assignee_count="$(gh pr view "$pr" --json assignees -q '.assignees | length')"
if [[ "$assignee_count" == "0" ]]; then
  gh pr edit "$pr" --add-assignee "@me"
fi
