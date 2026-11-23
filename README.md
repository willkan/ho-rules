# ho-rules

[English](README.md) | [中文](README.zh-CN.md)

A small toolkit to keep **one** `AGENTS.md` as the source of truth and symlink it into the global paths that common coding agents read.

Repository: `git@github.com:willkan/ho-rules.git`

## Use your own rules (recommended)

The `AGENTS.md` in this repo is **my** working rules, not a universal standard. For your own setup:

1. **Fork** this repository on GitHub.
2. Edit `AGENTS.md` in your fork to match how you want agents to behave.
3. Install from **your fork** (not this upstream), then keep iterating on your fork.

```bash
# After forking to github.com/<you>/ho-rules
git clone git@github.com:<you>/ho-rules.git ~/dev/ho-rules
cd ~/dev/ho-rules
# edit AGENTS.md
./ho-rules install --all --force --cli
```

Or with curl bootstrap against your fork’s raw URL / SSH remote:

```bash
HO_RULES_REPO=git@github.com:<you>/ho-rules.git \
  curl -fsSL https://raw.githubusercontent.com/<you>/ho-rules/main/bootstrap.sh | bash -s -- --all
```

Upstream here is mainly the **CLI + install layout**. Treat rule text as personal; pull tooling fixes from upstream if you want, keep `AGENTS.md` on your fork.

Unified CLI:

```bash
ho-rules <command>
```

## One-line install (curl)

By default this only installs the **`ho-rules` CLI entry** (symlink into `~/dev/bin` or `~/.local/bin`) and places the repo at `~/dev/ho-rules`.

Prefer installing from **your fork**. The examples below use this repo’s URLs; replace `willkan` with your GitHub user after forking.

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash
```

Also link all agent global rule paths:

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- --all
```

Selected agents only:

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- -a codex,claude,grok
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HO_RULES_HOME` | `~/dev/ho-rules` | Local repo path |
| `HO_RULES_REPO` | `git@github.com:willkan/ho-rules.git` | Git remote URL (set to your fork) |
| `HO_RULES_REF` | `main` | Branch / tag |

Example:

```bash
HO_RULES_HOME=~/src/ho-rules HO_RULES_REF=main \
  curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- --cli --force
```

After bootstrap, PATH is written into **`~/.zshrc`** (zsh) or **`~/.bash_profile`** (bash). The install log tells you to:

```bash
source ~/.zshrc          # or: source ~/.bash_profile
# or open a new terminal
ho-rules version
ho-rules status
```

`curl | bash` cannot change your current shell’s environment; `source` / new window is required once.

---

## Manual install

```bash
git clone git@github.com:willkan/ho-rules.git ~/dev/ho-rules   # or your fork
cd ~/dev/ho-rules

# CLI only
./ho-rules install --cli --force

# CLI + all agent paths
./ho-rules install --all --force --cli

# Selected agents
./ho-rules install -a codex,claude,grok --force
./ho-rules install codex cursor --force
```

## Commands

| Command | Description |
|---------|-------------|
| `ho-rules install` | Symlink `AGENTS.md` into agent global paths (default: symlink) |
| `ho-rules uninstall` | Remove symlinks that point at this repo |
| `ho-rules status` | Show install status for each path |
| `ho-rules list` | List available agent ids |
| `ho-rules update` | `git pull --ff-only` latest rules |
| `ho-rules publish` | Commit `AGENTS.md`, push branch, open PR |
| `ho-rules path` | Print repo path |
| `ho-rules help [cmd]` | Help |

### install selection

```bash
ho-rules install --cli --force          # CLI only (bootstrap default)
ho-rules install --all --force          # all agents
ho-rules install --all --force --cli    # all agents + CLI
ho-rules install -a codex,claude        # comma-separated
ho-rules install -a grok -a cursor      # repeated -a
ho-rules install codex gemini           # positional
```

Default is always **symlink**. Use `--copy` only when symlinks are unavailable (not recommended).

### Multi-machine sync

```bash
# Machine A: edit rules and open a PR
cd ~/dev/ho-rules
# edit AGENTS.md
ho-rules publish -m "clarify git author policy"

# After merge, machine B:
ho-rules update
# or re-run bootstrap (existing clone ff-only updates)
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash

