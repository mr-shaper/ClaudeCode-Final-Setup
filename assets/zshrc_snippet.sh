# Add local bin to PATH for manual installs (e.g. ripgrep)
export PATH="$HOME/.local/bin:$PATH"

# Claude Code Configuration (via Local Proxy)
# The Proxy translates Claude's requests to OpenAI format for your custom API
# Default Configuration Values
export OPENAI_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
export PORT=8000
export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
export ANTHROPIC_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
export ANTHROPIC_MODEL="claude-sonnet-4-5-20250929-thinking"
# Alternative models:
# export ANTHROPIC_MODEL="kimi-k2-0905-preview"  # Kimi latest
# export ANTHROPIC_MODEL="gemini-3-pro-preview-thinking"  # Gemini

# Function to switch modes and models
claude-switch() {
    if [[ "$1" == "native" ]]; then
        unset ANTHROPIC_API_KEY
        unset ANTHROPIC_BASE_URL
        unset OPENAI_API_KEY
        unset OPENAI_BASE_URL
        echo "✅ Switched to Native Claude (Official Account)"
        echo "Run 'claude login' if you haven't logged in."
    elif [[ "$1" == "proxy" ]]; then
        export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
        export OPENAI_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
        export PORT=8000
        export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
        export ANTHROPIC_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
        export ANTHROPIC_MODEL="claudecode/claude-sonnet-4-5-20250929-thinking"
        echo "🚀 Switched to Custom API Proxy Mode"
        start_claude_proxy
    elif [[ "$1" == "model" ]]; then
        if [[ -n "$2" ]]; then
            export ANTHROPIC_MODEL="$2"
            echo "✅ Model switched to: $2"
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
    pkill -f "src.main:app" # Kill existing instance if any
    nohup python3 ~/.claude-code-proxy/start_proxy.py > ~/.claude-code-proxy/proxy.log 2>&1 &
    echo "🚀 Claude Proxy started on port 8000"
    echo "Logs: ~/.claude-code-proxy/proxy.log"
}

# Claude Code Context Injection & Model Enforcement
claude() {
    local config_file="/Users/mrshaper/Library/Mobile Documents/com~apple~CloudDocs/Career/US Project/Claude_Code_优化配置/configs/CLAUDE.md"
    
    # Construct the command with explicit model and system prompt
    # We use the array approach to safely handle arguments
    local cmd=("command" "claude")

    # Always enforce the custom model if ANTHROPIC_API_KEY is set
    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        # Check if user already supplied --model
        if [[ "$*" != *"--model"* ]]; then
            cmd+=("--model" "$ANTHROPIC_MODEL")
        fi
    fi

    # Inject system prompt if config exists
    if [[ -f "$config_file" ]]; then
         if [[ "$*" != *"--system-prompt"* ]]; then
             cmd+=("--system-prompt" "$(cat "$config_file")")
         fi
    fi
    
    "${cmd[@]}" "$@"
}
