-- Pilot taxonomy classifier for Apple Mail.
-- Safety contract: reads sender/subject metadata and logs a suggestion only.
-- It never moves, deletes, creates mailboxes, or changes message state.

property maxManualMessages : 50

using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		my processMessages(theMessages, "rule")
	end perform mail action with messages
end using terms from

on run
	tell application "Mail" to set selectedMessages to selection
	if (count of selectedMessages) is 0 then
		my logInfo("taxonomy", "SKIP", "no selected messages")
		return "SKIP: select up to 50 messages in Mail"
	end if
	my processMessages(selectedMessages, "manual")
end run

on processMessages(theMessages, executionMode)
	set messageCount to count of theMessages
	if executionMode is "manual" and messageCount > maxManualMessages then set messageCount to maxManualMessages
	repeat with messageIndex from 1 to messageCount
		my classifyMessage(item messageIndex of theMessages, executionMode)
	end repeat
	return "OK: reviewed " & messageCount & " message(s)"
end processMessages

on classifyMessage(aMessage, executionMode)
	tell application "Mail"
		try
			set messageId to (id of aMessage as text)
			set messageSubject to subject of aMessage
			set messageSender to sender of aMessage
			set suggestedCategory to my categoryFor(messageSubject, messageSender)
			my logInfo("taxonomy", executionMode, "message_id=" & messageId & " suggested_category=" & suggestedCategory)
		on error errorMessage number errorNumber
			my logError("taxonomy", errorMessage, errorNumber)
		end try
	end tell
end classifyMessage

on categoryFor(messageSubject, messageSender)
	set combinedText to messageSubject & " " & messageSender
	if my containsAny(combinedText, {"fatura", "boleto", "pagamento", "invoice", "receipt", "comprovante", "imposto", "banco", "fintech", "contabilidade"}) then
		return "Financeiro"
	else if my containsAny(combinedText, {"projeto", "urgente", "contrato", "relatório", "relatorio", "cliente"}) then
		return "Trabalho"
	else if my containsAny(combinedText, {"newsletter", "boletim", "digest", "resumo semanal"}) then
		return "Leitura"
	else if my containsAny(combinedText, {"reserva", "voo", "hotel", "ticket", "itinerário", "itinerario"}) then
		return "Viagens"
	end if
	return "Revisar manualmente"
end categoryFor

on containsAny(sourceText, candidates)
	ignoring case
		repeat with candidateText in candidates
			if sourceText contains (candidateText as text) then return true
		end repeat
	end ignoring
	return false
end containsAny

on logInfo(componentName, executionMode, detailText)
	my appendLog("[INFO] [" & componentName & "] [" & executionMode & "] " & detailText)
end logInfo

on logError(componentName, errorMessage, errorNumber)
	my appendLog("[ERROR] [" & componentName & "] code=" & errorNumber & " " & errorMessage)
end logError

on appendLog(logMessage)
	set logPath to (POSIX path of (path to library folder from user domain)) & "Logs/MailAutomation.log"
	try
		do shell script "/usr/bin/printf '%s\\n' " & quoted form of ((current date as text) & " " & logMessage) & " >> " & quoted form of logPath
	end try
end appendLog