# Symlinks already point at the file; pull is enough
```

### publish

```bash
ho-rules publish -m "update fallback policy"
ho-rules publish -m "..." -b rules/my-topic --base main
ho-rules publish -m "..." --draft
ho-rules publish -m "..." --no-pr    # push branch only
```

Requires `origin` remote and authenticated `gh` when creating a PR.

## Agent paths

| id | Path |
|----|------|
| `codex` | `~/.codex/AGENTS.md` |
| `claude` | `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md` |
| `grok` | `~/.grok/rules/AGENTS.md` |
| `cursor` | `~/.cursor/AGENTS.md`, `~/.cursor/rules/AGENTS.mdc` |
| `gemini` | `~/.gemini/GEMINI.md` |
| `agy` | `~/.gemini/GEMINI.md` (shared with Gemini CLI) |
| `opencode` | `~/.config/opencode/AGENTS.md` |
| `continue` | `~/.continue/config/AGENTS.md` |

Edit only this repo’s `AGENTS.md`. Do not treat `~/.codex/...` (and similar) link targets as the source of truth.


## Bundled skills

```bash
ho-rules install-skills agy --dry-run
ho-rules install-skills agy
ho-rules install-skills -a codex,claude
ho-rules install-skills --all
```

`install` installs rules; `install-skills` links each folder containing
`skills/<name>/SKILL.md` from this repository. It defaults to all supported
skills targets. Matching links are skipped. Existing conflicting files,
directories and links are preserved and produce a nonzero exit status.
`--force` backs them up under `~/.local/state/ho-rules/backups/` before replacing
them; backups stay outside skill discovery directories. `--dry-run` writes nothing.
Start a new agent session to discover newly installed skills. For Agy, type
`/advisor` to select the advisor skill; installation does not invoke a review.

Verified global skills roots (2026-11-12; default profiles):

| Agent | Skills root |
| --- | --- |
| Codex | `~/.agents/skills/` |
| Claude Code | `~/.claude/skills/` |
| Grok Build | `~/.grok/skills/` |
| Cursor | `~/.cursor/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| Agy CLI | `~/.gemini/antigravity-cli/skills/` |
| OpenCode | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/` |
| Continue | Not supported by this installer: no verified global skills root |

These are local discovery roots, not a guarantee that remote/cloud agents share
local files. Agent settings may disable skills. Codex currently also discovers
legacy `~/.codex/skills/` locally; avoid installing the same skill in both roots
if your version shows duplicate entries. This command leaves existing legacy
installations untouched.

### Rules path audit

The rule links above predate this audit. Confirmed native global entries include
Codex `~/.codex/AGENTS.md` (or its configured Codex home; an `AGENTS.override.md`
takes precedence), Claude `~/.claude/CLAUDE.md`, Gemini and Agy
`~/.gemini/GEMINI.md`, and OpenCode `~/.config/opencode/AGENTS.md`.
Grok documents global rules under `~/.grok/` and project `.grok/rules/*.md`.
The existing Grok link is retained; verify discovered files with `grok inspect`.
Cursor documents project `AGENTS.md`/`.cursor/rules/*.mdc` and User Rules in
settings; the legacy `~/.cursor/` links above are not proof of global loading.
Continue documents project `.continue/rules/`; the legacy
`~/.continue/config/AGENTS.md` link is not a verified current global entry.
`status` checks link state, not whether an agent injected it into its prompt.

Sources: [Codex skills](https://developers.openai.com/codex/skills/),
[Codex rules](https://developers.openai.com/codex/guides/agents-md/),
[Claude skills](https://code.claude.com/docs/en/skills),
[Claude memory](https://code.claude.com/docs/en/memory),
[Grok skills](https://docs.x.ai/build/features/skills-plugins-marketplaces),
[Grok rules](https://docs.x.ai/build/features/project-rules),
[Cursor skills](https://cursor.com/docs/skills),
[Cursor rules](https://cursor.com/docs/rules),
[Gemini skills](https://geminicli.com/docs/cli/using-agent-skills/),
[Agy rules](https://antigravity.google/docs/rules/),
[Agy skills](https://www.agy.dev/docs/skills/),
[OpenCode skills](https://opencode.ai/docs/skills/),
[OpenCode rules](https://opencode.ai/docs/rules/),
[Continue rules](https://docs.continue.dev/customize/rules).

Validation: `bash -n ho-rules` and `python3 -m unittest discover -s tests -v`.
