#!/usr/bin/env python3
"""CC Switch CLI - Manage coding agent configs via CC Switch's SQLite database."""

import argparse
import json
import os
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path.home() / ".cc-switch" / "cc-switch.db"
SETTINGS_PATH = Path.home() / ".cc-switch" / "settings.json"

LIVE_CONFIGS = {
    "claude": {"settings": Path.home() / ".claude" / "settings.json"},
    "codex": {
        "auth": Path.home() / ".codex" / "auth.json",
        "config": Path.home() / ".codex" / "config.toml",
    },
    "gemini": {
        "env": Path.home() / ".gemini" / ".env",
        "settings": Path.home() / ".gemini" / "settings.json",
    },
    "opencode": {"config": Path.home() / ".opencode" / "config.json"},
}

APP_TYPES = ["claude", "codex", "gemini", "opencode"]
SETTINGS_KEY_MAP = {
    "claude": "currentProviderClaude",
    "codex": "currentProviderCodex",
    "gemini": "currentProviderGemini",
    "opencode": "currentProviderOpencode",
}


def get_db():
    if not DB_PATH.exists():
        print(f"Error: CC Switch database not found at {DB_PATH}", file=sys.stderr)
        sys.exit(1)
    return sqlite3.connect(str(DB_PATH))


def load_settings():
    if SETTINGS_PATH.exists():
        return json.loads(SETTINGS_PATH.read_text())
    return {}


def save_settings(settings):
    SETTINGS_PATH.write_text(json.dumps(settings, indent=2))


def _mask_key(key):
    if not key:
        return "(none)"
    return key[:4] + "..." + key[-4:] if len(key) > 8 else key[:2] + "***"


def _extract_info(app, cfg):
    if app == "claude":
        env = cfg.get("env", {})
        base = env.get("ANTHROPIC_BASE_URL", "official")
        model = cfg.get("model", "")
        return f"model={model} base={base}" if model else f"base={base}"
    elif app == "codex":
        config_str = cfg.get("config", "")
        base = ""
        for line in config_str.split("\n"):
            if "base_url" in line and "=" in line:
                base = line.split("=", 1)[1].strip().strip('"')
                break
        return f"base={base}" if base else ""
    elif app == "gemini":
        env = cfg.get("env", {})
        return f"base={env.get('GOOGLE_GEMINI_BASE_URL', 'official')}"
    elif app == "opencode":
        names = list(cfg.get("provider", {}).keys())
        return f"providers={','.join(names)}" if names else ""
    return ""


# ── Provider commands ────────────────────────────────────────────────


def cmd_list(args):
    db = get_db()
    cur = db.cursor()
    q = "SELECT id, app_type, name, is_current, in_failover_queue FROM providers"
    params = ()
    if args.app:
        q += " WHERE app_type = ?"
        params = (args.app,)
    q += " ORDER BY app_type, sort_index"
    cur.execute(q, params)
    rows = cur.fetchall()
    if not rows:
        print("No providers found.")
        return
    current_app = None
    for pid, app, name, is_cur, failover in rows:
        if app != current_app:
            current_app = app
            print(f"\n[{app.upper()}]")
        marker = " ★" if is_cur else ""
        fq = " (failover)" if failover else ""
        print(f"  {name}{marker}{fq}  ({pid[:8]}...)")
    print()
    db.close()


def cmd_current(args):
    db = get_db()
    cur = db.cursor()
    settings = load_settings()
    for app in APP_TYPES:
        cur_id = settings.get(SETTINGS_KEY_MAP.get(app))
        if cur_id:
            cur.execute(
                "SELECT name, settings_config FROM providers WHERE id=? AND app_type=?",
                (cur_id, app),
            )
            row = cur.fetchone()
            if row:
                info = _extract_info(app, json.loads(row[1]))
                print(f"[{app.upper()}] {row[0]}  {info}")
                continue
        cur.execute(
            "SELECT name FROM providers WHERE app_type=? AND is_current=1", (app,)
        )
        row = cur.fetchone()
        print(f"[{app.upper()}] {row[0]}" if row else f"[{app.upper()}] (none)")
    db.close()


