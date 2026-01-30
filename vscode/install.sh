#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_SRC="$ROOT_DIR/vscode/settings.json"
EXTENSIONS_SRC="$ROOT_DIR/vscode/extensions.txt"

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
SETTINGS_DEST="$VSCODE_USER_DIR/settings.json"

mkdir -p "$VSCODE_USER_DIR"

ln -sf "$SETTINGS_SRC" "$SETTINGS_DEST"
echo "Linked VS Code settings to $SETTINGS_DEST"

CODE_BIN=""
if command -v code >/dev/null 2>&1; then
  CODE_BIN="code"
elif [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [ -z "$CODE_BIN" ]; then
  echo "VS Code CLI not found. Skipping extension install."
  exit 0
fi

while IFS= read -r ext; do
  [ -z "$ext" ] && continue
  "$CODE_BIN" --install-extension "$ext" >/dev/null
  echo "Installed $ext"
done < "$EXTENSIONS_SRC"
