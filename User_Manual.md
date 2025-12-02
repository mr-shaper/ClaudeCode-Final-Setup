# Claude Code 终极配置指南

**状态:** ✅ 测试通过 (已启用 Proxy + 自定义 API)
**版本:** 1.0

本指南将帮助你使用自定义的 Claude API (Kimi/Opendoor) 并启用**完整的原生工具执行能力**（如创建文件、运行命令）。

---

## 📂 项目结构
所有关键文件都已备份在此文件夹中，以防丢失：
- `assets/zshrc_snippet.sh`: 你的 `.zshrc` 配置文件代码片段。
- `assets/CLAUDE.md`: Claude 的"大脑"文件，定义了它的身份和规则。
- `assets/claude.json`: 项目配置文件（包含项目历史等）。
- `assets/settings.local.json`: 权限配置文件（包含已批准的命令，避免重复确认）。
- `assets/restore_script.sh`: **一键还原脚本**。

---

## 🚀 1. 首次安装 / 一键还原 (First-Time Setup)
*如果你更换了新电脑，或者想重置环境，请按以下步骤操作：*

1.  **安装基础依赖**:
    *   Node.js & NPM
    *   Python 3 & Pip
    *   Claude CLI: `npm install -g @anthropic-ai/claude-code`
    *   Claude Proxy:
        ```bash
        git clone https://github.com/fuergaosi233/claude-code-proxy ~/.claude-code-proxy
        pip3 install -r ~/.claude-code-proxy/requirements.txt
        ```

2.  **运行一键还原脚本**:
    ```bash
    # 进入 assets 目录
    cd "/Users/mrshaper/Library/CloudStorage/OneDrive-SharedLibraries-onedrive/文档/Obsidian Vault/AI 应用/ClaudeCode_Final_Setup/assets"
    
    # 运行脚本
    ./restore_script.sh
    ```
    *脚本会自动还原 `.zshrc` 配置、`CLAUDE.md`、以及所有 Claude 配置文件。*

3.  **关键步骤：手动配置账号**
    打开 `~/.zshrc`，找到 "Claude Code 账号配置" 部分，填入你的 API Key。

    ```bash
    # --- Claude Code 账号配置 ---
    # 1. API 设置 (请填入你的 Kimi/Opendoor API Key)
    export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
    export OPENAI_API_KEY="sk-YOUR_KEY_HERE"
    
    # 2. Proxy 设置
    export PORT=8000
    
    # 3. 连接配置
    export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
    # 注意：这里也填同一个 Key！(Claude CLI 需要检查 Key 格式，虽然它实际上是通过 Proxy 转发的)
    export ANTHROPIC_API_KEY="sk-YOUR_KEY_HERE" 
    export ANTHROPIC_MODEL="claudecode/claude-sonnet-4-5-20250929-thinking"
    # ---------------------------
    ```

4.  **还原 Claude 配置文件 (可选 - 恢复项目历史)**:
    如果你想恢复之前的项目历史和权限设置，请手动复制以下文件：
    *   `assets/claude.json` -> 复制到 `~/.claude.json`
    *   `assets/settings.local.json` -> 复制到 `~/.claude/settings.local.json`

5.  **放置大脑文件**:
    确保 `assets/CLAUDE.md` 位于 `.zshrc` 中指定的路径。

---

## 💻 2. 日常使用指南 (Daily Usage)

### 前置检查
确保你已经完成了上面的 **步骤 B**，并且运行了 `source ~/.zshrc` 让配置生效。

### 第一步：启动代理
打开终端，运行：
```zsh
start_claude_proxy
```
*你应该会看到提示: "🚀 Claude Proxy started on port 8000"*

### 第二步：运行 Claude
直接运行：
```zsh
claude "你的提示词..."
```
*   **不需要** 手动指定模型 (已自动配置)。
*   **不需要** 复制粘贴命令 (它现在可以真正创建文件了！)。

---

## 🔧 3. 手动调试模式 (Manual Mode)
如果你想了解底层发生了什么，或者脚本失效了，你可以手动运行以下命令来复现环境：

```zsh
# 1. 加载配置
source ~/.zshrc

# 2. (可选) 手动设置环境变量 - 脚本已自动处理，这里仅作演示
# 告诉 Proxy 去哪里请求 (Kimi/Opendoor)
# 请替换为你自己的 API 地址和 Key
export OPENAI_BASE_URL="https://api.example.com/v1"
export OPENAI_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"

# 告诉 Claude CLI 连接到本地 Proxy (关键步骤！)
export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
# 这里通常填一样的 Key，用于 CLI 格式校验
export ANTHROPIC_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"

# 3. 启动 Claude (指定模型)
claude --model claudecode/claude-sonnet-4-5-20250929-thinking
```

### 🧪 测试案例
进入 Claude 后，你可以输入以下指令来测试工具执行能力：

```text
@~/.claude/CLAUDE.md 我需要在这里/Users/mrshaper/Library/CloudStorage/OneDrive-SharedLibraries-onedrive/文档/Obsidian Vault/TEST 创建一个md，写一个50字的小故事
```

**预期结果：** Claude 会直接创建文件，而不是给你一段代码让你复制。

---

## 🔄 4. 切换配置 (Switching Configs)

### 切换回官方 Claude (Standard)
如果你想使用官方 Anthropic API (付费账号)：
1.  打开 `~/.zshrc`。
2.  **注释掉** 整个 "Claude Code Configuration" 代码块 (在 `export` 行前面加 `#`)。
3.  运行 `source ~/.zshrc`。
4.  运行 `claude /login` 进行官方登录。

### 切换回自定义 API (Custom)
1.  取消 `~/.zshrc` 中的注释。
2.  运行 `source ~/.zshrc`。
3.  运行 `start_claude_proxy`。

---

## ⚠️ 故障排除 (Troubleshooting)

*   **404 Error**: 通常意味着 Proxy 没启动，或者 URL 配置错了。请运行 `start_claude_proxy`。
*   **Auth Conflict (权限冲突)**: 运行 `claude` -> 输入 `/logout` -> 退出重试。
