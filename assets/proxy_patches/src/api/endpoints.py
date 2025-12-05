from fastapi import APIRouter, HTTPException, Request, Header, Depends
from fastapi.responses import JSONResponse, StreamingResponse
from datetime import datetime
import uuid
import json
import os
from typing import Optional

from src.core.config import config
from src.core.logging import logger
from src.core.client import OpenAIClient
from src.models.claude import ClaudeMessagesRequest, ClaudeTokenCountRequest
from src.conversion.request_converter import convert_claude_to_openai
from src.conversion.response_converter import (
    convert_openai_to_claude_response,
    convert_openai_streaming_to_claude_with_cancellation,
)
from src.core.model_manager import model_manager

router = APIRouter()

# Get custom headers from config
custom_headers = config.get_custom_headers()

openai_client = OpenAIClient(
    config.openai_api_key,
    config.openai_base_url,
    config.request_timeout,
    api_version=config.azure_api_version,
    custom_headers=custom_headers,
)

# --- Behavior Logging ---
BEHAVIOR_LOG_PATH = os.path.expanduser("~/.claude-code-proxy/behavior.log")

def log_behavior(request_id: str, direction: str, content: str):
    """Log detailed behavior for debugging."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        # Ensure directory exists
        os.makedirs(os.path.dirname(BEHAVIOR_LOG_PATH), exist_ok=True)
        with open(BEHAVIOR_LOG_PATH, "a") as f:
            f.write(f"[{timestamp}] [{request_id}] [{direction}]\n")
            f.write(f"{content}\n")
            f.write("-" * 80 + "\n")
    except Exception as e:
        logger.error(f"Failed to write to behavior log: {e}")
# ------------------------

async def validate_api_key(x_api_key: Optional[str] = Header(None), authorization: Optional[str] = Header(None)):
    """Validate the client's API key from either x-api-key header or Authorization header."""
    client_api_key = None
    
    # Extract API key from headers
    if x_api_key:
        client_api_key = x_api_key
    elif authorization and authorization.startswith("Bearer "):
        client_api_key = authorization.replace("Bearer ", "")
    
    # Skip validation if ANTHROPIC_API_KEY is not set in the environment
    if not config.anthropic_api_key:
        return
        
    # Validate the client API key
    if not client_api_key or not config.validate_client_api_key(client_api_key):
        logger.warning(f"Invalid API key provided by client")
        raise HTTPException(
            status_code=401,
            detail="Invalid API key. Please provide a valid Anthropic API key."
        )

@router.post("/v1/messages")
async def create_message(request: ClaudeMessagesRequest, http_request: Request, _: None = Depends(validate_api_key)):
    try:
        request_id = str(uuid.uuid4())
        
        logger.info(f"================== INCOMING REQUEST {request_id} ==================")
        logger.info(f"Model received from Claude CLI: {request.model}")
        logger.info(f"Message count: {len(request.messages)}")
        logger.info(f"Stream: {request.stream}")
        logger.info(f"======================================================")
        
        # Log incoming Claude request
        log_behavior(request_id, "CLAUDE_REQUEST", request.model_dump_json(indent=2))

        # Convert Claude request to OpenAI format
        openai_request = convert_claude_to_openai(request, model_manager)
        
        # Log converted OpenAI request
        log_behavior(request_id, "OPENAI_REQUEST", json.dumps(openai_request, indent=2, ensure_ascii=False))

        # Check if client disconnected before processing
        if await http_request.is_disconnected():
            raise HTTPException(status_code=499, detail="Client disconnected")

        if request.stream:
            # Streaming response - wrap in error handling
            try:
                openai_stream = openai_client.create_chat_completion_stream(
                    openai_request, request_id
                )
                return StreamingResponse(
                    convert_openai_streaming_to_claude_with_cancellation(
                        openai_stream,
                        request,
                        logger,
                        http_request,
                        openai_client,
                        request_id,
                    ),
                    media_type="text/event-stream",
                    headers={
                        "Cache-Control": "no-cache",
                        "Connection": "keep-alive",
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "*",
                    },
                )
            except HTTPException as e:
                # Convert to proper error response for streaming
                # In a real streaming scenario, we might need to yield an error event
                # But here we just re-raise or return a JSON error if stream hasn't started
                raise e
        else:
            # Non-streaming response
            openai_response = await openai_client.create_chat_completion(
                openai_request, request_id
            )
            
            # Log OpenAI response
            log_behavior(request_id, "OPENAI_RESPONSE", json.dumps(openai_response, indent=2, ensure_ascii=False))
            
            claude_response = convert_openai_to_claude_response(
                openai_response, request
            )
            
            # Log converted Claude response
            log_behavior(request_id, "CLAUDE_RESPONSE", json.dumps(claude_response, indent=2, ensure_ascii=False))
            
            return JSONResponse(content=claude_response)

    except HTTPException as e:
        logger.error(f"HTTP Exception: {e.detail}")
        log_behavior(request_id, "ERROR", str(e.detail))
        raise e
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        log_behavior(request_id, "ERROR", str(e))
        raise HTTPException(status_code=500, detail=str(e))
