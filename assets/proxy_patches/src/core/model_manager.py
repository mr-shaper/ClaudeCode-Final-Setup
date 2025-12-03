from src.core.config import config
import os

class ModelManager:
    def __init__(self, config):
        self.config = config
    
    def map_claude_model_to_openai(self, claude_model: str) -> str:
        """Map Claude model names to OpenAI model names based on BIG/SMALL pattern"""
        
        # Map ONLY official Anthropic Claude model patterns
        # Official patterns: claude-3-haiku, claude-3-5-sonnet, claude-3-opus, etc.
        # Everything else (including claudecode/*, kimi-*, gemini-*, etc.) is passed through
        model_lower = claude_model.lower()
        
        # Check if it's an official Claude model (starts with "claude-" followed by version)
        # This ensures we don't match "claudecode/" or other custom prefixes
        if not model_lower.startswith('claude-'):
            # Not an official Claude model, pass through as-is
            return claude_model
        
        # Now we know it starts with 'claude-', check for haiku/sonnet/opus
        if 'haiku' in model_lower:
            # Dynamic Subagent Selection Logic
            # Get the current main model from environment variable
            current_main_model = os.environ.get("ANTHROPIC_MODEL", "").lower()
            
            # Rule 1: Claude Sonnet (Thinking or Normal) -> Use Haiku 4.5
            if 'claude-sonnet-4-5' in current_main_model:
                return "claude-haiku-4-5-20251001"
            
            # Rule 2: Kimi -> Use Kimi (Same as main)
            elif 'kimi' in current_main_model:
                return "kimi-k2-thinking"
                
            # Rule 3: Gemini Thinking -> Use Gemini Pro (Non-thinking)
            elif 'gemini' in current_main_model and 'thinking' in current_main_model:
                return "gemini-3-pro-preview"
            
            # Fallback: Use configured small model
            return self.config.small_model
            
        elif 'sonnet' in model_lower:
            return self.config.middle_model
        elif 'opus' in model_lower:
            return self.config.big_model
        
        # Unknown Claude variant, pass through
        return claude_model

model_manager = ModelManager(config)