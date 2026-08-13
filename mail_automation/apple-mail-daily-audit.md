# Apple Mail Daily Audit

## Purpose

Daily, read-only review of messages received in the aggregated Apple Mail Inbox. The result returns to the originating scheduled ChatGPT task as a structured Portuguese report.

## Schedule

- Runs every day at 08:00 in `America/Sao_Paulo`.
- Automation ID: `auditoria-di-ria-do-apple-mail`.
- First successful run covers the preceding 24 hours.
- Later runs start at the last successful audit timestamp. Failed runs must not advance that timestamp.

## Scope And Safety

- Covers all configured accounts, read and unread messages, Inbox only.
- May read message metadata and textual body only inside the audit window.
- Must not open links or attachments.
- Must not reply, forward, draft, delete, move, archive, flag, mark read/unread, mark spam, unsubscribe, or change Mail settings.
- Sensitive values are masked in the report, and uncertain classification is routed to manual review.
- The scheduled task invokes the Apple Mail skill but excludes mutation scripts and the staged notification, taxonomy, unsubscribe, and legacy summarizer routines.

## Legacy Routine

The LaunchAgent `com.danilonovais.mailaudit` was disabled and unloaded on 2026-08-11 to avoid duplicate 08:00 runs. Its installed plist, source, reports, and logs were preserved. Re-enabling it requires an explicit decision because it overlaps with the ChatGPT scheduled task.

The separate `com.user.mailautomation` service remains enabled. It runs a health check every 30 minutes, has a successful last exit, and is not a daily report or a scheduling conflict.

## Verification Notes

- The scheduled task is active and attached to its original conversation.
- The environment timezone resolves to UTC-03, matching `America/Sao_Paulo`.
- Apple Mail account discovery succeeded without reading messages.
- A metadata-only aggregate date query exceeded 30 seconds and was interrupted without changing Mail. Review the first scheduled runs for duration or permission failures.

## Related

- [[mcp-integration-subsystem]]
- [[codebase-architecture-overview]]
