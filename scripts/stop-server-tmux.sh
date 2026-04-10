#!/usr/bin/env bash
set -euo pipefail

readonly SESSION_NAME="ullama-server"

log() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

err() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
    exit 1
}

main() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log "Stopping tmux session: $SESSION_NAME"
        tmux kill-session -t "$SESSION_NAME"
        log "Session '$SESSION_NAME' killed successfully."
    else
        err "Session '$SESSION_NAME' does not exist."
    fi
}

main "$@"
