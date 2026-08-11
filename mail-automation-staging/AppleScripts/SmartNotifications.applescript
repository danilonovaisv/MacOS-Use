-- Pilot notification action for Apple Mail.
-- A Mail rule must restrict invocations to VIP or critical messages.
-- Standalone mode notifies only selected messages with critical subject terms.

property maxManualMessages : 20

using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		my processMessages(theMessages, "rule", true)
	end perform mail action with messages
end using terms from

on run
	tell application "Mail" to set selectedMessages to selection
	if (count of selectedMessages) is 0 then
		my appendLog("[INFO] [notification] [manual] SKIP no selected messages")
		return "SKIP: select up to 20 messages in Mail"
	end if
	my processMessages(selectedMessages, "manual", false)
end run

on processMessages(theMessages, executionMode, trustRuleMatch)
	set messageCount to count of theMessages
	if executionMode is "manual" and messageCount > maxManualMessages then set messageCount to maxManualMessages
	repeat with messageIndex from 1 to messageCount
		my evaluateMessage(item messageIndex of theMessages, executionMode, trustRuleMatch)
	end repeat
	return "OK: reviewed " & messageCount & " message(s)"
end processMessages

on evaluateMessage(aMessage, executionMode, trustRuleMatch)
	tell application "Mail"
		try
			set messageId to (id of aMessage as text)
			set messageSender to sender of aMessage
			set messageSubject to subject of aMessage
			set shouldNotify to trustRuleMatch or my containsCriticalTerm(messageSubject)
			if shouldNotify then
				display notification messageSubject with title "Mail prioritário" subtitle ("De: " & messageSender)
				my appendLog("[INFO] [notification] [" & executionMode & "] message_id=" & messageId)
			end if
		on error errorMessage number errorNumber
			my appendLog("[ERROR] [notification] code=" & errorNumber & " " & errorMessage)
		end try
	end tell
end evaluateMessage

on containsCriticalTerm(messageSubject)
	ignoring case
		repeat with criticalTerm in {"urgente", "crítico", "critico", "emergência", "emergencia", "contrato", "aprovação", "aprovacao", "segurança", "seguranca"}
			if messageSubject contains (criticalTerm as text) then return true
		end repeat
	end ignoring
	return false
end containsCriticalTerm

on appendLog(logMessage)
	set logPath to (POSIX path of (path to library folder from user domain)) & "Logs/MailAutomation.log"
	try
		do shell script "/usr/bin/printf '%s\\n' " & quoted form of ((current date as text) & " " & logMessage) & " >> " & quoted form of logPath
	end try
end appendLog
