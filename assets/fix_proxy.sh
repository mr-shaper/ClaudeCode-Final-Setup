#!/bin/bash
# Fix for "File Reading Failure" - Patches the response converter to handle missing tool call IDs

# Get absolute path to the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS_DIR="$SCRIPT_DIR"

SOURCE="$ASSETS_DIR/proxy_patches/src/conversion/response_converter.py"
DEST="$HOME/.claude-code-proxy/src/conversion/response_converter.py"

echo "🔧 Applying Proxy Fix..."
echo "   Source: $SOURCE"
echo "   Dest:   $DEST"

if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$DEST"
    if [ $? -eq 0 ]; then
        echo "✅ Patch applied successfully."
    else
        echo "❌ Failed to apply patch. Please check permissions."
        exit 1
    fi
else
    echo "❌ Patch file not found at $SOURCE"
    exit 1
fi

# Restart Proxy
echo "🔄 Restarting Proxy..."
PID=$(lsof -ti:8000)
if [ -n "$PID" ]; then
    kill -9 $PID
    echo "   Stopped existing proxy (PID $PID)."
fi

# Start Proxy Manually to ensure it runs
echo "🚀 Starting proxy..."
cd "$HOME/.claude-code-proxy" || exit
# Check for virtualenv
if [ -f "venv/bin/python" ]; then
    nohup ./venv/bin/python -m uvicorn src.main:app --host 127.0.0.1 --port 8000 > proxy.log 2>&1 &
else
    nohup python3 -m uvicorn src.main:app --host 127.0.0.1 --port 8000 > proxy.log 2>&1 &
fi

echo "✅ Proxy restarted in background."
echo "🎉 You can now try asking Claude to read a file!"
