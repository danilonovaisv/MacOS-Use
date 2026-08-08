#!/usr/bin/env bash

set -euo pipefail

MODE="${1:---check}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL_DIR="$ROOT_DIR/.claude/skills"

case "$MODE" in
  --check|--apply) ;;
  *)
    echo "usage: $0 [--check|--apply]" >&2
    exit 2
    ;;
esac

if [[ ! -d "$CANONICAL_DIR" ]]; then
  echo "Canonical skills directory is missing: $CANONICAL_DIR" >&2
  exit 1
fi

pending=0
errors=0

repair_root() {
  local link_root="$1"
  local entry name target relative_target kind current_target

  if [[ ! -d "$link_root" ]]; then
    echo "Missing skill link directory: $link_root" >&2
    errors=$((errors + 1))
    return
  fi

  while IFS= read -r -d '' entry; do
    kind="$(file -b "$entry")"
    [[ "$kind" == "MacOS Alias file" ]] || continue

    name="$(basename "$entry")"
    target="$CANONICAL_DIR/$name"
    relative_target="../../.claude/skills/$name"
    if [[ ! -e "$target" ]]; then
      echo "Missing canonical target for $entry: $target" >&2
      errors=$((errors + 1))
      continue
    fi

    pending=$((pending + 1))
    if [[ "$MODE" == "--apply" ]]; then
      rm "$entry"
      ln -s "$relative_target" "$entry"
      echo "Linked: ${entry#$ROOT_DIR/} -> $relative_target"
    else
      echo "Needs repair: ${entry#$ROOT_DIR/}"
    fi
  done < <(find "$link_root" -mindepth 1 -maxdepth 1 -type f -print0)

  while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    target="$CANONICAL_DIR/$name"
    relative_target="../../.claude/skills/$name"
    current_target="$(readlink "$entry")"
    if [[ ! -e "$target" ]]; then
      echo "Broken skill link: ${entry#$ROOT_DIR/}" >&2
      errors=$((errors + 1))
    elif [[ "$current_target" != "$relative_target" ]]; then
      echo "Unexpected skill link target: ${entry#$ROOT_DIR/} -> $current_target" >&2
      errors=$((errors + 1))
    fi
  done < <(find "$link_root" -mindepth 1 -maxdepth 1 -type l -print0)
}

clean_canonical_aliases() {
  local entry name target kind

  while IFS= read -r -d '' entry; do
    kind="$(file -b "$entry")"
    [[ "$kind" == "MacOS Alias file" ]] || continue
    name="$(basename "$entry")"
    [[ "$name" == *" alias" ]] || continue

    target="$CANONICAL_DIR/${name% alias}"
    if [[ ! -e "$target" ]]; then
      echo "Canonical alias has no matching target: $entry" >&2
      errors=$((errors + 1))
      continue
    fi

    pending=$((pending + 1))
    if [[ "$MODE" == "--apply" ]]; then
      rm "$entry"
      echo "Removed duplicate Finder alias: ${entry#$ROOT_DIR/}"
    else
      echo "Needs removal: ${entry#$ROOT_DIR/}"
    fi
  done < <(find "$CANONICAL_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
}

clean_canonical_aliases
repair_root "$ROOT_DIR/.agents/skills"
repair_root "$ROOT_DIR/.codex/Skills"

if [[ "$errors" -gt 0 ]]; then
  echo "Skill link repair found $errors error(s)." >&2
  exit 1
fi

if [[ "$MODE" == "--check" && "$pending" -gt 0 ]]; then
  echo "$pending Finder alias(es) need conversion to symbolic links." >&2
  exit 1
fi

echo "Skill links verified. Converted or pending: $pending"
