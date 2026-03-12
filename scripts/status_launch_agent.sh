#!/bin/zsh
set -euo pipefail

launchctl list | grep 'com.things-mcp.server' || true
tmux ls 2>/dev/null | grep 'things-mcp-http' || true
lsof -nP -iTCP:8718 -sTCP:LISTEN || true
