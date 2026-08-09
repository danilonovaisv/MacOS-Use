#!/usr/bin/env python3
"""
Apple Mail AI Daily Summarizer & Automation Daemon
Integrates macOS Apple Mail with Gemini AI and SQLite Project Database.
"""

import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path

# Add project root to sys.path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.db import get_all_config, log_mail_audit, init_db

# Load dotenv if present
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# Try importing google-genai SDK
try:
    from google import genai
    HAS_GENAI = True
except ImportError:
    HAS_GENAI = False


def extract_unread_emails(max_count: int = 100) -> list:
    """Extract unread email metadata from Apple Mail using AppleScript."""
    applescript = f'''
    tell application "Mail"
        try
            set unreadMsgs to (messages of inbox whose read status is false)
            set msgCount to count of unreadMsgs
            if msgCount is 0 then return ""
            set maxLimit to {max_count}
            if msgCount < maxLimit then set maxLimit to msgCount
            set outputStr to ""
            repeat with i from 1 to maxLimit
                set msg to item i of unreadMsgs
                set outputStr to outputStr & (sender of msg) & "|||" & (subject of msg) & "|||" & (date received of msg as string) & "___END_MSG___"
            end repeat
            return outputStr
        on error errStr
            return "ERROR:" & errStr
        end try
    end tell
    '''
    try:
        res = subprocess.run(
            ["osascript", "-e", applescript],
            capture_output=True,
            text=True,
            timeout=10
        )
        if res.returncode != 0:
            print(f"⚠️ AppleScript Error: {res.stderr.strip()}")
            return []
        
        raw_output = res.stdout.strip()
        if not raw_output:
            return []
        
        messages = []
        raw_blocks = raw_output.split("___END_MSG___")
        for block in raw_blocks:
            block = block.strip()
            if not block:
                continue
            parts = block.split("|||")
            if len(parts) >= 2:
                sender = parts[0].strip()
                subject = parts[1].strip()
                date_str = parts[2].strip() if len(parts) > 2 else ""
                messages.append({
                    "sender": sender,
                    "subject": subject,
                    "date": date_str
                })
        return messages
    except Exception as e:
        print(f"❌ Error extracting emails: {e}")
        return []


def generate_ai_summary(messages: list, config: dict) -> str:
    """Generate executive AI summary using Google GenAI SDK if API key available, or heuristic fallback."""
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    
    vip_senders = [s.strip().lower() for s in config.get("vip_senders", "").split(",") if s.strip()]
    urgent_keywords = [k.strip().lower() for k in config.get("urgent_keywords", "").split(",") if k.strip()]

    # Heuristic tagging
    vip_count = 0
    urgent_count = 0
    formatted_msg_text = []

    for msg in messages:
        sender_lower = msg["sender"].lower()
        subject_lower = msg["subject"].lower()
        
        is_vip = any(vip in sender_lower for vip in vip_senders)
        is_urgent = any(urg in subject_lower for urg in urgent_keywords)
        
        if is_vip:
            vip_count += 1
        if is_urgent:
            urgent_count += 1

        tag = "🔴 [VIP/URGENTE]" if (is_vip or is_urgent) else "🔹 [NORMAL]"
        formatted_msg_text.append(f"{tag} Remetente: {msg['sender']} | Assunto: {msg['subject']} ({msg['date']})")

    msg_summary_block = "\n".join(formatted_msg_text[:50])

    if HAS_GENAI and api_key:
        try:
            print("🤖 Sintetizando resumo via Google GenAI SDK...")
            client = genai.Client(api_key=api_key)
            prompt = f"""
Você é o Agente de Inteligência Artificial do macOS para resumo executivo diário de e-mails.
Com base nas seguintes mensagens da Caixa de Entrada do Apple Mail:

{msg_summary_block}

Gere um relatório executivo sucinto contendo:
1. 🎯 Destaques de Prioridade Alta (Mensagens VIP ou urgentes que exigem ação hoje)
2. 📋 Resumo Consolidado por Temas/Assuntos
3. 💡 Ações Sugeridas / Checklist de Tarefas

Seja claro, objetivo e em Português do Brasil.
"""
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt
            )
            return response.text
        except Exception as e:
            print(f"⚠️ Erro ao chamar a API Gemini ({e}). Usando gerador estruturado interno.")

    # Fallback structured summary
    report = [
        f"# 📬 Resumo Diário de E-mails - {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"- **Total de Mensagens Não Lidas**: {len(messages)}",
        f"- **VIPs Encontrados**: {vip_count}",
        f"- **Urgentes Identificados**: {urgent_count}",
        "",
        "## 📌 Principais Mensagens Detectadas",
        msg_summary_block if msg_summary_block else "Nenhuma mensagem não lida encontrada."
    ]
    return "\n".join(report)


def notify_macos(title: str, message: str):
    """Send native macOS System Notification."""
    applescript = f'display notification "{message}" with title "{title}" sound name "Glass"'
    subprocess.run(["osascript", "-e", applescript], capture_output=True)


def run_audit():
    """Main daemon execution workflow."""
    print("🚀 Iniciando Auditoria Matinal de E-mail com IA & Banco de Dados...")
    init_db()
    config = get_all_config()
    max_scan = int(config.get("max_scan_limit", 150))

    messages = extract_unread_emails(max_count=max_scan)
    total_unread = len(messages)
    
    vip_senders = [s.strip().lower() for s in config.get("vip_senders", "").split(",") if s.strip()]
    urgent_keywords = [k.strip().lower() for k in config.get("urgent_keywords", "").split(",") if k.strip()]
    
    vip_count = sum(1 for m in messages if any(v in m["sender"].lower() for v in vip_senders))
    urgent_count = sum(1 for m in messages if any(u in m["subject"].lower() for u in urgent_keywords))

    summary_text = generate_ai_summary(messages, config)

    # Save to Desktop folder
    desktop_folder = Path.home() / "Desktop" / "Auditoria-Mail"
    desktop_folder.mkdir(parents=True, exist_ok=True)
    report_file = desktop_folder / f"resumo-mail-{datetime.now().strftime('%Y-%m-%d')}.md"
    
    with open(report_file, "w", encoding="utf-8") as f:
        f.write(summary_text)

    # Log to SQLite DB
    log_mail_audit(
        total_unread=total_unread,
        vip_count=vip_count,
        urgent_count=urgent_count,
        summary_text=summary_text,
        status="SUCCESS"
    )

    # Trigger notification
    notif_msg = f"{total_unread} não lidas ({vip_count} VIP / {urgent_count} urgentes). Relatório salvo em ~/Desktop/Auditoria-Mail/"
    notify_macos("🤖 Resumo IA do Apple Mail", notif_msg)

    print(f"✅ Auditoria concluída! Relatório salvo em: {report_file}")
    print(f"📊 Registrado no Banco de Dados SQLite em: ~/Library/Application Support/MacOS-Use/config.db")


if __name__ == "__main__":
    run_audit()
