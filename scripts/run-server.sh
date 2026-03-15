#!/usr/bin/env bash
set -euo pipefail

# Unified llama-server Router Runner
# Leverages Router Mode and Presets for dynamic model management.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_TYPE=$(uname -s)

# Select appropriate preset based on OS
if [ "$OS_TYPE" = "Darwin" ]; then
    PRESET_FILE="${SCRIPT_DIR}/macos-presets.ini"
    CMD_PREFIX=""
else
    PRESET_FILE="${SCRIPT_DIR}/presets.ini"
    # taskset -c 0-7 binds the process to the first 8 physical cores (optimal for 3D V-Cache CCD)
    CMD_PREFIX="taskset -c 0-7"
fi

# Router Configuration
# --models-max 1: Ensures only one model is loaded in VRAM at a time (prevents OOM on 24GB cards)
ROUTER_ARGS=(
    --models-preset "$PRESET_FILE"
    --models-max 1
)

echo "=== Starting Ullama Router Server ==="
echo "OS Detected: $OS_TYPE"
echo "Using Preset: $PRESET_FILE"
echo "Command: $CMD_PREFIX llama-server ${ROUTER_ARGS[*]}"
echo "======================================"

# Execute llama-server
$CMD_PREFIX llama-server "${ROUTER_ARGS[@]}" "$@"