def cmd_show(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name, settings_config, website_url, notes "
        "FROM providers WHERE LOWER(name)=LOWER(?) AND app_type=?",
        (args.name, args.app),
    )
    row = cur.fetchone()
    if not row:
        print(f"Provider '{args.name}' not found for {args.app}.", file=sys.stderr)
        sys.exit(1)
    pid, name, cfg_str, url, notes = row
    print(f"Provider: {name}\nApp: {args.app}\nID: {pid}")
    if url:
        print(f"URL: {url}")
    if notes:
        print(f"Notes: {notes}")
    print(f"Config:\n{json.dumps(json.loads(cfg_str), indent=2)}")
    db.close()


def cmd_switch(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name, settings_config FROM providers "
        "WHERE LOWER(name)=LOWER(?) AND app_type=?",
        (args.name, args.app),
    )
    row = cur.fetchone()
    if not row:
        print(f"Provider '{args.name}' not found for {args.app}.", file=sys.stderr)
        sys.exit(1)
    pid, name, cfg_str = row
    cfg = json.loads(cfg_str)
    cur.execute("UPDATE providers SET is_current=0 WHERE app_type=?", (args.app,))
    cur.execute(
        "UPDATE providers SET is_current=1 WHERE id=? AND app_type=?", (pid, args.app)
    )
    db.commit()
    settings = load_settings()
    key = SETTINGS_KEY_MAP.get(args.app)
    if key:
        settings[key] = pid
        save_settings(settings)
    _write_live_config(args.app, cfg)
    print(f"Switched {args.app} to '{name}'. Restart the CLI for changes to take effect.")
    db.close()


def cmd_health(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT h.app_type, p.name, h.is_healthy, h.consecutive_failures, h.last_error "
        "FROM provider_health h "
        "JOIN providers p ON h.provider_id=p.id AND h.app_type=p.app_type "
        "ORDER BY h.app_type"
    )
    rows = cur.fetchall()
    if not rows:
        print("No health data recorded.")
        return
    for app, name, healthy, fails, err in rows:
        status = "✓ healthy" if healthy else f"✗ unhealthy (failures: {fails})"
        print(f"[{app.upper()}] {name}: {status}")
        if not healthy and err:
            print(f"  Last error: {err}")
    db.close()


# ── Live config writer ───────────────────────────────────────────────


def _write_live_config(app, cfg):
    if app == "claude":
        path = LIVE_CONFIGS["claude"]["settings"]
        path.parent.mkdir(parents=True, exist_ok=True)
        existing = {}
        if path.exists():
            try:
                existing = json.loads(path.read_text())
            except (json.JSONDecodeError, OSError):
                pass
        merged = {**existing, **cfg}
        path.write_text(json.dumps(merged, indent=2) + "\n")

    elif app == "codex":
        auth_path = LIVE_CONFIGS["codex"]["auth"]
        config_path = LIVE_CONFIGS["codex"]["config"]
        auth_path.parent.mkdir(parents=True, exist_ok=True)
        auth_path.write_text(json.dumps(cfg.get("auth", {}), indent=2))
        config_str = cfg.get("config", "")
        if config_str:
            existing_mcp = _extract_codex_mcp(config_path)
            config_path.write_text(config_str)
            if existing_mcp and "[mcp_servers" not in config_str:
                with open(config_path, "a") as f:
                    f.write("\n" + existing_mcp)

    elif app == "gemini":
        env_path = LIVE_CONFIGS["gemini"]["env"]
        settings_path = LIVE_CONFIGS["gemini"]["settings"]
        env_path.parent.mkdir(parents=True, exist_ok=True)
        env = cfg.get("env", {})
        lines = [f"{k}={v}" for k, v in env.items() if v]
        env_path.write_text("\n".join(lines) + "\n" if lines else "")
        gcfg = cfg.get("config", {})
        if gcfg:
            existing = {}
            if settings_path.exists():
                try:
                    existing = json.loads(settings_path.read_text())
                except (json.JSONDecodeError, OSError):
                    pass
            settings_path.write_text(json.dumps({**existing, **gcfg}, indent=2) + "\n")

    elif app == "opencode":
        config_path = LIVE_CONFIGS["opencode"]["config"]
        config_path.parent.mkdir(parents=True, exist_ok=True)
        config_path.write_text(json.dumps(cfg, indent=2) + "\n")


