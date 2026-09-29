from __future__ import annotations

import argparse
import os
import unittest
from unittest.mock import patch, MagicMock

from macos_use.agent import Agent
from macos_use.main import PROFILE_TOOLS, PROFILE_INSTRUCTIONS, build_parser, resolve_settings
from macos_use.agent.prompt.service import Prompt
from macos_use.agent.desktop.views import Browser


class CliTests(unittest.TestCase):
    def test_openai_default_and_explicit_rollback(self):
        with patch.dict(os.environ, {}, clear=True):
            parser = build_parser()
            self.assertEqual(resolve_settings(parser.parse_args(["--provider", "openai"])).model, "gpt-6-astra")
            self.assertEqual(resolve_settings(parser.parse_args(["--provider", "openai", "--model", "gpt-4o"])).model, "gpt-4o")

    def test_profile_instructions_reach_both_prompt_modes(self):
        desktop = MagicMock()
        with patch("macos_use.agent.prompt.service.ax.GetScreenSize", return_value=(100, 100)):
            for mode in ("normal", "flash"):
                prompt = Prompt.system(mode, desktop, Browser.SAFARI, 2, [PROFILE_INSTRUCTIONS["observe"]])
                self.assertIn(PROFILE_INSTRUCTIONS["observe"], prompt)

    def test_default_settings_are_safe(self):
        safe_env = {
            "MACOS_USE_PROFILE": "observe",
            "MACOS_USE_PROVIDER": "ollama",
            "MACOS_USE_BROWSER": "safari",
            "MACOS_USE_USE_VISION": "false",
            "MACOS_USE_THINKING": "false",
            "MACOS_USE_LOG_TO_FILE": "false",
        }
        with patch.dict(os.environ, safe_env, clear=False):
            args = build_parser().parse_args([])
        settings = resolve_settings(args)

        self.assertEqual(settings.profile, "observe")
        self.assertFalse(settings.use_vision)
        self.assertFalse(settings.thinking)
        self.assertFalse(settings.log_to_file)
        self.assertNotIn("shell_tool", PROFILE_TOOLS[settings.profile])

    def test_invalid_tool_allowlist_is_rejected_before_use(self):
        with self.assertRaisesRegex(ValueError, "Unknown enabled tools"):
            Agent(llm=None, enabled_tools=["not_a_real_tool"])

    def test_explicit_provider_and_model_are_resolved(self):
        args = argparse.Namespace(
            profile="assist",
            provider="openai",
            model="example-model",
            browser="chrome",
            max_steps=7,
            max_failures=1,
            vision=True,
            thinking=True,
            logs=True,
        )
        settings = resolve_settings(args)

        self.assertEqual(settings.provider, "openai")
        self.assertEqual(settings.model, "example-model")
        self.assertEqual(settings.browser, "chrome")
        self.assertEqual(settings.max_steps, 7)
        self.assertEqual(settings.max_failures, 1)
        self.assertTrue(settings.use_vision)
        self.assertTrue(settings.thinking)
        self.assertTrue(settings.log_to_file)


if __name__ == "__main__":
    unittest.main()
