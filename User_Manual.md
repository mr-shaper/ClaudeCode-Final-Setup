# Claude Code 终极配置指南

**状态:** ✅ 测试通过 (已启用 Proxy + 自定义 API)
**版本:** 2.2.0 (2025-12-04)

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
    
    # 4. 模型配置 (v2.2.0 更新)
    # 使用真实的 Claude 模型名称，避免 gpt-4o 错误
    export ANTHROPIC_MODEL="claude-sonnet-4-5-20250929-thinking"
    export SMALL_MODEL="claude-haiku-4-5-20251001"
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

### 3. 文件格式兼容性说明 (File Compatibility)

由于我们使用了 Proxy 转发，不同类型文件的处理方式略有不同：

| 文件类型 | 格式示例 | 兼容性 | 说明 |
| :--- | :--- | :--- | :--- |
| **纯文本文件** | `.md`, `.txt`, `.csv`, `.html`, `.xml`, `.svg`, 代码文件 (`.py`, `.js` 等) | ✅ **完美支持** | Claude 会直接读取文件内容，**完整发送**给 API。你可以让它读取、分析、修改这些文件。 |
| **文档/二进制** | `.pdf`, `.docx` (Word), `.xlsx` (Excel), `.pptx` (PPT) | ✅ **完美支持** | **Proxy 已升级！** 它会自动提取这些文件中的**纯文本内容**发给 Claude。你可以让 Claude 总结 PDF、分析 Excel 数据或润色 PPT 大纲。 |
| **图片** | `.jpg`, `.png`, `.gif` | ✅ **支持** | 会转换为 OpenAI 兼容格式发送 (依赖 API 提供商对图片的支持能力)。 |

**建议**：
*   **推荐**：直接拖入 PDF/Word/Excel 让 Claude 处理，无需手动转换。
*   **注意**：对于 Excel，它会读取所有 Sheet 的数据并转为 CSV 格式供 Claude 分析。

---
## 🌐 4. 联网搜索配置 (Web Search)

Claude Code 支持通过 MCP 插件进行联网搜索。

### 1. 安装必要组件
在终端运行：
```bash
# 1. 安装 ripgrep (搜索核心组件)
brew install ripgrep

# 2. 安装 Brave Search 插件
npm install -g @modelcontextprotocol/server-brave-search
```

### 2. 配置 Brave Search 插件 (最终解决方案)

**核心原则**：直接使用 `claude mcp` 命令配置，它会自动处理配置文件路径，避免"全局配置 vs 项目配置"的冲突。

**第一步：清理旧配置 (如果报错 "already exists")**
```bash
claude mcp remove brave-search
```

**第二步：添加新配置 (一键搞定)**
直接运行下面这行命令（替换你的 Key）：
```bash
claude mcp add brave-search -e BRAVE_API_KEY=你的_Key_粘贴在这里 -- /usr/local/bin/node ~/.claude/mcp/node_modules/@modelcontextprotocol/server-brave-search/dist/index.js
```

**为什么这样做？**
1.  **`-e BRAVE_API_KEY=...`**：直接把 Key 写入配置，**以后启动不需要再手动 export 了！**
2.  **`/usr/local/bin/node`**：使用绝对路径，防止因为环境变量问题找不到 Node。
3.  **`~/.claude/mcp/...`**：指向我们之前安装好的插件代码。

### 3. 常见问题：搜索结果为 0 (Did 0 searches)
如果你看到 `Did 0 searches`，这通常意味着：
1.  **你直接搜索了一个 URL**：Brave 搜索引擎可能没有收录这个具体的长链接。**解决方法**：请使用关键词搜索，例如 `claude "搜索一下 Kimi 的价格"`。
2.  **API Key 无效**：请检查你的 Key 是否正确。


---

## 🛠️ 5. 进阶技能 (Advanced Skills)

除了联网搜索，我们还为你准备了两个强大的进阶技能：**Puppeteer (浏览器自动化)** 和 **GitHub (代码仓库管理)**。

### 1. Puppeteer (网页自动化)
让 Claude 拥有一个真实的浏览器，可以截图、点击按钮、抓取动态网页数据。

**安装命令：**
```bash
claude mcp add puppeteer -- npx -y @modelcontextprotocol/server-puppeteer
```

**使用示例：**
*   "去 example.com 截个图"
*   "把这个网页转成 PDF"
*   "点击页面上的'登录'按钮"

### 2. GitHub (仓库管理)
让 Claude 直接操作你的 GitHub 仓库，查看 Issue、提交 PR、搜索代码。

**安装命令：**
```bash
# 注意：这需要先申请 GitHub Personal Access Token
export GITHUB_PERSONAL_ACCESS_TOKEN=你的_Token
claude mcp add github -- npx -y @modelcontextprotocol/server-github
```

---

## 🐛 6. Debugging & Logs

### New Behavior Logging (v2.3.0)
We have introduced a powerful logging system to diagnose "why Claude is acting stupid" (e.g., claiming to read files but not reading them).

**Log File Location:** `~/.claude-code-proxy/behavior.log`

This log captures the **full conversation** between Claude and the upstream API, including:
*   `CLAUDE_REQUEST`: What Claude (CLI) sent to the Proxy.
*   `OPENAI_REQUEST`: What the Proxy sent to Kimi/DeepSeek (Crucial for checking if file content was actually sent).
*   `OPENAI_RESPONSE`: What Kimi/DeepSeek replied.

**How to use:**
```bash
# View the detailed behavior log
tail -f ~/.claude-code-proxy/behavior.log
```

### 🔧 Fix for File Reading Failure

If Claude says "I will read the file" but nothing happens (no file content is shown), it is likely due to a missing ID in the tool call from the API provider.

We have prepared a one-click fix script:

```bash
# Run the fix script
"/Users/mrshaper/Library/CloudStorage/OneDrive-SharedLibraries-onedrive/文档/Obsidian Vault/AI 应用/ClaudeCode_Final_Setup/assets/fix_proxy.sh"
```

This script will:
1. Patch the proxy to handle missing tool call IDs.
2. Restart the proxy automatically.
3. **Hide "Thinking" Output**: Stops the model from reciting system instructions (the "Idiot" behavior).

### ⚠️ Auth Conflict Warning

If you see: `Auth conflict: Both a token (claude.ai) and an API key (ANTHROPIC_API_KEY) are set.`

**Solution:**
You must log out of the official Claude account to use the Proxy exclusively.
In the Claude Code terminal, type:
```
/logout
```
(Or run `claude logout` in your normal terminal).

### Standard Logs
If you just want to see connection status:
```bash
tail -f ~/.claude-code-proxy/proxy.log
```

### Common Error Codes

| Error | Meaning | Solution |
|-------|---------|----------|
| 503 | Service Unavailable | The upstream model is down. Switch models using `claude-switch model ...` |
| 401 | Unauthorized | API Key is invalid. Check `ANTHROPIC_API_KEY` in `~/.zshrc`. |
| 400 | Bad Request | Request format error. Check logs for details. |
| **Crash** | **"NoneType is not iterable"** | **Fixed in v2.2.0**. Run `assets/restore_script.sh` to update your proxy patches. |