def _extract_codex_mcp(config_path):
    if not config_path.exists():
        return ""
    lines = config_path.read_text().split("\n")
    mcp_lines, in_mcp = [], False
    for line in lines:
        if line.strip().startswith("[mcp_servers"):
            in_mcp = True
        elif line.strip().startswith("[") and not line.strip().startswith("[mcp_servers"):
            if in_mcp:
                in_mcp = False
        if in_mcp:
            mcp_lines.append(line)
    return "\n".join(mcp_lines)


# ── MCP commands ─────────────────────────────────────────────────────


def cmd_mcp_list(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name, enabled_claude, enabled_codex, enabled_gemini, enabled_opencode "
        "FROM mcp_servers ORDER BY name"
    )
    rows = cur.fetchall()
    if not rows:
        print("No MCP servers configured.")
        return
    for mid, name, ec, ecx, eg, eo in rows:
        apps = [a for a, v in [("claude", ec), ("codex", ecx), ("gemini", eg), ("opencode", eo)] if v]
        print(f"  {name} ({mid})  enabled: [{', '.join(apps) or 'none'}]")
    db.close()


def cmd_mcp_show(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name, server_config, description, enabled_claude, enabled_codex, "
        "enabled_gemini, enabled_opencode FROM mcp_servers WHERE id=? OR LOWER(name)=LOWER(?)",
        (args.id, args.id),
    )
    row = cur.fetchone()
    if not row:
        print(f"MCP server '{args.id}' not found.", file=sys.stderr)
        sys.exit(1)
    mid, name, cfg_str, desc, ec, ecx, eg, eo = row
    apps = [a for a, v in [("claude", ec), ("codex", ecx), ("gemini", eg), ("opencode", eo)] if v]
    print(f"Name: {name}\nID: {mid}")
    if desc:
        print(f"Description: {desc}")
    print(f"Enabled: [{', '.join(apps) or 'none'}]")
    print(f"Config:\n{json.dumps(json.loads(cfg_str), indent=2)}")
    db.close()


def cmd_mcp_add(args):
    """Add a new MCP server."""
    import uuid
    db = get_db()
    cur = db.cursor()
    mid = str(uuid.uuid4())
    cfg = {"command": args.command, "args": args.args or []}
    if args.env:
        env = {}
        for e in args.env:
            k, _, v = e.partition("=")
            env[k] = v
        cfg["env"] = env
    apps = args.apps.split(",") if args.apps else []
    ec = 1 if "claude" in apps else 0
    ecx = 1 if "codex" in apps else 0
    eg = 1 if "gemini" in apps else 0
    eo = 1 if "opencode" in apps else 0
    cur.execute(
        "INSERT INTO mcp_servers (id, name, server_config, description, "
        "enabled_claude, enabled_codex, enabled_gemini, enabled_opencode) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        (mid, args.name, json.dumps(cfg), args.desc or "", ec, ecx, eg, eo),
    )
    db.commit()
    apps_str = ", ".join(apps) if apps else "none"
    print(f"Added MCP server '{args.name}' (enabled: [{apps_str}])")
    db.close()


def cmd_mcp_enable(args):
    """Enable an MCP server for specific apps."""
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name FROM mcp_servers WHERE id=? OR LOWER(name)=LOWER(?)",
        (args.id, args.id),
    )
    row = cur.fetchone()
    if not row:
        print(f"MCP server '{args.id}' not found.", file=sys.stderr)
        sys.exit(1)
    mid, name = row
    apps = args.apps.split(",") if args.apps else APP_TYPES
    updates = []
    for app in apps:
        app = app.strip()
        if app in APP_TYPES:
            updates.append(f"enabled_{app}=1")
    if updates:
        cur.execute(f"UPDATE mcp_servers SET {', '.join(updates)} WHERE id=?", (mid,))
        db.commit()
    print(f"Enabled '{name}' for: {', '.join(apps)}")
    db.close()


