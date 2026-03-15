#!/usr/bin/env bash
set -euo pipefail

# Script to run Tesslate/OmniCoder-9B-GGUF model with Q8_0 quantization
# Usage: ./omnicoder-9B.sh

args=(
    -hf Tesslate/OmniCoder-9B-GGUF:Q8_0
    --alias "Tesslate/OmniCoder-9B"
    --ctx-size 262144
    --threads 8
    --threads-batch 16
    --batch-size 4096
    --ubatch-size 4096
    --flash-attn on
    --fit on
    --seed 3407
    --temp 0.4
    --top-p 0.95
    --presence-penalty 0.0
    # --min-p 0.01
    # --top-k 40
    --port 8001
    --jinja
    # Logging
    --log-file OmniCoder-9B-logs.txt
)

# taskset -c 0-7 binds the process exclusively to physical cores 0 through 7
taskset -c 0-7 llama-server "${args[@]}"
