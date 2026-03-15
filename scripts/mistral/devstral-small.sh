#!/usr/bin/env bash
set -euo pipefail

# Script to run Devstral-Small-2-24B-Instruct-2512-GGUF with Q4_K_XL quantization
# Usage: ./devstral-small.sh

# Model and quantization settings
MODEL_REF="unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:Q4_K_XL"

# Run the model using llama-server
llama-server \
  -hf "${MODEL_REF}" \
  --alias "Devstral-Small-2-24B-Instruct" \
  --fit \
  --seed 3407 \
  --temp 0.7 \
  --top-p 0.9 \
  --ctx-size 65536 \
  --port 8001 \
  --jinja