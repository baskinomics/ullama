#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/NVIDIA-Nemotron-3-Super-120B-A12B-GGUF model with UD-Q3_K_XL quantization
# Usage: ./nemotron-3-super_UD_Q3_K_XL.sh

args=(
    -hf unsloth/NVIDIA-Nemotron-3-Super-120B-A12B-GGUF:UD-Q3_K_XL
    --alias "unsloth/NVIDIA-Nemotron-3-Super-120B-A12B"
    --ctx-size 131072
    --threads 8
    --threads-batch 16
    --cache-type-k q8_0
    --cache-type-v q8_0
    --batch-size 4096
    --ubatch-size 4096
    --flash-attn on
    --fit on
    --seed 3407
    --temp 0.6
    --top-p 0.95
    --min-p 0.01
    # --top-k 40
    --port 8001
    --jinja
    # Logging
    --log-file Nemotron-3-Super-120B-A12B_UD_Q3_K_XL-logs.txt
)

# taskset -c 0-7 binds the process exclusively to physical cores 0 through 7
taskset -c 0-7 llama-server "${args[@]}"
