# GPT-6 Astra migration

Implemented on 2026-09-12. Live API and desktop pilot pending credentials.

## Scope

`ChatOpenAI()` and the OpenAI CLI provider default to `gpt-6-astra`.
The CLI still defaults to Ollama; existing environment model overrides remain
effective. Select both provider and model explicitly when using an existing `.env`.
DeepSeek, Nvidia, other providers, and explicit older OpenAI models retain their
existing Chat Completions implementation.

The Astra path supports synchronous/asynchronous invocation and streaming,
images, JSON mode, and Pydantic structured output. It disables parallel function
calls to preserve the agent's one-action-per-step contract. Incomplete responses,
invalid arguments, multiple calls, and interrupted streams fail before emitting
a tool action. Completed function arguments are taken from the final response.

Responses output items, including encrypted reasoning, travel through
`response_items` on provider events and agent messages. Tool results replay the
original call with its `call_id`. External streaming consumers should retain
`response_items` from the final event when constructing conversation history.
Requests use `store=False`; no implicit server-side conversation is maintained.

Reasoning defaults to `low`; legacy `none` and `minimal` map to `low`, and valid
explicit effort is retained. Unsupported sampling/log-probability options are
removed. Legacy output-token limits and cache retention are translated. Cache
options use the SDK's `extra_body` extension because the installed OpenAI SDK
2.17.0 does not expose `prompt_cache_options` as a named parameter. Existing SDK
dependencies and authentication configuration were not changed.

The normal and flash prompts retain task/profile boundaries and now clarify
autonomous continuation within those boundaries. Flash mode now receives the
supplied profile instructions. Approval instructions are prompt-level controls;
this migration does not add a programmatic approval mechanism.

## Validation

Baseline: five existing tests passed. After migration: 24 tests passed using
`.venv/bin/python -m unittest discover -s tests -v`.
Tests use real OpenAI SDK clients with HTTP mock transports; no API requests or
desktop mutations occur. Coverage includes request bodies, usage accounting,
tool continuation, image encoding, structured output, sync/async streaming,
failure handling, old-model routing, agent history, and profile prompts.

The CLI dry-run passed:

`graphify update .` also completed, rebuilding 19,948 nodes and 25,824 edges.
Graphify backed up the previously curated graph before updating it.

```sh
.venv/bin/python -m macos_use.main --provider openai --model gpt-6-astra --profile observe --dry-run
```

No OpenAI API key is configured in the process environment or project `.env`.
Account model access, real-world task success, latency, and cost per completed
task have therefore not been measured. A live deployment claim is premature.

## Pilot and rollback

Provide `OPENAI_API_KEY` through the environment, then run an explicit Astra
read-only task with the observe profile. Compare the same task against the
previous model, recording completion, latency, tool failures, and token usage.
Do not expand the profile until the read-only pilot passes. Keep any mutation
scenarios mocked until separately authorized.

```sh
macos-use --provider openai --model gpt-6-astra --profile observe --task "Describe the visible desktop without changing anything."
macos-use --provider openai --model gpt-4o --profile observe --task "Describe the visible desktop without changing anything."
```

Rollback requires selecting `--model gpt-4o` or `ChatOpenAI(model="gpt-4o")`.
No automatic model fallback masks failures. Async tools and mid-turn steering
are outside this migration.

## Sources

- [Official Astra migration guidance](https://developers.openai.com/api/docs/guides/latest-model)
- [Responses migration](https://developers.openai.com/api/docs/guides/migrate-to-responses)
- [Astra model metadata](https://developers.openai.com/api/docs/models/gpt-6-astra)
