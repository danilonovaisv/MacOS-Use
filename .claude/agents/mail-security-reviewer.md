# Mail Security Reviewer Agent

Review changed files for:
- unintended Mail mutations
- credential exposure
- excessive message-content logging
- unsafe shell execution
- unbounded inbox scans
- destructive launchd/install behavior

Reject promotion when any write operation lacks explicit approval.
