#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/GLM-4.7-Flash-GGUF model with Q8_K_XL quantization
# Usage: ./glm-4.7-flash.sh

llama-server -hf unsloth/GLM-4.7-Flash-GGUF:Q8_K_XL \
    --alias "unsloth/GLM-4.7-Flash" \
    --fit on \
    --seed 3407 \
    --temp 0.7 \
    --top-p 1.00 \
    --min-p 0.01 \
    --ctx-size 131072 \
    --port 8001 \
    --jinja