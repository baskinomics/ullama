#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/Nemotron-3-Nano-30B-A3B-GGUF model with Q4_K_XL quantization
# Usage: ./nemotron-3-nano.sh

llama-server -hf unsloth/Nemotron-3-Nano-30B-A3B-GGUF:Q4_K_XL \
    --alias "unsloth/Nemotron-3-Nano-30B-A3B-A3B" \
    --ctx-size 65536 \
    --threads 16 \
    --n-gpu-layers 99 \
    --n-cpu-moe 30 \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --flash-attn on \
    --fit off \
    --seed 3407 \
    --temp 0.6 \
    --top-p 0.95 \
    --min-p 0.01 \
    --top-k 40 \
    --port 8001 \
    --jinja