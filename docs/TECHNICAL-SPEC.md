# Technical Specification

EmailInput:
  sender
  subject
  received_at
  message_id?
  thread_reference?
  mailbox

AuditOutput:
  priority
  reason
  action_required
  proposed_follow_up?
  source_message_ids

Rules:
- Preserve source IDs when available.
- AI output is advisory.
- Never execute proposed actions automatically.
- Log execution status without storing unnecessary message content.
