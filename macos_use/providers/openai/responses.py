"""Responses API translation for the agent's single-action event contract."""

import json
from copy import deepcopy

from openai.lib._pydantic import to_strict_json_schema

from macos_use.messages import AIMessage, ImageMessage, ToolMessage
from macos_use.providers.events import LLMEvent, LLMEventType, LLMStreamEvent, LLMStreamEventType, ToolCall
from macos_use.providers.views import TokenUsage


def request_params(model, messages, tools, options, structured_output=None, json_mode=False):
    params = deepcopy(options)
    extra = params.setdefault("extra_body", {})
    for source in (params, extra):
        for key in ("temperature", "top_p", "top_logprobs", "logprobs", "stream_options"):
            source.pop(key, None)
        if "prompt_cache_retention" in source:
            source.pop("prompt_cache_retention")
            extra.setdefault("prompt_cache_options", {"ttl": "30m"})
        for key in ("max_tokens", "max_completion_tokens"):
            if key in source:
                params.setdefault("max_output_tokens", source.pop(key))
    if "prompt_cache_options" in params:
        extra["prompt_cache_options"] = params.pop("prompt_cache_options")
    reasoning = params.setdefault("reasoning", {})
    effort = params.pop("reasoning_effort", reasoning.get("effort", "low"))
    reasoning["effort"] = "low" if effort in ("none", "minimal") else effort
    if reasoning["effort"] not in {"low", "medium", "high", "xhigh", "max"}:
        raise ValueError("Unsupported Astra reasoning effort")
    params["include"] = [v for v in params.get("include", []) if v != "message.output_text.logprobs"]
    if "reasoning.encrypted_content" not in params["include"]:
        params["include"].append("reasoning.encrypted_content")
    inputs = []
    for message in messages:
        if message.response_items:
            inputs.extend(deepcopy(message.response_items))
        elif isinstance(message, ToolMessage):
            inputs.append({"type": "function_call", "call_id": message.id,
                           "name": message.name, "arguments": json.dumps(message.params)})
        elif isinstance(message, ImageMessage):
            content = [{"type": "input_text", "text": message.content}] if message.content else []
            content.extend({"type": "input_image", "image_url": f"data:{message.mime_type};base64,{image}"}
                           for image in message.convert_images(format="base64"))
            inputs.append({"role": "user", "content": content})
        else:
            role = "assistant" if isinstance(message, AIMessage) else {"human": "user", "system": "system"}[message.role]
            inputs.append({"role": role, "content": message.content or ""})
        if isinstance(message, ToolMessage):
            inputs.append({"type": "function_call_output", "call_id": message.id, "output": message.content or ""})
    params.update(model=model, input=inputs, store=False)
    if tools:
        params["tools"] = [{"type": "function", "name": tool.name,
                            "description": tool.description or "",
                            "parameters": tool.model.model_json_schema(), "strict": False} for tool in tools]
        # The agent executes exactly one action per step.
        params["parallel_tool_calls"] = False
    if structured_output is not None:
        schema_type = structured_output if isinstance(structured_output, type) else type(structured_output)
        params["text"] = {"format": {"type": "json_schema", "name": schema_type.__name__,
                                     "schema": to_strict_json_schema(schema_type), "strict": True}}
    elif json_mode:
        params["text"] = {"format": {"type": "json_object"}}
    return params


def response_event(response, structured_output=None):
    if response.status != "completed":
        raise ValueError(f"OpenAI response did not complete: {response.status}")
    items = [item.model_dump(exclude_none=True) for item in response.output]
    calls = [item for item in items if item["type"] == "function_call"]
    if len(calls) > 1:
        raise ValueError("Expected at most one tool call per agent step")
    data = response.usage
    usage = None if data is None else TokenUsage(
        prompt_tokens=data.input_tokens, completion_tokens=data.output_tokens,
        total_tokens=data.total_tokens,
        thinking_tokens=getattr(data.output_tokens_details, "reasoning_tokens", None),
        cache_read_input_tokens=getattr(data.input_tokens_details, "cached_tokens", None),
    )
    if calls:
        call = calls[0]
        arguments = json.loads(call["arguments"])
        if not isinstance(arguments, dict):
            raise ValueError("Tool arguments must be a JSON object")
        return LLMEvent(type=LLMEventType.TOOL_CALL, tool_call=ToolCall(
            id=call["call_id"], name=call["name"], params=arguments), usage=usage, response_items=items)
    refusals = [part["refusal"] for item in items if item["type"] == "message"
                for part in item.get("content", []) if part["type"] == "refusal"]
    if refusals:
        raise ValueError("OpenAI refused the request: " + " ".join(refusals))
    content = response.output_text
    if structured_output is not None:
        schema_type = structured_output if isinstance(structured_output, type) else type(structured_output)
        content = schema_type.model_validate_json(content).model_dump_json()
    return LLMEvent(type=LLMEventType.TEXT, content=content, usage=usage, response_items=items)


class ResponseStream:
    def __init__(self, structured_output=None):
        self.started = False
        self.completed = False
        self.structured_output = structured_output

    def feed(self, event):
        if event.type == "response.output_text.delta":
            if not self.started:
                self.started = True
                yield LLMStreamEvent(type=LLMStreamEventType.TEXT_START)
            yield LLMStreamEvent(type=LLMStreamEventType.TEXT_DELTA, content=event.delta)
        elif event.type == "response.completed":
            result = response_event(event.response, self.structured_output)
            self.completed = True
            if self.started or result.type == LLMEventType.TEXT:
                if not self.started:
                    yield LLMStreamEvent(type=LLMStreamEventType.TEXT_START)
                    yield LLMStreamEvent(type=LLMStreamEventType.TEXT_DELTA, content=result.content or "")
                yield LLMStreamEvent(type=LLMStreamEventType.TEXT_END, usage=result.usage,
                                     response_items=result.response_items)
            if result.tool_call:
                yield LLMStreamEvent(type=LLMStreamEventType.TOOL_CALL, tool_call=result.tool_call,
                                     usage=result.usage, response_items=result.response_items)
        elif event.type in {"error", "response.failed", "response.incomplete"}:
            raise ValueError(f"OpenAI stream failed: {event.type}")

    def finish(self):
        if not self.completed:
            raise ValueError("OpenAI stream ended without a completed response")
