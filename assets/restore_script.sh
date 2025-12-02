#!/bin/bash
set -e

# ==============================================================================
# Claude Code Environment Restore Script
# ==============================================================================
# This script restores your Claude Code configuration from the 'assets' folder.
# It handles:
# 1. .zshrc (Shell configuration)
# 2. CLAUDE.md (AI Identity/Brain)
# 3. .claude.json (Project settings)
# 4. .claude/settings.local.json (Permissions)

ASSETS_DIR="$(dirname "$0")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Starting Restoration Process..."

# --- Function: Backup and Restore ---
restore_file() {
    local source_file="$1"
    local target_file="$2"
    
    if [ -f "$source_file" ]; then
        echo "Processing $target_file..."
        
        # Create target directory if needed
        mkdir -p "$(dirname "$target_file")"
        
        # Backup existing file
        if [ -f "$target_file" ]; then
            echo "  -> Backing up existing file to ${target_file}.bak_${TIMESTAMP}"
            cp "$target_file" "${target_file}.bak_${TIMESTAMP}"
        fi
        
        # Restore
        echo "  -> Restoring from assets..."
        cp "$source_file" "$target_file"
    else
        echo "⚠️  Warning: Source file $source_file not found in assets. Skipping."
    fi
}

# 1. Restore .zshrc (Full Overwrite Option)
# We default to appending the snippet, but if full_zshrc_backup exists and user wants it, they can uncomment
# For safety, we just append the snippet here if it's not present
if grep -q "Claude Code Helper Functions" "$HOME/.zshrc"; then
    echo "✅ .zshrc already contains helper functions."
    # 4. Apply Proxy Patches (Document Parsing Support)
    echo "📦 Applying proxy enhancements..."
    PROXY_DIR="$HOME/.claude-code-proxy"
    PATCH_DIR="$ASSETS_DIR/proxy_patches"
    
    if [ -d "$PATCH_DIR" ] && [ -d "$PROXY_DIR" ]; then
        cp -r "$PATCH_DIR/"* "$PROXY_DIR/"
        echo "✅ Proxy patches applied."
        
        # Re-install dependencies to ensure new libs (pypdf etc.) are installed
        echo "📦 Installing additional dependencies..."
        pip3 install -r "$PROXY_DIR/requirements.txt" > /dev/null 2>&1
        echo "✅ Dependencies updated."
    else
        echo "⚠️ Proxy directory or patches not found. Skipping patch application."
    fi

    echo "🎉 Restore completed! Please restart your terminal."
else
    echo "🔧 Appending helper functions to .zshrc..."
    cat "$ASSETS_DIR/zshrc_snippet.sh" >> "$HOME/.zshrc"
fi

# 2. Restore CLAUDE.md
    echo "🔧 Restoring CLAUDE.md (System Prompt)..."
    mkdir -p "$HOME/.claude"
    cp "$ASSETS_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    cp "$ASSETS_DIR/Claude_Code_Token_Efficiency_Protocol.md" "$HOME/.claude/Token_Efficiency_Protocol.md"
    echo "✅ CLAUDE.md and Efficiency Protocol restored."
# 3. Restore Claude Configs
restore_file "$ASSETS_DIR/claude.json" "$HOME/.claude.json"
restore_file "$ASSETS_DIR/settings.local.json" "$HOME/.claude/settings.local.json"

echo "========================================================"
echo "✅ Restoration Complete!"
echo "⚠️  CRITICAL REMINDER:"
echo "   You MUST manually configure your API Keys in ~/.zshrc."
echo "   Open ~/.zshrc and look for the 'Claude Code 账号配置' section."
echo "   Fill in your OPENAI_API_KEY and ANTHROPIC_API_KEY."
echo "========================================================"
