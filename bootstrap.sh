#!/usr/bin/env bash
# Bootstrap ho-rules: clone/update repo and install the `ho-rules` CLI entry.
#
# Quick install (public repo):
#   curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash
#
# With agent links:
#   curl -fsSL .../bootstrap.sh | bash -s -- --all
#
# Private repo (needs network auth for git clone; fetch script via gh or token):
#   gh api repos/willkan/ho-rules/contents/bootstrap.sh --jq .content \
#     | base64 --decode | bash -s -- --all
#   # or:
#   curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" \
#     -H "Accept: application/vnd.github.raw" \
#     https://api.github.com/repos/willkan/ho-rules/contents/bootstrap.sh | bash
#
# Env:
#   HO_RULES_HOME   install dir (default: ~/dev/ho-rules)
#   HO_RULES_REPO   git URL (default: https://github.com/willkan/ho-rules.git)
#   HO_RULES_REF    branch/tag (default: main)
set -euo pipefail

HO_RULES_HOME="${HO_RULES_HOME:-${HOME}/dev/ho-rules}"
HO_RULES_REPO="${HO_RULES_REPO:-https://github.com/willkan/ho-rules.git}"
HO_RULES_REF="${HO_RULES_REF:-main}"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"
}

need git

# Default: only CLI entry. Pass --all / -a / agent ids to also link agents.
INSTALL_ARGS=(--cli --force)
if [[ $# -gt 0 ]]; then
  INSTALL_ARGS+=("$@")
fi

log "ho-rules bootstrap"
log "  home: $HO_RULES_HOME"
log "  repo: $HO_RULES_REPO"
log "  ref:  $HO_RULES_REF"
log ""

if [[ -d "${HO_RULES_HOME}/.git" ]]; then
  log "==> existing clone"
  if git -C "$HO_RULES_HOME" remote get-url origin >/dev/null 2>&1; then
    if git -C "$HO_RULES_HOME" fetch --quiet origin "$HO_RULES_REF" 2>/dev/null; then
      if [[ -n "$(git -C "$HO_RULES_HOME" status --porcelain)" ]]; then
        log "  working tree dirty; skip pull, install from local"
      else
        if git -C "$HO_RULES_HOME" rev-parse --verify "origin/${HO_RULES_REF}" >/dev/null 2>&1; then
          git -C "$HO_RULES_HOME" checkout --quiet "$HO_RULES_REF" 2>/dev/null \
            || git -C "$HO_RULES_HOME" checkout --quiet -B "$HO_RULES_REF" "origin/${HO_RULES_REF}"
          if git -C "$HO_RULES_HOME" pull --ff-only --quiet origin "$HO_RULES_REF" 2>/dev/null; then
            log "  updated to origin/${HO_RULES_REF}"
          else
            log "  could not ff-only pull; using local tree"
          fi
        else
          log "  origin/${HO_RULES_REF} missing; using local tree"
        fi
      fi
    else
      log "  fetch failed (offline or remote empty); using local tree"
    fi
  else
    log "  no origin remote; using local tree"
  fi
else
  if [[ -e "$HO_RULES_HOME" ]]; then
    die "path exists but is not a git repo: $HO_RULES_HOME"
  fi
  log "==> cloning"
  mkdir -p "$(dirname "$HO_RULES_HOME")"
  git clone --branch "$HO_RULES_REF" --single-branch "$HO_RULES_REPO" "$HO_RULES_HOME" \
    || die "clone failed; check HO_RULES_REPO / credentials (private repos need SSH or gh auth)"
fi

[[ -x "${HO_RULES_HOME}/ho-rules" ]] || die "ho-rules entry missing after clone: ${HO_RULES_HOME}/ho-rules"

log "==> installing CLI entry"
"${HO_RULES_HOME}/ho-rules" install "${INSTALL_ARGS[@]}"

bin_dir="${HOME}/dev/bin"
if [[ ! -d "$bin_dir" ]]; then
  bin_dir="${HOME}/.local/bin"
fi

log ""
log "Done. Try: ho-rules help"
case ":${PATH}:" in
  *":${bin_dir}:"*) ;;
  *)
    log "Add to PATH if needed:"
    log "  export PATH=\"${bin_dir}:\$PATH\""
    ;;
esac
