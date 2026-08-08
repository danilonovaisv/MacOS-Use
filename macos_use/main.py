"""Command-line entrypoint for macOS-Use."""

from __future__ import annotations

import argparse
import importlib
import os
import urllib.request
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()
os.environ.setdefault("ANONYMIZED_TELEMETRY", "false")

from macos_use.agent import Agent, Browser


PROVIDERS: dict[str, tuple[str, str, str]] = {
    "anthropic": ("macos_use.providers.anthropic", "ChatAnthropic", "claude-sonnet-4-5"),
    "azure_openai": ("macos_use.providers.azure_openai", "ChatAzureOpenAI", "gpt-4o"),
    "cerebras": ("macos_use.providers.cerebras", "ChatCerebras", "llama-3.3-70b"),
    "deepseek": ("macos_use.providers.deepseek", "ChatDeepSeek", "deepseek-chat"),
    "google": ("macos_use.providers.google", "ChatGoogle", "gemini-2.5-flash"),
    "groq": ("macos_use.providers.groq", "ChatGroq", "openai/gpt-oss-120b"),
    "litellm": ("macos_use.providers.litellm", "ChatLiteLLM", "gpt-4o"),
    "mistral": ("macos_use.providers.mistral", "ChatMistral", "mistral-medium-3-5"),
    "nvidia": ("macos_use.providers.nvidia", "ChatNvidia", "nvidia/nemotron-3-super-120b-a12b"),
    "ollama": ("macos_use.providers.ollama", "ChatOllama", "qwen3.6:latest"),
    "open_router": ("macos_use.providers.open_router", "ChatOpenRouter", "openai/gpt-4o"),
    "openai": ("macos_use.providers.openai", "ChatOpenAI", "gpt-4o"),
    "vllm": ("macos_use.providers.vllm", "ChatVLLM", "Qwen/Qwen3-8B"),
}

BROWSERS = {
    "safari": Browser.SAFARI,
    "chrome": Browser.CHROME,
    "firefox": Browser.FIREFOX,
    "edge": Browser.EDGE,
}

PROFILE_TOOLS: dict[str, list[str] | None] = {
    "observe": ["done_tool", "scrape_tool", "wait_tool"],
    "assist": [
        "app_tool",
        "click_tool",
        "done_tool",
        "move_tool",
        "scrape_tool",
        "scroll_tool",
        "shortcut_tool",
        "type_tool",
        "wait_tool",
    ],
    "execute": None,
}

PROFILE_INSTRUCTIONS = {
    "observe": "Operate read-only. Do not modify files, applications, settings, or external services.",
    "assist": "Prefer reversible GUI actions. Do not send, publish, delete, purchase, or change security settings.",
    "execute": "Execute the requested task, but require explicit confirmation before destructive, privileged, financial, or external actions.",
}

KEY_ENV_VARS = {
    "anthropic": ("ANTHROPIC_API_KEY",),
    "azure_openai": ("AZURE_OPENAI_API_KEY", "AZURE_OPENAI_ENDPOINT"),
    "cerebras": ("CEREBRAS_API_KEY",),
    "deepseek": ("DEEPSEEK_API_KEY",),
    "google": ("GEMINI_API_KEY", "GOOGLE_API_KEY"),
    "groq": ("GROQ_API_KEY",),
    "mistral": ("MISTRAL_API_KEY",),
    "nvidia": ("NVIDIA_NIM_API_KEY", "NVIDIA_API_KEY"),
    "open_router": ("OPENROUTER_API_KEY",),
    "openai": ("OPENAI_API_KEY",),
}


@dataclass(frozen=True)
class Settings:
    profile: str
    provider: str
    model: str
    browser: str
    max_steps: int
    max_failures: int
    use_vision: bool
    thinking: bool
    log_to_file: bool


def _env_bool(name: str, default: bool = False) -> bool:
    return os.getenv(name, str(default)).strip().lower() in {"1", "true", "yes", "on"}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the macOS-Use specialist agent")
    parser.add_argument("--profile", choices=PROFILE_TOOLS, default=os.getenv("MACOS_USE_PROFILE", "observe"))
    parser.add_argument("--provider", choices=PROVIDERS, default=os.getenv("MACOS_USE_PROVIDER", "ollama"))
    parser.add_argument("--model", default=os.getenv("MACOS_USE_MODEL"))
    parser.add_argument("--browser", choices=BROWSERS, default=os.getenv("MACOS_USE_BROWSER", "safari"))
    parser.add_argument("--task", help="Task to execute. Prompts interactively when omitted.")
    parser.add_argument("--max-steps", type=int, default=int(os.getenv("MACOS_USE_MAX_STEPS", "12")))
    parser.add_argument("--max-failures", type=int, default=int(os.getenv("MACOS_USE_MAX_FAILURES", "2")))
    parser.add_argument("--vision", action="store_true", default=_env_bool("MACOS_USE_USE_VISION"))
    parser.add_argument(
        "--thinking",
        action=argparse.BooleanOptionalAction,
        default=_env_bool("MACOS_USE_THINKING"),
        help="Enable extended model reasoning (slower for large local models)",
    )
    parser.add_argument("--logs", action="store_true", default=_env_bool("MACOS_USE_LOG_TO_FILE"))
    parser.add_argument("--check", action="store_true", help="Validate runtime imports and configuration without acting")
    parser.add_argument("--dry-run", action="store_true", help="Print resolved configuration without running the agent")
    return parser


