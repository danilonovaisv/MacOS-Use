#!/usr/bin/env python3
"""
apple-mail-account-setup.py

Configura contas IMAP no Apple Mail via AppleScript.
Módulo seguro - apenas cria/valida configurações, não modifica mensagens.
"""

import subprocess
import sys
import json
from dataclasses import dataclass
from typing import Optional


@dataclass
class ImapAccount:
    """Representa uma conta IMAP a ser configurada."""
    account_name: str
    full_name: str
    email: str
    username: str
    password: str
    imap_server: str
    imap_port: int
    imap_ssl: bool
    smtp_server: str
    smtp_port: int
    smtp_ssl: bool
    smtp_auth: bool
    account_type: str = "IMAP"


def validate_account(account: ImapAccount) -> list[str]:
    """Valida parâmetros da conta IMAP."""
    errors = []

    if not account.email or "@" not in account.email:
        errors.append("Email inválido - deve conter @")

    if not account.password:
        errors.append("Senha é obrigatória")

    if account.imap_port not in [993, 143]:
        errors.append(f"Porta IMAP inesperada: {account.imap_port}")

    if account.smtp_port not in [465, 587, 25]:
        errors.append(f"Porta SMTP inesperada: {account.smtp_port}")

    if account.account_type.upper() != "IMAP":
        errors.append(f"Tipo de conta inválido: {account.account_type}")

    return errors


def generate_applescript(account: ImapAccount) -> str:
    """Gera AppleScript para criar a conta."""
    imap_ssl_str = "true" if account.imap_ssl else "false"
    smtp_ssl_str = "true" if account.smtp_ssl else "false"
    smtp_auth_str = "true" if account.smtp_auth else "false"

    script = f'''
tell application "Mail"
    -- Verifica se conta já existe
    set accountExists to false
    set accountList to name of every account
    repeat with acct in accountList
        if acct is "{account.account_name}" then
            set accountExists to true
            exit repeat
        end if
    end repeat

    if accountExists then
        return "EXISTS"
    end if

    -- Cria nova conta IMAP
    try
        make new account with properties {{
            name:"{account.account_name}",
            short name:"{account.email}",
            user name:"{account.username}",
            password:"{account.password}",
            incoming mail server:"{account.imap_server}",
            incoming mail server port:{account.imap_port},
            use SSL:{imap_ssl_str},
            outgoing mail server:"{account.smtp_server}",
            outgoing mail server port:{account.smtp_port},
            outgoing use SSL:{smtp_ssl_str},
            outgoing authentication required:{smtp_auth_str},
            kind:IMAP
        }}

        return "CREATED"
    on error errMsg number errNum
        return "ERROR: " & errMsg
    end try
end tell
'''
    return script


def execute_applescript(script: str, dry_run: bool = False) -> tuple[bool, str]:
    """Executa o AppleScript via osascript."""
    if dry_run:
        return True, "Dry run - script gerado (não executado)"

    try:
        result = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            timeout=30
        )

        output = (result.stdout or result.stderr).strip()

        if result.returncode == 0:
            if "EXISTS" in output:
                return True, "Conta já existe no Apple Mail"
            elif "CREATED" in output:
                return True, "Conta criada com sucesso no Apple Mail"
            elif "ERROR" in output:
                return False, output
            else:
                return True, output or "Comando executado com sucesso"
        else:
            return False, output or f"Erro de execução (código: {result.returncode})"

    except subprocess.TimeoutExpired:
        return False, "Timeout ao executar AppleScript"
    except Exception as e:
        return False, str(e)


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "Uso: python apple-mail-account-setup.py <config.json>",
            "usage": "Passar arquivo JSON com parâmetros da conta"
        }))
        sys.exit(1)

    # Carrega configuração
    config_path = sys.argv[1]
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
    except FileNotFoundError:
        print(json.dumps({"error": f"Arquivo não encontrado: {config_path}"}))
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"JSON inválido: {e}"}))
        sys.exit(1)

    # Cria objeto de conta
    account = ImapAccount(
        account_name=config.get("account_name", "Zoho – Danilo"),
        full_name=config.get("full_name", "Danilo"),
        email=config["email"],
        username=config["username"],
        password=config["password"],
        imap_server=config.get("imap_server", "imap.zoho.com"),
        imap_port=config.get("imap_port", 993),
        imap_ssl=config.get("imap_ssl", True),
        smtp_server=config.get("smtp_server", "smtp.zoho.com"),
        smtp_port=config.get("smtp_port", 465),
        smtp_ssl=config.get("smtp_ssl", True),
        smtp_auth=config.get("smtp_auth", True),
        account_type=config.get("account_type", "IMAP")
    )

    # Valida
    errors = validate_account(account)
    if errors:
        print(json.dumps({"success": False, "errors": errors}))
        sys.exit(1)

    # Gera script
    script = generate_applescript(account)

    # Execução com aprovação humana (via parâmetro --execute ou env var)
    import os
    dry_run = not ('--execute' in sys.argv or os.environ.get('EXECUTE_SCRIPT') == '1')
    result, message = execute_applescript(script, dry_run=dry_run)

    # Output
    output = {
        "success": result,
        "message": message if not result else "Script gerado com sucesso",
        "account": account.account_name,
        "email": account.email,
        "generated_script_preview": script[:500] + "..." if len(script) > 500 else script
    }

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()