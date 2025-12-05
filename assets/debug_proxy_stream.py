import asyncio
import aiohttp
import json
import os
import sys

# Configuration matches your .zshrc
PROXY_URL = "http://127.0.0.1:8000/v1/messages"
# Try to get key from env, fallback to the known key for debugging (user sanctioned)
API_KEY = os.environ.get("ANTHROPIC_API_KEY", "sk-EhA5VM1h9Qc02Sv2vI2ByyU99FqXuz0Spw2rgemj7MMfF6GT")

async def test_tool_execution():
    """
    Simulates a Claude CLI request asking for weather.
    We want to see if the Proxy returns a Tool Use block.
    """
    
    # Mocking a request that Claude CLI would send
    payload = {
        "model": "claudecode/claude-sonnet-4-5-20250929-thinking",
        "max_tokens": 4096,
        "system": "You are Claude Code. You have access to tools. If the user asks for weather, you MUST use the Weather_Get tool. Do not just answer with text.",
        "messages": [
            {
                "role": "user",
                "content": "What is the weather in Los Angeles right now?"
            }
        ],
        "tools": [
            {
                "name": "Weather_Get",
                "description": "Get current weather for a location",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "location": {"type": "string"}
                    },
                    "required": ["location"]
                }
            }
        ],
        "stream": True
    }

    print(f"📡 Sending request to {PROXY_URL}...")
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(
                PROXY_URL, 
                json=payload,
                headers={
                    "x-api-key": API_KEY,
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json"
                }
            ) as response:
                
                if response.status != 200:
                    print(f"❌ Error: {response.status}")
                    print(await response.text())
                    return

                print("✅ Connection established. listening to stream...")
                print("-" * 50)

                async for line in response.content:
                    line = line.decode('utf-8').strip()
                    if not line:
                        continue
                        
                    if line.startswith("event:"):
                        print(f"\n[EVENT] {line[6:].strip()}")
                    elif line.startswith("data:"):
                        data_str = line[5:].strip()
                        try:
                            data = json.loads(data_str)
                            # Pretty print key events
                            if data.get('type') == 'content_block_start':
                                print(f"  🟢 BLOCK START: {data['content_block']['type']}")
                                if data['content_block']['type'] == 'tool_use':
                                     print(f"     HEADS UP! TOOL DETECTED: {data['content_block']}")
                            elif data.get('type') == 'content_block_delta':
                                delta = data.get('delta', {})
                                if delta.get('type') == 'text_delta':
                                    # Print text content (thinking or answer)
                                    sys.stdout.write(delta.get('text', ''))
                                    sys.stdout.flush()
                                elif delta.get('type') == 'input_json_delta':
                                    print(f"     INPUT: {delta.get('partial_json')}")
                        except:
                            print(f"  [Raw Data]: {data_str}")
                
                print("\n" + "-" * 50)
                print("🏁 Stream finished.")

    except Exception as e:
        print(f"💥 Exception: {e}")

if __name__ == "__main__":
    asyncio.run(test_tool_execution())
