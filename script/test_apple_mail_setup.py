#!/usr/bin/env python3
"""
test_apple_mail_setup.py

Testes para a configuração de conta IMAP no Apple Mail.
"""

import json
import os
import sys
import tempfile

# Adiciona diretório do script ao path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from apple_mail_account_setup import ImapAccount, validate_account, generate_applescript


def test_valid_account():
    """Testa validação de conta válida."""
    account = ImapAccount(
        account_name="Zoho – Danilo",
        full_name="Danilo",
        email="danilo@portfoliodanilo.com",
        username="danilo@portfoliodanilo.com",
        password="test-password",
        imap_server="imap.zoho.com",
        imap_port=993,
        imap_ssl=True,
        smtp_server="smtp.zoho.com",
        smtp_port=465,
        smtp_ssl=True,
        smtp_auth=True
    )

    errors = validate_account(account)
    assert len(errors) == 0, f"Erros inesperados: {errors}"
    print("✓ Teste de conta válida passou")


def test_invalid_email():
    """Testa email inválido."""
    account = ImapAccount(
        account_name="Test",
        full_name="Test",
        email="invalid-email",
        username="invalid-email",
        password="password",
        imap_server="imap.example.com",
        imap_port=993,
        imap_ssl=True,
        smtp_server="smtp.example.com",
        smtp_port=465,
        smtp_ssl=True,
        smtp_auth=True
    )

    errors = validate_account(account)
    assert len(errors) > 0, "Deveria detectar email inválido"
    assert any("Email inválido" in e for e in errors), "Mensagem de erro incorreta"
    print("✓ Teste de email inválido passou")


def test_missing_password():
    """Testa senha omitida."""
    account = ImapAccount(
        account_name="Test",
        full_name="Test",
        email="test@example.com",
        username="test@example.com",
        password="",
        imap_server="imap.example.com",
        imap_port=993,
        imap_ssl=True,
        smtp_server="smtp.example.com",
        smtp_port=465,
        smtp_ssl=True,
        smtp_auth=True
    )

    errors = validate_account(account)
    assert any("Senha" in e for e in errors), "Deveria detectar senha vazia"
    print("✓ Teste de senha vazia passou")


def test_invalid_port():
    """Testa portas inválidas."""
    account = ImapAccount(
        account_name="Test",
        full_name="Test",
        email="test@example.com",
        username="test@example.com",
        password="password",
        imap_server="imap.example.com",
        imap_port=99999,  # Porta inválida
        imap_ssl=True,
        smtp_server="smtp.example.com",
        smtp_port=99999,  # Porta inválida
        smtp_ssl=True,
        smtp_auth=True
    )

    errors = validate_account(account)
    assert len(errors) >= 1, "Deveria detectar portas inválidas"
    print("✓ Teste de portas inválidas passou")


def test_generate_applescript_zoho():
    """Testa geração de AppleScript para Zoho."""
    account = ImapAccount(
        account_name="Zoho – Danilo",
        full_name="Danilo",
        email="danilo@portfoliodanilo.com",
        username="danilo@portfoliodanilo.com",
        password="secretpassword",
        imap_server="imap.zoho.com",
        imap_port=993,
        imap_ssl=True,
        smtp_server="smtp.zoho.com",
        smtp_port=465,
        smtp_ssl=True,
        smtp_auth=True
    )

    script = generate_applescript(account)

    assert "imap.zoho.com" in script, "Servidor IMAP deveria estar no script"
    assert "smtp.zoho.com" in script, "Servidor SMTP deveria estar no script"
    assert "993" in script, "Porta IMAP deveria estar no script"
    assert "465" in script, "Porta SMTP deveria estar no script"
    assert "use SSL:true" in script, "SSL IMAP deveria estar ativado"
    assert "outgoing use SSL:true" in script, "SSL SMTP devere estar ativado"
    assert "danilo@portfoliodanilo.com" in script, "Email deveria estar no script"

    # Verifica que a senha está no script (segurança: apenas para geração)
    assert "secretpassword" in script, "Senha deveria estar no script (AppleScript)"

    print("✓ Teste de geração AppleScript passou")


def test_json_config_parsing():
    """Testa parsing de arquivo JSON de configuração."""
    config = {
        "account_name": "Zoho – Danilo",
        "full_name": "Danilo",
        "email": "danilo@portfoliodanilo.com",
        "username": "danilo@portfoliodanilo.com",
        "password": "test-password",
        "imap_server": "imap.zoho.com",
        "imap_port": 993,
        "imap_ssl": True,
        "smtp_server": "smtp.zoho.com",
        "smtp_port": 465,
        "smtp_ssl": True,
        "smtp_auth": True
    }

    account = ImapAccount(
        account_name=config["account_name"],
        full_name=config["full_name"],
        email=config["email"],
        username=config["username"],
        password=config["password"],
        imap_server=config["imap_server"],
        imap_port=config["imap_port"],
        imap_ssl=config["imap_ssl"],
        smtp_server=config["smtp_server"],
        smtp_port=config["smtp_port"],
        smtp_ssl=config["smtp_ssl"],
        smtp_auth=config["smtp_auth"]
    )

    errors = validate_account(account)
    assert len(errors) == 0, f"Config JSON deveria ser válida: {errors}"
    print("✓ Teste de parsing JSON passou")


def test_zoho_custom_server():
    """Testa configuração com servidor Zoho customizado."""
    # Para domínios próprios, Zoho usa imappro.zoho.com
    account = ImapAccount(
        account_name="Zoho – Danilo",
        full_name="Danilo",
        email="danilo@portfoliodanilo.com",
        username="danilo@portfoliodanilo.com",
        password="test-password",
        imap_server="imappro.zoho.com",  # Servidor customizado
        imap_port=993,
        imap_ssl=True,
        smtp_server="smtp.zoho.com",
        smtp_port=465,
        smtp_ssl=True,
        smtp_auth=True
    )

    script = generate_applescript(account)
    assert "imappro.zoho.com" in script, "Servidor customizado deveria estar no script"

    print("✓ Teste de servidor Zoho customizado passou")


def run_all_tests():
    """Executa todos os testes."""
    print("\n=== Executando testes de Apple Mail Setup ===\n")

    tests = [
        test_valid_account,
        test_invalid_email,
        test_missing_password,
        test_invalid_port,
        test_generate_applescript_zoho,
        test_json_config_parsing,
        test_zoho_custom_server
    ]

    passed = 0
    failed = 0

    for test in tests:
        try:
            test()
            passed += 1
        except AssertionError as e:
            print(f"✗ {test.__name__} falhou: {e}")
            failed += 1
        except Exception as e:
            print(f"✗ {test.__name__} erro inesperado: {e}")
            failed += 1

    print(f"\n=== Resultado: {passed} passaram, {failed} falharam ===")
    return failed == 0


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)