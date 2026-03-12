#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
PYTHON_BIN="$PROJECT_DIR/.venv/bin/python3"
export HOME="${HOME:-$PROJECT_DIR}"
export PATH="$PROJECT_DIR/.venv/bin:/Users/zephyr/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export THINGS_MCP_TRANSPORT="${THINGS_MCP_TRANSPORT:-http}"
export THINGS_MCP_HOST="${THINGS_MCP_HOST:-0.0.0.0}"
export THINGS_MCP_PORT="${THINGS_MCP_PORT:-8718}"

cd "$PROJECT_DIR"
exec "$PYTHON_BIN" things_server.py
