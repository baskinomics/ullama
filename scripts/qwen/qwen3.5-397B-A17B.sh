#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/Qwen3.5-397B-A17B-GGUF model with UD-TQ1_0 quantization
# Usage: ./qwen3.5.sh

llama-server \
    -hf unsloth/Qwen3.5-397B-A17B-GGUF:UD-TQ1_0 \
    --alias "unsloth/Qwen3.5-397B-A17B" \
    --ctx-size 8192 \
    --n-gpu-layers 99 \
    --threads 12 \
    --batch-size 2048 \
    --ubatch-size 512 \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --flash-attn on \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 40 \
    --port 8001 \
    --jinja --mlock
