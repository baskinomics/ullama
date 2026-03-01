args=(
    -hf unsloth/Qwen3-Coder-Next-GGUF:Q4_K_XL
    --alias "unsloth/Qwen3-Coder-Next"
    --ctx-size 262144
    # --ctx-size 131072
    # --threads 16
    --threads 8
    --threads-batch 16
    --n-gpu-layers 99
    --n-cpu-moe 30
    --cache-type-k q8_0
    --cache-type-v q8_0
    --batch-size 1024
    --ubatch-size 2048
    --flash-attn on
    --fit off
    --seed 3407
    --temp 0.6
    --top-p 0.95
    --min-p 0.01
    --top-k 40
    # --dry-multiplier 0.8
    --port 8001
    --jinja
)

llama-server "${args[@]}"
