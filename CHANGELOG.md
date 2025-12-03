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

### Assets
- Synced patched `model_manager.py` and `config.py` to `assets/proxy_patches/`.
