#!/usr/bin/env bash
set -euo pipefail

readonly SOURCE_FILE="opencode.jsonc"
readonly DEST_DIR="$HOME/.config/opencode"
readonly DEST_FILE="$DEST_DIR/opencode.jsonc"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/logging.sh"

main() {
  [[ -f "$SOURCE_FILE" ]] || err "Source file '$SOURCE_FILE' not found"
  mkdir -p "$DEST_DIR"
  cp "$SOURCE_FILE" "$DEST_FILE"
  log "Copied $SOURCE_FILE to $DEST_FILE"
}

main "$@"
