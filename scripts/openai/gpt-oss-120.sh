#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/gpt-oss-120b-GGUF model with F16 quantization
# Usage: ./gpt-oss-120.sh

llama-server -hf unsloth/gpt-oss-120b-GGUF:F16 \
    --alias "unsloth/gpt-oss-120B" \
    --fit on \
    --flash-attn on \
    --seed 3407 \
    --temp 1.0 \
    --top-p 1.0 \
    --top-k 100.0 \
    --ctx-size 32768 \
    --port 8001 \
    --jinja \
    --chat-template-kwargs '{"reasoning_effort": "high"}'
