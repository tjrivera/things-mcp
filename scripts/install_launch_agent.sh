#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
TEMPLATE_PATH="$PROJECT_DIR/launchd/com.things-mcp.server.plist"
TARGET_DIR="$HOME/Library/LaunchAgents"
TARGET_PATH="$TARGET_DIR/com.things-mcp.server.plist"

mkdir -p "$TARGET_DIR"
perl -0pe "s|__REPO_DIR__|$PROJECT_DIR|g" "$TEMPLATE_PATH" > "$TARGET_PATH"
chmod 600 "$TARGET_PATH"
plutil -lint "$TARGET_PATH"
echo "Installed LaunchAgent to $TARGET_PATH"
