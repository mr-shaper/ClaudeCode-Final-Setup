from src.core.config import config

class ModelManager:
    def __init__(self, config):
        self.config = config
    
    def map_claude_model_to_openai(self, claude_model: str) -> str:
        """Map Claude model names to OpenAI model names based on BIG/SMALL pattern"""
        
        # Map ONLY standard Claude model patterns (haiku/sonnet/opus)
        # Everything else is passed through as-is to the API provider
        model_lower = claude_model.lower()
        
        # Only map if it's a PURE Claude model name pattern
        if 'claude' in model_lower and 'haiku' in model_lower:
            return self.config.small_model
        elif 'claude' in model_lower and 'sonnet' in model_lower:
            return self.config.middle_model
        elif 'claude' in model_lower and 'opus' in model_lower:
            return self.config.big_model
        
        # For everything else (custom models, provider-specific models, etc.),
        # pass through as-is to the upstream API
        return claude_model

model_manager = ModelManager(config)