def resolve_settings(args: argparse.Namespace) -> Settings:
    default_model = PROVIDERS[args.provider][2]
    return Settings(
        profile=args.profile,
        provider=args.provider,
        model=args.model or default_model,
        browser=args.browser,
        max_steps=args.max_steps,
        max_failures=args.max_failures,
        use_vision=args.vision,
        thinking=args.thinking,
        log_to_file=args.logs,
    )


def provider_is_configured(provider: str) -> bool:
    if provider == "ollama":
        host = os.getenv("OLLAMA_HOST", "http://127.0.0.1:11434").rstrip("/")
        try:
            with urllib.request.urlopen(f"{host}/api/tags", timeout=2):
                return True
        except OSError:
            return False
    required = KEY_ENV_VARS.get(provider)
    if not required:
        return True
    if provider in {"google", "nvidia"}:
        return any(os.getenv(name) for name in required)
    return all(os.getenv(name) for name in required)


def build_llm(settings: Settings):
    module_name, class_name, _ = PROVIDERS[settings.provider]
    llm_class = getattr(importlib.import_module(module_name), class_name)
    if settings.provider == "ollama":
        return llm_class(model=settings.model, think=settings.thinking)
    return llm_class(model=settings.model)


def accessibility_is_trusted() -> bool:
    try:
        from ApplicationServices import AXIsProcessTrusted

        return bool(AXIsProcessTrusted())
    except ImportError:
        return False


def print_check(settings: Settings) -> int:
    imports = ("Quartz", "Cocoa", "ApplicationServices")
    failures: list[str] = []
    for module_name in imports:
        try:
            importlib.import_module(module_name)
            print(f"PASS import: {module_name}")
        except ImportError as error:
            failures.append(module_name)
            print(f"FAIL import: {module_name} ({error})")

    print(f"INFO profile: {settings.profile}")
    print(f"INFO provider: {settings.provider}")
    print(f"INFO model: {settings.model}")
    print(f"INFO provider configured: {'yes' if provider_is_configured(settings.provider) else 'no'}")
    print(f"INFO accessibility trusted: {'yes' if accessibility_is_trusted() else 'no'}")
    return 1 if failures else 0


def print_dry_run(settings: Settings, task: str | None) -> None:
    tools = PROFILE_TOOLS[settings.profile]
    print("macOS-Use dry run")
    print(f"profile={settings.profile}")
    print(f"provider={settings.provider}")
    print(f"model={settings.model}")
    print(f"browser={settings.browser}")
    print(f"max_steps={settings.max_steps}")
    print(f"max_failures={settings.max_failures}")
    print(f"use_vision={str(settings.use_vision).lower()}")
    print(f"thinking={str(settings.thinking).lower()}")
    print(f"log_to_file={str(settings.log_to_file).lower()}")
    print(f"enabled_tools={','.join(tools) if tools is not None else 'all'}")
    print(f"task={task or '<interactive>'}")


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    settings = resolve_settings(args)

    if args.check:
        return print_check(settings)
    if args.dry_run:
        print_dry_run(settings, args.task)
        return 0
    if not provider_is_configured(settings.provider):
        if settings.provider == "ollama":
            raise SystemExit("Provider 'ollama' is not configured. Start the Ollama application or server.")
        names = " or ".join(KEY_ENV_VARS.get(settings.provider, ("the provider configuration",)))
        raise SystemExit(f"Provider '{settings.provider}' is not configured. Set {names}.")
    if not accessibility_is_trusted():
        raise SystemExit(
            "Accessibility permission is required. Enable it for the terminal or Codex app in "
            "System Settings > Privacy & Security > Accessibility."
        )

    task = args.task or input("Enter your query: ").strip()
    if not task:
        raise SystemExit("A non-empty task is required.")

    llm = build_llm(settings)
    agent = Agent(
        llm=llm,
        browser=BROWSERS[settings.browser],
        use_accessibility=True,
        use_vision=settings.use_vision,
        use_annotation=False,
        auto_minimize=False,
        max_steps=settings.max_steps,
        max_consecutive_failures=settings.max_failures,
        log_to_console=True,
        log_to_file=settings.log_to_file,
        experimental=False,
        disable_loop_detection=False,
        enabled_tools=PROFILE_TOOLS[settings.profile],
        instructions=[PROFILE_INSTRUCTIONS[settings.profile]],
    )
    result = agent.invoke(task=task)
    if result.content:
        print(result.content)
    if result.error:
        print(result.error)
    return 0 if result.is_done else 1


if __name__ == "__main__":
    raise SystemExit(main())
