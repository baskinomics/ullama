#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/logging.sh"

readonly DEFAULT_PORT=8001

usage() {
    echo "Usage: $0 [port]"
    echo "  port: The port to ensure is open in the firewall (default: $DEFAULT_PORT)"
}

main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        usage
        exit 0
    fi
    local port="${1:-$DEFAULT_PORT}"
    ensure_port_open "$port"
}

main "$@"

