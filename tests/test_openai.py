import asyncio
import json
import unittest
from copy import deepcopy

import httpx
from openai import OpenAI, AsyncOpenAI
from PIL import Image
from pydantic import BaseModel

from macos_use.messages import HumanMessage, ImageMessage, ToolMessage
from macos_use.providers.openai import ChatOpenAI
from macos_use.providers.deepseek import ChatDeepSeek
from macos_use.providers.nvidia import ChatNvidia
from macos_use.providers.events import LLMEventType, LLMStreamEventType
from macos_use.tool import Tool


class Answer(BaseModel):
    answer: str


def payload(arguments=None, status="completed"):
    output = [{"type": "message", "id": "msg_1", "role": "assistant", "status": "completed",
               "content": [{"type": "output_text", "text": '{"answer":"ok"}', "annotations": []}]}]
    if arguments is not None:
        output = [{"type": "reasoning", "id": "rs_1", "summary": [], "encrypted_content": "opaque"},
                  {"type": "function_call", "id": "fc_1", "call_id": "call_1", "name": "done_tool",
                   "arguments": arguments, "status": "completed"}]
    return {"id": "resp_1", "object": "response", "created_at": 1, "status": status,
            "model": "gpt-6-astra", "output": output, "parallel_tool_calls": False,
            "tools": [], "tool_choice": "auto", "metadata": {},
            "usage": {"input_tokens": 20, "output_tokens": 10, "total_tokens": 30,
                      "input_tokens_details": {"cached_tokens": 5},
                      "output_tokens_details": {"reasoning_tokens": 4}}}


