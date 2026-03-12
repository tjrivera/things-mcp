#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
TARGET_PATH="$HOME/Library/LaunchAgents/com.things-mcp.server.plist"

"$SCRIPT_DIR/install_launch_agent.sh"
launchctl unload "$TARGET_PATH" 2>/dev/null || true
tmux kill-session -t things-mcp-http 2>/dev/null || true
launchctl load "$TARGET_PATH"
echo "Reloaded LaunchAgent from $TARGET_PATH"
