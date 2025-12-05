# Change Log - Claude Code Final Setup

## v2.3.1 (2025-12-04) - "The Sanity Fix"

### 🐛 Critical Fixes
1.  **Stop the "Thinking" Leak (Fix "Idiot" Behavior)**
    *   **Issue**: Models like DeepSeek/Kimi output a `reasoning_content` field containing their internal thought process. Claude Code was treating this as text, causing it to "mutter" its system instructions (e.g., `⏺ 1. The first system reminder...`) before answering.
    *   **Fix**: Updated `src/conversion/response_converter.py` to actively suppress/hide `reasoning_content` from the stream.
    *   **Status**: ✅ Fixed.

2.  **Fix "File Reading Failure" (Missing Tool ID)**
    *   **Issue**: Some third-party APIs return tool calls without an `id` field, which is required by Claude. This caused Claude to *say* "I'm reading the file" but actually do nothing because the tool call was dropped.
    *   **Fix**: Updated `src/conversion/response_converter.py` to auto-generate a UUID for any tool call missing an ID.
    *   **Status**: ✅ Fixed.

3.  **Behavior Logging**
    *   **Feature**: Added detailed request/response logging to `src/api/endpoints.py`.
    *   **Log File**: `~/.claude-code-proxy/behavior.log`
    *   **Purpose**: Allows debugging of exactly what the CLI sent vs. what the Proxy sent to the API.

### 📂 Updated Assets
*   `assets/proxy_patches/src/conversion/response_converter.py`: Contains the ID generation and thinking suppression logic.
*   `assets/proxy_patches/src/api/endpoints.py`: Contains the logging logic.
*   `assets/fix_proxy.sh`: Script to apply these patches and restart the proxy automatically.
*   `assets/verify_search.py`: Script to verify Web Search dependencies.

### ⚠️ Configuration Notes
*   **Auth Conflict**: Users MUST run `claude logout` to clear official tokens if they want to use the Proxy. Mixed authentication causes unstable behavior.
