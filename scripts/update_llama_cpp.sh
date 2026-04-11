#!/usr/bin/env bash
set -euo pipefail

# Use absolute path for SCRIPT_DIR to avoid issues with how dirname handles BASH_SOURCE
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/logging.sh"

readonly TARGET_DIR="${HOME}/workspace/machine-learning/llama.cpp"
readonly BUILD_DIR="${TARGET_DIR}/build"

main() {
    [[ -d "${TARGET_DIR}" ]] || err "Directory not found: ${TARGET_DIR}"

    log "Navigating to ${TARGET_DIR}"
    cd "${TARGET_DIR}"

    log "Pulling latest upstream changes..."
    git fetch origin
    git rebase origin/master || err "Rebase failed. Resolve conflicts manually."

    log "Cleaning previous build artifacts..."
    rm -rf "${BUILD_DIR}"

    log "Configuring CMake (CUDA enabled)..."
    cmake -B "${BUILD_DIR}" \
          -DCMAKE_BUILD_TYPE=Release \
          -DGGML_CUDA=ON

    log "Compiling using $(nproc) threads..."
    cmake --build "${BUILD_DIR}" --config Release -j"$(nproc)"

    log "Build completed successfully."
}

main "$@"

