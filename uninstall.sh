#!/usr/bin/env bash
# Remove symlinks created by install.sh that still point at this repo's AGENTS.md.
# Does not delete real files or backups.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REAL="$(cd "$REPO_ROOT" && pwd)/AGENTS.md"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: ./uninstall.sh [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

TARGETS=(
  "${HOME}/.codex/AGENTS.md"
  "${HOME}/.claude/CLAUDE.md"
  "${HOME}/.claude/AGENTS.md"
  "${HOME}/.grok/rules/AGENTS.md"
  "${HOME}/.cursor/AGENTS.md"
  "${HOME}/.cursor/rules/AGENTS.mdc"
  "${HOME}/.gemini/GEMINI.md"
  "${HOME}/.config/opencode/AGENTS.md"
  "${HOME}/.continue/config/AGENTS.md"
)

for dest in "${TARGETS[@]}"; do
  if [[ ! -L "$dest" ]]; then
    continue
  fi
  target="$(readlink "$dest")"
  if [[ "$target" != /* ]]; then
    target="$(cd "$(dirname "$dest")" && cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")" || continue
  fi
  if [[ "$target" == "$SOURCE_REAL" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY-RUN: rm $dest"
    else
      rm "$dest"
      echo "removed: $dest"
    fi
  fi
done
