#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_PORT=8001

log() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

err() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
    exit 1
}

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
