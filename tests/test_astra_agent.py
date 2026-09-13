"""Agent-loop integration without desktop actions or external API calls."""

import asyncio
import unittest
from unittest.mock import MagicMock, AsyncMock, patch

from macos_use.agent import Agent
from macos_use.messages import HumanMessage, SystemMessage, ToolMessage
from macos_use.providers.events import LLMEvent, LLMEventType, ToolCall
from macos_use.agent.registry.views import ToolResult
from macos_use.main import PROFILE_TOOLS


class AstraAgentTests(unittest.TestCase):
    def test_sync_and_async_loop_preserve_response_history(self):
        for asynchronous in (False, True):
            with self.subTest(asynchronous=asynchronous), \
                 patch("macos_use.agent.service.Desktop"), \
                 patch("macos_use.agent.service.ProductTelemetry"), \
                 patch("macos_use.agent.service.WatchDog"):
                llm = MagicMock()
                items = [{"type": "reasoning", "id": "rs_1", "summary": [], "encrypted_content": "opaque"}]
                event = LLMEvent(type=LLMEventType.TOOL_CALL,
                                 tool_call=ToolCall(id="call_1", name="done_tool", params={"answer": "done"}),
                                 response_items=items)
                llm.invoke.return_value = event
                llm.ainvoke = AsyncMock(return_value=event)
                agent = Agent(llm=llm, enabled_tools=PROFILE_TOOLS["observe"], log_to_console=False,
                              max_steps=2, disable_loop_detection=False)
                agent.desktop.desktop_state = None
                agent.context = MagicMock()
                agent.context.task.return_value = HumanMessage(content="Inspect")
                agent.context.state.return_value = HumanMessage(content="Desktop snapshot")
                agent._cached_system_message = SystemMessage(content="Read only")
                result = ToolResult(is_success=True, content="done")
                with patch.object(agent.registry, "execute", return_value=result) as execute, \
                     patch.object(agent.registry, "aexecute", new=AsyncMock(return_value=result)) as aexecute:
                    outcome = asyncio.run(agent.aloop()) if asynchronous else agent.loop()
                    self.assertTrue(outcome.is_done)
                    self.assertEqual(outcome.content, "done")
                    history = [m for m in agent.state.messages if isinstance(m, ToolMessage)]
                    self.assertEqual(history[0].response_items, items)
                    actual = aexecute if asynchronous else execute
                    self.assertEqual(actual.call_args.kwargs["tool_name"], "done_tool")
                    self.assertNotIn("shell_tool", [t.name for t in agent.tools])


if __name__ == "__main__":
    unittest.main()
