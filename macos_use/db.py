"""
Database Manager for macOS Automation System.
Handles project configuration and audit logs in SQLite database.
"""

import sqlite3
import os
from pathlib import Path
from typing import Dict, Any, List, Optional


DB_DIR = Path.home() / "Library" / "Application Support" / "MacOS-Use"
DB_PATH = DB_DIR / "config.db"
SCHEMA_PATH = Path(__file__).parent.parent / "src" / "database" / "schema.sql"


def get_db_connection() -> sqlite3.Connection:
    """Ensure DB directory exists and return SQLite connection."""
    DB_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Initialize database tables from schema.sql."""
    conn = get_db_connection()
    if SCHEMA_PATH.exists():
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            conn.executescript(f.read())
        conn.commit()
    conn.close()


def get_config(key: str, default: Optional[str] = None) -> Optional[str]:
    """Fetch a configuration value from DB."""
    init_db()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT value FROM automation_config WHERE key = ?", (key,))
    row = cursor.fetchone()
    conn.close()
    return row["value"] if row else default


def get_all_config() -> Dict[str, str]:
    """Fetch all configuration key-values as a dict."""
    init_db()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT key, value FROM automation_config")
    rows = cursor.fetchall()
    conn.close()
    return {row["key"]: row["value"] for row in rows}


def set_config(key: str, value: str):
    """Set or update a configuration key in DB."""
    init_db()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO automation_config (key, value, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) "
        "ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = CURRENT_TIMESTAMP",
        (key, value)
    )
    conn.commit()
    conn.close()


def log_mail_audit(total_unread: int, vip_count: int, urgent_count: int, summary_text: str, status: str = "SUCCESS"):
    """Record an execution log entry for Apple Mail AI audit."""
    init_db()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO mail_audit_logs (total_unread, vip_count, urgent_count, summary_text, status) "
        "VALUES (?, ?, ?, ?, ?)",
        (total_unread, vip_count, urgent_count, summary_text, status)
    )
    conn.commit()
    conn.close()


def get_recent_audit_logs(limit: int = 10) -> List[Dict[str, Any]]:
    """Retrieve recent mail audit logs."""
    init_db()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id, processed_at, total_unread, vip_count, urgent_count, summary_text, status "
        "FROM mail_audit_logs ORDER BY processed_at DESC LIMIT ?",
        (limit,)
    )
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]
