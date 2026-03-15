#!/usr/bin/env bash
set -euo pipefail

# Benchmarking script for Qwen3.5-122B-A10B
# Hardware: Ryzen 9 7950X3D, RTX 4090 (24GB VRAM), 64GB RAM
# Focus: Permuting GPU Offload (-ngl) and CPU MoE Offload (-ncmoe)

# Pointing to the first shard of the model in the local cache (llama.cpp will automatically load the rest)
MODEL_PATH="/home/zoo/.cache/llama.cpp/unsloth_Qwen3.5-122B-A10B-GGUF_UD-Q4_K_XL_Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf"

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found at $MODEL_PATH"
    echo "Please ensure the model has been downloaded via Hugging Face."
    exit 1
fi

echo "=========================================================="
echo "1. GPU Offload (-ngl) and CPU MoE Offload (-ncmoe) Permutations"
echo "=========================================================="
echo "-> Testing a matrix of -ngl and -ncmoe combinations to find the sweet spot"
echo "-> Fixed parameters: 2048 prompt, 128 gen, 8 threads, q8_0 KV cache, Flash Attention ON"
# Testing varying layers of GPU offload and MoE weights kept in CPU RAM
taskset -c 0-7 llama-bench \
  -m "$MODEL_PATH" \
  -p 2048 \
  -n 128 \
  -t 8 \
  -ngl 10,15,20,30,40 \
  -ncmoe 0,10,20,30,48 \
  -ctk q8_0 \
  -ctv q8_0 \
  -fa 1 \
  -r 3

echo -e "\n=========================================================="
echo "2. The 'Script Replica' Benchmark"
echo "=========================================================="
echo "-> Baseline generation and prompt processing speeds based on server script args"
taskset -c 0-7 llama-bench \
  -m "$MODEL_PATH" \
  -p 2048,16384 \
  -n 128,512 \
  -t 8 \
  -ngl 15 \
  -ncmoe 30 \
  -ctk q8_0 \
  -ctv q8_0 \
  -fa 1 \
  -r 3

echo -e "\nBenchmarking complete."