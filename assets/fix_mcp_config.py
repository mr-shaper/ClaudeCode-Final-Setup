import json
import os

config_path = os.path.expanduser("~/.claude/config.json")
brave_key = "BSAyWb51QxF4XrCee2SnYIYH0lnOHYD"

print(f"Reading config from {config_path}...")
try:
    with open(config_path, 'r') as f:
        content = f.read().strip()
        if content:
            config = json.loads(content)
        else:
            config = {"mcpServers": {}}
except (FileNotFoundError, json.JSONDecodeError):
    print("Config file missing or invalid, creating new one.")
    config = {"mcpServers": {}}

servers = config.get("mcpServers", {})

# 1. Brave Search (Local Node)
servers["brave-search"] = {
    "command": "/usr/local/bin/node",
    "args": [
        os.path.expanduser("~/.claude/mcp/node_modules/@modelcontextprotocol/server-brave-search/dist/index.js")
    ],
    "env": {
        "BRAVE_API_KEY": brave_key
    }
}

# 2. GitHub (NPX)
# Preserve existing token if present
existing_github_env = servers.get("github", {}).get("env", {})
github_token = existing_github_env.get("GITHUB_PERSONAL_ACCESS_TOKEN", "YOUR_GITHUB_TOKEN_HERE")

servers["github"] = {
    "command": "/usr/local/bin/npx",
    "args": [
        "-y",
        "@modelcontextprotocol/server-github"
    ],
    "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": github_token
    }
}

# 3. Puppeteer (NPX)
servers["puppeteer"] = {
    "command": "/usr/local/bin/npx",
    "args": [
        "-y",
        "@modelcontextprotocol/server-puppeteer"
    ]
}

config["mcpServers"] = servers

print("Writing updated config...")
with open(config_path, 'w') as f:
    json.dump(config, f, indent=4)

print("✅ Config updated successfully!")
print(json.dumps(config, indent=2))
