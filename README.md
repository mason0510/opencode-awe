# OpenCode 完整使用指南

> 🚀 **OpenCode** - 开源的 AI 编程代理（AI coding agent），支持在终端、桌面应用和主流 IDE 中与 AI 交互完成代码相关任务。

## ✨ 核心特性

### 两种 Agent 模式
- **Build 模式**：全权限，可直接编辑文件、执行命令
- **Plan 模式**：只读规划，默认拒绝编辑，需要确认

### 主要功能
- 🧠 理解代码库、编写新功能、重构代码、修复 Bug
- 📊 自动分析项目结构，生成 AGENTS.md 指南
- 🤖 支持 75+ 家模型提供商
- 🆓 内置免费模型：GLM-4.7、MiniMax M2.1 等
- 🔗 一键生成会话分享链接

### 支持平台
- 💻 **终端**（Terminal）- TUI 交互界面
- 🖥️ **桌面应用**（Desktop App）
- 🔌 **IDE 集成**（VS Code 等）

## 📦 安装

### 一键通用安装脚本（推荐）

```bash
curl -fsSL https://opencode.ai/install | bash
```

验证安装：
```bash
opencode --version  # 应该输出版本号，如 1.1.19
```

### 包管理器安装

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

## 🚀 快速开始

```bash
# 进入你的项目目录
cd /path/to/your/project

# 启动 OpenCode
opencode

# 首次启动会引导完成配置：
# 1. 选择 AI 模型（推荐免费模型）
# 2. （可选）登录获取商业模型访问权限
```

### 初始化项目

```bash
# 在 OpenCode TUI 中运行：
/init

# 效果：
# - 生成 `.opencode/` 目录
# - 扫描代码结构，生成 `AGENTS.md` 文件
```

## 💬 日常交互

### 询问代码问题
```
文件 @index.html 包含哪些功能
```

### 添加新功能
```
添加用户注册 API，支持邮箱验证
```

### 切换工作模式
按 **Tab** 键在 **Plan/Build** 模式间切换

### 分享会话
```bash
/share     # 生成分享链接
/unshare   # 取消分享
```

## 🛠️ 核心命令速查

### TUI 中的 Slash 命令

| 命令 | 快捷键 | 功能 |
|------|--------|------|
| `/connect` | - | 添加/配置 LLM 提供商 |
| `/init` | Ctrl+X I | 初始化项目 |
| `/models` | Ctrl+X M | 列出并切换模型 |
| `/new` | Ctrl+X N | 开始新会话 |
| `/sessions` | Ctrl+X L | 列出并切换会话 |
| `/share` | Ctrl+X S | 分享会话 |
| `/undo` | Ctrl+X U | 撤销最后操作 |
| `/redo` | Ctrl+X R | 重做操作 |
| `/help` | Ctrl+X H | 显示帮助 |
| `/exit` | Ctrl+X Q | 退出 OpenCode |

### CLI 参数（非交互模式）

```bash
opencode --help                    # 显示帮助
opencode -d                        # 启用调试模式
opencode -c /path/to/project       # 指定工作目录
opencode -p "修复这个 bug"         # 非交互模式运行
opencode -p "..." -f json          # 输出 JSON 格式
```

## 🎨 Skills 系统

**Skills** 是 AI 执行特定任务的可复用操作说明书。

### 安装公开 Skills

```bash
npx skills add <owner/repo>

# 例如：
npx skills add remotion-dev/skills --skill remotion-best-practices
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max
```

### 推荐 Skills

| Skills | 用途 |
|--------|------|
| **remotion-best-practices** | React 视频制作 |
| **ui-ux-pro-max** | 专业 UI/UX 设计 |
| **code-review-expert** | 专业代码审查 |
| **frontend-design** | 高质量 UI 设计 |

## 📖 完整文档

本仓库包含详细的 OpenCode 使用指南：
- **OPENCODE_GUIDE.md** - 完整使用手册（601 行）
- **opencode.json** - 配置文件示例

## 🔗 官方资源

| 资源 | 链接 |
|------|------|
| 官网 | https://opencode.ai/ |
| GitHub | https://github.com/anomalyco/opencode |
| 文档 | https://opencode.ai/docs |
| 下载 | https://opencode.ai/download |
| Skills 市场 | https://skills.sh/ |

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙋 常见问题

**Q: 首次启动没有模型？**
A: 执行 `/models` 查看列表，选择标注 `Free` 的免费模型

**Q: 如何切换模型？**
A: 在 TUI 中输入 `/models` 并选择

**Q: 能否撤销文件修改？**
A: 输入 `/undo`（需要项目是 Git 仓库）

**Q: Skills 为什么没有自动触发？**
A: 添加 `trigger_keywords` 字段到 SKILL.md

---

**最后更新**：2026-03-13
**文档版本**：1.0.0
