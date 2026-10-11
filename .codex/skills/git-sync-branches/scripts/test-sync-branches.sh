#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

git init --bare "$test_root/origin.git" >/dev/null
git init -b main "$test_root/seed" >/dev/null
git -C "$test_root/seed" config user.email test@example.com
git -C "$test_root/seed" config user.name test
touch "$test_root/seed/README.md"
git -C "$test_root/seed" add README.md
git -C "$test_root/seed" commit -m seed >/dev/null
git -C "$test_root/seed" remote add origin "$test_root/origin.git"
git -C "$test_root/seed" push -u origin main >/dev/null
git --git-dir="$test_root/origin.git" symbolic-ref HEAD refs/heads/main
git -C "$test_root/seed" switch -c dev >/dev/null
git -C "$test_root/seed" push -u origin dev >/dev/null
git clone "$test_root/origin.git" "$test_root/workspaces/repo" >/dev/null
git -C "$test_root/workspaces/repo" branch --track dev origin/dev >/dev/null

touch "$test_root/seed/dev-change"
git -C "$test_root/seed" add dev-change
git -C "$test_root/seed" commit -m 'update dev' >/dev/null
git -C "$test_root/seed" push origin dev >/dev/null

"$skill_dir/scripts/sync-branches.sh" "$test_root/workspaces" >/dev/null
test "$(git -C "$test_root/workspaces/repo" rev-parse dev)" = "$(git -C "$test_root/seed" rev-parse dev)"
echo "OK git-sync-branches"