def cmd_mcp_disable(args):
    """Disable an MCP server for specific apps."""
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name FROM mcp_servers WHERE id=? OR LOWER(name)=LOWER(?)",
        (args.id, args.id),
    )
    row = cur.fetchone()
    if not row:
        print(f"MCP server '{args.id}' not found.", file=sys.stderr)
        sys.exit(1)
    mid, name = row
    apps = args.apps.split(",") if args.apps else APP_TYPES
    updates = []
    for app in apps:
        app = app.strip()
        if app in APP_TYPES:
            updates.append(f"enabled_{app}=0")
    if updates:
        cur.execute(f"UPDATE mcp_servers SET {', '.join(updates)} WHERE id=?", (mid,))
        db.commit()
    print(f"Disabled '{name}' for: {', '.join(apps)}")
    db.close()


def cmd_mcp_rm(args):
    """Remove an MCP server."""
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT id, name FROM mcp_servers WHERE id=? OR LOWER(name)=LOWER(?)",
        (args.id, args.id),
    )
    row = cur.fetchone()
    if not row:
        print(f"MCP server '{args.id}' not found.", file=sys.stderr)
        sys.exit(1)
    mid, name = row
    cur.execute("DELETE FROM mcp_servers WHERE id=?", (mid,))
    db.commit()
    print(f"Removed MCP server '{name}'")
    db.close()


def cmd_mcp_sync(args):
    """Sync enabled MCP servers to live config files."""
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT name, server_config, enabled_claude, enabled_codex, "
        "enabled_gemini, enabled_opencode FROM mcp_servers"
    )
    rows = cur.fetchall()
    db.close()

    per_app = {a: {} for a in APP_TYPES}
    for name, cfg_str, ec, ecx, eg, eo in rows:
        cfg = json.loads(cfg_str)
        if ec:
            per_app["claude"][name] = cfg
        if ecx:
            per_app["codex"][name] = cfg
        if eg:
            per_app["gemini"][name] = cfg
        if eo:
            per_app["opencode"][name] = cfg

    _sync_mcp_claude(per_app["claude"])
    _sync_mcp_codex(per_app["codex"])
    _sync_mcp_gemini(per_app["gemini"])
    _sync_mcp_opencode(per_app["opencode"])
    for app in APP_TYPES:
        n = len(per_app[app])
        print(f"  [{app}] {n} MCP server(s) synced")


