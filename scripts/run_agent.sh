#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required. Install it before running macOS-Use." >&2
  exit 1
fi

export ANONYMIZED_TELEMETRY="${ANONYMIZED_TELEMETRY:-false}"

MODE="${1:-run}"
case "$MODE" in
  run)
    shift || true
    exec uv run --frozen python -m macos_use.main "$@"
    ;;
  --check|check)
    shift || true
    exec uv run --frozen python -m macos_use.main --check "$@"
    ;;
  --dry-run|dry-run)
    shift || true
    exec uv run --frozen python -m macos_use.main --dry-run "$@"
    ;;
  --logs|logs)
    shift || true
    exec uv run --frozen python -m macos_use.main --logs "$@"
    ;;
  --verify|verify)
    shift || true
    uv run --frozen python -m unittest discover -s tests
    exec uv run --frozen python -m macos_use.main --check "$@"
    ;;
  *)
    exec uv run --frozen python -m macos_use.main "$@"
    ;;
esac
