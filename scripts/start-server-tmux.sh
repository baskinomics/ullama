#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/logging.sh"

SESSION_NAME="ullama-server"
PORT=8001

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    log "Session '$SESSION_NAME' already exists."
    echo "Options:"
    echo "  Attach:  tmux attach -t $SESSION_NAME"
    echo "  Kill:    tmux kill-session -t $SESSION_NAME"
    echo "  List:    tmux list-sessions"
    exit 0
fi

log "Creating new tmux session: $SESSION_NAME"
log "Starting llama-server with host 0.0.0.0:$PORT..."

tmux new-session -d -s "$SESSION_NAME" \
    "cd $SCRIPT_DIR && ./run-server.sh --host 0.0.0.0"

log "Server started in tmux session '$SESSION_NAME'"
echo ""
echo "=== Instructions ==="
echo "1. Detach from tmux: Press Ctrl+b, then d"
echo "2. Exit SSH: type 'exit'"
echo ""
echo "=== Later, to reconnect ==="
echo "  ssh zoo@jupiter"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "=== To stop the server ==="
echo "  tmux kill-session -t $SESSION_NAME"

