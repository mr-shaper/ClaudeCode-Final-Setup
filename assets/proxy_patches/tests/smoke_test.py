import os
import sys
from pathlib import Path

# Ensure src package is importable
THIS = Path(__file__).resolve()
SRC_ROOT = THIS.parents[1] / "src"
sys.path.insert(0, str(THIS.parents[1]))

# Set environment for mapping
os.environ["ANTHROPIC_MODEL"] = "claude-sonnet-4-5-20250929-thinking"
os.environ["MIDDLE_MODEL"] = "claude-sonnet-4-5-20250929-thinking"
os.environ["SMALL_MODEL"] = "claude-haiku-4-5-20251001"
os.environ["BIG_MODEL"] = "claude-sonnet-4-5-20250929-thinking"

from src.core.model_manager import model_manager

def main():
    cases = [
        "claude-sonnet-4-5-20250929-thinking",
        "claude-haiku-4-5-20251001",
        "claude-opus-4-5-2025xxxx",
        "claude-3-5-sonnet",
        "claude-3-haiku"
    ]
    for m in cases:
        mapped = model_manager.map_claude_model_to_openai(m)
        print(f"{m} -> {mapped}")

if __name__ == "__main__":
    main()

