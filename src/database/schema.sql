-- Database Schema for macOS Automation & Apple Mail AI Integration
-- Database File: ~/Library/Application Support/MacOS-Use/config.db (SQLite)

CREATE TABLE IF NOT EXISTS automation_config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mail_audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_unread INTEGER NOT NULL,
    vip_count INTEGER NOT NULL,
    urgent_count INTEGER NOT NULL,
    summary_text TEXT NOT NULL,
    status TEXT NOT NULL
);

-- Initial default configuration records
INSERT OR IGNORE INTO automation_config (key, value) VALUES
    ('vip_senders', 'apple.com,google.com,github.com,danilo'),
    ('urgent_keywords', 'urgente,prazo,vence hoje,importante,aprovacao'),
    ('noise_senders', 'no-reply,noreply,newsletter,marketing,promocoes'),
    ('max_scan_limit', '150'),
    ('daily_summary_time', '08:00'),
    ('notification_enabled', 'true');
