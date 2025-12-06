import asyncio
import os
import sys
# Try to import MCP client if available, or simulate the call environment
# Since we don't have the python mcp client easily, let's use node directly to test the server.

import subprocess

def test_brave_search():
    print("🧪 Testing Brave Search MCP Configuration...")
    
    # Configuration to test
    node_path = "/usr/local/bin/node"
    script_path = os.path.expanduser("~/.claude/mcp/node_modules/@modelcontextprotocol/server-brave-search/dist/index.js")
    api_key = os.environ.get("BRAVE_API_KEY", "BSAyWb51QxF4XrCee2SnYIYH0lnOHYD")
    
    # 1. Check Node
    if not os.path.exists(node_path):
        print(f"❌ Node not found at {node_path}")
        return
    print(f"✅ Node found at {node_path}")

    # 2. Check Script
    if not os.path.exists(script_path):
        print(f"❌ MCP Script not found at {script_path}")
        return
    print(f"✅ MCP Script found at {script_path}")

    # 3. Test Execution (Dry Run)
    # We can't easily speak JSON-RPC manually, but we can see if it starts without crashing.
    print("🚀 Attempting to start MCP server process...")
    try:
        process = subprocess.Popen(
            [node_path, script_path],
            env={**os.environ, "BRAVE_API_KEY": api_key},
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Wait a moment to see if it crashes immediately
        try:
            outs, errs = process.communicate(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
            print("✅ Server started and kept running (good sign)!")
            return

        if process.returncode != 0:
            print(f"❌ Server exited with error code {process.returncode}")
            print(f"STDERR: {errs}")
        else:
             print("⚠️ Server exited immediately (could be normal if it expects input, but check logs).")

    except Exception as e:
        print(f"❌ Execution failed: {e}")

if __name__ == "__main__":
    test_brave_search()
