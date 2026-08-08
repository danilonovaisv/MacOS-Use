from __future__ import annotations

import argparse
import os
import unittest
from unittest.mock import patch

from macos_use.agent import Agent
from macos_use.main import PROFILE_TOOLS, build_parser, resolve_settings


class CliTests(unittest.TestCase):
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
