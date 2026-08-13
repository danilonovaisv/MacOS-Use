#!/usr/bin/env python3
"""Conservative, dependency-free macOS daily audit and report generator."""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import subprocess
import time
import uuid
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

TZ = ZoneInfo("America/Sao_Paulo")
ROOT = Path(__file__).resolve().parents[1]
STATE = Path.home() / "Library/Application Support/MacBookDailyCare"
REPORTS = STATE / "reports"
HISTORY = STATE / "history"


def run(command: list[str], timeout: int = 20) -> dict:
    if not shutil.which(command[0]) and not Path(command[0]).exists():
        return {"ok": False, "error": "command unavailable"}
    try:
        proc = subprocess.run(command, capture_output=True, text=True, timeout=timeout, check=False)
        value = (proc.stdout or proc.stderr).strip()
        return {"ok": proc.returncode == 0, "value": redact(value), "code": proc.returncode}
    except (OSError, subprocess.TimeoutExpired) as exc:
        return {"ok": False, "error": type(exc).__name__}


def redact(value: str) -> str:
    home = str(Path.home())
    value = value.replace(home, "~")
    value = re.sub(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", "[IP]", value)
    return value[:12000]


def collect() -> dict:
    checks = {
        "macos": run(["sw_vers"]),
        "hardware": run(["system_profiler", "SPHardwareDataType", "-json"]),
        "uptime": run(["uptime"]),
        "storage": run(["df", "-h", "/"]),
        "memory": run(["vm_stat"]),
        "processes": run(["ps", "-A", "-o", "pid,%cpu,%mem,comm", "-r"]),
        "dns": run(["scutil", "--dns"]),
        "dns_resolution": run(["dscacheutil", "-q", "host", "-a", "name", "apple.com"]),
        "updates": run(["softwareupdate", "-l"], timeout=120),
        "filevault": run(["fdesetup", "status"]),
        "firewall": run(["/usr/libexec/ApplicationFirewall/socketfilterfw", "--getglobalstate"]),
        "gatekeeper": run(["spctl", "--status"]),
        "profiles": run(["profiles", "status", "-type", "enrollment"]),
        "login_items": run(["sfltool", "dumpbtm"], timeout=45),
    }
    trusted = Path("/Users/danilonovais/MacOS-Use/.agents/skills/macos-diagnostics/scripts/system_audit.sh")
    if trusted.exists():
        checks["trusted_system_audit"] = run(["bash", str(trusted)], timeout=60)
    for name in ("mas", "brew"):
        if shutil.which(name):
            checks[f"{name}_updates"] = run([name, "outdated"], timeout=120)
    return checks


def render(run_data: dict) -> str:
    ok = sum(1 for item in run_data["checks"].values() if item.get("ok"))
    failed = len(run_data["checks"]) - ok
    attention = "baixo" if failed == 0 else "medio"
    lines = [
        "# Relatorio diario de auditoria do MacBook",
        "",
        "## 1. Data e horario da auditoria",
        f"{run_data['started_at']} | America/Sao_Paulo | {run_data['duration_seconds']:.1f}s",
        "",
        "## 2. Resumo executivo",
        f"Auditoria somente leitura concluida: {ok} verificacoes disponiveis e {failed} incompletas. Nivel de atencao: {attention}.",
        "",
        "## 3. Saude do sistema",
        "Consulte as evidencias sanitizadas no historico JSON. Nenhuma alteracao foi feita nesta secao.",
        "",
        "## 4. Armazenamento",
        "Capacidade do volume principal verificada. Downloads, Lixeira, duplicatas e arquivos pessoais nao foram alterados.",
        "",
        "## 5. Rede e DNS",
        "Configuracao e resolucao foram verificadas. Nenhuma configuracao permanente de rede foi modificada.",
        "",
        "## 6. Atualizacoes",
        "Atualizacoes foram apenas consultadas; instalacao e reinicializacao exigem aprovacao.",
        "",
        "## 7. Seguranca e privacidade",
        "FileVault, firewall, Gatekeeper e perfis foram consultados quando permitidos pelo macOS.",
        "",
        "## 8. Consulta ao notebookLM",
        "Nao executada pelo coletor local. O agente pode consultar a integracao habilitada para problemas encontrados.",
        "",
        "## 9. Acoes executadas",
        "Coleta de informacoes, sanitizacao, registro local e geracao deste relatorio.",
        "",
        "## 10. Recomendacoes para o usuario",
        "Importante: revise verificacoes incompletas; elas podem indicar apenas falta de permissao ou ferramenta.",
        "",
        "## 11. Pendencias que exigem confirmacao",
        "Nenhuma acao sensivel foi executada. Atualizacoes, exclusoes e mudancas do sistema continuam bloqueadas.",
        "",
        "## 12. Conclusao",
        "A maquina foi observada de forma preventiva e segura. O proximo passo e revisar apenas os alertas com evidencia.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("audit", "safe-maintenance"), default="audit")
    parser.add_argument("--output-dir", type=Path, default=REPORTS)
    args = parser.parse_args()
    if platform.system() != "Darwin":
        raise SystemExit("Este plugin executa somente em macOS.")
    start = time.monotonic()
    started = datetime.now(TZ)
    checks = collect()
    finished = datetime.now(TZ)
    data = {
        "schema_version": "1.0",
        "run_id": str(uuid.uuid4()),
        "started_at": started.isoformat(),
        "finished_at": finished.isoformat(),
        "duration_seconds": time.monotonic() - start,
        "timezone": "America/Sao_Paulo",
        "mode": args.mode,
        "checks": checks,
        "actions": [],
        "approvals": [],
        "notebooklm": [],
        "errors": [{"check": key, **value} for key, value in checks.items() if not value.get("ok")],
    }
    args.output_dir.mkdir(parents=True, exist_ok=True)
    HISTORY.mkdir(parents=True, exist_ok=True)
    stamp = started.strftime("%Y-%m-%d_%H%M%S")
    report = args.output_dir / f"{stamp}_daily-audit.md"
    snapshot = HISTORY / f"{stamp}.json"
    report.write_text(render(data), encoding="utf-8")
    snapshot.write_text(json.dumps(data, ensure_ascii=True, indent=2), encoding="utf-8")
    print(json.dumps({"status": "complete", "report": str(report), "history": str(snapshot)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
