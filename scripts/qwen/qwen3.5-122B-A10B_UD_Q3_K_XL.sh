#!/usr/bin/env bash
set -euo pipefail

# Script to run unsloth/Qwen3.5-122B-A10B-GGUF model with UD-Q3_K_XL quantization
# Usage: ./qwen3.5-122B-A10B_UD_Q3_K_XL.sh

args=(
    -hf unsloth/Qwen3.5-122B-A10B-GGUF:UD-Q3_K_XL
    --alias "unsloth/Qwen3.5-122B-A10B"
    --ctx-size 262144 # [32768, 65536, 131072, 262144]
    --threads 8          # Optimal for keeping workload on the 3D V-Cache CCD
    --threads-batch 16
    # --n-gpu-layers 15    # Maximum number of layers to store in VRAM, either an exact number, 'auto', or 'all' (default: auto) ~35% offload targeting 24GB VRAM
    # --n-cpu-moe 30       # Keep the Mixture of Experts (MoE) weights of the first N layers in the CPU
    --cache-type-k q8_0
    --cache-type-v q8_0
    --batch-size 4096 # 2048
    --ubatch-size 4096 # 2048
    --flash-attn on
    --fit on
    --seed 3407
    --temp 0.6
    --top-p 0.95
    --min-p 0.00
    --top-k 20
    --repeat_penalty 1.05
    --presence-penalty 1.1
    --port 8001
    --jinja
    --log-file qwen3.5-122B-A10B-logs.txt
    # --mlock
    # --no-mmap
)

# taskset -c 0-7 binds the process exclusively to physical cores 0 through 7
taskset -c 0-7 llama-server "${args[@]}"
