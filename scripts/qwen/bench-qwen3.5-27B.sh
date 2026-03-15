#!/usr/bin/env bash
set -euo pipefail

# Benchmarking script for Qwen3.5-27B
# Hardware: Ryzen 9 7950X3D, RTX 4090 (24GB VRAM), 64GB RAM

MODEL_PATH="/home/zoo/.cache/llama.cpp/unsloth_Qwen3.5-27B-GGUF_Qwen3.5-27B-UD-Q4_K_XL.gguf"

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found at $MODEL_PATH"
    exit 1
fi

echo "=========================================================="
echo "1. Validating the 3D V-Cache Strategy (Thread Scaling)"
echo "=========================================================="
echo "-> Pinned to V-Cache CCD (0-7) testing 8 threads"
taskset -c 0-7 llama-bench -m "$MODEL_PATH" -p 512 -n 128 -t 8 -ngl 64

echo -e "\n-> Unpinned, testing 8 and 16 threads across the whole CPU"
llama-bench -m "$MODEL_PATH" -p 512 -n 128 -t 8,16 -ngl 64

echo -e "\n=========================================================="
echo "2. The GPU Offload 'Spillover' Penalty (-ngl)"
echo "=========================================================="
echo "-> Test full offload (65) vs the server's negotiated limit (64) vs heavy RAM spill (50)"
taskset -c 0-7 llama-bench -m "$MODEL_PATH" -p 512 -n 128 -t 8 -ngl 50,64,65

echo -e "\n=========================================================="
echo "3. Flash Attention & KV Cache Quantization Impact"
echo "=========================================================="
echo "-> Test Flash Attention (Off vs On) on an 8k prompt"
taskset -c 0-7 llama-bench -m "$MODEL_PATH" -p 8192 -n 128 -t 8 -ngl 64 -fa 0,1

echo -e "\n-> Test KV Cache Quantization (bf16 vs f16 vs q8_0) with Flash Attention on"
for ct in bf16 f16 q8_0; do
    taskset -c 0-7 llama-bench -m "$MODEL_PATH" -p 8192 -n 128 -t 8 -ngl 64 -fa 1 -ctk "$ct" -ctv "$ct"
done

echo -e "\n=========================================================="
echo "4. The 'Script Replica' Benchmark"
echo "=========================================================="
echo "-> Baseline generation and prompt processing speeds"
taskset -c 0-7 llama-bench \
  -m "$MODEL_PATH" \
  -p 512,8192 \
  -n 128,512 \
  -t 8 \
  -ngl 64 \
  -ctk q8_0 \
  -ctv q8_0 \
  -fa 1 \
  -r 3

echo -e "\nBenchmarking complete."
