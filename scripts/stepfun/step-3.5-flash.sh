#!/usr/bin/env bash
set -euo pipefail

# Script to run AesSedai/Step-3.5-Flash-GGUF model with IQ3_XXS quantization
# Usage: ./step-3.5-flash.sh

args=(
    -hf AesSedai/Step-3.5-Flash-GGUF:IQ3_XXS
    --alias "AesSedai/Step-3.5-Flash"
    --ctx-size 262144
    --threads 8
    --threads-batch 16
    --batch-size 4096
    --ubatch-size 4096
    --flash-attn on
    --fit on
    --seed 3407
    --temp 0.6
    --top-p 0.95
    --min-p 0.00
    --top-k 40
    --port 8001
    --jinja
)

# taskset -c 0-7 binds the process exclusively to physical cores 0 through 7
taskset -c 0-7 llama-server "${args[@]}"
