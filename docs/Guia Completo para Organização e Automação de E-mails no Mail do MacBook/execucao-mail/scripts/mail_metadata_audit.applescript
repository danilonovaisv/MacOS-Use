-- Apple Mail 16.0 metadata-only audit.
-- Reads only account, sender, date sent, read status, and flagged status.
-- Never reads message content, recipients, headers, or attachments.

property maxMessagesPerAccount : 500
property tabCharacter : character id 9
property lineFeed : character id 10

on replaceText(sourceText, searchText, replacementText)
	set savedDelimiters to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to searchText
		set textParts to every text item of sourceText
		set AppleScript's text item delimiters to replacementText
		set resultText to textParts as text
		set AppleScript's text item delimiters to savedDelimiters
		return resultText
	on error errorMessage number errorNumber
		set AppleScript's text item delimiters to savedDelimiters
		error errorMessage number errorNumber
	end try
end replaceText

on sanitizeField(valueText)
	set cleanedText to valueText as text
	set cleanedText to my replaceText(cleanedText, tabCharacter, " ")
	set cleanedText to my replaceText(cleanedText, return, " ")
	set cleanedText to my replaceText(cleanedText, lineFeed, " ")
	return cleanedText
end sanitizeField

on domainFromAddress(addressText)
	set savedDelimiters to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to "@"
		set addressParts to every text item of addressText
		if (count of addressParts) is greater than 1 then
			set domainText to item -1 of addressParts
		else
			set domainText to ""
		end if
		set AppleScript's text item delimiters to savedDelimiters
		return my sanitizeField(domainText)
	on error errorMessage number errorNumber
		set AppleScript's text item delimiters to savedDelimiters
		error errorMessage number errorNumber
	end try
end domainFromAddress

on booleanText(booleanValue)
	if booleanValue then return "true"
	return "false"
end booleanText

on writeUTF8(outputText, outputPath)
	set fileReference to missing value
	try
		set fileReference to open for access (POSIX file outputPath) with write permission
		set eof fileReference to 0
		write outputText to fileReference as «class utf8»
		close access fileReference
	on error errorMessage number errorNumber
		try
			if fileReference is not missing value then close access fileReference
		end try
		error errorMessage number errorNumber
	end try
end writeUTF8

on run argumentList
	if (count of argumentList) is less than 2 then error "Usage: osascript mail_metadata_audit.applescript OUTPUT_TSV ERROR_LOG" number 64

	set outputPath to item 1 of argumentList
	set errorPath to item 2 of argumentList
	set reportText to "account" & tabCharacter & "sender" & tabCharacter & "domain" & tabCharacter & "date" & tabCharacter & "read" & tabCharacter & "flagged" & lineFeed
	set errorText to "account" & tabCharacter & "error_number" & tabCharacter & "error" & lineFeed

	try
		tell application "Mail"
			set configuredAccounts to every account
			repeat with currentAccount in configuredAccounts
				set accountName to "unknown"
				try
					set accountName to my sanitizeField(name of currentAccount)
					if enabled of currentAccount then
						set inboxMailbox to missing value
						repeat with candidateMailbox in (get mailboxes of currentAccount)
							set mailboxName to name of candidateMailbox as text
							ignoring case
								if mailboxName is in {"INBOX", "Inbox", "Entrada", "Caixa de Entrada"} then
									set inboxMailbox to candidateMailbox
									exit repeat
								end if
							end ignoring
						end repeat

						if inboxMailbox is missing value then error "Inbox mailbox not found" number 1001

						set mailboxMessages to messages of inboxMailbox
						set messageCount to count of mailboxMessages
						set sampleCount to messageCount
						if sampleCount is greater than maxMessagesPerAccount then set sampleCount to maxMessagesPerAccount

						repeat with messageIndex from 1 to sampleCount
							try
								set currentMessage to item messageIndex of mailboxMessages
								set senderValue to sender of currentMessage as text
								try
									set senderAddress to extract address from senderValue
								on error
									set senderAddress to senderValue
								end try
								set senderAddress to my sanitizeField(senderAddress)
								set domainValue to my domainFromAddress(senderAddress)
								set dateValue to my sanitizeField(date sent of currentMessage as text)
								set readValue to my booleanText(read status of currentMessage)
								set flaggedValue to my booleanText(flagged status of currentMessage)
								set reportText to reportText & accountName & tabCharacter & senderAddress & tabCharacter & domainValue & tabCharacter & dateValue & tabCharacter & readValue & tabCharacter & flaggedValue & lineFeed
							on error errorMessage number errorNumber
								if errorNumber is -128 then error errorMessage number errorNumber
								set errorText to errorText & accountName & tabCharacter & errorNumber & tabCharacter & my sanitizeField(errorMessage) & lineFeed
							end try
						end repeat
					end if
				on error errorMessage number errorNumber
					if errorNumber is -128 then
						set errorText to errorText & accountName & tabCharacter & errorNumber & tabCharacter & "Cancelled by user" & lineFeed
					else
						set errorText to errorText & accountName & tabCharacter & errorNumber & tabCharacter & my sanitizeField(errorMessage) & lineFeed
					end if
				end try
			end repeat
		end tell
	on error errorMessage number errorNumber
		set errorText to errorText & "Mail" & tabCharacter & errorNumber & tabCharacter & my sanitizeField(errorMessage) & lineFeed
	end try

	my writeUTF8(reportText, outputPath)
	my writeUTF8(errorText, errorPath)
	return "metadata_rows=" & ((count paragraphs of reportText) - 1)
end run

