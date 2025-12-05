# Claude Code CLI 完整解决方案手册

> **核心功能**：一键切换官方/自定义源 (`claude-switch`)，强制代理 Thinking 模型，本地文件系统完全控制。

## ⚙️ 核心环境变量配置 (User Config)

所有配置均位于 `~/.zshrc` 中的 `claude-switch` 函数内。修改后需运行 `source ~/.zshrc` 生效。

| 变量名 | 描述 | 示例值 |
| :--- | :--- | :--- |
| `OPENAI_BASE_URL` | 自定义 API 端点 | `https://ai.opendoor.cn/v1` |
| `OPENAI_API_KEY` | 自定义 API 密钥 | `sk-EhA5...` |
| `ANTHROPIC_MODEL` | **主模型** (用于复杂任务) | `claude-sonnet-4-5-20250929-thinking` |
| `SMALL_MODEL` | **轻量模型** (用于快速/简单任务) | `claude-haiku-4-5-20251001` 或 `gpt-4o-mini` |
| `ANTHROPIC_BASE_URL` | **本地代理地址** (勿动) | `http://127.0.0.1:8000` |
| `PORT` | 本地代理端口 | `8000` |

---

## 🚀 日常操作流程

### 1. 启动/切换模式

**自定义 API 模式 (推荐)**
启动本地代理，自动配置 API Key，接管 `claude` 命令。
```bash
claude-switch proxy
```
*(成功标志：输出 `🚀 Claude Proxy started on port 8000`)*

**官方原生模式**
清除所有自定义配置，还原为官方 OAuth 登录状态。
```bash
claude-switch native
```

### 2. 切换模型 (实时生效)

**查看当前模型**
```bash
claude-switch model
```

**切换指定模型**
```bash
# Claude 4.5 Sonnet (Thinking)
claude-switch model claude-sonnet-4-5-20250929-thinking

# Kimi k2 (Thinking)
claude-switch model kimi-k2-thinking

# Gemini 3 Pro
claude-switch model gemini-3-pro-preview-thinking
```

---

## 🛠 维护与更新指南

### 更新项目代码

当 GitHub 仓库有更新时（修复 Bug 或增强功能）：

1.  进入项目目录：
    ```bash
    cd "/Users/mrshaper/Library/CloudStorage/OneDrive-SharedLibraries-onedrive/文档/Obsidian Vault/AI 应用/ClaudeCode_Final_Setup"
    ```
2.  拉取最新代码：
    ```bash
    git pull
    ```
3.  **关键步骤**：如果更新了 `assets/zshrc_snippet.sh`，必须重新应用到 zshrc：
    ```bash
    # 重新加载配置
    source ~/.zshrc
    ```
    *(或者直接编辑 `~/.zshrc` 手动更新函数定义)*

### 故障排查 (Troubleshooting)

*   **症状**：AI 说"我无法通过 API 读取文件" 或 "请你自己运行命令"。
*   **原因**：模型丢失 Agent 身份或 Proxy 没拦截到请求。
*   **修复**：
    1.  确认已运行 `claude-switch proxy`。
    2.  检查代理日志：
        ```bash
        tail -f ~/.claude-code-proxy/proxy.log
        ```
    3.  强制重启代理：
        ```bash
        claude-switch proxy
        ```

---

## 📂 项目文件结构

*   `assets/CLAUDE.md`: **系统提示词 (核心)** - 定义 AI 的 Agent 身份和工具使用规则。
*   `assets/config.json`: **MCP 工具配置** - Brave Search, Puppeteer, GitHub 配置。
*   `assets/zshrc_snippet.sh`: **Shell 函数定义** - `claude-switch` 的源代码。
*   `assets/proxy_patches/`: **Python 代理源码** - 中转和格式转换逻辑。