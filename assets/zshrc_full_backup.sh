# Add local bin to PATH for manual installs (e.g. ripgrep)
export PATH="$HOME/.local/bin:$PATH"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# GITSTATUS_LOG_LEVEL=DEBUG

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$PATH"

# Claude Code Helper Functions
# ==============================================================================

# Claude Code Configuration (via Local Proxy)
# The Proxy translates Claude's requests to OpenAI format for your custom API
# Default Configuration Values
export OPENAI_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
export OPENAI_BASE_URL="https://ai.opendoor.cn/v1"
export PORT=8000
export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
export ANTHROPIC_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
export ANTHROPIC_MODEL="claude-sonnet-4-5-20250929-thinking"
export ANTHROPIC_SMALL_FAST_MODEL="claude-haiku-4-5-20251001"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5-20251001"
export SMALL_MODEL="claude-haiku-4-5-20251001"
export BRAVE_API_KEY="BSAyWb51QxF4XrCee2SnYIYH0lnOHYD"

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
        export OPENAI_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
        export PORT=8000
        export ANTHROPIC_BASE_URL="http://127.0.0.1:8000"
        export ANTHROPIC_API_KEY="sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT"
        export ANTHROPIC_MODEL="claude-sonnet-4-5-20250929-thinking"
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
