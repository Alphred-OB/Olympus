#!/usr/bin/env bash
# Install Olympus skills.
#   All, global:      curl -fsSL https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.sh | bash
#   Some, global:     curl -fsSL .../install.sh | bash -s -- titan-the-developer atlas-the-planner
#   This project:     curl -fsSL .../install.sh | bash -s -- --project
set -euo pipefail

REPO="https://github.com/Alphred-OB/Olympus.git"
DEST="$HOME/.claude/skills"
ONLY=()

for arg in "$@"; do
  case "$arg" in
    --project) DEST="$PWD/.claude/skills" ;;
    --dest=*) DEST="${arg#--dest=}" ;;
    *) ONLY+=("$arg") ;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "git is required"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 --quiet "$REPO" "$TMP/olympus"

mkdir -p "$DEST"
count=0
for dir in "$TMP"/olympus/skills/*/; do
  name="$(basename "$dir")"
  if [ "${#ONLY[@]}" -gt 0 ]; then
    match=0
    for o in "${ONLY[@]}"; do [ "$o" = "$name" ] && match=1; done
    [ "$match" -eq 1 ] || continue
  fi
  rm -rf "$DEST/$name"
  cp -R "$dir" "$DEST/$name"
  echo "Installed $name"
  count=$((count + 1))
done

echo "Done. $count skill(s) in $DEST"
