from __future__ import annotations

import unittest

from macos_use.providers.events import LLMEventType
from macos_use.providers.ollama import ChatOllama


class OllamaProviderTests(unittest.TestCase):
    def test_explicit_thinking_setting_is_preserved(self):
        llm = ChatOllama(model="qwen3-test", think=False)
        params = {}

        llm._configure_thinking(params)

        self.assertIs(params["think"], False)

    def test_nullable_token_counts_are_normalized(self):
        llm = ChatOllama(model="test-model")
        event = llm._process_response(
            {
                "message": {"content": "ok"},
                "prompt_eval_count": None,
                "eval_count": None,
            }
        )

        self.assertEqual(event.type, LLMEventType.TEXT)
        self.assertEqual(event.content, "ok")
        self.assertEqual(event.usage.prompt_tokens, 0)
        self.assertEqual(event.usage.completion_tokens, 0)
        self.assertEqual(event.usage.total_tokens, 0)


if __name__ == "__main__":
    unittest.main()
