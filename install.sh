#!/usr/bin/env bash
# Install shared AGENTS.md into mainstream coding-agent global rule paths.
# Default mode: symlink (one source of truth). Use --copy to copy instead.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${REPO_ROOT}/AGENTS.md"
MODE="symlink" # symlink | copy
DRY_RUN=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Link (or copy) this repo's AGENTS.md into global paths that common coding agents read.

Options:
  --copy       Copy instead of symlink (default: symlink)
  --symlink    Symlink (default)
  --force      Replace existing non-matching targets without prompting
  --dry-run    Print actions only
  -h, --help   Show help

Targets:
  ~/.codex/AGENTS.md              Codex CLI
  ~/.claude/CLAUDE.md             Claude Code
  ~/.claude/AGENTS.md             Claude Code (alt name)
  ~/.grok/rules/AGENTS.md         Grok Build (home rules)
  ~/.cursor/AGENTS.md             Cursor (home agents file)
  ~/.cursor/rules/AGENTS.mdc      Cursor rules dir (mdc)
  ~/.gemini/GEMINI.md             Gemini CLI
  ~/.config/opencode/AGENTS.md    OpenCode
  ~/.continue/config/AGENTS.md    Continue (if present)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy) MODE="copy"; shift ;;
    --symlink) MODE="symlink"; shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ ! -f "$SOURCE" ]]; then
  echo "ERROR: source not found: $SOURCE" >&2
  exit 1
fi

SOURCE_REAL="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"

log() { printf '%s\n' "$*"; }

resolve_link_target() {
  # $1 = path that is a symlink; print absolute target if possible
  local path="$1"
  local target
  target="$(readlink "$path")"
  if [[ "$target" != /* ]]; then
    local dir
    dir="$(cd "$(dirname "$path")" && pwd)"
    # shellcheck disable=SC2164
    target="$(cd "$dir" && cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")" || {
      printf '%s\n' "$target"
      return 0
    }
  fi
  printf '%s\n' "$target"
}

backup_path() {
  local path="$1"
  local ts bak
  ts="$(date +%Y%m%dT%H%M%S)"
  bak="${path}.bak.${ts}"
  log "  backup: $path -> $bak"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  mv "$path" "$bak"
}

install_one() {
  local dest="$1"
  local label="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  log "==> $label"
  log "    $dest"

  if [[ ! -d "$dest_dir" ]]; then
    log "  mkdir: $dest_dir"
    if [[ "$DRY_RUN" -eq 0 ]]; then
      mkdir -p "$dest_dir"
    fi
  fi

  if [[ -L "$dest" ]]; then
    local target
    target="$(resolve_link_target "$dest")"
    if [[ "$target" == "$SOURCE_REAL" ]]; then
      log "  already linked -> skip"
      return 0
    fi
  fi

  if [[ "$MODE" == "copy" && -f "$dest" && ! -L "$dest" ]]; then
    if cmp -s "$SOURCE" "$dest"; then
      log "  already identical copy -> skip"
      return 0
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$FORCE" -eq 1 || "$DRY_RUN" -eq 1 ]]; then
      backup_path "$dest"
    elif [[ -t 0 ]]; then
      printf "  exists and differs. Replace (backup first)? [y/N] "
      read -r ans
      if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        log "  skipped"
        return 0
      fi
      backup_path "$dest"
    else
      log "  exists; use --force to replace (non-interactive)"
      return 0
    fi
  fi

  if [[ "$MODE" == "symlink" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "  DRY-RUN: ln -sfn $SOURCE_REAL $dest"
    else
      ln -sfn "$SOURCE_REAL" "$dest"
      log "  linked"
    fi
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "  DRY-RUN: cp $SOURCE $dest"
    else
      cp "$SOURCE" "$dest"
      log "  copied"
    fi
  fi
}

log "Source: $SOURCE_REAL"
log "Mode:   $MODE"
log ""

install_one "${HOME}/.codex/AGENTS.md" "Codex CLI"
install_one "${HOME}/.claude/CLAUDE.md" "Claude Code (CLAUDE.md)"
install_one "${HOME}/.claude/AGENTS.md" "Claude Code (AGENTS.md)"
install_one "${HOME}/.grok/rules/AGENTS.md" "Grok Build"
install_one "${HOME}/.cursor/AGENTS.md" "Cursor (home AGENTS.md)"
install_one "${HOME}/.cursor/rules/AGENTS.mdc" "Cursor (rules/AGENTS.mdc)"
install_one "${HOME}/.gemini/GEMINI.md" "Gemini CLI"
install_one "${HOME}/.config/opencode/AGENTS.md" "OpenCode"
install_one "${HOME}/.continue/config/AGENTS.md" "Continue"

log ""
log "Done."
log "Tip: edit only ${SOURCE_REAL} then re-run ./install.sh on each machine after git pull."
if [[ "$MODE" == "copy" ]]; then
  log "Note: --copy mode does not auto-update after edits; re-run install after pull."
fi
