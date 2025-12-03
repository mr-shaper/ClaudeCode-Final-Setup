# Changelog

## [2.1.0] - 2025-12-02

### Critical Fixes
- **Fixed Dual-Model Response Bug**: Resolved an issue where the proxy would incorrectly map subagent requests (using `claude-haiku`) to the default `claude-sonnet` model while the main request used a different model (e.g., `kimi-k2-thinking`). This caused incoherent, alternating responses from two different models.
- **Dynamic Subagent Selection**: Implemented intelligent logic in `model_manager.py` to select the appropriate subagent model based on the main model:
    - Main: `claude-sonnet` -> Subagent: `claude-haiku`
    - Main: `kimi` -> Subagent: `kimi` (Consistency)
    - Main: `gemini` -> Subagent: `gemini-pro` (Stability)
- **OAuth Conflict Resolution**: Removed `oauthAccount` from `~/.claude.json` to prevent conflicts between official Claude authentication and custom API key usage.
- **Quote Handling**: Updated `claude-switch` to automatically strip quotes from model names to prevent environment variable errors.

### Configuration Updates
- Updated `config.py` to set `SMALL_MODEL` default to `claude-haiku-4-5-20251001` as a safe fallback.
- Updated `zshrc_snippet.sh` with the robust `claude-switch` function.

### Fixes & Improvements
- **Fixed Brave Search 422 Error**: Added missing `BRAVE_API_KEY` to MCP configuration.
- **Improved Model Switching**: `claude-switch model` now automatically restarts the proxy to ensure the new model selection takes effect immediately for dynamic subagent logic.

### Documentation & Security
- **Updated Deployment Guide**: Added critical warning about "Project Config Override" and the correct MCP setup method.
- **Updated User Manual**: Added troubleshooting for "0 searches" and clarified the `claude mcp add` command usage.
- **Security**: Desensitized `assets/config.json` to remove hardcoded API keys before GitHub push.
- **Restore Script**: Updated `restore_script.sh` to explicitly prompt for `BRAVE_API_KEY` configuration.
- **Config Fix**: Removed empty `mcpServers` block from `assets/claude.json` to prevent overriding global settings on new installs.
- Added "Debugging & Logs" section to `User_Manual.md`.
- Updated `README.md` with new v2.1.0 features.

### Assets
- Synced patched `model_manager.py` and `config.py` to `assets/proxy_patches/`.
