#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/GLM-4.5-Air-GGUF model with Q5_K_XL quantization
# Usage: ./glm-4.5-air.sh

llama-server -hf unsloth/GLM-4.5-Air-GGUF:Q5_K_XL \
    --alias "unsloth/GLM-4.5-Air" \
    --threads -1 \
    --n-gpu-layers 999 \
    --prio 3 \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 40 \
    --ctx-size 16384 \
    --jinja