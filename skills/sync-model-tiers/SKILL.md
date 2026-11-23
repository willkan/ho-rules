---
name: sync-model-tiers
description: 按本机各 Agent CLI 实时模型目录自动更新 ho-rules/AGENTS.md 中的 subagent 能力档位与推理预算映射。用于模型发新版本、切换新系列或校准选型表，避免手工逐条指定。
---

# 同步模型档位映射

根据本机各 Agent CLI 的实时模型目录与能力定位，一次性更新 `~/dev/ho-rules/AGENTS.md` 中的 subagent 选型表与紧邻说明，不拆成多轮让用户逐条手工指定。

## 1. 采集实时目录（仅读非敏感元数据）

- **Codex**：读取 `~/.codex/models_cache.json`（或运行 `codex debug models`），只提取 `slug`、`display_name`、`description`、`supported_reasoning_levels`、`priority`、`visibility`。
- **Agy**：运行 `agy models` 获取当前可用模型 ID（含预算后缀）。
- **Claude**：核对当前 CLI/运行时支持的跟随版本别名（如 `fable` / `opus` / `sonnet` / `haiku`）与推理预算。
- 严禁读取或回显任何 `api_key`、`token`、`headers`、`auth.json` 等敏感内容。

## 2. 按能力定位一次性映射

按四档任务定位自主判断各 CLI 的最新同档模型与预算，同时保持风格一致：

| 能力档位 | 任务范围 | 选型原则 |
| --- | --- | --- |
| **顶级推理** | 复杂归因、架构取舍；老大难问题重新归因 | 各环境最新顶级推理系列 + 高/最高预算（如 Codex `astra`（最新）/ `xhigh`；Agy 顶级系列 `xhigh`，目录未提供时注明“无则取最高可用预算”；Claude `fable` / `medium`） |
| **主力实现** | 复杂实现、跨文件修复、端到端执行 | 各环境最新主力编码系列 + 中高预算（如 Codex `sol`（最新）/ `medium`；Agy 最新主力系列 `high`；Claude `opus` / `medium`） |
| **局部修复与验证** | 范围清楚的局部修复、UI/浏览器操作、验证 | 各环境高效/均衡系列 + 中档预算（如 Codex `terra`（最新）/ `medium`；Agy 主力/均衡系列 `medium`；Claude `sonnet` / `medium`） |
| **轻量检索与机械修改** | 明确规则下的检索、提取、批量转换、机械修改 | 各环境最新轻量高速系列（如 Codex `luna`（最新）/ `max`；Agy 最新轻量系列 `low`；Claude `haiku` / `low`） |

映射约束：
- **Codex** 用系列名加“（最新）”，不写死具体小版本号，避免每次小版本升级都要改表。
- **Agy** 写 `agy models` 中的准确带预算 ID；有新代际替换旧代际时同步更新表格下方的同档替代边界说明。
- **Claude** 优先使用跟随当前版本的别名。
- 目录中未提供的新模型不猜测 ID，保留不可用兜底说明。

## 3. 更新、验证与汇报

- 直接编辑 `~/dev/ho-rules/AGENTS.md` 的模型映射表及紧邻说明，不改动无关章节。
- 运行 `python3 -m unittest discover -s ~/dev/ho-rules/tests` 确认仓库测试通过。
- 在回复中用简表列出“旧值 → 新值”及对应目录依据，并标出目录暂缺的预算/型号；未经用户授权不执行 commit 或 push。
