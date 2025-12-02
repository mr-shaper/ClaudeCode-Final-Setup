# AI Deployment Protocol: Claude Code Custom Setup

**Target System:** macOS / Zsh
**Objective:** Deploy Claude Code CLI with `claude-code-proxy` for OpenAI-compatible APIs (e.g., Kimi).

## 🤖 Auto-Deployment Script

This script automates the entire setup using the provided `restore_script.sh`.

```bash
#!/bin/bash
set -e

# 1. Define Paths
PROXY_DIR="$HOME/.claude-code-proxy"
ASSETS_DIR="./assets"
RESTORE_SCRIPT="$ASSETS_DIR/restore_script.sh"

echo "🤖 Starting AI Deployment..."

# 2. Install Proxy
if [ ! -d "$PROXY_DIR" ]; then
    echo "Installing claude-code-proxy..."
    git clone https://github.com/fuergaosi233/claude-code-proxy "$PROXY_DIR"
    pip3 install -r "$PROXY_DIR/requirements.txt"
else
    echo "Proxy already installed."
fi

# 3. Run Restoration Script
if [ -f "$RESTORE_SCRIPT" ]; then
    chmod +x "$RESTORE_SCRIPT"
    "$RESTORE_SCRIPT"
else
    echo "Error: restore_script.sh not found in assets."
    exit 1
fi

echo "✅ Software & Functions Installed."
echo "⚠️  ACTION REQUIRED: You MUST manually add your API Keys to .zshrc!"
echo "See User_Manual.md for the configuration block."
```

## 📂 File Locations

| Component          | Location on Disk                                                                                                    |
| :----------------- | :------------------------------------------------------------------------------------------------------------------ |
| **Proxy**          | `~/.claude-code-proxy`                                                                                              |
| **Config**         | `~/.zshrc` (Appended)                                                                                               |
| **Brain (Prompt)** | `/Users/mrshaper/Library/Mobile Documents/com~apple~CloudDocs/Career/US Project/Claude_Code_优化配置/configs/CLAUDE.md` |
| **Logs**           | `~/.claude-code-proxy/proxy.log`                                                                                    |

## 🧩 Key Configuration Logic

The setup relies on three environment variables working in harmony:
1.  `OPENAI_BASE_URL`: Points the Proxy to the *Real* API (e.g., `ai.opendoor.cn`).
2.  `ANTHROPIC_BASE_URL`: Points the CLI to the *Proxy* (`http://127.0.0.1:8000`).
3.  `ANTHROPIC_MODEL`: Forces the CLI to send the specific model string the API expects.

## 🔄 Mode Switching

We provide a `claude-switch` command to easily toggle between modes:

- `claude-switch native`: Switch to official Anthropic API (requires login).
- `claude-switch proxy`: Switch to Custom API Proxy (Kimi/Opendoor).
- `claude-switch model "model-name"`: Change the model used by the proxy.
