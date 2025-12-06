import json
import os

settings_path = os.path.expanduser("~/.claude/settings.local.json")

# Define permissions to ensure are present
required_permissions = [
    "Bash(npx:*)",
    "Bash(/usr/local/bin/npx:*)",
    "Bash(git commit:*)", 
    "Bash(git push:*)",
    "Bash(git add:*)",
    "Bash(git status:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)",
    "WebFetch(*)" 
]

print(f"Reading settings from {settings_path}...")
try:
    with open(settings_path, 'r') as f:
        content = f.read().strip()
        if content:
            settings = json.loads(content)
        else:
            settings = {"permissions": {"allow": []}}
except (FileNotFoundError, json.JSONDecodeError):
    print("Settings file missing or invalid, creating new one.")
    settings = {"permissions": {"allow": []}}

# Ensure structure exists
if "permissions" not in settings:
    settings["permissions"] = {}
if "allow" not in settings["permissions"]:
    settings["permissions"]["allow"] = []

current_allow = settings["permissions"]["allow"]

# Add missing permissions
added_count = 0
for perm in required_permissions:
    if perm not in current_allow:
        current_allow.append(perm)
        added_count += 1
        print(f"Added permission: {perm}")

if added_count > 0:
    print("Writing updated settings...")
    with open(settings_path, 'w') as f:
        json.dump(settings, f, indent=2)
    print(f"✅ Successfully added {added_count} permissions.")
else:
    print("✅ All required permissions already present.")

print(json.dumps(settings["permissions"], indent=2))
