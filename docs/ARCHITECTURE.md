# Architecture

Apple Mail
  -> AppleScript extraction
  -> normalized message/thread model
  -> classification
  -> optional AI reasoning
  -> report/draft proposal
  -> SQLite audit log
  -> macOS notification

launchd -> scheduled read-only audit

staging -> validation -> human approval -> production
