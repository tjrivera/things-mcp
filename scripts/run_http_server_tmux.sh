#!/bin/zsh
set -euo pipefail

SESSION_NAME="things-mcp-http"
SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
LOG_FILE="/tmp/things-mcp.log"
ERR_FILE="/tmp/things-mcp.error.log"
TMUX_BIN="${TMUX_BIN:-$(command -v tmux)}"

export HOME="${HOME:-$PROJECT_DIR}"
export PATH="$PROJECT_DIR/.venv/bin:/Users/zephyr/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export THINGS_MCP_TRANSPORT="${THINGS_MCP_TRANSPORT:-http}"
export THINGS_MCP_HOST="${THINGS_MCP_HOST:-0.0.0.0}"
export THINGS_MCP_PORT="${THINGS_MCP_PORT:-8718}"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE" "$ERR_FILE"

if ! "$TMUX_BIN" has-session -t "$SESSION_NAME" 2>/dev/null; then
  "$TMUX_BIN" new-session -d -s "$SESSION_NAME" \
    "cd '$PROJECT_DIR' && exec '$PROJECT_DIR/scripts/run_http_server.sh' >>'$LOG_FILE' 2>>'$ERR_FILE'"
fi

while "$TMUX_BIN" has-session -t "$SESSION_NAME" 2>/dev/null; do
  sleep 5
done