def _sync_mcp_claude(servers):
    """Write to ~/.claude.json mcpServers."""
    path = Path.home() / ".claude.json"
    existing = {}
    if path.exists():
        try:
            existing = json.loads(path.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    existing["mcpServers"] = servers
    path.write_text(json.dumps(existing, indent=2) + "\n")


def _sync_mcp_codex(servers):
    """Write to ~/.codex/config.toml [mcp_servers.*] sections."""
    path = Path.home() / ".codex" / "config.toml"
    path.parent.mkdir(parents=True, exist_ok=True)
    # Read existing non-MCP lines
    non_mcp = []
    if path.exists():
        in_mcp = False
        for line in path.read_text().split("\n"):
            if line.strip().startswith("[mcp_servers"):
                in_mcp = True
                continue
            elif line.strip().startswith("[") and not line.strip().startswith("[mcp_servers"):
                in_mcp = False
            if not in_mcp:
                non_mcp.append(line)
    # Strip trailing blank lines
    while non_mcp and not non_mcp[-1].strip():
        non_mcp.pop()
    # Append MCP sections
    parts = non_mcp
    for name, cfg in servers.items():
        parts.append("")
        parts.append(f"[mcp_servers.{name}]")
        parts.append(f'type = "stdio"')
        parts.append(f'command = "{cfg.get("command", "")}"')
        a = cfg.get("args", [])
        parts.append(f'args = {json.dumps(a)}')
        env = cfg.get("env", {})
        if env:
            for k, v in env.items():
                parts.append(f'[mcp_servers.{name}.env]')
                parts.append(f'{k} = "{v}"')
                break  # TOML inline
    parts.append("")
    path.write_text("\n".join(parts))


def _sync_mcp_gemini(servers):
    """Write to ~/.gemini/settings.json mcpServers."""
    path = Path.home() / ".gemini" / "settings.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = {}
    if path.exists():
        try:
            existing = json.loads(path.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    existing["mcpServers"] = servers
    path.write_text(json.dumps(existing, indent=2) + "\n")


def _sync_mcp_opencode(servers):
    """Write to ~/.opencode/mcp.json."""
    path = Path.home() / ".opencode" / "mcp.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({"mcpServers": servers}, indent=2) + "\n")


# ── Skills commands ───────────────────────────────────────────────────

SKILL_DIRS = {
    "claude": Path.home() / ".claude" / "skills",
    "codex": Path.home() / ".codex" / "skills",
    "gemini": Path.home() / ".gemini" / "skills",
    "opencode": Path.home() / ".opencode" / "skills",
}


def cmd_skill_list(args):
    """List all skills."""
    db = get_db()
    cur = db.cursor()
    q = "SELECT id, name, description, directory, enabled_claude, enabled_codex, enabled_gemini, enabled_opencode FROM skills"
    params = ()
    if args.app:
        q += f" WHERE enabled_{args.app}=1"
    q += " ORDER BY name"
    cur.execute(q, params)
    rows = cur.fetchall()
    if not rows:
        print("No skills installed.")
        return
    for sid, name, desc, directory, ec, ecx, eg, eo in rows:
        apps = [a for a, v in [("claude", ec), ("codex", ecx), ("gemini", eg), ("opencode", eo)] if v]
        d = desc[:50] + "..." if desc and len(desc) > 50 else (desc or "")
        print(f"  {name}  [{', '.join(apps) or 'none'}]  {d}")
    db.close()


def cmd_skill_install(args):
    """Install a skill from a local directory path."""
    import uuid
    src = Path(args.path).resolve()
    if not src.is_dir():
        print(f"Error: '{args.path}' is not a directory.", file=sys.stderr)
        sys.exit(1)
    skill_md = src / "SKILL.md"
    desc = ""
    if skill_md.exists():
        for line in skill_md.read_text().split("\n"):
            if line.startswith("description:"):
                desc = line.split(":", 1)[1].strip().strip('"').strip("'")
                break
    name = args.name or src.name
    db = get_db()
    cur = db.cursor()
    # Check if already exists
    cur.execute("SELECT id FROM skills WHERE LOWER(name)=LOWER(?)", (name,))
    if cur.fetchone():
        print(f"Skill '{name}' already exists. Use 'skill rm' first.", file=sys.stderr)
        sys.exit(1)
    sid = str(uuid.uuid4())
    apps = args.apps.split(",") if args.apps else ["claude"]
    ec = 1 if "claude" in apps else 0
    ecx = 1 if "codex" in apps else 0
    eg = 1 if "gemini" in apps else 0
    eo = 1 if "opencode" in apps else 0
    import time
    cur.execute(
        "INSERT INTO skills (id, name, description, directory, "
        "enabled_claude, enabled_codex, enabled_gemini, enabled_opencode, installed_at) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (sid, name, desc, str(src), ec, ecx, eg, eo, int(time.time())),
    )
    db.commit()
    db.close()
    print(f"Installed skill '{name}' from {src}")
    print(f"  Enabled for: {', '.join(apps)}")
    print(f"  Run 'ccs.py skill sync' to write to live configs.")


def cmd_skill_enable(args):
    """Enable a skill for specific apps."""
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT id, name FROM skills WHERE LOWER(name)=LOWER(?)", (args.name,))
    row = cur.fetchone()
    if not row:
        print(f"Skill '{args.name}' not found.", file=sys.stderr)
        sys.exit(1)
    sid, name = row
    apps = args.apps.split(",") if args.apps else APP_TYPES
    updates = [f"enabled_{a.strip()}=1" for a in apps if a.strip() in APP_TYPES]
    if updates:
        cur.execute(f"UPDATE skills SET {', '.join(updates)} WHERE id=?", (sid,))
        db.commit()
    print(f"Enabled '{name}' for: {', '.join(apps)}")
    db.close()


def cmd_skill_disable(args):
    """Disable a skill for specific apps."""
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT id, name FROM skills WHERE LOWER(name)=LOWER(?)", (args.name,))
    row = cur.fetchone()
    if not row:
        print(f"Skill '{args.name}' not found.", file=sys.stderr)
        sys.exit(1)
    sid, name = row
    apps = args.apps.split(",") if args.apps else APP_TYPES
    updates = [f"enabled_{a.strip()}=0" for a in apps if a.strip() in APP_TYPES]
    if updates:
        cur.execute(f"UPDATE skills SET {', '.join(updates)} WHERE id=?", (sid,))
        db.commit()
    print(f"Disabled '{name}' for: {', '.join(apps)}")
    db.close()


def cmd_skill_rm(args):
    """Remove a skill."""
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT id, name FROM skills WHERE LOWER(name)=LOWER(?)", (args.name,))
    row = cur.fetchone()
    if not row:
        print(f"Skill '{args.name}' not found.", file=sys.stderr)
        sys.exit(1)
    sid, name = row
    cur.execute("DELETE FROM skills WHERE id=?", (sid,))
    db.commit()
    print(f"Removed skill '{name}'. Run 'skill sync' to clean up live configs.")
    db.close()


def cmd_skill_sync(args):
    """Sync enabled skills to live config directories (symlinks)."""
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT name, directory, enabled_claude, enabled_codex, "
        "enabled_gemini, enabled_opencode FROM skills"
    )
    rows = cur.fetchall()
    db.close()

    for app in APP_TYPES:
        skill_dir = SKILL_DIRS[app]
        skill_dir.mkdir(parents=True, exist_ok=True)
        col_idx = {"claude": 2, "codex": 3, "gemini": 4, "opencode": 5}[app]
        enabled_names = set()
        for row in rows:
            name, directory = row[0], row[1]
            enabled = row[col_idx]
            if enabled:
                enabled_names.add(name)
                link = skill_dir / name
                src = Path(directory)
                if link.is_symlink():
                    if link.resolve() == src.resolve():
                        continue
                    link.unlink()
                elif link.exists():
                    continue  # don't overwrite real dirs
                link.symlink_to(src)
        # Remove stale symlinks
        if skill_dir.exists():
            for item in skill_dir.iterdir():
                if item.is_symlink() and item.name not in enabled_names:
                    item.unlink()
        n = len(enabled_names)
        print(f"  [{app}] {n} skill(s) synced to {skill_dir}")


# ── Prompt commands ──────────────────────────────────────────────────


def cmd_prompt_list(args):
    db = get_db()
    cur = db.cursor()
    q = "SELECT id, app_type, name, enabled FROM prompts"
    params = ()
    if args.app:
        q += " WHERE app_type=?"
        params = (args.app,)
    q += " ORDER BY app_type, name"
    cur.execute(q, params)
    rows = cur.fetchall()
    if not rows:
        print("No prompts found.")
        return
    for pid, app, name, enabled in rows:
        print(f"  [{app}] {name} {'✓' if enabled else '✗'}  ({pid[:8]}...)")
    db.close()


def cmd_prompt_show(args):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "SELECT name, content, description, enabled FROM prompts "
        "WHERE LOWER(name)=LOWER(?) AND app_type=?",
        (args.name, args.app),
    )
    row = cur.fetchone()
    if not row:
        print(f"Prompt '{args.name}' not found for {args.app}.", file=sys.stderr)
        sys.exit(1)
    name, content, desc, enabled = row
    print(f"Name: {name}\nApp: {args.app}\nEnabled: {'yes' if enabled else 'no'}")
    if desc:
        print(f"Desc: {desc}")
    print(f"---\n{content}")
    db.close()


