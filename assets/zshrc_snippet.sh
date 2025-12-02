# ==============================================================================
# Claude Code Helper Functions
# ==============================================================================
# NOTE: You must set the following environment variables in your .zshrc manually:
# - OPENAI_API_KEY (Your actual Kimi/Opendoor Key)
# - OPENAI_BASE_URL (Your actual API URL)
# - ANTHROPIC_API_KEY (Set this to the SAME value as OPENAI_API_KEY for validation)
# - ANTHROPIC_BASE_URL (Set to http://127.0.0.1:8000)
# - ANTHROPIC_MODEL (Set to claudecode/claude-sonnet-4-5-20250929-thinking)
# - PORT (Optional, default 8000)

# 1. Helper Function: Start the Proxy
# Run 'start_claude_proxy' to launch the translator in the background
start_claude_proxy() {
    pkill -f "src.main:app" # Kill existing instance to avoid port conflicts
    # Assumes claude-code-proxy is installed in ~/.claude-code-proxy
    nohup python3 ~/.claude-code-proxy/start_proxy.py > ~/.claude-code-proxy/proxy.log 2>&1 &
    echo "🚀 Claude Proxy started on port 8000"
    echo "Logs: ~/.claude-code-proxy/proxy.log"
}

# 2. Wrapper Function: Context Injection & Model Enforcement
# This ensures CLAUDE.md is always loaded and the correct model is used
claude() {
    # Path to your CLAUDE.md (Update this if you move the file!)
    local config_file="/Users/mrshaper/Library/Mobile Documents/com~apple~CloudDocs/Career/US Project/Claude_Code_优化配置/configs/CLAUDE.md"
    
    local cmd=("command" "claude")

    # Enforce Custom Model if using API
    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        if [[ "$*" != *"--model"* ]]; then
            # Ensure ANTHROPIC_MODEL is set
            if [[ -z "$ANTHROPIC_MODEL" ]]; then
                echo "Error: ANTHROPIC_MODEL is not set. Please export it in .zshrc."
                return 1
            fi
            cmd+=("--model" "$ANTHROPIC_MODEL")
        fi
    fi

    # Inject System Prompt (Identity & Capabilities)
    if [[ -f "$config_file" ]]; then
         if [[ "$*" != *"--system-prompt"* ]]; then
             cmd+=("--system-prompt" "$(cat "$config_file")")
         fi
    fi
    
    "${cmd[@]}" "$@"
}
