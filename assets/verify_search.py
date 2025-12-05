import subprocess
import json
import sys

def verify_brave_search():
    print("🔍 Verifying Brave Search Configuration...")
    
    # 1. Check if ripgrep is installed
    try:
        subprocess.run(["rg", "--version"], check=True, capture_output=True)
        print("✅ ripgrep (rg) is installed.")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ ripgrep (rg) is NOT installed. Run: brew install ripgrep")
        return False
        
    # 2. Check if Node.js is installed
    try:
        subprocess.run(["node", "--version"], check=True, capture_output=True)
        print("✅ Node.js is installed.")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Node.js is NOT installed.")
        return False
        
    # 3. Check Claude MCP Config
    config_path = "/Users/mrshaper/Library/Application Support/Claude/claude_desktop_config.json"
    # Note: Claude Code CLI uses a different config path or arguments.
    # Since we use `claude mcp add`, let's verify if the Brave Search package exists
    
    package_path = "/Users/mrshaper/.claude/mcp/node_modules/@modelcontextprotocol/server-brave-search"
    import os
    if os.path.exists(package_path):
        print(f"✅ Brave Search MCP package found at: {package_path}")
    else:
        print(f"❌ Brave Search MCP package NOT found at: {package_path}")
        print("Run: npm install -g @modelcontextprotocol/server-brave-search (or follow manual)")
        return False
        
    print("\n🎉 Verification Complete. To test, run in Claude Code:")
    print('   /mcp list')
    print('   Then ask: "Search for the latest news about OpenAI"')
    return True

if __name__ == "__main__":
    verify_brave_search()
