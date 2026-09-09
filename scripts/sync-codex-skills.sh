#!/usr/bin/env bash
# Sync this repository's Codex skills into the user's Codex skill directory.
set -euo pipefail

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.codex/skills"
target_root="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$target_root"

for skill in "$source_root"/*/; do
  name="$(basename "$skill")"
  rsync -a --delete "$skill" "$target_root/$name/"
  echo "synced: $name"
done
