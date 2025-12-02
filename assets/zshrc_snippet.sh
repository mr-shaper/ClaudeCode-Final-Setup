# Add local bin to PATH for manual installs (e.g. ripgrep)
export PATH="$HOME/.local/bin:$PATH"

# Claude Code Configuration (via Local Proxy)
# The Proxy translates Claude's requests to OpenAI format for your custom API
export OPENAI_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
export PORT=8000
export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
# 注意：这里也填同一个 Key！(Claude CLI 需要检查 Key 格式，虽然它实际上是通过 Proxy 转发的)
export ANTHROPIC_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"

# 4. Search Config (Brave Search API Key)
# Get key: https://api.search.brave.com/app/keys
# export BRAVE_API_KEY="YOUR_BRAVE_KEY_HERE" # Uncomment to hardcode, or export manually in terminal
export ANTHROPIC_MODEL="claudecode/claude-sonnet-4-5-20250929-thinking"

# Function to start the proxy in background
start_claude_proxy() {
    pkill -f "src.main:app" # Kill existing instance if any
    nohup python3 ~/.claude-code-proxy/start_proxy.py > ~/.claude-code-proxy/proxy.log 2>&1 &
    echo "🚀 Claude Proxy started on port 8000"
    echo "Logs: ~/.claude-code-proxy/proxy.log"
}

# Claude Code Context Injection & Model Enforcement
claude() {
    local config_file="$HOME/.claude/CLAUDE.md"
    
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

    # Execute the command with all arguments
    "${cmd[@]}" "$@"
}
