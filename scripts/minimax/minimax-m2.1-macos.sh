#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/MiniMax-M2.1-GGUF model with IQ3_XXS quantization (macOS)
# Usage: ./minimax-m2.1-macos.sh

llama-server -hf unsloth/MiniMax-M2.1-GGUF:IQ3_XXS \
    --alias "unsloth/MiniMax-M2.1" \
    --fit on \
    --seed 3407 \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 40 \
    --min-p 0.01 \
    --ctx-size 16384 \
    --port 8001 \
    --jinja