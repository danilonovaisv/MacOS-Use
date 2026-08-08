-- mail-morning-audit.applescript
-- Auditoria matinal somente leitura para o Apple Mail.

-- Ajuste estas listas depois de revisar falsos positivos e negativos reais.
property vipSenders : {"memed.com.br", "magalu.com", "magazineluiza.com.br"}
property urgentKeywords : {"urgente", "urgent", "asap", "emergência", "prazo final", "deadline", "vence hoje", "vencimento hoje"}
property noiseSenders : {"noreply", "no-reply", "notification", "notifications@", "newsletter"}

-- A auditoria para ao atingir 150 não lidas ou após inspecionar 500 mensagens recentes.
property maxMessagesToScan : 150
property maxInboxMessagesToInspect : 500

on run
	set redList to {}
	set orangeList to {}
	set grayCount to 0
	set totalScanned to 0
	set totalInspected to 0
	set skippedCount to 0
	set unreadLimit to maxMessagesToScan
	set inspectCap to maxInboxMessagesToInspect
	set reportFolderPOSIX to (POSIX path of (path to desktop folder)) & "Auditoria-Mail/"

	tell application "Mail"
		set theMessages to messages of inbox
		set messageCount to count of theMessages
		set inspectLimit to inspectCap
		if messageCount < inspectLimit then set inspectLimit to messageCount

		repeat with messageIndex from 1 to inspectLimit
			if totalScanned is greater than or equal to unreadLimit then exit repeat

			set totalInspected to totalInspected + 1
			try
				set thisMessage to item messageIndex of theMessages
				if read status of thisMessage is false then
					set totalScanned to totalScanned + 1
					set messageSubject to my textOrFallback(subject of thisMessage, "(sem assunto)")
					set messageSender to my textOrFallback(sender of thisMessage, "(remetente indisponível)")

					set isVIP to my containsAny(messageSender, vipSenders)
					set hasUrgentKeyword to my containsAny(messageSubject, urgentKeywords)
					set isNoise to my containsAny(messageSender, noiseSenders)

					-- VIP sempre prevalece; ruído conhecido prevalece sobre palavra urgente isolada.
					if isVIP and hasUrgentKeyword then
						set end of redList to (messageSender & " — " & messageSubject)
					else if isVIP then
						set end of orangeList to (messageSender & " — " & messageSubject)
					else if isNoise then
						set grayCount to grayCount + 1
					else if hasUrgentKeyword then
						set end of orangeList to (messageSender & " — " & messageSubject)
					end if
				end if
			on error
				set skippedCount to skippedCount + 1
			end try
		end repeat
	end tell

	set reportText to my buildReport(redList, orangeList, grayCount, totalScanned, totalInspected, skippedCount)
	set reportPath to my saveReport(reportText, reportFolderPOSIX)

	display notification ((count of redList) as text) & " urgentes · " & ((count of orangeList) as text) & " atenção · " & (grayCount as text) & " ruído" with title "Auditoria de E-mail" sound name "Glass"

	return "Auditoria concluída: " & ((count of redList) as text) & " urgentes, " & ((count of orangeList) as text) & " atenção, " & (grayCount as text) & " ruído. Relatório: " & reportPath
end run

on containsAny(sourceText, searchTerms)
	ignoring case
		repeat with searchTerm in searchTerms
			if sourceText contains (searchTerm as text) then return true
		end repeat
	end ignoring
	return false
end containsAny

on textOrFallback(sourceValue, fallbackText)
	if sourceValue is missing value then return fallbackText
	try
		return sourceValue as text
	on error
		return fallbackText
	end try
end textOrFallback

on buildReport(redList, orangeList, grayCount, totalScanned, totalInspected, skippedCount)
	set reportText to "AUDITORIA DE E-MAIL — " & my formatDate(current date) & linefeed
	set reportText to reportText & "Modo: somente leitura; nenhuma mensagem foi modificada." & linefeed & linefeed

	set reportText to reportText & "AÇÃO IMEDIATA (" & ((count of redList) as text) & "):" & linefeed
	if (count of redList) is 0 then
		set reportText to reportText & "  Nenhuma." & linefeed
	else
		repeat with reportLine in redList
			set reportText to reportText & "  • " & reportLine & linefeed
		end repeat
	end if

	set reportText to reportText & linefeed & "ATENÇÃO (" & ((count of orangeList) as text) & "):" & linefeed
	if (count of orangeList) is 0 then
		set reportText to reportText & "  Nenhuma." & linefeed
	else
		repeat with reportLine in orangeList
			set reportText to reportText & "  • " & reportLine & linefeed
		end repeat
	end if

	set reportText to reportText & linefeed & "Ruído identificado: " & (grayCount as text) & linefeed
	set reportText to reportText & "Não lidas analisadas: " & (totalScanned as text) & linefeed
	set reportText to reportText & "Mensagens recentes inspecionadas: " & (totalInspected as text) & linefeed
	set reportText to reportText & "Mensagens ignoradas por erro: " & (skippedCount as text) & linefeed

	return reportText
end buildReport

on formatDate(dateValue)
	set yearText to year of dateValue as text
	set monthText to my padZero((month of dateValue) as integer)
	set dayText to my padZero(day of dateValue)
	return dayText & "/" & monthText & "/" & yearText
end formatDate

on formatISODate(dateValue)
	set yearText to year of dateValue as text
	set monthText to my padZero((month of dateValue) as integer)
	set dayText to my padZero(day of dateValue)
	return yearText & "-" & monthText & "-" & dayText
end formatISODate

on padZero(numberValue)
	if numberValue < 10 then return "0" & (numberValue as text)
	return numberValue as text
end padZero

on saveReport(reportText, reportFolderPOSIX)
	do shell script "/bin/mkdir -p " & quoted form of reportFolderPOSIX

	set fileName to "auditoria-" & my formatISODate(current date) & ".txt"
	set filePath to reportFolderPOSIX & fileName
	set reportFile to POSIX file filePath
	set fileDescriptor to missing value

	try
		set fileDescriptor to open for access reportFile with write permission
		set eof fileDescriptor to 0
		write reportText to fileDescriptor as «class utf8»
		close access fileDescriptor
	on error errorMessage number errorNumber
		if fileDescriptor is not missing value then
			try
				close access fileDescriptor
			end try
		end if
		error errorMessage number errorNumber
	end try

	return filePath
end saveReport
