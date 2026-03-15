#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/GLM-4.7-Flash-REAP-23B-A3B-GGUF model with Q5_K_XL quantization (macOS)
# Usage: ./glm-4.7-flash-reap-macos.sh

llama-server -hf unsloth/GLM-4.7-Flash-REAP-23B-A3B-GGUF:Q5_K_XL \
    -ngl 999 \
    --alias "unsloth/GLM-4.7-Flash-REAP" \
    --fit on \
    --seed 3407 \
    --temp 0.7 \
    --top-p 1.00 \
    --min-p 0.01 \
    --ctx-size 131072 \
    --port 8001 \
    --jinja
