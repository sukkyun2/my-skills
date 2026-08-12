#!/usr/bin/env bash
# Create and switch to a branch following <type>/<issue-number>-<slug> (or <type>/<slug>).
# Usage: new-branch.sh <type> <slug> [issue-number]
set -euo pipefail

type="${1:?usage: new-branch.sh <type> <slug> [issue-number]}"
slug="${2:?usage: new-branch.sh <type> <slug> [issue-number]}"
issue="${3:-}"

valid_types="feat fix docs refactor chore hotfix"
if [[ ! " $valid_types " == *" $type "* ]]; then
  echo "error: invalid type '$type' (allowed: $valid_types)" >&2
  exit 1
fi

slug="$(echo "$slug" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//')"
if [[ -z "$slug" ]]; then
  echo "error: slug is empty after normalization" >&2
  exit 1
fi

if [[ -n "$issue" ]]; then
  if [[ ! "$issue" =~ ^[0-9]+$ ]]; then
    echo "error: issue-number must be numeric, got '$issue'" >&2
    exit 1
  fi
  branch="${type}/${issue}-${slug}"
else
  branch="${type}/${slug}"
fi

git switch -c "$branch"
echo "$branch"
