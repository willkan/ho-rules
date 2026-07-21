# ho-rules

[English](README.md) | [中文](README.zh-CN.md)

跨机器、跨 coding agent 共用的全局规则。**唯一真相**是本仓库的 `AGENTS.md`。

仓库地址：`git@github.com:willkan/ho-rules.git`

统一入口：

```bash
ho-rules <command>
```

## 一键安装（curl）

默认只安装 **`ho-rules` CLI 入口**（软链到 `~/dev/bin` 或 `~/.local/bin`），并把仓库放到 `~/dev/ho-rules`。

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash
```

同时挂上全部 agent 全局规则路径：

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- --all
```

只挂部分 agent：

```bash
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- -a codex,claude,grok
```

### 环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `HO_RULES_HOME` | `~/dev/ho-rules` | 本地仓库路径 |
| `HO_RULES_REPO` | `git@github.com:willkan/ho-rules.git` | git remote URL |
| `HO_RULES_REF` | `main` | 分支 / tag |

示例：

```bash
HO_RULES_HOME=~/src/ho-rules HO_RULES_REF=main \
  curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash -s -- --cli --force
```

安装后确认：

```bash
ho-rules version
ho-rules status
```

确保 `~/dev/bin`（或 `~/.local/bin`）在 `PATH` 中。

---

## 手动安装

```bash
git clone git@github.com:willkan/ho-rules.git ~/dev/ho-rules
cd ~/dev/ho-rules

# 仅 CLI 入口
./ho-rules install --cli --force

# CLI + 全部 agent 路径
./ho-rules install --all --force --cli

# 或只装部分
./ho-rules install -a codex,claude,grok --force
./ho-rules install codex cursor --force
```

## 命令

| 命令 | 说明 |
|------|------|
| `ho-rules install` | 软链 `AGENTS.md` 到 agent 全局路径（默认 symlink） |
| `ho-rules uninstall` | 删除指向本仓库的软链 |
| `ho-rules status` | 查看各路径安装状态 |
| `ho-rules list` | 列出可选 agent id |
| `ho-rules update` | `git pull --ff-only` 拉取最新规则 |
| `ho-rules publish` | 提交 `AGENTS.md`、推 branch、开 PR |
| `ho-rules path` | 打印仓库路径 |
| `ho-rules help [cmd]` | 帮助 |

### install 选型

```bash
ho-rules install --cli --force          # 仅 CLI 入口（bootstrap 默认）
ho-rules install --all --force          # 全部 agent
ho-rules install --all --force --cli    # 全部 agent + CLI
ho-rules install -a codex,claude        # 逗号分隔
ho-rules install -a grok -a cursor      # 重复 -a
ho-rules install codex gemini           # 位置参数
```

默认始终是 **软链接**。只有环境不能 symlink 时才用 `--copy`（不推荐）。

### 多机同步

```bash
# 机器 A：改规则并提 PR
cd ~/dev/ho-rules
# edit AGENTS.md
ho-rules publish -m "clarify git author policy"

# 合并后，机器 B：
ho-rules update
# 或重新跑 bootstrap（已有 clone 会 ff-only 更新）
curl -fsSL https://raw.githubusercontent.com/willkan/ho-rules/main/bootstrap.sh | bash

# symlink 已指向文件，pull 即生效
```

### publish

```bash
ho-rules publish -m "update fallback policy"
ho-rules publish -m "..." -b rules/my-topic --base main
ho-rules publish -m "..." --draft
ho-rules publish -m "..." --no-pr    # 只推 branch
```

需要 `origin` remote 和已登录的 `gh`（开 PR 时）。

## Agent 路径

| id | 路径 |
|----|------|
| `codex` | `~/.codex/AGENTS.md` |
| `claude` | `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md` |
| `grok` | `~/.grok/rules/AGENTS.md` |
| `cursor` | `~/.cursor/AGENTS.md`, `~/.cursor/rules/AGENTS.mdc` |
| `gemini` | `~/.gemini/GEMINI.md` |
| `opencode` | `~/.config/opencode/AGENTS.md` |
| `continue` | `~/.continue/config/AGENTS.md` |

只在本仓库改 `AGENTS.md`，不要在 `~/.codex/...` 等链接路径上直接当“源文件”维护。
