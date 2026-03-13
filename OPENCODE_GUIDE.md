# OpenCode 完整使用指南

> OpenCode 是一个开源的 AI 编程代理（AI coding agent），支持在终端、桌面应用和主流 IDE 中与 AI 交互完成代码相关任务。

## 目录
1. [简介](#简介)
2. [安装](#安装)
3. [启动与基础使用](#启动与基础使用)
4. [项目初始化](#项目初始化)
5. [日常交互](#日常交互)
6. [内置工具](#内置工具)
7. [Skills 系统](#skills-系统)
8. [高级用法](#高级用法)
9. [常用命令速查](#常用命令速查)
10. [参考资源](#参考资源)

---

## 简介

### 核心特性

**两种 Agent 模式：**
- **Build 模式**：全权限，可直接编辑文件、执行命令
- **Plan 模式**：只读规划，默认拒绝编辑，需要确认

**主要功能：**
- 理解代码库、编写新功能、重构代码、修复 Bug
- 自动分析项目结构，生成 AGENTS.md 指南
- 支持 75+ 家模型提供商
- 内置免费模型：GLM-4.7、MiniMax M2.1 等
- 一键生成会话分享链接

**支持平台：**
- 终端（Terminal）- TUI 交互界面
- 桌面应用（Desktop App）
- IDE 集成（VS Code 等）

---

## 安装

### 方式一：一键通用安装脚本（推荐）

```bash
curl -fsSL https://opencode.ai/install | bash
```

验证安装：
```bash
opencode --version  # 应该输出版本号，如 1.1.19
```

### 方式二：包管理器安装

**macOS / Linux：**
```bash
brew install opencode
# 或
npm install -g opencode-ai
```

**Windows：**
```bash
choco install opencode
# 或
scoop bucket add extras
scoop install extras/opencode
```

**Arch Linux：**
```bash
paru -S opencode-bin
```

### 推荐终端工具

- **WezTerm** - 跨平台
- **Alacritty** - 跨平台
- **Ghostty** - Linux & macOS
- **Kitty** - Linux & macOS

### 桌面应用

从 [opencode.ai/download](https://opencode.ai/download) 下载对应平台安装包

| 系统 | 文件 |
|------|------|
| macOS (苹果芯片) | opencode-desktop-darwin-aarch64.dmg |
| macOS (英特尔) | opencode-desktop-darwin-x64.dmg |
| Windows | opencode-desktop-windows-x64.exe |
| Linux | .deb / .rpm / AppImage |

---

## 启动与基础使用

### 首次启动

```bash
cd /path/to/your/project
opencode
```

首次启动会引导完成基础配置：

1. **模型选择**：展示可用模型列表
   - 免费模型（标注 `Free`）：MiniMax M2.1、GLM-4.7 等，无需 API Key
   - 商业模型：OpenAI、Claude 等，需配置 API Key

2. **登录选项**（可选）
   - 跳过登录：稍后需要商业模型时再配置
   - 登录 Claude Code Pro：获取专属模型访问权限

### 查看可用模型

```bash
opencode
# 进入 TUI 后，输入：
/models
```

### 配置 API 密钥

```bash
opencode auth login
# 或在 TUI 中输入：
/connect
```

按提示选择模型提供商并粘贴 API Key

### 退出 OpenCode

```bash
/exit
# 或按 Ctrl+X Q
```

---

## 项目初始化

### 初始化项目

1. 进入项目目录并启动 OpenCode
2. 在 TUI 中运行：
```bash
/init
# 或按 Ctrl+X I
```

**效果：**
- 生成 `.opencode/` 目录（存储向量化索引和自定义指令）
- 扫描代码结构，生成 `AGENTS.md` 文件（记录项目信息）

### 查看 AGENTS.md

OpenCode 自动生成的文件，包含项目的：
- 文件结构说明
- 主要模块描述
- 开发指南

---

## 日常交互

### 提问代码相关问题

**询问代码功能：**
```
文件 @index.html 包含哪些功能
```
其中 `@` 用来引用项目里的文件路径。

**提问代码逻辑：**
```
解释 src/main.ts 中的认证逻辑
```

### 添加新功能

直接描述需求，AI 会自动实现：
```
添加用户注册 API，支持邮箱验证
```

### 切换工作模式

按 **Tab** 键在 **Plan/Build** 模式间切换
- **Plan 模式**：更安全，用于规划和设计
- **Build 模式**：直接修改代码

### 撤销与重做

```bash
/undo      # 撤销最后操作（需 Git 仓库）
/redo      # 重做已撤销的操作
```

### 分享会话

```bash
/share     # 生成分享链接（Ctrl+X S）
/unshare   # 取消分享
```

### 会话管理

```bash
/new       # 开始新会话，清除当前（Ctrl+X N）
/sessions  # 列出并切换已有会话（Ctrl+X L）
/compact   # 压缩/总结当前会话（Ctrl+X C）
```

### 非交互模式（脚本调用）

```bash
opencode -p "修复 login 函数中的 bug"
opencode -p "添加一个登录接口" -f json
```

参数说明：
- `-p, --prompt`：输入提示文本
- `-f, --output-format`：输出格式（text 或 json，默认 text）
- `-q, --quiet`：隐藏加载动画

---

## 内置工具

OpenCode 的 AI Agent 通过以下工具操作代码库（权限可在 `opencode.json` 中配置：allow/deny/ask）

| 工具 | 功能 |
|------|------|
| **bash** | 执行 shell 命令（git status、npm test 等） |
| **write/edit/patch** | 创建/修改/打补丁文件 |
| **read** | 读取文件内容（支持行范围） |
| **grep/glob/list** | 搜索和列出文件（遵守 .gitignore） |
| **webfetch** | 抓取网页内容（查文档） |
| **lsp**（实验） | 代码跳转、悬停提示等 |
| **question** | 向用户提问确认 |
| **todo** | 维护任务清单 |

### 自定义工具与 MCP

支持通过 MCP（Model Context Protocol）服务器扩展能力，如：
- 连接数据库
- 集成外部 API
- 自定义代码分析工具

---

## Skills 系统

### 什么是 Skills？

**Skills** 是 AI 执行特定任务的操作说明书，一旦写好就能反复调用。核心概念：
- **渐进式加载**：只在需要时才完整读取，节省 Token
- **可复用性**：跨项目、跨会话使用
- **一致性**：固定 SOP 模板，避免重复描述

### Skills vs 普通 Prompt

| 方面 | 普通 Prompt | Skills |
|------|-----------|--------|
| 每次描述 | 是 | 否（一次定义） |
| 上下文占用 | 每次全量 | 渐进式加载 |
| 复用方式 | 手动复制 | 自动匹配 |
| 维护方式 | 改 Prompt 重新发 | 修改文件即全局生效 |

### Skills 的工作流程

1. **发现**：启动时，AI 只加载名称和描述
2. **激活**：任务匹配某个 Skills 描述时，读入完整指令
3. **执行**：按照指令执行，按需加载参考文件或脚本

### 存放位置与优先级

| 级别 | 路径 | 生效范围 |
|------|------|---------|
| 个人级 | `~/.claude/skills/<skill-name>/SKILL.md` | 所有项目 |
| 项目级 | `.claude/skills/<skill-name>/SKILL.md` | 仅当前项目 |

**优先级**：项目级 > 个人级

### SKILL.md 最小模板

```yaml
---
name: skill-name
description: 说明该 Skill 的功能和适用场景
---

# 这里开始是正文（Markdown）

你现在是「某个专家角色」。

## 核心原则
- 原则 1
- 原则 2

## 工作流程
1. 步骤 1
2. 步骤 2
```

**必填字段：**
- `name`：技能名（小写+连字符，最多 64 字符）
- `description`：功能说明（最多 1024 字符）

**可选字段：**
- `license`：许可证
- `version`：版本号
- `author`：作者
- `trigger_keywords`：触发关键词（大幅提升自动触发率）

### 完整 SKILL.md 示例

```yaml
---
name: code-comment-expert
description: 为代码添加专业、清晰的中英双语注释
trigger_keywords:
  - 加注释
  - 注释
  - explain code
---

# 代码注释专家

你现在是「专业代码注释专家」。

## 核心原则
- 只在缺少注释或可读性明显不足处添加
- 优先使用英文 JSDoc / TSDoc 风格
- 复杂逻辑处额外加中文解释
- 注释精炼，每行不超过 80 字符
- 绝不修改原有逻辑

## 输出格式
1. 先输出完整修改后的代码块
2. 再用 diff 形式展示只改动注释的部分
3. 最后说明理由
```

### Skills 进阶目录结构

当 Skills 超过 500 行或需要模板/脚本时：

```
~/.claude/skills/react-component-review/
├── SKILL.md              # 核心指令（推荐 400 行内）
├── templates/            # 常用模板
│   ├── functional.tsx.md
│   └── class-component.md
├── examples/             # 优秀/反例
│   ├── good.md
│   └── anti-pattern.md
├── references/           # 规范、规则
│   ├── hooks-rules.md
│   └── naming-convention.md
└── scripts/              # 可执行脚本
    ├── validate-props.py
    └── check-cycle-deps.sh
```

### 安装公开 Skills

从 [skills.sh](https://skills.sh/) 查找并安装：

```bash
npx skills add <owner/repo>
# 例如
npx skills add remotion-dev/skills --skill remotion-best-practices
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max
```

### 推荐 Skills 速查表

| Skills | 用途 | 安装命令 |
|--------|------|---------|
| **remotion-best-practices** | React 视频制作 | `npx skills add remotion-dev/skills` |
| **ui-ux-pro-max** | 专业 UI/UX 设计 | `npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max` |
| **vercel-react-best-practices** | React 性能优化 | `npx skills add vercel-labs/agent-skills` |
| **frontend-design** | 高质量 UI 设计 | `npx skills add anthropics/skills --skill frontend-design` |
| **code-review-expert** | 专业代码审查 | `npx skills add sanyuan0704/code-review-expert` |
| **skill-creator** | 自定义 Skill 构建 | `npx skills add anthropics/skills --skill skill-creator` |

---

## 高级用法

### 自定义命令

在 `~/.config/opencode/commands/` 创建 Markdown 文件，如 `prime-context.md`，内容为预加载指令。

该命令会自动在 OpenCode 中可用。

### 主题与快捷键

在设置中自定义：
- 外观主题（浅色/暗色）
- 快捷键映射

### 多会话并行

同时开启多个 OpenCode 实例处理不同任务：
```bash
opencode -c ~/project1 &
opencode -c ~/project2 &
```

### IDE 集成

**VS Code 扩展：**
搜索安装 "OpenCode extension"

**远程控制：**
通过客户端/服务器架构远程控制 OpenCode

### 权限管理

在 `opencode.json` 中为各工具设置权限：

```json
{
  "tools": {
    "bash": "ask",      // 每次确认
    "write": "allow",   // 自动允许
    "delete": "deny"    // 禁用
  }
}
```

权限值：`allow`（自动允许）、`deny`（禁用）、`ask`（每次确认）

### oh-my-opencode 插件系统

**什么是 oh-my-opencode？**

一个强大的 OpenCode 插件层，将单个 Agent 升级为多智能体协作团队。

**安装：**
```bash
# 在 OpenCode 对话框粘贴以下提示
按照以下说明安装和配置 oh-my-opencode：
https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md
```

**核心功能：**
- **Sisyphus 主智能体**：持续执行复杂任务
- **并行子智能体**：Oracle（预言）、Librarian（文档）、Frontend Engineer（前端）、Explore（探索）
- **多模型调度**：自动分配任务给最适合的模型
- **自动化触发**：关键词 `ultrawork` 或 `ulw`

**使用示例：**
```
ultrawork: 请帮我实现一个 React 组件，支持暗黑模式
```

---

## 常用命令速查

### TUI 中的 Slash 命令

**配置与初始化：**
```bash
/connect      # 添加/配置 LLM 提供商
/init         # 初始化项目（Ctrl+X I）
/models       # 列出并切换模型（Ctrl+X M）
```

**会话管理：**
```bash
/new          # 开始新会话（Ctrl+X N）
/sessions     # 列出并切换会话（Ctrl+X L）
/share        # 分享会话（Ctrl+X S）
/unshare      # 取消分享
/compact      # 压缩/总结会话（Ctrl+X C）
```

**编辑与操作：**
```bash
/undo         # 撤销最后操作（Ctrl+X U）
/redo         # 重做（Ctrl+X R）
/details      # 切换工具执行详情显示（Ctrl+X D）
/thinking     # 切换思考过程可见性
/theme        # 切换主题（Ctrl+X T）
/editor       # 使用外部编辑器撰写消息（Ctrl+X E）
/export       # 导出对话为 Markdown（Ctrl+X X）
```

**帮助与退出：**
```bash
/help         # 显示帮助（Ctrl+X H）
/exit         # 退出 OpenCode（Ctrl+X Q）
```

### CLI 参数（非交互模式）

```bash
opencode --help                          # 显示帮助
opencode -d                              # 启用调试模式
opencode -c /path/to/project             # 指定工作目录
opencode -p "修复这个 bug"               # 非交互模式运行
opencode -p "..." -f json                # 输出 JSON 格式
opencode -p "..." -q                     # 隐藏加载动画
```

---

## 实战案例

### 案例 1：创建 Express.js API

```bash
mkdir my-api && cd my-api
npm init -y
opencode
# 在 TUI 中输入：
/init
# 然后提问：
创建一个 Express.js 服务，支持 /hello 路由返回 JSON { message: 'Hello World' }，并添加 README
```

### 案例 2：使用 remotion-best-practices Skill

```bash
mkdir opencode-video && cd opencode-video
npx skills add remotion-dev/skills
opencode
/remotion
# 提问：
生成一个 Hello World 的演示视频
```

### 案例 3：使用 ui-ux-pro-max Skill

```bash
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max
opencode
/ui
# 提问：
为宠物美容服务搭建着陆页，风格活泼亲和，设置预约按钮
```

---

## 参考资源

### 官方链接

| 资源 | 链接 |
|------|------|
| 官网 | https://opencode.ai/ |
| GitHub | https://github.com/anomalyco/opencode |
| 文档 | https://opencode.ai/docs |
| TUI 命令文档 | https://opencode.ai/docs/tui |
| 下载页面 | https://opencode.ai/download |

### Skills 相关

| 资源 | 链接 |
|------|------|
| Skills 聚合 | https://skills.sh/ |
| Skills 市场 | https://skillsmp.com/zh |
| 官方 Skills 仓库 | https://github.com/anthropics/skills |
| Awesome Claude Skills | https://github.com/ComposioHQ/awesome-claude-skills |

### oh-my-opencode

| 资源 | 链接 |
|------|------|
| GitHub | https://github.com/code-yeongyu/oh-my-opencode |
| 安装指南 | https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md |

---

## 常见问题排查

### 问：首次启动没有模型？
**答：** 执行 `/models` 查看列表，选择标注 `Free` 的免费模型（如 GLM-4.7、MiniMax M2.1）

### 问：如何切换模型？
**答：** 在 TUI 中输入 `/models` 并选择，或使用 `opencode auth login` 配置新的提供商

### 问：如何撤销文件修改？
**答：** 输入 `/undo`（需要项目是 Git 仓库），所有文件变更会自动回滚

### 问：Skills 为什么没有自动触发？
**答：** 添加 `trigger_keywords` 字段到 SKILL.md 的 frontmatter，提升自动匹配率

### 问：能否在多个项目中使用相同 Skills？
**答：** 可以。放在 `~/.claude/skills/` 为个人级（所有项目可用），放在 `.claude/skills/` 为项目级（仅当前项目）

---

**Last Updated**: 2026-03-13
**文档版本**: 1.0.0
