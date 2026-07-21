# agent-rules

一份跨机器、跨 coding agent 共用的全局规则：`AGENTS.md`。

编辑以本仓库根目录的 **`AGENTS.md` 为唯一真相**，用 `install.sh` 挂到各 agent 会读的全局路径。

## 新机器 / 多机同步

```bash
# 1. clone
git clone <your-github-url> ~/dev/agent-rules
cd ~/dev/agent-rules

# 2. 安装到本机各 agent 路径（默认 symlink）
./install.sh --force
```

之后只改仓库里的 `AGENTS.md`，`git push` / 另一台 `git pull`。  
symlink 模式下 pull 后无需重装；`--copy` 模式下 pull 后要再跑一次 `./install.sh --force`。

## 脚本

| 命令 | 说明 |
|------|------|
| `./install.sh` | 交互安装（已有文件会询问） |
| `./install.sh --force` | 覆盖已有目标（先备份为 `*.bak.<timestamp>`） |
| `./install.sh --copy` | 复制而非软链（适合不支持 symlink 的环境） |
| `./install.sh --dry-run` | 只打印将要执行的操作 |
| `./uninstall.sh` | 删除仍指向本仓库的 symlink |

## 安装目标

| Agent | Path |
|-------|------|
| Codex CLI | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/CLAUDE.md`、`~/.claude/AGENTS.md` |
| Grok Build | `~/.grok/rules/AGENTS.md` |
| Cursor | `~/.cursor/AGENTS.md`、`~/.cursor/rules/AGENTS.mdc` |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` |
| Continue | `~/.continue/config/AGENTS.md` |

说明：

- 父目录不存在时会自动创建。
- 若目标已是指向本仓库的 symlink，会跳过。
- 替换真实文件前会备份，不会静默覆盖。

## 工作流建议

1. 只在 `~/dev/agent-rules` 里改 `AGENTS.md`
2. commit / push
3. 其他机器 `git pull`（symlink 即生效）

不要反过来在 `~/.codex/AGENTS.md` 等路径直接改内容——那些应是指向本仓库的链接。

## 发布到 GitHub

```bash
cd ~/dev/agent-rules
gh repo create agent-rules --private --source=. --remote=origin --push
# 或 public:
# gh repo create agent-rules --public --source=. --remote=origin --push
```

## License

Private personal rules by default. Adjust if you make the repo public.
