# Change Log - Claude Code Final Setup

## v2.4.2 (2025-12-05) - "The Sound of Silence" (Models Forbidden)

### 🚀 Fixes & Optimizations
1.  **Fix "Summary Hallucination" (Zero-Model Short Circuit)**
    *   **User Constraint**: Strictly forbidden from switching models (even for background tasks).
    *   **Technical Issue**: Custom Haiku 4.5 model persistently echoed (parroted) instructions instead of summarizing.
    *   **Solution**: Implemented a **Local Short Circuit** in the Proxy.
    *   **Mechanism**: The Proxy intercepts requests containing "Summarize this coding conversation", bypasses the LLM entirely, and returns a hardcoded title `"Conversation"`.
    *   **Result**: 0 Latency, 0 Token Cost, 0 Hallucinations, 0 Model Switches.

---


### 🚀 Fixes & Optimizations
1.  **Fix "Seasoning" Hang (Post-Tool Freeze)**
    *   **Root Cause**: `response_converter.py` contained duplicate streaming logic blocks (legacy artifacts), causing double-processing of signals.
    *   **Fix**: Aggressively refactored the converter to a single, clean linear pipeline.
    *   **Feature**: Implemented **Invisible PING Events** during "Thinking" phases to prevent TCP timeouts while keeping the CLI silent.

2.  **Fix "Token Explosion" (24k+ Tokens)**
    *   **Forensic Analysis**: The previous "Parroting Bug" (where the model repeated history) caused the CLI to save massive text blocks into context memory, leading to a 24k token spike on subsequent requests.
    *   **Prevention**: The "Prompt Reinforcement" (v2.4.0) prevents this.
    *   **Remediation**: Users must reset their session (`/reset` or restart `claude`) to clear poisoned history.

3.  **Documentation Update**
    *   Added **Session Management** section to Solution Guide (New/Resume/Reset).

---


### 🚀 Performance & Stability
1.  **Fix "Spelunking" Hang (65 Tokens)**
    *   **Root Cause**: Custom Haiku 4.5 model sent non-standard stream chunks (empty content with stop signals), which the Proxy previously discarded.
    *   **Fix**: Rewrote `response_converter.py` logic to respect `finish_reason` even in empty chunks.
    *   **Result**: Summarization is now instant (2.7s roundtrip).

2.  **Fix "History Traversal" (Infinite Loop)**
    *   **Root Cause**: The custom Haiku model "parroted" conversation history instead of summarizing it due to weak instruction following.
    *   **Fix**: Implemented **Prompt Reinforcement** in `request_converter.py`. Injected `CRITICAL: DO NOT REPEAT history` system prompt specifically for this model.
    *   **Result**: Model now obeys and outputs concise titles.

3.  **Fix Shell Syntax & Configuration**
    *   **Restoration**: Reverted accidental removal of `claude-switch` function in `zshrc_snippet.sh`.
    *   **Compliance**: Fully respected user's custom model naming (`claude-haiku-4-5-20251001`) without forced changes.

### 🛠️ Technical Debt
*   **Prompt Injection**: Added targeted system prompt overrides in Proxy layer.
*   **Stream Hygiene**: Enhanced SSE stream parsing to handle upstream idiosyncrasies.

---


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
