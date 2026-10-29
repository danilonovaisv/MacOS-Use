# CC Switch CLI Skill

A CLI companion for [CC Switch](https://github.com/farion1231/cc-switch) — manage coding agent configs, MCP servers, and skills from the command line.

Works with CC Switch's SQLite database to control **Claude Code**, **Codex**, **Gemini CLI**, and **OpenCode** configurations without opening the desktop app.

## Features

- **Provider Management** — List, switch, and monitor API providers across all four coding agents
- **MCP Server Management** — Add, enable/disable, and sync MCP servers across agents with one command
- **Skills Management** — Install, enable/disable, and sync skills to all agents via symlinks
- **Prompt Management** — List and inspect system prompt presets
- **Health Monitoring** — Check provider health status and failure counts

## Prerequisites

- [CC Switch](https://github.com/farion1231/cc-switch) desktop app installed (creates the SQLite database)
- Python 3.8+
- No additional dependencies (stdlib only)

## Installation

### As an OpenClaw Skill

```bash
npx clawhub@latest install Hsiifu3/cc-switch-skill
```

### Manual

```bash
git clone https://github.com/Hsiifu3/cc-switch-skill.git
# Add to your agent's skills directory, or run directly:
python3 cc-switch-skill/scripts/ccs.py --help
```

## Usage

```bash
# Alias for convenience
alias ccs="python3 /path/to/scripts/ccs.py"
```

### Providers

```bash
ccs list                          # List all providers
ccs list --app claude             # Filter by app
ccs current                       # Show active providers
ccs show <name> --app claude      # Show provider config
ccs switch <name> --app claude    # Switch active provider
ccs health                        # Provider health status
```

### MCP Servers

```bash
ccs mcp list                      # List all MCP servers
ccs mcp show <name>               # Show server config
ccs mcp add <name> --command npx --args -y memorix@latest serve --apps claude,codex,gemini,opencode
ccs mcp enable <name> --apps gemini,opencode
ccs mcp disable <name> --apps codex
ccs mcp rm <name>                 # Remove server
ccs mcp sync                      # Write to live config files
```

Sync targets:
| Agent | Config File |
|-------|------------|
| Claude Code | `~/.claude.json` → `mcpServers` |
| Codex | `~/.codex/config.toml` → `[mcp_servers.*]` |
| Gemini CLI | `~/.gemini/settings.json` → `mcpServers` |
| OpenCode | `~/.opencode/mcp.json` → `mcpServers` |

### Skills

```bash
ccs skill list                    # List installed skills
ccs skill list --app claude       # Filter by app
ccs skill install /path/to/skill --apps claude,codex,gemini,opencode
ccs skill enable <name> --apps gemini
ccs skill disable <name> --apps codex
ccs skill rm <name>               # Remove skill
ccs skill sync                    # Sync symlinks to agent dirs
```

Sync creates symlinks in:
- `~/.claude/skills/`
- `~/.codex/skills/`
- `~/.gemini/skills/`
- `~/.opencode/skills/`

### Prompts

```bash
ccs prompt list                   # List all prompts
ccs prompt list --app claude      # Filter by app
ccs prompt show <name> --app claude
```

## How It Works

CC Switch stores all configuration in `~/.cc-switch/cc-switch.db` (SQLite). This CLI reads and writes to the same database, so changes are reflected in both the desktop app and the CLI.

The `sync` commands write enabled configurations to each agent's live config files. Restart the corresponding CLI tool after syncing for changes to take effect.

## License

MIT
