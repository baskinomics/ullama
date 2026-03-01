#!/usr/bin/env bash
set -euo pipefail

readonly TARGET_DIR="${HOME}/workspace/machine-learning/llama.cpp"
readonly BUILD_DIR="${TARGET_DIR}/build"

log() {
    echo -e "\033[1;34m==>\033[0m $*"
}

err() {
    echo -e "\033[1;31mERROR:\033[0m $*" >&2
    exit 1
}

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
