#!/usr/bin/env bash
# Safely fast-forward non-checked-out dev/main branches in all discovered repositories.
set -uo pipefail

root="${HOME}/Desktop/workspaces"
dry_run=false

if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
  shift
fi
if [[ -n "${1:-}" ]]; then
  root="$1"
fi
if [[ ! -d "$root" ]]; then
  echo "error: repository root not found: $root" >&2
  exit 1
fi

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

branch_is_checked_out() {
  local repo="$1" branch="$2"
  git -C "$repo" worktree list --porcelain | grep -Fxq "branch refs/heads/${branch}"
}

sync_branch() {
  local repo="$1" branch="$2" local_ref remote_ref

  if ! git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    log "skip ${repo}: origin/${branch} is absent"
    return
  fi

  if ! git -C "$repo" show-ref --verify --quiet "refs/heads/${branch}"; then
    if "$dry_run"; then
      log "would create ${repo}: ${branch} tracking origin/${branch}"
    else
      git -C "$repo" branch --track "$branch" "origin/${branch}"
      log "${repo}: created ${branch} tracking origin/${branch}"
    fi
    return
  fi

  local_ref="$(git -C "$repo" rev-parse "refs/heads/${branch}")"
  remote_ref="$(git -C "$repo" rev-parse "refs/remotes/origin/${branch}")"
  if [[ "$local_ref" == "$remote_ref" ]]; then
    log "${repo}: ${branch} is up to date"
  elif branch_is_checked_out "$repo" "$branch"; then
    log "skip ${repo}: ${branch} is checked out by a worktree"
  elif git -C "$repo" merge-base --is-ancestor "$local_ref" "$remote_ref"; then
    if "$dry_run"; then
      log "would fast-forward ${repo}: ${branch}"
    else
      git -C "$repo" update-ref "refs/heads/${branch}" "$remote_ref" "$local_ref"
      log "${repo}: fast-forwarded ${branch}"
    fi
  elif git -C "$repo" merge-base --is-ancestor "$remote_ref" "$local_ref"; then
    log "skip ${repo}: ${branch} is ahead of origin/${branch}"
  else
    log "skip ${repo}: ${branch} diverged from origin/${branch}"
  fi
}

sync_repo() {
  local repo="$1"
  if ! git -C "$repo" remote get-url origin >/dev/null 2>&1; then
    log "skip ${repo}: origin is absent"
    return
  fi

  if "$dry_run"; then
    log "would fetch ${repo}"
  elif ! git -C "$repo" fetch --prune origin; then
    log "skip ${repo}: origin fetch failed"
    return
  fi

  sync_branch "$repo" dev
  sync_branch "$repo" main
}

while IFS= read -r -d '' git_entry; do
  sync_repo "${git_entry%/.git}"
done < <(find "$root" -name .git -print0)
