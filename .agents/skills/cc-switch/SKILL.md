---
name: cc-switch
description: Manage CC Switch (coding agent config manager) via CLI. Query and switch providers, manage MCP servers and skills across Claude Code, Codex, Gemini CLI, and OpenCode. Use when user mentions CC Switch, switching providers, coding agent configs, MCP management, or skill installation.
---

# CC Switch Skill

Manage coding agent configs, MCP servers, and skills via CC Switch's SQLite database.

## CLI Tool

`python3 {baseDir}/scripts/ccs.py`

### Provider Operations
```bash
ccs.py list [--app claude|codex|gemini|opencode]  # List providers
ccs.py current                                     # Show active providers
ccs.py show <name> --app <app>                     # Show provider details
ccs.py switch <name> --app <app>                   # Switch provider
ccs.py health                                      # Provider health status
```

### MCP Operations
```bash
ccs.py mcp list                                    # List all MCP servers
ccs.py mcp show <id>                               # Show MCP server config
ccs.py mcp add <name> --command <cmd> [--args ...] [--env K=V ...] [--apps claude,codex,...] [--desc "..."]
ccs.py mcp enable <name> [--apps claude,codex,...]  # Enable for apps (default: all)
ccs.py mcp disable <name> [--apps claude,codex,...] # Disable for apps (default: all)
ccs.py mcp rm <name>                               # Remove MCP server
ccs.py mcp sync                                    # Sync to live config files
```

MCP sync targets:
- Claude: `~/.claude.json` → mcpServers
- Codex: `~/.codex/config.toml` → [mcp_servers.*]
- Gemini: `~/.gemini/settings.json` → mcpServers
- OpenCode: `~/.opencode/mcp.json` → mcpServers

### Skill Operations
```bash
ccs.py skill list [--app <app>]                    # List installed skills
ccs.py skill install <path> [--name <name>] [--apps claude,codex,...]  # Install from local dir
ccs.py skill enable <name> [--apps claude,codex,...] # Enable for apps
ccs.py skill disable <name> [--apps ...]            # Disable for apps
ccs.py skill rm <name>                              # Remove skill
ccs.py skill sync                                   # Sync symlinks to live dirs
```

Skill sync creates symlinks in:
- Claude: `~/.claude/skills/`
- Codex: `~/.codex/skills/`
- Gemini: `~/.gemini/skills/`
- OpenCode: `~/.opencode/skills/`

### Prompt Operations
```bash
ccs.py prompt list [--app <app>]                   # List prompts
ccs.py prompt show <name> --app <app>              # Show prompt content
```

## Important Notes

- After switching providers, restart the corresponding CLI tool.
- After `mcp sync` or `skill sync`, restart CLI tools to pick up changes.
- Database: `~/.cc-switch/cc-switch.db` (SQLite, source of truth)
- Settings: `~/.cc-switch/settings.json` (device-level)