# ── Main ─────────────────────────────────────────────────────────────


def main():
    p = argparse.ArgumentParser(description="CC Switch CLI")
    sub = p.add_subparsers(dest="cmd")

    s = sub.add_parser("list", help="List providers")
    s.add_argument("--app", choices=APP_TYPES)

    sub.add_parser("current", help="Show current active providers")

    s = sub.add_parser("show", help="Show provider details")
    s.add_argument("name")
    s.add_argument("--app", required=True, choices=APP_TYPES)

    s = sub.add_parser("switch", help="Switch active provider")
    s.add_argument("name")
    s.add_argument("--app", required=True, choices=APP_TYPES)

    sub.add_parser("health", help="Show provider health")

    s_mcp = sub.add_parser("mcp", help="MCP server operations")
    ms = s_mcp.add_subparsers(dest="mcp_cmd")
    ms.add_parser("list", help="List MCP servers")
    s2 = ms.add_parser("show", help="Show MCP server details")
    s2.add_argument("id")
    s2a = ms.add_parser("add", help="Add MCP server")
    s2a.add_argument("name", help="Server name")
    s2a.add_argument("--command", required=True, help="Command to run")
    s2a.add_argument("--args", nargs="*", help="Command arguments")
    s2a.add_argument("--env", nargs="*", help="Env vars (KEY=VALUE)")
    s2a.add_argument("--apps", help="Comma-separated apps to enable (claude,codex,gemini,opencode)")
    s2a.add_argument("--desc", help="Description")
    s2b = ms.add_parser("enable", help="Enable MCP for apps")
    s2b.add_argument("id", help="Server name or ID")
    s2b.add_argument("--apps", help="Comma-separated apps (default: all)")
    s2c = ms.add_parser("disable", help="Disable MCP for apps")
    s2c.add_argument("id", help="Server name or ID")
    s2c.add_argument("--apps", help="Comma-separated apps (default: all)")
    s2d = ms.add_parser("rm", help="Remove MCP server")
    s2d.add_argument("id", help="Server name or ID")
    ms.add_parser("sync", help="Sync MCP to live configs")

    s_skill = sub.add_parser("skill", help="Skills operations")
    ss = s_skill.add_subparsers(dest="skill_cmd")
    s5 = ss.add_parser("list", help="List skills")
    s5.add_argument("--app", choices=APP_TYPES)
    s6 = ss.add_parser("install", help="Install skill from local path")
    s6.add_argument("path", help="Path to skill directory")
    s6.add_argument("--name", help="Override skill name")
    s6.add_argument("--apps", help="Comma-separated apps (default: claude)")
    s7 = ss.add_parser("enable", help="Enable skill for apps")
    s7.add_argument("name")
    s7.add_argument("--apps", help="Comma-separated apps (default: all)")
    s8 = ss.add_parser("disable", help="Disable skill for apps")
    s8.add_argument("name")
    s8.add_argument("--apps", help="Comma-separated apps (default: all)")
    s9 = ss.add_parser("rm", help="Remove skill")
    s9.add_argument("name")
    ss.add_parser("sync", help="Sync skills to live configs")

    s_pr = sub.add_parser("prompt", help="Prompt operations")
    ps = s_pr.add_subparsers(dest="prompt_cmd")
    s3 = ps.add_parser("list", help="List prompts")
    s3.add_argument("--app", choices=APP_TYPES)
    s4 = ps.add_parser("show", help="Show prompt content")
    s4.add_argument("name")
    s4.add_argument("--app", required=True, choices=APP_TYPES)

    args = p.parse_args()
    dispatch = {
        "list": cmd_list,
        "current": cmd_current,
        "show": cmd_show,
        "switch": cmd_switch,
        "health": cmd_health,
    }
    if args.cmd in dispatch:
        dispatch[args.cmd](args)
    elif args.cmd == "mcp":
        {
            "list": cmd_mcp_list, "show": cmd_mcp_show, "add": cmd_mcp_add,
            "enable": cmd_mcp_enable, "disable": cmd_mcp_disable,
            "rm": cmd_mcp_rm, "sync": cmd_mcp_sync,
        }.get(args.mcp_cmd, lambda _: s_mcp.print_help())(args)
    elif args.cmd == "skill":
        {
            "list": cmd_skill_list, "install": cmd_skill_install,
            "enable": cmd_skill_enable, "disable": cmd_skill_disable,
            "rm": cmd_skill_rm, "sync": cmd_skill_sync,
        }.get(args.skill_cmd, lambda _: s_skill.print_help())(args)
    elif args.cmd == "prompt":
        {"list": cmd_prompt_list, "show": cmd_prompt_show}.get(
            args.prompt_cmd, lambda _: s_pr.print_help()
        )(args)
    else:
        p.print_help()


if __name__ == "__main__":
    main()
