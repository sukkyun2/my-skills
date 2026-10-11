---
name: git-sync-branches
description: Safely synchronize origin/dev and origin/main into local branches across repositories under the Desktop workspaces directory. Use for checking or configuring periodic dev/main branch updates.
---

# Sync Default Branches

Run [the sync script](scripts/sync-branches.sh) to update Git repositories under `~/Desktop/workspaces`:

```bash
scripts/sync-branches.sh
```

It fetches `origin`, then considers `dev` and `main` independently. It creates a missing local tracking branch and fast-forwards a local branch only when it is not checked out by any worktree. It skips missing remote branches, local branches that are ahead or diverged, and checked-out branches. It never stashes, resets, merges, rebases, or switches the user's working branch.

Use `--dry-run` to report the actions that current remote-tracking refs would permit without mutating local branches:

```bash
scripts/sync-branches.sh --dry-run
```

The installed LaunchAgent runs the same script every 60 minutes. Check `~/.codex/logs/git-sync-branches.log` for its output. Before changing the schedule or target root, inspect [the LaunchAgent template](assets/com.sukkyun2.git-branch-sync.plist).
