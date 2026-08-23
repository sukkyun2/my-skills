#!/usr/bin/env bash
# Sync this repo's .claude/skills/* into the user-scope ~/.claude/skills/,
# so edits made here take effect globally. Run after changing a skill.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.claude/skills"
DEST="$HOME/.claude/skills"

mkdir -p "$DEST"

for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  rsync -a --delete "$skill" "$DEST/$name/"
  echo "synced: $name"
done
