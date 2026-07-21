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
#     https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash
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

INSTALL_ARGS=(--cli --force)
# Default: only CLI entry. Pass --all / -a / agent ids to also link agents.
if [[ $# -eq 0 ]]; then
  :
else
  INSTALL_ARGS+=("$@")
fi

log "ho-rules bootstrap"
log "  home: $HO_RULES_HOME"
log "  repo: $HO_RULES_REPO"
log "  ref:  $HO_RULES_REF"
log ""

if [[ -d "${HO_RULES_HOME}/.git" ]]; then
  log "==> updating existing clone"
  git -C "$HO_RULES_HOME" remote get-url origin >/dev/null 2>&1 \
    || git -C "$HO_RULES_HOME" remote add origin "$HO_RULES_REPO"
  # Prefer configured origin; do not force-overwrite remote URL unless empty
  git -C "$HO_RULES_HOME" fetch --quiet origin "$HO_RULES_REF"
  if [[ -n "$(git -C "$HO_RULES_HOME" status --porcelain)" ]]; then
    die "working tree dirty at $HO_RULES_HOME; commit/stash or set a clean HO_RULES_HOME"
  fi
  git -C "$HO_RULES_HOME" checkout --quiet "$HO_RULES_REF"
  git -C "$HO_RULES_HOME" pull --ff-only --quiet origin "$HO_RULES_REF" \
    || git -C "$HO_RULES_HOME" reset --hard "origin/${HO_RULES_REF}"
else
  if [[ -e "$HO_RULES_HOME" ]]; then
    die "path exists but is not a git repo: $HO_RULES_HOME"
  fi
  log "==> cloning"
  mkdir -p "$(dirname "$HO_RULES_HOME")"
  git clone --branch "$HO_RULES_REF" --single-branch "$HO_RULES_REPO" "$HO_RULES_HOME"
fi

[[ -x "${HO_RULES_HOME}/ho-rules" ]] || die "ho-rules entry missing after clone: ${HO_RULES_HOME}/ho-rules"

log "==> installing CLI entry"
# shellcheck disable=SC2086
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
