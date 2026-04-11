#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/logging.sh"

readonly SESSION_NAME="ullama-server"

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

