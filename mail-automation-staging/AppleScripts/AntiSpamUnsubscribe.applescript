-- Pilot List-Unsubscribe detector for Apple Mail.
-- Safety contract: checks header presence and logs a review candidate only.
-- It never opens links, unsubscribes, flags, moves, or deletes messages.

property maxManualMessages : 50

using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		my processMessages(theMessages, "rule")
	end perform mail action with messages
end using terms from

on run
	tell application "Mail" to set selectedMessages to selection
	if (count of selectedMessages) is 0 then
		my appendLog("[INFO] [unsubscribe] [manual] SKIP no selected messages")
		return "SKIP: select up to 50 messages in Mail"
	end if
	my processMessages(selectedMessages, "manual")
end run

on processMessages(theMessages, executionMode)
	set messageCount to count of theMessages
	if executionMode is "manual" and messageCount > maxManualMessages then set messageCount to maxManualMessages
	repeat with messageIndex from 1 to messageCount
		my inspectMessage(item messageIndex of theMessages, executionMode)
	end repeat
	return "OK: reviewed " & messageCount & " message(s)"
end processMessages

on inspectMessage(aMessage, executionMode)
	tell application "Mail"
		try
			set messageId to (id of aMessage as text)
			set messageHeaders to all headers of aMessage
			ignoring case
				set isCandidate to messageHeaders contains "List-Unsubscribe:"
			end ignoring
			if isCandidate then my appendLog("[CANDIDATE] [unsubscribe] [" & executionMode & "] message_id=" & messageId)
		on error errorMessage number errorNumber
			my appendLog("[ERROR] [unsubscribe] code=" & errorNumber & " " & errorMessage)
		end try
	end tell
end inspectMessage

on appendLog(logMessage)
	set logPath to (POSIX path of (path to library folder from user domain)) & "Logs/MailAutomation.log"
	try
		do shell script "/usr/bin/printf '%s\\n' " & quoted form of ((current date as text) & " " & logMessage) & " >> " & quoted form of logPath
	end try
end appendLog
