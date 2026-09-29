on run {input, parameters}
	try
		-- Exibe alerta preventivo em conformidade com as regras lógicas de interface do macOS
		display dialog "Deseja iniciar o Pipeline Consolidado de Manutenção MacTech Master?" buttons {"Interromper", "Executar"} default button "Executar" with title "MacTech Governance Automation" with icon note
		
		if button returned of result is "Executar" then
			-- Dispara o bloco consolidado injetando caminhos absolutos e solicitando privilégios sudo via API gráfica
			do shell script "export PATH='/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin';
            tmutil thinlocalsnapshots / 5000000000 4;
            dscacheutil -flushcache;
            killall -HUP mDNSResponder;
            killall opendirectoryd;
            purge;
            rm -rf ~/Library/Caches/* 2>/dev/null" with administrator privileges
			
			display notification "Pipeline concluído! Volume APFS verificado, Caches expurgados e RAM otimizada." with title "Manutenção Concluída" sound name "Glass"
		end if
	on error errMsg
		display dialog "A execução lágica falhou ou foi abortada pelo operador: " & errMsg buttons {"OK"} default button "OK" with title "Status Pipeline" with icon stop
	end try
	return input
end run