class OpenAIProviderTests(unittest.TestCase):
    def setUp(self):
        self.requests = []
        self.result = payload()
        self.events = None
        self.llm = ChatOpenAI(api_key="test-key", max_retries=0)
        self.llm.client.close()
        asyncio.run(self.llm.aclient.close())
        self.llm.client = OpenAI(api_key="test-key", http_client=httpx.Client(transport=httpx.MockTransport(self.handle)))
        self.llm.aclient = AsyncOpenAI(api_key="test-key", http_client=httpx.AsyncClient(transport=httpx.MockTransport(self.handle)))
        self.addCleanup(self.llm.client.close)
        self.addCleanup(lambda: asyncio.run(self.llm.aclient.close()))
        self.messages = [HumanMessage(content="Return ok")]
        self.tool = Tool(name="done_tool", description="Finish", model=Answer)

    def handle(self, request):
        body = json.loads(request.content)
        self.requests.append((request.url.path, body))
        if body.get("stream"):
            events = self.events if self.events is not None else [
                {"type": "response.output_text.delta", "delta": '{"answer":"ok"}',
                 "item_id": "msg_1", "output_index": 0, "content_index": 0, "sequence_number": 1},
                {"type": "response.completed", "response": self.result, "sequence_number": 2}]
            data = "".join("data: " + json.dumps(event) + "\n\n" for event in events)
            return httpx.Response(200, text=data, headers={"Content-Type": "text/event-stream"})
        return httpx.Response(200, json=self.result)

    def test_invoke_maps_response_and_usage(self):
        event = self.llm.invoke(self.messages)
        self.assertEqual(self.requests[0][0], "/v1/responses")
        self.assertEqual(event.content, '{"answer":"ok"}')
        self.assertEqual(event.usage.total_tokens, 30)
        self.assertEqual(event.usage.thinking_tokens, 4)
        self.assertEqual(event.usage.cache_read_input_tokens, 5)
        self.assertEqual(self.llm.get_metadata().context_window, 1050000)

    def test_async_invoke(self):
        event = asyncio.run(self.llm.ainvoke(self.messages))
        self.assertEqual(event.content, '{"answer":"ok"}')
        self.assertEqual(self.requests[0][0], "/v1/responses")

    def test_request_normalizes_legacy_options_without_mutation(self):
        self.llm.temperature = 0.4
        self.llm.kwargs = {"top_p": 0.2, "top_logprobs": 1, "reasoning_effort": "minimal",
                           "max_completion_tokens": 100, "prompt_cache_retention": "24h",
                           "include": ["message.output_text.logprobs"],
                           "extra_body": {"temperature": 0.8}}
        before = deepcopy(self.llm.kwargs)
        self.llm.invoke(self.messages, tools=[self.tool])
        body = self.requests[0][1]
        self.assertEqual(body["reasoning"]["effort"], "low")
        self.assertEqual(body["max_output_tokens"], 100)
        self.assertEqual(body["prompt_cache_options"], {"ttl": "30m"})
        self.assertFalse(body["parallel_tool_calls"])
        self.assertFalse(body["store"])
        self.assertEqual(body["tools"][0]["name"], "done_tool")
        self.assertNotIn("temperature", body)
        self.assertNotIn("top_p", body)
        self.assertNotIn("top_logprobs", body)
        self.assertEqual(body["include"], ["reasoning.encrypted_content"])
        self.assertEqual(self.llm.kwargs, before)

    def test_high_effort_preserved(self):
        self.llm.kwargs = {"reasoning": {"effort": "high"}}
        self.llm.invoke(self.messages)
        self.assertEqual(self.requests[0][1]["reasoning"]["effort"], "high")

    def test_tool_result_replays_reasoning_and_call_once(self):
        self.result = payload('{"answer":"ok"}')
        first = self.llm.invoke(self.messages, tools=[self.tool])
        self.assertEqual(first.type, LLMEventType.TOOL_CALL)
        self.assertEqual(first.tool_call.id, "call_1")
        history = ToolMessage(id=first.tool_call.id, name=first.tool_call.name,
                              params=first.tool_call.params, content="done", response_items=first.response_items)
        self.llm.invoke(self.messages + [history], tools=[self.tool])
        items = self.requests[-1][1]["input"]
        self.assertEqual([v.get("type") for v in items], [None, "reasoning", "function_call", "function_call_output"])
        self.assertEqual(items[1]["encrypted_content"], "opaque")
        self.assertEqual(items[-1]["call_id"], "call_1")
        self.assertEqual(items[-1]["output"], "done")

    def test_images_and_legacy_tool_history(self):
        image = ImageMessage(content="Inspect", image=Image.new("RGB", (2, 2)))
        tool = ToolMessage(id="old", name="done_tool", params={"answer": "ok"}, content="done")
        self.llm.invoke([image, tool])
        items = self.requests[0][1]["input"]
        self.assertTrue(items[0]["content"][1]["image_url"].startswith("data:image/png;base64,"))
        self.assertEqual(items[1]["call_id"], items[2]["call_id"])

    def test_structured_output_sync_and_async(self):
        for method in (lambda: self.llm.invoke(self.messages, structured_output=Answer),
                       lambda: asyncio.run(self.llm.ainvoke(self.messages, structured_output=Answer))):
            event = method()
            self.assertEqual(json.loads(event.content), {"answer": "ok"})
            self.assertEqual(event.usage.total_tokens, 30)
            self.assertTrue(self.requests[-1][1]["text"]["format"]["strict"])

    def test_json_mode(self):
        self.llm.invoke(self.messages, json_mode=True)
        self.assertEqual(self.requests[-1][1]["text"]["format"], {"type": "json_object"})

    def test_sync_and_async_stream(self):
        async def collect():
            return [event async for event in self.llm.astream(self.messages, structured_output=Answer)]
        for events in (list(self.llm.stream(self.messages, structured_output=Answer)), asyncio.run(collect())):
            self.assertEqual([e.type for e in events], [LLMStreamEventType.TEXT_START,
                             LLMStreamEventType.TEXT_DELTA, LLMStreamEventType.TEXT_END])
            self.assertEqual(events[-1].usage.total_tokens, 30)
            self.assertTrue(events[-1].response_items)

    def test_stream_tool_arguments_wait_for_completion(self):
        self.result = payload('{"answer":"ok"}')
        self.events = [{"type": "response.function_call_arguments.delta", "delta": '{"answer":',
                        "item_id": "fc_1", "output_index": 1, "sequence_number": 1},
                       {"type": "response.function_call_arguments.delta", "delta": '"ok"}',
                        "item_id": "fc_1", "output_index": 1, "sequence_number": 2},
                       {"type": "response.completed", "response": self.result, "sequence_number": 3}]
        async def collect():
            return [event async for event in self.llm.astream(self.messages, tools=[self.tool])]
        for events in (list(self.llm.stream(self.messages, tools=[self.tool])), asyncio.run(collect())):
            self.assertEqual(len(events), 1)
            self.assertEqual(events[0].tool_call.params, {"answer": "ok"})
            self.assertEqual(events[0].tool_call.id, "call_1")

    def test_malformed_tool_arguments_rejected(self):
        for arguments in ("{", "[]"):
            self.result = payload(arguments)
            with self.assertRaises(ValueError):
                self.llm.invoke(self.messages)

    def test_multiple_tool_calls_rejected(self):
        self.result = payload("{}")
        self.result["output"].append(deepcopy(self.result["output"][-1]))
        with self.assertRaisesRegex(ValueError, "at most one"):
            self.llm.invoke(self.messages)

    def test_incomplete_response_rejected(self):
        self.result = payload(status="incomplete")
        with self.assertRaisesRegex(ValueError, "did not complete"):
            self.llm.invoke(self.messages)

    def test_interrupted_stream_rejected(self):
        self.events = []
        with self.assertRaisesRegex(ValueError, "without a completed"):
            list(self.llm.stream(self.messages))

    def test_failed_stream_rejected(self):
        self.events = [{"type": "response.failed", "response": payload(status="failed"), "sequence_number": 1}]
        with self.assertRaisesRegex(ValueError, "stream failed"):
            list(self.llm.stream(self.messages))

    def test_legacy_and_subclass_routing(self):
        self.llm._model = "gpt-4o"
        self.result = {"choices": [{"message": {"content": "ok", "tool_calls": None}}],
                       "usage": {"prompt_tokens": 2, "completion_tokens": 1, "total_tokens": 3}}
        self.assertEqual(self.llm.invoke(self.messages).content, "ok")
        self.assertEqual(self.requests[-1][0], "/v1/chat/completions")
        for provider in (ChatDeepSeek, ChatNvidia):
            llm = provider(api_key="test-key")
            try:
                self.assertFalse(llm._uses_responses())
                self.assertNotEqual(llm.model_name, "gpt-6-astra")
            finally:
                llm.client.close()
                asyncio.run(llm.aclient.close())


if __name__ == "__main__":
    unittest.main()
