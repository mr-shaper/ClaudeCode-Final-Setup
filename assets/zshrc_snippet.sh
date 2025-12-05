# Claude Code Helper Functions
# ==============================================================================

# Claude Code Configuration (via Local Proxy)
# The Proxy translates Claude's requests to OpenAI format for your custom API
# Default Configuration Values
export OPENAI_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"
export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
export PORT=8000
export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
export ANTHROPIC_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"
export ANTHROPIC_MODEL="claudecode/claude-sonnet-4-5-20250929-thinking"
export ANTHROPIC_SMALL_FAST_MODEL="claude-haiku-4-5-20251001"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5-20251001"
export SMALL_MODEL="claude-haiku-4-5-20251001"
export BRAVE_API_KEY="YOUR_BRAVE_API_KEY_HERE"

# Function to switch modes and models
claude-switch() {
    if [[ "$1" == "native" ]]; then
        unset ANTHROPIC_API_KEY
        unset ANTHROPIC_BASE_URL
        unset OPENAI_API_KEY
        unset OPENAI_BASE_URL
        unset ANTHROPIC_MODEL
        unset ANTHROPIC_SMALL_FAST_MODEL
        unset ANTHROPIC_DEFAULT_HAIKU_MODEL
        unset SMALL_MODEL
        echo "✅ Switched to Native Claude (Official Account)"
        echo "Run 'claude login' if you haven't logged in."
    elif [[ "$1" == "proxy" ]]; then
        export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
        export OPENAI_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"
        export PORT=8000
        export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
        export ANTHROPIC_API_KEY="sk-YOUR_OPENAI_API_KEY_HERE"
        export ANTHROPIC_MODEL="claudecode/claude-sonnet-4-5-20250929-thinking"
        export ANTHROPIC_SMALL_FAST_MODEL="claude-haiku-4-5-20251001"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5-20251001"
        export SMALL_MODEL="claude-haiku-4-5-20251001"
        echo "🚀 Switched to Custom API Proxy Mode"
        start_claude_proxy
    elif [[ "$1" == "model" ]]; then
        if [[ -n "$2" ]]; then
            # Strip surrounding quotes if present
            model_name="${2//\"/}"
            model_name="${model_name//\'/}"
            export ANTHROPIC_MODEL="$model_name"
            echo "✅ Model switched to: $model_name"
            echo "🔄 Restarting proxy to apply model change..."
            start_claude_proxy
        else
            echo "Current model: $ANTHROPIC_MODEL"
            echo "Usage: claude-switch model <model_name>"
        fi
    else
        echo "Usage: claude-switch [native|proxy|model]"
    fi
}

# Function to start the proxy in background
start_claude_proxy() {
    # Kill any existing proxy instances
    pkill -f "src.main" 2>/dev/null
    pkill -f "start_proxy.py" 2>/dev/null
    sleep 0.5
    
    nohup python3 ~/.claude-code-proxy/start_proxy.py > ~/.claude-code-proxy/proxy.log 2>&1 &
    echo "🚀 Claude Proxy started on port 8000"
    echo "Logs: ~/.claude-code-proxy/proxy.log"
}

# Claude Code Context Injection & Model Enforcement
claude() {
    # 配置文件路径
    local config_file="$HOME/.claude/CLAUDE.md"
    
    # 构造基础命令
    local cmd=("command" "claude")

    # 1. 强制使用自定义模型 (Thinking)
    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        if [[ "$*" != *"--model"* ]]; then
            if [[ -n "$ANTHROPIC_MODEL" ]]; then
                cmd+=("--model" "$ANTHROPIC_MODEL")
            fi
        fi
    fi

    # 2. 注入身份认知 (关键修复)
    # 使用 --append-system-prompt 将 CLAUDE.md 的内容附加到系统提示中
    # 这样既保留了 Claude Code 的原生能力，又增加了您的自定义身份
    if [[ -f "$config_file" ]]; then
         # 读取文件内容并转义换行符，防止 Shell 错误
         local sys_prompt=$(cat "$config_file")
         if [[ "$*" != *"--append-system-prompt"* ]]; then
             cmd+=("--append-system-prompt" "$sys_prompt")
         fi
    fi
    
    "${cmd[@]}" "$@"
}
