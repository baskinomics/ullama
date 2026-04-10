#!/usr/bin/env bash
set -euo pipefail

readonly LLAMA_SERVER_BIN="${HOME}/workspace/machine-learning/llama.cpp/build/bin/llama-server"
readonly TARGET_FILE="reference/llama-server.md"

log() {
    echo -e "\033[1;34m==>\033[0m $*"
}

err() {
    echo -e "\033[1;31mERROR:\033[0m $*" >&2
    exit 1
}

main() {
    [[ -f "${LLAMA_SERVER_BIN}" ]] || err "Binary not found: ${LLAMA_SERVER_BIN}"
    
    log "Updating ${TARGET_FILE} from ${LLAMA_SERVER_BIN} --help..."
    
    # Extract only the help content, skipping potential initialization warnings/logs
    # We use a temporary file to ensure we don't truncate the target if the command fails
    TMP_FILE=$(mktemp)
    
    # Run help and capture output.
    # Since llama-server often prints GPU init info to stderr/stdout, 
    # we capture everything and then filter for the "common params" section.
    "${LLAMA_SERVER_BIN}" --help > "${TMP_FILE}" 2>&1
    
    # We want to preserve the help output but it's often preceded by hardware info.
    # To make it a clean markdown file, we wrap it in a code block.
    {
        printf "# \`llama-server\` Help Reference\n\n"
        printf "Updated on: %s\n\n" "$(date)"
        printf "\`\`\`text\n"
        cat "${TMP_FILE}"
        printf "\`\`\`\n"
    } > "${TARGET_FILE}"
    
    rm "${TMP_FILE}"
    log "Successfully updated ${TARGET_FILE}"
}

main "$@"
